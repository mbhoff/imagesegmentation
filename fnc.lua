--[[
 * @file 
 *
 * @mainpage <Final Project> - Split and Merge
 * 
 * @section course_section Course Information 
			CSC-442 Digital Image Processing Dr. Weiss
 *
 * @author Jake Miller
 * 
 * @date Monday April 24th
 * 
 * @par Professor: 
 *         Dr. Weiss
 * 
 * @par Course: 
 *         CSC-442 Digital Image Processing
 * 
 * @par Location: 
 *         McLaury 310
 *
 * @section program_section Program Information 
 * 
 * @details 
 * This program takes in am image and splits it up using a quadtree approach.  It tests to see if the region is homogeneous by 
 * comparing the average intensity value of region to given delta value.  If any pixel in the region is outside of the range, 
 * then the region is not homogeneous and further split up.  Once all regions are homogeneous, the regions will be merged together.
 * If a region is adjacent to the one being compared, then it will be given the same intensity value and label if it is within
 * the given delta value.  The image is then updated and outputted with the new intensity values.
 
 * This program cycles through the pixels and several times, thus causing it to run very slowly.  It takes about 10 seconds for 
 * it to run to completion.  When it is running, it will say "Not Responding", but it will complete if it is given enough time.
]]--

require "ip"
require "math"
local viz = require "visual"
local il = require "il"
local f2 = require "fnc2"


-- Author:  Jake Miller
-- Variables:
--  in:
--    img - the original image
--    xmin - the minimum x coordinate of the region
--    x - the maximum x coordinate of the region
--    ymin - the minimum y coordinate of the region
--    y - the maximum y coordinate of the region
--    region - the list that holds the homogeneous regions
--    index - the number of homogeneous regions
--  out:
--    region - the list of the homogeneous regions
--    index - the number of homogeneous regions
--
-- Description:
-- This function takes in the coordinates for a homogeneous region calculates the the average and
-- stores the average, the coordinates and the index in an array of the homogeneous regions
--
local function countRegion(img, xmin, x, ymin, y, region, index)
  local sum = 0
  
  --adds one more spot in the list for the new region to be added
  index = index + 1
  for i = index, index do
    region[i] = {}
    for j = 1, 6 do
      region[i][j] = 0
    end
  end
  
  -- sums the intensity value in the region
  for r = ymin, y do
    for c = xmin, x do
      sum = img:at(r,c).y + sum
    end
  end
  
  -- computes the number of pixels in the region and computes the average
  local amt = (x - xmin + 1) * (y - ymin + 1)
  local avg = sum/amt
  
  -- updates the new entry with the new region info
  region[index][1] = xmin
  region[index][2] = x
  region[index][3] = ymin
  region[index][4] = y
  region[index][5] = index
  region[index][6] = avg
  
  return region, index
end


-- Author:  Jake Miller
-- Variables:
--  in:
--    region - the list that holds the homogeneous regions
--    index - the number of homogeneous regions
--    delta - the amount that the average intensity value can be off my in order for it to be merged
--  out:
--    region - the list of the homogeneous regions
--
-- Description:
-- This function goes through the region array of homogeneous regions and determines if the regions are next
-- to each other.  If they are next to each other, within the given delta value and don't have the same label
-- then they are merged together with the same intensity value
--
local function merge(region, index, delta)
  
  -- compares every homogeneous region to one another
  for i = 1, index do
    for j = 1, index do
      
      -- if region 'j' is above or below region 'i'
      if ((region[i][3] <= region[j][3] and region[i][4] >= region[j][4]) or (region[i][3] >= region[i][3] and region[i][4] <= region[j][4])) then
        
        -- if region 'j' is on the same x axis of region 'i'
        if ((region[i][2] + 1 == region[j][1]) or (region[i][1] - 1 == region[j][2])) then
          
          -- if the absolute value of the region is less than the given delta value and the don't
          -- have the same label
          if math.abs(region[i][6] - region[j][6]) <= delta and region[i][5] ~= region[j][5] then
            -- they are given the same label and the same intensity value
            region[j][6] = region[i][6]
            region[j][5] = region[i][5]
          end
        end
      end
      
      -- if the region 'j' is to the left or the right of region 'i'
      if ((region[i][1] >= region[j][1] and region[i][2] <= region[j][2]) or (region[i][1] <= region[j][1] and region[i][2] >= region[j][2])) then
      
        -- if region 'j' is on the same y axis as region 'i'
        if ((region[i][4] + 1 == region[j][3]) or (region[i][3] - 1 == region[j][4])) then
          
          -- if the absolute value of the region is less than the given delta value and the don't
          -- have the same label
          if math.abs(region[i][6] - region[j][6]) <= delta and region[i][5] ~= region[j][5] then
            -- they are given the same label and the same intensity value
            region[j][6] = region[i][6]
            region[j][5] = region[i][5]
          end
        end
      end
    end
  end
  
  return region
end


-- Author:  Jake Miller
-- Variables:
--  in:
--    img2 - the image to be updated with the new intnsities
--    region - the list that holds the homogeneous regions
--    index - the number of homogeneous regions
--  out:
--    img2 - the updated image
--
-- Description:
-- This function goes throught the list of homogeneous regions and updates the image with the average intensity values
--
local function updateImage(img2, region, index)
  
  -- goes through the entire list
  for i = 1, index do
    -- varies the y values of the region
    for r = region[i][3], region[i][4] do
      -- varies the x values of the region
      for c = region[i][1], region[i][2] do
        img2:at(r,c).y = region[i][6]
      end
    end
  end
  
  return img2
end


-- Author:  Jake Miller
-- Variables:
--  in:
--    img - the original image
--    xmin - the minimum x coordinate of the region
--    x - the maximum x coordinate of the region
--    ymin - the minimum y coordinate of the region
--    y - the maximum y coordinate of the region
--    region - the list that holds the homogeneous regions
--    index - the number of homogeneous regions
--    delta - the amount that it's allowed to vary
--  out:
--    region - the list of the homogeneous regions
--    index - the number of homogeneous regions
--
-- Description:
-- This function takes in the coordinates for a homogeneous region calculates the the average and
-- stores the average, the coordinates and the index in an array of the homogeneous regions
--
local function split(img, xmin, x, ymin, y, region, index, delta)
  local row, col = img.height, img.width
  local crd = {}
  
  -- creates an array for the coordinates of the regions
  for i=1,4 do
    crd[i] = {}
    for j=1,4 do
      crd[i][j] = 0
    end
  end
  
  -- calculates the midpoints for the x and y axis
  local xmid = math.floor((x-xmin+1)/2) + xmin
  local ymid = math.floor((y-ymin+1)/2) + ymin
  
  -- different regions
  --crd = {xmin, xmid, ymin, ymid}
  --top left
  crd[1] = {xmin, xmid, ymin, ymid}
  --top right
  crd[2] = {xmid + 1, x, ymin, ymid}
  --bottom left
  crd[3] = {xmin, xmid, ymid + 1, y}
  --bottom right
  crd[4] = {xmid + 1, x , ymid + 1, y}
  
  -- cyles through the different regions
  for i = 1, 4 do
    -- tests if the region is homogeneous
    local test = f2.checkRegion(img, crd[i][1], crd[i][2], crd[i][3], crd[i][4], delta)
    
    -- splits the region recursively if it is not homogeneous and counts it if it is
    if test == false then
      region, index = split(img, crd[i][1], crd[i][2], crd[i][3], crd[i][4], region, index, delta)
    else
      region, index = countRegion(img, crd[i][1], crd[i][2], crd[i][3], crd[i][4], region, index)
    end
  end
  
  return region, index
end

return
{
  split = split,
  countRegion = countRegion,
  updateImage = updateImage,
  merge = merge,
}