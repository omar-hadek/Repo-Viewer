import 'package:dio/dio.dart';
import 'package:github_app/core/infrastructure/sembase_database.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

final sembastProvider = Provider((ref) => SembastDatabase());
final dioProvider = Provider((ref) => Dio());
