extends Resource

# Metadatos de items usados por el HUD y la lógica de uso
const ITEMS = {
    "Wood": {
        "restores_energy": false,
        "restore_amount": 0,
        "icon": "res://assets/wood_icon.png"
    },
    "Fruit": {
        "restores_energy": true,
        "restore_amount": 30,
        "icon": "res://assets/fruit_icon.png"
    }
}

func has(item_name: String) -> bool:
    return ITEMS.has(item_name)

func get(item_name: String) -> Dictionary:
    return ITEMS.get(item_name, {})
