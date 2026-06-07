# minimum macOS target support
if(CMAKE_OSX_DEPLOYMENT_TARGET VERSION_LESS TR_MACOS_LEGACY_SUPPORT_MINIMUM)
    message(FATAL_ERROR "Targeting macOS versions before ${TR_MACOS_LEGACY_SUPPORT_MINIMUM} is not supported for the macOS project, please adjust CMAKE_OSX_DEPLOYMENT_TARGET (${CMAKE_OSX_DEPLOYMENT_TARGET})")
endif()

set(TR_MACOS_USE_SOURCE_IMAGE_ASSETS OFF)
if(CMAKE_OSX_DEPLOYMENT_TARGET VERSION_LESS 10.7)
    set(TR_MACOS_USE_SOURCE_IMAGE_ASSETS ON)
endif()

find_program(CODESIGN_EXECUTABLE codesign REQUIRED)
if(TR_MACOS_USE_SOURCE_IMAGE_ASSETS)
    find_program(SIPS_EXECUTABLE sips REQUIRED)
else()
    find_program(ACTOOL_EXECUTABLE actool REQUIRED)
endif()

set(TR_OBJC_WEAK_PROPERTY weak)
set(TR_OBJC_WEAK_REF __weak)
set(TR_MACOS_OBJC_WEAK_COMPILE_OPTIONS "$<$<COMPILE_LANGUAGE:C,CXX>:-fobjc-weak>")
if(CMAKE_OSX_DEPLOYMENT_TARGET VERSION_LESS 10.7)
    set(TR_OBJC_WEAK_PROPERTY assign)
    set(TR_OBJC_WEAK_REF __unsafe_unretained)
    set(TR_MACOS_OBJC_WEAK_COMPILE_OPTIONS)
endif()

add_compile_definitions(
    TR_OBJC_WEAK=${TR_OBJC_WEAK_PROPERTY}
    TR_OBJC_WEAK_REF=${TR_OBJC_WEAK_REF})

set(MAC_BUNDLE_NAME Transmission)

add_compile_options(
    $<$<COMPILE_LANGUAGE:C>:-fmodules>

    # https://github.com/llvm/llvm-project/issues/57432
    "$<$<COMPILE_LANG_AND_ID:CXX,AppleClang,Clang>:-fno-modules;-Xclang;-fno-cxx-modules>"

    # equivalent of XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC YES for this directory
    $<$<COMPILE_LANGUAGE:C,CXX>:-fobjc-arc>

    # equivalent of XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_WEAK YES for this directory
    ${TR_MACOS_OBJC_WEAK_COMPILE_OPTIONS}

    # GNU extensions are good practice in Objective-C
    $<$<COMPILE_LANGUAGE:C,CXX>:-Wno-gnu>

    # Our #warnings are good practice in IDE development, not in command-line compilation
    $<$<AND:$<NOT:$<BOOL:${XCODE}>>,$<COMPILE_LANGUAGE:C,CXX>>:-Wno-\#warnings>)

add_link_options(
    # equivalent of XCODE_ATTRIBUTE_DEAD_CODE_STRIPPING YES for this directory
    $<$<LINK_LANGUAGE:C,CXX>:-dead_strip>)

if(CMAKE_OSX_DEPLOYMENT_TARGET VERSION_GREATER_EQUAL 12.0)
    add_subdirectory(QuickLookExtension)
endif()
add_subdirectory(QuickLookPlugin)
add_subdirectory(VDKQueue)

add_executable(${TR_NAME}-mac MACOSX_BUNDLE)

set(TR_ENABLE_SPARKLE ON)
if(CMAKE_OSX_DEPLOYMENT_TARGET VERSION_LESS 10.9)
    set(TR_ENABLE_SPARKLE OFF)
endif()

set(TR_SPARKLE_INFO_PLIST_KEYS "")
if(TR_ENABLE_SPARKLE)
    set(TR_SPARKLE_INFO_PLIST_KEYS [=[
	<key>SUAllowsAutomaticUpdates</key>
	<false/>
	<key>SUFeedURL</key>
	<string>https://update.transmissionbt.com/appcast.xml</string>
	<key>SUPublicDSAKeyFile</key>
	<string>sparkle_dsa_pub.pem</string>
	<key>SUScheduledCheckInterval</key>
	<string>86400</string>]=])
endif()

target_sources(${TR_NAME}-mac
    PRIVATE
        AboutWindowController.h
        AboutWindowController.mm
        AddMagnetWindowController.h
        AddMagnetWindowController.mm
        AddWindowController.h
        AddWindowController.mm
        Badger.h
        Badger.mm
        BadgeView.h
        BadgeView.mm
        BlocklistDownloader.h
        BlocklistDownloader.mm
        BlocklistDownloaderViewController.h
        BlocklistDownloaderViewController.mm
        BlocklistScheduler.h
        BlocklistScheduler.mm
        BonjourController.h
        BonjourController.mm
        ButtonToolbarItem.h
        ButtonToolbarItem.mm
        CocoaCompatibility.h
        CocoaCompatibility.mm
        ColorTextField.h
        ColorTextField.mm
        Controller.h
        Controller.mm
        CreatorWindowController.h
        CreatorWindowController.mm
        DefaultAppHelper.h
        DefaultAppHelper.mm
        DragOverlayView.h
        DragOverlayView.mm
        DragOverlayWindow.h
        DragOverlayWindow.mm
        ExpandedPathToIconTransformer.h
        ExpandedPathToIconTransformer.mm
        ExpandedPathToPathTransformer.h
        ExpandedPathToPathTransformer.mm
        FileListNode.h
        FileListNode.mm
        FileCheckCellView.h
        FileCheckCellView.mm
        FileNameCellView.h
        FileNameCellView.mm
        FileOutlineController.h
        FileOutlineController.mm
        FileOutlineView.h
        FileOutlineView.mm
        FilePriorityCellView.h
        FilePriorityCellView.mm
        FileRenameSheetController.h
        FileRenameSheetController.mm
        FilterBarController.h
        FilterBarController.mm
        FilterButton.h
        FilterButton.mm
        GlobalOptionsPopoverViewController.h
        GlobalOptionsPopoverViewController.mm
        GroupCell.h
        GroupCell.mm
        GroupPopUpButtonCell.h
        GroupPopUpButtonCell.mm
        GroupsController.h
        GroupsController.mm
        GroupsPrefsController.h
        GroupsPrefsController.mm
        GroupToolbarItem.h
        GroupToolbarItem.mm
        InfoActivityViewController.h
        InfoActivityViewController.mm
        InfoFileViewController.h
        InfoFileViewController.mm
        InfoGeneralViewController.h
        InfoGeneralViewController.mm
        InfoOptionsViewController.h
        InfoOptionsViewController.mm
        InfoPeersViewController.h
        InfoPeersViewController.mm
        InfoTextField.h
        InfoTextField.mm
        InfoTrackersViewController.h
        InfoTrackersViewController.mm
        InfoViewController.h
        InfoWindowController.h
        InfoWindowController.mm
        LegacyArchiving.h
        LegacyArchiving.mm
        LegacyColors.h
        LegacyColors.mm
        LegacyConstraints.h
        LegacyConstraints.mm
        LegacyFormatters.h
        LegacyFormatters.mm
        LegacyPowerActivity.h
        LegacyPowerActivity.mm
        LegacySegmentedControl.h
        LegacySegmentedControl.mm
        LegacySheets.h
        LegacySheets.mm
        LegacyStackView.h
        LegacyStackView.mm
        LegacySymbols.h
        LegacySymbols.mm
        LegacyTitlebarAccessory.h
        LegacyTitlebarAccessory.mm
        LegacyURLRequest.h
        LegacyURLRequest.mm
        main.mm
        MessageWindowController.h
        MessageWindowController.mm
        NSApplicationAdditions.h
        NSApplicationAdditions.mm
        NSDataAdditions.h
        NSDataAdditions.mm
        NSImageAdditions.h
        NSImageAdditions.mm
        NSMutableArrayAdditions.h
        NSMutableArrayAdditions.mm
        NSStringAdditions.h
        NSStringAdditions.mm
        PeerProgressIndicatorCell.h
        PeerProgressIndicatorCell.mm
        PeerTableView.h
        PeerTableView.mm
        PiecesView.h
        PiecesView.mm
        PortChecker.h
        PortChecker.mm
        PowerManager.h
        PowerManager.mm
        PredicateEditorRowTemplateAny.h
        PredicateEditorRowTemplateAny.mm
        PrefsController.h
        PrefsController.mm
        PrefsWindow.h
        PrefsWindow.mm
        PriorityPopUpButtonCell.h
        PriorityPopUpButtonCell.mm
        ProgressBarView.h
        ProgressBarView.mm
        ProgressGradients.h
        ProgressGradients.mm
        ShareToolbarItem.h
        ShareToolbarItem.mm
        ShareTorrentFileHelper.h
        ShareTorrentFileHelper.mm
        SmallTorrentCell.h
        SmallTorrentCell.mm
        StatsWindowController.h
        StatsWindowController.mm
        StatusBarController.h
        StatusBarController.mm
        SystemNotificationController.h
        SystemNotificationController.mm
        Toolbar.h
        Toolbar.mm
        Torrent.h
        Torrent.mm
        TorrentCell.h
        TorrentCell.mm
        TorrentCellActionButton.h
        TorrentCellActionButton.mm
        TorrentCellControlButton.h
        TorrentCellControlButton.mm
        TorrentCellRevealButton.h
        TorrentCellRevealButton.mm
        TorrentGroup.h
        TorrentGroup.mm
        TorrentTableView.h
        TorrentTableView.mm
        TrackerCell.h
        TrackerCell.mm
        TrackerNode.h
        TrackerNode.mm
        TrackerTableView.h
        TrackerTableView.mm
        URLSheetWindowController.h
        URLSheetWindowController.mm
        Utils.h
        Utils.mm
        VersionComparator.h
        VersionComparator.mm
        WebSeedTableView.h
        WebSeedTableView.mm)

target_compile_definitions(${TR_NAME}-mac
    PRIVATE
        TR_ENABLE_SPARKLE=$<BOOL:${TR_ENABLE_SPARKLE}>)

if(TR_ENABLE_SPARKLE)
    target_sources(${TR_NAME}-mac
        PRIVATE
            SparkleProxy.mm)
endif()

if(TR_MACOS_LEGACY_COMPAT)
    target_compile_options(${TR_NAME}-mac PRIVATE
        -include ${CMAKE_CURRENT_SOURCE_DIR}/CocoaCompatibility.h
        -Wno-nullability-completeness)
endif()

set(XIB_FILES
    AboutWindow.xib
    BlocklistStatusWindow.xib
    FileRenameSheetController.xib
    InfoFileView.xib
    InfoPeersView.xib
    InfoTrackersView.xib
    InfoWindow.xib
    MessageWindow.xib
    StatusBar.xib
    URLSheetWindow.xib)
if(NOT TR_MACOS_LEGACY_COMPAT)
    list(APPEND XIB_FILES
        FilterBar.xib
        StatsWindow.xib)
endif()

set(RESOURCES
    Defaults.plist
    Credits.rtf
    ../COPYING
    Images/TransmissionDocument.icns)
if(TR_ENABLE_SPARKLE)
    list(APPEND RESOURCES sparkle_dsa_pub.pem)
endif()
source_group(Resources
    FILES ${RESOURCES})

set_source_files_properties(
    ${RESOURCES}
    PROPERTIES
        MACOSX_PACKAGE_LOCATION Resources)

set(IMAGESETS
    ActionHover
    CleanupTemplate
    CompleteCheck
    CreateLarge
    DownArrowGroupTemplate
    DownArrowTemplate
    DownloadBadge
    EllipsisTemplate
    Globe
    Magnet
    PauseHover
    PauseOff
    PauseOn
    PinTemplate
    PriorityControlHigh
    PriorityControlLow
    PriorityControlNormal
    PriorityHighTemplate
    PriorityLowTemplate
    PriorityNormalTemplate
    ResumeHover
    ResumeNoWaitHover
    ResumeNoWaitOff
    ResumeNoWaitOn
    ResumeOff
    ResumeOn
    RevealHover
    RevealOff
    RevealOn
    TortoiseTemplate
    UpArrowGroupTemplate
    UpArrowTemplate
    UploadBadge
    YingYangGroupTemplate
    YingYangTemplate)

set(APPICON_NAME AppIcon)

set(IMAGE_ASSETS_DIR Images/Images.xcassets)
set(APPICONSET_DIR "${IMAGE_ASSETS_DIR}/${APPICON_NAME}.appiconset")

set(IMAGE_ASSETS
    ${IMAGE_ASSETS_DIR}/Contents.json
    ${APPICONSET_DIR}/Contents.json)

foreach(IMG IN LISTS IMAGESETS)
    set(IMG_DIR "${IMAGE_ASSETS_DIR}/${IMG}.imageset")
    list(APPEND IMAGE_ASSETS
        ${IMG_DIR}/${IMG}.png
        ${IMG_DIR}/${IMG}@2x.png
        ${IMG_DIR}/Contents.json)
endforeach()

foreach(SIZE IN ITEMS 16 32 128 256 512)
    list(APPEND IMAGE_ASSETS
        ${APPICONSET_DIR}/icon_${SIZE}x${SIZE}.png
        ${APPICONSET_DIR}/icon_${SIZE}x${SIZE}@2x.png)
endforeach()

set(COMPILED_IMAGE_ASSETS
    "${CMAKE_CURRENT_BINARY_DIR}/${APPICON_NAME}.icns")

if(TR_MACOS_USE_SOURCE_IMAGE_ASSETS)
    set(TR_LEGACY_IMAGE_ASSET_COMMANDS)
    foreach(IMG IN LISTS IMAGESETS)
        list(APPEND COMPILED_IMAGE_ASSETS
            "${CMAKE_CURRENT_BINARY_DIR}/${IMG}.png"
            "${CMAKE_CURRENT_BINARY_DIR}/${IMG}@2x.png")
        list(APPEND TR_LEGACY_IMAGE_ASSET_COMMANDS
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${CMAKE_CURRENT_SOURCE_DIR}/${IMAGE_ASSETS_DIR}/${IMG}.imageset/${IMG}.png"
                "${CMAKE_CURRENT_BINARY_DIR}/${IMG}.png"
            COMMAND ${CMAKE_COMMAND} -E copy_if_different
                "${CMAKE_CURRENT_SOURCE_DIR}/${IMAGE_ASSETS_DIR}/${IMG}.imageset/${IMG}@2x.png"
                "${CMAKE_CURRENT_BINARY_DIR}/${IMG}@2x.png")
    endforeach()
    add_custom_command(
        OUTPUT ${COMPILED_IMAGE_ASSETS}
        COMMAND
            ${SIPS_EXECUTABLE}
            -s format icns
            "${CMAKE_CURRENT_SOURCE_DIR}/${APPICONSET_DIR}/icon_512x512.png"
            --out "${CMAKE_CURRENT_BINARY_DIR}/${APPICON_NAME}.icns"
        ${TR_LEGACY_IMAGE_ASSET_COMMANDS}
        DEPENDS ${IMAGE_ASSETS}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
        VERBATIM)
    source_group("Generated Files"
        FILES ${COMPILED_IMAGE_ASSETS})
else()
    list(APPEND COMPILED_IMAGE_ASSETS
        "${CMAKE_CURRENT_BINARY_DIR}/Assets.car")
    add_custom_command(
        OUTPUT
            ${COMPILED_IMAGE_ASSETS}
            ${APPICON_NAME}.Info.plist
        COMMAND
            ${ACTOOL_EXECUTABLE}
            --compile "${CMAKE_CURRENT_BINARY_DIR}"
            --platform macosx
            --minimum-deployment-target ${CMAKE_OSX_DEPLOYMENT_TARGET}
            --app-icon ${APPICON_NAME}
            --output-partial-info-plist "${CMAKE_CURRENT_BINARY_DIR}/${APPICON_NAME}.Info.plist"
            ${IMAGE_ASSETS_DIR}
        DEPENDS ${IMAGE_ASSETS}
        WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR})
    source_group("Generated Files"
        FILES
            ${COMPILED_IMAGE_ASSETS}
            ${APPICON_NAME}.Info.plist)
endif()

list(APPEND RESOURCES
    ${COMPILED_IMAGE_ASSETS})

set_source_files_properties(
    ${COMPILED_IMAGE_ASSETS}
    PROPERTIES
        MACOSX_PACKAGE_LOCATION Resources)

set(LINGUAS
    da
    de
    en
    es
    eu
    fr
    he
    hu
    it
    ja
    nl
    pl
    pt-BR
    pt-PT
    ru
    sv
    tr
    uk
    zh-CN
    zh-TW)

if(ENABLE_NLS)
    set(ENABLED_LINGUAS ${LINGUAS})
else()
    set(ENABLED_LINGUAS en)
endif()

set(BASE_XIB_FILES
    AddMagnetWindow.xib
    AddWindow.xib
    Creator.xib
    GlobalOptionsPopover.xib
    GroupRules.xib
    InfoActivityView.xib
    InfoGeneralView.xib
    InfoOptionsView.xib
    MainMenu.xib
    PrefsWindow.xib)
set(BASE_XIB_SOURCE_FILES ${BASE_XIB_FILES})
if(TR_MACOS_LEGACY_COMPAT)
    list(REMOVE_ITEM BASE_XIB_SOURCE_FILES
        InfoActivityView.xib
        InfoOptionsView.xib
        MainMenu.xib)
endif()
list(TRANSFORM BASE_XIB_FILES
    PREPEND Base.lproj/)
list(TRANSFORM BASE_XIB_SOURCE_FILES
    PREPEND Base.lproj/)

set(LANG_STRINGS_FILES
    InfoPlist.strings
    Localizable.strings)

foreach(LANG ${ENABLED_LINGUAS})
    set(${LANG}_STRINGS_FILES)
    if(NOT LANG STREQUAL "en")
        foreach(F ${BASE_XIB_FILES})
            get_filename_component(F_BASE "${F}" NAME_WE)
            list(APPEND ${LANG}_STRINGS_FILES ${LANG}.lproj/${F_BASE}.strings)
        endforeach()
    endif()
    foreach(F ${LANG_STRINGS_FILES})
        list(APPEND ${LANG}_STRINGS_FILES ${LANG}.lproj/${F})
    endforeach()
    source_group(Resources/${LANG}.lproj
        FILES ${${LANG}_STRINGS_FILES})
endforeach()

foreach(LANG ${ENABLED_LINGUAS})
    list(APPEND RESOURCES ${${LANG}_STRINGS_FILES})
    set(STRINGS_FILES_RESOURCES_DIR Resources)
    if(NOT CMAKE_GENERATOR STREQUAL Xcode)
        string(APPEND STRINGS_FILES_RESOURCES_DIR /${LANG}.lproj)
    endif()
    set_source_files_properties(
        ${${LANG}_STRINGS_FILES}
        PROPERTIES
            MACOSX_PACKAGE_LOCATION ${STRINGS_FILES_RESOURCES_DIR})
endforeach()

target_sources(${TR_NAME}-mac
    PRIVATE
        ${RESOURCES})

tr_target_xib_files(${TR_NAME}-mac
    ${XIB_FILES}
    ${BASE_XIB_SOURCE_FILES})

if(TR_MACOS_LEGACY_COMPAT)
    tr_wrap_xib(${TR_NAME}-mac
        LegacyXibs/FilterBar.xib
        "${CMAKE_CURRENT_BINARY_DIR}/FilterBar.nib"
        "")
    tr_wrap_xib(${TR_NAME}-mac
        LegacyXibs/StatsWindow.xib
        "${CMAKE_CURRENT_BINARY_DIR}/StatsWindow.nib"
        "")
    tr_wrap_xib(${TR_NAME}-mac
        LegacyXibs/Base.lproj/InfoActivityView.xib
        "${CMAKE_CURRENT_BINARY_DIR}/Base.lproj/InfoActivityView.nib"
        Base.lproj)
    tr_wrap_xib(${TR_NAME}-mac
        LegacyXibs/Base.lproj/InfoOptionsView.xib
        "${CMAKE_CURRENT_BINARY_DIR}/Base.lproj/InfoOptionsView.nib"
        Base.lproj)
    tr_wrap_xib(${TR_NAME}-mac
        LegacyXibs/Base.lproj/MainMenu.xib
        "${CMAKE_CURRENT_BINARY_DIR}/Base.lproj/MainMenu.nib"
        Base.lproj)
endif()

set(SPARKLE_LINK_LIBRARIES)
if(TR_ENABLE_SPARKLE)
    find_library(SPARKLE_FRAMEWORK Sparkle
        PATHS ${CMAKE_CURRENT_SOURCE_DIR}
        NO_DEFAULT_PATHS)
    set(SPARKLE_LINK_LIBRARIES ${SPARKLE_FRAMEWORK} "-weak_framework Sparkle")
endif()

target_link_libraries(${TR_NAME}-mac
    PRIVATE
        ${TR_NAME}
        transmission::fmt-header-only
        vdkqueue
        ${SPARKLE_LINK_LIBRARIES}
        "-framework AppKit"
        "-framework Carbon"
        "-framework Foundation"
        "-framework Quartz"
        "-framework Security")

if(CMAKE_OSX_DEPLOYMENT_TARGET VERSION_GREATER_EQUAL 11.0)
    target_link_libraries(${TR_NAME}-mac PRIVATE "-weak_framework UniformTypeIdentifiers")
endif()

if(IS_ABSOLUTE "${CMAKE_OSX_SYSROOT}")
    find_library(USERNOTIFICATIONS_FRAMEWORK UserNotifications
        PATHS "${CMAKE_OSX_SYSROOT}/System/Library/Frameworks"
        NO_DEFAULT_PATH)
else()
    find_library(USERNOTIFICATIONS_FRAMEWORK UserNotifications)
endif()
if(USERNOTIFICATIONS_FRAMEWORK)
    target_link_libraries(${TR_NAME}-mac PRIVATE "-weak_framework UserNotifications")
endif()

if(NOT CMAKE_GENERATOR STREQUAL Xcode)
    add_custom_command(
        TARGET ${TR_NAME}-mac
        POST_BUILD
        COMMAND ${CODESIGN_EXECUTABLE} -s - $<TARGET_BUNDLE_DIR:${TR_NAME}-mac>)
endif()

set_target_properties(
    ${TR_NAME}-mac
    PROPERTIES
        INSTALL_RPATH "@executable_path;@executable_path/../Frameworks"
        MACOSX_BUNDLE_GUI_IDENTIFIER "org.m0k.transmission"
        MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist.in
        OUTPUT_NAME ${MAC_BUNDLE_NAME})

install(
    TARGETS ${TR_NAME}-mac
    DESTINATION Applications)

install(
    DIRECTORY TransmissionHelp
    DESTINATION Applications/${MAC_BUNDLE_NAME}.app/Contents/Resources)
tr_install_web(Applications/${MAC_BUNDLE_NAME}.app/Contents/Resources)

install(CODE
    "list(APPEND CMAKE_MODULE_PATH \"${PROJECT_SOURCE_DIR}/cmake\")
    include(TrMacros)
    include(GetPrerequisites)
    tr_fixup_bundle_item(
        \"\$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/Applications/${MAC_BUNDLE_NAME}.app\"
        \"Contents/MacOS/${MAC_BUNDLE_NAME}\" \"${CMAKE_CURRENT_SOURCE_DIR}\")")
