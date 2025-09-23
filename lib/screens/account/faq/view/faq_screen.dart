import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../widgets/colors.dart';
import '../bloc/faq_bloc.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FaqBloc()..add(const FaqLoaded()),
      child: const FaqView(),
    );
  }
}

class FaqView extends StatelessWidget {
  const FaqView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocListener<FaqBloc, FaqState>(
        listener: (context, state) {
          if (state.hasError) {
            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage ?? 'Failed to load FAQ'),
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
          child: Column(
            children: [
              const _HeaderSection(),
              const SizedBox(height: 24),
              const _SearchSection(),
              const SizedBox(height: 24),
              const _CategorySection(),
              const SizedBox(height: 24),
              const Expanded(child: _FaqListSection()),
            ],
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
          // FAQ Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Icon(
              Icons.help_outline_rounded,
              size: 32,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 16),
          // Header Text
          Text(
            'Frequently Asked Questions',
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
            'Find answers to common questions and get help',
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

class _SearchSection extends StatelessWidget {
  const _SearchSection();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        onChanged: (query) => context.read<FaqBloc>().add(FaqSearchChanged(query)),
        style: TextStyle(
          fontSize: 16,
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
        decoration: InputDecoration(
          hintText: 'Search FAQ...',
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 16,
          ),
          prefixIcon: Container(
            margin: const EdgeInsets.all(12),
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.search,
              color: AppColors.cyan,
              size: 20,
            ),
          ),
          filled: true,
          fillColor: AppColors.background,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.border,
              width: 1,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(
              color: AppColors.cyan,
              width: 2,
            ),
          ),
        ),
      ),
    );
  }
}

class _CategorySection extends StatelessWidget {
  const _CategorySection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaqBloc, FaqState>(
      builder: (context, state) {
        return Container(
          height: 50,
          margin: const EdgeInsets.symmetric(horizontal: 24),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: state.categories.length,
            itemBuilder: (context, index) {
              final category = state.categories[index];
              final isSelected = state.selectedCategory == category;
              
              return Container(
                margin: const EdgeInsets.only(right: 12),
                child: FilterChip(
                  label: Text(
                    category,
                    style: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  selected: isSelected,
                  onSelected: (selected) {
                    context.read<FaqBloc>().add(FaqCategoryChanged(category));
                  },
                  backgroundColor: AppColors.surface,
                  selectedColor: AppColors.cyan,
                  checkmarkColor: Colors.white,
                  side: BorderSide(
                    color: isSelected ? AppColors.cyan : AppColors.border,
                    width: 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _FaqListSection extends StatelessWidget {
  const _FaqListSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaqBloc, FaqState>(
      builder: (context, state) {
        if (state.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.filteredFaqItems.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          itemCount: state.filteredFaqItems.length,
          itemBuilder: (context, index) {
            final faqItem = state.filteredFaqItems[index];
            return _FaqItemCard(faqItem: faqItem);
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: AppColors.cyan.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.cyan,
            ),
          ),
          const SizedBox(height: 24),
          Text(
            'No Results Found',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching with different keywords\nor browse other categories',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItemCard extends StatelessWidget {
  final FaqItem faqItem;

  const _FaqItemCard({required this.faqItem});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FaqBloc, FaqState>(
      builder: (context, state) {
        final isExpanded = state.isItemExpanded(faqItem.id);
        
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.08),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              InkWell(
                onTap: () {
                  if (isExpanded) {
                    context.read<FaqBloc>().add(FaqItemCollapsed(faqItem.id));
                  } else {
                    context.read<FaqBloc>().add(FaqItemExpanded(faqItem.id));
                  }
                },
                borderRadius: BorderRadius.circular(16),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          faqItem.question,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                        color: AppColors.cyan,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
              if (isExpanded) ...[
                const Divider(height: 1, color: AppColors.border),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        faqItem.answer,
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            'Was this helpful?',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          _HelpfulButton(
                            faqItem: faqItem,
                            isHelpful: true,
                          ),
                          const SizedBox(width: 8),
                          _HelpfulButton(
                            faqItem: faqItem,
                            isHelpful: false,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _HelpfulButton extends StatelessWidget {
  final FaqItem faqItem;
  final bool isHelpful;

  const _HelpfulButton({
    required this.faqItem,
    required this.isHelpful,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = isHelpful ? faqItem.isHelpful : faqItem.isNotHelpful;
    
    return GestureDetector(
      onTap: () {
        if (isHelpful) {
          context.read<FaqBloc>().add(FaqItemHelpful(faqItem.id));
        } else {
          context.read<FaqBloc>().add(FaqItemNotHelpful(faqItem.id));
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected 
              ? (isHelpful ? AppColors.success : AppColors.error).withOpacity(0.1)
              : AppColors.background,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected 
                ? (isHelpful ? AppColors.success : AppColors.error)
                : AppColors.border,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isHelpful ? Icons.thumb_up : Icons.thumb_down,
              size: 16,
              color: isSelected 
                  ? (isHelpful ? AppColors.success : AppColors.error)
                  : AppColors.textTertiary,
            ),
            const SizedBox(width: 4),
            Text(
              isHelpful ? 'Yes' : 'No',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: isSelected 
                    ? (isHelpful ? AppColors.success : AppColors.error)
                    : AppColors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}