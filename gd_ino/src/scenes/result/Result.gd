extends Node2D
# =========================================
# リザルト画面.
# =========================================
# -----------------------------------------
# const.
# -----------------------------------------
enum eState {
	INIT,
	MAIN,
	END,
}

# -----------------------------------------
# onready.
# -----------------------------------------
@onready var _txt_item = $GainItem
@onready var _txt_time = $ClearTime

# -----------------------------------------
# var.
# -----------------------------------------
var _state = eState.INIT
var _gained_item = 19
var _clear_time = (59*60) + (59) + 0.999

# -----------------------------------------
# functions.
# -----------------------------------------
## 開始.
func _ready() -> void:
	_txt_item.text = "%d"%_gained_item
	var msec = int(_clear_time*1000) % 1000
	var sec = int(_clear_time) % 60
	var minute = int(_clear_time/60)
	var time = "%2d:%02d.%03d"%[minute, sec, msec]
	_txt_time.text = time

## 更新.
func _physics_process(_delta: float) -> void:
	match _state:
		eState.INIT:
			_state = eState.MAIN
		eState.MAIN:
			if Input.is_action_just_released("action"):
				_state = eState.END
		eState.END:
			get_tree().change_scene_to_file("res://src/scenes/title/Title.tscn")
