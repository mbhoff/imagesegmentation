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

-- Author:  Jake Miller
-- Variables:
--  in:
--    img - the original image
--    xmin - the minimum x coordinate of the region
--    x - the maximum x coordinate of the region
--    ymin - the minimum y coordinate of the region
--    y - the maximum y coordinate of the region
--    delta - the amount that the intenisty is allowed to differ from the average
--  out:
--    true/false - if the region is homogeneous or not
--
-- Description:
-- This function computes the average intensity value of the region and if any pixel value differs by more than the 
-- delta value than the region is not considered homogeneous
--
local function checkRegion(img, xmin, x, ymin, y, delta)
  local sum = 0
  local val
  
  -- limits the region size to 25 pixels in order to avoid a stack overflow
  local amt2 = (x - xmin + 1) * (y - ymin + 1)
  if amt2 < 25 then
    return true
  end
  
  -- computes the sum of the pixel values
  for r = ymin, y do
    for c = xmin, x do
      sum = img:at(r,c).y + sum
    end
  end
  
  sum = sum/amt2
  
  -- determines if any intensity value differs by more than delta
  for r = ymin, y do
    for c = xmin, x do
      -- returns false if it is not homogeneous
      val = math.abs(img:at(r,c).y - sum)
      if val > delta then
        return false
      end
    end
  end
  
  return true
end

return
{
  checkRegion = checkRegion,
}
