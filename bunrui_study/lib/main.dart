import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/home_screen.dart';
import 'screens/question_screen.dart';
import 'screens/column_screen.dart';
import 'admin/admin_home_screen.dart';
import 'admin/kentei_create_screen.dart';
import 'admin/question_create_screen.dart';
import 'admin/question_import_screen.dart';
import 'admin/question_export_screen.dart';
import 'providers/supabase_provider.dart';
import 'services/question_sync_service.dart';
import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: '.env');

  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_ANON_KEY']!,
  );

  // Sync questions from asset to database on app startup
  try {
    final supabaseService = SupabaseService(Supabase.instance.client);
    final syncService = QuestionSyncService(supabaseService);
    final count = await syncService.syncQuestionsToDatabase(
      kenteiId: biologyKenteiId,
      assetPath: 'assets/questions/biology_grade3.json',
    );
    if (count > 0) {
      print('Synced $count questions from asset to database');
    }
  } catch (e) {
    print('Failed to sync questions on startup: $e');
  }

  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

final _router = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/questions',
      builder: (context, state) => const QuestionScreen(),
    ),
    GoRoute(
      path: '/columns',
      builder: (context, state) => const ColumnScreen(),
    ),
    GoRoute(
      path: '/admin',
      builder: (context, state) => const AdminHomeScreen(),
    ),
    GoRoute(
      path: '/admin/kentei/create',
      builder: (context, state) => const KenteiCreateScreen(),
    ),
    GoRoute(
      path: '/admin/kentei/:id/question/create',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return QuestionCreateScreen(kenteiId: id);
      },
    ),
    GoRoute(
      path: '/admin/kentei/:id/question/import',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return QuestionImportScreen(kenteiId: id);
      },
    ),
    GoRoute(
      path: '/admin/kentei/:id/question/export',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return QuestionExportScreen(kenteiId: id);
      },
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '生物分類技能検定３級 学習アプリ',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      routerConfig: _router,
    );
  }
}
