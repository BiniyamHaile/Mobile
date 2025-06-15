
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:mobile/bloc/notifications/retrieve-notifications/retrieve_notifications_bloc.dart';
import 'package:mobile/models/notification/notification-model.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:mobile/ui/utils/ui_helpers.dart';
import 'package:mobile/ui/widgets/notification_tile.dart';
import 'package:mobile/ui/widgets/widgets.dart';
import 'package:mobile/ui/theme/theme_helper.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage>
    with AutomaticKeepAliveClientMixin {

  @override
  void initState() {
    super.initState();
    context.read<RetrieveNotificationsBloc>().add(
          RetrieveNotifications(),
        );
  }

  void readAll() {
    context.read<RetrieveNotificationsBloc>().add(
          ReadAllNotifications(),
        );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final theme1 = AppTheme.getTheme(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: theme1.colorScheme.onPrimary,
        automaticallyImplyLeading: false,
        flexibleSpace: ResponsivePadding(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Notifications',
                    style: textTheme.bodyMedium?.copyWith(
                      color: theme1.colorScheme.primary,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: readAll,
                    icon: const Icon(Icons.check),
                    label: Text(
                      'Read all',
                      style: textTheme.bodyMedium?.copyWith(
                        color:  theme1.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          Divider(
            color: theme1.colorScheme.primary.withOpacity(0.3),
            thickness: 1,
            height: 1,
          ),
          Expanded(
            child: ResponsivePadding(
              child: BlocConsumer<RetrieveNotificationsBloc, RetrieveNotificationsState>(
                listener: (context, state) {
                  if (state is RetrieveNotificationsError) {
                    UiHelpers.showErrorSnackBar(context, state.error);
                  }
                },
                builder: (context, state) {
                  if (state is RetrieveNotificationsLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (state is RetrieveNotificationsLoaded) {
                    final List<NotificationModel> notifications = state.notifications;
                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              LucideIcons.bellOff,
                              size: 80,
                              color: theme.primaryColor.withOpacity(0.6),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'No Notifications Yet',
                              style: TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: theme.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Stay tuned for updates and alerts!',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.primaryColor.withOpacity(0.8),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }
                  
                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (_, index) {
                        return NotificationTile(notification: notifications[index]);
                      },
                    );
                  }
                  
                  if (state is RetrieveNotificationsError) {
                    return Center(
                      child: Text(
                        state.error,
                        style: textTheme.bodyLarge,
                      ),
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
