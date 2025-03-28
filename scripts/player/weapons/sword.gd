extends Weapon

# Referencia al área de colisión de la espada
@onready var sword_area: Area2D = $Area2D 
@onready var hit_sound: AudioStreamPlayer2D = $hit  # Sonido de impacto

var previous_position: Vector2 = Vector2()
var speed: float = 0.0

func _ready():
	knockback_force = 1.0 
	damage = 10
	range = 75.0  # Rango específico para la espada
	follow_speed = 5.0  # Velocidad de seguimiento específica
	rotation_offset = deg_to_rad(-90)  # Offset de rotación específico para la espada
	super._ready()
	previous_position = global_position  # Inicializa la posición anterior

func _process(delta: float):
	# Llama al método para seguir el ratón
	follow_mouse(delta)
	# Calcula la velocidad de movimiento del arma
	speed = global_position.distance_to(previous_position) / delta
	
	#if speed > 50 and not swing_sound.playing:  
		#swing_sound.play()
	
	previous_position = global_position

func follow_mouse(delta: float):
	if not knight:
		return

	# Obtiene la posición del ratón en el mundo
	var mouse_pos = get_global_mouse_position()
	# Calcula la dirección desde el caballero hacia el ratón
	var direction = (mouse_pos - knight.global_position).normalized()
	
	# Calcula la posición objetivo del arma dentro del rango
	var distance_to_mouse = knight.global_position.distance_to(mouse_pos)
	var clamped_distance = min(distance_to_mouse, range)
	var target_position = knight.global_position + direction * clamped_distance
	
	# Interpola la posición actual del arma hacia la posición objetivo
	global_position = global_position.lerp(target_position, follow_speed * delta)
	
	# Rota el arma para que el mango apunte al caballero
	var angle_to_knight = (knight.global_position - global_position).angle()
	rotation = angle_to_knight + rotation_offset

# Cuando el área de la espada entra en contacto con un cuerpo (enemigo)
func _on_area_2d_body_entered(body: Node) -> void:
	if body.is_in_group("enemy"):
		var velocity_damage = damage + (speed * 0.1)
		var knockback_direction = (body.global_position - global_position).normalized()
		print("Enemigo golpeado, infligiendo daño.")
		print (velocity_damage)
		print(knockback_direction)
		
		if body.has_method("take_damage"):
			body.take_damage(velocity_damage, knockback_force, knockback_direction, speed)  # Pasa la velocidad como parámetro
		hit_sound.play()
