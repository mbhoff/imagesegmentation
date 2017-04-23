require "ip"
local viz = require "visual"
local main = require "main"

viz.imageMenu("Image Segmentation",
  {
    {"Spilt and Merge", main.main,
    {{name = "variance", type = "number", displaytype = "slider", default = 10, min = 0, max = 100}}},
  }
)

start()