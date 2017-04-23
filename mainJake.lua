require "ip"
require "math"
local viz = require "visual"
local il = require "il"
local f = require "fnc"
local f2 = require "fnc2"

local function main(img, variance)
  local row, col = img.height - 1, img.width - 1
  local x, y = col, row
  local xmin, ymin = 0, 0
  local region = {}
  local index = 0
  
  img = il.RGB2YIQ(img)
  local img2 = img:clone()
  
  local test = f2.checkRegion(img, xmin, x, ymin, y, variance)
  
  if test == false then
    img2, region, index = f.split(img, img2, xmin, x, ymin, y, region, index, variance)
  else
    img2, region, index = f.countRegion(img, img2, xmin, ymin, y, region, index)
  end
  
  region = f.merge(region, index, variance)
  img2 = f.updateImage(img2, region, index)
  
  img2 = il.YIQ2RGB(img2)
  return img2
end

return
{
  main = main,
}
  