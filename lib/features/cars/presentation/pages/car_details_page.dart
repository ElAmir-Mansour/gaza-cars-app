import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../../domain/entities/car_entity.dart';
import '../bloc/favorites_bloc.dart';
import '../../../chat/presentation/bloc/chat_bloc.dart';
import '../../../chat/presentation/bloc/chat_event.dart';
import '../../../chat/presentation/bloc/chat_state.dart';
import '../../../admin/presentation/bloc/report_cubit.dart';
import '../../../admin/presentation/bloc/report_state.dart';

class CarDetailsPage extends StatelessWidget {
  final CarEntity car;

  const CarDetailsPage({super.key, required this.car});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.userId;
    }

    return Scaffold(
      backgroundColor: Colors.white, // Ensure background is white
      appBar: AppBar(
        title: Text('${car.make} ${car.model}'),
        backgroundColor: Colors.blue, // Make AppBar distinct
        foregroundColor: Colors.white,
        actions: [
          BlocProvider(
            create: (context) => sl<FavoritesBloc>()..add(LoadFavoritesEvent(userId: userId ?? '')),
            child: BlocBuilder<FavoritesBloc, FavoritesState>(
              builder: (context, state) {
                if (userId == null) return const SizedBox.shrink();
                
                bool isFavorite = false;
                if (state is FavoritesLoaded) {
                  isFavorite = state.favorites.any((c) => c.id == car.id);
                }
                return IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : null,
                  ),
                  onPressed: () {
                    context.read<FavoritesBloc>().add(
                          ToggleFavoriteEvent(carId: car.id, userId: userId!),
                        );
                  },
                );
              },
            ),
          ),
          if (userId != null && userId != car.sellerId)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'report') {
                  _showReportDialog(context, userId!, car.id);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem<String>(
                    value: 'report',
                    child: Row(
                      children: [
                        const Icon(Icons.flag, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(l10n.reportListing ?? 'Report Listing'),
                      ],
                    ),
                  ),
                ];
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Carousel
            if (car.images.isNotEmpty)
              CarouselSlider(
                options: CarouselOptions(
                  height: 300.0,
                  viewportFraction: 1.0,
                  enlargeCenterPage: false,
                  autoPlay: car.images.length > 1,
                ),
                items: car.images.map((imageUrl) {
                  return Builder(
                    builder: (BuildContext context) {
                      return Container(
                        width: MediaQuery.of(context).size.width,
                        decoration: const BoxDecoration(color: Colors.grey),
                        child: Image.network(
                          imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(child: Icon(Icons.error, size: 50)),
                        ),
                      );
                    },
                  );
                }).toList(),
              )
            else
              Container(
                height: 300,
                width: double.infinity,
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.directions_car, size: 100)),
              ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Price and Title
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          '${car.year} ${car.make} ${car.model}',
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                      ),
                      Text(
                        '\$${car.price.toStringAsFixed(0)}',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Details Grid
                  _buildDetailRow(context, Icons.speed, l10n.mileage, '${car.mileage} km'),
                  const Divider(),
                  _buildDetailRow(context, Icons.build, l10n.condition, _getLocalizedCondition(l10n, car.condition)),
                  const Divider(),
                  _buildDetailRow(context, Icons.location_on, l10n.location, car.location),
                  const Divider(),
                  _buildDetailRow(context, Icons.calendar_today, l10n.listedDate, _formatDate(car.createdAt)),
                  
                  const SizedBox(height: 32),
                  
                  const SizedBox(height: 24),
                  
                  // Contact Seller Buttons
                  if (userId != car.sellerId) ...[
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.icon(
                            onPressed: car.sellerPhone.isNotEmpty ? () => _makePhoneCall(car.sellerPhone) : null,
                            icon: const Icon(Icons.phone),
                            label: Text(l10n.callSeller),
                            style: FilledButton.styleFrom(
                              padding: const EdgeInsets.all(16),
                              backgroundColor: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: BlocProvider(
                            create: (context) => sl<ChatBloc>(),
                            child: BlocConsumer<ChatBloc, ChatState>(
                              listener: (context, state) {
                                if (state is ChatCreated) {
                                  context.push('/chat/${state.chatId}', extra: {
                                    'title': '${car.make} ${car.model}',
                                    'otherUserId': car.sellerId,
                                  });
                                } else if (state is ChatError) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(state.message)),
                                  );
                                }
                              },
                              builder: (context, state) {
                                return FilledButton.icon(
                                  onPressed: state is ChatLoading ? null : () {
                                    context.read<ChatBloc>().add(CreateChatEvent(
                                      otherUserId: car.sellerId,
                                      carId: car.id,
                                      carName: '${car.make} ${car.model}',
                                    ));
                                  },
                                  icon: state is ChatLoading 
                                    ? const SizedBox(
                                        width: 16,
                                        height: 16,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Icon(Icons.chat_bubble),
                                  label: Text(l10n.chat),
                                  style: FilledButton.styleFrom(
                                    padding: const EdgeInsets.all(16),
                                    backgroundColor: Colors.blue,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                        l10n.thisIsYourListing,
                        style: const TextStyle(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  } 
  
  String _getLocalizedCondition(AppLocalizations l10n, String condition) {
    switch (condition) {
      case 'New':
        return l10n.newCondition;
      case 'Used':
        return l10n.usedCondition;
      case 'Damaged':
        return l10n.damagedCondition;
      default:
        return condition;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }



  Widget _buildDetailRow(BuildContext context, IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Colors.grey[600]),
          ),
          const Spacer(),
          Text(
            value,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  void _showReportDialog(BuildContext context, String reporterId, String listingId) {
    showDialog(
      context: context,
      builder: (context) => BlocProvider(
        create: (context) => sl<ReportCubit>(),
        child: Builder(
          builder: (context) {
            return AlertDialog(
              title: const Text('Report Listing'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Why are you reporting this listing?'),
                  const SizedBox(height: 16),
                  ...['Spam', 'Inappropriate Content', 'Misleading', 'Other'].map(
                    (reason) => ListTile(
                      title: Text(reason),
                      onTap: () {
                        context.read<ReportCubit>().submitReport(
                              reporterId: reporterId,
                              reportedId: listingId,
                              type: 'listing',
                              reason: reason,
                            );
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Report submitted. Thank you.')),
                        );
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ],
            );
          }
        ),
      ),
    );
  }
}
