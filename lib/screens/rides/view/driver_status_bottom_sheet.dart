import 'package:flutter/material.dart';

class DriverStatusBottomSheet extends StatefulWidget {
  final bool isOnline;
  final List<DriverActionItem> requiredActions;
  final VoidCallback? onMenuTap;
  final VoidCallback? onSettingsTap;

  const DriverStatusBottomSheet({
    super.key,
    required this.isOnline,
    required this.requiredActions,
    this.onMenuTap,
    this.onSettingsTap,
  });

  @override
  State<DriverStatusBottomSheet> createState() => _DriverStatusBottomSheetState();
}

class _DriverStatusBottomSheetState extends State<DriverStatusBottomSheet> {
  bool _expanded = true;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: MediaQuery.of(context).viewInsets,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 16,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 12),
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            // Status Row
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
              child: Row(
                children: [
                  Icon(
                    widget.isOnline ? Icons.check_circle_outline_rounded : Icons.info_outline,
                    color: widget.isOnline ? Colors.green : Colors.black,
                    size: 26,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.isOnline ? "You're online" : "You're offline",
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.menu, color: Colors.black),
                    onPressed: widget.onMenuTap,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            // Required Actions Section
            if (widget.requiredActions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: GestureDetector(
                  onTap: () => setState(() => _expanded = !_expanded),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
                    child: Row(
                      children: [
                        const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 22),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Required actions (${widget.requiredActions.length})',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        Text(
                          _expanded ? 'Go online when resolved' : '',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(_expanded ? Icons.expand_less : Icons.expand_more, color: Colors.black),
                      ],
                    ),
                  ),
                ),
              ),
            // Action Items
            if (_expanded && widget.requiredActions.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Column(
                  children: widget.requiredActions.map((item) {
                    return Container(
                      margin: const EdgeInsets.only(top: 10),
                      decoration: BoxDecoration(
                        color: Colors.grey[100],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        leading: Icon(item.icon, color: Colors.black, size: 22),
                        title: Text(
                          item.title,
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontSize: 15,
                          ),
                        ),
                        subtitle: item.subtitle != null
                            ? Text(
                                item.subtitle!,
                                style: const TextStyle(fontSize: 13, color: Colors.black54),
                              )
                            : null,
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.black, size: 18),
                        onTap: item.onTap,
                      ),
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class DriverActionItem {
  final String title;
  final String? subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  const DriverActionItem({
    required this.title,
    this.subtitle,
    required this.icon,
    this.onTap,
  });
}