extends Spatial


export (int) var Gen_LayeringAmount:int = 0

onready var Gen_Start = $GenStart
onready var Gen_End = $GenEnd
onready var Gen_TrackerMain = $GenTrackerMain
export (Array) var Gen_LayerArray:Array = []
export (int) var Gen_Seed:int 
export (float) var Gen_RoomSpacing:float = 5
export (int) var Gen_BranchingAmountChance:int = 0 
var Gen_RNG = RandomNumberGenerator.new()
var Gen_Stepping:bool = false
export (bool) var Gen_Done:bool = false
export (bool) var Gen_MainDone:bool = false
export (bool) var Gen_BranchDone:bool = false
export (Array) var Gen_BranchArray:Array = []
var CurrentTrakerPos = Vector3()
var PrevTrackerPos = Vector3(0,1,0)
export (Vector3) var EndPos:Vector3 = Vector3()
var RecenterTarg:bool = false
var SpawnDelay:float = 2.5
export (PackedScene) var DebugRoom
var CanSpawnRoom:bool = true
var PlayerSpawned:bool = false
var AllDone:bool = false
var AllDone2:bool = false
var AllDone3:bool = false
var points:Array = []
func _ready():
	StartLinktree()


func _physics_process(delta):
	if SpawnDelay >0:
		SpawnDelay -= delta *2
	if SpawnDelay <= 0:
		if !Gen_Done:
			LinktreeGen()
		SpawnDelay = 0.1
	if Gen_Done:
		for i in $Rooms.get_children().size():
			$Rooms.get_child(i).Placed = true
		if !PlayerSpawned:
			SpawnPlayer()
			PlayerSpawned = true
		var eee = get_tree().get_nodes_in_group("PlacedRoom")
		for i in eee.size():
			if i == eee.size() -1:
				if eee[i].SetinPlace:
					AllDone = true
		if AllDone && !AllDone2:
			SpawnHostile()
			$AStar.EnableAstar()
			AllDone2 = true
		if AllDone2 && !AllDone3:
			var Trackers = get_tree().get_nodes_in_group("TrackerStatic")
			for t in Trackers.size():
				Trackers[t].queue_free()
			if Trackers.empty() || Trackers.size() == -1:
				AllDone3 = true


func StartLinktree():
	Gen_RNG.randomize()
	Gen_Seed = Gen_RNG.randi() %100
	EndPos = Gen_End.global_transform.origin.snapped(Vector3.ONE)
	print(EndPos)
	print(Gen_Seed)
	LinktreeGen()


func LinktreeGen():
	var dist = Gen_TrackerMain.global_transform.origin.direction_to(EndPos * Gen_RoomSpacing).round()
	if dist != Vector3.ZERO && Gen_TrackerMain.global_transform.origin != PrevTrackerPos && !Gen_MainDone:
		if Gen_Stepping:
			PrevTrackerPos = Gen_TrackerMain.global_transform.origin
			if PrevTrackerPos == get_closest_point(PrevTrackerPos):
				CanSpawnRoom = false
			Gen()
			add_point(PrevTrackerPos)
			Gen_Stepping = false
		if !Gen_Stepping:
			if (dist.x == 1 || dist.x == -1) && (dist.z == 1 || dist.z == -1):
				var rand = Gen_RNG.randi_range(0,1)
				if rand == 0:
					Gen_TrackerMain.global_transform.origin.z += dist.z * Gen_RoomSpacing
				if rand == 1:
					Gen_TrackerMain.global_transform.origin.x += dist.x * Gen_RoomSpacing
			else:
				Gen_TrackerMain.global_transform.origin += dist * Gen_RoomSpacing
			Gen_Stepping = true
	else:
		Gen_MainDone = true
		
		GenBranches()


func RegenBranch():
	if !RecenterTarg && !Gen_BranchDone:
		Gen_TrackerMain.global_transform.origin = Vector3(0,0,0)
		RecenterTarg = true
	if RecenterTarg:
		if !Gen_BranchArray.empty() && !Gen_BranchDone:
			var branchEnd = TempArray[0].global_transform.origin.round()
			var dist2 = Gen_TrackerMain.global_transform.origin.direction_to(branchEnd * Gen_RoomSpacing).round()
			if dist2 != Vector3.ZERO && Gen_TrackerMain.global_transform.origin != PrevTrackerPos :
				if Gen_Stepping:
					PrevTrackerPos = Gen_TrackerMain.global_transform.origin
					if PrevTrackerPos == get_closest_point(PrevTrackerPos):
						CanSpawnRoom = false
					Gen()
					add_point(PrevTrackerPos)
					Gen_Stepping = false
				if !Gen_Stepping:
					if (dist2.x == 1 || dist2.x == -1) && (dist2.z == 1 || dist2.z == -1):
						var rand = Gen_RNG.randi_range(0,1)
						if rand == 0:
							Gen_TrackerMain.global_transform.origin.z += dist2.z * Gen_RoomSpacing
						if rand == 1:
							Gen_TrackerMain.global_transform.origin.x += dist2.x * Gen_RoomSpacing
					else:
						Gen_TrackerMain.global_transform.origin += dist2 * Gen_RoomSpacing
					Gen_Stepping = true
			else:
				Gen_BranchDone = true
	if Gen_BranchDone && !Gen_BranchArray.empty():
		Gen_BranchingAmountChance -= 1
		TempArray.remove(0)
		RecenterTarg = false
		Gen_BranchDone = false


var TempArray:Array = []
var tick:int = 1

func GenBranches():
	
	if tick == 1:
		for gen in Gen_BranchingAmountChance:
			var tempPos = Position3D.new()
			$Branches.add_child(tempPos)
			Gen_BranchArray.append(tempPos)
			TempArray.append(tempPos)
			var trashvec = Vector3(Gen_RNG.randf_range(-25,30) ,0 , Gen_RNG.randf_range(-40,0))
			tempPos.global_transform.origin =  trashvec.snapped(Vector3.ONE)
			if TempArray.size() - 1 >= Gen_BranchingAmountChance:
				tick = 0
	if Gen_BranchingAmountChance <= -1:
		Gen_Done = true
	if Gen_BranchingAmountChance > -1 && !Gen_BranchArray.empty():
		RegenBranch()
		
	


func Gen():
	if $Rooms.get_children().empty():
		var temp = DebugRoom.instance()
		var mmm = load("res://scenes/game/worldgen/TrackerRoomDetect.tscn").instance()
		Gen_LayerArray.append(mmm)
		Gen_LayerArray.append(temp)
		$Rooms.add_child(temp)
		add_child(mmm)
		mmm.global_transform.origin = Gen_TrackerMain.global_transform.origin
		mmm.connect("body_entered", self, "_on_TrackerRoomDetect_body_entered")
		mmm.connect("body_exited", self, "_on_TrackerRoomDetect_body_exited")
		temp.global_transform.origin = Gen_TrackerMain.global_transform.origin
	if CanSpawnRoom:
		var temp = DebugRoom.instance()
		var mmm = load("res://scenes/game/worldgen/TrackerRoomDetect.tscn").instance()
		Gen_LayerArray.append(mmm)
		Gen_LayerArray.append(temp)
		$Rooms.add_child(temp)
		add_child(mmm)
		mmm.global_transform.origin = Gen_TrackerMain.global_transform.origin
		mmm.connect("body_entered", self, "_on_TrackerRoomDetect_body_entered")
		mmm.connect("body_exited", self, "_on_TrackerRoomDetect_body_exited")
		temp.global_transform.origin = Gen_TrackerMain.global_transform.origin
	


func SpawnPlayer():
	var temp = load("res://scenes/game/player/Player0.tscn").instance()
	var parray = []
	parray.append(temp)
	add_child(temp)
	temp.global_transform.origin = $Rooms.get_children().back().global_transform.origin * 2.5


func SpawnHostile():
	var temp = load("res://scenes/hostile/Hostile.tscn").instance()
	var harray = []
	harray.append(temp)
	add_child(temp)
	for i in $Rooms.get_children().size():
		temp.global_transform.origin = $Rooms.get_children()[i -2].global_transform.origin * 2.5


func add_point(Vec: Vector3):
	points.append(Vec)

func get_closest_point(from: Vector3) -> Vector3:
	var point_size = points.size()
	for p in point_size:
		if from.distance_to(points[p]) > 5:
			continue
		elif from.distance_to(points[p]) == 5:
			continue
		elif from.distance_to(points[p]) < 5:
			print(from.distance_to(points[p]))
			return points[p]
	return Vector3.INF
	
	

func _on_TrackerRoomDetect_body_entered(body):
	if body.is_in_group("TrackerColl"):
		CanSpawnRoom = false
		print(body)


func _on_TrackerRoomDetect_body_exited(body):
	if body.is_in_group("TrackerColl"):
		CanSpawnRoom = true



