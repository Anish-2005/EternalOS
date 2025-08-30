import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'voice_service.dart';
import 'context_manager.dart';
import 'nlu.dart';
import 'action_executor.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/permissions_screen.dart';
import 'screens/home_screen.dart';
import 'screens/context_dashboard.dart';
import 'screens/history_screen.dart';
import 'widgets/listening_pill.dart';
import 'widgets/recording_wave.dart';
import 'widgets/overlay_sidebar.dart';
import 'screens/onboarding_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final cm = ContextManager();
          // load persisted prefs asynchronously
          Future.microtask(() => cm.loadPreferences());
          return cm;
        }),
        ChangeNotifierProvider(create: (_) => VoiceService()),
      ],
      child: MaterialApp(
        title: 'EternalOS Assistant (MVP)',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          textTheme:
              GoogleFonts.exo2TextTheme(Theme.of(context).textTheme).copyWith(
            titleLarge: GoogleFonts.orbitron(
                textStyle: Theme.of(context).textTheme.titleLarge),
            titleMedium: GoogleFonts.orbitron(
                textStyle: Theme.of(context).textTheme.titleMedium),
            headlineLarge: GoogleFonts.orbitron(
                textStyle: Theme.of(context).textTheme.headlineLarge),
          ),
        ),
        initialRoute: '/splash',
        routes: {
          '/': (ctx) => const MainShell(),
          '/splash': (ctx) => const SplashScreen(),
          '/permissions': (ctx) => const PermissionsScreen(),
          // Temporary mock route for settings — replace with a fuller settings flow later.
          '/settings': (ctx) => const SettingsScreen(),
        },
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = Provider.of<ContextManager>(context, listen: false);
      if (!ctx.onboardingSeen) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      }
    });
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const ContextDashboard(),
    const HistoryScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final voice = Provider.of<VoiceService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EternalOS Assistant'),
        // ensure icons/text in the app bar use a contrasting color from the theme
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
        // optionally ensure the AppBar background uses primary
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          if (voice.isListening)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child:
                  Center(child: SizedBox(width: 140, child: RecordingWave())),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Center(child: Text('Cart: ${ctx.cartTotalCount}')),
          ),
        ],
      ),
      body: Stack(children: [
        IndexedStack(index: _index, children: _pages),
        const OverlaySidebar()
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: Theme.of(context).colorScheme.onSurface,
        unselectedItemColor:
            Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
        backgroundColor: Theme.of(context).colorScheme.surface,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.visibility), label: 'Context'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: ListeningPill(
        onStart: () async {
          await voice.startListening(
              onResult: (t) async {
                // route transcript to NLU and executor
                final parsed = NLU.parse(t);
                final resolved = ctx.resolveTarget(parsed['item'] ?? '');
                final action = {
                  'intent': parsed['intent'],
                  'item': parsed['item'],
                  'resolvedItem': resolved,
                };
                final result = await ActionExecutor(ctx).execute(action);
                if (!mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result ?? 'No action')));
              },
              context: context);
          setState(() {});
        },
        onStop: () async {
          await voice.stopListening();
          setState(() {});
        },
      ),
    );
  }
}
