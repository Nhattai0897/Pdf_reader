import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'dart:math' as math;
import 'package:another_flushbar/flushbar.dart';
import 'package:app_settings/app_settings.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:local_auth/local_auth.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:pdf_reader/sign_vanban_den/model/pdf_result.dart';
import 'package:pdf_reader/sign_vanban_den/page/view_file_home.dart';
import 'package:pdf_reader/sign_vanban_den/utils/util.dart';
import 'package:pdf_reader/sign_vanban_den/widget/modal_bottom_sheet_select_file.dart';
import 'package:pdf_reader/utils/base_multi_language.dart';
import 'package:pdf_reader/utils/format_date.dart';
import 'package:pdf_reader/utils/networks.dart';
import 'package:pdf_reader/utils/notification_service.dart';
import 'package:pdf_reader/utils/shared_prefs.dart';
import 'package:pdf_reader/widget/custom_popup_menu/popup_menu.dart';
import 'package:pdf_reader/widget/lock_page.dart';
import 'package:pdf_reader/widget/popup_link.dart';
import 'package:pdf_reader/widget/popup_list_picker.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_extend/share_extend.dart';
import 'package:showcaseview/showcaseview.dart';
import 'package:tiengviet/tiengviet.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vibration/vibration.dart';
import '../main.dart';
import 'dashboard_bloc.dart';
import 'dashboard_state.dart';
import 'package:device_info_plus/device_info_plus.dart';

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
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  late DashboardBloc bloc;
  late double heightAppbar, screenWidth, screenHeight;
  late AnimationController _controllerRotateLightDark;
  late TabController tabController;
  late LocalAuthentication auth;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  late TextEditingController searchController;
  String tempPath = "";
  late String pathFile;
  late Animation<Color?> animation;
  late AnimationController controller;
  String msg = "You are not authorized.";
  String dir = "";
  List<MenuItemProvider> itemDropdown = [];
  bool isAuthen = false;
  bool isZalo = false;
  bool isDownloadFolder = false;
  bool isSearch = false;
  bool isFirstSlide = false;
  bool isPermission = false;
  bool isFirst = true;
  BuildContext? showCaseContext;
  late AppLifecycleState lifecycleState = AppLifecycleState.resumed;
  CarouselController carouselController = CarouselController();
  var androidInfo;
  var sdkInt;
  var dio;
  int? countPermis;
  late final Box pdfBox;
  late final Box pdfPrivateBox;
  late final Box conutPermissBox;

  ///List pdf public dc clone ra từ list orgin hive publicBox
  List<PDFModel> publicCloneList = [];

  /// list pdf public dùng hiển thị khi search(không nên thao tác xóa sửa)
  List<PDFModel> publicSearchCurrentList = [];

  ///List pdf private dc clone ra từ list orgin hive publicBox
  List<PDFModel> privateCloneList = [];

  /// list pdf privarte dùng hiển thị khi search(không nên thao tác xóa sửa)
  List<PDFModel> privateSearchCurrentList = [];

  /// Biến dùng để hiển thị ban đầu khi chưa nhập text search(Public)
  bool isFirstPublic = false;

  /// Biến dùng để hiển thị ban đầu khi chưa nhập text search(Private)
  bool isFirstPrivate = false;
  final GlobalKey _one = GlobalKey();
  final GlobalKey _two = GlobalKey();
  final GlobalKey _three = GlobalKey();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    NoticationService.initialize(flutterLocalNotificationsPlugin);
    WidgetsBinding.instance!.addObserver(this);
    dio = Dio();
    pdfBox = Hive.box('pdfBox');
    pdfPrivateBox = Hive.box('pdfPriavteBox');
    conutPermissBox = Hive.box('countPermisBox');
    bloc = BlocProvider.of<DashboardBloc>(context);
    searchController = TextEditingController();
    auth = LocalAuthentication();
    bloc.initContext(context);
    setupCountPermiss();
    // Animation wave
    _controllerRotateLightDark =
        AnimationController(vsync: this, duration: Duration(seconds: 60))
          ..repeat();
    // Color background
    controller = AnimationController(
        duration: const Duration(milliseconds: 600), vsync: this);
    animation = ColorTween(
            begin: Color.fromRGBO(148, 112, 251, 0.2), end: Colors.black87)
        .animate(controller)
          ..addListener(() => setState(() {
                // The state that has changed here is the animation object’s value.(Update background light_dark mode)
              }));
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
    getPrivatePath();
    getDirPath();
    WidgetsBinding.instance!.addPostFrameCallback((_) async {
      isFirst = SharedPrefs().getValue<bool>(KeyPrefs.isFirst) ?? true;
      if (isFirst) {
        await Future.delayed(Duration(milliseconds: 500));
        ShowCaseWidget.of(showCaseContext!).startShowCase([_one, _two, _three]);
      }
      reDownloadFilePending();
    });
  }

  @override
  didChangeAppLifecycleState(AppLifecycleState state) {
    lifecycleState = state;
  }

  Future<void> getPrivatePath() async {
    tempPath = await FileLocalResponse().getPathLocal(
          ePathType: EPathType.Storage,
          configPathStr: 'privateFolder',
        ) ??
        "";
  }

  Future<void> changeLanguage() async {
    try {
      var language = SharedPrefs().getValue(KeyPrefs.localeCode) ?? 'VI';
      SharedPrefs()
          .setValue(KeyPrefs.localeCode, language == "VI" ? "EN" : "VI");
      bloc.updateLanguage(language == "VI" ? false : true);
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => MyHomePage(isFirst: false)));
    } catch (e) {
      print(e);
    }
  }

//Sort by Datetime
  int _reverseOrder(k1, k2) {
    if (k1 is int) {
      if (k2 is int) {
        if (k1 > k2) {
          return -1;
        } else if (k1 < k2) {
          return 1;
        } else {
          return 0;
        }
      } else {
        return -1;
      }
    } else {
      return 0;
    }
  }

  void getDirPath() async {
    dir = (await getApplicationDocumentsDirectory()).path;
  }

  Future<void> setupCountPermiss() async {
    // get giá trị theo key là name.
    countPermis = conutPermissBox.get('count');
    if (countPermis == null) {
      await conutPermissBox.put('count', 0);
    }
  }

  _deleteItemList(int index) {
    pdfBox.deleteAt(index);
  }

  _updateItem({required PDFModel pdfModel, required int index}) async {
    await pdfBox.putAt(index, pdfModel);
  }

  Future<void> addPublicItem(PDFModel pdfModel) async {
    // phương thức add() sẽ tự động tăng key lên +1 mỗi khi có liên hệ được thêm vào.
    await pdfBox.add(PDFModel(
        pathFile: pdfModel.pathFile,
        urlLink: pdfModel.urlLink,
        timeOpen: pdfModel.timeOpen,
        currentIndex: pdfModel.currentIndex,
        isOpen: false,
        isEdit: pdfModel.isEdit ?? false));
  }

  ///////// Private box ////////

  _deleteItemPrivateList(int index) {
    pdfPrivateBox.deleteAt(index);
  }

  _updatePrivateItem({required PDFModel pdfModel, required int index}) async {
    await pdfPrivateBox.putAt(index, pdfModel);
  }

  Future<void> addPrivateItem(PDFModel pdfModel) async {
    // phương thức add() sẽ tự động tăng key lên +1 mỗi khi có liên hệ được thêm vào.
    await pdfPrivateBox.add(pdfModel);
  }

  @override
  void dispose() {
    tabController.dispose();
    _controllerRotateLightDark.dispose();
    controller.dispose();
    Hive.close();
    bloc.dispose();
    pdfBox.close();
    pdfPrivateBox.close();
    conutPermissBox.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    heightAppbar = MediaQuery.of(context).viewPadding.top;
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    return ShowCaseWidget(onFinish: () {
      if (isFirst) {
        SharedPrefs().setValue<bool>(KeyPrefs.isFirst, false);
      }
    }, builder: Builder(builder: (context) {
      showCaseContext = context;
      return SafeArea(
          top: false,
          child: GestureDetector(
            onTap: () => closeSearch(),
            child: Scaffold(
              body: BlocBuilder<DashboardBloc, DashboardState>(
                  builder: (context, state) {
                isSearch = state.isSearch;
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
                                      isAuthen && tabController.index == 1 ||
                                              tabController.index == 0
                                          ? IconButton(
                                              onPressed: () {
                                                bloc.searchAction(true);
                                              },
                                              icon: Icon(
                                                Icons.search,
                                                color: Colors.white,
                                              ))
                                          : IconButton(
                                              onPressed: () => Flushbar(
                                                    messageText: Text(
                                                        Language.of(context)!.trans(
                                                                "searchPrivate") ??
                                                            '',
                                                        style: TextStyle(
                                                            color:
                                                                Colors.white)),
                                                    icon: Icon(
                                                        Icons
                                                            .warning_amber_rounded,
                                                        color: Colors
                                                            .yellowAccent[100]),
                                                    backgroundColor:
                                                        Colors.yellow[700]!,
                                                    flushbarPosition:
                                                        FlushbarPosition.TOP,
                                                    duration: Duration(
                                                        milliseconds: 3000),
                                                  )..show(context),
                                              icon: Icon(
                                                Icons.search_off,
                                                color: Colors.white,
                                              )),
                                      Expanded(
                                          child: Stack(
                                        children: [
                                          Center(
                                              child: Text(
                                            'PDF Editor',
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
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              12.0))),
                                              margin: new EdgeInsets.only(
                                                  right: 5.0),
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
                                                                onChanged: (keySearch) => tabController.index == 0
                                                                    ? searchPublicList(
                                                                        keySearch)
                                                                    : searchPrivateList(
                                                                        keySearch),
                                                                decoration: InputDecoration(
                                                                    hintStyle: TextStyle(
                                                                        color: Colors
                                                                            .grey,
                                                                        fontSize:
                                                                            15),
                                                                    hintText:
                                                                        Language.of(context)!.trans("searchpdf") ??
                                                                            "",
                                                                    contentPadding:
                                                                        EdgeInsets.fromLTRB(
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
                                                              isFirstPublic =
                                                                  false;
                                                              searchController
                                                                  .clear();
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
                                                              color:
                                                                  Colors.grey,
                                                            ))
                                                        : SizedBox()
                                                  ],
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      )),
                                      Showcase(
                                        key: _one,
                                        radius: BorderRadius.circular(15),
                                        titleTextStyle: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87),
                                        descTextStyle: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.normal,
                                            color: Colors.black54),
                                        blurValue: 0.1,
                                        overlayOpacity: 0.3,
                                        overlayColor:
                                            Colors.black.withOpacity(0.01),
                                        title: 'Setup',
                                        description:
                                            'Tap to see settings for the app: language, theme, contact...',
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 5, right: 5),
                                          child: InkWell(
                                              key: _formKey,
                                              onTap: () =>
                                                  optionMenu(_formKey, state),
                                              child: Icon(
                                                Icons.more_horiz_outlined,
                                                color: Colors.white,
                                              )),
                                        ),
                                      ),
                                      SizedBox(width: 15)
                                    ])),
                              ),
                              buildTabbarWidget(state),
                              buildTotalFile(state),
                            ],
                          ),
                        ],
                      ),
                      Expanded(
                        child: TabBarView(
                          physics: NeverScrollableScrollPhysics(),
                          controller: tabController,
                          children: [
                            state.isSearch
                                ? buildPublicSearchListView(
                                    isFirstPublic
                                        ? publicSearchCurrentList
                                        : publicCloneList,
                                    state)
                                : pdfBox.isOpen
                                    ? WatchBoxBuilder(
                                        box: pdfBox,
                                        builder: (context, pdfListBox) {
                                          // Get list dynamic type
                                          publicCloneList = pdfListBox.values
                                              .toList()
                                              .cast<PDFModel>();
                                          bloc.publicCloneList =
                                              publicCloneList;
                                          bloc.pushPublicTotalData(
                                              publicCloneList.length);
                                          return publicCloneList.length != 0
                                              ? buildPublicListView(
                                                  publicCloneList, state)
                                              : buildEmptyPublish();
                                        },
                                      )
                                    : hiveClose(),
                            isAuthen == true
                                ? state.isSearch
                                    ? buildListPrivateSearch(
                                        isFirstPrivate
                                            ? privateSearchCurrentList
                                            : privateCloneList,
                                        state)
                                    : pdfPrivateBox.isOpen
                                        ? WatchBoxBuilder(
                                            box: pdfPrivateBox,
                                            builder:
                                                (context, pdfListPrivateBox) {
                                              // Get list dynamic type
                                              privateCloneList =
                                                  pdfListPrivateBox.values
                                                      .toList()
                                                      .cast<PDFModel>();
                                              bloc.privateCloneList =
                                                  privateCloneList;
                                              bloc.pushPrivateTotalData(
                                                  privateCloneList.length);
                                              return privateCloneList.length !=
                                                      0
                                                  ? buildListViewPrivate(
                                                      privateCloneList, state)
                                                  : buildEmptyPrivate();
                                            },
                                          )
                                        : hiveClose()
                                : buildAuthenWidget(state),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              }),
            ),
          ));
    }));
  }

  Widget hiveClose() {
    openBox();
    return Center(child: CircularProgressIndicator());
  }

  Future<void> openBox() async {
    await Hive.openBox('pdfBox', keyComparator: _reverseOrder);
    await Hive.openBox('pdfPriavteBox', keyComparator: _reverseOrder);
    await Hive.openBox('countPermisBox');
    await Hive.openBox('introuctionBox');
    await Navigator.push(context,
        MaterialPageRoute(builder: (context) => MyHomePage(isFirst: false)));
  }

  void closeSearch() {
    if (isSearch) {
      FocusScope.of(context).unfocus();
      isFirstPublic = false;
      bloc.searchAction(false);
      searchController.clear();
    }
  }

  void searchPublicList(String keySearch) {
    setState(() {
      isFirstPublic = true;
    });
    if (keySearch.trim() == "") {
      setState(() => publicSearchCurrentList = publicCloneList);
    } else {
      setState(() => publicSearchCurrentList = []);
      for (var item in publicCloneList) {
        if (TiengViet.parse(item.pathFile?.split("/").last.toLowerCase() ?? '')
            .contains(TiengViet.parse(keySearch.toLowerCase()))) {
          publicSearchCurrentList.add(item);
        }
      }
      setState(() => publicSearchCurrentList = publicSearchCurrentList);
    }
  }

  void searchPrivateList(String keySearch) {
    setState(() {
      isFirstPrivate = true;
    });
    if (keySearch.trim() == "") {
      setState(() => privateSearchCurrentList = privateCloneList);
    } else {
      setState(() => privateSearchCurrentList = []);
      for (var item in privateCloneList) {
        if (TiengViet.parse(item.pathFile?.split("/").last.toLowerCase() ?? '')
            .contains(TiengViet.parse(keySearch.toLowerCase()))) {
          privateSearchCurrentList.add(item);
        }
      }
      setState(() => privateSearchCurrentList = privateSearchCurrentList);
    }
  }

  Center buildAuthenWidget(DashboardState state) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 15),
            child: Text(
              Language.of(context)!.trans("Unlock") ?? "",
              style: TextStyle(
                  color: state.isNight ? Colors.white : Colors.black,
                  fontSize: 13,
                  fontWeight: FontWeight.bold),
            ),
          ),
          InkWell(
            onTap: () async {
              try {
                bool pass = await auth.authenticate(
                    localizedReason:
                        Language.of(context)!.trans("AuthenPaten") ?? "",
                    biometricOnly: false);
                if (pass) {
                  msg = Language.of(context)!.trans("Authenticated") ?? "";
                  setState(() {
                    isAuthen = true;
                  });
                }
              } on PlatformException catch (ex) {
                msg = Language.of(context)!.trans("ErrorAuthen") ?? "";
              }
            },
            child: Image.asset(
              "assets/fingerprint-2.png",
              height: 75,
            ),
          )
        ],
      ),
    );
  }

  Widget buildPublicListView(List<dynamic> pdfListBox, DashboardState state) {
    return pdfListBox.length != 0
        ? ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: pdfListBox.length,
            itemBuilder: (BuildContext context, int index) {
              final pdfItem = pdfListBox[index] as PDFModel;
              publicCloneList[index].currentIndex = index;
              return InkWell(
                onTap: () async {
                  closeSearch();
                  // await  Slidable.of(context)?.close();
                  bool isExists = await File(pdfItem.pathFile ?? '').exists();
                  if (!isExists) {
                    buildNotFoundDialog(index, pdfItem, true);
                    return;
                  }
                  var linkResult = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewFileMain(
                              isNightMode: state.isNight,
                              fileKyTen: pdfItem.pathFile ?? '',
                              isKySo: true,
                              isUseMauChuKy: true,
                              isPublic: tabController.index == 0,
                            )),
                  );
                  if (linkResult != null && linkResult != "") {
                    await _updateItem(
                        pdfModel: PDFModel(
                            pathFile: linkResult,
                            currentIndex: pdfItem.currentIndex,
                            timeOpen: DateTime.now(),
                            isOpen: pdfItem.isOpen,
                            urlLink: pdfItem.urlLink,
                            isNew: false,
                            isEdit: pdfItem.isEdit == false
                                ? linkResult == pdfItem.pathFile
                                    ? false
                                    : true
                                : pdfItem.isEdit ?? false),
                        index: index);
                    if (linkResult != pdfItem.pathFile) {
                      await bloc.setupTotalData();
                      carouselController.nextPage();
                      await File(pdfItem.pathFile!).delete();
                    }
                  }
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
                                onPressed: (context) async {
                                  closeSearch();
                                  // Slidable.of(context)?.close();
                                  await ShareExtend.share(
                                      pdfItem.pathFile ?? '', "file");
                                },
                                backgroundColor:
                                    Color.fromRGBO(151, 116, 247, 1.0),
                                foregroundColor: Colors.white,
                                icon: Icons.share,
                                spacing: 5,
                                padding: EdgeInsets.all(0),
                                label:
                                    Language.of(context)!.trans("share") ?? "",
                              ),
                              SlidableAction(
                                flex: 1,
                                autoClose: true,
                                onPressed: (context) {
                                  closeSearch();
                                  // Slidable.of(context)?.close();
                                  buildPrivateDialog(
                                      index,
                                      pdfItem.currentIndex ?? 0,
                                      pdfItem,
                                      true,
                                      false);
                                },
                                backgroundColor:
                                    Color.fromRGBO(134, 88, 249, 1.0),
                                foregroundColor: Colors.white,
                                icon: Icons.lock,
                                spacing: 5,
                                padding: EdgeInsets.all(0),
                                label: Language.of(context)!.trans("private") ??
                                    "",
                              ),
                              SlidableAction(
                                flex: 1,
                                autoClose: true,
                                onPressed: (context) {
                                  closeSearch();
                                  // Slidable.of(context)?.close();
                                  buildRemoveDialog(
                                      index, 0, pdfItem, true, false);
                                },
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                spacing: 5,
                                padding: EdgeInsets.all(0),
                                label:
                                    Language.of(context)!.trans("Delete") ?? "",
                              ),
                            ],
                          ),
                          child: Builder(builder: (ctx) {
                            // if (pdfItem.isOpen != null &&
                            //     pdfItem.isOpen == false) {
                            //   Slidable.of(ctx)?.close();
                            // } else if (isFirstSlide) {
                            //   Slidable.of(ctx)?.openEndActionPane();
                            // }
                            return Container(
                              height: 57,
                              decoration: BoxDecoration(
                                color: state.isNight
                                    ? Colors.grey[100]
                                    : Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color.fromRGBO(151, 116, 247, 0.3),
                                    blurRadius: 4,
                                    offset: Offset(4, 8),
                                  ),
                                ],
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10.0)),
                              ),
                              child: Row(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 7),
                                    child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Color.fromRGBO(
                                                    251, 173, 254, 0.5),
                                                Color.fromRGBO(
                                                    250, 157, 254, 0.75),
                                                Color.fromRGBO(
                                                    250, 127, 253, 0.85),
                                                Color.fromRGBO(
                                                    255, 109, 255, 0.86),
                                              ],
                                              begin: const FractionalOffset(
                                                  0.0, 0.0),
                                              end: const FractionalOffset(
                                                  0.2, 0.9),
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
                                            child: Stack(
                                                alignment:
                                                    Alignment.bottomRight,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Image.asset(
                                                      "assets/file-format.png",
                                                      height: 50,
                                                    ),
                                                  ),
                                                  pdfItem.isEdit ?? false
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 2.0,
                                                                  bottom: 9.0),
                                                          child: Container(
                                                              color: Colors
                                                                  .blue[400],
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        0.8,
                                                                    vertical:
                                                                        1.0),
                                                                child: Text(
                                                                    Language.of(context)!.trans(
                                                                            "Edited") ??
                                                                        "",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            6.8)),
                                                              )),
                                                        )
                                                      : SizedBox(),
                                                ]),
                                            filter: ImageFilter.blur(
                                                sigmaX: 0.5, sigmaY: 0.5),
                                          ),
                                        )),
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2.0),
                                        child: Text(
                                            pdfItem.pathFile?.split("/").last ??
                                                '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        children: [
                                          Text(
                                            FormatDateAndTime
                                                .convertDatetoStringWithFormat(
                                                    pdfItem.timeOpen ??
                                                        DateTime.now(),
                                                    ' dd/MM/yyyy'),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                color: Colors.grey[600]),
                                          ),
                                          pdfItem.isNew != null &&
                                                  pdfItem.isNew == true
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          left: 4.0),
                                                  child: Container(
                                                      decoration: BoxDecoration(
                                                          boxShadow: [
                                                            BoxShadow(
                                                              color: Colors
                                                                  .grey[200]!,
                                                              blurRadius: 4,
                                                              offset:
                                                                  Offset(3, 3),
                                                            ),
                                                          ],
                                                          color: Colors.red
                                                              .withOpacity(0.9),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(5)),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                vertical: 2,
                                                                horizontal: 3),
                                                        child: Row(
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      right: 2),
                                                              child: Container(
                                                                width: 4,
                                                                height: 4,
                                                                decoration:
                                                                    new BoxDecoration(
                                                                  color: Colors
                                                                      .white,
                                                                  shape: BoxShape
                                                                      .circle,
                                                                ),
                                                              ),
                                                            ),
                                                            Text(
                                                                Language.of(context)!
                                                                        .trans(
                                                                            "New") ??
                                                                    "",
                                                                style: TextStyle(
                                                                    color: Colors
                                                                        .white,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold,
                                                                    fontSize:
                                                                        6)),
                                                          ],
                                                        ),
                                                      )),
                                                )
                                              : SizedBox()
                                        ],
                                      ),
                                    ],
                                  )),
                                  pdfItem.propress != null &&
                                          pdfItem.urlLink != null &&
                                          pdfItem.urlLink != "" &&
                                          pdfItem.isDownloadSuccess ==
                                              "inprogress"
                                      ? Padding(
                                          padding:
                                              const EdgeInsets.only(right: 8.0),
                                          child: Container(
                                            child: CircularPercentIndicator(
                                              radius: 16.0,
                                              lineWidth: 2.5,
                                              percent: pdfItem.propress! / 100,
                                              center: pdfItem.propress! / 100 ==
                                                      0.0
                                                  ? Image.asset(
                                                      'assets/download.gif')
                                                  : new Text(
                                                      pdfItem.propress!
                                                              .toStringAsFixed(
                                                                  1) +
                                                          "%",
                                                      style: TextStyle(
                                                          fontSize: 9,
                                                          fontWeight:
                                                              FontWeight.w700),
                                                    ),
                                              progressColor: Colors.green,
                                            ),
                                          ),
                                        )
                                      : pdfItem.propress != null &&
                                                  pdfItem.urlLink != null &&
                                                  pdfItem.urlLink != "" &&
                                                  pdfItem.isDownloadSuccess ==
                                                      "fail" ||
                                              pdfItem.isDownloadSuccess ==
                                                  "pending"
                                          ? Row(
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    Slidable.of(ctx)?.close();
                                                    _deleteItemList(index);
                                                  },
                                                  child: Padding(
                                                    padding: const EdgeInsets
                                                            .symmetric(
                                                        horizontal: 10),
                                                    child: Icon(Icons.delete,
                                                        color: Colors.red,
                                                        size: 20),
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () async {
                                                    isFirstSlide = true;
                                                    Slidable.of(ctx)?.close();
                                                    var linkDownload =
                                                        await downloadFilePDF(
                                                            pdfItem.urlLink ??
                                                                "",
                                                            index,
                                                            pdfItem);
                                                    // Update final pathFile: linkDownload
                                                    if (linkDownload != null) {
                                                      _updateItem(
                                                          pdfModel: PDFModel(
                                                            pathFile:
                                                                linkDownload,
                                                            isDownloadSuccess:
                                                                "success",
                                                            isNew: true,
                                                            isEdit: false,
                                                            urlLink: pdfItem
                                                                    .urlLink ??
                                                                "",
                                                            timeOpen: pdfItem
                                                                .timeOpen,
                                                          ),
                                                          index: index);
                                                    } else {
                                                      _updateItem(
                                                          pdfModel: PDFModel(
                                                            pathFile: pdfItem
                                                                    .urlLink ??
                                                                "",
                                                            isDownloadSuccess:
                                                                "fail",
                                                            isEdit: false,
                                                            isNew: false,
                                                            urlLink: pdfItem
                                                                    .urlLink ??
                                                                "",
                                                            timeOpen: pdfItem
                                                                .timeOpen,
                                                          ),
                                                          index: index);
                                                    }
                                                  },
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 15.0),
                                                    child: Icon(
                                                        Icons.replay_outlined,
                                                        color: Colors.red,
                                                        size: 20),
                                                  ),
                                                ),
                                              ],
                                            )
                                          : IconButton(
                                              splashColor: Colors.transparent,
                                              highlightColor:
                                                  Colors.transparent,
                                              onPressed: () async {
                                                isFirstSlide = true;
                                                Slidable.of(ctx)
                                                            ?.animation
                                                            .isCompleted ==
                                                        true
                                                    ? Slidable.of(ctx)?.close()
                                                    : Slidable.of(ctx)
                                                        ?.openEndActionPane();
                                                if (pdfItem.isOpen != null &&
                                                    pdfItem.isOpen == true) {
                                                  await handleCloseAllList(
                                                      pdfListBox);
                                                } else {
                                                  handleList(pdfListBox, index,
                                                      pdfItem);
                                                }
                                              },
                                              icon: Icon(
                                                  Icons.more_horiz_rounded,
                                                  size: 20)),
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
            },
          )
        : buildEmptyPublish();
  }

  Future<void> handleCloseAllList(List<dynamic> pdfListBox) async {
    // for (var i = 0; i < pdfListBox.length; i++) {
    //   var pdfItem = pdfListBox[i] as PDFModel;
    //   await _updateItem(
    //       pdfModel: PDFModel(
    //           pathFile: pdfItem.pathFile,
    //           timeOpen: pdfItem.timeOpen,
    //           currentIndex: pdfItem.currentIndex,
    //           isEdit: pdfItem.isEdit,
    //           isDownloadSuccess: pdfItem.isDownloadSuccess,
    //           propress: pdfItem.propress,
    //           urlLink: pdfItem.urlLink,
    //           isOpen: false),
    //       index: i);
    // }
  }

  void handleList(List<dynamic> pdfListBox, int index, PDFModel pdfItem) async {
    // for (var i = 0; i < pdfListBox.length; i++) {
    //   var pdfItem = pdfListBox[i] as PDFModel;
    //   await _updateItem(
    //       pdfModel: PDFModel(
    //           pathFile: pdfItem.pathFile,
    //           timeOpen: pdfItem.timeOpen,
    //           isEdit: pdfItem.isEdit,
    //           currentIndex: pdfItem.currentIndex,
    //           isOpen: index == i ? true : false),
    //       index: i);
    // }
  }

  Widget buildPublicSearchListView(
      List<PDFModel> pdfListBox, DashboardState state) {
    return pdfListBox.length != 0
        ? ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: pdfListBox.length,
            itemBuilder: (BuildContext context, int index) {
              final pdfItem = pdfListBox[index];
              return InkWell(
                onTap: () async {
                  // closeSearch();
                  // Slidable.of(context)?.close();
                  bool isExists = await File(pdfItem.pathFile ?? '').exists();
                  if (!isExists) {
                    buildNotFoundDialog(index, pdfItem, true);
                    return;
                  }
                  var linkResult = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewFileMain(
                              isNightMode: state.isNight,
                              fileKyTen: pdfItem.pathFile ?? '',
                              isKySo: true,
                              isUseMauChuKy: true,
                              isPublic: tabController.index == 0,
                            )),
                  );
                  setState(() => publicSearchCurrentList[index] = PDFModel(
                      pathFile: linkResult,
                      timeOpen: DateTime.now(),
                      isOpen: pdfItem.isOpen,
                      urlLink: pdfItem.urlLink,
                      isEdit: pdfItem.isEdit == false
                          ? linkResult == pdfItem.pathFile
                              ? false
                              : true
                          : pdfItem.isEdit ?? false,
                      currentIndex:
                          publicSearchCurrentList[index].currentIndex));

                  await _updateItem(
                      pdfModel: PDFModel(
                          pathFile: linkResult,
                          timeOpen: DateTime.now(),
                          urlLink: pdfItem.urlLink,
                          isDownloadSuccess: pdfItem.isDownloadSuccess,
                          currentIndex: pdfItem.currentIndex,
                          isEdit: pdfItem.isEdit == false
                              ? linkResult == pdfItem.pathFile
                                  ? false
                                  : true
                              : pdfItem.isEdit ?? false,
                          isOpen: pdfItem.isOpen),
                      index: publicSearchCurrentList[index].currentIndex ?? 0);
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
                                onPressed: (context) async {
                                  closeSearch();
                                  // Slidable.of(context)?.close();
                                  await ShareExtend.share(
                                      pdfItem.pathFile ?? '', "file");
                                },
                                backgroundColor:
                                    Color.fromRGBO(151, 116, 247, 1.0),
                                foregroundColor: Colors.white,
                                icon: Icons.share,
                                spacing: 5,
                                padding: EdgeInsets.all(0),
                                label:
                                    Language.of(context)!.trans("share") ?? "",
                              ),
                              SlidableAction(
                                flex: 1,
                                autoClose: true,
                                onPressed: (context) {
                                  closeSearch();
                                  // Slidable.of(context)?.close();
                                  buildPrivateDialog(
                                      index,
                                      pdfItem.currentIndex ?? 0,
                                      pdfItem,
                                      true,
                                      true);
                                },
                                backgroundColor:
                                    Color.fromRGBO(134, 88, 249, 1.0),
                                foregroundColor: Colors.white,
                                icon: Icons.lock,
                                spacing: 5,
                                padding: EdgeInsets.all(0),
                                label: Language.of(context)!.trans("private") ??
                                    "",
                              ),
                              SlidableAction(
                                flex: 1,
                                autoClose: true,
                                onPressed: (context) {
                                  closeSearch();
                                  // Slidable.of(context)?.close();
                                  buildRemoveDialog(pdfItem.currentIndex ?? 0,
                                      index, pdfItem, true, true);
                                },
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                spacing: 5,
                                padding: EdgeInsets.all(0),
                                label:
                                    Language.of(context)!.trans("Delete") ?? "",
                              ),
                            ],
                          ),
                          child: Builder(builder: (ctx) {
                            return Container(
                              height: 57,
                              decoration: BoxDecoration(
                                color: state.isNight
                                    ? Colors.grey[100]
                                    : Colors.white,
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
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 7),
                                    child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Color.fromRGBO(
                                                    251, 173, 254, 0.5),
                                                Color.fromRGBO(
                                                    250, 157, 254, 0.75),
                                                Color.fromRGBO(
                                                    250, 127, 253, 0.85),
                                                Color.fromRGBO(
                                                    255, 109, 255, 0.86),
                                              ],
                                              begin: const FractionalOffset(
                                                  0.0, 0.0),
                                              end: const FractionalOffset(
                                                  0.2, 0.9),
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
                                            child: Stack(
                                                alignment:
                                                    Alignment.bottomRight,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Image.asset(
                                                      "assets/file-format.png",
                                                      height: 50,
                                                    ),
                                                  ),
                                                  pdfItem.isEdit ?? false
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 2.0,
                                                                  bottom: 9.0),
                                                          child: Container(
                                                              color: Colors
                                                                  .blue[400],
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        0.8,
                                                                    vertical:
                                                                        1.0),
                                                                child: Text(
                                                                    Language.of(context)!.trans(
                                                                            "Edited") ??
                                                                        "",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            6.8)),
                                                              )),
                                                        )
                                                      : SizedBox(),
                                                ]),
                                            filter: ImageFilter.blur(
                                                sigmaX: 0.5, sigmaY: 0.5),
                                          ),
                                        )),
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2.0),
                                        child: Text(
                                            pdfItem.pathFile?.split("/").last ??
                                                '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                      Text(
                                        FormatDateAndTime
                                            .convertDatetoStringWithFormat(
                                                pdfItem.timeOpen ??
                                                    DateTime.now(),
                                                ' dd/MM/yyyy'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      )
                                    ],
                                  )),
                                  IconButton(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onPressed: () {
                                        isFirstSlide = true;
                                        Slidable.of(ctx)
                                                    ?.animation
                                                    .isCompleted ==
                                                true
                                            ? Slidable.of(ctx)?.close()
                                            : Slidable.of(ctx)
                                                ?.openEndActionPane();
                                      },
                                      icon: Icon(Icons.more_horiz_rounded,
                                          size: 20))
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
            },
          )
        : buildEmptyPublish();
  }

  Future<void> reDownloadFilePending() async {
    for (var i = 0; i < publicCloneList.length; i++) {
      var propress = publicCloneList[i].propress ?? 0;
      if (propress > 0 && propress < 100) {
        var linkDownload = await downloadFilePDF(
            publicCloneList[i].urlLink ?? "", i, publicCloneList[i]);
        // Update final pathFile: linkDownload
        if (linkDownload != null) {
          await _updateItem(
              pdfModel: PDFModel(
                pathFile: linkDownload,
                isNew: true,
                isDownloadSuccess: "success",
                urlLink: publicCloneList[i].urlLink ?? "",
                timeOpen: publicCloneList[i].timeOpen,
              ),
              index: i);
        }
      }
    }
  }

  void buildNotFoundDialog(int index, PDFModel pdfItem, bool isPublic) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
            actionsPadding: EdgeInsets.zero,
            actionsOverflowButtonSpacing: 0.0,
            titlePadding:
                EdgeInsets.only(bottom: 0.0, left: 8.0, right: 8.0, top: 8.0),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
                          width: 60,
                          child: Image.asset('assets/no-results.png'))),
                  new Text(
                    Language.of(context)!.trans("FileNotexist") ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            actions: listNotFoundAction(
                contextGobal: context,
                index: index,
                pdfItem: pdfItem,
                isPublic: isPublic)));
  }

  void buildPrivateDialog(int index, int indexSearch, PDFModel pdfItem,
      bool isPublic, bool isSearch) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
            actionsPadding: EdgeInsets.zero,
            actionsOverflowButtonSpacing: 0.0,
            titlePadding:
                EdgeInsets.only(bottom: 0.0, left: 8.0, right: 8.0, top: 8.0),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
                          width: 60,
                          child: Image.asset('assets/lock_confirm.gif'))),
                  Text(
                    isPublic
                        ? Language.of(context)!.trans("MakePrivate") ?? ""
                        : Language.of(context)!.trans("MakePublic") ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            actions: listAction(
                contextGobal: context,
                index: index,
                indexSearch: indexSearch,
                pdfItem: pdfItem,
                isPublic: isPublic,
                isSearch: isSearch)));
  }

  void buildRemoveDialog(int index, int indexSearch, PDFModel pdfModel,
      bool isPublic, bool isSearch) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
            actionsPadding: EdgeInsets.zero,
            actionsOverflowButtonSpacing: 0.0,
            titlePadding:
                EdgeInsets.only(bottom: 0.0, left: 8.0, right: 8.0, top: 8.0),
            title: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: Container(
                          width: 60, child: Image.asset('assets/bin.gif'))),
                  new Text(
                    Language.of(context)!.trans("DeleteFile") ?? "",
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            actions: listDeleteAction(
                contextGobal: context,
                index: index,
                indexSearch: indexSearch,
                pdfModel: pdfModel,
                isPublic: isPublic,
                isSearch: isSearch)));
  }

  List<Widget> listDeleteAction(
      {contextGobal,
      required int index,
      required int indexSearch,
      required PDFModel pdfModel,
      required bool isPublic,
      required bool isSearch}) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: InkWell(
          onTap: () async {
            Navigator.of(context, rootNavigator: true).pop();
            if (isPublic) {
              _deleteItemList(index);
            } else {
              _deleteItemPrivateList(index);
            }
            if (isSearch && isPublic) {
              setState(() {
                publicSearchCurrentList.removeAt(indexSearch);
              });
              if (pdfModel.isEdit == true) {
                await File(pdfModel.pathFile ?? '').delete();
              }
            } else if (!isSearch && isPublic) {
              if (pdfModel.isEdit == true) {
                await File(pdfModel.pathFile ?? '').delete();
              }
            } else if (isSearch && !isPublic) {
              setState(() {
                privateSearchCurrentList.removeAt(indexSearch);
              });
              if (pdfModel.isEdit == true) {
                await File(pdfModel.pathFile ?? '').delete();
              }
            } else if (!isSearch && !isPublic) {
              if (pdfModel.isEdit == true) {
                await File(pdfModel.pathFile ?? '').delete();
              }
            }
            await bloc.setupTotalData();
            carouselController.nextPage();
          },
          child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(51, 204, 204, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 5,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                child: Text(
                  'Sure',
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 5.0, bottom: 2.0, right: 2.0),
        child: InkWell(
          onTap: () =>  Navigator.of(context, rootNavigator: true).pop(),
          child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 5,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: Text(
                  Language.of(context)!.trans("Cancel") ?? "",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              )),
        ),
      ),
    ];
  }

  List<Widget> listAction(
      {contextGobal,
      required int index,
      required int indexSearch,
      required PDFModel pdfItem,
      required bool isPublic,
      required bool isSearch}) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: InkWell(
          onTap: () async {
            // Navigator.of(context).pop();
            var status = await Permission.storage.status;
            if (status.isGranted == false) {
              await Permission.storage.request();
              status = await Permission.storage.status;
            }
            if (status.isGranted) {
              Navigator.of(context, rootNavigator: true).pop();
              await Future.delayed(Duration(milliseconds: 100));
              if (isSearch) {
                if (isPublic) {
                  privateFile(index);
                  if (pdfItem.pathFile != null &&
                      pdfItem.isEdit == true &&
                      tempPath != "") {
                    var newPath = pdfItem.pathFile!
                        .replaceAll('publicFolder', 'privateFolder');
                    await createFolder(tempPath);
                    await moveFile(File(pdfItem.pathFile!), newPath);
                    await addPrivateItem(PDFModel(
                        currentIndex: pdfItem.currentIndex,
                        isEdit: pdfItem.isEdit,
                        isOpen: pdfItem.isOpen,
                        urlLink: pdfItem.urlLink,
                        pathFile: newPath,
                        timeOpen: pdfItem.timeOpen));
                    await bloc.setupTotalData();
                    carouselController.nextPage();
                  } else {
                    addPrivateItem(pdfItem);
                    await bloc.setupTotalData();
                    carouselController.nextPage();
                  }
                  setState(() => publicSearchCurrentList.removeAt(indexSearch));
                } else {
                  publicFile(index);
                  if (pdfItem.pathFile != null &&
                      pdfItem.isEdit == true &&
                      tempPath != "") {
                    var newPath = pdfItem.pathFile!
                        .replaceAll('privateFolder', 'publicFolder');
                    await createFolder(tempPath);
                    await moveFile(File(pdfItem.pathFile!), newPath);
                    await addPublicItem(PDFModel(
                        currentIndex: pdfItem.currentIndex,
                        isEdit: pdfItem.isEdit,
                        isOpen: pdfItem.isOpen,
                        urlLink: pdfItem.urlLink,
                        pathFile: newPath,
                        timeOpen: pdfItem.timeOpen));
                    await bloc.setupTotalData();
                    carouselController.nextPage();
                  } else {
                    await addPublicItem(pdfItem);
                    await bloc.setupTotalData();
                    carouselController.nextPage();
                  }
                  setState(
                      () => privateSearchCurrentList.removeAt(indexSearch));
                }
              } else {
                if (isPublic) {
                  privateFile(indexSearch);
                  if (pdfItem.pathFile != null &&
                      pdfItem.isEdit == true &&
                      tempPath != "") {
                    var newPath = pdfItem.pathFile!
                        .replaceAll('publicFolder', 'privateFolder');
                    await createFolder(tempPath);
                    await moveFile(File(pdfItem.pathFile!), newPath);
                    await addPrivateItem(PDFModel(
                        currentIndex: pdfItem.currentIndex,
                        isEdit: pdfItem.isEdit,
                        isOpen: pdfItem.isOpen,
                        urlLink: pdfItem.urlLink,
                        pathFile: newPath,
                        timeOpen: pdfItem.timeOpen));
                    await bloc.setupTotalData();
                    carouselController.nextPage();
                  } else {
                    await addPrivateItem(pdfItem);
                    await bloc.setupTotalData();
                    carouselController.nextPage();
                  }
                } else {
                  publicFile(indexSearch);
                  if (pdfItem.pathFile != null &&
                      pdfItem.isEdit == true &&
                      tempPath != "") {
                    var newPath = pdfItem.pathFile!
                        .replaceAll('privateFolder', 'publicFolder');
                    await createFolder(tempPath);
                    await moveFile(File(pdfItem.pathFile!), newPath);
                    addPublicItem(PDFModel(
                        currentIndex: pdfItem.currentIndex,
                        isEdit: pdfItem.isEdit,
                        urlLink: pdfItem.urlLink,
                        isOpen: pdfItem.isOpen,
                        pathFile: newPath,
                        timeOpen: pdfItem.timeOpen));
                    await bloc.setupTotalData();
                    carouselController.nextPage();
                  } else {
                    await addPublicItem(pdfItem);
                    await bloc.setupTotalData();
                    carouselController.nextPage();
                  }
                }
              }
            } else {
              Navigator.of(context, rootNavigator: true).pop();
              await Future.delayed(Duration(milliseconds: 100));
              Flushbar(
                  messageText: Text(
                      Language.of(context)!.trans("PermissStorage") ?? "",
                      style: TextStyle(color: Colors.white)),
                  icon: Icon(Icons.warning, color: Colors.red[100]),
                  backgroundColor: Colors.red,
                  flushbarPosition: FlushbarPosition.TOP,
                  duration: Duration(milliseconds: 5000),
                  mainButton: InkWell(
                    onTap: () async =>
                      await AppSettings.openAppSettings() ,
                    child: Container(
                      height: 40,
                      width: screenWidth / 3.5,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 2,
                            offset: Offset(0, 3),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(5.0),
                        child: Center(
                          child: Text(
                              Language.of(context)!.trans("OpenSettings") ?? "",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ),
                  ))
                ..show(context);
            }
          },
          child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(51, 204, 204, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 5,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                child: Text(
                  Language.of(context)!.trans("Sure") ?? "",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 5.0, bottom: 2.0, right: 2.0),
        child: InkWell(
          onTap: () =>  Navigator.of(context, rootNavigator: true).pop() ,
          child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 5,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 20.0),
                child: Text(
                  Language.of(context)!.trans("Cancel") ?? "",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              )),
        ),
      ),
    ];
  }

  Future<String> createFolder(String folderPath) async {
    final path = Directory(folderPath);
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      await Permission.storage.request();
    }
    if ((await path.exists())) {
      return path.path;
    } else {
      path.create();
      return path.path;
    }
  }

  Future<File> moveFile(File sourceFile, String newPath) async {
    try {
      // prefer using rename as it is probably faster
      return await sourceFile.rename(newPath);
    } on FileSystemException catch (e) {
      // if rename fails, copy the source file and then delete it
      final newFile = await sourceFile.copy(newPath);
      await sourceFile.delete();
      return newFile;
    }
  }

  List<Widget> listNotFoundAction(
      {contextGobal,
      required int index,
      required PDFModel pdfItem,
      required bool isPublic}) {
    return <Widget>[
      Padding(
        padding: const EdgeInsets.only(bottom: 2.0),
        child: InkWell(
          onTap: () {
            Navigator.of(context, rootNavigator: true).pop();
            if (isPublic) {
              _deleteItemList(index);
            } else {
              _deleteItemPrivateList(index);
            }
          },
          child: Container(
              decoration: BoxDecoration(
                color: Color.fromRGBO(51, 204, 204, 1.0),
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 5,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 25.0),
                child: Text(
                  Language.of(context)!.trans("Delete") ?? "",
                  style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              )),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(left: 5.0, bottom: 2.0, right: 2.0),
        child: InkWell(
          onTap: () =>   Navigator.of(context, rootNavigator: true).pop() , 
          child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.all(Radius.circular(5.0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.6),
                    blurRadius: 5,
                    offset: Offset(1, 2),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 8.0, horizontal: 32.0),
                child: Text(
                  'OK',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
              )),
        ),
      ),
    ];
  }

  Future<void> privateFile(int index) async {
    Flushbar(
      messageText: Text(Language.of(context)!.trans("MadePrivate") ?? "",
          style: TextStyle(color: Colors.white)),
      icon: Icon(Icons.privacy_tip_outlined, color: Colors.lightBlue[50]),
      backgroundColor: Color.fromRGBO(51, 204, 204, 1.0),
      flushbarPosition: FlushbarPosition.TOP,
      duration: Duration(milliseconds: 1700),
    )..show(context);
    await Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext ct, _, __) => LockPage(
        ctx: context,
      ),
    ));
    _deleteItemList(index);
  }

  Future<void> publicFile(int index) async {
    Flushbar(
      messageText: Text(Language.of(context)!.trans("MadePublic") ?? "",
          style: TextStyle(color: Colors.white)),
      icon: Icon(Icons.privacy_tip_outlined, color: Colors.lightBlue[50]),
      backgroundColor: Color.fromRGBO(51, 204, 204, 1.0),
      flushbarPosition: FlushbarPosition.TOP,
      duration: Duration(milliseconds: 1700),
    )..show(context);
    await Navigator.of(context).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext ct, _, __) => LockPage(
        ctx: context,
      ),
    ));
    _deleteItemPrivateList(index);
  }

  Future<void> onClickMenu(
      MenuItemProvider item, int index, DashboardState state) async {
    switch (item.menuTitle) {
      case ' Private':
        setState(() => isAuthen = false);
        break;
      case ' Riêng tư':
        setState(() => isAuthen = false);
        break;
      case 'Contact':
        launch('mailto:tainguyen0897@gmail.com?subject=PDF Editor App');
        break;
      case 'Liên hệ':
        launch('mailto:tainguyen0897@gmail.com?subject=PDF Editor App');
        break;
      case 'Vietnamese':
        changeLanguage();
        break;
      case ' English':
        changeLanguage();
        break;
      default:
        controller.isCompleted ? controller.reverse() : controller.forward();
        bloc.onChangeDay();
        break;
    }
  }

  Future<List<File>> fetchListSuggest({required String? pathFolder}) async {
    List<File> suggestPDFlst = [];
    try {
      if (pathFolder != null) {
        var docassets = Directory(pathFolder)
            .listSync(recursive: false, followLinks: false)
            .where((e) => e is File);
        for (FileSystemEntity asset in docassets) {
          if (asset is File) {
            String name = path.basename(asset.path);
            if (name.endsWith('.pdf') || name.endsWith('.PDF')) {
              File? file = asset.absolute;
              suggestPDFlst.add(file);
            }
          }
        }
      }
      return suggestPDFlst;
    } catch (e) {
      print(fetchListSuggest);
      return suggestPDFlst;
    }
  }

  Future<String?> getDownloadPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download folder path");
    }
    return directory?.path;
  }

  Future<String?> getDownloadZaloPath() async {
    Directory? directory;
    try {
      if (Platform.isIOS) {
        directory = await getApplicationDocumentsDirectory();
      } else {
        directory = Directory('/storage/emulated/0/Download/Zalo');
        // Put file in global download folder, if for an unknown reason it didn't exist, we fallback
        if (!await directory.exists())
          directory = await getExternalStorageDirectory();
      }
    } catch (err, stack) {
      print("Cannot get download zalo folder path");
    }
    return directory?.path;
  }

  void optionMenu(
      GlobalKey<State<StatefulWidget>> btnKey, DashboardState state) {
    PopupMenu menu = PopupMenu(
        context: context,
        config: MenuConfig.forList(
          backgroundColor: Colors.black.withOpacity(0.8),
          lineColor: Colors.black,
          itemWidth: 125,
        ),
        items: [],
        onClickMenu: (item, index) => onClickMenu(item, index, state),
        index: 0,
        isHorizonal: false);
    isAuthen
        ? menu.items = [
            MenuItem.forList(
                title: state.isNight
                    ? Language.of(context)!.trans("Lighttheme") ?? ""
                    : Language.of(context)!.trans("Darktheme") ?? "",
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white),
                image: Image.asset(
                  "assets/day-and-night.png",
                  height: 20,
                )),
            MenuItem.forList(
                title: ' ${Language.of(context)!.trans("private") ?? ""}',
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white),
                image: Image.asset(
                  "assets/folder-2.png",
                  height: 16,
                )),
            MenuItem.forList(
                title: Language.of(context)!.trans("Contact") ?? "",
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white),
                image: Image.asset(
                  "assets/customer-service.png",
                  height: 20,
                )),
            MenuItem.forList(
                title: state.isEnglish ? 'Vietnamese' : ' English',
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white),
                image: Image.asset(
                  state.isEnglish
                      ? 'assets/vietnam.png'
                      : 'assets/united-kingdom.png',
                  height: state.isEnglish ? 23 : 20,
                ))
          ]
        : menu.items = [
            MenuItem.forList(
                title: state.isNight
                    ? Language.of(context)!.trans("Lighttheme") ?? ""
                    : Language.of(context)!.trans("Darktheme") ?? "",
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white),
                image: Image.asset(
                  "assets/day-and-night.png",
                  height: 20,
                )),
            MenuItem.forList(
                title: Language.of(context)!.trans("Contact") ?? "",
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white),
                image: Image.asset(
                  "assets/customer-service.png",
                  height: 22,
                )),
            MenuItem.forList(
                title: state.isEnglish ? 'Vietnamese' : ' English',
                textAlign: TextAlign.center,
                textStyle: TextStyle(color: Colors.white),
                image: Image.asset(
                  state.isEnglish
                      ? 'assets/vietnam.png'
                      : 'assets/united-kingdom.png',
                  height: state.isEnglish ? 23 : 20,
                ))
          ];

    menu.show(widgetKey: btnKey);
  }

  Positioned buildAnimationTime(DashboardState state) {
    return Positioned(
      top: 0,
      left: -20,
      child: AnimatedBuilder(
        animation: _controllerRotateLightDark,
        builder: (_, child) {
          return Transform.rotate(
            angle: _controllerRotateLightDark.value * 2 * math.pi,
            child: child,
          );
        },
        child: Image.asset(
          state.isNight ? "assets/moon.png" : "assets/sun.png",
          height: state.isNight ? 94 : 88,
        ),
      ),
    );
  }

  Widget buildTotalFile(DashboardState state) {
    return Padding(
      padding:
          const EdgeInsets.only(top: 10, bottom: 10, left: 17.0, right: 25.0),
      child: Container(
        height: 85.0,
        child: Row(
          children: [
            Expanded(
                child: StreamBuilder<int>(
                    stream: bloc.streamPublicTotal,
                    builder: (context, snapshot) {
                      var totalPublic = snapshot.data ?? 0;
                      return StreamBuilder<int>(
                          stream: bloc.streamPrivateTotal,
                          builder: (context, snapshot) {
                            var totalPrivate = snapshot.data ?? 0;
                            return StreamBuilder<int>(
                                stream: bloc.streampublicEditCount,
                                builder: (context, snapshot) {
                                  var publicEditCount = snapshot.data ?? 0;
                                  return StreamBuilder<int>(
                                      stream: bloc.streamPrivateEditCount,
                                      builder: (context, snapshot) {
                                        var privateEditCount =
                                            snapshot.data ?? 0;
                                        return isFirst
                                            ? Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Showcase(
                                                  key: _two,
                                                  radius:
                                                      BorderRadius.circular(15),
                                                  titleTextStyle: TextStyle(
                                                      fontSize: 15,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color: Colors.black87),
                                                  descTextStyle: TextStyle(
                                                      fontSize: 12,
                                                      fontWeight:
                                                          FontWeight.normal,
                                                      color: Colors.black54),
                                                  blurValue: 0.1,
                                                  overlayOpacity: 0.3,
                                                  overlayColor: Colors.black
                                                      .withOpacity(0.01),
                                                  title: 'File manager',
                                                  description:
                                                      'This is where the parameters of your files are displayed',
                                                  child: CarouselSlider(
                                                      carouselController:
                                                          carouselController,
                                                      items: [
                                                        buildInfoApp(
                                                            state,
                                                            totalPublic,
                                                            totalPrivate,
                                                            publicEditCount,
                                                            privateEditCount),
                                                        buildImageInfo(state),
                                                      ],
                                                      options: CarouselOptions(
                                                        autoPlayInterval:
                                                            Duration(
                                                                seconds: 15),
                                                        autoPlay: true,
                                                        enableInfiniteScroll:
                                                            true,
                                                        initialPage: 0,
                                                        onPageChanged:
                                                            (index, reason) {
                                                          if (index == 0) {
                                                            bloc.setupTotalData();
                                                          }
                                                        },
                                                        viewportFraction: 1.0,
                                                      )),
                                                ),
                                              )
                                            : CarouselSlider(
                                                carouselController:
                                                    carouselController,
                                                items: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child: buildInfoApp(
                                                        state,
                                                        totalPublic,
                                                        totalPrivate,
                                                        publicEditCount,
                                                        privateEditCount),
                                                  ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            8.0),
                                                    child:
                                                        buildImageInfo(state),
                                                  ),
                                                ],
                                                options: CarouselOptions(
                                                  autoPlayInterval:
                                                      Duration(seconds: 15),
                                                  autoPlay: true,
                                                  enableInfiniteScroll: true,
                                                  initialPage: 0,
                                                  onPageChanged:
                                                      (index, reason) {
                                                    if (index == 0) {
                                                      bloc.setupTotalData();
                                                    }
                                                  },
                                                  viewportFraction: 1.0,
                                                ));
                                      });
                                });
                          });
                    })),
            Showcase(
              key: _three,
              radius: BorderRadius.circular(15),
              titleTextStyle: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87),
              descTextStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black54),
              blurValue: 0.1,
              overlayOpacity: 0.3,
              overlayColor: Colors.black.withOpacity(0.01),
              title: 'Add files',
              onTargetClick: () {
                if (isFirst) {
                  SharedPrefs().setValue<bool>(KeyPrefs.isFirst, false);
                }
                closeSearch();
                addFile(state);
              },
              disposeOnTap: true,
              description: 'Tap to select, add files and enjoy the features',
              child: Padding(
                padding: const EdgeInsets.only(left: 0.0),
                child: AnimatedSize(
                  curve: Curves.bounceInOut,
                  vsync: this,
                  duration: new Duration(milliseconds: 200),
                  child: InkWell(
                    onTap: () {
                      closeSearch();
                      addFile(state);
                    },
                    child: Container(
                        width: tabController.index == 0 ? 62 : 0,
                        height: 70,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(255, 230, 226, 1),
                          borderRadius: BorderRadius.all(Radius.circular(15.0)),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.3),
                              blurRadius: 5,
                              offset: Offset(3, 5),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(15.0),
                          child: Image.asset(
                            "assets/add.png",
                            width: 55,
                          ),
                        )),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  InkWell buildInfoApp(DashboardState state, int totalPublic, int totalPrivate,
      int publicEditCount, int privateEditCount) {
    return InkWell(
      onTap: () => closeSearch(),
      child: Container(
        height: 80,
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
              color: Colors.grey.withOpacity(isFirst ? 0.0 : .3),
              blurRadius: 5,
              offset: Offset(3, 5),
            ),
          ],
        ),
        child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: buildPieChart(state, totalPublic, totalPrivate,
                publicEditCount, privateEditCount)),
      ),
    );
  }

  Container buildImageInfo(DashboardState state) {
    return Container(
      height: 80,
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
            color: Colors.grey.withOpacity(isFirst ? 0.0 : .3),
            blurRadius: 5,
            offset: Offset(3, 5),
          ),
        ],
      ),
      child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(15.0)),
              color: Colors.blue[100],
            ),
            child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(15.0)),
                child: Container(
                  height: 80,
                  width: double.infinity,
                  child: InkWell(
                      onTap: () {
                        closeSearch();
                        state.indexTab == 0 ? addFile(state) : null;
                      },
                      child: futureBuild()),
                )),
          )),
    );
  }

  void addFile(state) {
    customModalBottomSheet(context, isFile: true, isUrl: true, fFile: () async {
      // Close bottomsheet
      Navigator.pop(context);
      var isDownloading = publicCloneList
          .indexWhere((element) => element.isDownloadSuccess == "inprogress");
      if (isDownloading != -1) {
        Flushbar(
          messageText: Text(
              Language.of(context)!.trans("DownloadWarning") ?? "",
              style: TextStyle(color: Colors.white)),
          icon: Icon(Icons.download, color: Colors.yellow[100]),
          backgroundColor: Colors.yellow[600]!,
          flushbarPosition: FlushbarPosition.TOP,
          duration: Duration(milliseconds: 3000),
        )..show(context);
        return;
      }
      // Check permission storage
      androidInfo = await DeviceInfoPlugin().androidInfo;
      var isPermission = await getPermission();
      // Show Dialog

      showDialogAddFile(
          onResult: (data) async {
            var pathFile = data.keys.toString();
            var subLink = pathFile.substring(1, pathFile.length - 1);
            await Future.delayed(Duration(milliseconds: 20));

            int indexItem = publicCloneList
                .indexWhere((element) => element.pathFile == subLink);
            if (indexItem == -1) {
              await addPublicItem(PDFModel(
                  pathFile: subLink,
                  isEdit: false,
                  isNew: true,
                  timeOpen: DateTime.now(),
                  isOpen: false));

              var linkResultFile = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ViewFileMain(
                            isNightMode: state.isNight,
                            isUrl: false,
                            fileKyTen: subLink,
                            isKySo: true,
                            isUseMauChuKy: true,
                            isPublic: tabController.index == 0,
                          )));
              await _updateItem(
                  pdfModel: PDFModel(
                      currentIndex: publicCloneList[0].currentIndex,
                      isNew: true,
                      isEdit: linkResultFile != subLink,
                      isOpen: true,
                      pathFile: linkResultFile,
                      timeOpen: DateTime.now()),
                  index: 0);
            } else {
              _deleteItemList(indexItem);
              addPublicItem(PDFModel(
                  currentIndex: publicCloneList[indexItem].currentIndex,
                  isNew: true,
                  isEdit: publicCloneList[indexItem].isEdit,
                  isOpen: publicCloneList[indexItem].isOpen,
                  pathFile: publicCloneList[indexItem].pathFile,
                  timeOpen: DateTime.now()));
            }
          },
          isPermission: isPermission,
          isNightMode: state.isNight);
    }, fUrl: () {
      Navigator.pop(context);
      var isDownloading = publicCloneList
          .indexWhere((element) => element.isDownloadSuccess == "inprogress");
      if (isDownloading != -1) {
        Flushbar(
          messageText: Text(
              Language.of(context)!.trans("DownloadWarning") ?? "",
              style: TextStyle(color: Colors.white)),
          icon: Icon(Icons.download, color: Colors.yellow[100]),
          backgroundColor: Colors.yellow[600]!,
          flushbarPosition: FlushbarPosition.TOP,
          duration: Duration(milliseconds: 3000),
        )..show(context);
        return;
      }
      showGetLinkDialog(
          ctx: context,
          isRealModalBottom: false,
          title: Language.of(context)!.trans("PickFile") ?? "",
          isDownloadFolder: isDownloadFolder,
          isZalo: isZalo,
          onResult: (url) async {
            var path = url.keys.toString();
            var subLink = path.substring(1, path.length - 1);
            Navigator.pop(context);

            var indexExists = publicCloneList.indexWhere((element) =>
                element.urlLink == subLink && element.isEdit == false);
            if (indexExists == -1) {
              // Add New item model
              await addPublicItem(PDFModel(
                  urlLink: subLink,
                  pathFile: subLink,
                  propress: 0,
                  isEdit: false,
                  isNew: false,
                  timeOpen: DateTime.now(),
                  isDownloadSuccess: "none"));
              await Future.delayed(Duration(milliseconds: 100));
              // Get index for check Exists
              var indexwhere = publicCloneList.indexWhere((element) =>
                  element.urlLink == subLink &&
                  !element.pathFile!.contains("_edit_"));
              if (indexwhere != -1) {
                var linkDownload = await downloadFilePDF(
                    subLink, indexwhere, publicCloneList[indexwhere]);
                // Update final pathFile: linkDownload
                _updateItem(
                    pdfModel: PDFModel(
                      status: linkDownload != null ? "ready" : "none",
                      isDownloadSuccess: linkDownload != null ? "true" : "fail",
                      pathFile: linkDownload != null ? linkDownload : subLink,
                      isEdit: false,
                      urlLink: subLink,
                      isNew: linkDownload != null ? true : false,
                      timeOpen: publicCloneList[indexwhere].timeOpen,
                    ),
                    index: indexwhere);
                await bloc.setupTotalData();
                carouselController.nextPage();
              } else {
                Flushbar(
                  messageText: Text(
                      Language.of(context)!.trans("DownloadFailed") ?? "",
                      style: TextStyle(color: Colors.white)),
                  icon: Icon(Icons.warning, color: Colors.red[100]),
                  backgroundColor: Colors.red,
                  flushbarPosition: FlushbarPosition.TOP,
                  duration: Duration(milliseconds: 3000),
                )..show(context);
              }
            } else {
              Flushbar(
                messageText: Text(
                    Language.of(context)!.trans("FileExist") ?? "",
                    style: TextStyle(color: Colors.white)),
                icon: Icon(Icons.warning_amber_rounded,
                    color: Colors.yellowAccent[100]),
                backgroundColor: Colors.yellow[700]!,
                flushbarPosition: FlushbarPosition.TOP,
                duration: Duration(milliseconds: 3000),
              )..show(context);
            }
          });
    });
  }

  Future<String?> downloadFilePDF(
      String link, int index, PDFModel pdfModel) async {
    try {
      // Flushbar(
      //   messageText: Text(
      //       "File is downloading, please wait for the process to complete!",
      //       style: TextStyle(color: Colors.white)),
      //   icon: Icon(Icons.download, color: Colors.green[100]),
      //   backgroundColor: Colors.green,
      //   flushbarPosition: FlushbarPosition.TOP,
      //   duration: Duration(milliseconds: 3000),
      // )..show(context);
      if (dir == "") dir = (await getApplicationDocumentsDirectory()).path;
      final filename = link.substring(link.lastIndexOf("/") + 1);
      pdfBox.putAt(
          index,
          PDFModel(
              currentIndex: pdfModel.currentIndex,
              isEdit: pdfModel.isEdit,
              isOpen: pdfModel.isOpen,
              pathFile: pdfModel.pathFile,
              isDownloadSuccess: "inprogress",
              propress: 0,
              timeOpen: pdfModel.timeOpen,
              urlLink: pdfModel.urlLink));
      Response response = await dio.download(link, '$dir/$filename',
          options: Options(
            responseType: ResponseType.bytes,
            followRedirects: false,
            receiveDataWhenStatusError: true,
            // receiveTimeout: 100 * 1000,
            // sendTimeout: 100 * 1000
          ) // 100 seconds
          , onReceiveProgress: (count, total) async {
        var indexWhere = publicCloneList.indexWhere((element) =>
            element.pathFile == pdfModel.pathFile &&
            element.timeOpen == pdfModel.timeOpen &&
            element.urlLink == pdfModel.urlLink &&
            element.currentIndex == pdfModel.currentIndex);
        await pdfBox.putAt(
            indexWhere,
            PDFModel(
                currentIndex: pdfModel.currentIndex,
                isEdit: pdfModel.isEdit,
                isOpen: pdfModel.isOpen,
                pathFile: pdfModel.pathFile,
                isNew: false,
                isDownloadSuccess: "inprogress",
                propress: (count / total) * 100,
                timeOpen: pdfModel.timeOpen,
                urlLink: pdfModel.urlLink));
      });
      if (response.statusCode != 404) {
        var indexWhere = publicCloneList.indexWhere((element) =>
            element.pathFile == pdfModel.pathFile &&
            element.timeOpen == pdfModel.timeOpen &&
            element.urlLink == pdfModel.urlLink);
        await pdfBox.putAt(
            indexWhere,
            PDFModel(
                currentIndex: pdfModel.currentIndex,
                isEdit: pdfModel.isEdit,
                isOpen: pdfModel.isOpen,
                pathFile: pdfModel.pathFile,
                isDownloadSuccess: "success",
                status: "true",
                isNew: true,
                propress: 100,
                timeOpen: pdfModel.timeOpen,
                urlLink: pdfModel.urlLink));
        if (lifecycleState == AppLifecycleState.resumed) {
          Vibration.vibrate(pattern: [50, 200, 50, 200]);
          Flushbar(
            title:
                "$filename ${Language.of(context)!.trans("Downloaded") ?? ""}",
            flushbarStyle: FlushbarStyle.FLOATING,
            messageText: Text(Language.of(context)!.trans("AllReady") ?? "",
                style: TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.normal)),
            icon: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(15.0))),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(5.0),
                  child: Image.asset(
                    'assets/icon_notification.png',
                    width: 20,
                  ),
                ),
              ),
            ),
            titleColor: Colors.grey[350],
            backgroundColor: Colors.black.withOpacity(0.8),
            flushbarPosition: FlushbarPosition.TOP,
            barBlur: 1.0,
            margin: EdgeInsets.all(8),
            borderRadius: BorderRadius.circular(15),
            duration: Duration(milliseconds: 3000),
          )..show(context);
        } else {
          NoticationService.showBigTextNotification(
              title:
                  "$filename ${Language.of(context)!.trans("Downloaded") ?? ""}",
              body: Language.of(context)!.trans("AllReady") ?? "",
              fln: flutterLocalNotificationsPlugin);
        }
        return '$dir/$filename';
      } else {
        var indexWhere = publicCloneList.indexWhere((element) =>
            element.pathFile == pdfModel.pathFile &&
            element.timeOpen == pdfModel.timeOpen &&
            element.urlLink == pdfModel.urlLink);
        await pushFailCase(indexWhere, pdfModel);
        pushFailCaseFlusbar();
        return null;
      }
    } catch (e) {
      var indexWhere = publicCloneList.indexWhere((element) =>
          element.pathFile == pdfModel.pathFile &&
          element.timeOpen == pdfModel.timeOpen &&
          element.urlLink == pdfModel.urlLink);
      await pushFailCase(indexWhere, pdfModel);
      pushFailCaseFlusbar();
      return null;
    }
  }

  void pushFailCaseFlusbar() {
    Flushbar(
      messageText: Text(Language.of(context)!.trans("DownloadFailed") ?? "",
          style: TextStyle(color: Colors.white)),
      icon: Icon(Icons.close, color: Colors.red[100]),
      backgroundColor: Colors.red,
      flushbarPosition: FlushbarPosition.TOP,
      duration: Duration(milliseconds: 3000),
    )..show(context);
  }

  Future<void> pushFailCase(int index, PDFModel pdfModel) async {
    await pdfBox.putAt(
        index,
        PDFModel(
            currentIndex: pdfModel.currentIndex,
            isEdit: pdfModel.isEdit,
            isOpen: pdfModel.isOpen,
            pathFile: pdfModel.pathFile,
            isDownloadSuccess: "fail",
            propress: 50,
            timeOpen: pdfModel.timeOpen,
            urlLink: pdfModel.urlLink));
  }

  Row futureBuild() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Image.asset(
              'assets/pdf_header.png',
              fit: BoxFit.cover,
              width: 45,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 10.0, bottom: 6.0),
              child: Container(
                  color: Color.fromRGBO(243, 234, 230, 1),
                  child: Image.asset(
                    'assets/pencil-3.png',
                    fit: BoxFit.cover,
                    width: 23,
                  )),
            )
          ],
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Image.asset(
                'assets/pdf_header.png',
                fit: BoxFit.cover,
                width: 45,
              ),
              Padding(
                padding: const EdgeInsets.only(right: 7.0, bottom: 5.0),
                child: Container(
                    color: Color.fromRGBO(243, 234, 230, 1),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 4, right: 5),
                      child: Image.asset(
                        'assets/add_image.png',
                        fit: BoxFit.cover,
                        width: 20,
                      ),
                    )),
              )
            ],
          ),
        ),
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Image.asset(
              'assets/pdf_header.png',
              fit: BoxFit.cover,
              width: 45,
            ),
            Padding(
              padding: const EdgeInsets.only(right: 12.0, bottom: 6.0),
              child: Container(
                  color: Color.fromRGBO(243, 234, 230, 1),
                  child: Image.asset(
                    'assets/tools.png',
                    fit: BoxFit.cover,
                    width: 20,
                  )),
            )
          ],
        ),
      ],
    );
  }

  Future<bool> getPermission() async {
    sdkInt = androidInfo.version.sdkInt ?? 0;
    if (Platform.isAndroid) {
      if (sdkInt >= 30) {
        if (countPermis == null || countPermis == 0) {
          if (await Permission.manageExternalStorage.isGranted) {
            return true;
          } else {
            var permission = await Permission.manageExternalStorage.request();
            await conutPermissBox.put('count', 1);
            if (permission.isGranted) {
              return true;
            } else {
              return false;
            }
          }
        } else {
          return await Permission.manageExternalStorage.isGranted;
        }
      } else {
        if (countPermis == null || countPermis == 0) {
          if (await Permission.storage.isGranted) {
            return true;
          } else {
            var permission = await Permission.storage.request();
            await conutPermissBox.put('count', 1);
            if (permission.isGranted) {
              return true;
            } else {
              return false;
            }
          }
        } else {
          return await Permission.manageExternalStorage.isGranted;
        }
      }
    } else {
      return false;
    }
  }

  void showDialogAddFile(
      {Function(Map<String, String>)? onResult,
      required bool isPermission,
      required bool isNightMode}) async {
    List<Map<String, String>> listMap = [];
    List<File> suggestList = [];
    if (isPermission) {
      var rootDownloadPath = await getDownloadPath();
      var downloadList = await fetchListSuggest(pathFolder: rootDownloadPath);
      ///////
      var rootZaloPath = await getDownloadZaloPath();
      var zaloList = await fetchListSuggest(pathFolder: rootZaloPath);
      ///////
      suggestList = new List.from(downloadList)..addAll(zaloList);
      await addSuggestList(listChucNang: suggestList)
          .then((value) => listMap = value);
      isZalo = false;
      isDownloadFolder = false;
      for (var item in suggestList) {
        if (item.path != "" && item.path.contains("/Zalo")) {
          isZalo = true;
        } else if (item.path != "" && item.path.contains("/Download")) {
          isDownloadFolder = true;
        }
      }
    }

    showDialogAddFilePickerCustom(
        ctx: context,
        isRealModalBottom: false,
        listData: listMap,
        title: "Pick File",
        onResult: onResult,
        isDownloadFolder: isDownloadFolder,
        isZalo: isZalo,
        isAccess: isPermission,
        isNightMode: isNightMode,
        isWarning: countPermis == null || countPermis == 0 ? true : false);

    countPermis = conutPermissBox.get('count');
  }

  Future<List<Map<String, String>>> addSuggestList(
      {List<File>? listChucNang}) async {
    List<Map<String, String>> listMapNew = [];
    if (listChucNang!.length > 0) {
      listMapNew.clear();
      for (int i = 0; i < listChucNang.length; i++) {
        listMapNew
            .add({listChucNang[i].path: listChucNang[i].path.split("/").last});
      }
    }
    return listMapNew;
  }

  void showDialogAddFilePickerCustom(
      {List<Map<String, String>>? listData,
      String? title,
      BuildContext? ctx,
      bool? isRealModalBottom,
      List<String>? imageList,
      required bool isDownloadFolder,
      required bool isZalo,
      required bool isAccess,
      required bool isNightMode,
      required bool isWarning,
      Function(Map<String, String>)? onResult}) {
    Navigator.of(ctx!).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext ct, _, __) => PopUpListPicker(
        isCenter: true,
        listData: listData,
        title: title,
        ctx: ctx,
        onResult: onResult,
        imageList: imageList,
        isDownloadFolder: isDownloadFolder,
        isZalo: isZalo,
        onRequsetPermis: () async {
          if (sdkInt >= 30) {
            var isPermis = await Permission.manageExternalStorage.request();
            if (isPermis.isGranted) {
              Navigator.pop(context);
              // Check permission storage
              isPermission = await getPermission();
              // Show Dialog

              showDialogAddFile(
                  onResult: (data) async {
                    var pathFile = data.keys.toString();
                    var subLink = pathFile.substring(1, pathFile.length - 1);
                    await Future.delayed(Duration(milliseconds: 20));
                    var linkResultFile = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewFileMain(
                                isNightMode: isNightMode,
                                isUrl: false,
                                fileKyTen: subLink,
                                isKySo: true,
                                isUseMauChuKy: true,
                                isPublic: tabController.index == 0,
                              )),
                    );
                    addPublicItem(PDFModel(
                      isEdit: false,
                      pathFile: linkResultFile,
                      timeOpen: DateTime.now(),
                    ));
                  },
                  isPermission: isPermission,
                  isNightMode: isNightMode);
            } else {
              if (sdkInt >= 30) {
                WidgetsBinding.instance!.addPostFrameCallback((_) => Flushbar(
                      messageText: Text(
                          Language.of(context)!.trans("ExternalDenied") ?? "",
                          style: TextStyle(color: Colors.white)),
                      icon: Icon(Icons.warning_amber_rounded,
                          color: Colors.yellowAccent[100]),
                      backgroundColor: Colors.yellow[700]!,
                      flushbarPosition: FlushbarPosition.TOP,
                      duration: Duration(seconds: 3),
                    )..show(context));
              }
            }
          } else {
            if (await Permission.storage.isGranted) {
              Navigator.pop(context);
              var permission = await Permission.storage.request();
              showDialogAddFile(
                  onResult: (data) async {
                    var pathFile = data.keys.toString();
                    var subLink = pathFile.substring(1, pathFile.length - 1);
                    await Future.delayed(Duration(milliseconds: 20));
                    var linkResultFile = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewFileMain(
                                isNightMode: isNightMode,
                                isUrl: false,
                                fileKyTen: subLink,
                                isKySo: true,
                                isUseMauChuKy: true,
                                isPublic: tabController.index == 0,
                              )),
                    );
                    addPublicItem(PDFModel(
                      isEdit: false,
                      pathFile: linkResultFile,
                      timeOpen: DateTime.now(),
                    ));
                  },
                  isPermission: permission.isGranted,
                  isNightMode: isNightMode);
            } else {
              Navigator.pop(context);
              var permission = await Permission.storage.request();
              showDialogAddFile(
                  onResult: (data) async {
                    var pathFile = data.keys.toString();
                    var subLink = pathFile.substring(1, pathFile.length - 1);
                    await Future.delayed(Duration(milliseconds: 20));
                    var linkResultFile = await Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ViewFileMain(
                                isNightMode: isNightMode,
                                isUrl: false,
                                fileKyTen: subLink,
                                isKySo: true,
                                isUseMauChuKy: true,
                                isPublic: tabController.index == 0,
                              )),
                    );
                    addPublicItem(PDFModel(
                      isEdit: false,
                      pathFile: linkResultFile,
                      timeOpen: DateTime.now(),
                    ));
                  },
                  isPermission: permission.isGranted,
                  isNightMode: isNightMode);
            }
          }
        },
        isAccess: isAccess,
        isWarning: isWarning,
        isRequestAllFile: sdkInt >= 30,
        // 30 is android 11
      ),
    ));
  }

  void showGetLinkDialog(
      {List<Map<String, String>>? listData,
      String? title,
      BuildContext? ctx,
      bool? isRealModalBottom,
      List<String>? imageList,
      required bool isDownloadFolder,
      required bool isZalo,
      Function(Map<String, String>)? onResult}) {
    Navigator.of(ctx!).push(PageRouteBuilder(
      opaque: false,
      pageBuilder: (BuildContext ct, _, __) => PopUpLinkPicker(
        isCenter: true,
        title: title,
        ctx: ctx,
        onResult: onResult,
      ),
    ));
  }

  Future<void> showMediaSelection({
    required BuildContext context,
    required int index,
    MediaLoaiChucNangDinhKem? loaiChucNangDinhKem,
  }) async {
    ImagePicker picker = ImagePicker();
    switch (loaiChucNangDinhKem!) {
      case MediaLoaiChucNangDinhKem.Camera:
        PickedFile? pickedFile =
            await picker.getImage(source: ImageSource.camera);
        pathFile = pickedFile?.path ?? '';
        Navigator.pop(context);
        break;
      case MediaLoaiChucNangDinhKem.Album:
        PickedFile? pickedFile =
            await picker.getImage(source: ImageSource.gallery);
        pathFile = pickedFile?.path ?? '';
        Navigator.pop(context);
        break;
      case MediaLoaiChucNangDinhKem.File:
        FilePickerResult? file = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: ['pdf'],
          allowMultiple: false,
        );
        pathFile = file?.paths.first ?? "";
        Navigator.pop(context);
        break;
      case MediaLoaiChucNangDinhKem.Video:
        break;
    }
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

  ListView buildListViewPrivate(
      List<dynamic> privateList, DashboardState state) {
    return ListView.builder(
      padding: EdgeInsets.all(0),
      itemCount: privateList.length,
      itemBuilder: (BuildContext context, int index) {
        final pdfItem = privateList[index];
        privateCloneList[index].currentIndex = index;
        return InkWell(
          onTap: () async {
            closeSearch();
            // Slidable.of(context)?.close();
            var linkResult = await Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ViewFileMain(
                        isNightMode: state.isNight,
                        fileKyTen: pdfItem.pathFile ?? '',
                        isKySo: true,
                        isUseMauChuKy: true,
                        isPublic: tabController.index == 0,
                      )),
            );
            await _updatePrivateItem(
                pdfModel: PDFModel(
                    pathFile: linkResult,
                    urlLink: pdfItem.urlLink,
                    currentIndex: pdfItem.currentIndex,
                    timeOpen: DateTime.now(),
                    isOpen: pdfItem.isOpen,
                    isEdit: pdfItem.isEdit == false
                        ? linkResult == pdfItem.pathFile
                            ? false
                            : true
                        : pdfItem.isEdit ?? false),
                index: index);
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
                          onPressed: (context) async {
                            closeSearch();
                            // Slidable.of(context)?.close();
                            await ShareExtend.share(
                                pdfItem.pathFile ?? '', "file");
                          },
                          backgroundColor: Color.fromRGBO(151, 116, 247, 1.0),
                          foregroundColor: Colors.white,
                          icon: Icons.share,
                          spacing: 5,
                          padding: EdgeInsets.all(0),
                          label: Language.of(context)!.trans("share") ?? "",
                        ),
                        SlidableAction(
                          flex: 1,
                          autoClose: true,
                          onPressed: (context) {
                            closeSearch();
                            // Slidable.of(context)?.close();
                            buildPrivateDialog(index, pdfItem.currentIndex ?? 0,
                                pdfItem, false, false);
                          },
                          backgroundColor: Color.fromRGBO(134, 88, 249, 1.0),
                          foregroundColor: Colors.white,
                          icon: Icons.people_alt_outlined,
                          spacing: 5,
                          padding: EdgeInsets.all(0),
                          label: Language.of(context)!.trans("public") ?? "",
                        ),
                        SlidableAction(
                          flex: 1,
                          autoClose: true,
                          onPressed: (context) {
                            closeSearch();
                            // Slidable.of(context)?.close();
                            buildRemoveDialog(index, pdfItem.currentIndex ?? 0,
                                pdfItem, false, false);
                          },
                          backgroundColor: Color(0xFFFE4A49),
                          foregroundColor: Colors.white,
                          icon: Icons.delete,
                          spacing: 5,
                          padding: EdgeInsets.all(0),
                          label: Language.of(context)!.trans("Delete") ?? "",
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
                                          Color.fromRGBO(255, 109, 255, 0.86),
                                        ],
                                        begin: const FractionalOffset(0.0, 0.0),
                                        end: const FractionalOffset(0.2, 0.9),
                                        stops: [0.0, 0.5, 0.75, 1.0],
                                        tileMode: TileMode.clamp),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                    boxShadow: [
                                      BoxShadow(
                                          color:
                                              Color.fromRGBO(249, 95, 254, 0.2),
                                          blurRadius: 2,
                                          offset: Offset(1, 1))
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5.0)),
                                    child: BackdropFilter(
                                      child: Stack(
                                        alignment: Alignment.bottomRight,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.all(5.0),
                                            child: Image.asset(
                                              "assets/file-format.png",
                                              height: 50,
                                            ),
                                          ),
                                          pdfItem.isEdit ?? false
                                              ? Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                          right: 2.0,
                                                          bottom: 9.0),
                                                  child: Container(
                                                      color: Colors.blue[400],
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                    .symmetric(
                                                                horizontal: 0.8,
                                                                vertical: 1.0),
                                                        child: Text(
                                                            Language.of(context)!
                                                                    .trans(
                                                                        "Edited") ??
                                                                "",
                                                            style: TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                                fontSize: 6.8)),
                                                      )),
                                                )
                                              : SizedBox(),
                                        ],
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
                                      pdfItem.pathFile?.split("/").last ?? '',
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: TextStyle(color: Colors.black)),
                                ),
                                Text(
                                  FormatDateAndTime
                                      .convertDatetoStringWithFormat(
                                          pdfItem.timeOpen ?? DateTime.now(),
                                          ' dd/MM/yyyy'),
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
                                  isFirstSlide = true;
                                  Slidable.of(ctx)?.animation.isCompleted ==
                                          true
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
      },
    );
  }

  Widget buildListPrivateSearch(
      List<dynamic> privateList, DashboardState state) {
    return privateList.length != 0
        ? ListView.builder(
            padding: EdgeInsets.all(0),
            itemCount: privateList.length,
            itemBuilder: (BuildContext context, int index) {
              final pdfItem = privateList[index];
              return InkWell(
                onTap: () async {
                  closeSearch();
                  // Slidable.of(context)?.close();
                  bool isExists = await File(pdfItem.pathFile ?? '').exists();
                  if (!isExists) {
                    buildNotFoundDialog(index, pdfItem, true);
                    return;
                  }
                  var linkResult = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ViewFileMain(
                              isNightMode: state.isNight,
                              fileKyTen: pdfItem.pathFile ?? '',
                              isKySo: true,
                              isUseMauChuKy: true,
                              isPublic: tabController.index == 0,
                            )),
                  );

                  setState(() => privateSearchCurrentList[index] = PDFModel(
                      pathFile: linkResult,
                      timeOpen: DateTime.now(),
                      isOpen: pdfItem.isOpen,
                      urlLink: pdfItem.urlLink,
                      isEdit: pdfItem.isEdit == false
                          ? linkResult == pdfItem.pathFile
                              ? false
                              : true
                          : pdfItem.isEdit ?? false,
                      currentIndex:
                          privateSearchCurrentList[index].currentIndex));
                  _updatePrivateItem(
                      pdfModel: PDFModel(
                        pathFile: linkResult,
                        urlLink: pdfItem.urlLink,
                        timeOpen: DateTime.now(),
                        isEdit: pdfItem.isEdit == false
                            ? linkResult == pdfItem.pathFile
                                ? false
                                : true
                            : pdfItem.isEdit ?? false,
                        isOpen: pdfItem.isOpen,
                      ),
                      index: privateSearchCurrentList[index].currentIndex ?? 0);
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
                                onPressed: (context) async {
                                  closeSearch();
                                  // Slidable.of(context)?.close();
                                  await ShareExtend.share(
                                      pdfItem.pathFile ?? '', "file");
                                },
                                backgroundColor:
                                    Color.fromRGBO(151, 116, 247, 1.0),
                                foregroundColor: Colors.white,
                                icon: Icons.share,
                                spacing: 5,
                                padding: EdgeInsets.all(0),
                                label:
                                    Language.of(context)!.trans("share") ?? "",
                              ),
                              SlidableAction(
                                flex: 1,
                                autoClose: true,
                                onPressed: (context) {
                                  closeSearch();
                                  // Slidable.of(context)?.close();
                                  buildPrivateDialog(
                                      index,
                                      pdfItem.currentIndex ?? 0,
                                      pdfItem,
                                      false,
                                      true);
                                },
                                backgroundColor:
                                    Color.fromRGBO(134, 88, 249, 1.0),
                                foregroundColor: Colors.white,
                                icon: Icons.people_alt_outlined,
                                spacing: 5,
                                padding: EdgeInsets.all(0),
                                label:
                                    Language.of(context)!.trans("public") ?? "",
                              ),
                              SlidableAction(
                                flex: 1,
                                autoClose: true,
                                onPressed: (context) {
                                  closeSearch();
                                  // Slidable.of(context)?.close();

                                  buildRemoveDialog(pdfItem.currentIndex ?? 0,
                                      index, pdfItem, false, true);
                                },
                                backgroundColor: Color(0xFFFE4A49),
                                foregroundColor: Colors.white,
                                icon: Icons.delete,
                                spacing: 5,
                                padding: EdgeInsets.all(0),
                                label:
                                    Language.of(context)!.trans("Delete") ?? "",
                              ),
                            ],
                          ),
                          child: Builder(builder: (ctx) {
                            return Container(
                              height: 57,
                              decoration: BoxDecoration(
                                color: state.isNight
                                    ? Colors.grey[100]
                                    : Colors.white,
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
                                    padding: const EdgeInsets.only(
                                        left: 5, right: 7),
                                    child: Container(
                                        height: 40,
                                        width: 40,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                              colors: [
                                                Color.fromRGBO(
                                                    251, 173, 254, 0.5),
                                                Color.fromRGBO(
                                                    250, 157, 254, 0.75),
                                                Color.fromRGBO(
                                                    250, 127, 253, 0.85),
                                                Color.fromRGBO(
                                                    255, 109, 255, 0.86),
                                              ],
                                              begin: const FractionalOffset(
                                                  0.0, 0.0),
                                              end: const FractionalOffset(
                                                  0.2, 0.9),
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
                                            child: Stack(
                                                alignment:
                                                    Alignment.bottomRight,
                                                children: [
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            5.0),
                                                    child: Image.asset(
                                                      "assets/file-format.png",
                                                      height: 50,
                                                    ),
                                                  ),
                                                  pdfItem.isEdit ?? false
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                      .only(
                                                                  right: 2.0,
                                                                  bottom: 9.0),
                                                          child: Container(
                                                              color: Colors
                                                                  .blue[400],
                                                              child: Padding(
                                                                padding: const EdgeInsets
                                                                        .symmetric(
                                                                    horizontal:
                                                                        0.8,
                                                                    vertical:
                                                                        1.0),
                                                                child: Text(
                                                                    Language.of(context)!.trans(
                                                                            "Edited") ??
                                                                        "",
                                                                    style: TextStyle(
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .bold,
                                                                        color: Colors
                                                                            .white,
                                                                        fontSize:
                                                                            6.8)),
                                                              )),
                                                        )
                                                      : SizedBox(),
                                                ]),
                                            filter: ImageFilter.blur(
                                                sigmaX: 0.5, sigmaY: 0.5),
                                          ),
                                        )),
                                  ),
                                  Expanded(
                                      child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 2.0),
                                        child: Text(
                                            pdfItem.pathFile?.split("/").last ??
                                                '' ??
                                                '',
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                            style:
                                                TextStyle(color: Colors.black)),
                                      ),
                                      Text(
                                        FormatDateAndTime
                                            .convertDatetoStringWithFormat(
                                                pdfItem.timeOpen ??
                                                    DateTime.now(),
                                                ' dd/MM/yyyy'),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style:
                                            TextStyle(color: Colors.grey[600]),
                                      )
                                    ],
                                  )),
                                  IconButton(
                                      splashColor: Colors.transparent,
                                      highlightColor: Colors.transparent,
                                      onPressed: () {
                                        isFirstSlide = true;
                                        Slidable.of(ctx)
                                                    ?.animation
                                                    .isCompleted ==
                                                true
                                            ? Slidable.of(ctx)?.close()
                                            : Slidable.of(ctx)
                                                ?.openEndActionPane();
                                      },
                                      icon: Icon(Icons.more_horiz_rounded,
                                          size: 20))
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
            },
          )
        : buildEmptyPublish();
  }

  Widget buildPieChart(DashboardState state, int totalPublic, int totalPrivate,
      int publicEditCount, int privateEditCount) {
    return Row(
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
                    padding: const EdgeInsets.only(top: 7.0, right: 3.0),
                    child: Image.asset(
                      "assets/document-reader.png",
                      height: 24,
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
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0, top: 2),
                        child: Text(
                          tabController.index == 0
                              ? totalPublic == 1
                                  ? '$totalPublic ${Language.of(context)!.trans("file")}'
                                  : '$totalPublic ${Language.of(context)!.trans("files")}'
                              : isAuthen
                                  ? totalPrivate == 1
                                      ? '$totalPrivate private file'
                                      : '$totalPrivate private files'
                                  : Language.of(context)!
                                          .trans("Privatefiles") ??
                                      "",
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color.fromRGBO(118, 71, 248, 1.0)),
                        ),
                      ),
                      Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 1.0),
                          child: Text(
                            tabController.index == 0
                                ? publicEditCount == 1
                                    ? '($publicEditCount ${Language.of(context)!.trans("editFile")}: ${state.totalSizePublic} MB)'
                                    : '($publicEditCount ${Language.of(context)!.trans("editFiles")}: ${state.totalSizePublic} MB)'
                                : isAuthen
                                    ? privateEditCount == 1
                                        ? '($privateEditCount ${Language.of(context)!.trans("editFile")}: ${state.totalSizePrivate} MB)'
                                        : '($privateEditCount ${Language.of(context)!.trans("editFiles")}: ${state.totalSizePrivate} MB)'
                                    : '${Language.of(context)!.trans("Freespace")}',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.grey[400]),
                          ))
                    ],
                  ),
                ),
                // Spacer(),
              ],
            ),
            Padding(
              padding: EdgeInsets.only(top: 2),
              child: new LinearPercentIndicator(
                animation: true,
                lineHeight: 09.8,
                animationDuration: 250,
                addAutomaticKeepAlive: true,
                barRadius: Radius.circular(3),
                percent: state.percent,
                linearStrokeCap: LinearStrokeCap.roundAll,
                progressColor: Colors.green,
                center: Padding(
                  padding: const EdgeInsets.only(bottom: 1),
                  child: Text(
                    "${Language.of(context)!.trans("phoneStorage") ?? ''} ${(state.percent * 100).toStringAsFixed(1)}%)",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 7.8,
                        fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ),
          ],
        ))
      ],
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
                    ? buttonTabbar(
                        title: Language.of(context)!.trans("recent") ?? '')
                    : InkWell(
                        onTap: () async {
                          closeSearch();
                          setState(() => tabController.index = 0);
                          bloc.emitIndex(0);
                          await bloc.setupTotalData();
                          carouselController.nextPage();
                        },
                        child: SizedBox(
                          height: 45,
                          width: (screenWidth - 50) / 2,
                          child: Center(
                            child: Text(
                                Language.of(context)!.trans("recent") ?? '',
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
                    ? buttonTabbar(
                        title: Language.of(context)!.trans("private") ?? '')
                    : SizedBox(
                        height: 45,
                        child: InkWell(
                          onTap: () {
                            closeSearch();
                            setState(() => tabController.index = 1);
                            bloc.emitIndex(1);
                          },
                          child: Center(
                            child: Text(
                              Language.of(context)!.trans("private") ?? '',
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
      onTap: () async {
        closeSearch();
        if (tabController.index == 0) {
          setState(() => tabController.index = title == 'Private' ? 1 : 0);
        }
        await bloc.setupTotalData();
        carouselController.nextPage();
      },
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

// extension StringExtension on String {
//   String capitalize() {
//     return "${this[0].toUpperCase()}${this.substring(1).toLowerCase()}";
//   }
// }
