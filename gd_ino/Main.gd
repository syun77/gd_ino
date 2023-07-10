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

## 状態.
enum eState {
	READY, # げーむ　はじまる！
	MAIN, # メインゲーム.
	GAMEOVER, # げーむ　おわた。
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
@onready var _player = $Player
@onready var _camera = $Camera2D
@onready var _map = $TileMap
@onready var _bgm = $BGM
@onready var _ui_health = $UILayer/UIHeath
@onready var _ui_caption = $UILayer/UICaption
@onready var _ui_item_list = $UILayer/UIItemList

@onready var _item_layer = $ItemLayer
@onready var _particle_layer = $ParticleLayer
@onready var _ui_layer = $UILayer

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
	# レイヤーを登録する.
	var layers = {
		"item": _item_layer,
		"particle": _particle_layer,
	}
	Common.setup(self, layers, _player, _camera)
	# タイルマップを設定.
	Map.setup(_map, MAP_WIDTH, MAP_HEIGHT)
	# カメラをワープ.
	_update_camera(true)
	
	# アイテムを生成.
	_create_items()
	
	# 開始キャプションを表示.
	_ui_caption.start(UICaption.eType.START)
	
## アイテムオブジェクトを生成.
func _create_items() -> void:
	# タイルだとアイテムの判定がややこしいのでオブジェクト化する.
	for j in range(Map.height):
		for i in range(Map.width):
			var pos = Vector2i(i, j)
			var id = Map.get_item(pos)
			if id == Map.eItem.NONE:
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
	# UIの更新.
	_update_ui()
	
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
			_player.update(delta)
			_update_camera(false)
			_gain_item = _player.itemID
			if _player.is_dead():
				# プレイヤー死亡処理.
				_bgm.stop()
				_timer = 0
				_state = eState.GAMEOVER
				_ui_caption.start(UICaption.eType.GAMEOVER)
			elif _gain_item != Map.eItem.NONE:
				# アイテム獲得メッセージを表示.
				_bgm.stop()
				_main_step = eMainStep.ITEM_MSG
				_item_ui = UI_ITEM_OBJ.instantiate()
				_ui_layer.add_child(_item_ui)
				_item_ui.setup(_gain_item)
		eMainStep.ITEM_MSG:
			if is_instance_valid(_item_ui) == false:
				# アイテム獲得メッセージ表示終了.
				_bgm.play()
				_ui_item_list.gain(_gain_item)
				_player.reset_item()
				_main_step = eMainStep.MAIN
		
## 更新 > ゲームオーバー.
func _update_gameover(delta:float) -> void:
	_player.update(delta)
	if _timer < TIMER_GAMEOVER:
		return # 少し待ちます.
	if Input.is_action_just_pressed("action"):
		# リトライ.
		get_tree().change_scene_to_file("res://Main.tscn")

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
