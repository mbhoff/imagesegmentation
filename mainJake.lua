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
local f = require "fnc"
local f2 = require "fnc2"

-- Author:  Jake Miller
-- Variables:
--  in:
--    img - the original image
--    delta - the amount that the intenisty is allowed to vary
--  out:
--    img2 - the updated image
--
-- Description:
-- This function serves as the starting point for the split and merge process
--
local function main(img, delta)
  local row, col = img.height - 1, img.width - 1
  local x, y = col, row
  local xmin, ymin = 0, 0
  local region = {}
  local index = 0
  
  --copies and converts the image to yiq
  img = il.RGB2YIQ(img)
  local img2 = img:clone()
  
  -- checks to see if the image is homogeneous
  local test = f2.checkRegion(img, xmin, x, ymin, y, delta)
  
  --if the image is not homogeneous then it is split and if it is then the region is counted
  if test == false then
    region, index = f.split(img, xmin, x, ymin, y, region, index, delta)
  else
    region, index = f.countRegion(img, xmin, ymin, y, region, index)
  end
  
  -- the homogeneous regions are merged
  region = f.merge(region, index, delta)
  -- the image is updated with the new intensity values
  img2 = f.updateImage(img2, region, index)
  
  -- the image is converted back to rgb and displayed
  img2 = il.YIQ2RGB(img2)
  return img2
end

return
{
  main = main,
}
  