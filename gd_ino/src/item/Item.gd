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
var _id = Map.eItem.NONE
## 有効フラグ.
var _enabled = true

# -------------------------------------------
# public functions.
# -------------------------------------------
## セットアップ.
## add_child()した後に呼びます.
func setup(id:Map.eItem) -> void:
	_id = id
	_spr.frame = SPR_FRAME_OFS + _id - 1
	
	if id == Map.eItem.OMEGA:
		# おめがの勲章は初期状態無効.
		_enabled = false
		visible = false
		
## 表示開始.
func display() -> void:
	_enabled = true
	visible = true
	
## ID取得.
func get_id() -> Map.eItem:
	return _id
	
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
	if _enabled == false:
		return # 無効.
	
	if body is Player:
		# アイテムゲット.
		var player = body as Player
		player.gain_item(_id)
		# 消滅する.
		queue_free()

