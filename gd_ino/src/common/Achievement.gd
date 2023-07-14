extends Node2D
# ==============================================
# 実績.
# ==============================================
class_name Achievement

# ----------------------------------------------
# const.
# ----------------------------------------------
## 種別.
enum eType {
	NORMAL_COMPLETED,
	MIN_COMPLETED,
	FAKE_COMPLETED,
	ALL_COMPLETED,
	SPEEDRUN_40SEC,
	SPEEDRUN_60SEC,
}
## 概要.
const TITLE = [
	"通常クリア",
	"ミニマムクリア",
	"コンプリート(?)クリア",
	"コンプリートクリア",
	"40秒クリア",
	"60秒クリア",
]

## 詳細.
const DETAIL = [
	"3種の神器を集める",
	"収集アイテムx3でクリアする",
	"収集アイテムx18でクリアする",
	"すべての収集アイテムを集める",
	"40秒以内でクリアする",
	"60秒以内でクリアする",
]

# ----------------------------------------------
# public functions.
# ----------------------------------------------
static func get_title(id:Achievement.eType) -> String:
	return TITLE[id]
static func get_detail(id:Achievement.eType) -> String:
	return DETAIL[id]
