import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile/bloc/notifications/retrieve-notifications/retrieve_notifications_bloc.dart';
import 'package:mobile/models/notification/notification-model.dart';
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
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        flexibleSpace: ResponsivePadding(
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Notifications', style: textTheme.bodyMedium?.copyWith(color: const ColorScheme.light().whiteColor)),
                  TextButton.icon(
                    onPressed: readAll,
                    icon: const Icon(Icons.check),
                    label: Text('Read all', style:  textTheme.bodyMedium?.copyWith(color: const ColorScheme.light().whiteColor)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: ResponsivePadding(
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
                return const Center(child: Text('No notifications yet'));
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

            return const Center(
              child: Text('Something went wrong'),
            );
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
