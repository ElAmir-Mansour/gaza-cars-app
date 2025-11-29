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
                            title: const Text('Admin Dashboard'),
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
                      expandedHeight: 120.0,
                      floating: true,
                      pinned: true,
                      elevation: 0,
                      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                      surfaceTintColor: Colors.transparent,
                      leading: Builder(
                        builder: (context) => IconButton(
                          icon: const Icon(Icons.menu, color: Colors.black87),
                          onPressed: () => Scaffold.of(context).openDrawer(),
                        ),
                      ),
                      title: Text(
                        l10n.appTitle,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      actions: [
                        IconButton(
                          icon: const Icon(Icons.filter_list, color: Colors.black87),
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
                        IconButton(
                          icon: const Icon(Icons.bug_report, color: Colors.black87),
                          tooltip: 'Add Mock Data',
                          onPressed: () => _addMockData(context),
                        ),
                      ],
                      bottom: PreferredSize(
                        preferredSize: const Size.fromHeight(60),
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
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

                      if (displayCars.isEmpty) {
                        return EmptyStateWidget(
                          icon: Icons.directions_car_outlined,
                          title: l10n.noCarsFound,
                          subtitle: 'Try adjusting your filters or search query',
                          onRetry: () {
                            context.read<CarBloc>().add(const GetCarsEvent());
                          },
                          retryText: l10n.retry,
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<CarBloc>().add(const GetCarsEvent());
                        },
                        child: _CarList(cars: displayCars, hasReachedMax: state.hasReachedMax),
                      );
                    } else if (state is CarError) {
                      return EmptyStateWidget(
                        icon: Icons.error_outline,
                        title: l10n.error,
                        subtitle: state.message,
                        onRetry: () {
                          context.read<CarBloc>().add(const GetCarsEvent());
                        },
                        retryText: l10n.retry,
                      );
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
                label: const Text('Sell Car'),
                backgroundColor: const Color(0xFF1E88E5),
              ),
            );
          }
        ),
      ),
    );
  }

  void _addMockData(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      final userId = authState.user.uid;
      
      final List<CarEntity> mockCars = [
        CarEntity(
          id: '',
          sellerId: userId,
          sellerPhone: '+970 599 123 456',
          make: 'Toyota',
          model: 'Camry',
          year: 2020,
          price: 25000,
          mileage: 15000,
          condition: 'Used',
          location: 'Gaza City',
          images: [],
          status: 'active',
          createdAt: DateTime.now(),
        ),
        CarEntity(
          id: '',
          sellerId: userId,
          sellerPhone: '+970 599 234 567',
          make: 'Hyundai',
          model: 'Tucson',
          year: 2021,
          price: 28000,
          mileage: 10000,
          condition: 'Used',
          location: 'Khan Yunis',
          images: [],
          status: 'active',
          createdAt: DateTime.now(),
        ),
        CarEntity(
          id: '',
          sellerId: userId,
          sellerPhone: '+970 599 345 678',
          make: 'Kia',
          model: 'Sportage',
          year: 2019,
          price: 22000,
          mileage: 45000,
          condition: 'Used',
          location: 'Rafah',
          images: [],
          status: 'active',
          createdAt: DateTime.now(),
        ),
      ];

      for (final car in mockCars) {
        context.read<CarBloc>().add(AddCarEvent(car));
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adding 3 mock cars...')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be logged in to add mock data')),
      );
    }
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
