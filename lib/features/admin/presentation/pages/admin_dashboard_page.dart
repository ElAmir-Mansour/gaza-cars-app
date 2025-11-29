import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../bloc/admin_stats_bloc.dart';
import '../bloc/admin_stats_event.dart';
import '../bloc/admin_stats_state.dart';
import '../bloc/car_moderation_bloc.dart';
import '../bloc/car_moderation_event.dart';
import '../bloc/car_moderation_state.dart';
import '../bloc/user_management_bloc.dart';
import '../bloc/user_management_event.dart';
import '../bloc/user_management_state.dart';

class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => sl<AdminStatsBloc>()..add(const LoadAdminStats()),
        ),
        BlocProvider(
          create: (context) => sl<CarModerationBloc>()..add(LoadPendingCars()),
        ),
        BlocProvider(
          create: (context) => sl<UserManagementBloc>()..add(LoadAllUsers()),
        ),
      ],
      child: DefaultTabController(
        length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Admin Dashboard'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.analytics), text: 'Analytics'),
                Tab(icon: Icon(Icons.pending_actions), text: 'Moderation'),
                Tab(icon: Icon(Icons.people), text: 'Users'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              _AnalyticsTab(),
              _ModerationTab(),
              _UsersTab(),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnalyticsTab extends StatelessWidget {
  const _AnalyticsTab();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AdminStatsBloc, AdminStatsState>(
      builder: (context, state) {
        if (state is AdminStatsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is AdminStatsLoaded) {
          final stats = state.stats;
          return RefreshIndicator(
            onRefresh: () async {
              context.read<AdminStatsBloc>().add(const LoadAdminStats());
            },
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(child: _StatCard('Total Users', stats.totalUsers.toString(), Icons.people, Colors.blue)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard('Total Cars', stats.totalCars.toString(), Icons.directions_car, Colors.green)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatCard('Traders', stats.totalTraders.toString(), Icons.store, Colors.orange)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard('Pending', stats.pendingCars.toString(), Icons.pending, Colors.red)),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: _StatCard('Active Cars', stats.activeCars.toString(), Icons.check_circle, Colors.teal)),
                    const SizedBox(width: 12),
                    Expanded(child: _StatCard('Chats', stats.totalChats.toString(), Icons.chat, Colors.purple)),
                  ],
                ),
              ],
            ),
          );
        } else if (state is AdminStatsError) {
          return Center(child: Text('Error: ${state.message}'));
        }
        return const Center(child: Text('No data'));
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard(this.title, this.value, this.icon, this.color);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: color, size: 24),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.bodySmall,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: color,
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModerationTab extends StatelessWidget {
  const _ModerationTab();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<CarModerationBloc, CarModerationState>(
      listener: (context, state) {
        if (state is CarModerationActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is CarModerationError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is CarModerationLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CarModerationLoaded) {
          if (state.pendingCars.isEmpty) {
            return const Center(child: Text('No pending cars'));
          }
          return RefreshIndicator(
            onRefresh: () async {
              context.read<CarModerationBloc>().add(LoadPendingCars());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.pendingCars.length,
              itemBuilder: (context, index) {
                final car = state.pendingCars[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${car.year} ${car.make} ${car.model}',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text('Price: \$${car.price.toStringAsFixed(0)}'),
                        Text('Location: ${car.location}'),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  context.read<CarModerationBloc>().add(ApproveCar(car.id));
                                },
                                icon: const Icon(Icons.check),
                                label: const Text('Approve'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.green,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  _showRejectDialog(context, car.id);
                                },
                                icon: const Icon(Icons.close),
                                label: const Text('Reject'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: Text('No data'));
      },
    );
  }

  void _showRejectDialog(BuildContext context, String carId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Reject Car'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for rejection',
            border: OutlineInputBorder(),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                context.read<CarModerationBloc>().add(RejectCar(carId, reason));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Reject'),
          ),
        ],
      ),
    );
  }
}

class _UsersTab extends StatelessWidget {
  const _UsersTab();

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserManagementBloc, UserManagementState>(
      listener: (context, state) {
        if (state is UserManagementActionSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        } else if (state is UserManagementError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is UserManagementLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is UserManagementLoaded) {
          return RefreshIndicator(
            onRefresh: () async {
              context.read<UserManagementBloc>().add(LoadAllUsers());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                final isBanned = user.isBanned;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isBanned ? Colors.red.shade50 : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isBanned ? Colors.red : null,
                      child: Text(user.name[0].toUpperCase()),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(user.name)),
                        if (isBanned) 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'BANNED',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      isBanned 
                        ? '${user.role} • ${user.email}\n🚫 ${user.banReason ?? "No reason"}'
                        : '${user.role} • ${user.email}',
                      maxLines: isBanned ? 2 : 1,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _showUserActionsDialog(context, user.uid, user.name, isBanned);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        } else if (state is UserManagementActionSuccess) {
          // Also show users list when action succeeds
          return RefreshIndicator(
            onRefresh: () async {
              context.read<UserManagementBloc>().add(LoadAllUsers());
            },
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                final isBanned = user.isBanned;
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  color: isBanned ? Colors.red.shade50 : null,
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isBanned ? Colors.red : null,
                      child: Text(user.name[0].toUpperCase()),
                    ),
                    title: Row(
                      children: [
                        Expanded(child: Text(user.name)),
                        if (isBanned) 
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Text(
                              'BANNED',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                      ],
                    ),
                    subtitle: Text(
                      isBanned 
                        ? '${user.role} • ${user.email}\n🚫 ${user.banReason ?? "No reason"}'
                        : '${user.role} • ${user.email}',
                      maxLines: isBanned ? 2 : 1,
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () {
                        _showUserActionsDialog(context, user.uid, user.name, isBanned);
                      },
                    ),
                  ),
                );
              },
            ),
          );
        }
        return const Center(child: Text('No data'));
      },
    );
  }

  void _showUserActionsDialog(BuildContext context, String userId, String userName, bool isBanned) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Manage $userName'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!isBanned)
              ListTile(
                leading: const Icon(Icons.block, color: Colors.red),
                title: const Text('Ban User'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  _showBanDialog(context, userId);
                },
              ),
            if (isBanned)
              ListTile(
                leading: const Icon(Icons.check_circle, color: Colors.green),
                title: const Text('Unban User'),
                onTap: () {
                  Navigator.pop(dialogContext);
                  context.read<UserManagementBloc>().add(UnbanUser(userId));
                },
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showBanDialog(BuildContext context, String userId) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ban User'),
        content: TextField(
          controller: reasonController,
          decoration: const InputDecoration(
            labelText: 'Reason for ban',
            border: OutlineInputBorder(),
          ),
          maxLines: 2,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final reason = reasonController.text.trim();
              if (reason.isNotEmpty) {
                context.read<UserManagementBloc>().add(BanUser(userId, reason));
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Ban'),
          ),
        ],
      ),
    );
  }
}
