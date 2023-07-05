extends Resource
# =================================
# config.tres にアタッチするスクリプト.
# =================================
class_name Config

# ---------------------------------
@export_category("プレイヤー")
## 移動速度.
@export var move_speed = 500.0
## ジャンプ力.
@export var jump_velocity = 900.0
## 重力加速度.
@export var gravity = 1960.0

