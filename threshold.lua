--[[
  * * * * threshold.lua * * * *
  
This file contains the following auto threshold functions:
* basic global threshold
* otsu threshold

Author: Mark Buttenhoff, Dr. Weiss, Alex Iverson
Class: CSC442 Digital Image Processing
Date: Spring 2017
--]]

local il = require "il"
local math = require "math"

--[[
Function: basicThreshold
Author: Mark Buttenhoff
This function performs a basic global threshold on an image.
It initially uses the average image intensity to split the image into foreground and background groups,
then enters a loop that find the average of the pixels in each group respectively,
and lastly takes the average of those two group averages. This gives gives a threshold value, which
is re-calculated by using the previous steps until the amount of change in the threshold
is below a predefined parameter (I used 1).
--]]
local function basicthreshold(img)
  
  img = il.RGB2YIQ(img)
  
  local intensitySum = 0
  local count = 0
  
  --get global average pixel intensity
  for r = 0,img.height-1 do
      for c = 0,img.width-1 do
        intensitySum = intensitySum + img:at(r,c).y
        count = count + 1
      end
  end
  
  -- initialize previous threshold to something negative to make sure
  -- initial difference between prev and curr threshold is greater than 1
  local prevthreshold = -256
  
  -- initialize current threshold to the global intensity average
  local currthreshold = math.floor(intensitySum/count)
  
  -- while the threshold change for an iteration is greater than 1
  while((currthreshold - prevthreshold) > 1) do
    
    local group1intensitysum = 0
    local group2intensitysum = 0
    local group1pixelcount = 0
    local group2pixelcount = 0
    
    
    -- count all pixels in each class, and average them
    for r = 0,img.height-1 do
        for c = 0,img.width-1 do
          if (img:at(r,c).y > currthreshold) then
            group1intensitysum = group1intensitysum + img:at(r,c).y
            group1pixelcount = group1pixelcount + 1
          elseif (img:at(r,c).y <= currthreshold) then
            group2intensitysum = group2intensitysum + img:at(r,c).y
            group2pixelcount = group2pixelcount + 1
          end
        end
    end
    
    -- average the two group averages
    local group1average = group1intensitysum/group1pixelcount
    local group2average = group2intensitysum/group2pixelcount
    prevthreshold = currthreshold
    currthreshold = (group1average + group2average)/2
  end  

    -- binarize the image with the threshold found
    img = il.YIQ2RGB(img)
    return img:mapPixels(function( r, g, b )
      local pixelValue = r * .30 + g * .59 + b * .11
        if pixelValue > currthreshold
          then pixelValue = 255
        else pixelValue = 0
      end
        return pixelValue, pixelValue, pixelValue
    end
)
end


--[[
Function: otsuthreshold
Author: Mark Buttenhoff
This function first makes a intensity histogram,
then sums the weight of the intensities in the histogram.
For every possible intensity in the image(1-256),
we calculate the between class variance using the following equation:
Background Weight * Foreground Weight * (Background mean - Foreground mean)^2
The background weight and foreground weights are found by summing the values on the left and right
of the threshold in the histogram respectively. The means for each class are calculated by taking
(sum of (intensity values in class * their frequencies) / number of pixels in class),
Once we have the means and weights, we compute the between class variance
for the current iteration, and save the threshold value on iterations
where the between class variance is greater than the max between class variance.
--]]
local function otsuthreshold(img)
 
  img = il.RGB2YIQ(img)
  local hist = {}
  local totalPixels = 0


  -- make histogram
  for i = 1, 256 do hist[i] = 0 end
  img:mapPixels(function(y, i, q)
      hist[y+1] = hist[y+1] + 1
      totalPixels = totalPixels + 1
      return y, i, q
    end
  )


  -- compute global weight sum
  local globalWeightSum = 0
  for i = 1, 256 do globalWeightSum = globalWeightSum + (i * hist[i]) end
  
  local backgroundSum = 0;
  local backgroundWeight = 0;
  local foregroundWeight = 0;
  local maxVariance = 0
  local threshold = 0


  -- for every possible threshold
  for i=1,256 do
    
    -- get the background weight (the number of pixels in the background class)
    backgroundWeight = backgroundWeight + hist[i]
    
    -- get the foreground weight (the number of pixels in the foreground class)
    foregroundWeight = totalPixels - backgroundWeight
    
    -- sum (intensity value * frequency) in background class
    backgroundSum = backgroundSum + (i * hist[i])
    
    -- get background mean by taking (background sum / number of pixels in background class)
    local backgroundMean = backgroundSum/backgroundWeight
    
    -- get foreground mean by taking (foreground sum / number of pixels in foreground class)
    local foregroundMean = (globalWeightSum - backgroundSum) / foregroundWeight
    
    -- between class variance is product of the two weights and the squared difference between the means
    local betweenClassVariance = backgroundWeight * foregroundWeight * (backgroundMean - foregroundMean)^2
    
    -- if the current between class variance is greater than the max
    -- set max equal to the current, and set the threshold equal to i
    if(betweenClassVariance > maxVariance) then
      maxVariance = betweenClassVariance
      threshold = i
    end
    
  end

  img = il.YIQ2RGB(img)

  -- binarize the image with the threshold found
  return img:mapPixels(function( r, g, b )
    local pixelValue = r * .30 + g * .59 + b * .11 
      if pixelValue > threshold
        then pixelValue = 255
      else pixelValue = 0
    end
    
      return pixelValue, pixelValue, pixelValue
    end
  )

end

------------------------------------
-------- exported routines ---------
------------------------------------

return {
  basicthreshold = basicthreshold,
  otsuthreshold = otsuthreshold,
}