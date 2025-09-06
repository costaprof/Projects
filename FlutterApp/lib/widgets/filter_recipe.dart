import 'package:flutter/material.dart';
import 'package:was_essen/global_decoration.dart';
import '../models/rezept.dart';
// import '../../models/types.dart';

//FIlterOption Class To Use for My Filters List and Have Value to check if an Option is Selected or not
class FilterOption {
  String? filterName;
  bool? isSelected;

  FilterOption({required this.filterName, required this.isSelected});
}

class FilterWidget extends StatefulWidget {
  final List<Rezept> reciepeList;

  const FilterWidget({super.key, required this.reciepeList});

  @override
  State<FilterWidget> createState() => _FilterWidgetState();
}

class _FilterWidgetState extends State<FilterWidget> {
  List<FilterOption> filtersList = [
    FilterOption(filterName: "vegan", isSelected: false),
    FilterOption(filterName: "vegetarisch", isSelected: false),
    FilterOption(filterName: "ohne nüsse", isSelected: false),
    FilterOption(filterName: "ohne gluten", isSelected: false)
  ];

  List<FilterOption> selectedOptionsList = [];

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey,
      width: MediaQuery.of(context).size.width,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              const SizedBox(
                height: 10,
              ),
              const Text(
                "Filter Liste",
                style: TextStyle(color: Colors.black, fontSize: 25),
              ),
              const SizedBox(
                height: 10,
              ),
              filterOptionsWidget()
            ],
          ),
          applyFilterButton(),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }

  //Button to Apply Filter Changes
  Widget applyFilterButton() {
    return GestureDetector(
      onTap: () => _applyFilterChanges(),
      child: Container(
        height: 50,
        width: MediaQuery.of(context).size.width / 1.1,
        decoration: getBoxDeco(8, Colors.white),
        child: const Center(
          child: Text(
            "Filter anwenden",
            style: TextStyle(color: Colors.black, fontSize: 20),
          ),
        ),
      ),
    );
  }

  //Display my Filters
  Widget filterOptionsWidget() {
    return SizedBox(
      width: MediaQuery.of(context).size.width / 1.1,
      child: Column(
        children: [
          for (int i = 0; i < filtersList.length; i++)
            Column(
              children: [
                filterOption(filtersList.elementAt(i)),
                const SizedBox(
                  height: 10,
                )
              ],
            )
        ],
      ),
    );
  }

  //Single Filter Option
  Widget filterOption(FilterOption filterOption) {
    return CheckboxListTile(
      controlAffinity: ListTileControlAffinity.leading,
      value: filterOption.isSelected,
      onChanged: (bool? value) {
        _handleFilterSelection(filterOption, value!);
      },
      title: Text(filterOption.filterName!),
    );
  }

  //

  void _handleFilterSelection(FilterOption item, bool value) {
    setState(() {
      item.isSelected = value;
    });

    if (item.isSelected!) {
      selectedOptionsList.add(item);
    } else {
      selectedOptionsList.remove(item);
    }
  }

  //apply filter changes
  void _applyFilterChanges() {
    //loop over selected filter and apply filter method
  }
}
