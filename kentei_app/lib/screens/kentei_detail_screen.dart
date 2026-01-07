import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/supabase_provider.dart';

class KenteiDetailScreen extends ConsumerWidget {
  final String kenteiId;

  const KenteiDetailScreen({
    super.key,
    required this.kenteiId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final kenteiListAsync = ref.watch(kenteiListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('検定詳細'),
      ),
      body: kenteiListAsync.when(
        data: (kenteiList) {
          final kentei = kenteiList.firstWhere((k) => k.id == kenteiId);
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  kentei.name,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                if (kentei.description != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    kentei.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.quiz),
                    label: const Text('問題に挑戦'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () =>
                        context.go('/kentei/$kenteiId/questions'),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.article),
                    label: const Text('コラムを読む'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.all(16),
                    ),
                    onPressed: () => context.go('/kentei/$kenteiId/columns'),
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, stack) => Center(
          child: Text('エラーが発生しました: $error'),
        ),
      ),
    );
  }
}
