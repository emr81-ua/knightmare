extends CharacterBody2D

@export var move_speed: int = 400
@export var roll_speed: int = 600
@export var max_health: int = 100  # Salud máxima del jugador

# Estados y variables globales
enum State { IDLE, RUN, ROLL, DEAD }
var current_state: State = State.IDLE
var current_health: int = max_health
var is_facing_right = true
var can_dash = true
var can_get_hit = true  # Permite recibir daño
var last_walk_sound_time = 0  # Guarda el tiempo de la última reproducción

# Nodos
@onready var animated_sprite = $animated_sprite
@onready var health_bar = $hud/Control/health_bar
@onready var roll_timer = $roll_timer
@onready var can_dash_timer = $can_dash
@onready var damage_timer = $damage_timer # Timer para el efecto de daño
@onready var dash_progress = $hud/Control/dash_cd
@onready var weapon_node = $WeaponNode  # Nodo donde se instanciará el arma
@onready var walk_sound = $walk # Nodo de sonido de pasos

# Referencia al arma equipada
var equipped_weapon: Weapon = null

func _ready():
	# Configura los valores iniciales
	update_health_bar()
	dash_progress.max_value = can_dash_timer.wait_time
	update_dash_progress()

	# Instancia y equipa el arma
	var weapon_scene = load("res://player/weapons/sword.tscn").instantiate()
	equipped_weapon = weapon_scene
	weapon_node.add_child(equipped_weapon)
	print("Arma equipada.")

func _physics_process(delta):
	if current_state == State.DEAD:
		return  # No se realiza ninguna acción si está muerto

	handle_state()
	flip()
	move_and_slide()
	update_animations()
	handle_walk_sound()  # Verifica si debe sonar el sonido de pasos

func _process(delta):
	update_dash_progress()  # Actualiza el progreso del cooldown del dash

# Gestión de estados
func handle_state():
	match current_state:
		State.IDLE:
			handle_idle()
		State.RUN:
			handle_run()
		State.ROLL:
			handle_roll()

func handle_idle():
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down")
	if input_vector != Vector2.ZERO:
		current_state = State.RUN
	elif Input.is_action_just_pressed("roll") and can_dash:
		if input_vector != Vector2.ZERO:
			start_roll()

func handle_run():
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down") * move_speed
	if velocity == Vector2.ZERO:
		current_state = State.IDLE
	elif Input.is_action_just_pressed("roll") and can_dash:
		if velocity != Vector2.ZERO:
			start_roll()

func handle_roll():
	pass  # El roll sigue activo mientras el temporizador esté corriendo

# Acciones del personaje
func start_roll():
	can_dash = false
	current_state = State.ROLL
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down").normalized() * roll_speed
	roll_timer.start()
	can_dash_timer.start()

func take_damage(amount: int):
	if current_state == State.DEAD or current_state == State.ROLL:
		return  # No recibe daño si está muerto o haciendo un dash

	if can_get_hit:
		current_health -= amount
		current_health = max(current_health, 0)
		update_health_bar()

		if current_health <= 0:
			die()
		else:
			animated_sprite.modulate = Color(1, 0, 0)
			damage_timer.start()
			can_get_hit = false

func heal(amount: int):
	if current_state == State.DEAD:
		return

	current_health += amount
	current_health = min(current_health, max_health)
	update_health_bar()

func die():
	current_state = State.DEAD
	velocity = Vector2.ZERO
	animated_sprite.modulate = Color(1, 0.5, 0.5)
	animated_sprite.play("death")
	print("El personaje ha muerto.")
	walk_sound.stop()  # Detener sonido de pasos al morir

# Gestión de eventos
func _on_roll_timer_timeout() -> void:
	if current_state == State.ROLL:
		current_state = State.IDLE
		velocity = Vector2.ZERO

func _on_can_dash_timeout() -> void:
	can_dash = true

func _on_damage_timer_timeout() -> void:
	animated_sprite.modulate = Color(1, 1, 1)
	can_get_hit = true

# Actualización de la barra de vida
func update_health_bar():
	if health_bar:
		health_bar.value = current_health

func update_dash_progress():
	if not can_dash:
		dash_progress.value = dash_progress.max_value - can_dash_timer.time_left
	else:
		dash_progress.value = dash_progress.max_value

# Animaciones y orientación
func update_animations():
	if current_state == State.DEAD:
		return

	match current_state:
		State.IDLE:
			animated_sprite.play("idle")
		State.RUN:
			animated_sprite.play("run")
		State.ROLL:
			animated_sprite.play("roll")

func flip():
	if (is_facing_right and velocity.x < 0) or (not is_facing_right and velocity.x > 0):
		animated_sprite.flip_h = not animated_sprite.flip_h
		is_facing_right = not is_facing_right

# Detección de enemigos
func _on_enemy_entered(body: Node2D) -> void:
	if body.is_in_group("enemy"):
		if body.has_method("get_damage"):
			var damage = body.get_damage()
			print("¡Un enemigo ha entrado en el área y causa ", damage, " de daño!")
			take_damage(damage)

# 🎵 SONIDO DE PASOS 🎵
func handle_walk_sound():
	if current_state == State.RUN:
		var current_time = Time.get_ticks_msec()
		if current_time - last_walk_sound_time >= 150:  # Comprueba si pasaron 100ms
			walk_sound.play()
			last_walk_sound_time = current_time  # Actualiza el tiempo de reproducción
