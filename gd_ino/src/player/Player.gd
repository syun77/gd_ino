extends CharacterBody2D
# =================================
# プレイヤー.
# =================================
class_name Player
# ---------------------------------
# const.
# ---------------------------------
var ANIM_NORMAL_TBL = [0, 1]
var ANIM_DEAD_TBL = []

# ---------------------------------
# onready.
# ---------------------------------
## 設定ファイル.
@onready var _config:Config = preload("res://assets/config.tres")
## Sprite.
@onready var _spr = $Sprite

# ---------------------------------
# var.
# ---------------------------------
## アニメーション用タイマー.
var _timer_anim = 0.0
## 左向きかどうか.
var _is_left = true

# ---------------------------------
# private functions.
# ---------------------------------
## 更新.
func _physics_process(delta: float) -> void:
	_timer_anim += delta
	
	# 着地していなければ重力を加算.
	if not is_on_floor():
		velocity.y += _config.gravity * delta

	# ジャンプ.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = _config.jump_velocity * -1

	# 左右で移動.
	var direction := Input.get_axis("ui_left", "ui_right")
	if direction:
		_is_left = (direction > 0.0)
		velocity.x = direction * _config.move_speed
	else:
		velocity.x = move_toward(velocity.x, 0, _config.move_speed)
	_spr.flip_h = _is_left
	_spr.frame = _get_anim()

	move_and_slide()

## アニメーションフレーム番号を取得する.
func _get_anim() -> int:
	var t = int(_timer_anim * 8)
	return ANIM_NORMAL_TBL[t%2]
