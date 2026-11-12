import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'config.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    if (!Config.demo) await Firebase.initializeApp(options: Config.firebase);
    final state = AppState();
    try {
      await state.alerts.initialize();
    } catch (_) {
      /* O app continua disponível sem alertas locais. */
    }
    try {
      await state.restore();
    } catch (_) {
      /* Permite novo login se a sessão não puder ser restaurada. */
    }
    runApp(HippieApp(state: state));
  } catch (_) {
    runApp(
      MaterialApp(
        home: Scaffold(
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.settings_outlined, size: 64),
                  SizedBox(height: 24),
                  Text(
                    'Falta configurar o Firebase',
                    style: TextStyle(fontSize: 24),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Preencha config.local.json conforme o README ou inicie com DEMO_MODE=true para conhecer o aplicativo.',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class HippieApp extends StatelessWidget {
  final AppState state;
  const HippieApp({super.key, required this.state});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Hippie Turismo',
    debugShowCheckedModeBanner: false,
    theme: buildAppTheme(),
    home: ListenableBuilder(
      listenable: state,
      builder: (context, _) =>
          state.signedIn ? HomeScreen(state: state) : AuthScreen(state: state),
    ),
  );
}
