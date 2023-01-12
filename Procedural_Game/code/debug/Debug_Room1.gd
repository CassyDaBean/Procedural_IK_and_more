extends Spatial


export (bool) var DoorFront:bool = false
export (bool) var DoorBack:bool = false
export (bool) var DoorLeft:bool = false
export (bool) var DoorRight:bool = false
export (bool) var Placed:bool = false
export (bool) var FullyPlaced:bool = false
var AdjacentRooms:Array = []
export (bool) var Front
export (bool) var Back
export (bool) var Left
export (bool) var Right
var RoomPth:String = "res://scenes/game/rooms/"
var RNG = RandomNumberGenerator.new()

func _ready():
	pass

func _physics_process(delta):
	for i in AdjacentRooms.size():
		if self.global_transform.origin == AdjacentRooms[i].global_transform.origin:
			self.queue_free()
	if Placed && !FullyPlaced:
		HandleRooms()

func HandleRooms():
	##Single Side
	if Front && !Back && !Left && !Right:
		SpawnRoomtype(0)
	if !Front && Back && !Left && !Right:
		SpawnRoomtype(1)
	if !Front && !Back && Left && !Right:
		SpawnRoomtype(2)
	if !Front && !Back && !Left && Right:
		SpawnRoomtype(3)
	
	##Halls
	if Front && Back && !Left && !Right:
		SpawnRoomtype(4)
	if !Front && !Back && Left && Right:
		SpawnRoomtype(5)
	
	##Corners
	if !Front && Back && Left && !Right: # BackLeft
		SpawnRoomtype(6)
	if !Front && Back && !Left && Right: # BackRight
		SpawnRoomtype(7)
	if Front && !Back && Left && !Right: # FrontLeft
		SpawnRoomtype(8)
	if Front && !Back && !Left && Right: # FrontRight
		SpawnRoomtype(9)
	
	#Four Ways
	if Front && Back && Left && Right: 
		SpawnRoomtype(10)
	
	#Three Way
	if Front && !Back && Left && Right: 
		SpawnRoomtype(11)
	if !Front && Back && Left && Right: 
		SpawnRoomtype(12)
	if Front && Back && !Left && Right: 
		SpawnRoomtype(13)
	if Front && Back && Left && !Right: 
		SpawnRoomtype(14)
	FullyPlaced = true
	


func SpawnRoomtype(Type:int):
	RNG.randomize()
	var ech = RNG.randi_range(0,2)
	
	
	if Type == 0 || Type == 1 || Type == 2 || Type == 3:
		for i in 1:
			var temp = load(RoomPth + "deadend0.tscn").instance()
			var temparray = []
			temparray.append(temp)
			get_tree().current_scene.add_child(temp)
			temp.global_transform.origin = self.global_transform.origin * 2.5
			if Type == 0:
				temp.SetinPlace = true
			if Type == 1:
				temp.rotation_degrees.y = -180
				temp.SetinPlace = true
			if Type == 2:
				temp.rotation_degrees.y = -90
				temp.SetinPlace = true
			if Type ==3:
				temp.rotation_degrees.y = 90
				temp.SetinPlace = true
			temp.Place()
		
		
	if Type == 4 || Type == 5:
		for i in 1:
			var temp = load(RoomPth + "hall%d.tscn" % ech).instance()
			var temparray = []
			temparray.append(temp)
			get_tree().current_scene.add_child(temp)
			temp.global_transform.origin = self.global_transform.origin * 2.5
			if Type == 4:
				temp.SetinPlace = true
			if Type == 5:
				temp.rotation_degrees.y = 90
				temp.SetinPlace = true
			
	if Type == 6 || Type == 7 || Type == 8 || Type == 9:
		for i in 1:
			var temp = load(RoomPth + "lhall0.tscn").instance()
			var temparray = []
			temparray.append(temp)
			get_tree().current_scene.add_child(temp)
			temp.global_transform.origin = self.global_transform.origin * 2.5
			if Type == 6:
				temp.rotation_degrees.y = -180
			if Type == 7:
				temp.rotation_degrees.y = 90
			if Type == 8:
				temp.rotation_degrees.y = -90
			if Type == 9:
				temp.rotation_degrees.y = 0
			temp.SetinPlace = true
			temp.Place()
	if Type == 10:
		for i in 1:
			var temp = load(RoomPth + "4way0.tscn").instance()
			var temparray = []
			temparray.append(temp)
			get_tree().current_scene.add_child(temp)
			temp.global_transform.origin = self.global_transform.origin * 2.5
			temp.SetinPlace = true
			temp.Place()
	
	if Type == 11 || Type == 12 || Type == 13 || Type == 14:
		for i in 1:
			var temp = load(RoomPth + "thall0.tscn").instance()
			var temparray = []
			temparray.append(temp)
			get_tree().current_scene.add_child(temp)
			temp.global_transform.origin = self.global_transform.origin * 2.5
			if Type == 11:
				temp.rotation_degrees.y = 0
			if Type == 12:
				temp.rotation_degrees.y = -180
			if Type == 13:
				temp.rotation_degrees.y = 90
			if Type == 14:
				temp.rotation_degrees.y = -90
			temp.SetinPlace = true
			temp.Place()
	



func _on_Forward_body_entered(body):
	if body.is_in_group("Room"):
		$BaseRoom/Front.set_deferred("visible", true)
		Front = true
		AdjacentRooms.append(body)


func _on_Back_body_entered(body):
	if body.is_in_group("Room"):
		$BaseRoom/Back.set_deferred("visible", true)
		Back = true
		AdjacentRooms.append(body)


func _on_Left_body_entered(body):
	if body.is_in_group("Room"):
		$BaseRoom/Left.set_deferred("visible", true)
		Left = true
		AdjacentRooms.append(body)


func _on_Right_body_entered(body):
	if body.is_in_group("Room"):
		$BaseRoom/Right.set_deferred("visible", true)
		Right = true
		AdjacentRooms.append(body)



