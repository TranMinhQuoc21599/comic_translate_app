import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'translation_state.freezed.dart';

@freezed
class TranslationState with _$TranslationState {
  const factory TranslationState.initial() = _Initial;
  const factory TranslationState.loading() = _Loading;
  const factory TranslationState.success({
    required String originalText,
    required String translatedText,
    required XFile image,
  }) = _Success;
  const factory TranslationState.error(String message) = _Error;
}
