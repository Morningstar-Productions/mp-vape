# mp-vape
Vape / Stress Reduce Resource for Overextended Resources

## Installation
- Copy/Paste Images into ox_inventory/web/images or Drag and Drop
- Put this into your ox_inventory/data/items.lua

```lua
    ["vape"] = {
        label = "Vape",
        weight = 250,
        stack = false,
        degrade = 20160,
        decay = false,
        description = "For the kids who think clouds are cool.",
        consume = 0,
        server = { export = 'randol_vape.useVape' },
        client = { image = "vape.png" },
        dropModel = `ba_prop_battle_vape_01`
    },

    ["vapejuice"] = {
        label = "Vape Juice",
        weight = 10,
        close = true,
        description = "100ml Vape Juice.",
        client = { image = "vapejuice.png" },
        dropModel = `brum_watermelon_elfbar`
    },
```