import 'package:flutter/material.dart';

class SidebarItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.label,
    this.onTap,
  });

  @override
  State<SidebarItem> createState() => SidebarItemState();
}

class SidebarItemState extends State<SidebarItem> {
  bool hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => hover = true),
      onExit: (_) => setState(() => hover = false),
      child: InkWell(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: hover ? Colors.white10 : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Icon(widget.icon, color: Colors.white),
              const SizedBox(width: 12),
              Text(widget.label, style: const TextStyle(color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
