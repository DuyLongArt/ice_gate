// import 'package:drift/drift.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
part 'ExternalWidgetProtocol.freezed.dart';
// part 'ExternalWidgetProtocol.g.dart';

@freezed
abstract class ExternalWidgetProtocol with _$ExternalWidgetProtocol {
  const factory ExternalWidgetProtocol({
    required String name,
    required String protocol,
    required String host,
    required String url,
    String? alias,
    String? imageUrl,
    String? dateAdded,
  }) = _ExternalWidgetProtocol;
}
