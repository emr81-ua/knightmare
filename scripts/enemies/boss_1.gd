extends GenericEnemy

var player: Node2D = null
var charge_speed = 200.0  # Velocidad de carga del enemigo
var charge_distance = 300.0  # Distancia mínima para activar la carga

func _ready():
	max_health = 300
	health = max_health  # Salud máxima
	damage = 10   # Daño del enemigo
	base_speed = 100.0  # Velocidad base del enemigo
	
	add_to_group("enemy")  # Añade al enemigo al grupo "enemy"
	var players = get_tree().get_nodes_in_group("player")
	if players.size() > 0:
		player = players[0]
	animated_sprite.play("idle")  # Asegúrate de tener una animación "idle" configurada para este enemigo
	super._ready()

func _physics_process(delta: float) -> void:
	if player != null:
		follow_player(delta)

func follow_player(delta: float) -> void:
	var player_sprite = player.get_node("animated_sprite")
	var distance_to_player = global_position.distance_to(player_sprite.global_position)

	if distance_to_player > charge_distance:
		velocity = (player_sprite.global_position - global_position).normalized() * charge_speed
	else:
		velocity = (player_sprite.global_position - global_position).normalized() * base_speed
		
	move_and_slide()

func get_damage() -> int:
	return damage
