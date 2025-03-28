extends Area2D

@export_file() var target_scene
var player_inside = false  # Variable para saber si el jugador está dentro
@onready var message_label = $RichTextLabel # Conectar un Label desde la interfaz

func _ready():
	message_label.hide()  # Ocultamos el mensaje al inicio

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = true
		message_label.text = "Press [E] to start"
		message_label.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_inside = false
		message_label.hide()

func _process(delta: float) -> void:
	if player_inside and Input.is_action_just_pressed("interact"):
		get_tree().change_scene_to_file(target_scene)
