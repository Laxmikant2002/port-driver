import '../models/support_contact.dart';

class SupportData {
  static const List<SupportContact> supportContacts = [
    SupportContact(
      id: '1',
      title: 'Call Support',
      description: '24/7 helpline available\n+91-1800-555-0123',
      type: SupportContactType.call,
      value: '+91-1800-555-0123',
      icon: '📞',
      color: '#3B82F6', // Light blue
      isAvailable: true,
      availability: '24/7',
    ),
    SupportContact(
      id: '2',
      title: 'Email Support',
      description: 'Send us your queries\nsupport@cargodriver.com',
      type: SupportContactType.email,
      value: 'support@cargodriver.com',
      icon: '✉️',
      color: '#8B5CF6', // Light purple
      isAvailable: true,
      availability: '24/7',
    ),
  ];

  static const SupportContact emergencyContact = SupportContact(
    id: 'emergency',
    title: 'Emergency Support',
    description: 'Immediate assistance - Bypass queue',
    type: SupportContactType.emergency,
    value: '+91-1800-555-911',
    icon: '🚨',
    color: '#EF4444', // Red
    isAvailable: true,
    availability: '24/7',
  );
}
