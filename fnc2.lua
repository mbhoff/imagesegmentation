require "ip"
require "math"
local viz = require "visual"
local il = require "il"


local function checkRegion(img, xmin, x, ymin, y, variance)
  local sum = 0
  local max, min = 0, 256
  local test = false
  
  local amt2 = (x - xmin + 1) * (y - ymin + 1)
  
  if amt2 < 30 then
    return true
  end
  
  
  for r = ymin, y do
    for c = xmin, x do
      sum = img:at(r,c).y + sum
      
      if max < img:at(r,c).y then
        max = img:at(r,c).y
      elseif min > img:at(r,c).y then
        min = img:at(r,c).y
      end
    end
  end
  
  local amt = (x - xmin + 1) * (y - ymin + 1)
  sum = sum/amt
  local range = max - min
  
  if range <= (variance + sum) then
    test = true
  end
  
  return test
end

return
{
  checkRegion = checkRegion,
}
