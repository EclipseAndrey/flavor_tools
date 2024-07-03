import 'package:flavor_tools/flavor_tools.dart';
import 'package:xcode_parser/xcode_parser.dart';

MapPbx createXCConfigurationFirst(BuildType type, flavor, String uuidRef, String uuid, String teamId) {
  final config = createXCConfigurationFirstDebug(type, flavor, uuidRef, uuid, teamId);
  switch (type) {
    case BuildType.debug:
      return config;
    case BuildType.profile:
      final buildSettings = config.find<MapPbx>('buildSettings');
      buildSettings?.remove('SWIFT_OPTIMIZATION_LEVEL');
      return config;
    case BuildType.release:
      final buildSettings = config.find<MapPbx>('buildSettings');
      buildSettings?.remove('SWIFT_OPTIMIZATION_LEVEL');
      return config;
  }
}

MapPbx createXCConfigurationSecond(BuildType type, flavor, String uuidRef, String uuid) {
  final config = createXCConfigurationSecondDebug(type, flavor, uuidRef, uuid);
  switch (type) {
    case BuildType.debug:
      return config;
    case BuildType.profile:
      final buildSettings = config.find<MapPbx>('buildSettings');
      buildSettings?.replaceOrAdd(MapEntryPbx('DEBUG_INFORMATION_FORMAT', VarPbx('"dwarf-with-dsym"')));
      buildSettings?.replaceOrAdd(MapEntryPbx('ENABLE_NS_ASSERTIONS', VarPbx('NO')));
      buildSettings?.replaceOrAdd(MapEntryPbx('SUPPORTED_PLATFORMS', VarPbx('iphoneos')));
      buildSettings?.replaceOrAdd(MapEntryPbx('SWIFT_COMPILATION_MODE', VarPbx('wholemodule')));
      buildSettings?.replaceOrAdd(MapEntryPbx('VALIDATE_PRODUCT', VarPbx('YES')));
      buildSettings?.remove('ENABLE_TESTABILITY');
      buildSettings?.remove('GCC_DYNAMIC_NO_PIC');
      buildSettings?.remove('GCC_OPTIMIZATION_LEVEL');
      buildSettings?.remove('GCC_PREPROCESSOR_DEFINITIONS');
      buildSettings?.remove('ONLY_ACTIVE_ARCH');
      return config;
    case BuildType.release:
      final buildSettings = config.find<MapPbx>('buildSettings');
      buildSettings?.replaceOrAdd(MapEntryPbx('DEBUG_INFORMATION_FORMAT', VarPbx('"dwarf-with-dsym"')));
      buildSettings?.replaceOrAdd(MapEntryPbx('ENABLE_NS_ASSERTIONS', VarPbx('NO')));
      buildSettings?.replaceOrAdd(MapEntryPbx('MTL_ENABLE_DEBUG_INFO', VarPbx('NO')));
      buildSettings?.replaceOrAdd(MapEntryPbx('SUPPORTED_PLATFORMS', VarPbx('iphoneos')));
      buildSettings?.replaceOrAdd(MapEntryPbx('SWIFT_OPTIMIZATION_LEVEL', VarPbx('"-O"')));
      buildSettings?.replaceOrAdd(MapEntryPbx('VALIDATE_PRODUCT', VarPbx('YES')));
      buildSettings?.remove('ENABLE_TESTABILITY');
      buildSettings?.remove('GCC_DYNAMIC_NO_PIC');
      buildSettings?.remove('GCC_OPTIMIZATION_LEVEL');
      buildSettings?.remove('GCC_PREPROCESSOR_DEFINITIONS');
      buildSettings?.remove('ONLY_ACTIVE_ARCH');
      return config;
  }
}

MapPbx createXCConfigurationFirstDebug(BuildType type, flavor, String uuidRef, String uuid, String teamId) {
  return MapPbx(
    comment: '$type-$flavor',
    uuid: uuid,
    children: [
      MapEntryPbx('isa', VarPbx('XCBuildConfiguration')),
      MapEntryPbx('baseConfigurationReference', VarPbx(uuidRef), comment: '$type-$flavor.xcconfig'),
      MapPbx(
        uuid: 'buildSettings',
        children: [
          MapEntryPbx('APP_DISPLAY_NAME', VarPbx('"\${app_display_name}"')),
          MapEntryPbx('ASSETCATALOG_COMPILER_APPICON_NAME', VarPbx('"\${app_display_icon}"')),
          MapEntryPbx('CLANG_ENABLE_MODULES', VarPbx('YES')),
          MapEntryPbx('CODE_SIGN_ENTITLEMENTS', VarPbx('Runner/Runner.entitlements')),
          MapEntryPbx('CODE_SIGN_IDENTITY', VarPbx('"Apple Development"')),
          MapEntryPbx('CODE_SIGN_STYLE', VarPbx('Automatic')),
          MapEntryPbx('CURRENT_PROJECT_VERSION', VarPbx('"\$(FLUTTER_BUILD_NUMBER)"')),
          MapEntryPbx('DEVELOPMENT_TEAM', VarPbx(teamId)),
          MapEntryPbx('ENABLE_BITCODE', VarPbx('NO')),
          MapEntryPbx('INFOPLIST_FILE', VarPbx('Runner/Info.plist')),
          ListPbx('LD_RUNPATH_SEARCH_PATHS', [
            ElementOfListPbx('"\$(inherited)"'),
            ElementOfListPbx('"@executable_path/Frameworks"'),
          ]),
          MapEntryPbx('PRODUCT_BUNDLE_IDENTIFIER', VarPbx('"\${bundle_id}"')),
          MapEntryPbx('PRODUCT_NAME', VarPbx('"\$(TARGET_NAME)"')),
          MapEntryPbx('PROVISIONING_PROFILE_SPECIFIER', VarPbx('""')),
          MapEntryPbx('SUPPORTED_PLATFORMS', VarPbx('"iphoneos iphonesimulator"')),
          MapEntryPbx('SUPPORTS_MACCATALYST', VarPbx('NO')),
          MapEntryPbx('SUPPORTS_MAC_DESIGNED_FOR_IPHONE_IPAD', VarPbx('NO')),
          MapEntryPbx('SWIFT_OBJC_BRIDGING_HEADER', VarPbx('"Runner/Runner-Bridging-Header.h"')),
          MapEntryPbx('SWIFT_OPTIMIZATION_LEVEL', VarPbx('"-Onone"')),
          MapEntryPbx('SWIFT_VERSION', VarPbx('5.0')),
          MapEntryPbx('TARGETED_DEVICE_FAMILY', VarPbx('1')),
          MapEntryPbx('VERSIONING_SYSTEM', VarPbx('"apple-generic"')),
          MapEntryPbx('app_display_name', VarPbx('"\${app_display_name}"')),
        ],
      ),
      MapEntryPbx('name', VarPbx('"$type-$flavor"')),
    ],
  );
}

MapPbx createXCConfigurationSecondDebug(BuildType type, String flavor, String uuidRef, String uuid) {
  return MapPbx(uuid: uuid, comment: '$type-$flavor', children: [
    MapEntryPbx('isa', VarPbx('XCBuildConfiguration')),
    MapEntryPbx('baseConfigurationReference', VarPbx(uuidRef), comment: '$type-$flavor.xcconfig'),
    MapPbx(uuid: 'buildSettings', children: [
      MapEntryPbx('ALWAYS_SEARCH_USER_PATHS', VarPbx('NO')),
      MapEntryPbx('CLANG_ANALYZER_NONNULL', VarPbx('YES')),
      MapEntryPbx('CLANG_CXX_LANGUAGE_STANDARD', VarPbx('"gnu++0x"')),
      MapEntryPbx('CLANG_CXX_LIBRARY', VarPbx('"libc++"')),
      MapEntryPbx('CLANG_ENABLE_MODULES', VarPbx('YES')),
      MapEntryPbx('CLANG_ENABLE_OBJC_ARC', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_BLOCK_CAPTURE_AUTORELEASING', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_BOOL_CONVERSION', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_COMMA', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_CONSTANT_CONVERSION', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_DEPRECATED_OBJC_IMPLEMENTATIONS', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_DIRECT_OBJC_ISA_USAGE', VarPbx('YES_ERROR')),
      MapEntryPbx('CLANG_WARN_EMPTY_BODY', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_ENUM_CONVERSION', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_INFINITE_RECURSION', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_INT_CONVERSION', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_NON_LITERAL_NULL_CONVERSION', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_OBJC_IMPLICIT_RETAIN_SELF', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_OBJC_LITERAL_CONVERSION', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_OBJC_ROOT_CLASS', VarPbx('YES_ERROR')),
      MapEntryPbx('CLANG_WARN_RANGE_LOOP_ANALYSIS', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_STRICT_PROTOTYPES', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_SUSPICIOUS_MOVE', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN_UNREACHABLE_CODE', VarPbx('YES')),
      MapEntryPbx('CLANG_WARN__DUPLICATE_METHOD_MATCH', VarPbx('YES')),
      MapEntryPbx('"CODE_SIGN_IDENTITY[sdk=iphoneos*]"', VarPbx('"iPhone Developer"')),
      MapEntryPbx('COPY_PHASE_STRIP', VarPbx('NO')),
      MapEntryPbx('DEBUG_INFORMATION_FORMAT', VarPbx('dwarf')),
      MapEntryPbx('ENABLE_STRICT_OBJC_MSGSEND', VarPbx('YES')),
      MapEntryPbx('ENABLE_TESTABILITY', VarPbx('YES')),
      MapEntryPbx('GCC_C_LANGUAGE_STANDARD', VarPbx('gnu99')),
      MapEntryPbx('GCC_DYNAMIC_NO_PIC', VarPbx('NO')),
      MapEntryPbx('GCC_NO_COMMON_BLOCKS', VarPbx('YES')),
      MapEntryPbx('GCC_OPTIMIZATION_LEVEL', VarPbx('0')),
      ListPbx('GCC_PREPROCESSOR_DEFINITIONS', [
        ElementOfListPbx('"DEBUG=1"'),
        ElementOfListPbx('"\$(inherited)"'),
      ]),
      MapEntryPbx('GCC_WARN_64_TO_32_BIT_CONVERSION', VarPbx('YES')),
      MapEntryPbx('GCC_WARN_ABOUT_RETURN_TYPE', VarPbx('YES_ERROR')),
      MapEntryPbx('GCC_WARN_UNDECLARED_SELECTOR', VarPbx('YES')),
      MapEntryPbx('GCC_WARN_UNINITIALIZED_AUTOS', VarPbx('YES_AGGRESSIVE')),
      MapEntryPbx('GCC_WARN_UNUSED_FUNCTION', VarPbx('YES')),
      MapEntryPbx('GCC_WARN_UNUSED_VARIABLE', VarPbx('YES')),
      MapEntryPbx('IPHONEOS_DEPLOYMENT_TARGET', VarPbx('12.0')),
      MapEntryPbx('MTL_ENABLE_DEBUG_INFO', VarPbx('YES')),
      MapEntryPbx('ONLY_ACTIVE_ARCH', VarPbx('YES')),
      MapEntryPbx('SDKROOT', VarPbx('iphoneos')),
      MapEntryPbx('TARGETED_DEVICE_FAMILY', VarPbx('"1,2"')),
    ]),
    MapEntryPbx('name', VarPbx('"$type-$flavor"')),
  ]);
}
