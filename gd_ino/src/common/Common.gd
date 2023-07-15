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

# セーブデータのパス.
const PATH_SAVEDATA = "user://savedata.txt"

## コリジョンレイヤー.
enum eCollisionLayer {
	PLAYER = 1, # プレイヤー.
	WALL = 2, # 壁・床.
	ONEWAY = 3, # 一方通行床.
}

# ----------------------------------------
# var.
# ----------------------------------------
## 初期化済みかどうか.
var _initialized = false

## セーブデータ用.
var bgm_volume:float = 1.0:
	get:
		return bgm_volume
	set(v):
		var db = 64.0 * (v - 1)
		AudioServer.set_bus_volume_db(1, db)
		bgm_volume = v
var se_volume:float = 1.0:
	get:
		return se_volume
	set(v):
		var db = 64.0 * (v - 1)
		AudioServer.set_bus_volume_db(2, db)
		se_volume = v
var skip_op_ed = false
var quick_retry = true
var _achievements:Array[bool] = []

## ゲームデータ.
var _gained_item = {} # 獲得アイテム.
var _past_time = 0.0 # 経過時間.
var is_lunker = false # ランカーモードかどうか.

## 共有オブジェクト.
var _layers = []
var _camera:Camera2D = null
var _player:Player = null
var _bgm:AudioStreamPlayer = null
### BGMテーブル.
var _bgm_tbl = {
	"ino1": "res://assets/sound/ino1.ogg",
	"ino2": "res://assets/sound/ino2.ogg",
}
var _snds:Array = []
### SEテーブル.
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

## セーブ.
func to_save() -> void:
	var f = FileAccess.open(PATH_SAVEDATA, FileAccess.WRITE)
	var data = {
		"bgm": bgm_volume,
		"se": se_volume,
		"skip_op_ed": skip_op_ed,
		"quick_retry": quick_retry,
		"achievements": _achievements,
	}
	var s = var_to_str(data)
	f.store_string(s)
	f.close()
	
## ロード.
func from_load() -> void:
	if FileAccess.file_exists(PATH_SAVEDATA):
		# 存在すれば読み込み.
		var f = FileAccess.open(PATH_SAVEDATA, FileAccess.READ)
		var s = f.get_as_text()
		f.close()
		var data = str_to_var(s)
		bgm_volume = data["bgm"]
		se_volume = data["se"]
		skip_op_ed = data["skip_op_ed"]
		quick_retry = data["quick_retry"]
		_achievements = data["achievements"]	

## 初期化.
func init() -> void:
	if _initialized == false:
		# 実績.
		for i in range(Achievement.eType.size()):
			_achievements.append(false)
		
		# AudioStreamPlayerをあらかじめ作っておく.
		## BGM.
		if _bgm == null:
			_bgm = AudioStreamPlayer.new()
			add_child(_bgm)
			_bgm.bus = "BGM"
		## SE.
		for i in range(MAX_SOUND):
			var snd = AudioStreamPlayer.new()
			#snd.volume_db = -4
			snd.bus = "SE"
			add_child(snd)
			_snds.append(snd)
		
		# 初期化した.
		_initialized = true
	
	init_vars()

## 各種変数の初期化.
func init_vars() -> void:
	_past_time = 0
	_gained_item = {}

## セットアップ.
func setup(layers, player:Player, camera:Camera2D) -> void:
	init_vars()
	
	_layers = layers
	_player = player
	_camera = camera

## 経過時間を足し込む.
func add_past_time(delta:float) -> void:
	_past_time += delta

## 収集アイテムを所持しているかどうか.
func has_item(id:Map.eItem) -> bool:
	return id in _gained_item

## 収集アイテムの所持数を取得する.
func count_item() -> int:
	return _gained_item.size()

## 経過時間の取得.
func get_past_time() -> float:
	return _past_time

## 経過時間を秒で取得する.
func get_past_time_sec() -> int:
	var t = _past_time
	var sec = int(t)
	return sec

## 経過時間を文字列として取得する.
func get_past_time_str() -> String:
	var t = _past_time
	var msec = int(t*1000) % 1000
	var sec = int(t) % 60
	var minute = int(t/60)
	var time = "%2d:%02d.%03d"%[minute, sec, msec]
	return time
	
## 収集アイテム獲得.
func gain_item(id:Map.eItem) -> void:
	if Map.get_item_type(id) == Map.eItemType.POWER_UP:
		return # パワーアップ系は含めない.
	_gained_item[id] = true

## BGMの再生.
func play_bgm(name:String) -> void:
	if not name in _bgm_tbl:
		push_error("存在しないサウンド %s"%name)
		return
	_bgm.stream = load(_bgm_tbl[name])
	_bgm.play()

## BGMの停止.
func stop_bgm() -> void:
	_bgm.stop()

## SEの再生.
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

## SE再生中かどうか.
func playing_se(name:String) -> bool:
	if not name in _snd_tbl:
		push_error("存在しないサウンド %s"%name)
		return false
		
	for snd in _snds:
		var s = snd as AudioStreamPlayer
		if s.playing:
			if s.stream.resource_path == _snd_tbl[name]:
				return true
	
	# 再生中でない.
	return false
	
## 実績の開放.
func unlock_achievement(id:int) -> void:
	_achievements[id] = true
## 実績を開放済みかどうか.
func unlocked_achievement(id:int) -> bool:
	return _achievements[id]

# ----------------------------------------
# private functions.
# ----------------------------------------
