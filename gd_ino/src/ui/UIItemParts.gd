extends Control

class_name UIItemParts

const TIMER_BLINK = 0.5

@onready var _bg = $Bg
@onready var _spr = $Sprite2D

var _type = Map.eItemType.FUJI
var _color = Color.WHITE
var _timer_blink = 0.0
var _gained = false

func gain() -> void:
	_bg.color = Color.WHITE
	_spr.modulate = _color
	_timer_blink = TIMER_BLINK
	_gained = true

func _ready() -> void:
	_bg.color = Color.BLACK
	_spr.modulate = Color.BLACK

func _process(delta: float) -> void:
	if _gained:
		_spr.visible = true
		if _timer_blink > 0:
			_timer_blink -= delta
			var v = int(_timer_blink * 100)
			if v%10 < 5:
				_spr.visible = false

var itemID = Map.eItem.NONE:
	set(v):
		itemID = v
		_type = Map.get_item_type(v)
		_color = Map.item_to_color(v)

var gained:bool:
	get:
		return _gained
