import 'package:freezed_annotation/freezed_annotation.dart';
part 'fresh.freezed.dart';

@freezed
class Fresh<T> with _$Fresh<T> {
  const Fresh._();
  const factory Fresh({
    required T entity,
    required bool isFresh,
    bool? isNextPageAvailable,
  }) = _Fresh<T>;

  factory Fresh.no(
    T entity, {
    bool? isNextPagevailable,
  }) =>
      Fresh(
          entity: entity,
          isFresh: false,
          isNextPageAvailable: isNextPagevailable);
  factory Fresh.yes(
    T entity, {
    bool? isNextPagevailable,
  }) =>
      Fresh(
          entity: entity,
          isFresh: true,
          isNextPageAvailable: isNextPagevailable);
}
