--[[
  * * * * main.lua * * * *
Authors: Mark Buttenhoff, Dr. Weiss, Alex Iverson
Class: CSC442/542 Digital Image Processing
Date: Spring 2017
Program Description:
Contains functions for basic and otsu thresholding of images.

--]]

-- LuaIP image processing routines
require "ip"
local viz = require "visual"
local il = require "il"

local thr = require "threshold"
local nb = require "segment"
local main = require "mainJake"
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
    {"Spilt and Merge", main.main,
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