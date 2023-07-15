extends Node2D
# =================================
# メインシーン.
# =================================
# ---------------------------------
# const.
# ---------------------------------
# タイルマップのサイズを定義.
# @note サイズを変更したらここを修正する必要がある.
const MAP_WIDTH = 108 # 幅.
const MAP_HEIGHT = 52 # 高さ.

const TIMER_READY = 50.0 / 60.0
const TIMER_GAMEOVER = 0.5
const TIMER_GAMECLEAR = 1.0

## 状態.
enum eState {
	READY, # げーむ　はじまる！
	MAIN, # メインゲーム.
	GAMEOVER, # げーむ　おわた。
	GAMECLEAR, # ゲームクリア演出.
}
## メインのサブ状態.
enum eMainStep {
	MAIN, # 自由移動.
	ITEM_MSG, # アイテムメッセージを表示.
}

# ---------------------------------
# preload.
# ---------------------------------
const ITEM_OBJ = preload("res://src/item/Item.tscn")
const UI_ITEM_OBJ = preload("res://src/ui/UIItem.tscn")

# ---------------------------------
# onready.
# ---------------------------------
@onready var _bg = $BgLayer/Bg
@onready var _player = $MainLayer/Player
@onready var _camera = $Camera2D
@onready var _map = $MainLayer/TileMap
@onready var _ui_health = $UILayer/UIHeath
@onready var _ui_caption = $UILayer/UICaption
@onready var _ui_item_list = $UILayer/UIItemList

@onready var _item_layer = $ItemLayer
@onready var _particle_layer = $ParticleLayer
@onready var _ui_layer = $UILayer
@onready var _ui_time = $UILayer/UITime
@onready var _ui_fade = $UILayer/FadeRect

# ---------------------------------
# var.
# ---------------------------------
## 状態.
var _state = eState.READY
var _main_step = eMainStep.MAIN
## タイマー.
var _timer = 0.0
## 獲得アイテム.
var _gain_item = Map.eItem.NONE
## アイテムウィンドウ.
var _item_ui:UIItem = null
## おめがの勲章の解放フラグ.
var _is_unlock_secret = false

# ---------------------------------
# private functions.
# ---------------------------------
## 開始.
func _ready() -> void:
	# 開始用の初期化.
	Common.init()
	
	if Common.is_lunker:
		# ランカーモード.
		_bg.visible = true
	
	# レイヤーを登録する.
	var layers = {
		"item": _item_layer,
		"particle": _particle_layer,
	}
	Common.setup(layers, _player, _camera)
	# タイルマップを設定.
	Map.setup(_map, MAP_WIDTH, MAP_HEIGHT)
	# カメラをワープ.
	_update_camera(true)
	
	# アイテムを生成。ブロックタイルを置き換える.
	_create_items_and_replace_block()
	
	# 開始キャプションを表示.
	_ui_caption.start(UICaption.eType.START)
	
	# BGM再生開始.
	Common.play_bgm("ino1")
	
## アイテムオブジェクトを生成。ブロックタイルを置き換える.
func _create_items_and_replace_block() -> void:
	# タイルだとアイテムの判定がややこしいのでオブジェクト化する.
	for j in range(Map.height):
		for i in range(Map.width):
			var pos = Vector2i(i, j)
			var id = Map.get_item(pos)
			if id == Map.eItem.NONE:
				var block = Map.get_block(pos)
				# ブロックタイルを置き換える.
				match block:
					Map.eBlock.INVISIBLE: # 不可視.
						Map.set_cell(pos, Map.eTileLayer.GROUND, Vector2i(2, 0))
					Map.eBlock.THROUGH: # 通過可能.
						Map.set_cell(pos, Map.eTileLayer.GROUND, Vector2i(4, 6))
				continue # 生成不要.
			
			# アイテム生成.
			var obj = ITEM_OBJ.instantiate()
			obj.position = Map.grid_to_world(pos, true)
			_item_layer.add_child(obj)
			obj.setup(id)
			
			# タイルから消しておく.
			Map.erase_cell(pos, Map.eTileLayer.GROUND)

## 更新.
func _physics_process(delta: float) -> void:
	_timer += delta
	
	# stateに応じた更新処理.
	match _state:
		eState.READY:
			_update_ready(delta)
		eState.MAIN:
			_update_main(delta)
		eState.GAMEOVER:
			_update_gameover(delta)
		eState.GAMECLEAR:
			_update_gameclear(delta)
	# UIの更新.
	_update_ui()
	
	if Common.quick_retry:
		# クイックリスタート.
		if Input.is_action_just_pressed("reset"):
			get_tree().change_scene_to_file("res://Main.tscn")

## 更新 > ゲーム開始.
func _update_ready(delta:float) -> void:
	if _timer >= TIMER_READY:
		# プレイヤー動く.
		_player.start()
		_state = eState.MAIN
## 更新 > メイン.
func _update_main(delta:float) -> void:
	# おめがの勲章チェック.
	_check_omega()
	
	# サブ状態の更新.
	match _main_step:
		eMainStep.MAIN:
			# メイン.
			## 時間経過.
			Common.add_past_time(delta)
			_player.update(delta)
			_update_camera(false)
			_gain_item = _player.itemID
			if _player.is_dead():
				# プレイヤー死亡処理.
				Common.stop_bgm()
				_timer = 0
				_state = eState.GAMEOVER
				_ui_caption.start(UICaption.eType.GAMEOVER)
			elif _gain_item != Map.eItem.NONE:
				# アイテム獲得メッセージを表示.
				Common.stop_bgm()
				_main_step = eMainStep.ITEM_MSG
				_item_ui = UI_ITEM_OBJ.instantiate()
				_ui_layer.add_child(_item_ui)
				_item_ui.setup(_gain_item)
		eMainStep.ITEM_MSG:
			if is_instance_valid(_item_ui) == false:
				# アイテム獲得メッセージ表示終了.
				_ui_item_list.gain(_gain_item)
				Common.gain_item(_gain_item)
				_player.reset_item()
				if _ui_item_list.is_completed():
					# ゲームクリア処理へ.
					_timer = 0.0
					_state = eState.GAMECLEAR
				else:
					# BGM再開.
					Common.play_bgm("ino1")
					_main_step = eMainStep.MAIN
		
## 更新 > ゲームオーバー.
func _update_gameover(delta:float) -> void:
	_player.update(delta)
	if _timer < TIMER_GAMEOVER:
		return # 少し待ちます.
	if Input.is_action_just_pressed("action"):
		# リトライ.
		#get_tree().change_scene_to_file("res://Main.tscn")
		get_tree().change_scene_to_file("res://src/scenes/title/Title.tscn")

## 更新 > ゲームクリア.
func _update_gameclear(delta:float) -> void:
	_timer += delta
	var rate = _timer / TIMER_GAMECLEAR
	_ui_fade.visible = true
	_ui_fade.color.a = rate
	if _timer >= TIMER_GAMECLEAR:
		get_tree().change_scene_to_file("res://src/scenes/ending/Ending.tscn")

## カメラの位置を更新.
func _update_camera(is_warp:bool) -> void:
	# カメラの注視点
	var target = _player.position
	target.y += -64 # 1タイルずらす
	target.x += _player.velocity.x * 0.7 # 移動先を見る.
	
	if is_warp:
		# カメラワープが有効.
		_camera.position = target
	else:
		# 通常はスムージングを行う.
		_camera.position += (target - _camera.position) * 0.05
	
## UIの更新.
func _update_ui() -> void:
	# Heath UIを更新.
	_ui_health.set_hp(_player.hp, _player.max_hp)
	# 経過時間UIを更新.
	_ui_time.text = Common.get_past_time_str()

## おめがの勲章チェック.
func _check_omega() -> void:
	if _is_unlock_secret:
		return # 解放済みなら何もしない.
		
	if _ui_item_list.count_gain() >= 15:
		# アイテムを15種類集めると出現する.
		for v in _item_layer.get_children():
			if v.get_id() == Map.eItem.OMEGA:
				# おめがの勲章を表示する.
				v.display()
				_is_unlock_secret = true
				break
