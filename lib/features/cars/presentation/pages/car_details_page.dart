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
import '../../../../shared/widgets/cached_image.dart';


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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 300.0,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                elevation: 0,
                leading: Container(
                  margin: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onSurface),
                    onPressed: () => context.pop(),
                  ),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                      shape: BoxShape.circle,
                    ),
                    child: BlocProvider(
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
                              color: isFavorite ? Colors.red : Theme.of(context).colorScheme.onSurface,
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
                  ),
                  if (userId != null && userId != car.sellerId)
                    Container(
                      margin: const EdgeInsets.only(right: 16, top: 8, bottom: 8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor.withValues(alpha: 0.9),
                        shape: BoxShape.circle,
                      ),
                      child: PopupMenuButton<String>(
                        icon: Icon(Icons.more_vert, color: Theme.of(context).colorScheme.onSurface),
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
                                  Text(l10n.reportListing),
                                ],
                              ),
                            ),
                          ];
                        },
                      ),
                    ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: car.images.isNotEmpty
                      ? CarouselSlider(
                          options: CarouselOptions(
                            height: 340.0, // Slightly taller to cover status bar
                            viewportFraction: 1.0,
                            enlargeCenterPage: false,
                            autoPlay: car.images.length > 1,
                          ),
                          items: car.images.asMap().entries.map((entry) {
                            final index = entry.key;
                            final imageUrl = entry.value;
                            final imageWidget = CachedImage(
                              imageUrl: imageUrl,
                              fit: BoxFit.cover,
                              width: double.infinity,
                            );

                            if (index == 0) {
                              return Hero(
                                tag: 'car_image_${car.id}',
                                child: imageWidget,
                              );
                            }
                            return imageWidget;
                          }).toList(),
                        )
                      : Container(
                          color: Colors.grey[200],
                          child: const Center(child: Icon(Icons.directions_car, size: 80, color: Colors.grey)),
                        ),
                ),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                  ),
                  transform: Matrix4.translationValues(0, -20, 0), // Overlap effect
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Title and Price
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${car.make} ${car.model}',
                                    style: const TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                      height: 1.2,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${car.year} • ${car.condition}',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '\$${car.price.toStringAsFixed(0)}',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF1E88E5),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Specs Grid
                        const Text(
                          'Car Specs',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        GridView.count(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisCount: 3,
                          childAspectRatio: 1.5,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          children: [
                            _buildSpecItem(context, Icons.speed, '${car.mileage} km', 'Mileage'),
                            _buildSpecItem(context, Icons.settings, _getLocalizedTransmission(l10n, car.transmission), l10n.transmission),
                            _buildSpecItem(context, Icons.local_gas_station, _getLocalizedFuelType(l10n, car.fuelType), l10n.fuelType),
                            _buildSpecItem(context, Icons.location_on, car.location, 'Location'),
                            _buildSpecItem(context, Icons.calendar_today, _formatDate(car.createdAt), l10n.listedDate),
                            _buildSpecItem(context, Icons.build, _getLocalizedCondition(l10n, car.condition), l10n.condition),
                          ],
                        ),
                        
                        const SizedBox(height: 24),
                        const Text(
                          'Description',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This is a great car in excellent condition. Contact the seller for more details and to arrange a viewing.', // Placeholder description
                          style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color?.withValues(alpha: 0.8), height: 1.5),
                        ),
                        
                        const SizedBox(height: 100), // Space for bottom bar
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          
          // Sticky Bottom Bar
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    if (userId != car.sellerId) ...[
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: car.sellerPhone.isNotEmpty ? () => _makePhoneCall(car.sellerPhone) : null,
                          icon: const Icon(Icons.phone),
                          label: const Text('Call'),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            side: const BorderSide(color: Colors.green),
                            foregroundColor: Colors.green,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
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
                                label: const Text('Chat with Seller'),
                                style: FilledButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 16),
                                  backgroundColor: const Color(0xFF1E88E5),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ] else
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'This is your listing',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  } 
  
  Widget _buildSpecItem(BuildContext context, IconData icon, String value, String label) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 20, color: const Color(0xFF1E88E5)),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            label,
            style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color?.withValues(alpha: 0.7), fontSize: 10),
          ),
        ],
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

  String _getLocalizedTransmission(AppLocalizations l10n, String transmission) {
    switch (transmission) {
      case 'Automatic':
        return l10n.automatic;
      case 'Manual':
        return l10n.manual;
      default:
        return transmission;
    }
  }

  String _getLocalizedFuelType(AppLocalizations l10n, String fuelType) {
    switch (fuelType) {
      case 'Petrol':
        return l10n.petrol;
      case 'Diesel':
        return l10n.diesel;
      case 'Hybrid':
        return l10n.hybrid;
      case 'Electric':
        return l10n.electric;
      default:
        return fuelType;
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
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
