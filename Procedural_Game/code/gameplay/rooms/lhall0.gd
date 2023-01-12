extends Spatial


export (bool) var DF:bool
export (bool) var DS1:bool
export (bool) var Placed:bool
export (Array) var AdjArray:Array = []
export (String) var InternType:String = "lhall"
onready var Front = $Front
onready var Side = $Side
var SetinPlace:bool = false

func Adjust():
	if AdjArray.empty():
		return
	if !AdjArray.empty():
		for i in AdjArray.size():
			if (AdjArray[0].InternType == "lhall" || AdjArray[0].InternType == "4way"|| AdjArray[0].InternType == "thall"):
				if self.rotation_degrees.y == 0:
					AdjArray[0].global_transform.origin = Front.global_transform.origin + Vector3(0,0,15)
				if self.rotation_degrees.y == 90:
					AdjArray[0].global_transform.origin = Front.global_transform.origin + Vector3(15,0,0)
				if self.rotation_degrees.y == -90:
					AdjArray[0].global_transform.origin = Front.global_transform.origin + Vector3(-15,0,0)
				if self.rotation_degrees.y == -180:
					AdjArray[0].global_transform.origin = Front.global_transform.origin + Vector3(0,0,-15)
			if AdjArray[0].InternType == "hall":
				AdjArray[0].global_transform.origin = Front.global_transform.origin
			
			if (AdjArray[1].InternType == "lhall" || AdjArray[1].InternType == "4way"|| AdjArray[1].InternType == "thall"):
				if self.rotation_degrees.y == 0:
					AdjArray[1].global_transform.origin = Side.global_transform.origin + Vector3(15,0,0)
				if self.rotation_degrees.y == 90:
					AdjArray[1].global_transform.origin = Side.global_transform.origin + Vector3(0,0,-15)
				if self.rotation_degrees.y == -90:
					AdjArray[1].global_transform.origin = Side.global_transform.origin + Vector3(0,0,15)
				if self.rotation_degrees.y == -180:
					AdjArray[1].global_transform.origin = Side.global_transform.origin + Vector3(-15,0,0)
			if AdjArray[1].InternType == "hall":
				AdjArray[1].global_transform.origin = Side.global_transform.origin



func Place():
	$Front/DFront/CollisionShape.set_deferred("disabled", false)
	$Side/DSide/CollisionShape.set_deferred("disabled", false)
	Placed = true


func _physics_process(_delta):
	if Placed:
		if !DF:
			SpawnDoor(0)
		if !DS1:
			SpawnDoor(2)
		Placed = false
	if SetinPlace:
		$Front/Front/CollisionShape.set_deferred("disabled", false)
		$Side/Side/CollisionShape.set_deferred("disabled", false)
		$Front/Front.global_transform.origin.y = 0
		$Side/Side.global_transform.origin.y = 0
		SetinPlace = false
		Adjust()
		
		


func SpawnDoor(placement:int):
	for i in 1:
		var temp = load("res://scenes/game/interactive/doors/door0.tscn").instance()
		var temparray = []
		temparray.append(temp)
		add_child(temp)
		if placement == 0:
			temp.global_transform.origin = $Front/DFront.global_transform.origin
		if placement == 2:
			temp.global_transform.origin = $Side/DSide.global_transform.origin
			temp.rotation_degrees.y = 90
	


func _on_VisibilityNotifier_screen_entered():
	self.set_deferred("visible", true)


func _on_VisibilityNotifier_screen_exited():
	self.set_deferred("visible", false)


func _on_DFront_body_entered(body):
	if body.is_in_group("Door"):
		DF = true
		$Front/DFront/CollisionShape.set_deferred("disabled", true)


func _on_DSide_body_entered(body):
	if body.is_in_group("Door"):
		DS1 = true
		$Side/DSide/CollisionShape.set_deferred("disabled", true)


func _on_Front_body_entered(body):
	if body.is_in_group("SetRoom"):
		AdjArray.append(body.get_parent().get_parent())


func _on_Side_body_entered(body):
	if body.is_in_group("SetRoom"):
		AdjArray.append(body.get_parent().get_parent())
