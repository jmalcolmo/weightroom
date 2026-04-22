#!/usr/bin/env ruby
# add_home_screen.rb
# Adds HomeView.swift to WeightRoom.xcodeproj.

require 'xcodeproj'

PROJECT_PATH = File.join(__dir__, 'WeightRoom.xcodeproj')
SOURCE_DIR   = File.join(__dir__, 'WeightRoom')

project    = Xcodeproj::Project.open(PROJECT_PATH)
app_target = project.targets.find { |t| t.name == 'WeightRoom' }
source_group = project.main_group.children.find { |g| g.display_name == 'WeightRoom' }

ref = source_group.new_file(File.join(SOURCE_DIR, 'HomeView.swift'))
app_target.source_build_phase.add_file_reference(ref)

project.save
puts '✓ HomeView.swift added to WeightRoom.xcodeproj'
