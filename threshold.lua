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
  
  local intensitysum = 0
  local count = 0
  
  --get global average pixel intensity
  for r = 0,img.height-1 do
      for c = 0,img.width-1 do
        
        intensitysum = intensitysum + img:at(r,c).y
        count = count + 1
      end
  end
  
  
  local prevthreshold = -20
  local currthreshold = math.floor(intensitysum/count)
  

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
  --]]
end
end


local function otsuthreshold(img)
 
  img = il.RGB2YIQ(img)
 
  local hist = {}
  totalPixels = 0
  for i = 1, 256 do hist[i] = 0 end
  img:mapPixels(function(y, i, q)
      hist[y+1] = hist[y+1] + 1
      totalPixels = totalPixels + 1
      return y, i, q
    end
  )


  weightSum = 0
  for i = 1, 256 do weightSum = weightSum + (i * hist[i]) end
    
  backgroundSum = 0;
  weightBackground = 0;
  weightForeground = 0;

  maxVariance = 0
  threshold = 0

  for i=1,256 do
    weightBackground = weightBackground + hist[i]
    
    weightForeground = totalPixels - weightBackground
    
    backgroundSum = backgroundSum + (i * hist[i])
    
    meanBackground = backgroundSum/weightBackground
    
    meanForeground = (weightSum - backgroundSum) / weightForeground
    
    betweenClassVariance = weightBackground * weightForeground * (meanBackground - meanForeground)^2
    
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