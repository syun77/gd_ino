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
var _hiscore = 0
var _score = 0
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
	
func get_score() -> int:
	return _score
	
func add_score(v:int) -> void:
	_score += v
	
	if _score > _hiscore:
		# ハイスコア更新.
		_hiscore = _score

func get_hiscore() -> int:
	return _hiscore

func init() -> void:
	_hiscore = 0
	_score = 0

## 各種変数の初期化.
func init_vars() -> void:
	_score = 0
	_snds.clear()
	
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
