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
## デバッグ用ラベル.
@onready var _label = $Label

# ---------------------------------
# var.
# ---------------------------------
## アニメーション用タイマー.
var _timer_anim = 0.0
## フレームカウンタ.
var _cnt = 0
## 無敵タイマー.
var _timer_muteki = 0.0
## 左向きかどうか.
var _is_left = true
## 飛び降り中かどうか.
var _is_fall_through = false
## 方向.
var _direction = 0
## 踏んでいる床.
var _stomp_tile = Map.eType.NONE
## ダメージ処理フラグ.
var _is_damage = false

# ---------------------------------
# private functions.
# ---------------------------------
## 更新.
func update(delta: float) -> void:
	# タイマー関連の更新.
	_timer_anim += delta
	_cnt += 1
	if _timer_muteki > 0:
		_timer_muteki -= delta
	
	# 移動処理.
	_update_moving()
	
	# アニメーション更新.
	_update_anim()

	move_and_slide()
	if is_on_floor():
		_set_fall_through(false) # 着地したら飛び降り終了.
	
	_update_collision_post()
	
	# デバッグ用更新.
	#_update_debug()

## 飛び降りフラグの設定.
func _set_fall_through(b:bool) -> void:
	if _is_fall_through == b:
		return # すでに設定されていれば更新不要.
	
	_is_fall_through = b
	# コリジョンレイヤーの設定.
	_update_collision_layer()

## 移動処理.
func _update_moving() -> void:
	if _is_damage:
		_is_damage = false
		if _timer_muteki <= 0:
			# ダメージ処理.
			velocity.y = -_config.jump_velocity
			_timer_muteki = _config.muteki_time
			return
	
	# move_and_slide()で足元のタイルを判定したいので
	# 常に重力を加算.
	velocity.y += _config.gravity
	
	if _is_fall_through:
		# 飛び降り中.
		if _check_fall_through() == false:
			# 飛び降り終了.
			_set_fall_through(false)
	elif _check_fall_through():
		# 飛び降り開始.
		_set_fall_through(true)
		# X方向の速度を0にしてしまう.
		# ※これをしないと is_on_floor() が falseにならない.
		velocity.x = 0
		return

	elif _checkJump():
		# 接地していたらジャンプ.
		velocity.y = _config.jump_velocity * -1
	
	# 左右移動の更新.
	_update_horizontal_moving()

## ジャンプチェック.
func _checkJump() -> bool:
	if Input.is_action_just_pressed("action") == false:
		# ジャンプボタンを押していない.
		return false
	if is_on_floor() == false:
		# 接地していない.
		return false
	
	# ジャンプする.
	return true
	
## 飛び降り判定.
func _check_fall_through() -> bool:
	if Input.is_action_pressed("action"):
		if Input.is_action_pressed("ui_down"):
			return true # 下＋ジャンプ.
	return false
	
## 左右移動の更新.
func _update_horizontal_moving() -> void:
	# 左右キーで移動.
	if Input.is_action_pressed("ui_left"):
		_direction = -1
	elif Input.is_action_pressed("ui_right"):
		_direction = 1

	var MOVE_SPEED = _config.move_speed
	var AIR_ACC_RATIO = _config.air_acc_ratio
	
	if is_on_floor() == false:
		# 空中移動.
		velocity.x = velocity.x * (1.0 - AIR_ACC_RATIO) + _direction * MOVE_SPEED * AIR_ACC_RATIO
		return

	# 地上の移動.
	var GROUND_ACC_RATIO = _config.ground_acc_ratio
	var SCROLLPANEL_SPEED = _config.scroll_panel_speed
	# 前回の速度を減衰させる.
	var base = velocity.x * (1.0 - GROUND_ACC_RATIO)
	
	# 踏んでいるタイルごとの処理.
	match _stomp_tile:
		Map.eType.NONE: # 普通の床.
			velocity.x = base + _direction * MOVE_SPEED * GROUND_ACC_RATIO
		Map.eType.SCROLL_L: # ベルト床(左).
			velocity.x = base + (_direction * MOVE_SPEED - SCROLLPANEL_SPEED) * GROUND_ACC_RATIO
		Map.eType.SCROLL_R: # ベルト床(右).
			velocity.x = base + (_direction * MOVE_SPEED + SCROLLPANEL_SPEED) * GROUND_ACC_RATIO
		Map.eType.SLIP: # すべる床.
			pass # 地上では加速できない.

## アニメーションの更新.
func _update_anim() -> void:
	# ダメージ点滅.
	_spr.visible = true
	if _timer_muteki > 0.0 and _cnt%10 < 5:
		_spr.visible = false
	
	# 向きを更新.
	_is_left = (_direction > 0.0)
	_spr.flip_h = _is_left
	_spr.frame = _get_anim()

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

func _update_collision_post() -> void:
	# 衝突したコリジョンに対応するフラグを設定する.
	var dist = 99999 # 一番近いオブジェクトだけ処理する.
	_stomp_tile = Map.eType.NONE # 処理するタイル.
	
	for i in range(get_slide_collision_count()):
		var col:KinematicCollision2D = get_slide_collision(i)
		# 衝突位置.
		var pos = col.get_position()
		var v = Map.get_floor_type(pos)
		if v == Map.eType.NONE:
			continue # 何もしない.
		if v == Map.eType.SPIKE:
			_is_damage = true # ダメージ処理は最優先.
			continue # 移動処理に直接の影響はない.
		
		if pos.y < position.y:
			# プレイヤーよりも上にあるタイルは処理不要.
			continue
			
		var d = pos.x - position.x
		if d < dist:
			# より近い.
			dist = d
			_stomp_tile = v

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

# デバッグ用更新.
func _update_debug() -> void:
	_label.visible = true
	_label.text = "stomp:%d"%_stomp_tile
	_label.text += "\nis_floor:%s"%("true" if is_on_floor() else "false")
	_label.text += "\n" + str(get_floor_normal())
