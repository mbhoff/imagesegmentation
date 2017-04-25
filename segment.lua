--[[
  Author: Chance Haka
  segment.lua
  
  This file holds the functions that implement scan-line seedfilling for 
  region-based segmentation of an image. 
  All regions are created by comparing the gray-scale intensity of a seed pixel
  to its neighborhood.
  Requires the LuaIP library for processing.
--]]



local il = require "il"


Xmin = 0
Xmax = 0
Ymin = 0
Ymax = 0
labels = {}

lowerthresh = 0
upperthresh = 0


 --[[ Chance Haka
    This function changes the recursive scanline implementation to 
    a stack-based one. With a global image along with a seed pixel
    position and region ID, we start a seedfill.
    Scan the row that the seed is on for valid pixels that are similar to it.
    Then push the pixels that are below and above them onto the stack to process
    neighboring rows.
  --]]
local function stack_scanline(row, col, label)
 

  stack = {}
  local size = 0
  table.insert( stack, {row,col})
  --stack.push({row,col})
  
  ::continue::
  --while we still have pixels on the stack, process them
  while( table.getn(stack) > 0 ) do
    local item = table.remove(stack) --stack.pop()
    
    row = item[1]
    col = item[2]
    
    --if we are at the borders of the image
    if ((row == 0 or col == 0 ) or (row == Ymax or col == Xmax)) then
      --return
      goto continue -- there's no actual continue statement in LUA :(
    end
   
    local intensity = image_vals:at(row,col).i

    --if the current intensity is outisde of the range,skip this pixel
    if (intensity < lowerthresh or intensity > upperthresh) or labels[row][col] > 0 then
      --return
      goto continue
    else
      labels[row][col] = label --else it is a valid pixel, label it
    end
    
    
    local left_col = col - 1
    local left_pix = image_vals:at(row,col-1).i
    
    --scan to the left of the seed pixel 
    while( (left_pix < upperthresh) and (left_pix > lowerthresh) and (labels[row][left_col] == -1) ) do
        
        labels[row][left_col] = label
        size = size + 1
        if( new_col == 0) then
          break
        end
        
        left_col = left_col - 1
        left_pix = image_vals:at(row,left_col).i
      
    end --end of while
    
    right_col = col + 1
    local right_pix = image_vals:at(row,col+1).i
    
    --scan to the right side of the seed
    while( (right_pix < upperthresh) and (right_pix > lowerthresh) and (labels[row][right_col] == -1) ) do
      
      labels[row][right_col] = label
      size = size + 1
      if( right_col == Xmax) then
        break
      end
      
      right_col = right_col + 1
      right_pix = image_vals:at(row,right_col).i
    
    end --end of while

    --
    --scan from the right_endpoint to left_endpoint and push all the pixels onto the stack
    local it = right_col-1
    while( it > left_col+1 ) do
      --scanline( row - 1, a_col, label)
      --scanline( row + 1, a_col, label)
      
      --we will "recurse" on the upper pixel and lower pixel of each spot along this row
      table.insert(stack, {row-1, it}) --stack.push({row - 1, a_col})
      table.insert(stack, {row+1, it}) --stack.push({row + 1, a_col})
      it = it - 1
    end
    
    --return
  end
  
  return size
end






 --[[ Chance Haka
    This is a recursive scanline function that will fill a region using
    a global object that holds the image, intensity, and coordinates for the seed pixel.
    It scans the row that the starting coordinates are on for valid pixels that are within
    the intensity range given, then recursively calls scanline for the above and below
    rows.
  --]]
local function scanline(row, col, label)


  --if the starting coordinates are on the border, return
  if ((row == 0 or col == 0 ) or (row == Ymax or col == Xmax)) then
    return
  end
 
  local intensity = image_vals:at(row,col).i

  --if the starting coordinate is not within the threshold range (globals)
  if (intensity < lowerthresh or intensity > upperthresh) or labels[row][col] > 0 then
    return
  else
    labels[row][col] = label
  end
  
  
  --scan to the left of the seed
  local left_col = col - 1
  local left_pix = image_vals:at(row,col-1).i
  while( (left_pix < upperthresh) and (left_pix > lowerthresh) and (labels[row][left_col] == -1) ) do
      
      labels[row][left_col] = label
      
      if( new_col == 0) then
        break
      end
      
      
      left_col = left_col - 1
      left_pix = image_vals:at(row,left_col).i
    
  end --end of while
  
  
  --scan to the right of the seed
  right_col = col + 1
  local right_pix = image_vals:at(row,col+1).i
  while( (right_pix < upperthresh) and (right_pix > lowerthresh) and (labels[row][right_col] == -1) ) do
    
    labels[row][right_col] = label
    
    if( right_col == Xmax) then
      break
    end
    
    right_col = right_col + 1
    right_pix = image_vals:at(row,right_col).i
  
  end --end of while

  --for every pixel between the left/right endpoints recurse on the pixel
  --above and below
  for a_col = left_col+1, right_col-1 do
    scanline( row - 1, a_col, label)
    scanline( row + 1, a_col, label)
  end
  
  return
end


--returns a RGB array with random values
local function generateRGB()
  
  return {math.random(0,255), math.random(0,255), math.random(0,255)}
  
end


 --[[ Chance Haka
    stack_seedfill uses a stack based scanline algorithm to
    fill every region in the image given. This is used to
    eliminate stack overflow errors.
    
    This will set regions under certain size such as 200 pixels
    to black. To remove small rainbow regions
    
    User provides the image and the threshold offset
  --]]
local function stack_seedfill(img, thresh)
  local nrows, ncols = img.height, img.width
  Xmin = 1
  Ymin = 1
  Xmax = ncols - 2 
  Ymax = nrows - 2
  local label = 0
  local label_colors = {} -- LUT holding RGB values for each label/region
  
  --initialize label array to -1
  for i = 1, nrows+2 do
    labels[i] = {}
    for j = 1, ncols+2 do
      labels[i][j] = -1
      --print(labels[i][j])
    end
  end


  -- make a local copy of the image
  image_vals = img:clone()
    
  -- convert image from RGB to YIQ
  image_vals = il.RGB2IHS( image_vals )

  local label_value = 0;

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
    
      label_value = labels[r][c]
      
      --if the pixel is unlabeled, call the scanline-seedfill
      if label_value == -1 then
        local val = image_vals:at(r,c).i
        lowerthresh = val - thresh
        upperthresh = val + thresh
        label = label + 1
        label_colors[label] = generateRGB();
        
        --scanline(r, c, label)
        local size = stack_scanline( r, c, label )
        
        if size < 200 then
          label_colors[label] = { 0, 0 , 0}
        end
        
        
        img:at(r,c).r = label_colors[label][1]
        img:at(r,c).g = label_colors[label][2]
        img:at(r,c).b = label_colors[label][3]
        
      --otherwise we have a label to color the pixel with
      else
        img:at(r,c).r = label_colors[label_value][1]
        img:at(r,c).g = label_colors[label_value][2]
        img:at(r,c).b = label_colors[label_value][3]
      end
      
    end
  end

  print("max labels: ", label, "\n")

  return img

end


 --[[ Chance Haka
    This version of the seedfill implements a recursive
    scanline method. Uses a threshold given by the user
    to determine the variance for how big a region can be.
  --]]
local function seedfill(img, thresh)
  local nrows, ncols = img.height, img.width
  Xmin = 1
  Ymin = 1
  Xmax = ncols - 2 
  Ymax = nrows - 2
  local label = 0
  local label_colors = {}
  for i = 1, nrows+2 do
    labels[i] = {}
    for j = 1, ncols+2 do
      labels[i][j] = -1
      --print(labels[i][j])
    end
  end


  -- make a local copy of the image
  image_vals = img:clone()
    
  -- convert image from RGB to YIQ
  image_vals = il.RGB2IHS( image_vals )

  local label_value = 0;

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
    
      label_value = labels[r][c]
      if label_value == -1 then
        local val = image_vals:at(r,c).i
        lowerthresh = val - thresh
        upperthresh = val + thresh
        label = label + 1
        label_colors[label] = generateRGB();
        
        scanline(r, c, label)
        --stack_scanline( r, c, label )
        
        img:at(r,c).r = label_colors[label][1]
        img:at(r,c).g = label_colors[label][2]
        img:at(r,c).b = label_colors[label][3]
        
      else
        img:at(r,c).r = label_colors[label_value][1]
        img:at(r,c).g = label_colors[label_value][2]
        img:at(r,c).b = label_colors[label_value][3]
      end
      
    end
  end

  print("max labels: ", label, "\n")
 
  return img

end



 --[[ Chance Haka
    Sizefilter uses a stack-based scanline method to 
    find every region in a given image and compares
    their sizes. If they're under the size amount
    given by the user then its set to whatever color
    "filter" is. Such as white or black.
  --]]
local function sizefilter(img, thresh, size, filter)
  local nrows, ncols = img.height, img.width
  Xmin = 1
  Ymin = 1
  Xmax = ncols - 2 
  Ymax = nrows - 2
  local label = 0
  local label_colors = {}
  
  --set the label array to -1 for each index
  for i = 1, nrows+2 do
    labels[i] = {}
    for j = 1, ncols+2 do
      labels[i][j] = -1
      --print(labels[i][j])
    end
  end

  local filter_color = {}
  if filter == "white" then
    filter_color[1] = 255
    filter_color[2] = 255
    filter_color[3] = 255
  else
    filter_color[1] = 0 --else it is black
    filter_color[2] = 0
    filter_color[3] = 0
  end
  -- make a local copy of the image
  image_vals = img:clone()
    
  -- convert image from RGB to YIQ
  image_vals = il.RGB2IHS( image_vals )

  local label_value = 0;

  -- for each pixel in the image
  for r = 1, nrows-2 do
    for c = 1, ncols-2 do
    
      --if the pixel has been labeled use the LUT to color it in
      --otherwise call the scanline to fill in its region
      label_value = labels[r][c]
      if label_value == -1 then
        local val = image_vals:at(r,c).i
        lowerthresh = val - thresh
        upperthresh = val + thresh
        label = label + 1
        label_colors[label] = generateRGB();
        
        --scanline(r, c, label)
        local region_size = stack_scanline( r, c, label )
        
        if region_size < size then
          label_colors[label][1] = -2
          label_colors[label][2] = -2
          label_colors[label][3] = -2
          img:at(r,c).r = filter_color[1]
          img:at(r,c).g = filter_color[2]
          img:at(r,c).b = filter_color[3]
        end
        
      elseif label_colors[label_value][1] == -2 then
        img:at(r,c).r = filter_color[1]
        img:at(r,c).g = filter_color[2]
        img:at(r,c).b = filter_color[3]
      end
      
    end
  end

  print("max labels: ", label, "\n")

  return img

end
  



  
  return{
    seedfill = seedfill,
    scanline = scanline,
    sizefilter = sizefilter,
    stack_scanline = stack_scanline,
    stack_seedfill = stack_seedfill,
    }