extends Node2D

@onready var _list = $ItemList
@onready var _detail = $Detail

func _ready() -> void:
	for id in Achievement.eType.values():
		var label = _list.get_child(id)
		label.text = AchievementData.get_title(id)
	_detail.text = AchievementData.get_detail(Achievement.eType.ALL_COMPLETED)
