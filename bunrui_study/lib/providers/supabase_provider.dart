import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/supabase_service.dart';
import '../services/question_sync_service.dart';
import '../models/kentei.dart';
import '../models/question.dart';
import '../models/column_model.dart';

// 生物分類技能検定３級の固定ID
// TODO: データベースに実際のIDが作成されたら更新してください
const String biologyKenteiId = 'biology-classification-3';

final supabaseServiceProvider = Provider<SupabaseService>((ref) {
  return SupabaseService(Supabase.instance.client);
});

final questionSyncServiceProvider = Provider<QuestionSyncService>((ref) {
  final supabaseService = ref.watch(supabaseServiceProvider);
  return QuestionSyncService(supabaseService);
});

final kenteiListProvider = FutureProvider<List<Kentei>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getAllKentei();
});

final questionsProvider =
    FutureProvider.family<List<Question>, String>((ref, kenteiId) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getQuestionsByKenteiId(kenteiId);
});

final columnsProvider =
    FutureProvider.family<List<ColumnModel>, String>((ref, kenteiId) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getColumnsByKenteiId(kenteiId);
});

// 生物分類技能検定３級専用のプロバイダー
final biologyQuestionsProvider = FutureProvider<List<Question>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getQuestionsByKenteiId(biologyKenteiId);
});

final biologyColumnsProvider = FutureProvider<List<ColumnModel>>((ref) async {
  final service = ref.watch(supabaseServiceProvider);
  return service.getColumnsByKenteiId(biologyKenteiId);
});
