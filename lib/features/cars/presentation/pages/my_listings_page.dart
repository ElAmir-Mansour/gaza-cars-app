import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/car_bloc.dart';
import '../bloc/car_event.dart';
import '../bloc/car_state.dart';
import '../widgets/my_listing_card.dart';
import '../widgets/listing_shimmer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class MyListingsPage extends StatelessWidget {
  const MyListingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.user.uid;
    }

    return BlocProvider(
      create: (context) => sl<CarBloc>()..add(const GetCarsEvent()),
      child: Scaffold(
      appBar: AppBar(
        title: const Text('My Listings'),
      ),
      body: userId == null
          ? const Center(child: Text('You must be logged in to view your listings'))
          : BlocBuilder<CarBloc, CarState>(
              builder: (context, state) {
                if (state is CarLoading) {
                  return const ListingShimmer();
                } else if (state is CarLoaded) {
                  // Filter cars by sellerId
                  final myCars = state.cars.where((car) => car.sellerId == userId).toList();

                  if (myCars.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.format_list_bulleted,
                      title: 'No listings yet',
                      message: 'Start selling by adding your first car!',
                    );
                  }

                  return ListView.builder(
                    itemCount: myCars.length,
                    itemBuilder: (context, index) {
                      final car = myCars[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: MyListingCard(
                          car: car,
                          onEdit: () {
                            context.push('/edit-car', extra: car);
                          },
                          onDelete: () {
                            // Capture bloc reference before dialog
                            final carBloc = context.read<CarBloc>();
                            // Show confirmation dialog
                            showDialog(
                              context: context,
                              builder: (dialogContext) => AlertDialog(
                                title: const Text('Delete Listing'),
                                content: Text('Are you sure you want to delete ${car.make} ${car.model}?'),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(dialogContext),
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () {
                                      carBloc.add(DeleteCarEvent(car.id));
                                      Navigator.pop(dialogContext);
                                    },
                                    child: const Text('Delete', style: TextStyle(color: Colors.red)),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      );
                    },
                  );
                } else if (state is CarError) {
                  return EmptyStateWidget(
                    icon: Icons.error_outline,
                    title: 'Error',
                    message: state.message,
                  );
                }
                return const SizedBox.shrink();
              },
            ),
      ),
    );
  }
}
