extends Spatial


onready var anim = $AnimationPlayer
export (int, "Down, Up, Error") var DoorState:int = 0


func _physics_process(_delta):
	HandleStates()


func HandleStates():
	if DoorState == 0:
		anim.play("Down")
	if DoorState == 1:
		anim.play("Up")


func _on_Detect_body_entered(body):
	if body.is_in_group("Player") || body.is_in_group("Hostile"):
		DoorState = 1


func _on_Detect_body_exited(body):
	if body.is_in_group("Player")|| body.is_in_group("Hostile"):
		DoorState = 0
