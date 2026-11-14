// ============================================================================
// AUTH MESSAGE BANNER
// ============================================================================
// Bandeau d'erreur (rouge) ou d'information (vert) au-dessus du formulaire.
// Composant "bête" : reçoit le texte et sa nature.

import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class AuthMessageBanner extends StatelessWidget {
  final String message;
  final bool isError;

  const AuthMessageBanner({
    super.key,
    required this.message,
    required this.isError,
  });

  @override
  Widget build(BuildContext context) {
    final background = isError ? errorContainerLight : const Color(0xFFDFF3E4);
    final foreground = isError ? onErrorContainerLight : const Color(0xFF1E5631);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.mark_email_read_outlined,
            color: foreground,
            size: 20,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(message, style: TextStyle(color: foreground)),
          ),
        ],
      ),
    );
  }
}
