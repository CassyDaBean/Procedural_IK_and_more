extends Spatial

var SetinPlace:bool = false
export (Array) var AdjArray:Array = []
onready var Front = $Front
onready var Back = $Back
export (String) var InternType:String = "hall"

func _physics_process(_delta):
	if SetinPlace:
		$Back/Back/CollisionShape.set_deferred("disabled", false)
		$Front/Front/CollisionShape.set_deferred("disabled", false)
		$Back/Back.global_transform.origin.y = 0
		$Front/Front.global_transform.origin.y = 0
		SetinPlace = false
		Adjust()

func Adjust():
	if AdjArray.empty():
		return
	if !AdjArray.empty():
		
		for i in AdjArray.size():
			if (AdjArray[0].InternType == "lhall" || AdjArray[0].InternType == "4way"|| AdjArray[0].InternType == "thall" || AdjArray[0].InternType == "hall" || AdjArray[0].InternType == "deadend"):
				self.global_transform.origin = AdjArray[0].Front.global_transform.origin
				if self.rotation_degrees.y == 0:
					AdjArray[0].global_transform.origin = Front.global_transform.origin + Vector3(0,0,15)
				if self.rotation_degrees.y == 90:
					AdjArray[0].global_transform.origin = Front.global_transform.origin + Vector3(15,0,0)
			
			if (AdjArray[1].InternType == "lhall" || AdjArray[1].InternType == "4way"|| AdjArray[1].InternType == "thall" || AdjArray[1].InternType == "deadend"):
				if self.rotation_degrees.y == 0:
					AdjArray[1].global_transform.origin = Back.global_transform.origin + Vector3(0,0,-15)
				if self.rotation_degrees.y == 90:
					AdjArray[1].global_transform.origin = Back.global_transform.origin + Vector3(-15,0,0)
			if AdjArray[1].InternType == "hall":
				AdjArray[1].global_transform.origin = Back.global_transform.origin



func _on_Front_body_entered(body):
	if body.is_in_group("SetRoom"):
		AdjArray.append(body.get_parent().get_parent())


func _on_Back_body_entered(body):
	if body.is_in_group("SetRoom"):
		AdjArray.append(body.get_parent().get_parent())
