import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'image_picker_state.freezed.dart';

@freezed
class ImagePickerState with _$ImagePickerState {
  const factory ImagePickerState.initial() = _Initial;
  const factory ImagePickerState.loading() = _Loading;
  const factory ImagePickerState.success(XFile image) = _Success;
  const factory ImagePickerState.error(String message) = _Error;
}
