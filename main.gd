extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$GoalLeft.score_label = get_node("/root/Main/UserInterface/ScoreLabel_1")
	$GoalRight.score_label = get_node("/root/Main/UserInterface/ScoreLabel_2")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
