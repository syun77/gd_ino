extends Area2D
# ===========================================
# アイテム.
# ===========================================
class_name Item

# -------------------------------------------
# const.
# -------------------------------------------
const SPR_FRAME_OFS = 64 # 64から開始.

# -------------------------------------------
# onready.
# -------------------------------------------
@onready var _spr = $Sprite2D

# -------------------------------------------
# var.
# -------------------------------------------
## アイテムID.
var _id = Map.eType.NONE

# -------------------------------------------
# public functions.
# -------------------------------------------
## セットアップ.
## add_child()した後に呼びます.
func setup(id:Map.eType) -> void:
	_id = id
	_spr.frame = SPR_FRAME_OFS + _id - 1
	
## 指定のアイテムがレアアイテムかどうか.
static func is_rare(id:Map.eItem) -> bool:
	var tbl = [
		Map.eItem.FUJI, Map.eItem.TAKA, Map.eItem.NASU, Map.eItem.OMEGA
	]
	if id in tbl:
		return true
	return false
	
# -------------------------------------------
# private functions.
# -------------------------------------------
func _physics_process(delta: float) -> void:
	#_spr.offset.x = randf_range(-4, 4)
	#_spr.offset.y = randf_range(-4, 4)
	pass

# -------------------------------------------
# signals.
# -------------------------------------------
## プレイヤーと衝突した.
func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		# アイテムゲット.
		var player = body as Player
		player.gain_item(_id)
		# 消滅する.
		queue_free()
