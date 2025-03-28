extends Node2D

var ruta = ""

func _on_acc_patio_der_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		get_tree().change_scene_to_file("res://kingdom/patio_derecha.tscn")



func _on_run_start_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		$Start_label.visible_characters=-1
		ruta = "res://game_scenes/field.tscn"
		
		
func _on_run_start_body_exited(body: Node2D) -> void:
	$Start_label.visible_characters=0


func _process(delta: float) -> void:
	if Input.is_action_just_pressed("interact"):
			get_tree().change_scene_to_file(ruta)
