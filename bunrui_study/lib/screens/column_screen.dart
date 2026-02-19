import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/supabase_provider.dart';

class ColumnScreen extends ConsumerWidget {
  const ColumnScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final columnsAsync = ref.watch(biologyColumnsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('コラム'),
      ),
      body: columnsAsync.when(
        data: (columns) {
          if (columns.isEmpty) {
            return const Center(
              child: Text('コラムがありません'),
            );
          }
          return ListView.builder(
            itemCount: columns.length,
            itemBuilder: (context, index) {
              final column = columns[index];
              return Card(
                margin: const EdgeInsets.all(16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        column.title,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        column.content,
                        style: Theme.of(context).textTheme.bodyLarge,
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
    );
  }
}
