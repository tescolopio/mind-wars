/**
 * Mind Wars - Main Application Entry Point
 * Mobile-First: Designed for 5" touch screens, scales up
 * Flutter app for iOS 14+ and Android 8+
 * Alpha Mode: Local authentication without backend server
 */

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'services/local_auth_service.dart';
import 'services/multiplayer_service.dart';
import 'services/offline_service.dart';
import 'services/progression_service.dart';
import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/registration_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/profile_setup_screen.dart';

// Alpha mode flag - set to false when backend is ready
const bool kAlphaMode = true;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MindWarsApp());
}

class MindWarsApp extends StatefulWidget {
  const MindWarsApp({super.key});

  @override
  State<MindWarsApp> createState() => _MindWarsAppState();
}

class _MindWarsAppState extends State<MindWarsApp> {
  late Future<void> _initFuture;
  late ApiService _apiService;
  late AuthService _authService;
  late OfflineService _offlineService;
  late MultiplayerService _multiplayerService;
  late ProgressionService _progressionService;

  @override
  void initState() {
    super.initState();
    _initFuture = _initializeServices();
  }

  Future<void> _initializeServices() async {
    // Initialize services
    _apiService = ApiService(
      baseUrl: 'https://api.mindwars.app', // Configure your API endpoint
    );
    
    _offlineService = OfflineService();
    _multiplayerService = MultiplayerService();
    _progressionService = ProgressionService(apiService: _apiService);
    
    // Initialize database for local auth in alpha mode
    if (kAlphaMode) {
      final database = await _offlineService.database;
      final localAuthService = LocalAuthService(database: database);
      _authService = AuthService(
        apiService: _apiService,
        localAuthService: localAuthService,
        isAlphaMode: true,
      );
    } else {
      _authService = AuthService(
        apiService: _apiService,
        isAlphaMode: false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          // Show loading screen while initializing
          return MaterialApp(
            home: Scaffold(
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF6200EE),
                      Color(0xFF9D46FF),
                    ],
                  ),
                ),
                child: const Center(
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                ),
              ),
            ),
          );
        }

        return MultiProvider(
          providers: [
            Provider<ApiService>.value(value: _apiService),
            Provider<AuthService>.value(value: _authService),
            Provider<MultiplayerService>.value(value: _multiplayerService),
            Provider<OfflineService>.value(value: _offlineService),
            Provider<ProgressionService>.value(value: _progressionService),
          ],
          child: MaterialApp(
            title: kAlphaMode ? 'Mind Wars Alpha' : 'Mind Wars',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              // Mobile-First: Material Design 3 with touch-friendly sizing
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6200EE),
                brightness: Brightness.light,
              ),
              
              // Touch-friendly sizes for 5" screens
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(120, 48), // Touch-friendly
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ),
              
              cardTheme: CardTheme(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              
              appBarTheme: const AppBarTheme(
                centerTitle: true,
                elevation: 0,
              ),
              
              // Typography optimized for mobile
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
                displayMedium: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                displaySmall: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                headlineMedium: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
                bodyLarge: TextStyle(fontSize: 16),
                bodyMedium: TextStyle(fontSize: 14),
              ),
            ),
            
            darkTheme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6200EE),
                brightness: Brightness.dark,
              ),
            ),
            
            themeMode: ThemeMode.system,
            
            // Initial route - splash screen handles navigation
            initialRoute: '/',
            
            routes: {
              '/': (context) => const SplashScreen(),
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegistrationScreen(),
              '/onboarding': (context) => const OnboardingScreen(),
              '/profile-setup': (context) => const ProfileSetupScreen(),
              '/home': (context) => const HomeScreen(),
              '/lobby-list': (context) => const LobbyListScreen(),
              '/leaderboard': (context) => const LeaderboardScreen(),
              '/profile': (context) => const ProfileScreen(),
              '/offline': (context) => const OfflineScreen(),
            },
          ),
        );
      },
    );
  }
}

/// Home Screen - Main entry point
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mind Wars'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // App Logo/Header
              const SizedBox(height: 40),
              const Icon(
                Icons.psychology,
                size: 80,
                color: Color(0xFF6200EE),
              ),
              const SizedBox(height: 16),
              Text(
                'Mind Wars',
                style: Theme.of(context).textTheme.displayLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Challenge Your Mind',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              
              const SizedBox(height: 60),
              
              // Main Action Buttons
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/lobby-list');
                },
                icon: const Icon(Icons.people),
                label: const Text('Multiplayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6200EE),
                  foregroundColor: Colors.white,
                ),
              ),
              
              const SizedBox(height: 16),
              
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/offline');
                },
                icon: const Icon(Icons.offline_bolt),
                label: const Text('Play Offline'),
              ),
              
              const SizedBox(height: 16),
              
              OutlinedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/leaderboard');
                },
                icon: const Icon(Icons.leaderboard),
                label: const Text('Leaderboard'),
              ),
              
              const Spacer(),
              
              // Feature Highlights
              _buildFeatureChip(context, '2-10 Players'),
              const SizedBox(height: 8),
              _buildFeatureChip(context, '12+ Games, 5 Categories'),
              const SizedBox(height: 8),
              _buildFeatureChip(context, 'Weekly Challenges'),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureChip(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, size: 20, color: Colors.green[700]),
          const SizedBox(width: 8),
          Text(
            text,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}

/// Placeholder screens (to be implemented)
class LobbyListScreen extends StatelessWidget {
  const LobbyListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Available Lobbies')),
      body: const Center(child: Text('Lobby List - Coming Soon')),
    );
  }
}

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Leaderboard')),
      body: const Center(child: Text('Leaderboard - Coming Soon')),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: const Center(child: Text('Profile - Coming Soon')),
    );
  }
}

class OfflineScreen extends StatelessWidget {
  const OfflineScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Offline Mode')),
      body: const Center(child: Text('Offline Mode - Coming Soon')),
    );
  }
}
