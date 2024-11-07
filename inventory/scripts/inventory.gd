extends Node2D

var items_array = [ItemData]
@onready var inventory_slot = $CanvasLayer/Control/Panel/HBoxContainer

func pick_up(data: ItemData):
	items_array.append(data)
	var slot = TextureRect.new()
	slot.texture = data.icon
	#size is a placeholder
	slot.expand_mode = TextureRect.EXPAND_FIT_WIDTH
	inventory_slot.add_child(slot)
	

func drop_item(data: ItemData):
	var item_index = items_array.find(data)
	items_array.remove_at(item_index)
	var slots = inventory_slot.get_child_count()
	for slot in range(slots -1, -1, -1):
		var child = inventory_slot.get_child(slot)
		if child.texture == data.icon:
			inventory_slot.remove_child(child)
	

func check_item(data: ItemData):
	for item in items_array:
		if item == data:
			return item
