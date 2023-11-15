import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared/page_title_widget.dart';
import 'package:shared/queue/list.dart';
import 'package:shared/queue/notifier.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/queue/shop_queue.dart';
import 'package:shared/custom_app_bar.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/theme/notifier.dart';
import 'package:shared/theme/editor.dart';
import 'qr_screen.dart';
import 'add_queue.dart';
import 'edit_queue.dart';
import 'settings_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => QueueNotifier(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ServerUrlNotifier(),
        ),
        ChangeNotifierProvider(create: (ctx) => AppThemeNotifier()),
      ],
      child: Consumer<AppThemeNotifier>(builder: (context, model, child) {
        return MaterialApp(
          theme: model.theme.theme,
          routes: {
            '/': (ctx) => const BottomNavBar(),
            '/editor': (ctx) => const EditQueueScreen(),
            '/qr': (ctx) => const QRScreen(),
            '/theme-editor': (ctx) => const ThemeSwitcherScreen(),
          },
        );
      }),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageTitleWidget(title: "Services"),
        Expanded(
          child: QueueBuilder(
            // Todo: Responsive sizing in wide screens
            builder: (ShopQueue queue) => QueueItem(
                data: queue,
                onTap: () {
                  Provider.of<QueueNotifier>(context, listen: false).queue =
                      queue;
                  Navigator.pushNamed(context, "/editor");
                }),
          ),
        ),
      ],
    );
  }
}

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar>
    with SingleTickerProviderStateMixin {
  int _tabIndex = 0;
  int get tabIndex => _tabIndex;
  set tabIndex(int v) {
    setState(() {
      _tabIndex = v;
    });
  }

  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _tabIndex);
    // When server url changes, update the theme
    AppThemeNotifier.of(context, listen: false).fetch(context);
    Provider.of<ServerUrlNotifier>(context, listen: false).addListener(
        () => AppThemeNotifier.of(context, listen: false).fetch(context));
  }

  Icon icon(IconData iconData, bool isActive) {
    return Icon(
      iconData,
      color: isActive ? Surface.fg(context) : SurfaceVariant.fg(context),
      size: 35,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        height: 125,
        title: "Line-Up Guru | Admin",
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (v) {
          tabIndex = v;
        },
        children: const [
          HomePage(),
          QRServerScreen(),
          SettingsPage(),
        ],
      ),
      floatingActionButton: _tabIndex != 0 ? null : const AddQueueBtn(),
      bottomNavigationBar: CircleNavBar(
        activeIcons: [
          icon(Icons.home_outlined, true),
          icon(Icons.qr_code_sharp, true),
          icon(Icons.settings_outlined, true),
        ],
        inactiveIcons: [
          icon(Icons.home_outlined, false),
          icon(Icons.qr_code_sharp, false),
          icon(Icons.settings_outlined, false),
        ],
        color: SurfaceVariant.bg(context),
        circleColor: Surface.bg(context),
        circleShadowColor: Surface.fg(context),
        shadowColor: Surface.fg(context),
        elevation: 10,
        height: 90,
        circleWidth: 70,
        activeIndex: tabIndex,
        onTap: (index) {
          tabIndex = index;
          pageController.jumpToPage(tabIndex);
        },
        cornerRadius: const BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
    );
  }
}
