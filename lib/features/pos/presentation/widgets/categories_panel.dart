import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../menu/presentation/providers/menu_provider.dart';

/// Provider de categoría seleccionada en el POS
final selectedCategoryProvider = StateProvider<String?>((ref) => null);

/// Panel de categorías para el POS
class CategoriesPanel extends ConsumerWidget {
  const CategoriesPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);
    final selectedCategoryId = ref.watch(selectedCategoryProvider);

    return Container(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              border: Border(
                bottom: BorderSide(
                  color: Theme.of(context).dividerColor,
                ),
              ),
            ),
            child: Text(
              'Categorías',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),

          // Botón "Todas"
          _CategoryButton(
            name: 'Todas',
            icon: Icons.grid_view_rounded,
            isSelected: selectedCategoryId == null,
            onTap: () {
              ref.read(selectedCategoryProvider.notifier).state = null;
            },
          ),

          const Divider(height: 1),

          // Lista de categorías
          Expanded(
            child: categoriesAsync.when(
              data: (categories) {
                return ListView.builder(
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    final isSelected = selectedCategoryId == category.id;

                    return _CategoryButton(
                      name: category.name,
                      icon: _getCategoryIcon(category.name),
                      isSelected: isSelected,
                      onTap: () {
                        ref.read(selectedCategoryProvider.notifier).state =
                            category.id;
                      },
                    );
                  },
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    'Error al cargar categorías',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String categoryName) {
    final name = categoryName.toLowerCase();
    if (name.contains('entrada')) return Icons.restaurant_menu;
    if (name.contains('plato') || name.contains('principal')) {
      return Icons.dinner_dining;
    }
    if (name.contains('postre')) return Icons.cake;
    if (name.contains('bebida')) return Icons.local_bar;
    return Icons.fastfood;
  }
}

/// Botón de categoría individual
class _CategoryButton extends StatelessWidget {
  final String name;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryButton({
    required this.name,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary
              : null,
          border: Border(
            bottom: BorderSide(
              color: Theme.of(context).dividerColor.withOpacity(0.3),
            ),
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 24,
              color: isSelected
                  ? Colors.white
                  : Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                name,
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.normal,
                      color: isSelected
                          ? Colors.white
                          : Theme.of(context).colorScheme.onSurface,
                    ),
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.white,
              ),
          ],
        ),
      ),
    );
  }
}
