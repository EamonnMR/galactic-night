extends DataRow

class_name ItemData

enum CommodityPrice {
	LOW,
	MEDIUM,
	HIGH
}

var id: String
var name: String
var equip_category: String
var icon: Texture2D
var tooltip: String
var stackable: bool
var consumable_effect: String
var consumable_magnitude: int
var commodity: bool
var price: int

func price_at(factor: CommodityPrice) -> int:
	return price * {
		CommodityPrice.HIGH: 1.25,
		CommodityPrice.MEDIUM: 1,
		CommodityPrice.LOW: 0.75
	}[factor]

static func get_csv_path():
	return "res://data/items.csv"
