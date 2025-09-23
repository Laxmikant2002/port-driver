import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_repo/shared_repo.dart';
import '../../../../widgets/colors.dart';
import '../bloc/ratings_bloc.dart';

class RatingsScreen extends StatelessWidget {
  const RatingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RatingsBloc(sharedRepo: context.read<SharedRepo>())..add(const RatingsLoaded()),
      child: const RatingsView(),
    );
  }
}

class RatingsView extends StatelessWidget {
  const RatingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<RatingsBloc, RatingsState>(
        listener: (context, state) {
          if (state.isSuccess) {
            // Handle success
          } else if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to load ratings'),
                  backgroundColor: AppColors.error,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              children: [
                const _HeaderSection(),
                const SizedBox(height: 24),
                const _RatingSummaryCard(),
                const SizedBox(height: 24),
                const _RatingDistributionCard(),
                const SizedBox(height: 24),
                const _ReviewsListCard(),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSection extends StatelessWidget {
  const _HeaderSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primary.withOpacity(0.1),
            AppColors.cyan.withOpacity(0.05),
          ],
        ),
      ),
      child: Column(
        children: [
          // Rating Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.star_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Header Text
          Text(
            'Ratings & Reviews',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'View your performance ratings and customer feedback',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _RatingSummaryCard extends StatelessWidget {
  const _RatingSummaryCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RatingsBloc, RatingsState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.border.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Rating Icon and Average
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.star_rounded,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Overall Rating',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Based on ${state.totalRatings} reviews',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Rating Display
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: AppColors.warning,
                      size: 48,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      state.averageRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '/ 5.0',
                      style: TextStyle(
                        fontSize: 24,
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Rating Trend
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: _getTrendColor(state.ratingTrend).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getTrendIcon(state.ratingTrend),
                        color: _getTrendColor(state.ratingTrend),
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Trend: ${state.ratingTrend.toUpperCase()}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: _getTrendColor(state.ratingTrend),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getTrendColor(String trend) {
    switch (trend) {
      case 'improving':
        return AppColors.success;
      case 'declining':
        return AppColors.error;
      default:
        return AppColors.textSecondary;
    }
  }

  IconData _getTrendIcon(String trend) {
    switch (trend) {
      case 'improving':
        return Icons.trending_up;
      case 'declining':
        return Icons.trending_down;
      default:
        return Icons.trending_flat;
    }
  }
}

class _RatingDistributionCard extends StatelessWidget {
  const _RatingDistributionCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RatingsBloc, RatingsState>(
      builder: (context, state) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.border.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.bar_chart_rounded,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Rating Distribution',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            'Breakdown by star rating',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Distribution Bars
                ...List.generate(5, (index) {
                  final rating = 5 - index;
                  final count = state.ratingDistribution[rating] ?? 0;
                  final percentage = state.totalRatings > 0 ? (count / state.totalRatings) * 100 : 0.0;
                  
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: Row(
                      children: [
                        // Star count
                        SizedBox(
                          width: 20,
                          child: Text(
                            '$rating',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Star icon
                        Icon(
                          Icons.star_rounded,
                          color: AppColors.warning,
                          size: 16,
                        ),
                        const SizedBox(width: 12),
                        // Progress bar
                        Expanded(
                          child: Container(
                            height: 8,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(4),
                              color: AppColors.border.withOpacity(0.3),
                            ),
                            child: FractionallySizedBox(
                              alignment: Alignment.centerLeft,
                              widthFactor: percentage / 100,
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(4),
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.warning,
                                      AppColors.warning.withOpacity(0.8),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Count
                        SizedBox(
                          width: 30,
                          child: Text(
                            '$count',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w500,
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ReviewsListCard extends StatelessWidget {
  const _ReviewsListCard();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<RatingsBloc, RatingsState>(
      builder: (context, state) {
        final reviews = state.currentRatings;
        
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 32,
                offset: const Offset(0, 12),
                spreadRadius: 0,
              ),
              BoxShadow(
                color: AppColors.border.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
                spreadRadius: 0,
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cyan.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.reviews_rounded,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Recent Reviews',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                          Text(
                            '${reviews.length} total reviews',
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Reviews List
                if (reviews.isEmpty)
                  _buildEmptyState()
                else
                  ...reviews.take(5).map((review) => _buildReviewItem(review)),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.star_border_rounded,
              size: 40,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'No Reviews Yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your ratings will appear here once passengers start rating your rides.',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildReviewItem(Rating review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.border.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with stars and date
          Row(
            children: [
              // Stars
              ...List.generate(5, (index) {
                return Icon(
                  index < review.rating ? Icons.star_rounded : Icons.star_border_rounded,
                  color: AppColors.warning,
                  size: 16,
                );
              }),
              const Spacer(),
              // Date
              Text(
                _formatDate(review.createdAt),
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Comment
          if (review.comment != null && review.comment!.isNotEmpty)
            Text(
              review.comment!,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.textPrimary,
                height: 1.4,
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);
    
    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }
}