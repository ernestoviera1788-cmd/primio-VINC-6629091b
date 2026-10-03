import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/my_photo.dart';
import '../providers/me_provider.dart';
import '../theme/responsive_layout.dart';
import '../theme/theme.dart';
import '../widgets/common/confirm_dialog.dart';
import '../widgets/common/state_view.dart';
import '../widgets/profile/photo_manager_tile.dart';

class PhotosScreen extends StatelessWidget {
  const PhotosScreen({super.key});

  Future<void> _add(BuildContext context) async {
    final me = context.read<MeProvider>();
    final messenger = ScaffoldMessenger.of(context);
    final XFile? file;
    try {
      file = await ImagePicker().pickImage(source: ImageSource.gallery, maxWidth: 1600, imageQuality: 85);
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text('No pudimos abrir tu galería: $e')));
      return;
    }
    if (file == null) return;
    final bytes = await file.readAsBytes();
    final error = await me.addPhoto(bytes, file.name, file.mimeType);
    messenger.showSnackBar(SnackBar(content: Text(error ?? 'Foto subida. Será visible cuando se apruebe.')));
  }

  Future<void> _run(BuildContext context, Future<String?> action) async {
    final messenger = ScaffoldMessenger.of(context);
    final error = await action;
    if (error != null) messenger.showSnackBar(SnackBar(content: Text(error)));
  }

  Future<void> _delete(BuildContext context, MyPhoto photo) async {
    final me = context.read<MeProvider>();
    final ok = await showConfirmDialog(context, title: '¿Eliminar esta foto?', message: 'Se quitará de tu perfil.', confirmLabel: 'Eliminar', destructive: true);
    if (ok && context.mounted) await _run(context, me.deletePhoto(photo.id));
  }

  @override
  Widget build(BuildContext context) {
    final me = context.watch<MeProvider>();
    final photos = me.photos;

    return Scaffold(
      appBar: AppBar(title: const Text('Tus fotos')),
      body: SafeArea(
        top: false,
        child: ResponsiveLayout.constrain(
          ListView(
            padding: ResponsiveLayout.getPadding(context),
            children: [
              InfoBanner(
                icon: Icons.verified_user_outlined,
                message: 'Hasta ${me.maxPhotos} fotos JPG o PNG de máximo 10 MB. Las nuevas quedan pendientes hasta su aprobación, '
                    'y solo una foto aprobada puede ser la principal.',
              ),
              if (me.photoBusy) ...[
                const SizedBox(height: AppTheme.spacingMd),
                const LinearProgressIndicator(),
              ],
              const SizedBox(height: AppTheme.spacingLg),
              if (photos.isEmpty && me.isLoading)
                const Padding(padding: EdgeInsets.all(AppTheme.spacingXl), child: LoadingView(message: 'Cargando fotos…'))
              else if (photos.isEmpty)
                Text('Aún no tienes fotos. Los perfiles con foto reciben más vínculos.', style: Theme.of(context).textTheme.bodyLarge),
              for (var i = 0; i < photos.length; i++) ...[
                PhotoManagerTile(
                  photo: photos[i],
                  index: i,
                  busy: me.photoBusy,
                  onMoveUp: i == 0 ? null : () => _run(context, me.move(photos[i].id, -1)),
                  onMoveDown: i == photos.length - 1 ? null : () => _run(context, me.move(photos[i].id, 1)),
                  onSetPrimary: () => _run(context, me.setPrimary(photos[i].id)),
                  onDelete: () => _delete(context, photos[i]),
                ),
                const SizedBox(height: AppTheme.spacingSm),
              ],
              const SizedBox(height: AppTheme.spacingMd),
              FilledButton.icon(
                onPressed: me.canAddPhoto && !me.photoBusy ? () => _add(context) : null,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(me.canAddPhoto ? 'Añadir foto' : 'Has llegado al máximo de fotos'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
