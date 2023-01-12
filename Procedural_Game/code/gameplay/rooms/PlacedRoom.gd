extends Spatial


export (bool) var DF:bool
export (bool) var DB:bool
export (bool) var DS1:bool
export (bool) var DS2:bool
export (bool) var Placed:bool
export (Array) var AdjArray:Array = []
export (String) var InternType:String = "4way"

onready var Front = $Front
onready var Back = $Back
onready var Side = $Side
onready var Side2 = $Side2 

var SetinPlace:bool = false

func Adjust():
	if AdjArray.empty():
		return
	if !AdjArray.empty():
		for i in AdjArray.size():
			if (AdjArray[0].InternType == "lhall" || AdjArray[0].InternType == "4way"|| AdjArray[0].InternType == "thall"||AdjArray[0].InternType == "hall"):
				AdjArray[0].global_transform.origin = Front.global_transform.origin + Vector3(0,0,15)
			
			if (AdjArray[1].InternType == "lhall" || AdjArray[1].InternType == "4way"|| AdjArray[1].InternType == "thall"||AdjArray[1].InternType == "hall"):
				AdjArray[1].global_transform.origin = Back.global_transform.origin + Vector3(0,0,-15)
			if (AdjArray[2].InternType == "lhall" || AdjArray[2].InternType == "4way"|| AdjArray[2].InternType == "thall"||AdjArray[2].InternType == "hall"):
				AdjArray[2].global_transform.origin = Side.global_transform.origin + Vector3(15,0,0)
			
			if (AdjArray[3].InternType == "lhall" || AdjArray[3].InternType == "4way"|| AdjArray[3].InternType == "thall"||AdjArray[3].InternType == "hall"):
				AdjArray[3].global_transform.origin = Side2.global_transform.origin + Vector3(-15,0,0)
			



func Place():
	$Back/DBack/CollisionShape.set_deferred("disabled", false)
	$Front/DFront/CollisionShape.set_deferred("disabled", false)
	$Side/DSide/CollisionShape.set_deferred("disabled", false)
	$Side2/DSide2/CollisionShape.set_deferred("disabled", false)
	Placed = true


func _physics_process(delta):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var temp = rng.randi_range(0,3)
	var val = rng.randf_range(0,1.5)
	if temp == 0:
		$OmniLight.light_energy = lerp($OmniLight.light_energy, 1, delta * 5.0)
	if temp >= 1:
		$OmniLight.light_energy = lerp($OmniLight.light_energy,val, delta * 20.0)
	
	if Placed:
		if !DF:
			SpawnDoor(0)
		if !DB:
			SpawnDoor(1)
		if !DS1:
			SpawnDoor(2)
		if !DS2:
			SpawnDoor(3)
		Placed = false
	if SetinPlace:
		$Back/Back/CollisionShape.set_deferred("disabled", false)
		$Front/Front/CollisionShape.set_deferred("disabled", false)
		$Side/Side/CollisionShape.set_deferred("disabled", false)
		$Side2/Side2/CollisionShape.set_deferred("disabled", false)
		$Side2/Side2.global_transform.origin.y = 0
		$Back/Back.global_transform.origin.y = 0
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
		if placement == 1:
			temp.global_transform.origin = $Back/DBack.global_transform.origin
		if placement == 2:
			temp.global_transform.origin = $Side/DSide.global_transform.origin
			temp.rotation_degrees.y = 90
		if placement == 3:
			temp.global_transform.origin = $Side2/DSide2.global_transform.origin
			temp.rotation_degrees.y = 90
	


func _on_VisibilityNotifier_screen_entered():
	self.set_deferred("visible", true)


func _on_VisibilityNotifier_screen_exited():
	self.set_deferred("visible", false)


func _on_DFront_body_entered(body):
	if body.is_in_group("Door"):
		DF = true
		$Front/DFront/CollisionShape.set_deferred("disabled", true)


func _on_DBack_body_entered(body):
	if body.is_in_group("Door"):
		DB = true
		$Back/DBack/CollisionShape.set_deferred("disabled", true)


func _on_DSide_body_entered(body):
	if body.is_in_group("Door"):
		DS1 = true
		$Side/DSide/CollisionShape.set_deferred("disabled", true)


func _on_DSide2_body_entered(body):
	if body.is_in_group("Door"):
		DS2 = true
		$Side2/DSide2/CollisionShape.set_deferred("disabled", false)


func _on_Front_body_entered(body):
	if body.is_in_group("SetRoom"):
		AdjArray.append(body.get_parent().get_parent())


func _on_Back_body_entered(body):
	if body.is_in_group("SetRoom"):
		AdjArray.append(body.get_parent().get_parent())


func _on_Side_body_entered(body):
	if body.is_in_group("SetRoom"):
		AdjArray.append(body.get_parent().get_parent())


func _on_Side2_body_entered(body):
	if body.is_in_group("SetRoom"):
		AdjArray.append(body.get_parent().get_parent())
