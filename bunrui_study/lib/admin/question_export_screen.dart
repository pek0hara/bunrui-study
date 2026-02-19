import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/supabase_provider.dart';

class QuestionExportScreen extends ConsumerStatefulWidget {
  final String kenteiId;

  const QuestionExportScreen({
    super.key,
    required this.kenteiId,
  });

  @override
  ConsumerState<QuestionExportScreen> createState() =>
      _QuestionExportScreenState();
}

class _QuestionExportScreenState extends ConsumerState<QuestionExportScreen> {
  bool _isLoading = false;
  String? _exportedJson;
  String? _errorMessage;

  Future<void> _exportQuestions() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _exportedJson = null;
    });

    try {
      final syncService = ref.read(questionSyncServiceProvider);
      final json = await syncService.exportQuestionsToJson(
        kenteiId: widget.kenteiId,
      );

      setState(() {
        _exportedJson = json;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('エクスポートが完了しました')),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _copyToClipboard() {
    if (_exportedJson != null) {
      Clipboard.setData(ClipboardData(text: _exportedJson!));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('クリップボードにコピーしました')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSONエクスポート'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '使い方',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '1. 「エクスポート」ボタンをクリック\n'
                      '2. 表示されたJSONをコピー\n'
                      '3. assets/questions/biology_grade3.json に保存\n'
                      '4. Gitにコミット・プッシュ',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.download),
                label: const Text('エクスポート'),
                onPressed: _isLoading ? null : _exportQuestions,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            if (_isLoading) ...[
              const SizedBox(height: 16),
              const Center(child: CircularProgressIndicator()),
            ],
            if (_errorMessage != null) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.red),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error, color: Colors.red),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _errorMessage!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (_exportedJson != null) ...[
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'エクスポート結果',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  ElevatedButton.icon(
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('コピー'),
                    onPressed: _copyToClipboard,
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Container(
                height: 400,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: SingleChildScrollView(
                  child: SelectableText(
                    _exportedJson!,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
