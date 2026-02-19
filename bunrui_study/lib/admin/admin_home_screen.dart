import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/supabase_provider.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kenteiListAsync = ref.watch(kenteiListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('管理画面'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () => context.go('/'),
          ),
        ],
      ),
      body: kenteiListAsync.when(
        data: (kenteiList) {
          return ListView.builder(
            itemCount: kenteiList.length,
            itemBuilder: (context, index) {
              final kentei = kenteiList[index];
              return Card(
                margin: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: ListTile(
                  title: Text(kentei.name),
                  subtitle: kentei.description != null
                      ? Text(kentei.description!)
                      : null,
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.download),
                        tooltip: 'JSONエクスポート',
                        onPressed: () =>
                            context.go('/admin/kentei/${kentei.id}/question/export'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.upload_file),
                        tooltip: 'JSONインポート',
                        onPressed: () =>
                            context.go('/admin/kentei/${kentei.id}/question/import'),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add),
                        tooltip: '問題を作成',
                        onPressed: () =>
                            context.go('/admin/kentei/${kentei.id}/question/create'),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/admin/kentei/create'),
        child: const Icon(Icons.add),
      ),
    );
  }
}
