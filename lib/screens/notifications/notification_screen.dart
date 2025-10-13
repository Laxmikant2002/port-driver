import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:driver/widgets/colors.dart';
import 'package:driver/locator.dart';
import 'package:notifications_repo/notifications_repo.dart' as notifications_repo;

import 'bloc/notification_bloc.dart';

/// Modern Notification Screen with Uber/Ola-like features
class NotificationScreen extends StatelessWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationBloc(notificationsRepo: sl<notifications_repo.NotificationsRepo>())
        ..add(const NotificationsLoaded()),
      child: const NotificationView(),
    );
  }
}

class NotificationView extends StatefulWidget {
  const NotificationView({Key? key}) : super(key: key);

  @override
  State<NotificationView> createState() => _NotificationViewState();
}

class _NotificationViewState extends State<NotificationView>
    with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedFilter = 'all';
  
  final List<String> _filters = ['all', 'unread', 'ride', 'payment', 'system'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: BlocListener<NotificationBloc, NotificationState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage ?? 'An error occurred'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              _buildSliverAppBar(),
              _buildFilterChips(),
              _buildTabBar(),
            ];
          },
          body: TabBarView(
            controller: _tabController,
            children: [
              _buildNotificationsTab(),
              _buildUnreadTab(),
              _buildFilteredTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSliverAppBar() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        return SliverAppBar(
          expandedHeight: 120.0,
          floating: false,
          pinned: true,
          backgroundColor: AppColors.primary,
          flexibleSpace: FlexibleSpaceBar(
            title: Text(
              'Notifications',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.primary, AppColors.primary.withOpacity(0.8)],
                ),
              ),
            ),
          ),
          actions: [
            if (state.hasUnreadNotifications)
              IconButton(
                icon: Badge(
                  label: Text('${state.unreadCount}'),
                  child: Icon(Icons.mark_email_read),
                ),
                onPressed: () => _showClearAllDialog(),
              ),
            IconButton(
              icon: Icon(Icons.refresh),
              onPressed: () {
                context.read<NotificationBloc>().add(NotificationsRefreshed());
              },
            ),
          ],
        );
      },
    );
  }

  Widget _buildFilterChips() {
    return SliverToBoxAdapter(
      child: Container(
        height: 50,
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: _filters.length,
          itemBuilder: (context, index) {
            final filter = _filters[index];
            final isSelected = _selectedFilter == filter;
            
            return Padding(
              padding: EdgeInsets.only(right: 8),
              child: FilterChip(
                label: Text(filter.toUpperCase()),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  _applyFilter(filter);
                },
                backgroundColor: Colors.grey[200],
                selectedColor: AppColors.primary.withOpacity(0.2),
                checkmarkColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return SliverToBoxAdapter(
      child: Container(
        color: Colors.white,
        child: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: Colors.grey,
          indicatorColor: AppColors.primary,
          tabs: [
            Tab(text: 'All'),
            Tab(text: 'Unread'),
            Tab(text: 'Important'),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        if (state.isLoading) {
          return Center(child: CircularProgressIndicator());
        }
        
        if (state.allNotifications.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildNotificationList(state.allNotifications);
      },
    );
  }

  Widget _buildUnreadTab() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final unreadNotifications = state.allNotifications
            .where((notification) => !notification.isRead)
            .toList();
            
        if (unreadNotifications.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildNotificationList(unreadNotifications);
      },
    );
  }

  Widget _buildFilteredTab() {
    return BlocBuilder<NotificationBloc, NotificationState>(
      builder: (context, state) {
        final importantNotifications = state.allNotifications
            .where((notification) => 
                notification.priority == notifications_repo.NotificationPriority.high ||
                notification.priority == notifications_repo.NotificationPriority.urgent)
            .toList();
            
        if (importantNotifications.isEmpty) {
          return _buildEmptyState();
        }
        
        return _buildNotificationList(importantNotifications);
      },
    );
  }

  Widget _buildNotificationList(List<notifications_repo.Notification> notifications) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<NotificationBloc>().add(NotificationsRefreshed());
      },
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return _buildNotificationCard(notification);
        },
      ),
    );
  }

  Widget _buildNotificationCard(notifications_repo.Notification notification) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showNotificationDetail(notification),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildNotificationIcon(notification),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontWeight: notification.isRead ? FontWeight.normal : FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: AppColors.primary,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    SizedBox(height: 4),
                    Text(
                      notification.body,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 14,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 8),
                    Row(
                      children: [
                        _buildPriorityBadge(notification.priority),
                        SizedBox(width: 8),
                        _buildTypeBadge(notification.type),
                        Spacer(),
                        Text(
                          _formatTime(notification.createdAt),
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'mark_read') {
                    context.read<NotificationBloc>().add(
                      NotificationMarkedAsRead(notification.id),
                    );
                  } else if (value == 'delete') {
                    _showDeleteConfirmation(notification);
                  }
                },
                itemBuilder: (context) => [
                  PopupMenuItem(
                    value: 'mark_read',
                    child: Text(notification.isRead ? 'Mark as Unread' : 'Mark as Read'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Delete'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationIcon(notifications_repo.Notification notification) {
    IconData iconData;
    Color iconColor;
    
    switch (notification.type) {
      case notifications_repo.NotificationType.ride:
        iconData = Icons.directions_car;
        iconColor = AppColors.primary;
        break;
      case notifications_repo.NotificationType.payment:
        iconData = Icons.payment;
        iconColor = Colors.green;
        break;
      case notifications_repo.NotificationType.system:
        iconData = Icons.settings;
        iconColor = Colors.orange;
        break;
      case notifications_repo.NotificationType.promotion:
        iconData = Icons.local_offer;
        iconColor = Colors.purple;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
    }
    
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 20,
      ),
    );
  }

  Widget _buildPriorityBadge(notifications_repo.NotificationPriority priority) {
    Color color;
    String text;
    
    switch (priority) {
      case notifications_repo.NotificationPriority.low:
        color = Colors.grey;
        text = 'LOW';
        break;
      case notifications_repo.NotificationPriority.normal:
        color = Colors.blue;
        text = 'NORMAL';
        break;
      case notifications_repo.NotificationPriority.high:
        color = Colors.orange;
        text = 'HIGH';
        break;
      case notifications_repo.NotificationPriority.urgent:
        color = Colors.red;
        text = 'URGENT';
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildTypeBadge(notifications_repo.NotificationType type) {
    String text;
    
    switch (type) {
      case notifications_repo.NotificationType.ride:
        text = 'RIDE';
        break;
      case notifications_repo.NotificationType.payment:
        text = 'PAYMENT';
        break;
      case notifications_repo.NotificationType.system:
        text = 'SYSTEM';
        break;
      case notifications_repo.NotificationType.promotion:
        text = 'PROMO';
        break;
      default:
        text = 'NOTIFICATION';
        break;
    }
    
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: Colors.grey.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[600],
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 64,
            color: Colors.grey[400],
          ),
          SizedBox(height: 16),
          Text(
            'No notifications',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'You\'re all caught up!',
            style: TextStyle(
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  void _applyFilter(String filter) {
    // Filter logic would be implemented here
    // For now, just trigger a refresh
    context.read<NotificationBloc>().add(NotificationsRefreshed());
  }

  void _showClearAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Mark All as Read'),
        content: Text('Are you sure you want to mark all notifications as read?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationBloc>().add(AllNotificationsMarkedAsRead());
              Navigator.pop(context);
            },
            child: Text('Mark All Read'),
          ),
        ],
      ),
    );
  }

  void _showNotificationDetail(notifications_repo.Notification notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _buildNotificationIcon(notification),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              notification.title,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              _formatTime(notification.createdAt),
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16),
                  Text(
                    notification.body,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      _buildPriorityBadge(notification.priority),
                      SizedBox(width: 8),
                      _buildTypeBadge(notification.type),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(notifications_repo.Notification notification) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete Notification'),
        content: Text('Are you sure you want to delete this notification?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NotificationBloc>().add(NotificationDeleted(notification.id));
              Navigator.pop(context);
            },
            child: Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}
