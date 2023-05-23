extends NinePatchRect

var entry: String = ""

var index: Dictionary = {}

func fill_out_directory(node: TreeItem, source_node: Dictionary, path: Array):
	for item in source_node:
		var child = %Tree.create_item(node)
		child.set_text(0, item)
		var local_path = path + [item]
		if source_node[item] is Dictionary:
			fill_out_directory(child, source_node[item], local_path)
		else:
			index[child] = local_path

func _ready():
	var root = %Tree.create_item()
	%Tree.hide_root = true
	index = {}
	fill_out_directory(root, Data.codex, [])


func select_entry_by_index(index: int):
	_select_entry(self.index[index])

func select_entry_by_path(entry_path: String):
	_select_entry(entry_path.split("/"))

func _select_entry(path: Array):
	self.entry = entry
	%Text.text = walk_tree(Data.codex, path)

func walk_tree(tree, path: Array):
	for i in path:
		tree = tree[i]
	return tree


#func _on_tree_button_clicked(item, column, id, mouse_button_index):
#	breakpoint
#	_select_entry(index[id])


func _on_tree_cell_selected():
	var selected = %Tree.get_selected()
	if selected in index:
		_select_entry(index[selected])
