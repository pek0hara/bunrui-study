import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../services/supabase_service.dart';
import '../services/question_sync_service.dart';
import '../models/kentei.dart';
import '../models/question.dart';
import '../models/column_model.dart';

// 生物分類技能検定３級の固定ID
const String biologyKenteiId = 'biology-classification-3';

// Worker APIのベースURL（.envから取得、未設定の場合は本番URL）
String get _apiBaseUrl {
  final url = dotenv.env['WORKER_API_URL'] ?? '';
  return url.isEmpty ? 'https://bunrui-study.workers.dev' : url;
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService(_apiBaseUrl);
});

// 後方互換性のために残す（内部では ApiService を使う）
final supabaseServiceProvider = apiServiceProvider;

final questionSyncServiceProvider = Provider<QuestionSyncService>((ref) {
  final apiService = ref.watch(apiServiceProvider);
  return QuestionSyncService(apiService);
});

final kenteiListProvider = FutureProvider<List<Kentei>>((ref) async {
  final service = ref.watch(apiServiceProvider);
  return service.getAllKentei();
});

final questionsProvider =
    FutureProvider.family<List<Question>, String>((ref, kenteiId) async {
  final service = ref.watch(apiServiceProvider);
  return service.getQuestionsByKenteiId(kenteiId);
});

final columnsProvider =
    FutureProvider.family<List<ColumnModel>, String>((ref, kenteiId) async {
  final service = ref.watch(apiServiceProvider);
  return service.getColumnsByKenteiId(kenteiId);
});

// 生物分類技能検定３級専用のプロバイダー
final biologyQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final service = ref.watch(apiServiceProvider);
  return service.getQuestionsByKenteiId(biologyKenteiId);
});

final biologyColumnsProvider = FutureProvider<List<ColumnModel>>((ref) async {
  final service = ref.watch(apiServiceProvider);
  return service.getColumnsByKenteiId(biologyKenteiId);
});
