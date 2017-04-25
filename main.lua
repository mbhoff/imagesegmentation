--[[
  * * * * main.lua * * * *
Authors: Mark Buttenhoff, Chance Haka, Jake Miller
Class: CSC442/542 Digital Image Processing
Date: Spring 2017
Program Description:
This program implements region based thresholding methods along with
automated thresholding ones.

Using the LuaIP library, this program can modify images through
thresholding, seedfilling, and a split/merge algorithm.
The binary thresholding includes a basic approach as well as the Otsu method.
Seedfilling implements both a recursive and stack-based scanline to fill every region in the image.
Split/merge separates the image into blocks that represent a group of similar pixels. Then 
adjacent regions can then be merged together based on their gray-scale intensities.
--]]

-- LuaIP image processing routines
require "ip"
local viz = require "visual"
local il = require "il"

local thr = require "threshold"
local nb = require "segment"
local splitmerge = require "splitmerge"
-----------
-- menus --
-----------

imageMenu("Auto Threshold Processes",
  {
    
      {"Basic threshold", thr.basicthreshold},
      {"Otsu threshold", thr.otsuthreshold},
  }
)

imageMenu("Histogram processes",
  {
    {"Display Histogram", il.showHistogram,
       {{name = "color model", type = "string", default = "yiq"}}},
  }
)

viz.imageMenu("Split/Merge",
  {
    {"Spilt and Merge", splitmerge.main,
    {{name = "variance", type = "number", displaytype = "slider", default = 10, min = 0, max = 100}}},
  }
)

imageMenu("Region Segmentation",
  {
      {"Grayscale IHS", il.grayscaleIHS},
      {"Seedfill", nb.seedfill,
        {{name = "Threshold", type = "number", displaytype = "slider", default = 35, min = 0, max = 255}}},
      {"Stack-based Seedfill", nb.stack_seedfill,
        {{name = "Threshold", type = "number", displaytype = "slider", default = 35, min = 0, max = 255}}},
      {"Size filter", nb.sizefilter,
        {{name = "Threshold", type = "number", displaytype = "slider", default = 35, min = 0, max = 255},
        {name = "Size", type = "number", displaytype = "spin", default = 100, min = 0, max = 10000},
        {name = "Filter color", type = "string", displaytype = "combo", choices = {"white", "black"}, default = "white"}}},
     
  }
)

start()