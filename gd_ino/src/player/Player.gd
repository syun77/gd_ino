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
## 飛び降り中かどうか.
var _is_fall_through = false

# ---------------------------------
# private functions.
# ---------------------------------
## 更新.
func _physics_process(delta: float) -> void:
	_timer_anim += delta
	
	# 着地していなければ重力を加算.
	if not is_on_floor():
		velocity.y += _config.gravity * delta
	
	if _is_fall_through:
		# 飛び降り中.
		if Input.is_action_pressed("ui_down") == false:
			# 飛び降り終了.
			_is_fall_through = false
	elif Input.is_action_pressed("ui_accept") and Input.is_action_pressed("ui_down"):
		# 飛び降り開始.
		_is_fall_through = true
		# 重力を足し込む.
		velocity.y += _config.gravity * delta
	elif Input.is_action_just_pressed("ui_accept") and is_on_floor():
		# ジャンプ.
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
	
	# コリジョンレイヤーの設定.
	_update_collision_layer()

	move_and_slide()

## アニメーションフレーム番号を取得する.
func _get_anim() -> int:
	var t = int(_timer_anim * 8)
	return ANIM_NORMAL_TBL[t%2]

## コリジョンレイヤーの更新.
func _update_collision_layer() -> void:
	var oneway_bit = Common.get_collision_bit(Common.eCollisionLayer.ONEWAY)
	if _is_fall_through:
		# 飛び降り中なのでビットを下げる.
		collision_mask &= ~oneway_bit
	else:
		collision_mask |= oneway_bit
