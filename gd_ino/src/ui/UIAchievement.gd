extends Node2D
# ===================================
# 実績UI
# ===================================

# -----------------------------------
# const.
# -----------------------------------
const START_OFS_X = 600
const START_OFS_Y = -128
const TIME_IN_OUT = 0.5
const TIME_WAIT = 3.0

enum eState {
	APPEAR,
	WAIT,
	HIDE,
}

# -----------------------------------
# onready.
# -----------------------------------
@onready var _label = $Label

# -----------------------------------
# var.
# -----------------------------------
var _timer = 0.0
var _state = eState.APPEAR
var _type:Achievement.eType

# -----------------------------------
# public functions.
# -----------------------------------
## 開始.
func start(type:Achievement.eType) -> void:
	_type = type
	_state = eState.APPEAR
	position.x = START_OFS_X

# -----------------------------------
# private functions.
# -----------------------------------
## 開始.
func _ready() -> void:
	var title = Achievement.get_title(_type)
	_label.text = "Unlock:%s"%title

## 更新.
func _process(delta: float) -> void:
	_timer += delta
	match _state:
		eState.APPEAR:
			var rate = _timer/TIME_IN_OUT
			position.x = START_OFS_X * Ease.expo_in(1 - rate)
			if rate >= 1:
				_timer = 0
				_state = eState.WAIT
		eState.WAIT:
			position.x = 0
			if _timer >= TIME_WAIT:
				_timer = 0
				_state = eState.HIDE
		eState.HIDE:
			var rate = _timer/TIME_IN_OUT
			position.y = START_OFS_Y * Ease.expo_in(rate)
			if rate >= 1:
				queue_free()
