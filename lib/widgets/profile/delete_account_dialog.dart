import 'package:flutter/material.dart';

import '../../theme/theme.dart';

/// Pops `true` only after the user types ELIMINAR.
class DeleteAccountDialog extends StatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  State<DeleteAccountDialog> createState() => _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends State<DeleteAccountDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final confirmed = _controller.text.trim().toUpperCase() == 'ELIMINAR';
    return AlertDialog(
      title: const Text('Eliminar tu cuenta'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Se eliminarán tu perfil, tus fotos, tus vínculos y tus conversaciones. No se puede deshacer.'),
          const SizedBox(height: AppTheme.spacingMd),
          TextField(
            controller: _controller,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(labelText: 'Escribe ELIMINAR para confirmar'),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
        FilledButton(
          style: FilledButton.styleFrom(backgroundColor: colors.error, foregroundColor: colors.onError),
          onPressed: confirmed ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Eliminar cuenta'),
        ),
      ],
    );
  }
}
