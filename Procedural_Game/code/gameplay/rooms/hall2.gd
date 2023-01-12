extends Spatial

export (String) var InternType:String = "hall"
var SetinPlace:bool = false

func _process(delta):
	var rng = RandomNumberGenerator.new()
	rng.randomize()
	var temp = rng.randi_range(0,3)
	var val = rng.randf_range(0,1.5)
	if temp == 0:
		$OmniLight.light_energy = lerp($OmniLight.light_energy, 1, delta * 5.0)
	if temp >= 1:
		$OmniLight.light_energy = lerp($OmniLight.light_energy,val, delta * 10.0)
	


func _on_VisibilityNotifier_screen_entered():
	self.set_deferred("visible", true)


func _on_VisibilityNotifier_screen_exited():
	self.set_deferred("visible", false)
