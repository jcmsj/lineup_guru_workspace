import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared/page_title_widget.dart';
import 'package:shared/queue/list.dart';
import 'package:shared/queue/notifier.dart';
import 'package:shared/queue/shop_queue.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/theme/notifier.dart';
import 'package:shared/custom_app_bar.dart';
import 'queue_view.dart';
import 'qr_scanner.dart';
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
          create: (ctx) => ServerUrlNotifier(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ActiveQueuesNotifier(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => QueueListNotifier(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => QueueNotifier(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => AppThemeNotifier(),
        ),
      ],
      child: Consumer<AppThemeNotifier>(builder: (context, model, child) {
        return MaterialApp(
          theme: model.theme.theme,
          home: const BottomNavBar(),
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
  bool dialogShown = false;
  @override
  void initState() {
    super.initState();
    final serverNotifier =
        Provider.of<ServerUrlNotifier>(context, listen: false);
    final activeQueue =
        Provider.of<ActiveQueuesNotifier>(context, listen: false);

    // Persist the queue number across app restarts using SharedPreferences
    serverNotifier
        .restore()
        .then((prefs) => {
              // 1. restore the queue positions
              activeQueue.load(prefs),
            })
        // 2. listen to changes in...
        .whenComplete(() => {
              // 2.1 Immediately load the theme
              AppThemeNotifier.of(context, listen: false).fetch(context),
              // 2.2 The Queue notifier
              activeQueue.start(),
              // 2.3 start polling the server for queues
              Provider.of<QueueListNotifier>(context, listen: false)
                  .stopTimer(),
              Provider.of<QueueListNotifier>(context, listen: false)
                  .startTimedFetch(
                Provider.of<ServerUrlNotifier>(context, listen: false)
                    .serverUrl,
              ),
              // If the server url changes,
              // 1. clear the queue positions
              // 2. persist the new server url
              // 3. fetch the server's theme
              serverNotifier.addListener(
                () {
                  activeQueue.clear();
                  serverNotifier.onChange();
                  AppThemeNotifier.of(context, listen: false)
                      .fetch(context)
                      .then(
                        (value) => setState(() {}),
                      );
                },
              ),
            });

    // listen to changes in the queue notifier, if myNumber matches the current number,
    //  then show an alert dialog

    Provider.of<QueueListNotifier>(context, listen: false).addListener(() {
      final ql = Provider.of<QueueListNotifier>(context, listen: false);
      final qn = Provider.of<ActiveQueuesNotifier>(context, listen: false);

      // Loop ql.queues, show dialog if it's the customer's turn
      if (dialogShown) return;
      for (ShopQueue q in ql.queues) {
        final assignedNumber = qn.joinedQueueIDs[q.id];
        if (assignedNumber == q.current) {
          dialogShown = true;
          showDialog(
            context: context,
            builder: (context) => YourTurnDialog(q: q),
          ).then((value) => {
                dialogShown = false,
              });
          break;
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const PageTitleWidget(title: "Services"),
        Expanded(
          child: QueueBuilder(
            builder: (queue) => QueueItem(
                data: queue,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => QueueView(
                              activeId: queue.id,
                            )),
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

  Icon icon(IconData iconData, bool isActive) {
    return Icon(
      iconData,
      color: isActive
          ? Theme.of(context).colorScheme.onSurface
          : Theme.of(context).colorScheme.onSurfaceVariant,
      size: 35,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        height: MediaQuery.of(context).size.height / 10,
        title: "Lineup Guru",
      ),
      body: PageView(
        controller: pageController,
        onPageChanged: (v) {
          tabIndex = v;
        },
        children: const [
          HomePage(),
          QRScanner(),
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
        color: Theme.of(context).colorScheme.surfaceVariant,
        circleColor: Theme.of(context).colorScheme.surface,
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

class YourTurnDialog extends StatelessWidget {
  const YourTurnDialog({
    super.key,
    required this.q,
  });

  final ShopQueue q;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: SurfaceVariant.bg(context),
      title: Text("Your turn!",
          style: TextStyle(
            color: SurfaceVariant.fg(context),
          )),
      content: Text(
        "Please proceed to the counter for ${q.name}",
        style: TextStyle(
          color: SurfaceVariant.fg(context),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text(
            "OK",
            style: TextStyle(
              color: SurfaceVariant.fg(context),
            ),
          ),
        ),
      ],
    );
  }
}
