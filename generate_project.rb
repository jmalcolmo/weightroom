#!/usr/bin/env ruby
# generate_project.rb
# Generates WeightRoom.xcodeproj with Dev and Prod schemes via the xcodeproj gem.

require 'xcodeproj'
require 'fileutils'

PROJECT_NAME    = 'WeightRoom'
PROJECT_DIR     = __dir__
SOURCE_DIR      = File.join(PROJECT_DIR, PROJECT_NAME)
CONFIGS_DIR     = File.join(PROJECT_DIR, 'Configs')
BUNDLE_ID_DEV   = 'com.jmalcolmo.weightroom.dev'
BUNDLE_ID_PROD  = 'com.jmalcolmo.weightroom'
TEAM_ID         = ''  # Fill in your Apple Developer Team ID when you enroll

# ---------------------------------------------------------------------------
# 1. Create project
# ---------------------------------------------------------------------------
project_path = File.join(PROJECT_DIR, "#{PROJECT_NAME}.xcodeproj")
project = Xcodeproj::Project.new(project_path)

# ---------------------------------------------------------------------------
# 2. App target (auto-creates Debug/Release configs on project + target)
# ---------------------------------------------------------------------------
app_target = project.new_target(:application, PROJECT_NAME, :ios, '17.0')

# ---------------------------------------------------------------------------
# 3. Rename Debug → Dev, Release → Prod on both the project and target
# ---------------------------------------------------------------------------
[project, app_target].each do |obj|
  obj.build_configurations.each do |config|
    case config.name
    when 'Debug'   then config.name = 'Dev'
    when 'Release' then config.name = 'Prod'
    end
  end
  obj.build_configuration_list.default_configuration_name = 'Prod'
end

# ---------------------------------------------------------------------------
# 4. Target build settings per config
# ---------------------------------------------------------------------------
dev_settings = {
  'ASSETCATALOG_COMPILER_APPICON_NAME'             => 'AppIcon',
  'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME' => 'AccentColor',
  'CODE_SIGN_STYLE'                                => 'Automatic',
  'DEVELOPMENT_TEAM'                               => TEAM_ID,
  'ENABLE_PREVIEWS'                                => 'YES',
  'INFOPLIST_FILE'                                 => "#{PROJECT_NAME}/Info.plist",
  'LD_RUNPATH_SEARCH_PATHS'                        => ['$(inherited)', '@executable_path/Frameworks'],
  'MARKETING_VERSION'                              => '1.0',
  'CURRENT_PROJECT_VERSION'                        => '1',
  'SWIFT_EMIT_LOC_STRINGS'                         => 'YES',
  'SWIFT_VERSION'                                  => '5.0',
  'TARGETED_DEVICE_FAMILY'                         => '1',
  'PRODUCT_BUNDLE_IDENTIFIER'                      => BUNDLE_ID_DEV,
  'PRODUCT_NAME'                                   => 'WeightRoom Dev',
  'INFOPLIST_KEY_CFBundleDisplayName'              => 'WeightRoom Dev',
  'DEBUG_INFORMATION_FORMAT'                       => 'dwarf',
  'SWIFT_OPTIMIZATION_LEVEL'                       => '-Onone',
  'SWIFT_ACTIVE_COMPILATION_CONDITIONS'            => 'DEBUG DEV',
  'GCC_PREPROCESSOR_DEFINITIONS'                   => ['DEV=1', '$(inherited)'],
  'MTL_ENABLE_DEBUG_INFO'                          => 'INCLUDE_SOURCE',
}

prod_settings = {
  'ASSETCATALOG_COMPILER_APPICON_NAME'             => 'AppIcon',
  'ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME' => 'AccentColor',
  'CODE_SIGN_STYLE'                                => 'Automatic',
  'DEVELOPMENT_TEAM'                               => TEAM_ID,
  'ENABLE_PREVIEWS'                                => 'YES',
  'INFOPLIST_FILE'                                 => "#{PROJECT_NAME}/Info.plist",
  'LD_RUNPATH_SEARCH_PATHS'                        => ['$(inherited)', '@executable_path/Frameworks'],
  'MARKETING_VERSION'                              => '1.0',
  'CURRENT_PROJECT_VERSION'                        => '1',
  'SWIFT_EMIT_LOC_STRINGS'                         => 'YES',
  'SWIFT_VERSION'                                  => '5.0',
  'TARGETED_DEVICE_FAMILY'                         => '1',
  'PRODUCT_BUNDLE_IDENTIFIER'                      => BUNDLE_ID_PROD,
  'PRODUCT_NAME'                                   => 'WeightRoom',
  'INFOPLIST_KEY_CFBundleDisplayName'              => 'WeightRoom',
  'DEBUG_INFORMATION_FORMAT'                       => 'dwarf-with-dsym',
  'SWIFT_OPTIMIZATION_LEVEL'                       => '-O',
  'SWIFT_ACTIVE_COMPILATION_CONDITIONS'            => 'PROD',
  'VALIDATE_PRODUCT'                               => 'YES',
  'COPY_PHASE_STRIP'                               => 'NO',
}

app_target.build_configurations.each do |config|
  case config.name
  when 'Dev'  then config.build_settings.merge!(dev_settings)
  when 'Prod' then config.build_settings.merge!(prod_settings)
  end
end

# ---------------------------------------------------------------------------
# 5. File references and groups
# ---------------------------------------------------------------------------
main_group = project.main_group

# Configs group
configs_group = main_group.new_group('Configs', 'Configs')
['Base.xcconfig', 'Dev.xcconfig', 'Prod.xcconfig'].each do |cfg|
  configs_group.new_file(File.join(CONFIGS_DIR, cfg))
end

# App source group
source_group = main_group.new_group(PROJECT_NAME, PROJECT_NAME)

swift_files = ['WeightRoomApp.swift', 'ContentView.swift']
swift_refs = swift_files.map do |f|
  source_group.new_file(File.join(SOURCE_DIR, f))
end

assets_ref    = source_group.new_file(File.join(SOURCE_DIR, 'Assets.xcassets'))
preview_group = source_group.new_group('Preview Content', 'Preview Content')
preview_ref   = preview_group.new_file(File.join(SOURCE_DIR, 'Preview Content', 'Preview Assets.xcassets'))
source_group.new_file(File.join(SOURCE_DIR, 'Info.plist'))

# Move Products reference into a Products group
products_group = main_group.new_group('Products')
app_target.product_reference.move(products_group)

# ---------------------------------------------------------------------------
# 6. Add files to build phases
# ---------------------------------------------------------------------------
swift_refs.each { |ref| app_target.source_build_phase.add_file_reference(ref) }
app_target.resources_build_phase.add_file_reference(assets_ref)
app_target.resources_build_phase.add_file_reference(preview_ref)

# ---------------------------------------------------------------------------
# 7. Schemes
# ---------------------------------------------------------------------------
schemes_dir = File.join(project_path, 'xcshareddata', 'xcschemes')
FileUtils.mkdir_p(schemes_dir)

def write_scheme(schemes_dir, scheme_name, config_name, project_name)
  # We rely on target UUID lookup — use a container reference only
  xml = <<~XML
    <?xml version="1.0" encoding="UTF-8"?>
    <Scheme
       LastUpgradeVersion = "1500"
       version = "1.7">
       <BuildAction
          parallelizeBuildables = "YES"
          buildImplicitDependencies = "YES">
          <BuildActionEntries>
             <BuildActionEntry
                buildForTesting = "YES"
                buildForRunning = "YES"
                buildForProfiling = "YES"
                buildForArchiving = "YES"
                buildForAnalyzing = "YES">
                <BuildableReference
                   BuildableIdentifier = "primary"
                   BlueprintIdentifier = "PLACEHOLDER"
                   BuildableName = "#{project_name}.app"
                   BlueprintName = "#{project_name}"
                   ReferencedContainer = "container:#{project_name}.xcodeproj">
                </BuildableReference>
             </BuildActionEntry>
          </BuildActionEntries>
       </BuildAction>
       <TestAction
          buildConfiguration = "#{config_name}"
          selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
          selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
          shouldUseLaunchSchemeArgsEnv = "YES"
          shouldAutocreateTestPlan = "YES">
       </TestAction>
       <LaunchAction
          buildConfiguration = "#{config_name}"
          selectedDebuggerIdentifier = "Xcode.DebuggerFoundation.Debugger.LLDB"
          selectedLauncherIdentifier = "Xcode.DebuggerFoundation.Launcher.LLDB"
          launchStyle = "0"
          useCustomWorkingDirectory = "NO"
          ignoresPersistentStateOnLaunch = "NO"
          debugDocumentVersioning = "YES"
          debugServiceExtension = "internal"
          allowLocationSimulation = "YES">
          <BuildableProductRunnable
             runnableDebuggingMode = "0">
             <BuildableReference
                BuildableIdentifier = "primary"
                BlueprintIdentifier = "PLACEHOLDER"
                BuildableName = "#{project_name}.app"
                BlueprintName = "#{project_name}"
                ReferencedContainer = "container:#{project_name}.xcodeproj">
             </BuildableReference>
          </BuildableProductRunnable>
       </LaunchAction>
       <ProfileAction
          buildConfiguration = "#{config_name}"
          shouldUseLaunchSchemeArgsEnv = "YES"
          savedToolIdentifier = ""
          useCustomWorkingDirectory = "NO"
          debugDocumentVersioning = "YES">
          <BuildableProductRunnable
             runnableDebuggingMode = "0">
             <BuildableReference
                BuildableIdentifier = "primary"
                BlueprintIdentifier = "PLACEHOLDER"
                BuildableName = "#{project_name}.app"
                BlueprintName = "#{project_name}"
                ReferencedContainer = "container:#{project_name}.xcodeproj">
             </BuildableReference>
          </BuildableProductRunnable>
       </ProfileAction>
       <AnalyzeAction
          buildConfiguration = "#{config_name}">
       </AnalyzeAction>
       <ArchiveAction
          buildConfiguration = "#{config_name}"
          revealArchiveInOrganizer = "YES">
       </ArchiveAction>
    </Scheme>
  XML
  File.write(File.join(schemes_dir, "#{scheme_name}.xcscheme"), xml)
end

# Save the project first so we can read the real target UUID
project.save
target_uuid = app_target.uuid

# Write schemes then patch in the real target UUID
write_scheme(schemes_dir, 'WeightRoom-Dev',  'Dev',  PROJECT_NAME)
write_scheme(schemes_dir, 'WeightRoom-Prod', 'Prod', PROJECT_NAME)

['WeightRoom-Dev', 'WeightRoom-Prod'].each do |name|
  path = File.join(schemes_dir, "#{name}.xcscheme")
  content = File.read(path)
  content.gsub!('PLACEHOLDER', target_uuid)
  File.write(path, content)
end

puts "✓ #{PROJECT_NAME}.xcodeproj created"
puts "  Schemes : WeightRoom-Dev  (bundle: #{BUNDLE_ID_DEV})"
puts "            WeightRoom-Prod (bundle: #{BUNDLE_ID_PROD})"
puts "  Target UUID: #{target_uuid}"
