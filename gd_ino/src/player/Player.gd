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
## 方向.
var _direction = 0
## 踏んでいる床.
var _stompTile = Map.eType.NONE

# ---------------------------------
# private functions.
# ---------------------------------
## 更新.
func _physics_process(delta: float) -> void:
	_timer_anim += delta
	
	# move_and_slide()で足元のタイルを判定したいので
	# 常に重力を加算.
	velocity.y += _config.gravity
	
	if _is_fall_through:
		# 飛び降り中.
		if Input.is_action_pressed("ui_down") == false:
			# 飛び降り終了.
			_is_fall_through = false
	elif Input.is_action_pressed("ui_accept") and Input.is_action_pressed("ui_down"):
		# 飛び降り開始.
		_is_fall_through = true
	elif checkJump():
		# 設置していたらジャンプ.
		velocity.y = _config.jump_velocity * -1
	
	# 左右移動の更新.
	_update_horizontal_moving()
	# 向きを更新.
	_is_left = (_direction > 0.0)
	_spr.flip_h = _is_left
	_spr.frame = _get_anim()
	
	# コリジョンレイヤーの設定.
	_update_collision_layer()

	move_and_slide()
	if is_on_floor():
		_is_fall_through = false # 着地したら飛び降り終了.
	
	_update_collision_post(delta)

## ジャンプチェック.
func checkJump() -> bool:
	if Input.is_action_just_pressed("ui_accept") == false:
		# ジャンプボタンを押していない.
		return false
	if is_on_floor() == false:
		# 接地していない.
		return false
	
	# ジャンプする.
	return true
	
## 左右移動の更新.
func _update_horizontal_moving() -> void:
	# 左右キーで移動.
	if Input.is_action_pressed("ui_left"):
		_direction = -1
	elif Input.is_action_pressed("ui_right"):
		_direction = 1

	var MOVE_SPEED = _config.move_speed
	var AIR_ACC_RATIO = _config.air_acc_ratio
	var GROUND_ACC_RATIO = _config.ground_acc_ratio
	
	if is_on_floor() == false:
		# 空中移動.
		velocity.x = velocity.x * (1.0 - AIR_ACC_RATIO) + _direction * MOVE_SPEED * AIR_ACC_RATIO
	else:
		# 地上の移動
		velocity.x = velocity.x * (1.0 - GROUND_ACC_RATIO) + _direction * MOVE_SPEED * GROUND_ACC_RATIO
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

func _update_collision_post(delta:float) -> void:
	# 衝突したコリジョンの影響を処理する.
	for i in range(get_slide_collision_count()):
		var col:KinematicCollision2D = get_slide_collision(i)
		# 衝突位置.
		var pos = col.get_position()
		var v = Map.get_floor_type(pos)
		if v == Map.eType.NONE:
			continue # 何もしない.
		_update_floor_type(delta, v)

## 床種別に対応した処理をする.
func _update_floor_type(delta:float, v:Map.eType) -> bool:
	var ret = false
	match v:
		Map.eType.NONE:
			pass # 何もしない.
		Map.eType.SCROLL_L: # スクロール床(左).
			velocity.x -= _config.scroll_panel_speed * delta
		Map.eType.SCROLL_R: # スクロール床(右).
			velocity.x += _config.scroll_panel_speed * delta
	
	return ret
