extends Node2D
class_name Weapon

@export var range: float = 100.0  # Rango máximo desde el caballero
@export var follow_speed: float = 5.0  # Velocidad para seguir al ratón
@export var rotation_offset: float = 0.0  # Offset de rotación predeterminado
@export var damage: int = 50  # Daño base del arma
@export var knockback_force: float = 1.0  # Fuerza reducida del knockback

var knight: Node2D  # Referencia al caballero (el padre)

func _ready():
	# Asegúrate de asignar al caballero como el padre del arma
	knight = get_parent()
