import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:lineup_guru_app/queue_list.dart';
import 'package:shared/page_title_widget.dart';
import 'package:shared/queue_list.dart';
import 'package:shared/queue_notifier.dart';
import 'package:provider/provider.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/theme_switcher_screen.dart';
import 'package:shared/custom_app_bar.dart';
import 'q_r_view_example.dart';
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
        ChangeNotifierProvider(
          create: (ctx) => ThemeNotifier(),
        ),
      ],
      child: Consumer<ThemeNotifier>(builder: (context, theme, child) {
        return MaterialApp(
          theme: theme.theme,
          home: const BottomNavBar(),
        );
      }),
    );
  }

  ThemeData customTheme() {
    return ThemeData(
      colorScheme: ColorScheme.fromSeed(
        seedColor: const Color(0xFFFFBD59),
        // surface: const Color(0xFF403734),
        // onSurface: Colors.white,
        // background: const Color(0xFFFFF7CF),
        brightness: Brightness.light,
      ),
      // appBarTheme: const AppBarTheme(
      //   backgroundColor: Color(0xFFFFEB96),
      //   foregroundColor: Colors.black,
      // ),
      // primaryColor: const Color.fromARGB(255, 255, 189, 89),
      // primaryColorLight: const Color(0xFFFFBD59),
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
            builder: (queue) => QueueItem(data: queue),
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

  Icon icon(IconData iconData, bool isActive) {
    final appBarTheme = Theme.of(context).appBarTheme;
    return Icon(
      iconData,
      color: isActive
          ? Theme.of(context).colorScheme.surface
          : appBarTheme.foregroundColor,
      size: 35,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        height: 125,
        title: "Lineup Guru",
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (v) {
          tabIndex = v;
        },
        children: const [
          HomePage(),
          QRViewExample(),
          SettingsPage(),
        ],
      ),
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
        color: Theme.of(context).colorScheme.primaryContainer,
        circleColor: Theme.of(context).colorScheme.onBackground,
        circleShadowColor: Theme.of(context).colorScheme.onSurface,
        shadowColor: Theme.of(context).colorScheme.onSurface,
        elevation: 5,
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
