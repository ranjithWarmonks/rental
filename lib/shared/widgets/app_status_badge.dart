import 'package:flutter/material.dart';

enum RentalStatusType {
  active,
  dueToday,
  overdue,
  returned,
}

class AppStatusBadge extends StatelessWidget {
  final String label;
  final RentalStatusType type;

  const AppStatusBadge({
    super.key,
    required this.label,
    required this.type,
  });

  factory AppStatusBadge.fromStatus(String status) {
    final s = status.toLowerCase();
    if (s.contains('overdue')) {
      return AppStatusBadge(label: status, type: RentalStatusType.overdue);
    } else if (s.contains('due')) {
      return AppStatusBadge(label: status, type: RentalStatusType.dueToday);
    } else if (s.contains('return')) {
      return AppStatusBadge(label: status, type: RentalStatusType.returned);
    } else {
      return AppStatusBadge(label: status, type: RentalStatusType.active);
    }
  }

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color fg;

    switch (type) {
      case RentalStatusType.active:
        bg = const Color(0xFFD1FAE5);
        fg = const Color(0xFF059669);
        break;
      case RentalStatusType.dueToday:
        bg = const Color(0xFFF3F4F6);
        fg = const Color(0xFF374151);
        break;
      case RentalStatusType.overdue:
        bg = const Color(0xFFFEE2E2);
        fg = const Color(0xFFDC2626);
        break;
      case RentalStatusType.returned:
        bg = const Color(0xFFE5E7EB);
        fg = const Color(0xFF6B7280);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: fg,
          fontFamily: 'Urbanist',
        ),
      ),
    );
  }
}
