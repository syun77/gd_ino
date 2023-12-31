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
	ALL_COMPLETED_3MIN,
	LUNKER_COMPLETED,
	LUNKER_ALL_COMPLETED,
}
## 概要.
const TITLE = [
	"通常クリア",
	"ミニマムクリア",
	"コンプリート(?)クリア",
	"コンプリートクリア",
	"40秒クリア",
	"60秒クリア",
	"コンプリート＋3分クリア",
	"ランカーモードクリア",
	"ランカーモードALLコンプリート",
]

## 詳細.
const DETAIL = [
	"3種の神器 (富士・鷹・茄子) を集める",
	"収集アイテムを 3個 だけ集めてクリアする",
	"収集アイテムを 18個 以上集めてクリアする",
	"すべての収集アイテムを集めてクリアする\n(達成するとランカーモードが開放されます)",
	"40秒以内でクリアする",
	"60秒以内でクリアする",
	"すべての収集アイテムを集めて\n3分以内にクリアする",
	"ランカーモードをクリアする",
	"ランカーモードで収集アイテムを\nすべて集めてクリアする",
]

# ----------------------------------------------
# public functions.
# ----------------------------------------------
## すべての実績開放チェック.
static func check_all_test() -> void:
	for id in range(Achievement.eType.size()):
		if check(id):
			# 実績開放.
			print(get_title(id))
			
				
## 実績開放チェック.
static func check(id:eType) -> bool:
	match id:
		eType.NORMAL_COMPLETED:
			return check_normal_completed()
		eType.MIN_COMPLETED:
			return Common.count_item() == 3
		eType.FAKE_COMPLETED:
			return Common.count_item() >= 18
		eType.ALL_COMPLETED:
			return Common.count_item() == 19
		eType.SPEEDRUN_40SEC:
			return Common.get_past_time_sec() <= 40
		eType.SPEEDRUN_60SEC:
			return Common.get_past_time_sec() <= 60
		eType.ALL_COMPLETED_3MIN:
			return Common.count_item() == 19 and Common.get_past_time_sec() <= 60 * 3
		eType.LUNKER_COMPLETED:
			if Common.is_lunker_support:
				return false
			return Common.is_lunker
		eType.LUNKER_ALL_COMPLETED:
			if Common.is_lunker_support:
				return false
			return Common.is_lunker and Common.count_item() == 19

	assert(0, "未定義の実績:%d"%id)	
	return false
	
## 通常クリアチェック.
static func check_normal_completed() -> bool:
	for id in Map.ITEM_LEGENDS:
		if Common.has_item(id) == false:
			return false
	return true
	
static func unlock(id:eType) -> void:
	Common.unlock_achievement(id)
static func unlocked(id:eType) -> bool:
	return Common.unlocked_achievement(id)
	
static func get_title(id:eType) -> String:
	return TITLE[id]
static func get_detail(id:eType) -> String:
	return DETAIL[id]
