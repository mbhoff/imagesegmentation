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
-----------
-- menus --
-----------

imageMenu("Auto Threshold Processes",
  {
    
      {"Basic threshold", thr.basicthreshold},
      {"Otsu threshold", thr.otsuthreshold},
  }
)

start()