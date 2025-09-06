import 'package:flutter/material.dart';
import 'package:was_essen/widgets/list_item.dart';
import '../../../models/list_zutat.dart';

class ItemTileWithCheckbox extends StatelessWidget {
  final ListZutat item;
  final bool checkboxValue;
  final Function(bool?) onCheckboxChanged;
  final Function(ListZutat) onDelete;
  final Function(ListZutat, String) onNameChanged;

  const ItemTileWithCheckbox({
    required this.item,
    required this.checkboxValue,
    required this.onCheckboxChanged,
    required this.onDelete,
    required this.onNameChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Checkbox(
          value: checkboxValue,
          onChanged: (bool? value) {
            onCheckboxChanged(value);
          },
        ),
        Expanded(
          child: ItemTile(
            item: item,
            onDelete: onDelete,
            onNameChanged: onNameChanged,
          ),
        ),
      ],
    );
  }
}
