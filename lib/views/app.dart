import 'package:flutter/material.dart';
import 'package:unicons/unicons.dart';

class ListTileState {
  List<bool> isSelected;

  ListTileState({required this.isSelected});

  void isSelect(int index) {
    isSelected[index] = !isSelected[index];
  }
}

class AppTile extends StatefulWidget {
  final ListTileState listTileState;
  final List apps;
  final int item;
  final List<String> paths;

  const AppTile({
    super.key,
    required this.listTileState,
    required this.apps,
    required this.item,
    required this.paths,
  });

  @override
  AppTileState createState() => AppTileState();
}

class AppTileState extends State<AppTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      selected: widget.listTileState.isSelected[widget.item],
      onTap: () {
        setState(() {
          widget.listTileState.isSelect(widget.item);
          if (widget.listTileState.isSelected[widget.item]) {
            widget.paths.add(widget.apps[widget.item].apkFilePath);
          } else {
            widget.paths.remove(widget.apps[widget.item].apkFilePath);
          }
        });
      },
      leading: Image.memory(
        widget.apps[widget.item].icon,
        width: 36,
      ),
      title: Text(
        widget.apps[widget.item].appName,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: widget.listTileState.isSelected[widget.item]
          ? const Icon(UniconsLine.check_circle)
          : null,
    );
  }
}
