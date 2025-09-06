import 'package:flutter/material.dart';
import 'package:was_essen/search_reciep.dart';
import 'global_decoration.dart';

//Modified at 07/07/2024

class SearchBox extends StatefulWidget {
  final String hintText;
  final TextEditingController controller;
  final Function(String value) onChanged; //every time you type anything
  final double boxWidth;
  final Function(String value) onEditFinished; //when you press enter
  const SearchBox(
      {super.key,
      required this.hintText,
      required this.controller,
      required this.onChanged,
      required this.boxWidth,
      required this.onEditFinished});

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.boxWidth,
      child: Column(
        children: [
          if (widget.hintText != "")
            Column(
              children: [
                hintTextWidget(),
                const SizedBox(
                  height: 5,
                )
              ],
            ),
          searchContainer()
        ],
      ),
    );
  }

  Widget hintTextWidget() {
    return Container();
  }

  Widget searchContainer() {
    return Container(
      height: 50,
      width: widget.boxWidth,
      decoration: getBoxDeco(12, Colors.grey),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(
            width: 10,
          ),
          const Padding(
            padding: EdgeInsets.only(top: 8.0),
            child: Icon(
              Icons.search_outlined,
              size: 20,
              color: Colors.black,
            ),
          ),
          searchTextField(),
        ],
      ),
    );
  }

  Widget searchTextField() {
    return Container(
      color: Colors.transparent,
      height: 50,
      width: widget.boxWidth - 110,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.only(
            left: 8.0,
          ),
          child: TextField(
            controller: widget.controller,
            autofocus: false,
            style: const TextStyle(color: Colors.black),
            cursorColor: Colors.black,
            decoration: const InputDecoration(
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              border: InputBorder.none,
              hintText: "Suche Rezept",
              hintStyle: TextStyle(color: Colors.black),
              // suffix: IconButton(onPressed: () => widget.controller.clear, icon: icon)
            ),
            onEditingComplete: () {
              widget.onEditFinished(widget.controller.text);
              widget.onChanged(widget.controller.text);
              isSearchClicked.value = false;
            },
            onTap: () {
              setState(() {
                isSearchClicked.value = true;
              });
            },
            /*onChanged: (val) {
              widget.onChanged(val);
            },*/
          ),
        ),
      ),
    );
  }

}
