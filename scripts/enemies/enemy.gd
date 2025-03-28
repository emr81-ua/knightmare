extends CharacterBody2D
class_name GenericEnemy

@export var health: int = 100  # Salud del enemigo
@export var max_health: int = 100  # Salud máxima
@export var damage: int = 10   # Daño del enemigo
@export var base_speed: float = 100.0  # Velocidad base del enemigo

@onready var animated_sprite = $animated_sprite
@onready var collision_shape = $CollisionShape2D
@onready var area2d = $Area2D  # Asegúrate de que hay un nodo Area2D para detectar colisiones
@onready var health_bar = $Control/health_bar # Referencia a la barra de vida

var knockback_velocity: Vector2 = Vector2()  # Usamos un vector separado para el knockback
var knockback_timer: float = 0.0  # Tiempo durante el cual el enemigo recibe knockback
var normal_velocity: Vector2 = Vector2()  # Guardamos la velocidad base cuando no está en knockback

func _ready():
	#animated_sprite.play("idle")  # Asegúrate de tener una animación "idle" configurada
	add_to_group("enemy")  # Añade al enemigo al grupo "enemy"
	update_health_bar()  # Configura la barra de vida al iniciar
	normal_velocity = velocity  # Guarda la velocidad base al iniciar

func _process(delta: float) -> void:
	# Si el enemigo está siendo afectado por knockback, reduce su timer
	if knockback_timer > 0:
		knockback_timer -= delta
		# Aplica el movimiento debido al knockback
		velocity = knockback_velocity  # Actualiza la velocidad temporalmente con el knockback
		move_and_slide()  # Ahora no necesita parámetros adicionales
	else:
		# Si no hay knockback, restablece la velocidad base del enemigo
		velocity = normal_velocity  # Restauramos la velocidad base
		move_and_slide()  # Mantén el movimiento normal

func take_damage(amount: int, knockback_force: float, knockback: Vector2 = Vector2(), weapon_speed: float = 0.0) -> void:
	health -= amount
	health = clamp(health, 0, max_health)  # Asegúrate de que la salud no baje de 0
	#animated_sprite.modulate = Color(1, 0, 0)
	apply_knockback(knockback, weapon_speed, knockback_force)
	update_health_bar()
	if health <= 0:
		die()

func apply_knockback(knockback: Vector2, weapon_speed: float, knockback_force: float) -> void:
	if knockback != Vector2():
		# Escala el knockback con la velocidad del arma
		var scaled_knockback = knockback * knockback_force * weapon_speed
		knockback_velocity = scaled_knockback
		knockback_timer = 0.3  # Tiempo de duración del knockback (ajustable)



func die():
	queue_free()

# Método que actualiza la barra de vida
func update_health_bar() -> void:
	if health_bar:
		health_bar.value = float(health) / max_health * health_bar.max_value  # Normaliza la barra

# Método que maneja cuando otro cuerpo entra en el área de colisión
func _on_body_entered(body: Node) -> void:
	pass
