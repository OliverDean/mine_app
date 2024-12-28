import 'dart:async';
import 'dart:isolate';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';

import 'services/auth_service.dart';
import 'screens/game_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/lobby_screen.dart';
import 'screens/home_screen.dart';

// import 'package:firebase_crashlytics/firebase_crashlytics.dart'; // Uncomment if using Crashlytics
// import 'package:sentry_flutter/sentry_flutter.dart'; // Uncomment if using Sentry
// import 'package:firebase_remote_config/firebase_remote_config.dart'; // Uncomment if using Remote Config

// import 'cairo_minesweeper_app.dart';

// Toggle each service on/off here
const bool useCrashlytics = false;
const bool useSentry = false;
const bool useRemoteConfig = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set up a fallback error listener for the current isolate.
  configureIsolateErrorListener();

  // Catch all unhandled errors using runZonedGuarded.
  runZonedGuarded<Future<void>>(() async {
    await initializeFirebase();

    // Initialize optional services based on toggles
    if (useCrashlytics) {
      await initializeCrashlytics();
    }
    if (useSentry) {
      await initializeSentry();
    }
    if (useRemoteConfig) {
      await initializeRemoteConfig();
    }

    // Now run the main app.
    runApp(const CairoMinesweeperApp());
  }, (error, stackTrace) {
    // Unhandled errors caught here.
    // Log or forward to your crash-reporting services.
    handleUncaughtError(error, stackTrace);
  });
}

/// Configures a fallback error listener for errors that occur outside runZonedGuarded,
/// such as errors in spawned isolates.
void configureIsolateErrorListener() {
  Isolate.current.addErrorListener(RawReceivePort((dynamic pair) {
    final List<dynamic> errorAndStackTrace = pair;
    final error = errorAndStackTrace.first;
    final stackTrace = errorAndStackTrace.last;
    handleUncaughtError(error, stackTrace);
  }).sendPort);
}

/// Initializes Firebase for the app.
Future<void> initializeFirebase() async {
  await Firebase.initializeApp();
  // If you need specific Firebase options, pass them here or configure in your project’s files.
  // e.g., await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
}

/// Initializes Firebase Crashlytics if toggled on.
/// Make sure to uncomment the relevant imports.
Future<void> initializeCrashlytics() async {
  // Uncomment if you want Flutter to send all uncaught errors to Crashlytics automatically:
  // await FirebaseCrashlytics.instance.setCrashlyticsCollectionEnabled(true);
  // FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterError;
}

/// Initializes Sentry if toggled on.
/// Make sure to uncomment the relevant imports and add Sentry to your pubspec.yaml.
Future<void> initializeSentry() async {
  // Example usage:
  /*
  await SentryFlutter.init(
    (options) {
      options.dsn = 'Your Sentry DSN here';
      options.tracesSampleRate = 1.0; // Adjust for performance monitoring
    },
    appRunner: () {
      // If Sentry is controlling the app runner, it can capture errors at startup.
      // runApp(const CairoMinesweeperApp());
    },
  );
  */
}

/// Initializes Firebase Remote Config if toggled on.
/// Make sure to uncomment the relevant imports and add firebase_remote_config to your pubspec.yaml.
Future<void> initializeRemoteConfig() async {
  // Example usage:
  /*
  final remoteConfig = FirebaseRemoteConfig.instance;
  await remoteConfig.setConfigSettings(RemoteConfigSettings(
    fetchTimeout: const Duration(seconds: 60),
    minimumFetchInterval: const Duration(minutes: 5),
  ));
  await remoteConfig.fetchAndActivate();
  // Now you can read values from remoteConfig.getString('key_name') etc.
  */
}

/// Handles uncaught errors for logging or sending to external services.
/// In production, connect this to Crashlytics, Sentry, or another reporting system.
void handleUncaughtError(Object error, StackTrace stackTrace) {
  // In production, log to Crashlytics or Sentry.
  // if (useCrashlytics) {
  //   FirebaseCrashlytics.instance.recordError(error, stackTrace);
  // }
  // if (useSentry) {
  //   Sentry.captureException(error, stackTrace: stackTrace);
  // }

  // For now, just print to console.
  debugPrint('Uncaught error: $error');
  debugPrint('$stackTrace');
}


class CairoMinesweeperApp extends StatelessWidget {
  const CairoMinesweeperApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Use StreamProvider to listen to auth state changes.
    // AuthService should provide a stream of User? (Firebase user or custom user model).
    return StreamProvider.value(
      value: AuthService().authStateChanges, // Stream<User?>
      initialData: null,
      catchError: (_, __) => null,
      child: MaterialApp(
        title: 'Cairo Minesweeper',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        // Use AuthWrapper as the home to decide which screen to show based on auth state.
        home: const AuthWrapper(),
        routes: {
          '/login': (context) => LoginScreen(),
          '/register': (context) => RegisterScreen(),
          '/lobby': (context) => LobbyScreen(),
          '/game': (context) => GameScreen(), 
          '/home': (context) => HomeScreen(),
        },
      ),
    );
  }
}

/// A widget that decides which screen to show based on the user's authentication state.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<dynamic>(context); // 'dynamic' since initialData is null; normally User? type.

    // While waiting for Firebase initialization and auth state check, show a loading screen.
    // If you have a SplashScreen or loading indicator, show it here.
    if (user == null) {
      return LoginScreen();
    } else {
      // User is signed in, navigate to the HomeScreen or LobbyScreen as desired.
      return HomeScreen();
    }
  }
}
