extends GenericEnemy

@export var speed: float = 100  # Velocidad del enemigo
@export var move_duration: float = 3.0  # Tiempo en movimiento (en segundos)
@export var pause_duration: float = 1.0  # Tiempo en pausa (en segundos)

var state: String = "moving"  # Estados: "moving" o "paused"
var timer: float = 0.0  # Temporizador para controlar los estados
var random_direction: Vector2 = Vector2()  # Dirección aleatoria de movimiento

func _ready():
	add_to_group("enemy")  # Añade al enemigo al grupo "enemy"
	change_state("moving")  # Inicia en estado "moving"

func _physics_process(delta: float) -> void:
	timer -= delta
	if timer <= 0:
		if state == "moving":
			change_state("paused")
		elif state == "paused":
			change_state("moving")

	if state == "moving":
		move_randomly()
	elif state == "paused":
		velocity = Vector2.ZERO  # Detiene al enemigo
		move_and_slide()

func move_randomly() -> void:
	# Aplica la dirección aleatoria para mover al enemigo
	velocity = random_direction * speed
	move_and_slide()

func change_state(new_state: String) -> void:
	state = new_state
	if state == "moving":
		timer = move_duration
		# Genera una dirección aleatoria válida y asegura que no sea Vector2.ZERO
		while random_direction == Vector2.ZERO:
			random_direction = Vector2(randf() * 2 - 1, randf() * 2 - 1).normalized()
	elif state == "paused":
		timer = pause_duration
