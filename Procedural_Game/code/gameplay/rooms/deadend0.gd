extends Spatial

export (bool) var Placed:bool
var SetinPlace:bool = false
export (Array) var AdjArray:Array = []
onready var Front = $Front
export (String) var InternType:String = "deadend"
export (bool) var DF:bool
signal obstacle_should_spawn(location)


func Place():
	$Front/DFront/CollisionShape.set_deferred("disabled", false)
	Placed = true


func _physics_process(_delta):
	if Placed:
		if !DF:
			SpawnDoor(0)
		Placed = false
	if SetinPlace:
		$Front/Front/CollisionShape.set_deferred("disabled", false)
		$Front/Front.global_transform.origin.y = 0
		SetinPlace = false
		Adjust()

func Adjust():
	if AdjArray.empty():
		return
	if !AdjArray.empty():
		
		for i in AdjArray.size():
			if (AdjArray[0].InternType == "lhall" || AdjArray[0].InternType == "4way"|| AdjArray[0].InternType == "thall" || AdjArray[0].InterType == "hall" ):
				self.global_transform.origin = AdjArray[0].Front.global_transform.origin
				if self.rotation_degrees.y == 0:
					AdjArray[0].global_transform.origin = Front.global_transform.origin + Vector3(0,0,15)
				if self.rotation_degrees.y == 90:
					AdjArray[0].global_transform.origin = Front.global_transform.origin + Vector3(15,0,0)
			

func SpawnDoor(placement:int):
	for i in 1:
		var temp = load("res://scenes/game/interactive/doors/door0.tscn").instance()
		var temparray = []
		temparray.append(temp)
		add_child(temp)
		if placement == 0:
			temp.global_transform.origin = $Front/DFront.global_transform.origin

func _on_VisibilityNotifier_screen_entered():
	self.set_deferred("visible", true)


func _on_VisibilityNotifier_screen_exited():
	self.set_deferred("visible", false)


func _on_DFront_body_entered(body):
	if body.is_in_group("Door"):
		DF = true
		$Front/DFront/CollisionShape.set_deferred("disabled", true)


func _on_Front_body_entered(body):
	if body.is_in_group("SetRoom"):
		AdjArray.append(body.get_parent().get_parent())
