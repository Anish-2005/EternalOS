// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_web/webview_flutter_web.dart';
import 'package:webview_flutter_platform_interface/webview_flutter_platform_interface.dart';

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
import 'screens/task_manager_screen.dart';
import 'puter_ai_service.dart';

// Theme provider for dynamic dark/light mode
class ThemeProvider extends ChangeNotifier {
  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    notifyListeners();
    SharedPreferences.getInstance()
        .then((prefs) => prefs.setBool('isDarkMode', _isDarkMode));
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    notifyListeners();
  }
}

void main() {
  WebViewPlatform.instance = WebWebViewPlatform();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) {
          final tp = ThemeProvider();
          tp.loadTheme();
          return tp;
        }),
        Provider(create: (_) => PuterAIService()),
        ChangeNotifierProvider(create: (context) {
          final puterService =
              Provider.of<PuterAIService>(context, listen: false);
          final cm = ContextManager(puterService);
          Future.microtask(() => cm.loadPreferences());
          return cm;
        }),
        ChangeNotifierProvider(create: (_) => VoiceService()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'EternalOS - AI Operating System',
            theme: _buildLightTheme(),
            darkTheme: _buildDarkTheme(),
            themeMode:
                themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            initialRoute: '/splash',
            routes: {
              '/': (ctx) => const MainShell(),
              '/splash': (ctx) => const SplashScreen(),
              '/permissions': (ctx) => const PermissionsScreen(),
              '/settings': (ctx) => const SettingsScreen(),
            },
            // Smooth page transitions for OS feel
            onGenerateRoute: (settings) {
              Widget page;
              switch (settings.name) {
                case '/':
                  page = const MainShell();
                  break;
                case '/splash':
                  page = const SplashScreen();
                  break;
                case '/permissions':
                  page = const PermissionsScreen();
                  break;
                case '/settings':
                  page = const SettingsScreen();
                  break;
                default:
                  page = const MainShell();
              }
              return PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => page,
                transitionsBuilder:
                    (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end)
                      .chain(CurveTween(curve: curve));
                  return SlideTransition(
                      position: animation.drive(tween), child: child);
                },
              );
            },
          );
        },
      ),
    );
  }

  static ThemeData _buildLightTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.cyan,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      textTheme:
          GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.orbitron(
            textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        titleMedium: GoogleFonts.orbitron(
            textStyle: const TextStyle(fontSize: 20, color: Colors.white)),
        headlineLarge: GoogleFonts.orbitron(
            textStyle: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        bodyLarge:
            GoogleFonts.exo2(textStyle: const TextStyle(color: Colors.white)),
        bodyMedium:
            GoogleFonts.exo2(textStyle: const TextStyle(color: Colors.white70)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF2A2A2A),
        shadowColor: Colors.cyanAccent.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3A3A3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }

  static ThemeData _buildDarkTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: Colors.cyan,
      scaffoldBackgroundColor: const Color(0xFF0A0A0A),
      textTheme:
          GoogleFonts.orbitronTextTheme(ThemeData.dark().textTheme).copyWith(
        titleLarge: GoogleFonts.orbitron(
            textStyle: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        titleMedium: GoogleFonts.orbitron(
            textStyle: const TextStyle(fontSize: 20, color: Colors.white)),
        headlineLarge: GoogleFonts.orbitron(
            textStyle: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        bodyLarge:
            GoogleFonts.exo2(textStyle: const TextStyle(color: Colors.white)),
        bodyMedium:
            GoogleFonts.exo2(textStyle: const TextStyle(color: Colors.white70)),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFF1A1A1A),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Color(0xFF1A1A1A),
        selectedItemColor: Colors.cyanAccent,
        unselectedItemColor: Colors.grey,
      ),
      cardTheme: CardThemeData(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: const Color(0xFF2A2A2A),
        shadowColor: Colors.cyanAccent.withOpacity(0.3),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyanAccent,
          foregroundColor: Colors.black,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF3A3A3A),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        hintStyle: const TextStyle(color: Colors.white54),
      ),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _index = 0;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabScaleAnimation;

  @override
  void initState() {
    super.initState();
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fabScaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
          parent: _fabAnimationController, curve: Curves.elasticOut),
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final ctx = Provider.of<ContextManager>(context, listen: false);
      if (!ctx.onboardingSeen) {
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (_) => const OnboardingScreen()));
      }
    });
  }

  @override
  void dispose() {
    _fabAnimationController.dispose();
    super.dispose();
  }

  final List<Widget> _pages = [
    const HomeScreen(),
    const ContextDashboard(),
    const HistoryScreen(),
    const TaskManagerScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final ctx = Provider.of<ContextManager>(context);
    final voice = Provider.of<VoiceService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('EternalOS'),
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
          IconButton(
            icon: Icon(
                themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
      body: Stack(children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: _pages[_index],
        ),
        const OverlaySidebar(),
        Consumer<PuterAIService>(
          builder: (context, puterService, child) {
            return Opacity(
              opacity: 0.0, // Hidden WebView
              child: puterService.buildWebView(),
            );
          },
        ),
      ]),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.visibility), label: 'Context'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'History'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tasks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.settings), label: 'Settings'),
        ],
      ),
      floatingActionButton: ScaleTransition(
        scale: _fabScaleAnimation,
        child: ListeningPill(
          onStart: () async {
            _fabAnimationController.forward();
            await voice.startListening(
                onResult: (t) async {
                  final parsed = NLU.parse(t);
                  final resolved = ctx.resolveTarget(parsed['item'] ?? '');
                  final action = {
                    'intent': parsed['intent'],
                    'item': parsed['item'],
                    'resolvedItem': resolved,
                  };
                  final result =
                      await ActionExecutor(ctx, ctx.aiService).execute(action);
                  if (!mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result ?? 'Action executed')));
                },
                context: context);
            setState(() {});
          },
          onStop: () async {
            _fabAnimationController.reverse();
            await voice.stopListening();
            setState(() {});
          },
        ),
      ),
    );
  }
}
