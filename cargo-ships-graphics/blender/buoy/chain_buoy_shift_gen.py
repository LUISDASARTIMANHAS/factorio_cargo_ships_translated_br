# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import PIL.Image as Image
import PIL.ImageChops as ImageChops
import math

# Step 1: Open the file for the bouy sprite

old_direction_number = 8


filenames = [[r"hr-chain-buoys-base_tlc.png", 64, -14],
             [r"hr-chain-buoys-shadow_tlc.png", 64, -14],
             [r"hr-chain-buoys-lights_tlc.png", 64, -14],
             [r"chain-buoys-water-reflection.png", 64*52/230, 16*52/230]]

for filename in filenames:
    OG_sheet = Image.open(filename[0])
    pixels_per_tile = filename[1]
    og_xshift = filename[2]
    
    
    width, height = OG_sheet.size
    sprite_size = height/old_direction_number  # because the original sprites have 8 rotations, but could have multiple frames on each line
    OG_sprite = ImageChops.offset(OG_sheet.crop((0,0,width,sprite_size)), round(og_xshift), 0)
    #OG_sprite.save("test1.png")
    
    
    # Step 2: Determine the center point
    # The sprite will be centered on the rail signal connection point,
    # which is 1.5 tiles from the center of the rail.
    # We want the signal to appear 2.5 tiles from the rail, along the same 
    # orthogonal vector as the signal connection point
    # This is how the OG sprite is shifted, for the "north" case with the signal on 
    # the left side of the rail
    
    center_radius = 1.5
    buoy_radius = 2.5
    
    rotation_radius_pixels = (buoy_radius-center_radius)*pixels_per_tile
    
    #image_center = (sprite_size/2+0.24*pixels_per_tile, sprite_size/2)
    #buoy_center = (image_center[0]-rotation_radius_pixels, image_center[1])
    
    # Step 3: Find all the rotations to use
    # Offset goes clockwise around to follow the rail
    new_direction_count = 16
    angles = [direction/new_direction_count*2*math.pi for direction in range(0,new_direction_count)]
    x_offsets = [round(rotation_radius_pixels*(1-math.cos(angle))) for angle in angles]
    y_offsets = [round(rotation_radius_pixels*(-math.sin(angle))) for angle in angles]
    
    # Step 4: Generate the rotated sprites
    # Make an array of all the shifted copies
    pictures= []
    
    for direction in range(new_direction_count):
        pictures.append(ImageChops.offset(OG_sprite, x_offsets[direction], y_offsets[direction]))
    
    
    # Step 5: Combine them together into the spritesheet
    NEW_sheet = Image.new("RGBA", (width, round(sprite_size*new_direction_count)))
    
    for direction in range(new_direction_count):
        NEW_sheet.paste(pictures[direction], (0, round(direction*sprite_size)))
    
    NEW_sheet.save(filename[0].split('.')[0]+"-16.png")
