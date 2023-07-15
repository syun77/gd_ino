extends CanvasLayer

const UIACHIEVEMENT_OBJ = preload("res://src/ui/UIAchievement.tscn")

var _queue = []
var _ui = null

func check_all_achievements() -> void:
	for id in range(Achievement.eType.size()):
		if Common.unlocked_achievement(id):
			continue # 開放済み.
		if Achievement.check(id):
			# 実績開放.
			Common.unlock_achievement(id)
			var obj = UIACHIEVEMENT_OBJ.instantiate()
			obj.start(id)
			_queue.push_back(obj)
			
func _process(_delta: float) -> void:
	if _queue.size() <= 0:
		return
	
	if is_instance_valid(_ui):
		return
	
	_ui = _queue.pop_front()
	add_child(_ui)
