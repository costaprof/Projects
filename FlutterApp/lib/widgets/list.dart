import 'package:flutter/material.dart';
import 'package:was_essen/widgets/list_item_checkbox.dart';
import '../../../models/list_zutat.dart';

class ItemList extends StatefulWidget {
  final List<ListZutat> items;
  final Function(ListZutat, bool?) onItemChanged;
  final Function(ListZutat) onItemDeleted;
  final Function(ListZutat, String) onItemNameChanged;
  final GlobalKey<AnimatedListState> listKey;
  final bool Function(ListZutat) toggleValueProvider;

  const ItemList({
    required this.items,
    required this.onItemChanged,
    required this.onItemDeleted,
    required this.onItemNameChanged,
    required this.listKey,
    required this.toggleValueProvider,
    super.key,
  });

  @override
  State<ItemList> createState() => _ItemListState();
}

class _ItemListState extends State<ItemList> {
  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: widget.listKey,
      initialItemCount: widget.items.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index, animation) {
        final item = widget.items[index];
        return SizeTransition(
          sizeFactor: animation,
          child: _buildItem(item, animation),
        );
      },
    );
  }

  Widget _buildItem(ListZutat item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: ItemTileWithCheckbox(
        item: item,
        checkboxValue:
            widget.toggleValueProvider(item), // Determines the checkbox state
        onCheckboxChanged: (bool? value) {
          widget.onItemChanged(item, value);
        },
        onDelete: (item) {
          widget.listKey.currentState?.removeItem(
            widget.items.indexOf(item),
            (context, animation) => _buildItem(item, animation),
          );
          widget.onItemDeleted(item);
        },
        onNameChanged: widget.onItemNameChanged,
      ),
    );
  }
}
