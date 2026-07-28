import 'package:flutter/material.dart';

import '../../../core/theme/theme_colors.dart';
import 'nav_item.dart';

class PremiumBottomNav extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onTap;

  const PremiumBottomNav({
    super.key,
    required this.selectedIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.colorSurface,
      child: SafeArea(
        child: Container(
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: context.colorBorder,
              ),
            ),
          ),
          child: Row(
            children: [
              NavItem(
                icon: Icons.home_rounded,
                label: "Home",
                selected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              NavItem(
                icon: Icons.qr_code_scanner_rounded,
                label: "Pay",
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              NavItem(
                icon: Icons.send_rounded,
                label: "Send",
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              NavItem(
                icon: Icons.receipt_long_rounded,
                label: "Activity",
                selected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              NavItem(
                icon: Icons.person_outline_rounded,
                label: "Profile",
                selected: selectedIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

