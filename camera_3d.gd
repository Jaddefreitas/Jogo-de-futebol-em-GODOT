extends Camera3D


@onready var player : RigidBody3D = get_node("/root/Main/Player")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(_delta: float) -> void:
	#look_at(player.global_transform.origin, Vector3.UP)
