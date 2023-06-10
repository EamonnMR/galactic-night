extends DataRow

class_name ItemData

enum CommodityPrice {
	LOW,
	MEDIUM,
	HIGH
}

const PRICE_NAMES = {
	CommodityPrice.LOW: "Low",
	CommodityPrice.MEDIUM: "Medium",
	CommodityPrice.HIGH: "High"
}

var id: String
var name: String
var equip_category
var icon: Texture2D
var tooltip: String
var stackable: bool
var consumable_effect: String
var consumable_magnitude: int
var commodity: bool
var price: int
var codex: String

func price_at(factor: CommodityPrice) -> int:
	return price * {
		CommodityPrice.HIGH: 1.25,
		CommodityPrice.MEDIUM: 1,
		CommodityPrice.LOW: 0.75
	}[factor]
	
func _init(data):
	super._init(data)
	if data["equip_category"]:
		equip_category = Equipment.CATEGORY.get(data["equip_category"].to_upper())

static func get_csv_path():
	return "res://data/items.csv"

func derive_codex_path():
	# TODO: Maybe some sort of automatic organization
	return codex
