extends Control

# =================================
# キャプションUI.
# =================================
class_name UICaption

# ---------------------------------
# const.
# ---------------------------------
## キャプションの種別.
enum eType {
	NONE = -1,
	START = 0, # げーむ　はじまる！
	GAMEOVER = 1, # げーむ　おわた。
}

## 状態.
enum eState {
	NONE,
	FADE_IN,
	WAIT,
	FADE_OUT,
}

# ---------------------------------
# onready.
# ---------------------------------
@onready var _spr = $Caption

var _type = eType.NONE
var _state = eState.NONE
var _timer = 0.0
var _bg_rate = 0.0

# ---------------------------------
# public functions.
# ---------------------------------
## 開始.
func start(type:eType) -> void:
	_type = type
	_spr.offset = Vector2.ZERO
	_spr.frame = _type
	_spr.visible = true
	_spr.scale = Vector2.ONE
	_spr.modulate = Color.WHITE
	_state = eState.FADE_IN
	_timer = 0.0


# ---------------------------------
# private functions.
# ---------------------------------
## 開始
func _ready() -> void:
	# 初期状態は非表示.
	_spr.visible = false

## 非表示.
func _hide() -> void:
	_type = eType.NONE
	_spr.visible = false

## 更新.
func _physics_process(delta: float) -> void:
	if _type == eType.NONE:
		_spr.visible = false
		return
	
	_timer += delta
	
	if _type != eType.START:
		return
	
	var ofs = Vector2.ZERO
	var sc = Vector2.ONE
	var color = Color.WHITE
	match _state:
		eState.FADE_IN:
			var rate = 1.0 - (_timer / 0.4)
			_bg_rate = (_timer / 0.4)
			# ランダムで色を選ぶ.
			color = [Color.WHITE, Color.RED, Color.LIME, Color.DEEP_SKY_BLUE].pick_random()
			# 揺らす.
			ofs.x = 48 * randf_range(-rate, rate)
			ofs.y = 24 * randf_range(-rate, rate)
			if _timer > 0.4:
				_timer = 0
				_state = eState.WAIT
		eState.WAIT:
			var rate = 1 + 0.07 * _timer/1.5
			sc *= rate
			if _timer > 1.5:
				_timer = 0
				_state = eState.FADE_OUT
		eState.FADE_OUT:
			color.a = 1.0 - (_timer / 0.9)
			sc *= 1.07
			if _timer < 0.1:
				var rate = Ease.cube_out(_timer / 0.1)
				_bg_rate = 1.0 - rate
				sc.x -= 0.5 * rate
				sc.y += 1.0 * rate
			elif _timer < 0.9:
				var rate = (_timer-0.1) / 0.9
				sc.x = (sc.x - 0.5) * 20 * Ease.expo_out(rate)
				sc.y = (sc.y + 1.0) * (1 - Ease.expo_out(rate*1.5))
			else:
				## 非表示.
				_hide()
				
	_spr.offset = ofs
	_spr.scale = sc
	_spr.modulate = color
	
	queue_redraw()
	
func _draw() -> void:
	if _bg_rate <= 0.0:
		return

	var rect = Rect2()
	rect.position.x = 0
	rect.position.y = _spr.position.y - 60
	rect.size.x = 1280
	rect.size.y = 60 * 2
	var color = Color.WHITE
	color.a = 0.2 * _bg_rate
	draw_rect(rect, color)
