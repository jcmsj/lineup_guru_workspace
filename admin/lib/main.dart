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
import 'package:shared/bot_icon.dart';
import 'qr_screen.dart';
import 'add_queue.dart';
import 'edit_queue.dart';
import 'settings_page.dart';

void main() {
  runApp(const AdminApp());
}

class AdminApp extends StatelessWidget {
  const AdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (ctx) => ActiveQueuesNotifier(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ServerUrlNotifier(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => QueueListNotifier(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => QueueNotifier(),
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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
    final serverNotifier =
        Provider.of<ServerUrlNotifier>(context, listen: false);
    // Restore from shared preferences the last server used
    serverNotifier
        .restore()
        // Regardless if any error occurs in the server,
        // start listening to changes in...
        .whenComplete(() => {
              // 4.2 start polling the server for queues
              Provider.of<QueueListNotifier>(context, listen: false)
                  .stopTimer(),
              Provider.of<QueueListNotifier>(context, listen: false)
                  .startTimedFetch(
                Provider.of<ServerUrlNotifier>(context, listen: false)
                    .serverUrl,
              ),
              // 1. sync theme from server
              AppThemeNotifier.of(context, listen: false).fetch(context),
              // If the server url changes,
              // 1. clear the queue positions
              // 2. persist the new server url
              // 3. fetch the server's theme
              serverNotifier.addListener(
                () {
                  serverNotifier.onChange();
                  AppThemeNotifier.of(context, listen: false).fetch(context);
                },
              ),
            });
  }

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
                  Navigator.pushNamed(
                    context,
                    "/editor",
                  );
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        // 1/10 of screen height
        height: MediaQuery.of(context).size.height / 10,
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
        activeIcons: const [
          BotIcon(iconData: Icons.home_outlined, isActive: true),
          BotIcon(iconData: Icons.qr_code_sharp, isActive: true),
          BotIcon(iconData: Icons.settings_outlined, isActive: true),
        ],
        inactiveIcons: const [
          BotIcon(iconData: Icons.home_outlined, isActive: false),
          BotIcon(iconData: Icons.qr_code_sharp, isActive: false),
          BotIcon(iconData: Icons.settings_outlined, isActive: false),
        ],
        color: SurfaceVariant.bg(context),
        circleColor: Surface.bg(context),
        circleShadowColor: Surface.fg(context),
        shadowColor: Surface.fg(context),
        elevation: 10,
        height: MediaQuery.of(context).size.height / 13,
        circleWidth: MediaQuery.of(context).size.height / 15,
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
