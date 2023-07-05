extends Node2D
# =================================
# メインシーン.
# =================================

# ---------------------------------
# onready.
# ---------------------------------
@onready var _player = $Player
@onready var _camera = $Camera2D

# ---------------------------------
# private functions.
# ---------------------------------
## 開始.
func _ready() -> void:
	# カメラをワープ.
	_update_camera(true)

## 更新.
func _process(delta: float) -> void:
	_update_camera(false)

## カメラの位置を更新.
func _update_camera(is_warp:bool) -> void:
	if is_warp:
		_camera.position_smoothing_enabled = false
	_camera.position = _player.position
	if is_warp:
		_camera.position_smoothing_enabled = true
	
