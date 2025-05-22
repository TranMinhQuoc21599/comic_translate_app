import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:image_picker/image_picker.dart';

part 'translation_event.freezed.dart';

@freezed
class TranslationEvent with _$TranslationEvent {
  const factory TranslationEvent.translate(XFile image) = _Translate;
  const factory TranslationEvent.reset() = _Reset;
}
