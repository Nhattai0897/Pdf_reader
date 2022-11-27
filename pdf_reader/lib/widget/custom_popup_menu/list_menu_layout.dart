import 'package:flutter/material.dart';
import 'menu_config.dart';
import 'menu_item.dart';
import 'menu_layout.dart';
import 'popup_menu.dart';

/// list menu layout
class ListMenuLayout implements MenuLayout {
  final MenuConfig config;
  final List<MenuItemProvider> items;
  final VoidCallback onDismiss;
  final BuildContext context;
  final MenuClickCallback? onClickMenu;
  final int index;
  final bool isHorizontal;

  ListMenuLayout({
    required this.config,
    required this.items,
    required this.onDismiss,
    required this.context,
    required this.index,
    required this.isHorizontal,
    this.onClickMenu,
  });

  @override
  Widget build() {
    return Container(
      width: width,
      height: height,
      child: isHorizontal == false
          ? Column(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Container(
                      width: width,
                      height: height,
                      decoration: BoxDecoration(
                          color: config.backgroundColor,
                          borderRadius: BorderRadius.circular(10.0)),
                      child: Column(
                        children: items.map((item) {
                          return GestureDetector(
                            onTap: () {
                              onDismiss();
                              onClickMenu?.call(item, index);
                            },
                            behavior: HitTestBehavior.translucent,
                            child: Container(
                              height: config.itemHeight,
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    margin: const EdgeInsets.only(left: 10),
                                    child: item.menuImage,
                                  ),
                                  Container(
                                    alignment: Alignment.centerLeft,
                                    margin: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      item.menuTitle,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: item.menuTextStyle,
                                      textAlign: item.menuTextAlign,
                                    ),
                                  )
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    )),
              ],
            )
          : Row(
              children: <Widget>[
                ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Padding(
                      padding: const EdgeInsets.only(right: 0),
                      child: Container(
                          width: width,
                          height: height,
                          color: config.backgroundColor,
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 3),
                            child: ListView.builder(
                                scrollDirection: Axis.horizontal,
                                shrinkWrap: true,
                                itemCount: items.length,
                                itemBuilder: (context, index) {
                                  return InkWell(
                                    onTap: () {
                                      onDismiss();
                                      onClickMenu?.call(items[index], index);
                                    },
                                    child: Container(
                                      height: config.itemHeight,
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                              color: this.index == index
                                                  ? Colors.redAccent
                                                  : Colors.white,
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(5.0)),
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 5, vertical: 3),
                                            margin: EdgeInsets.only(
                                                left: items.length == 1 ? 5 : 8,
                                                right:
                                                    (index == items.length - 1)
                                                        ? 10
                                                        : 0),
                                            child: Text(
                                              (index + 1).toString(),
                                              style: TextStyle(
                                                  color: this.index == index
                                                      ? Colors.white
                                                      : Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                }),
                          )),
                    ))
              ],
            ),
    );
  }

  @override
  double get height =>
      isHorizontal ? config.itemHeight : config.itemHeight * items.length;

  @override
  double get width => isHorizontal
      ? items.length > 3
          ? config.itemWidth * 3.7
          : (config.itemWidth * items.length)
      : config.itemWidth;
}
