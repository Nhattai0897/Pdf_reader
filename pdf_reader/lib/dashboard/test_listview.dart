import 'package:flutter/material.dart';

class MyAppTestList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Update AnimatedList data')),
        body: BodyWidget(),
      ),
    );
  }
}

class BodyWidget extends StatefulWidget {
  @override
  BodyWidgetState createState() {
    return new BodyWidgetState();
  }
}

class BodyWidgetState extends State<BodyWidget> {
  // the GlobalKey is needed to animate the list
  final GlobalKey<AnimatedListState> _listKey = GlobalKey(); // backing data
  List<String> _data = ['Horse', 'Cow', 'Camel', 'Sheep', 'Goat'];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        SizedBox(
          height: 400,
          child: AnimatedList(
            key: _listKey,
            initialItemCount: _data.length,
            itemBuilder: (context, index, animation) {
              return _buildItem(_data[index], animation);
            },
          ),
        ),
        RaisedButton(
          child: Text(
            'Insert single item',
            style: TextStyle(fontSize: 20),
          ),
          onPressed: () {
            _onButtonPress();
          },
        )
      ],
    );
  }

  Widget _buildItem(String item, Animation<double> animation) {
    return SizeTransition(
      sizeFactor: animation,
      child: Card(
        child: ListTile(
          title: Text(
            item,
            style: TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }

  void _onButtonPress() {
    // replace this with method choice below
    _removeSingleItems();
  }

  void _insertSingleItem() {
    String item = "Pig";
    int insertIndex = 2;
    _data.insert(insertIndex, item);
    _listKey.currentState!.insertItem(insertIndex);
  }

  void _insertMultipleItems() {
    final items = ['Pig', 'Chichen', 'Dog'];
    int insertIndex = 2;
    _data.insertAll(insertIndex, items);
    // This is a bit of a hack because currentState doesn't have
    // an insertAll() method.
    for (int offset = 0; offset < items.length; offset++) {
      _listKey.currentState?.insertItem(insertIndex + offset);
    }
  }

  void _removeSingleItems() {
    for (var i = 0; i < _data.length; i++) {
      int removeIndex = i;
      String removedItem = _data.removeAt(removeIndex);
      // This builder is just so that the animation has something
      // to work with before it disappears from view since the
      // original has already been deleted.
      AnimatedListRemovedItemBuilder builder = (context, animation) {
        // A method to build the Card widget.
        return _buildItem(removedItem, animation);
      };
      _listKey.currentState?.removeItem(removeIndex, builder);
    }
  }

  void _removeMultipleItems() {
    int removeIndex = 2;
    int count = 2;
    for (int i = 0; i < count; i++) {
      String removedItem = _data.removeAt(removeIndex);
      AnimatedListRemovedItemBuilder builder = (context, animation) {
        return _buildItem(removedItem, animation);
      };
      _listKey.currentState?.removeItem(removeIndex, builder);
    }
  }

  void _removeAllItems() {
    final length = _data.length;
    for (int i = length - 1; i >= 0; i--) {
      String removedItem = _data.removeAt(i);
      AnimatedListRemovedItemBuilder builder = (context, animation) {
        return _buildItem(removedItem, animation);
      };
      _listKey.currentState?.removeItem(i, builder);
    }
  }

  void _updateSingleItem() {
    final newValue = 'I like sheep';
    final index = 3;
    setState(() {
      _data[index] = newValue;
    });
  }
}
