extends Node

const PURE_SHAMAN_MERCY_FLAG := "pure_rep_shaman_mercy"
const MIXED_BETRAYED_OWN_FLAG := "mixed_betrayed_own"
const SHAMAN_RECRUITED_FLAG := "shaman_recruited"
const SHAMAN_KILLED_FLAG := "shaman_killed"

func get_axis_labels() -> Dictionary:
	var lawful_score := 0
	var chaotic_score := 0
	var good_score := 0
	var evil_score := 0

	if bool(PlayerData.get_ghost_flag(PURE_SHAMAN_MERCY_FLAG, false)):
		good_score += 1
	if bool(PlayerData.get_ghost_flag(MIXED_BETRAYED_OWN_FLAG, false)):
		evil_score += 1
	if bool(PlayerData.get_flag(SHAMAN_RECRUITED_FLAG, false)):
		chaotic_score += 1
	if bool(PlayerData.get_flag(SHAMAN_KILLED_FLAG, false)) and PlayerData.is_pure():
		lawful_score += 1

	return {
		"law_chaos": _resolve_axis_label("Lawful", "Chaotic", lawful_score, chaotic_score),
		"moral": _resolve_axis_label("Good", "Evil", good_score, evil_score),
	}

func get_alignment_label() -> String:
	var axes := get_axis_labels()
	var law_chaos := str(axes.get("law_chaos", "Neutral"))
	var moral := str(axes.get("moral", "Neutral"))
	if law_chaos == "Neutral" and moral == "Neutral":
		return "True Neutral"
	return "%s %s" % [law_chaos, moral]

func _resolve_axis_label(positive_label: String, negative_label: String, positive_score: int, negative_score: int) -> String:
	if positive_score > negative_score:
		return positive_label
	if negative_score > positive_score:
		return negative_label
	return "Neutral"
