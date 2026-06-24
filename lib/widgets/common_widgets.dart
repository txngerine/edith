import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ─── EdithScaffold ──────────────────────────────────────────────────────────

class EdithScaffold extends StatelessWidget {
  final String? title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? bottomNavigationBar;
  final bool showAppBar;

  const EdithScaffold({
    super.key,
    this.title,
    required this.body,
    this.actions,
    this.leading,
    this.bottomNavigationBar,
    this.showAppBar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EdithColors.bg,
      appBar: showAppBar
          ? AppBar(
              title: title != null ? Text(title!.toUpperCase()) : null,
              leading: leading,
              actions: actions,
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(1),
                child: Divider(height: 1, color: EdithColors.border),
              ),
            )
          : null,
      body: body,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}

// ─── EdithCard ───────────────────────────────────────────────────────────────

class EdithCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final VoidCallback? onTap;
  final Color? color;
  final bool bordered;

  const EdithCard({
    super.key,
    required this.child,
    this.padding,
    this.onTap,
    this.color,
    this.bordered = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: padding ?? const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color ?? EdithColors.card,
          borderRadius: BorderRadius.circular(4),
          border: bordered
              ? Border.all(color: EdithColors.border, width: 1)
              : null,
        ),
        child: child,
      ),
    );
  }
}

// ─── StatTile ────────────────────────────────────────────────────────────────

class StatTile extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;

  const StatTile({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: EdithColors.accent, size: 18),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            color: EdithColors.textPrimary,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            fontFamily: 'SpaceMono',
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: EdithColors.textSecondary,
            fontSize: 10,
            letterSpacing: 1,
            fontFamily: 'SpaceMono',
          ),
        ),
      ],
    );
  }
}

// ─── ToggleRow ────────────────────────────────────────────────────────────────

class ToggleRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final bool value;
  final ValueChanged<bool> onChanged;

  const ToggleRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: EdithColors.border)),
      ),
      child: Row(
        children: [
          Icon(icon, color: EdithColors.textSecondary, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        color: EdithColors.textPrimary,
                        fontSize: 13,
                        fontFamily: 'SpaceMono')),
                if (subtitle != null)
                  Text(subtitle!,
                      style: const TextStyle(
                          color: EdithColors.textSecondary,
                          fontSize: 11,
                          fontFamily: 'SpaceMono')),
              ],
            ),
          ),
          Switch(value: value, onChanged: onChanged),
        ],
      ),
    );
  }
}

// ─── NavRow ───────────────────────────────────────────────────────────────────

class NavRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? trailing;
  final VoidCallback? onTap;
  final Color? iconColor;

  const NavRow({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: EdithColors.border)),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor ?? EdithColors.textSecondary, size: 18),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          color: EdithColors.textPrimary,
                          fontSize: 13,
                          fontFamily: 'SpaceMono')),
                  if (subtitle != null)
                    Text(subtitle!,
                        style: const TextStyle(
                            color: EdithColors.textSecondary,
                            fontSize: 11,
                            fontFamily: 'SpaceMono')),
                ],
              ),
            ),
            Text(
              trailing ?? '>',
              style: const TextStyle(
                  color: EdithColors.textSecondary,
                  fontSize: 12,
                  fontFamily: 'SpaceMono'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── EdithButton ─────────────────────────────────────────────────────────────

class EdithButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isDanger;
  final bool isOutlined;
  final bool isLoading;
  final IconData? icon;

  const EdithButton({
    super.key,
    required this.label,
    this.onTap,
    this.isDanger = false,
    this.isOutlined = false,
    this.isLoading = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDanger ? EdithColors.danger : EdithColors.accent;
    final fg = EdithColors.bg;

    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        height: 52,
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : bg,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: bg),
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: isOutlined ? bg : fg,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: isOutlined ? bg : fg, size: 16),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      label.toUpperCase(),
                      style: TextStyle(
                        color: isOutlined ? bg : fg,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ─── BottomNav ────────────────────────────────────────────────────────────────

class EdithBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const EdithBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final items = [
      {'icon': Icons.chat_bubble_outline, 'label': 'Messages'},
      {'icon': Icons.qr_code_scanner, 'label': 'Scan'},
      {'icon': Icons.lock_outline, 'label': 'Vault'},
      {'icon': Icons.settings_outlined, 'label': 'Settings'},
    ];

    return Container(
      height: 64,
      decoration: const BoxDecoration(
        color: EdithColors.surface,
        border: Border(top: BorderSide(color: EdithColors.border)),
      ),
      child: Row(
        children: List.generate(items.length, (i) {
          final selected = i == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(i),
              child: Container(
                color: Colors.transparent,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i]['icon'] as IconData,
                      color: selected ? EdithColors.accent : EdithColors.textDim,
                      size: 22,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      (items[i]['label'] as String).toUpperCase(),
                      style: TextStyle(
                        color: selected ? EdithColors.accent : EdithColors.textDim,
                        fontSize: 9,
                        letterSpacing: 1,
                        fontFamily: 'SpaceMono',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── ExpiryBadge ─────────────────────────────────────────────────────────────

class ExpiryTimer extends StatelessWidget {
  final String timeLeft;
  final bool protected;

  const ExpiryTimer({
    super.key,
    required this.timeLeft,
    this.protected = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: EdithColors.surface,
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: EdithColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Expires in',
            style: const TextStyle(
                color: EdithColors.textSecondary,
                fontSize: 10,
                fontFamily: 'SpaceMono'),
          ),
          const SizedBox(width: 8),
          Text(
            timeLeft,
            style: const TextStyle(
                color: EdithColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.bold,
                fontFamily: 'SpaceMono'),
          ),
          if (protected) ...[
            const SizedBox(width: 8),
            const Icon(Icons.lock, color: EdithColors.accent, size: 14),
          ],
        ],
      ),
    );
  }
}

// ─── SectionHeader ───────────────────────────────────────────────────────────

class SectionHeader extends StatelessWidget {
  final String title;

  const SectionHeader(this.title, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: EdithColors.textDim,
          fontSize: 10,
          letterSpacing: 2,
          fontFamily: 'SpaceMono',
        ),
      ),
    );
  }
}

// ─── GreenProgressBar ────────────────────────────────────────────────────────

class EdithProgressBar extends StatelessWidget {
  final double value; // 0.0 to 1.0
  final Color? color;
  final double height;

  const EdithProgressBar({
    super.key,
    required this.value,
    this.color,
    this.height = 4,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: EdithColors.border,
        borderRadius: BorderRadius.circular(2),
      ),
      child: FractionallySizedBox(
        widthFactor: value.clamp(0.0, 1.0),
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: color ?? EdithColors.accent,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ),
    );
  }
}
