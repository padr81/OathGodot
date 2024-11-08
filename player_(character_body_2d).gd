extends CharacterBody2D

# Character states
var combat_stance = false
var is_dashing = false
var is_attacking = false
var last_direction = "2"  # Track last movement direction for idle animations

# Movement parameters
@export var speed = 200
@export var dash_speed = 400

# Node references
@onready var sprite = $AnimatedSprite2D

func _input(event):
	if event.is_action_pressed("Attack") and combat_stance:
		is_attacking = true
		doAttack()
		if is_attacking:
			print("attacking")
	
	if event.is_action_pressed("CombatStance"):
		combat_stance = !combat_stance
		$WeaponEquipSFX.play()
		update_animation(Vector2.ZERO)
	
	if event.is_action_pressed("dash"):
		is_dashing = true
	elif event.is_action_released("dash"):
		is_dashing = false

func _physics_process(_delta):
	var direction = Vector2.ZERO
	
	# Get input direction
	direction.x = Input.get_axis("ui_left", "ui_right")
	direction.y = Input.get_axis("ui_up", "ui_down")
	
	# Normalize direction to prevent faster diagonal movement
	if direction.length() > 0:
		direction = direction.normalized()
		# Update last_direction only when actually moving
		last_direction = get_direction_number(direction)
	
	# Apply movement speed
	var current_speed = dash_speed if is_dashing else speed
	velocity = direction * current_speed
	
	# Apply movement
	move_and_slide()
	
	# Update animations
	update_animation(direction)

func update_animation(direction: Vector2) -> void:
	if !is_attacking:
		var animation_base = "idle"
		var dir_number = last_direction  # Use last_direction by default (for idle)
		var animation_name = ""
			
		if direction != Vector2.ZERO:
			animation_base = "dash" if is_dashing else "walk"
			dir_number = get_direction_number(direction)
		
		if combat_stance:
			animation_name = "c" + animation_base.capitalize() + dir_number
		else:
			animation_name = animation_base + dir_number
			
		sprite.play(animation_name)

func get_direction_number(direction: Vector2) -> String:
	if direction == Vector2.ZERO:
		return last_direction  # Return last direction instead of defaulting to "2"
	
	if direction.y > 0:
		if direction.x > 0:
			return "3"      # Down-Right
		elif direction.x < 0:
			return "1"      # Down-Left
		else:
			return "2"      # Down
	elif direction.y < 0:
		if direction.x > 0:
			return "9"      # Up-Right
		elif direction.x < 0:
			return "7"      # Up-Left
		else:
			return "8"      # Up
	else:
		if direction.x > 0:
			return "6"      # Right
		else:
			return "4"      # Left

func doAttack() -> void:
	is_attacking = true
	var dir = last_direction
	var anim_to_play = "attack" + dir
	sprite.play(anim_to_play)
	await sprite.animation_finished
	is_attacking = false
