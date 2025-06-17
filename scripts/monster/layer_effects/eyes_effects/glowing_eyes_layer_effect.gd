extends GPUParticles2D
class_name GlowingEyesLayerEffects

@export var eyes_color: Color = Color.RED

func _ready():
	setup_glowing_eyes()

func setup_glowing_eyes():
	# Configure the material
	#var material = ParticleProcessMaterial.new()
	#process_material = material
	self.process_material
	# Glowing eyes effect
	self.process_material.direction = Vector3(0, -1, 0)
	self.process_material.initial_velocity_min = 10.0
	self.process_material.initial_velocity_max = 20.0
	self.process_material.gravity = Vector3(0, -50, 0)
	self.process_material.scale_min = 0.5
	self.process_material.scale_max = 1.0
	self.process_material.color = self.eyes_color
	
	# Set emission properties
	amount = 50
	lifetime = 2.0
	emitting = true
