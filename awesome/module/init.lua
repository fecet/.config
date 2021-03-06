local gears = require("gears")
local dock = require("module.dock")
dock.init(screen.primary, 50, 5, gears.shape.rounded_rect)

require("module.bling")
require("module.rubato")
require("module.layout-machi")
require("module.better-resize")
require("module.exit-screen")
require("module.tooltip")
require("module.savefloats")
require("module.window_switcher").enable()
