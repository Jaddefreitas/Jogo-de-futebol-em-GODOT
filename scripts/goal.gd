extends Node3D


@export var score_label : Label
@export var team_name : String
@onready var score := 0


func _on_goal_area_body_exited(body: Node3D) -> void:
	if body.is_in_group("ball"):
		score += 1
		score_label.text = "%s: %d" % [team_name, score]
		await get_tree().create_timer(1.0).timeout
		body.reset()
