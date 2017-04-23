require "ip"
require "math"
local viz = require "visual"
local il = require "il"
local f2 = require "fnc2"


local function countRegion(img, img2, xmin, x, ymin, y, region, index)
  local sum = 0
  
  index = index + 1
  for i = index, index do
    region[i] = {}
    for j = 1, 6 do
      region[i][j] = 0
    end
  end
  
  for r = ymin, y do
    for c = xmin, x do
      sum = img:at(r,c).y + sum
      img2:at(r,c).y = index
    end
  end
  
  local amt = (x - xmin + 1) * (y - ymin + 1)
  local avg = sum/amt
  
  region[index][1] = xmin
  region[index][2] = x
  region[index][3] = ymin
  region[index][4] = y
  region[index][5] = index
  region[index][6] = avg
  
  return img2, region, index
end

local function merge(region, index, variance)
  
  for i = 1, index do
    for j = 1, index do
      
      if ((region[i][3] <= region[j][3] and region[i][4] >= region[j][4]) or (region[i][3] >= region[i][3] and region[i][4] <= region[j][4])) then
      
        if ((region[i][2] + 1 == region[j][1]) or (region[i][1] - 1 == region[j][2])) then
          if math.abs(region[i][6] - region[j][6]) <= variance and region[i][5] ~= region[j][5] then
            region[j][6] = region[i][6]
            region[j][5] = region[i][5]
          end
        end
      end
      
      if ((region[i][1] >= region[j][1] and region[i][2] <= region[j][2]) or (region[i][1] <= region[j][1] and region[i][2] >= region[j][2])) then
      
        if ((region[i][4] + 1 == region[j][3]) or (region[i][3] - 1 == region[j][4])) then
          if math.abs(region[i][6] - region[j][6]) <= variance and region[i][5] ~= region[j][5] then
            region[j][6] = region[i][6]
            region[j][5] = region[i][5]
          end
        end
      end
    end
  end
  
  return region
end

local function updateImage(img2, region, index)
  
  for i = 1, index do
    for r = region[i][3], region[i][4] do
      for c = region[i][1], region[i][2] do
        img2:at(r,c).y = region[i][6]
      end
    end
  end
  
  return img2
end

local function split(img, img2, xmin, x, ymin, y, region, index, variance)
  local row, col = img.height, img.width
  local crd = {}
  
  
  for i=1,4 do
    crd[i] = {}
    for j=1,4 do
      crd[i][j] = 0
    end
  end
  
  local xmid = math.floor((x-xmin+1)/2) + xmin
  local ymid = math.floor((y-ymin+1)/2) + ymin
  
  --crd = {xmin, xmid, ymin, ymid}
  --top left
  crd[1] = {xmin, xmid, ymin, ymid}
  --top right
  crd[2] = {xmid + 1, x, ymin,ymid}
  --bottom left
  crd[3] = {xmin, xmid, ymid + 1, y}
  --bottom right
  crd[4] = {xmid + 1, x , ymid + 1, y}
  
  for i = 1, 4 do
    local test = f2.checkRegion(img, crd[i][1], crd[i][2], crd[i][3], crd[i][4], variance)
    
    if test == false then
      img2, region, index = split(img, img2, crd[i][1], crd[i][2], crd[i][3], crd[i][4], region, index, variance)
    else
      img2, region, index = countRegion(img, img2, crd[i][1], crd[i][2], crd[i][3], crd[i][4], region, index)
    end
  end
  
  return img2, region, index
end

return
{
  split = split,
  countRegion = countRegion,
  updateImage = updateImage,
  merge = merge,
}