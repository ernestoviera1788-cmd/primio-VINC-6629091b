import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../models/match_item.dart';
import '../providers/matches_provider.dart';
import '../widgets/common/confirm_dialog.dart';

/// Opens a chat and refreshes the match list (last message) when it closes.
void openChat(BuildContext context, String conversationId) {
  final matches = context.read<MatchesProvider>();
  context.push('/messages/chat/$conversationId').then((_) => matches.load());
}

Future<bool> confirmAndUnmatch(BuildContext context, MatchItem match) async {
  final provider = context.read<MatchesProvider>();
  final messenger = ScaffoldMessenger.of(context);
  final ok = await showConfirmDialog(
    context,
    title: '¿Deshacer vínculo con ${match.user.name}?',
    message: 'Se cerrará su conversación. Esta acción no se puede deshacer.',
    confirmLabel: 'Deshacer vínculo',
    destructive: true,
  );
  if (!ok) return false;
  final error = await provider.unmatch(match);
  messenger.showSnackBar(SnackBar(content: Text(error ?? 'Vínculo deshecho.')));
  return error == null;
}
