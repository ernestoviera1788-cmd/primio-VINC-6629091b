enum PhotoStatus { pending, approved, rejected, other }

/// One of the user's own photos (listmyphotos / uploadprofilephoto).
class MyPhoto {
  final String id;
  final int position;
  final bool isPrimary;
  final String? url;
  final String? altText;
  final String status;

  const MyPhoto({
    required this.id,
    required this.position,
    required this.isPrimary,
    required this.url,
    required this.altText,
    required this.status,
  });

  PhotoStatus get state => switch (status.toLowerCase()) {
        'pending' => PhotoStatus.pending,
        'approved' => PhotoStatus.approved,
        'rejected' => PhotoStatus.rejected,
        _ => PhotoStatus.other,
      };
}
