extends KinematicBody


var speed = 10
var gravity = -40
var jump = 20
export var full_contact = false

var mouse_sensitivity:float = 0.3

var Input_Vec:Vector2 = Vector2()
var velocity:Vector3 = Vector3()
var Accel:float = 50
export var gravity_vec = Vector3()
export (float) var Rot_Speed:float = 25
export (float) var Cam_Rot:float = 50
export (float) var Friction:float = 100
export (float) var Air_Friction:float = 60
var snap_vec:Vector3 = Vector3.ZERO


onready var head = $Head
onready var ground_check = $GroundCheck


var isCrouching:int = 0
var flashlightstate:int = 0
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg2rad(-event.relative.x * mouse_sensitivity))
		head.rotate_x(deg2rad(-event.relative.y * mouse_sensitivity))
		head.rotation.x = clamp(head.rotation.x, deg2rad(-98), deg2rad(98))
		
func _physics_process(delta):
	if Input.is_action_just_pressed("ui_cancel"):
		get_tree().quit()
	if Input.is_action_just_pressed("q"):
		var mm = get_tree().current_scene.get_node("AStar")
		var ll = get_tree().get_nodes_in_group("Hostile")
		for h in ll.size():
			ll[h].update_path(mm.find_path(ll[h].global_transform.origin, self.global_transform.origin))
	#Movement
	var input = Get_Input()
	var Dir = Get_Dir(input)
	Sprint(Dir)
	Movement(Dir)
	Apply_Friction(Dir, delta)
	Apply_Grav(delta)
	update_Snap()
	Crouch()
	velocity = move_and_slide_with_snap(velocity, snap_vec, Vector3.UP, true)
	Flashlight()


func Movement(Direction):
	if Direction != Vector3.ZERO:
		velocity.x = velocity.move_toward(Direction * speed, Accel ).x
		velocity.z = velocity.move_toward(Direction * speed, Accel ).z


func Apply_Grav(delta):
	full_contact = ground_check.is_colliding()
	if !is_on_floor() && !full_contact:
		velocity.y += gravity * delta
		velocity.y = clamp(velocity.y, gravity, jump)


func Apply_Friction(dir, delta):
	if dir == Vector3.ZERO:
		if is_on_floor() && full_contact:
			velocity = velocity.move_toward(Vector3.ZERO, Friction * delta)
		else:
			velocity.x = velocity.move_toward(dir * speed, Air_Friction * delta).x
			velocity.z = velocity.move_toward(dir * speed, Air_Friction * delta).z

func Get_Input():
	var Inp_Vec = Vector3.ZERO
	Inp_Vec.x = Input.get_action_strength("d") - Input.get_action_strength("a")
	Inp_Vec.z = Input.get_action_strength("s") - Input.get_action_strength("w")
	return Inp_Vec.normalized() if Inp_Vec.length() > 1 else Inp_Vec

func Get_Dir(InputVec):
	var direction = (InputVec.x * transform.basis.x) + (InputVec.z * transform.basis.z)
	return direction

func update_Snap():
	snap_vec = -get_floor_normal() if is_on_floor() else Vector3.DOWN


func Crouch():
	if isCrouching == 0:
		$Foot.transform.origin.y = 1
	if isCrouching == 1:
		$Foot.transform.origin.y = lerp($Foot.transform.origin.y, 1.5, 0.5)
		if $Foot.transform.origin.y >= 1.5:
			isCrouching = 2
	if isCrouching >= 3:
		$Foot.transform.origin.y = lerp($Foot.transform.origin.y, 1, 0.5)
		if $Foot.transform.origin.y <= 1:
			isCrouching = 0
	if Input.is_action_just_pressed("space"):
		isCrouching += 1


func Flashlight():
	if Input.is_action_just_pressed("f"):
		flashlightstate += 1
	if flashlightstate == 0:
		$Head/SpotLight.set_deferred("visible", false)
	if flashlightstate == 1:
		$Head/SpotLight.set_deferred("visible", true)
	if flashlightstate >= 2:
		flashlightstate = 0

func Sprint(Direction):
	if Direction != Vector3.ZERO:
		if Input.is_action_pressed("shift"):
			speed = 15
		if Input.is_action_just_released("shift") || !Input.is_action_pressed("shift"):
			speed = 10
