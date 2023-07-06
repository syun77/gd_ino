extends Node

# --------------------------------------------------
# const.
# --------------------------------------------------
## マップの基準位置を変更したい場合はこの値を変更する.
const OFS_X = 0
const OFS_Y = 0

## タイルマップのレイヤー.
enum eTileLayer {
	GROUND, # 地面.
#	TERRAIN, # 地形.
}

## コリジョンの種類.
enum eCollision {
	NONE = 0,
		
}

## アイテムID.
enum eItem {
	NONE = 0, # 何もない.
	
	## アップグレード・特殊アイテム系.
	JUMP_UP = 1, # ジャンプ回数上昇.
	LIFE = 2, # ライフ最大値上昇.
	POWER_UP = 3, # 未使用.
	KEY = 4, # 未使用.
	
	## 収集アイテム系.
	### 富士系.
	FUJI = 10, # 富士山.
	BUSHI = 11, # 武士.
	APPLE = 12, # ふじリンゴ.
	V = 13, # ブイ.
	
	### 鷹系.
	TAKA = 14, # 鷹.
	SHOULDER = 15, # 肩.
	DAGGER = 16, # ダガー.
	KATAKATA = 17, # かたかた.
	
	### 茄子系.
	NASU = 18, # 茄子.
	BONUS = 19, # 棒と茄子.
	NURSE = 20, # ナース.
	NAZUNA = 21, # なずな.
	
	### クソゲー系.
	GAMEHELL = 22, # ゲームヘル2000.
	GUNDAM = 23, # 実写版ガンダム.
	POED = 24, # PO'ed (ポエド).
		
	### その他.
	MILESTONE = 25, # マイルストーン.
	ONE_YEN = 26, # 1円札.
	TRIANGLE = 27, # トライアングル・サービス.
	OMEGA = 28, # おめがの勲章.
}

# --------------------------------------------------
# private var.
# --------------------------------------------------
var _tilemap:TileMap = null

# --------------------------------------------------
# public function.
# --------------------------------------------------
## タイルマップを設定.
func setup(tilemap:TileMap) -> void:
	_tilemap = tilemap

## タイルサイズを取得する.
func get_tile_size() -> int:
	# 正方形なので xの値 でOK.
	return _tilemap.tile_set.tile_size.x

## ワールド座標をグリッド座標に変換する.
func world_to_grid(world:Vector2, centered=true) -> Vector2:
	var grid = Vector2()
	grid.x = world_to_grid_x(world.x, centered)
	grid.y = world_to_grid_y(world.y, centered)
	return grid
func world_to_grid_x(wx:float, centered:bool) -> float:
	var size = get_tile_size()
	if centered:
		wx -= size / 2
	return (wx-OFS_X) / size
func world_to_grid_y(wy:float, centered:bool) -> float:
	var size = get_tile_size()
	if centered:
		wy -= size / 2
	return (wy-OFS_Y) / size

## グリッド座標をワールド座標に変換する.
func grid_to_world(grid:Vector2, centered:bool) -> Vector2:
	var world = Vector2()
	world.x = grid_to_world_x(grid.x, centered)
	world.y = grid_to_world_y(grid.y, centered)
	return world
func grid_to_world_x(gx:float, centered:bool) -> float:
	var size = get_tile_size()
	var x = OFS_X + (gx * size)
	if centered:
		x += size / 2 # 中央に移動.
	return x
func grid_to_world_y(gy:float, centered:bool) -> float:
	var size = get_tile_size()
	var y = OFS_Y + (gy * size)
	if centered:
		y += size / 2 # 中央に移動.
	return y

## マウスカーソルの位置をグリッド座標で取得する.
func get_grid_mouse_pos() -> Vector2i:
	var mouse = get_viewport().get_mouse_position()
	# 中央揃えしない.
	return world_to_grid(mouse, false)
func get_mouse_pos(snapped:bool=false) -> Vector2:
	if snapped == false:
		# スナップしない場合は viewport そのままの値.
		return get_viewport().get_mouse_position()
	# スナップする場合はいったんグリッド座標に変換.
	var pos = get_grid_mouse_pos()
	# ワールドに戻すことでスナップされる.
	return grid_to_world(pos, true)
	
## カスタムデータの取得.
func get_custom_data_from_world(world:Vector2, name:String) -> Variant:
	var pos:Vector2i = world_to_grid(world)
	for layer in eTileLayer.values():
		var data = _tilemap.get_cell_tile_data(layer, pos)
		if data == null:
			continue
		return data.get_custom_data(name)
	
	# 存在しない.
	return null
	

## 砲台の設置できない場所かどうか.
func cant_build_position(pos:Vector2i) -> bool:
	for layer in eTileLayer.values():
		var data = _tilemap.get_cell_tile_data(layer, pos)
		if data == null:
			continue
		if data.get_custom_data("cant_build"):
			return true # 配置できない場所.
	
	# 配置可能.	
	return false

