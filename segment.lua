--[[
  segment.lua
  
  Region based segmentation processes
--]]



local il = require "il"


Xmin = 0
Xmax = 0
Ymin = 0
Ymax = 0
labels = {}

lowerthresh = 0
upperthresh = 0



local function stack_scanline(row, col, label)
 

  stack = {}
  local size = 0
  table.insert( stack, {row,col})
  --stack.push({row,col})
  
  ::continue::
  while( table.getn(stack) > 0 ) do
    local item = table.remove(stack) --stack.pop()
    
    row = item[1]
    col = item[2]
    
    if ((row == 0 or col == 0 ) or (row == Ymax or col == Xmax)) then
      --return
      goto continue -- there's no actual continue statement in LUA :(
    end
   
    local intensity = image_vals:at(row,col).i



    if (intensity < lowerthresh or intensity > upperthresh) or labels[row][col] > 0 then
      --return
      goto continue
    else
      labels[row][col] = label
    end
    
    
    local left_col = col - 1
    local left_pix = image_vals:at(row,col-1).i
    while( (left_pix < upperthresh) and (left_pix > lowerthresh) and (labels[row][left_col] == -1) ) do
        
        labels[row][left_col] = label
        size = size + 1
        if( new_col == 0) then
          break
        end
        
        --recurse up and down
        --scanline( row-1, new_col )
        --scanline( row+1, new_col )
        
        left_col = left_col - 1
        left_pix = image_vals:at(row,left_col).i
      
    end --end of while
    
    right_col = col + 1
    local right_pix = image_vals:at(row,col+1).i
    while( (right_pix < upperthresh) and (right_pix > lowerthresh) and (labels[row][right_col] == -1) ) do
      
      labels[row][right_col] = label
      size = size + 1
      if( right_col == Xmax) then
        break
      end
      
      --recurse up and down
      --scanline( row-1, right_col )
      --scanline( row+1, right_col )
      
      right_col = right_col + 1
      right_pix = image_vals:at(row,right_col).i
    
    end --end of while

  --  for a_col = left_col+1, right_col-1 do
    local it = right_col-1
    while( it > left_col+1 ) do
      --scanline( row - 1, a_col, label)
      --scanline( row + 1, a_col, label)
      table.insert(stack, {row-1, it}) --stack.push({row - 1, a_col})
      table.insert(stack, {row+1, it}) --stack.push({row + 1, a_col})
      it = it - 1
    end
    
    --return
  end
  
  return size
end







local function scanline(row, col, label)
 
 --[[
  --print("start label", label)
  if( label > 1 ) then
    print("test", label)
  end


  if( label == 400 ) then
  print( "row: ", row)
  print( "col: ", col)
  print( "int ", intensity )
  print( "lowerthresh ", lowerthresh)
  print( "upperthresh ", upperthresh)
  print("label: ", label)
end
--]]
  
  if ((row == 0 or col == 0 ) or (row == Ymax or col == Xmax)) then
    return
  end
 
  local intensity = image_vals:at(row,col).i



  if (intensity < lowerthresh or intensity > upperthresh) or labels[row][col] > 0 then
    return
  else
    labels[row][col] = label
  end
  
  
  local left_col = col - 1
  local left_pix = image_vals:at(row,col-1).i
  while( (left_pix < upperthresh) and (left_pix > lowerthresh) and (labels[row][left_col] == -1) ) do
      
      labels[row][left_col] = label
      
      if( new_col == 0) then
        break
      end
      
      --recurse up and down
      --scanline( row-1, new_col )
      --scanline( row+1, new_col )
      
      left_col = left_col - 1
      left_pix = image_vals:at(row,left_col).i
    
  end --end of while
  
  right_col = col + 1
  local right_pix = image_vals:at(row,col+1).i
  while( (right_pix < upperthresh) and (right_pix > lowerthresh) and (labels[row][right_col] == -1) ) do
    
    labels[row][right_col] = label
    
    if( right_col == Xmax) then
      break
    end
    
    --recurse up and down
    --scanline( row-1, right_col )
    --scanline( row+1, right_col )
    
    right_col = right_col + 1
    right_pix = image_vals:at(row,right_col).i
  
  end --end of while

  for a_col = left_col+1, right_col-1 do
    scanline( row - 1, a_col, label)
    scanline( row + 1, a_col, label)
  end
  
  return
end


local function generateRGB()
  
  return {math.random(0,255), math.random(0,255), math.random(0,255)}
  
end



local function stack_seedfill(img, thresh)
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
        
        --scanline(r, c, label)
        local size = stack_scanline( r, c, label )
        
        if size < 200 then
          label_colors[label] = { 0, 0 , 0}
        end
        
        
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