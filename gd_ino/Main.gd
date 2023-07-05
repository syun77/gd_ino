extends Node2D

@onready var _player = $Player
@onready var _camera = $Camera2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	_camera.position = _player.position
