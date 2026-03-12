
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/auction_entity.dart';
import '../bloc/auction_list_bloc.dart';

class CategoryFilterBar extends StatelessWidget {
  const CategoryFilterBar({super.key});

  static const _categories = [
    (AuctionCategory.vacation, '🏖️', 'Vakanties'),
    (AuctionCategory.beauty, '💅', 'Beauty'),
    (AuctionCategory.sauna, '🧖', 'Sauna'),
    (AuctionCategory.food, '🍽️', 'Eten'),
    (AuctionCategory.experiences, '🎭', 'Uitjes'),
    (AuctionCategory.products, '📦', 'Producten'),
    (AuctionCategory.sports, '⚽', 'Sport'),
    (AuctionCategory.wellness, '🧘', 'Wellness'),
    (AuctionCategory.dayTrips, '🚂', 'Dagtrips'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 80,
      color: Colors.white,
      child: BlocBuilder<AuctionListBloc, AuctionListState>(
        builder: (context, state) {
          final selectedCategory = state is AuctionListLoaded
              ? state.selectedCategory
              : null;
          return ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            children: [
              // All button
              _CategoryChip(
                emoji: '🏷️',
                label: 'Alles',
                isSelected: selectedCategory == null,
                onTap: () => context.read<AuctionListBloc>()
                    .add(const FilterByCategory(category: null)),
              ),
              ..._categories.map((c) => _CategoryChip(
                emoji: c.$2,
                label: c.$3,
                isSelected: selectedCategory == c.$1,
                onTap: () => context.read<AuctionListBloc>()
                    .add(FilterByCategory(category: c.$1)),
              )),
            ],
          );
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Theme.of(context).primaryColor
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isSelected ? Colors.white : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}