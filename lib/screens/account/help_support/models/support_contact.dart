class SupportContact {
  const SupportContact({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.value,
    required this.icon,
    required this.color,
    this.isAvailable = true,
    this.availability,
  });

  final String id;
  final String title;
  final String description;
  final SupportContactType type;
  final String value;
  final String icon;
  final String color;
  final bool isAvailable;
  final String? availability;
}

enum SupportContactType {
  emergency('emergency', 'Emergency'),
  call('call', 'Call'),
  email('email', 'Email'),
  whatsapp('whatsapp', 'WhatsApp'),
  ticket('ticket', 'Support Ticket');

  const SupportContactType(this.value, this.displayName);

  final String value;
  final String displayName;
}
