extends Node2D

export (Array, NodePath) var slot_cols
var active_slot_index = 0

func _ready():
	get_node(slot_cols[active_slot_index]).click_sfx_enabled = true

func slot_hit():
	if active_slot_index < slot_cols.size():
		if active_slot_index == slot_cols.size() - 1:
			$"match_complete".play()
		else:
			$"match_continue".play()
		get_node(slot_cols[active_slot_index]).stop()
		get_node(slot_cols[active_slot_index]).click_sfx_enabled = false
	if active_slot_index < slot_cols.size() - 1:	
		active_slot_index += 1
		get_node(slot_cols[active_slot_index]).click_sfx_enabled = true

func evaluate():
	pass
