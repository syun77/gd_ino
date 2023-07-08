extends Control

# ひとまず最大10まで.
const MAX_HP = 10

@onready var _spr = $Health00

var _spr_list:Array[Sprite2D] = []
var _hp = 0
var _max_hp = 0

func set_hp(hp:int, max_hp:int) -> void:
	_hp = hp
	_max_hp = max_hp

func _ready() -> void:
	for i in range(MAX_HP):
		var spr = Sprite2D.new()
		spr.texture = _spr.texture
		spr.centered = false
		spr.position.x = i * spr.texture.get_width() / 2
		spr.hframes = 2
		spr.visible = false # 非表示.
		_spr_list.append(spr)
		add_child(spr)
	_spr.visible = false # 使用しない.

func _physics_process(_delta: float) -> void:
	for i in range(MAX_HP):
		var spr = _spr_list[i]
		if i >= _max_hp:
			# 表示不要.
			spr.visible = false
			continue
		
		# 表示する.
		spr.visible = true
		if i < _hp:
			# 残りHP.
			spr.frame = 0
		else:
			spr.frame = 1
