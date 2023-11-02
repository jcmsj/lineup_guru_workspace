import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared/page_title_widget.dart';
import 'package:shared/queue_list.dart';
import 'package:shared/queue_notifier.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/shop_queue.dart';
import 'package:shared/custom_app_bar.dart';
import 'package:shared/theme_switcher_screen.dart';
import 'qr_screen.dart';
import 'queue_list.dart';
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
        ChangeNotifierProvider(create: (ctx) => ThemeNotifier()),
      ],
      child: Consumer<ThemeNotifier>(builder: (context, theme, child) {
        return MaterialApp(
          theme: theme.theme,
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

  // TODO make all these configurable
  ThemeData customTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color.fromARGB(255, 255, 189, 89),
        surface: const Color.fromARGB(255, 64, 55, 52),
        onSurface: Colors.white,
        background: const Color.fromARGB(255, 255, 247, 207),
        brightness: Brightness.light,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color.fromARGB(255, 255, 235, 150),
        foregroundColor: Colors.black,
      ),
      primaryColor: const Color.fromARGB(255, 255, 189, 89),
      useMaterial3: true,
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
            builder: (ShopQueue queue) => QueueItem(data: queue),
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
          Icon(Icons.home_outlined,
              color: Theme.of(context).colorScheme.onInverseSurface, size: 35),
          Icon(Icons.qr_code_sharp,
              color: Theme.of(context).colorScheme.onInverseSurface, size: 35),
          Icon(Icons.settings_outlined,
              color: Theme.of(context).colorScheme.onInverseSurface, size: 35),
        ],
        inactiveIcons: const [
          Icon(Icons.home_outlined, size: 35),
          Icon(Icons.qr_code_sharp, size: 35),
          Icon(Icons.settings_outlined, size: 35),
        ],
        color: Theme.of(context).colorScheme.primaryContainer,
        circleColor: Theme.of(context).colorScheme.onBackground,
        circleShadowColor: Theme.of(context).colorScheme.onSurface,
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
