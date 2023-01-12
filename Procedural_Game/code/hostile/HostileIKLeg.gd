extends Position3D


onready var IK = get_parent().get_node("Skeleton/IK")
onready var RestRay = get_parent().get_parent().get_node("RestRay")
onready var FootRay = get_parent().get_node("Skeleton/Foot/FootCast")
export (bool) var IsLifted:bool = false
export (float) var FootLifting:float = 0
export (float) var FootLiftingMax:float = 0
export (float) var StepDistance:float = 2.5
export (float) var StepHeight:float = 1
export (Vector3) var FootHeightOffset:Vector3 = Vector3(0,0.2,0)
export (float) var Speed:float = 2
export (Vector3) var NewPosition:Vector3
export (Vector3) var OldPosition:Vector3
export (Vector3) var Test:Vector3
var Lerp:float
var CurrentPosition:Vector3
onready var audio = $AudioStreamPlayer3D


func _ready():
	CurrentPosition = self.global_transform.origin
	
	IK.start()
	
	
func UpdateLegs(delta, oop:Vector3):
	self.global_transform.origin = CurrentPosition
	if RestRay.is_colliding():
		if NewPosition.distance_squared_to(RestRay.get_collision_point() + oop) > StepDistance :
			var rng = RandomNumberGenerator.new()
			rng.randomize()
			audio.pitch_scale = rng.randf_range(0.9, 1.05)
			audio.play()
			IsLifted = true
			Lerp = 0;
			NewPosition = RestRay.get_collision_point() + FootHeightOffset + oop
	if Lerp < 1:
		var Footposition:Vector3 = lerp(OldPosition, NewPosition, Lerp)
		Footposition.y += sin(Lerp * PI) *  StepHeight
		
		CurrentPosition = Footposition
		Lerp += delta * Speed
	else:
		OldPosition = NewPosition
	if Lerp >=1:
		IsLifted = false
	
	if get_parent().get_node("Skeleton/Foot/FootCast").is_colliding():
		self.rotation = get_parent().get_node("Skeleton/Foot/FootCast").get_collision_normal()
	if !get_parent().get_node("Skeleton/Foot/FootCast").is_colliding():
		self.rotation = lerp(self.rotation, Vector3(0,0,0), 0.5)

func _physics_process(delta):
	self.global_transform.origin = CurrentPosition
	


func _on_AudioStreamPlayer3D_finished():
	audio.stop()
