extends Resource
# =================================
# config.tres にアタッチするスクリプト.
# =================================
class_name Config

# ---------------------------------
@export_category("プレイヤー")
## 移動速度(加速度).
@export var move_speed = 2.0 * 60
## ジャンプ力.
@export var jump_velocity = 900.0
## 重力加速度.
@export var gravity = 1960.0

# ---------------------------------
@export_category("地形")
## 移動床の速度.
@export var moving_floor = 100.0
