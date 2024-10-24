import 'package:flutter/material.dart';

class ListViewWidget extends StatefulWidget {
  const ListViewWidget({super.key});

  @override
  State<ListViewWidget> createState() => _ListViewWidgetState();
}

class _ListViewWidgetState extends State<ListViewWidget> {
  final GlobalKey<AnimatedListState> _listKey = GlobalKey();
  final data = List.generate(100, (e) => 'Item $e');
  int _indexRemove = -1;

  void onRemoveItem(int index) {
    final removedItem = data.removeAt(index);
    builder(context, animation) {
      return _buildItem(index, removedItem, animation);
    }

    _listKey.currentState?.removeItem(index, builder);
  }

  Widget _buildItem(int index, String item, animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: _ItemWidget(
        item: item,
        onRemoveItem: () {
          onRemoveItem(index);
        },
        isShowRemove: _indexRemove == index,
        updateIndexShowRemove: () {
          setState(() {
            _indexRemove = index;
          });
        },
        clearIndexShowRemove: () {
          if (index == _indexRemove) {
            setState(() {
              _indexRemove = -1;
            });
          }
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.cyan,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedList.separated(
          key: _listKey,
          initialItemCount: data.length,
          itemBuilder: (context, index, animation) {
            final item = data[index];
            return _buildItem(index, item, animation);
          },
          separatorBuilder: (context, index, animation) {
            return const SizedBox(
              height: 5,
            );
          },
          removedSeparatorBuilder: (context, index, animation) {
            return const SizedBox(
              height: 5,
            );
          },
        ),
      ),
    );
  }
}

class _ItemWidget extends StatefulWidget {
  final String item;
  final void Function()? onRemoveItem;
  final void Function()? updateIndexShowRemove;
  final void Function()? clearIndexShowRemove;
  final bool isShowRemove;

  const _ItemWidget(
      {super.key,
      required this.item,
      required this.isShowRemove,
      this.onRemoveItem,
      this.updateIndexShowRemove,
      this.clearIndexShowRemove});

  @override
  State<_ItemWidget> createState() => _ItemWidgetState();
}

class _ItemWidgetState extends State<_ItemWidget> {
  bool _isLongPressing = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: (details) {
        if (details.delta.dx.abs() < 1) {
          return;
        }
        final v = details.primaryDelta ?? 0;
        if (v < 0) {
          widget.updateIndexShowRemove?.call();
        } else {
          widget.clearIndexShowRemove?.call();
        }
      },
      onTapDown: (details) {
        setState(() {
          _isLongPressing = true;
        });
      },
      onTapUp: (details) async {
        await Future.delayed(const Duration(milliseconds: 100));
        setState(() {
          _isLongPressing = false;
        });
      },
      child: Row(
        children: [
          Expanded(
            child: SizedBox(
              height: 100,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 100),
                margin: EdgeInsets.all(_isLongPressing ? 5 : 0),
                decoration: BoxDecoration(
                    color: Colors.white, borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(widget.item)),
              ),
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            child: SizedBox.square(
              dimension: widget.isShowRemove ? 100 : 0,
              child: InkWell(
                onTap: () {
                  widget.clearIndexShowRemove?.call();
                  widget.onRemoveItem?.call();
                },
                child: Container(
                    margin: const EdgeInsets.only(left: 5),
                    decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(10)),
                    child: const Icon(Icons.delete)),
              ),
            ),
          )
        ],
      ),
    );
  }
}
