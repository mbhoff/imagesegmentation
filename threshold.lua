--[[
  * * * * functions.lua * * * *
  
This file contains the following kirsch edge detection functions:
* kirsch magnitude
* kirsch direction

Author: Mark Buttenhoff, Dr. Weiss, Alex Iverson
Class: CSC442 Digital Image Processing
Date: Spring 2017
--]]

local il = require "il"
local math = require "math"

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
  
  local prevthreshold = -256
  local currthreshold = math.floor(intensitySum/count)
  
  while((currthreshold - prevthreshold) > 1) do
    
    local group1intensitysum = 0
    local group2intensitysum = 0
    local group1pixelcount = 0
    local group2pixelcount = 0
    
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
    
    local group1average = group1intensitysum/group1pixelcount
    local group2average = group2intensitysum/group2pixelcount
    prevthreshold = currthreshold
    currthreshold = (group1average + group2average)/2
  end  

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



local function otsuthreshold(img)
 
  img = il.RGB2YIQ(img)
  local hist = {}
  local totalPixels = 0

  for i = 1, 256 do hist[i] = 0 end
  img:mapPixels(function(y, i, q)
      hist[y+1] = hist[y+1] + 1
      totalPixels = totalPixels + 1
      return y, i, q
    end
  )

  local weightSum = 0
  for i = 1, 256 do weightSum = weightSum + (i * hist[i]) end
  
  local backgroundSum = 0;
  local backgroundWeight = 0;
  local foregroundWeight = 0;
  local maxVariance = 0
  local threshold = 0

  for i=1,256 do
    backgroundWeight = backgroundWeight + hist[i]
    
    foregroundWeight = totalPixels - backgroundWeight
    
    backgroundSum = backgroundSum + (i * hist[i])
    
    local backgroundMean = backgroundSum/backgroundWeight
    
    local foregroundMean = (weightSum - backgroundSum) / foregroundWeight
    
    local betweenClassVariance = backgroundWeight * foregroundWeight * (backgroundMean - foregroundMean)^2
    
    if(betweenClassVariance > maxVariance) then
      maxVariance = betweenClassVariance
      threshold = i
    end
    
  end

  img = il.YIQ2RGB(img)

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