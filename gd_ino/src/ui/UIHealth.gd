extends Control

# ======================================
# HP表示UI
# ======================================

# --------------------------------------
# const.
# --------------------------------------
# ひとまず最大10まで.
const MAX_HP = 10

# --------------------------------------
# onready.
# --------------------------------------
@onready var _spr = $Health00

# --------------------------------------
# var.
# --------------------------------------
var _spr_list:Array[Sprite2D] = []
var _hp = 0
var _max_hp = 0
var _cnt = 0 # フレームカウンタ.

# --------------------------------------
# public functions.
# --------------------------------------
## HPを設定.
func set_hp(hp:int, max_hp:int) -> void:
	_hp = hp
	_max_hp = max_hp

# --------------------------------------
# private functions.
# --------------------------------------
## 開始.
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

## 更新.
func _physics_process(_delta: float) -> void:
	_cnt += 1
	var is_blink = (_hp <= 1) # HP1以下で点滅する.
	if _max_hp == _hp:
		# 最大HPを同じであれば点滅しない.
		is_blink = false
	
	for i in range(MAX_HP):
		var spr = _spr_list[i]
		
		if is_blink and _cnt%10 < 5:
			spr.visible = false
			continue
		
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
