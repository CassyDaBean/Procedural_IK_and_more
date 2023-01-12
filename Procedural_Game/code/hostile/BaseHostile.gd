extends KinematicBody

##--Body Stuff--##
export (String) var Path_Mats:String = "res://assets/shaders/hostile/"
export (int) var MaterialType:int = 0
export (String) var Path_BodyParts:String = "res://scenes/hostile/bodyparts/"
export (int) var BodyType:int = 0
export (int) var LegType:int = 0
export (int) var FeetType:int = 0
export (int) var LegCount:int = 3
export (Vector3) var LegSpacing:Vector3 = Vector3()
var BodyArray:Array = []
var LegArray:Array = []
var FeetArray:Array = []
var LegUp:Array = []

##--Movement--##
export (float) var MoveSpeed:float = 4
var TestVelo:Vector3 = Vector3()
var TestGravity:Vector3 = Vector3(0,0.5,0)
var TestDir:Vector3 = Vector3()
var Target:Vector3 = Vector3.INF
var path:Array = []

##--Attributes--##
export (float) var Global_scale:float = 1
export (Dictionary) var Mutations:Dictionary = {}
 


func _ready():
	scale = Vector3(Global_scale,Global_scale,Global_scale)
	SpawnBody()


func _physics_process(delta):
	var newVelo:Vector3
#	if Target != Vector3.INF:
#		var dir_to_target = global_transform.origin.direction_to(Target).normalized()
#		TestVelo = lerp(TestVelo, MoveSpeed * dir_to_target, 0.5)
#		if self.global_transform.origin.distance_to(Target) < 0.5:
#			find_next_point_in_path()
#	if Target == Vector3.INF:
#		TestVelo *= 0.5
	if Input.is_action_just_pressed("w"):
		TestVelo.z = 1
	if Input.is_action_just_pressed("s"):
		TestVelo.z = -1
	if !$GroundRay2.is_colliding():
		TestVelo -= TestGravity
	if $GroundRay.is_colliding():
		TestVelo.y += 1
	if $GroundRay2.is_colliding():
		TestVelo.y = lerp(TestVelo.y, 0,0.5)
	LegCheck(delta)
	self.move_and_slide(TestVelo *MoveSpeed, Vector3.UP)
	
	


func find_next_point_in_path():
	if path.size() > 0:
		var new_target = path.pop_front()
		new_target.y = global_transform.origin.y
		Target = new_target
	else:
		Target = Vector3.INF


func update_path(new_path: Array):
	path = new_path
	find_next_point_in_path()





func ClearBody():
	if get_node("BodyCont").get_children().empty() || BodyArray.empty():
		return
	if !get_node("BodyCont").get_children().empty() || !BodyArray.empty():
		for child in BodyArray.size():
			if LegArray.empty():
				pass
			if !LegArray.empty():
				LegArray.clear()
			BodyArray[child].queue_free()


func SpawnBody():
	var file = File.new()
	if file.file_exists(Path_BodyParts +"body%s" % str(BodyType) + ".tscn"):
		ClearBody()
		var temp = load(Path_BodyParts +"body%s" % str(BodyType) + ".tscn").instance()
		BodyArray.append(temp)
		get_node("BodyCont").add_child(temp)
		temp.get_node("body%s_Rig/Skeleton/body%s_Mesh" % [str(BodyType), str(BodyType)]).material_override = load(Path_Mats + "hostilemat%s.tres" % str(MaterialType))
		SpawnLegs()


func ClearLegs():
	if LegArray.empty():
		return
	if !LegArray.empty():
		for leg in LegArray.size():
			LegArray[leg].queue_free()
			LegArray.remove(leg)


func SpawnLegs():
	var file = File.new()
	if file.file_exists(Path_BodyParts +"leg%s" % str(LegType) + ".tscn") && !BodyArray.empty():
		ClearLegs()
		for leg in LegCount:
			var temp = load(Path_BodyParts +"leg%s" % str(LegType) + ".tscn").instance()
			LegArray.append(temp)
			BodyArray[0].get_node("body%s_Rig/Skeleton/Legs" % str(BodyType)).add_child(temp)
			temp.rotation.y = PI - leg
			temp.global_transform.origin.x = LegSpacing.x * temp.transform.basis.z.x
			temp.global_transform.origin.z = LegSpacing.z * temp.transform.basis.z.z
			temp.global_transform.origin.y += LegSpacing.y
			temp.get_node("leg%s_Rig/Skeleton/leg%s_Mesh" % [str(LegType), str(LegType)]).material_override = load(Path_Mats + "hostilemat%s.tres" % str(MaterialType))
		if LegCount >= LegArray.size():
			SpawnFeet()
	if !file.file_exists(Path_BodyParts +"leg%s" % str(LegType) + ".tscn"):
		return


func LegCheck(delta):
	if LegArray.empty():
		return
	if !LegArray.empty():
		for i in LegArray.size():
#			if LegUp.size() >= 10:
#				LegUp.clear()
#			if LegArray[i].IKCont.IsLifted:
#				if !LegUp.has(LegArray[i]):
#					LegUp.append(LegArray[i])
#			if !LegArray[i].IKCont.IsLifted:
#				if LegUp.has(LegArray[i]):
#					var temp = LegUp.find(LegArray[i])
#					LegUp.remove(temp)
			if i >= 1 && i < LegArray.size() -1:
				if !LegArray[i - 1].IKCont.IsLifted && !LegArray[i + 1].IKCont.IsLifted:
					LegArray[i].IKCont.UpdateLegs(delta,Vector3(TestVelo.x,0,TestVelo.z ))
			if i == 0:
				if !LegArray[i + 1].IKCont.IsLifted:
					LegArray[i].IKCont.UpdateLegs(delta,Vector3(TestVelo.x ,0,TestVelo.z ))
			if i == LegArray.size() -1:
				if !LegArray[i - 1].IKCont.IsLifted:
					LegArray[i].IKCont.UpdateLegs(delta,Vector3(TestVelo.x ,0,TestVelo.z ))
			


func ClearFeet():
	if FeetArray.empty():
		return
	if !FeetArray.empty():
		for i in FeetArray.size() - 1:
			FeetArray[i].queue_free()
			FeetArray.remove(i)


func SpawnFeet():
	var file = File.new()
	if file.file_exists(Path_BodyParts +"foot%s" % str(FeetType) + ".tscn") && !LegArray.empty():
		ClearFeet()
		for foot in LegArray.size():
			var temp = load(Path_BodyParts +"foot%s" % str(FeetType) + ".tscn").instance()
			FeetArray.append(temp)
			LegArray[foot].get_node("leg%s_Rig/Skeleton/Foot" % str(LegType)).add_child(temp)
	if !file.file_exists(Path_BodyParts +"foot%s" % str(FeetType) + ".tscn"):
		return
