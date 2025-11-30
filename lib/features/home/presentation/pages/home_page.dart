import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../../../features/auth/presentation/bloc/auth_event.dart';
import '../../../../features/auth/presentation/bloc/auth_state.dart';
import '../../../../features/cars/presentation/bloc/car_bloc.dart';
import '../../../../features/cars/presentation/bloc/car_event.dart';
import '../../../../features/cars/presentation/bloc/car_state.dart';
import '../../../../features/cars/domain/entities/car_entity.dart';
import '../../../../features/cars/presentation/widgets/car_card.dart';
import '../../../../features/cars/presentation/widgets/filter_bottom_sheet.dart';
import '../../../../features/cars/presentation/widgets/car_list_shimmer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<CarBloc>()..add(const GetCarsEvent())),
      ],
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthUnauthenticated) {
            context.go('/login');
          }
        },
        child: Builder(
          builder: (context) {
            return Scaffold(
              drawer: Drawer(
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DrawerHeader(
                      decoration: const BoxDecoration(
                        color: Color(0xFF1E88E5), // Premium Blue
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 30,
                            child: Icon(Icons.directions_car, size: 35, color: Color(0xFF1E88E5)),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            l10n.appTitle,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ListTile(
                      leading: const Icon(Icons.home_outlined),
                      title: Text(l10n.home),
                      onTap: () {
                        context.pop(); // Close drawer
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.list_alt),
                      title: Text(l10n.myListings),
                      onTap: () {
                        context.pop(); // Close drawer
                        context.push('/my-listings');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.favorite_border),
                      title: Text(l10n.favorites),
                      onTap: () {
                        context.pop(); // Close drawer
                        context.push('/favorites');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.chat_bubble_outline),
                      title: const Text('Messages'),
                      onTap: () {
                        context.pop(); // Close drawer
                        context.push('/chats');
                      },
                    ),
                    // Admin Dashboard - only show if user is admin
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, authState) {
                        if (authState is AuthAuthenticated && authState.user.role == 'admin') {
                          return ListTile(
                            leading: const Icon(Icons.admin_panel_settings_outlined),
                            title: Text(l10n.adminDashboard),
                            onTap: () {
                              context.pop(); // Close drawer
                              context.push('/admin');
                            },
                          );
                        }
                        return const SizedBox.shrink();
                      },
                    ),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.settings_outlined),
                      title: Text(l10n.settings),
                      onTap: () {
                        context.pop(); // Close drawer
                        context.push('/settings');
                      },
                    ),
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.red),
                      title: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
                      onTap: () {
                        context.read<AuthBloc>().add(LogoutEvent());
                      },
                    ),
                  ],
                ),
              ),
              body: NestedScrollView(
                headerSliverBuilder: (context, innerBoxIsScrolled) {
                  return [
                    SliverAppBar(
                      expandedHeight: 140.0,
                      floating: true,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      surfaceTintColor: Colors.transparent,
                      leading: Builder(
                        builder: (context) => IconButton(
                          icon: Icon(Icons.menu, color: Theme.of(context).colorScheme.onSurface),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      title: Text(
                        l10n.appTitle,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: Icon(Icons.filter_list, color: Theme.of(context).colorScheme.onSurface),
                          tooltip: l10n.filters,
                          onPressed: () {
                            final carBloc = context.read<CarBloc>();
                            showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              builder: (bottomSheetContext) => BlocProvider.value(
                                value: carBloc,
                                child: const FilterBottomSheet(),
                              ),
                            );
                          },
                        ),

                      ],
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(70),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: l10n.searchHint,
                                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                              ),
                              onChanged: (query) {
                                context.read<CarBloc>().add(FilterCarsEvent(query));
                              },
                            ),
                          ),
                        ),
                      ),
                    ),
                  ];
                },
                body: BlocBuilder<CarBloc, CarState>(
                  builder: (context, state) {
                    if (state is CarLoading) {
                      return const CarListShimmer();
                    } else if (state is CarLoaded) {
                      final displayCars = state.filteredCars;

                      if (state.cars.isEmpty) {
                        return EmptyStateWidget(
                          title: l10n.noCarsFound,
                          message: 'Try adjusting your filters or search for something else.',
                          icon: Icons.no_crash,
                          onAction: () {
                            context.read<CarBloc>().add(const GetCarsEvent());
                          },
                          actionLabel: 'Refresh',
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<CarBloc>().add(const GetCarsEvent());
                        },
                        child: _CarList(cars: displayCars, hasReachedMax: state.hasReachedMax),
                      );
                    } else if (state is CarError) {
                      return Center(child: Text(state.message));
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
              floatingActionButton: FloatingActionButton.extended(
                onPressed: () {
                  context.push('/add-car');
                },
                icon: const Icon(Icons.add),
                label: Text(l10n.addCar),
                backgroundColor: const Color(0xFF1E88E5),
              ),
            );
          }
        ),
      ),
    );
  }

}



class _CarList extends StatefulWidget {
  final List<CarEntity> cars;
  final bool hasReachedMax;

  const _CarList({
    required this.cars,
    required this.hasReachedMax,
  });

  @override
  State<_CarList> createState() => _CarListState();
}

class _CarListState extends State<_CarList> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isBottom && !widget.hasReachedMax) {
      context.read<CarBloc>().add(LoadMoreCarsEvent());
    }
  }

  bool get _isBottom {
    if (!_scrollController.hasClients) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  @override
  Widget build(BuildContext context) {
    return MasonryGridView.count(
        controller: _scrollController,
        crossAxisCount: 2,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        padding: const EdgeInsets.all(12),
        itemCount: widget.hasReachedMax
            ? widget.cars.length
            : widget.cars.length + 1,
        itemBuilder: (context, index) {
          if (index >= widget.cars.length) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
          return CarCard(car: widget.cars[index]);
        },
      );
  }
}
