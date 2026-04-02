import 'product_modifier_option.dart';

/// Grupo de modificadores para un producto
/// Ejemplo: "Término de cocción", "Ingredientes extras", "Bebida incluida"
class ProductModifierGroup {
  final String id;
  final String name;
  final List<ProductModifierOption> options;
  final bool isRequired; // El cliente debe seleccionar algo
  final bool allowMultiple; // Permite seleccionar múltiples opciones
  final int? minSelections;
  final int? maxSelections;

  const ProductModifierGroup({
    required this.id,
    required this.name,
    required this.options,
    this.isRequired = false,
    this.allowMultiple = false,
    this.minSelections,
    this.maxSelections,
  });

  /// Verifica si el grupo es válido según las selecciones
  bool isValidSelection(List<String> selectedOptionIds) {
    final count = selectedOptionIds.length;
    
    if (isRequired && count == 0) return false;
    if (minSelections != null && count < minSelections!) return false;
    if (maxSelections != null && count > maxSelections!) return false;
    if (!allowMultiple && count > 1) return false;
    
    return true;
  }

  /// Obtiene las opciones seleccionadas
  List<ProductModifierOption> getSelectedOptions(List<String> selectedIds) {
    return options.where((opt) => selectedIds.contains(opt.id)).toList();
  }

  ProductModifierGroup copyWith({
    String? id,
    String? name,
    List<ProductModifierOption>? options,
    bool? isRequired,
    bool? allowMultiple,
    int? minSelections,
    int? maxSelections,
  }) {
    return ProductModifierGroup(
      id: id ?? this.id,
      name: name ?? this.name,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      allowMultiple: allowMultiple ?? this.allowMultiple,
      minSelections: minSelections ?? this.minSelections,
      maxSelections: maxSelections ?? this.maxSelections,
    );
  }
}
