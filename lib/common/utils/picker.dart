import 'package:flutter/material.dart';
import 'package:flutter_picker/Picker.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'package:wechat_camera_picker/wechat_camera_picker.dart';

import '../index.dart';

// 视频配置，秒
const videoDurationMin = 6;
const videoDurationMax = 900;

class ActionPicker {
  static Future<List<AssetEntity>?> assets({
    required BuildContext context,
    List<AssetEntity>? selected,
    RequestType type = RequestType.image,
    int maxAssets = 9,
    SpecialPickerType? specialPickerType,
    Widget Function(BuildContext)? specialItemBuilder,
    SpecialItemPosition specialItemPosition = SpecialItemPosition.none,
  }) async {
    var privilege = await Privilege.photos();
    if (!privilege.result) {
      await ActionDialog.normal(
        context: context,
        content: Text(privilege.message),
        confirm: const Text('Setting'),
        cancel: const Text('Not allowed'),
        onConfirm: () => Privilege.openSettings(),
      );
      return null;
    }
    var result = await AssetPicker.pickAssets(
      context,
      selectedAssets: selected,
      requestType: type,
      maxAssets: maxAssets,
      themeColor: AppColors.surfaceVariant,
      specialPickerType: specialPickerType,
      filterOptions: FilterOptionGroup(
        orders: [const OrderOption(type: OrderOptionType.createDate)],
        videoOption: const FilterOption(
          durationConstraint: DurationConstraint(
            min: Duration(seconds: videoDurationMin),
            max: Duration(seconds: videoDurationMax),
          ),
        ),
      ),
      specialItemPosition: specialItemPosition,
      specialItemBuilder: specialItemBuilder,
    );
    return result;
  }

  static Future<AssetEntity?> camera({
    required BuildContext context,
    bool enableRecording = true,
  }) async {
    var privilege = await Privilege.camera();
    if (!privilege.result) {
      await ActionDialog.normal(
        context: context,
        content: Text(privilege.message),
        confirm: const Text('Setting'),
        cancel: const Text('Not allowed'),
        onConfirm: () => Privilege.openSettings(),
      );
      return null;
    }
    var result = await CameraPicker.pickFromCamera(
      context,
      enableRecording: enableRecording,
      enableAudio: enableRecording,
      textDelegate: enableRecording
          ? EnglishCameraPickerTextDelegateWithRecording()
          : EnglishCameraPickerTextDelegate(),
      resolutionPreset: ResolutionPreset.veryHigh,
    );
    return result;
  }

  static Picker text({
    required PickerAdapter adapter,
  }) {
    return Picker(
      itemExtent: 40,
      height: 270,
      backgroundColor: Colors.transparent,
      containerColor: Colors.transparent,
      hideHeader: true,
      textStyle: TextStyle(
        fontSize: 18,
        height: 1.2,
        color: AppColors.surfaceVariant,
      ),
      adapter: adapter,
    );
  }
}
