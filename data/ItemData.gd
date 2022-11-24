extends DataRow

class_name ItemData

var id: String
var name: String
var equip_category: String
var icon: Texture2D
var tooltip: String
var stackable: bool
var consumable_effect: String
var consumable_magnitude: int
	
static func get_csv_path():
	return "res://data/items.csv"
