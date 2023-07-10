extends Control

# ===========================================
# アイテムリストの各項目 (取得状況の表示).
# ===========================================
class_name UIItemParts

# ----------------------------------------
# const.
# ----------------------------------------
const TIMER_BLINK = 0.5

# ----------------------------------------
# onready.
# ----------------------------------------
@onready var _bg = $Bg
@onready var _spr = $Sprite2D

# ----------------------------------------
# var.
# ----------------------------------------
var _type = Map.eItemType.FUJI
var _color = Color.WHITE
var _timer_blink = 0.0
var _gained = false

# ----------------------------------------
# public functions.
# ----------------------------------------
## 獲得した.
func gain() -> void:
	# 明るくする.
	_bg.color = Color.WHITE
	_spr.modulate = _color
	# 点滅開始.
	_timer_blink = TIMER_BLINK
	_gained = true

# ----------------------------------------
# private functions.
# ----------------------------------------
## 開始
func _ready() -> void:
	# 未取得なので暗転しておく
	_bg.color = Color.BLACK
	_spr.modulate = Color.BLACK

## 更新.
func _process(delta: float) -> void:
	if _gained == false:
		# 未取得の場合は何もしない
		return
	
	# 表示開始.
	_spr.visible = true
	if _timer_blink > 0:
		# 点滅する.
		_timer_blink -= delta
		var v = int(_timer_blink * 100)
		if v%10 < 5:
			_spr.visible = false

## itemIDを設定する.
var itemID = Map.eItem.NONE:
	set(v):
		itemID = v
		_type = Map.get_item_type(v)
		_color = Map.item_to_color(v)

## アイテム獲得状態を取得する.
var gained:bool:
	get:
		return _gained
