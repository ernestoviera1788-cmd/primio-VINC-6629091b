import 'package:flutter/material.dart';

import '../../theme/theme.dart';

class ChatComposer extends StatefulWidget {
  final bool sending;
  final int maxLength;

  /// Returns an error message, or null when the message was sent.
  final Future<String?> Function(String text) onSend;

  const ChatComposer({super.key, required this.sending, required this.maxLength, required this.onSend});

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text;
    if (text.trim().isEmpty || widget.sending) return;
    final messenger = ScaffoldMessenger.of(context);
    final error = await widget.onSend(text);
    if (!mounted) return;
    if (error == null) {
      _controller.clear();
    } else {
      messenger.showSnackBar(SnackBar(content: Text('No se envió el mensaje. $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      color: colors.surface,
      padding: const EdgeInsets.fromLTRB(AppTheme.spacingMd, AppTheme.spacingSm, AppTheme.spacingSm, AppTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              maxLength: widget.maxLength,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: const InputDecoration(hintText: 'Escribe un mensaje…', counterText: ''),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          IconButton.filled(
            tooltip: 'Enviar',
            onPressed: widget.sending ? null : _send,
            icon: widget.sending
                ? const SizedBox(
                    width: AppTheme.iconSm,
                    height: AppTheme.iconSm,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.send_rounded),
          ),
        ],
      ),
    );
  }
}
