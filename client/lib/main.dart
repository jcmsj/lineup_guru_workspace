import 'package:flutter/material.dart';
import 'package:circle_nav_bar/circle_nav_bar.dart';
import 'package:provider/provider.dart';
import 'package:shared/page_title_widget.dart';
import 'package:shared/queue/list.dart';
import 'package:shared/queue/notifier.dart';
import 'package:shared/server_url_notifier.dart';
import 'package:shared/theme/app_theme.dart';
import 'package:shared/theme/notifier.dart';
import 'package:shared/custom_app_bar.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
          create: (ctx) => QueueNotifier(),
        ),
        ChangeNotifierProvider(
          create: (ctx) => ServerUrlNotifier(),
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

class HomePage extends StatelessWidget {
  const HomePage({super.key});

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
                  Provider.of<QueueNotifier>(context, listen: false).queue =
                      queue;
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QueueView()),
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
  bool dialogShown = false;
  @override
  void initState() {
    super.initState();
    pageController = PageController(initialPage: _tabIndex);
    final serverNotifier =
        Provider.of<ServerUrlNotifier>(context, listen: false);
    AppThemeNotifier.of(context, listen: false).fetch(context).then((vaue) {
      setState(() {});
    });
    final qn = Provider.of<QueueNotifier>(context, listen: false);

    // Persist the queue number across app restarts using SharedPreferences
    SharedPreferences.getInstance().then((prefs) => {
          // Get the last server url used
          serverNotifier
              .tryCandidate(prefs.getString('server-url') ?? "")
              .then((valueVoid) => {
                    qn.myNumber = prefs.getInt('my-number') ?? -1,
                    qn.activeQueueId = prefs.getInt('active-queue-id') ?? -1,
                    // Listen to changes in the server url notifier, and save the url to shared preferences
                  })
              .whenComplete(() => {
                    qn.addListener(() {
                      final qn =
                          Provider.of<QueueNotifier>(context, listen: false);
                      prefs.setInt('my-number', qn.myNumber);
                      prefs.setInt('active-queue-id', qn.activeQueueId);
                    }),
                    serverNotifier.addListener(() {
                      prefs.setString(
                        'server-url',
                        Provider.of<ServerUrlNotifier>(context, listen: false)
                            .serverUrl,
                      );
                      qn.myNumber = -1;
                      qn.activeQueueId = -1;
                      AppThemeNotifier.of(context, listen: false)
                          .fetch(context)
                          .then(
                            (value) => setState(() {}),
                          );
                    }),
                  }),
        });

    // listen to changes in the queue notifier, if myNumber matches the current number,
    //  then show an alert dialog
    Provider.of<QueueNotifier>(context, listen: false).addListener(() {
      if (!dialogShown && qn.myNumber == qn.queue?.current) {
        dialogShown = true;
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: SurfaceVariant.bg(context),
            title: Text("Your turn!",
                style: TextStyle(
                  color: SurfaceVariant.fg(context),
                )),
            content: Text(
              "Please proceed to the counter for ${qn.queue!.name}",
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
          ),
        ).then(
          (value) {
            dialogShown = false;
          },
        );
      }
    });
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
