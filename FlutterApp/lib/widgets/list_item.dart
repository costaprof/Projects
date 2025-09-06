import 'package:flutter/material.dart';
import 'package:styled_widget/styled_widget.dart';
import '../../../models/list_zutat.dart';

class ItemTile extends StatelessWidget {
  final ListZutat item;
  final Function(ListZutat) onDelete;
  final Function(ListZutat, String) onNameChanged;

  const ItemTile({
    required this.item,
    required this.onDelete,
    required this.onNameChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: TextEditingController(text: item.name),
            onSubmitted: (newValue) {
              onNameChanged(item, newValue);
            },
            decoration: const InputDecoration(
              border: InputBorder.none,
            ),
          ),
        ),
        Column(
          children: [
            if (item.anzahl != 0)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(item.anzahl.toString()).padding(horizontal: 2.0),
                  Text(item.einheit).padding(horizontal: 2.0),
                  IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => onDelete(item),
                  ),
                ],
              )
            else
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => onDelete(item),
              ),
          ],
        ),
      ],
    );
  }
}
