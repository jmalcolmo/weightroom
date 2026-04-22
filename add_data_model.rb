#!/usr/bin/env ruby
# add_data_model.rb
# Adds the Models group, CoreData model, and updated app file to WeightRoom.xcodeproj.

require 'xcodeproj'

PROJECT_DIR  = __dir__
PROJECT_PATH = File.join(PROJECT_DIR, 'WeightRoom.xcodeproj')
SOURCE_DIR   = File.join(PROJECT_DIR, 'WeightRoom')

project = Xcodeproj::Project.open(PROJECT_PATH)
app_target = project.targets.find { |t| t.name == 'WeightRoom' }

# Find the existing WeightRoom source group
source_group = project.main_group.children.find { |g| g.display_name == 'WeightRoom' }

# ── Models group ────────────────────────────────────────────────────────────
models_group = source_group.new_group('Models', 'Models')

model_files = %w[
  WorkoutType.swift
  Exercise.swift
  WorkoutSession.swift
  LoggedSet.swift
  Persistence.swift
]

model_files.each do |filename|
  path = File.join(SOURCE_DIR, 'Models', filename)
  ref  = models_group.new_file(path)
  app_target.source_build_phase.add_file_reference(ref)
end

# ── WeightRoomApp.swift (already in project — update reference, not re-add) ─
# Nothing to do — it was added during initial scaffold.

# ── CoreData model (.xcdatamodeld) ──────────────────────────────────────────
xcdatamodeld_path = File.join(SOURCE_DIR, 'WeightRoom.xcdatamodeld')
datamodel_ref = source_group.new_file(xcdatamodeld_path)
# CoreData models go in the Sources phase (Xcode compiles them via momc)
app_target.source_build_phase.add_file_reference(datamodel_ref)

project.save
puts '✓ Data model files added to WeightRoom.xcodeproj'
