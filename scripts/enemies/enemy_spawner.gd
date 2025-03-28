extends Node2D

@export var enemy_scene: PackedScene  # Escena del enemigo
@export var spawn_area_size: Vector2 = Vector2(100, 100)  # Área de spawn
@export var spawn_interval: float = 0.0  # Intervalo de spawn, configurable desde cualquier escena

@onready var spawn_timer = $spawn_timer

func _ready():
	# Verifica si el intervalo de spawn es mayor que 0
	if spawn_interval != 0:
		# Configura el tiempo de espera del Timer
		spawn_timer.wait_time = spawn_interval
		spawn_timer.start()

func _on_spawn_timer_timeout():
	if spawn_interval != 0:
		spawn_enemy()

func spawn_enemy():
	if enemy_scene:
		# Instancia el enemigo
		var enemy = enemy_scene.instantiate()
		
		# Calcula una posición aleatoria dentro del área de spawn
		var random_position = Vector2(
			randf_range(-spawn_area_size.x / 2, spawn_area_size.x / 2),
			randf_range(-spawn_area_size.y / 2, spawn_area_size.y / 2)
		)
		enemy.position = global_position + random_position

		# Añade el enemigo a la escena principal
		get_tree().current_scene.add_child(enemy)
