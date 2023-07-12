extends Node
# ========================================
# 共通モジュール.
# ========================================

# ----------------------------------------
# consts
# ----------------------------------------
# ウィンドウの幅と高さ.
const WINDOW_WIDTH = 1280
const WINDOW_HEIGHT = 960

# 同時再生可能なサウンドの数.
const MAX_SOUND = 8

## コリジョンレイヤー.
enum eCollisionLayer {
	PLAYER = 1, # プレイヤー.
	WALL = 2, # 壁・床.
	ONEWAY = 3, # 一方通行床.
}

# ----------------------------------------
# var.
# ----------------------------------------
var _gained_item = {} # 獲得アイテム.
var _past_time = 0.0 # 経過時間.
var _layers = []
var _camera:Camera2D = null
var _player:Player = null
var _snds:Array = []
var _snd_tbl = {
	"damage": "res://assets/sound/damage.wav",
	"heal": "res://assets/sound/heal.wav",
	"itemget2": "res://assets/sound/itemget2.wav",
	"itemget": "res://assets/sound/itemget.wav",
	"jump": "res://assets/sound/jump.wav",
}


# ----------------------------------------
# public functions.
# ----------------------------------------
func get_collision_bit(bit:eCollisionLayer) -> int:
	return int(pow(2, bit-1))

## 初期化.
func init() -> void:
	init_vars()

## 各種変数の初期化.
func init_vars() -> void:
	_past_time = 0
	_gained_item = {}
	_snds.clear()

## セットアップ.
func setup(root, layers, player:Player, camera:Camera2D) -> void:
	init_vars()
	
	_layers = layers
	_player = player
	_camera = camera
	# AudioStreamPlayerをあらかじめ作っておく.
	for i in range(MAX_SOUND):
		var snd = AudioStreamPlayer.new()
		#snd.volume_db = -4
		root.add_child(snd)
		_snds.append(snd)

## 経過時間を足し込む.
func add_past_time(delta:float) -> void:
	_past_time += delta

## 収集アイテムを所持しているかどうか.
func has_item(id:Map.eItem) -> bool:
	return id in _gained_item

## 経過時間の取得.
func get_past_time() -> float:
	return _past_time
	
## 収集アイテム獲得.
func gain_item(id:Map.eItem) -> void:
	_gained_item[id] = true

func play_se(name:String, id:int=0) -> void:
	if id < 0 or MAX_SOUND <= id:
		push_error("不正なサウンドID %d"%id)
		return
	
	if not name in _snd_tbl:
		push_error("存在しないサウンド %s"%name)
		return
	
	var snd = _snds[id]
	snd.stream = load(_snd_tbl[name])
	snd.play()

# ----------------------------------------
# private functions.
# ----------------------------------------
