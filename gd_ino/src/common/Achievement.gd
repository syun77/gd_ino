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
