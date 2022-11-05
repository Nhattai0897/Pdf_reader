import 'dart:ui';
import 'dart:math' as math;
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pdf_reader/sign_vanban_den/page/view_file_home.dart';
import 'package:pdf_reader/utils/format_date.dart';
import 'package:pdf_reader/widget/custom_popup_menu/popup_menu.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'dashboard_bloc.dart';
import 'dashboard_state.dart';

class DashboardHome extends StatelessWidget {
  DashboardHome({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(providers: [
      BlocProvider<DashboardBloc>(create: (context) => DashboardBloc()),
    ], child: DashboardPage());
  }
}

class DashboardPage extends StatefulWidget {
  DashboardPage({Key? key}) : super(key: key);

  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage>
    with TickerProviderStateMixin {
  late DashboardBloc bloc;
  late double heightAppbar, screenWidth, screenHeight;
  late AnimationController _controller;
  late TabController tabController;
  late LocalAuthentication auth;
  late List<GlobalObjectKey<FormState>> formKeyList;
  late TextEditingController searchController;
  String msg = "You are not authorized.";
  /////////////////
  late Animation<Color?> animation;
  late AnimationController controller;
  bool isAuthen = false;
  List<MenuItemProvider> itemDropdown = [];
  // the GlobalKey is needed to animate the list
  final GlobalKey<AnimatedListState> _listKey = GlobalKey(); // backing data

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    bloc = BlocProvider.of<DashboardBloc>(context);
    searchController = TextEditingController();
    auth = LocalAuthentication();
    bloc.initContext(context);
    // Animation wave
    _controller =
        AnimationController(vsync: this, duration: Duration(seconds: 60))
          ..repeat();
    // Color background
    controller = AnimationController(
        duration: const Duration(milliseconds: 300), vsync: this);
    animation = ColorTween(
            begin: Colors.black87, end: Color.fromRGBO(148, 112, 251, 0.2))
        .animate(controller)
          ..addListener(() {
            setState(() {
              // The state that has changed here is the animation object’s value.
            });
          });
    tabController = TabController(
      initialIndex: 0,
      length: 2,
      vsync: this,
    )..addListener(() {
        switch (tabController.index) {
          case 0:
            setState(() => tabController.index = 0);
            break;
          case 1:
            setState(() => tabController.index = 1);
            break;
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    heightAppbar = MediaQuery.of(context).viewPadding.top;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    formKeyList =
        new List.generate(1, (index) => GlobalObjectKey<FormState>(index));
    return SafeArea(
        top: false,
        child: GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
            bloc.searchAction(false);
          },
          child: Scaffold(
            body: BlocBuilder<DashboardBloc, DashboardState>(
                builder: (context, state) {
              return Container(
                color: animation.value,
                child: Column(
                  children: [
                    Stack(
                      children: [
                        Container(
                          height: 190,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                                colors: [
                                  Color.fromRGBO(148, 112, 251, 1.0),
                                  Color.fromRGBO(151, 116, 247, 1.0),
                                  Color.fromRGBO(134, 88, 249, 1.0),
                                  Color.fromRGBO(118, 71, 248, 1.0),
                                ],
                                begin: const FractionalOffset(0.0, 0.0),
                                end: const FractionalOffset(0.5, 0.4),
                                stops: [0.0, 0.5, 0.75, 1.0],
                                tileMode: TileMode.clamp),
                            borderRadius: BorderRadius.only(
                              bottomLeft: Radius.circular(30.0),
                              bottomRight: Radius.circular(30.0),
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(151, 116, 247, 0.4),
                                blurRadius: 4,
                                offset: Offset(4, 8),
                              ),
                            ],
                          ),
                        ),
                        buildAnimationTime(state),
                        Column(
                          children: [
                            Padding(
                              padding: EdgeInsets.only(top: heightAppbar),
                              child: Container(
                                  color: Colors.transparent,
                                  child: Row(children: [
                                    IconButton(
                                        onPressed: () =>
                                            bloc.searchAction(true),
                                        icon: Icon(
                                          Icons.search,
                                          color: Colors.white,
                                        )),
                                    Expanded(
                                        child: Stack(
                                      children: [
                                        Center(
                                            child: Text(
                                          'PDF Reader',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold),
                                        )),
                                        new AnimatedSize(
                                          curve: Curves.fastOutSlowIn,
                                          vsync: this,
                                          duration:
                                              new Duration(milliseconds: 500),
                                          child: new Container(
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12.0))),
                                            margin:
                                                new EdgeInsets.only(right: 5.0),
                                            height: state.isSearch ? 30 : 0.0,
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Row(
                                                children: [
                                                  Expanded(
                                                      child: state.isSearch
                                                          ? TextField(
                                                              autofocus: true,
                                                              decoration: InputDecoration(
                                                                  hintStyle: TextStyle(
                                                                      color: Colors
                                                                          .grey,
                                                                      fontSize:
                                                                          15),
                                                                  hintText:
                                                                      'Search PDF',
                                                                  contentPadding:
                                                                      EdgeInsets
                                                                          .fromLTRB(
                                                                              0,
                                                                              0,
                                                                              0,
                                                                              16),
                                                                  border:
                                                                      InputBorder
                                                                          .none),
                                                              controller:
                                                                  searchController)
                                                          : SizedBox()),
                                                  state.isSearch
                                                      ? InkWell(
                                                          onTap: () {
                                                            searchController
                                                                .clear();
                                                            FocusScope.of(
                                                                    context)
                                                                .unfocus();
                                                            bloc.searchAction(
                                                                false);
                                                          },
                                                          child: Icon(
                                                            Icons.clear,
                                                            size: 19,
                                                            color: Colors.grey,
                                                          ))
                                                      : SizedBox()
                                                ],
                                              ),
                                            ),
                                          ),
                                        )
                                      ],
                                    )),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                          left: 5, right: 15),
                                      child: InkWell(
                                          key: formKeyList[0],
                                          onTap: () =>
                                              optionMenu(formKeyList[0], state),
                                          child: Icon(
                                            Icons.more_horiz_outlined,
                                            color: Colors.white,
                                          )),
                                    )
                                  ])),
                            ),
                            buildTabbarWidget(state),
                            buildTotalFile(),
                          ],
                        ),
                      ],
                    ),
                    Expanded(
                      child: TabBarView(
                        physics: NeverScrollableScrollPhysics(),
                        controller: tabController,
                        children: [
                          bloc.formKeyList.length != 0
                              ? buildListViewPublish(state)
                              : buildEmptyPublish(),
                          isAuthen == true
                              ? bloc.formKeyList.length != 0
                                  ? buildListViewPrivate(state)
                                  : buildEmptyPrivate()
                              : Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 15),
                                        child: Text(
                                          'Unlock to see private files',
                                          style: TextStyle(
                                              color: state.isNight
                                                  ? Colors.white
                                                  : Colors.black,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                      InkWell(
                                        onTap: () async {
                                          try {
                                            bool pass = await auth.authenticate(
                                                localizedReason:
                                                    'Authenticate with pattern/pin/passcode',
                                                biometricOnly: false);
                                            if (pass) {
                                              msg = "You are Authenticated.";
                                              setState(() {
                                                isAuthen = true;
                                              });
                                            }
                                          } on PlatformException catch (ex) {
                                            msg =
                                                "Error while opening fingerprint/face scanner";
                                          }
                                        },
                                        child: Image.asset(
                                          "assets/fingerprint-2.png",
                                          height: 75,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            }),
          ),
        ));
  }

  Future<void> onClickMenu(
      MenuItemProvider item, int index, DashboardState state) async {
    switch (item.menuTitle) {
      case ' Private':
        _removeAllItems(state);
        await Future.delayed(Duration(milliseconds: 400));
        setState(() {
          isAuthen = false;
          bloc.formKeyList = bloc.newPrivateFileLst;
        });

        break;

      default:
        controller.isCompleted ? controller.reverse() : controller.forward();
        bloc.onChangeDay();
        break;
    }
  }

  void _removeAllItems(DashboardState state) {
    final length = bloc.formKeyList.length;
    for (int i = length - 1; i >= 0; i--) {
      bloc.newPrivateFileLst.add(bloc.formKeyList[i]);
      GlobalObjectKey<FormState> removedItem = bloc.formKeyList.removeAt(i);
      AnimatedListRemovedItemBuilder builder = (context, animation) {
        return _buildItem(animation, state, removedItem);
      };
      _listKey.currentState?.removeItem(i, builder);
    }
  }

  void optionMenu(
      GlobalKey<State<StatefulWidget>> btnKey, DashboardState state) {
    PopupMenu menu = PopupMenu(
        context: context,
        config: MenuConfig.forList(
            backgroundColor: Colors.black.withOpacity(0.8),
            lineColor: Colors.black,
            itemWidth: 125),
        items: [],
        onClickMenu: (item, index) {
          onClickMenu(item, index, state);
        },
        index: 0);
    isAuthen
        ? menu.items = [
            MenuItem.forList(
                title: state.isNight ? 'Light theme' : 'Dark theme',
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white),
                image: Image.asset(
                  "assets/day-and-night.png",
                  height: 20,
                )),
            MenuItem.forList(
                title: ' Private',
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white),
                image: Image.asset(
                  "assets/folder-2.png",
                  height: 16,
                ))
          ]
        : menu.items = [
            MenuItem.forList(
                title: state.isNight ? 'Light theme' : 'Dark theme',
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white),
                image: Image.asset(
                  "assets/day-and-night.png",
                  height: 20,
                )),
          ];

    menu.show(widgetKey: btnKey);
  }

  Positioned buildAnimationTime(DashboardState state) {
    return Positioned(
      top: 0,
      left: -20,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (_, child) {
          return Transform.rotate(
            angle: _controller.value * 2 * math.pi,
            child: child,
          );
        },
        child: Image.asset(
          state.isNight ? "assets/moon.png" : "assets/sun.png",
          height: state.isNight ? 96 : 90,
        ),
      ),
    );
  }

  Widget buildCarousel() {
    return CarouselSlider(
        items: [
          buildTotalFile(),
        ],
        options: CarouselOptions(
            autoPlayInterval: Duration(seconds: 5),
            disableCenter: true,
            enableInfiniteScroll: true,
            initialPage: 0,
            viewportFraction: 0.85,
            onPageChanged: (index, reason) {}));
  }

  Widget buildTotalFile() {
    return Padding(
      padding: const EdgeInsets.only(top: 15, bottom: 10),
      child: Container(
        height: 80,
        width: (screenWidth - 50),
        decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [
                Color.fromRGBO(255, 255, 255, 1.0),
                Color.fromRGBO(255, 255, 255, 1.0),
              ],
              begin: const FractionalOffset(0.0, 0.0),
              end: const FractionalOffset(0.2, 0.9),
              stops: [0.0, 1.0],
              tileMode: TileMode.clamp),
          borderRadius: BorderRadius.all(Radius.circular(15.0)),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              offset: Offset(3, 5), // Shadow position
            ),
          ],
        ),
        child: Container(
          color: Colors.transparent,
          height: 20,
          width: (screenWidth - 70),
          child: Padding(
              padding: const EdgeInsets.all(2.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: buildPieChart(),
              )),
        ),
      ),
    );
  }

  ListView buildListViewPublish(DashboardState state) {
    return ListView.builder(
        padding: EdgeInsets.only(top: 0),
        shrinkWrap: true,
        itemCount: bloc.formKeyList.length,
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => ViewFileMain(
                          fileKyTen:
                              'https://www.africau.edu/images/default/sample.pdf',
                          isKySo: true,
                          isUseMauChuKy: true,
                        )),
              );
              //ViewFileMain
            },
            child: AnimationConfiguration.synchronized(
              duration: Duration(milliseconds: 1000),
              child: SlideAnimation(
                duration: Duration(milliseconds: 600),
                child: Padding(
                  padding: EdgeInsets.only(left: 25, right: 25, bottom: 12),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.0),
                    child: Slidable(
                      enabled: false,
                      key: const ValueKey(0),
                      closeOnScroll: false,
                      endActionPane: ActionPane(
                        extentRatio: 0.60,
                        motion: DrawerMotion(),
                        children: [
                          SlidableAction(
                            flex: 1,
                            autoClose: true,
                            onPressed: (context) {},
                            backgroundColor: Color.fromRGBO(151, 116, 247, 1.0),
                            foregroundColor: Colors.white,
                            icon: Icons.share,
                            spacing: 5,
                            padding: EdgeInsets.all(0),
                            label: 'Share',
                          ),
                          SlidableAction(
                            flex: 1,
                            autoClose: true,
                            onPressed: (context) {},
                            backgroundColor: Color.fromRGBO(134, 88, 249, 1.0),
                            foregroundColor: Colors.white,
                            icon: Icons.privacy_tip_outlined,
                            spacing: 5,
                            padding: EdgeInsets.all(0),
                            label: 'Private',
                          ),
                          SlidableAction(
                            flex: 1,
                            autoClose: true,
                            onPressed: (context) {},
                            backgroundColor: Color(0xFFFE4A49),
                            foregroundColor: Colors.white,
                            icon: Icons.delete,
                            spacing: 5,
                            padding: EdgeInsets.all(0),
                            label: 'Delete',
                          ),
                        ],
                      ),
                      child: Builder(builder: (ctx) {
                        return Container(
                          height: 57,
                          decoration: BoxDecoration(
                            color:
                                state.isNight ? Colors.grey[100] : Colors.white,
                            boxShadow: [
                              BoxShadow(
                                color: Color.fromRGBO(151, 116, 247, 0.3),
                                blurRadius: 4,
                                offset: Offset(4, 8),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Padding(
                                padding:
                                    const EdgeInsets.only(left: 5, right: 7),
                                child: Container(
                                    height: 40,
                                    width: 40,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                          colors: [
                                            Color.fromRGBO(251, 173, 254, 0.5),
                                            Color.fromRGBO(250, 157, 254, 0.75),
                                            Color.fromRGBO(250, 127, 253, 0.85),
                                            Color.fromRGBO(255, 109, 255, 0.95),
                                          ],
                                          begin:
                                              const FractionalOffset(0.0, 0.0),
                                          end: const FractionalOffset(0.2, 0.9),
                                          stops: [0.0, 0.5, 0.75, 1.0],
                                          tileMode: TileMode.clamp),
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      boxShadow: [
                                        BoxShadow(
                                            color: Color.fromRGBO(
                                                249, 95, 254, 0.2),
                                            blurRadius: 2,
                                            offset: Offset(1, 1))
                                      ],
                                    ),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(5.0)),
                                      child: BackdropFilter(
                                        child: Padding(
                                          padding: const EdgeInsets.all(5.0),
                                          child: Image.asset(
                                            "assets/pdf-file.png",
                                            height: 50,
                                          ),
                                        ),
                                        filter: ImageFilter.blur(
                                            sigmaX: 0.5, sigmaY: 0.5),
                                      ),
                                    )),
                              ),
                              Expanded(
                                  child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 2.0),
                                    child: Text(
                                        'How to Create a circular progressbar in Android',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(color: Colors.black)),
                                  ),
                                  Text(
                                    FormatDateAndTime
                                        .convertDatetoStringWithFormat(
                                            DateTime.now(), 'hh:mm dd/MM/yyyy'),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(color: Colors.grey[600]),
                                  )
                                ],
                              )),
                              IconButton(
                                  splashColor: Colors.transparent,
                                  highlightColor: Colors.transparent,
                                  onPressed: () {
                                    Slidable.of(ctx)?.animation.isCompleted ==
                                            true
                                        ? Slidable.of(ctx)?.close()
                                        : Slidable.of(ctx)?.openEndActionPane();
                                  },
                                  icon:
                                      Icon(Icons.more_horiz_rounded, size: 20))
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ),
            ),
          );
        });
  }

  Center buildEmptyPublish() {
    return Center(
      child: Container(
        width: 115,
        height: 115,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Image.asset(
              "assets/empty-folder.png",
              height: 68,
            ),
          ),
        ),
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.black.withOpacity(0.2)),
      ),
    );
  }

  Center buildEmptyPrivate() {
    return Center(
      child: Container(
        width: 115,
        height: 115,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Image.asset(
              "assets/empty-folder.png",
              height: 68,
            ),
          ),
        ),
        decoration: BoxDecoration(
            shape: BoxShape.circle, color: Colors.black.withOpacity(0.2)),
      ),
    );
  }

  AnimatedList buildListViewPrivate(DashboardState state) {
    return AnimatedList(
        padding: EdgeInsets.only(top: 0),
        key: _listKey,
        shrinkWrap: true,
        initialItemCount: bloc.formKeyList.length,
        itemBuilder: (context, index, animation) {
          return _buildItem(animation, state, bloc.formKeyList[index]);
        });
  }

  SizeTransition _buildItem(Animation<double> animation, DashboardState state,
      GlobalObjectKey<FormState> removedItem) {
    return SizeTransition(
      sizeFactor: animation,
      child: AnimationConfiguration.synchronized(
        duration: Duration(milliseconds: 1000),
        child: SlideAnimation(
          duration: Duration(milliseconds: 600),
          child: Padding(
            padding: EdgeInsets.only(left: 25, right: 25, bottom: 12),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10.0),
              child: Slidable(
                enabled: false,
                key: const ValueKey(0),
                closeOnScroll: false,
                endActionPane: ActionPane(
                  extentRatio: 0.60,
                  motion: DrawerMotion(),
                  children: [
                    SlidableAction(
                      flex: 1,
                      autoClose: true,
                      onPressed: (context) {},
                      backgroundColor: Color.fromRGBO(151, 116, 247, 1.0),
                      foregroundColor: Colors.white,
                      icon: Icons.share,
                      spacing: 5,
                      padding: EdgeInsets.all(0),
                      label: 'Share',
                    ),
                    SlidableAction(
                      flex: 1,
                      autoClose: true,
                      onPressed: (context) {},
                      backgroundColor: Color.fromRGBO(134, 88, 249, 1.0),
                      foregroundColor: Colors.white,
                      icon: Icons.privacy_tip_outlined,
                      spacing: 5,
                      padding: EdgeInsets.all(0),
                      label: 'Private',
                    ),
                    SlidableAction(
                      flex: 1,
                      autoClose: true,
                      onPressed: (context) {},
                      backgroundColor: Color(0xFFFE4A49),
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      spacing: 5,
                      padding: EdgeInsets.all(0),
                      label: 'Delete',
                    ),
                  ],
                ),
                child: Builder(builder: (ctx) {
                  return Container(
                    height: 57,
                    decoration: BoxDecoration(
                      color: state.isNight ? Colors.grey[100] : Colors.white,
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(151, 116, 247, 0.3),
                          blurRadius: 4,
                          offset: Offset(4, 8),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 5, right: 7),
                          child: Container(
                              height: 40,
                              width: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                    colors: [
                                      Color.fromRGBO(251, 173, 254, 0.5),
                                      Color.fromRGBO(250, 157, 254, 0.75),
                                      Color.fromRGBO(250, 127, 253, 0.85),
                                      Color.fromRGBO(255, 109, 255, 0.95),
                                    ],
                                    begin: const FractionalOffset(0.0, 0.0),
                                    end: const FractionalOffset(0.2, 0.9),
                                    stops: [0.0, 0.5, 0.75, 1.0],
                                    tileMode: TileMode.clamp),
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                boxShadow: [
                                  BoxShadow(
                                      color: Color.fromRGBO(249, 95, 254, 0.2),
                                      blurRadius: 2,
                                      offset: Offset(1, 1))
                                ],
                              ),
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5.0)),
                                child: BackdropFilter(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Image.asset(
                                      "assets/pdf-file.png",
                                      height: 50,
                                    ),
                                  ),
                                  filter: ImageFilter.blur(
                                      sigmaX: 0.5, sigmaY: 0.5),
                                ),
                              )),
                        ),
                        Expanded(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(bottom: 2.0),
                              child: Text(
                                  'How to Create a circular progressbar in Android which rotates on it?',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(color: Colors.black)),
                            ),
                            Text(
                              DateTime.now().toString(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(color: Colors.grey[600]),
                            )
                          ],
                        )),
                        IconButton(
                            splashColor: Colors.transparent,
                            highlightColor: Colors.transparent,
                            onPressed: () {
                              Slidable.of(ctx)?.animation.isCompleted == true
                                  ? Slidable.of(ctx)?.close()
                                  : Slidable.of(ctx)?.openEndActionPane();
                            },
                            icon: Icon(Icons.more_horiz_rounded, size: 20))
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildPieChart() {
    double? percent;

    Map<String, double> dataMapMDHL = {
      "phanTram": percent ?? 20,
      "100": 100 - (percent ?? 0),
    };

    List<Color> listColor = [
      Colors.green,
      Colors.red[700]!,
    ];
    return Container(
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Image.asset(
                "assets/folder.png",
                height: 55,
              ),
              tabController.index == 1
                  ? Padding(
                      padding: const EdgeInsets.only(top: 5.0, right: 3.0),
                      child: Image.asset(
                        "assets/bubble-chat.png",
                        height: 22,
                      ),
                    )
                  : SizedBox()
            ],
          ),
          Expanded(
              child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                        child: Text(
                          tabController.index == 0
                              ? '${bloc.formKeyList.length} files'
                              : '${bloc.formKeyList.length} private files',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(118, 71, 248, 1.0)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 1.0),
                        child: Text(
                          'Free Space',
                          style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: Colors.grey[400]),
                        ),
                      )
                    ],
                  ),
                  Spacer(),
                ],
              ),
              Padding(
                padding: EdgeInsets.only(top: 4.0),
                child: new LinearPercentIndicator(
                  animation: true,
                  lineHeight: 08.0,
                  animationDuration: 2000,
                  percent: 0.5,
                  linearStrokeCap: LinearStrokeCap.roundAll,
                  progressColor: Colors.greenAccent,
                ),
              ),
            ],
          ))
        ],
      ),
    );
  }

  Padding buildTabbarWidget(DashboardState state) {
    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Container(
        height: 45,
        width: screenWidth - 50,
        decoration: BoxDecoration(
            color: state.isNight ? Colors.black54 : Colors.white,
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(151, 116, 247, 0.3),
                blurRadius: 4,
                offset: Offset(4, 8), // Shadow position
              ),
            ],
            borderRadius: BorderRadius.all(Radius.circular(30.0))),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Stack(
              alignment: AlignmentDirectional.center,
              children: [
                tabController.index == 0
                    ? buttonTabbar(title: 'Recent')
                    : InkWell(
                        onTap: () => setState(() => tabController.index = 0),
                        child: SizedBox(
                          height: 45,
                          width: (screenWidth - 50) / 2,
                          child: Center(
                            child: Text('Recent',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: Colors.grey)),
                          ),
                        ),
                      ),
              ],
            ),
            Expanded(
                child: Stack(
              alignment: AlignmentDirectional.center,
              children: [
                tabController.index == 1
                    ? buttonTabbar(title: 'Private')
                    : SizedBox(
                        height: 45,
                        child: InkWell(
                          onTap: () => setState(() => tabController.index = 1),
                          child: Center(
                            child: Text(
                              'Private',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        ),
                      ),
              ],
            ))
          ],
        ),
      ),
    );
  }

  Widget buttonTabbar({required String title}) {
    return InkWell(
      onTap: () =>
          setState(() => tabController.index = title == 'Private' ? 1 : 0),
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Container(
          height: 40,
          width: (screenWidth - 50) / 2,
          decoration: BoxDecoration(
            gradient: LinearGradient(
                colors: [
                  Color.fromRGBO(251, 173, 254, 1.0),
                  Color.fromRGBO(250, 157, 254, 1.0),
                  Color.fromRGBO(250, 127, 253, 1.0),
                  Color.fromRGBO(255, 109, 255, 1.0),
                ],
                begin: const FractionalOffset(0.0, 0.0),
                end: const FractionalOffset(0.2, 0.9),
                stops: [0.0, 0.5, 0.75, 1.0],
                tileMode: TileMode.clamp),
            borderRadius: BorderRadius.all(Radius.circular(30.0)),
            boxShadow: [
              BoxShadow(
                color: Color.fromRGBO(249, 95, 254, 0.2),
                blurRadius: 2,
                offset: Offset(1, 1), // Shadow position
              ),
            ],
          ),
          child: Center(
            child: Text(
              title,
              style: TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}
