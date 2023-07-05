extends CharacterBody2D


const SPEED = 500.0
const JUMP_VELOCITY = -900.0

# プロジェクト設定から重力値を取得する.
var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

## 更新.
func _physics_process(delta: float) -> void:
	# 着地していなければ重力を加算.
	if not is_on_floor():
		velocity.y += gravity * delta

	# ジャンプ.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# 左右で移動.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()
