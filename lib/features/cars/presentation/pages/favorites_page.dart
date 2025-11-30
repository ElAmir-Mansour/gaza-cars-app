import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../l10n/generated/app_localizations.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_state.dart';
import '../bloc/favorites_bloc.dart';
import '../widgets/car_card.dart';
import '../widgets/listing_shimmer.dart';
import '../../../../shared/widgets/empty_state_widget.dart';

class FavoritesPage extends StatelessWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final authState = context.read<AuthBloc>().state;
    String? userId;
    if (authState is AuthAuthenticated) {
      userId = authState.userId;
    }

    if (userId == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.favorites)),
        body: Center(child: Text(l10n.loginRequired)),
      );
    }

    return BlocProvider(
      create: (context) => sl<FavoritesBloc>()..add(LoadFavoritesEvent(userId: userId!)),
      child: Scaffold(
        appBar: AppBar(title: Text(l10n.favorites)),
        body: BlocBuilder<FavoritesBloc, FavoritesState>(
          builder: (context, state) {
            if (state is FavoritesLoading) {
              return const ListingShimmer();
            } else if (state is FavoritesError) {
              return EmptyStateWidget(
                icon: Icons.error_outline,
                title: l10n.error,
                message: state.message,
              );
            } else if (state is FavoritesLoaded) {
              if (state.favorites.isEmpty) {
                return EmptyStateWidget(
                  icon: Icons.favorite_border,
                  title: l10n.noFavorites,
                  message: 'Save cars you like to find them easily later.',
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: state.favorites.length,
                itemBuilder: (context, index) {
                  final car = state.favorites[index];
                  return CarCard(car: car);
                },
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
