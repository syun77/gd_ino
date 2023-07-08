extends Node2D
# =================================
# メインシーン.
# =================================
# ---------------------------------
# const.
# ---------------------------------
enum eState {
	READY, # げーむ　はじまる！
	MAIN, # メインゲーム.
	GAMEOVER, # げーむ　おわた。
}

# ---------------------------------
# onready.
# ---------------------------------
@onready var _player = $Player
@onready var _camera = $Camera2D
@onready var _map = $TileMap
@onready var _ui_health = $UILayer/UIHeath

# ---------------------------------
# private functions.
# ---------------------------------
## 開始.
func _ready() -> void:
	# 共通.
	var layers = {} # 今回ゲームオブジェクトのLayerは存在しない.
	Common.setup(self, layers, _player, _camera)
	# タイルマップを設定.
	Map.setup(_map)
	# カメラをワープ.
	_update_camera(true)

## 更新.
func _physics_process(delta: float) -> void:
	_player.update(delta)
	_update_camera(false)
	# UIの更新.
	_update_ui()

## カメラの位置を更新.
func _update_camera(is_warp:bool) -> void:
	_camera.position_smoothing_enabled = true
	if is_warp:
		# TODO: カメラワープは未実装.
		_camera.position_smoothing_enabled = false
	_camera.position = _player.position
	
## UIの更新.
func _update_ui() -> void:
	_ui_health.set_hp(_player.hp, _player.max_hp)
