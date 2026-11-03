import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'data/repositories/session_repository.dart';
import 'data/services/tts_service.dart';
import 'ui/core/app_colors.dart';
import 'ui/features/active_cpr/view_models/active_cpr_view_model.dart';
import 'ui/features/active_cpr/views/active_cpr_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 鎖定螢幕為直向，避免急救現場顛簸翻轉
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // 初始化語音服務
  await TtsService().init();

  final repository = SessionRepository();
  final viewModel = ActiveCprViewModel(repository: repository);

  runApp(HsinchuOhcaApp(viewModel: viewModel));
}

class HsinchuOhcaApp extends StatelessWidget {
  final ActiveCprViewModel viewModel;

  const HsinchuOhcaApp({super.key, required this.viewModel});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '新竹市消防局 OHCA 現場輔助',
      debugShowCheckedModeBanner: false,
      themeMode: ThemeMode.dark,
      darkTheme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.cprGreen,
          secondary: AppColors.drugBlue,
          surface: AppColors.surface,
          error: AppColors.urgentRed,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.surface,
          elevation: 0,
        ),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', 'TW'),
        Locale('zh'),
        Locale('en'),
      ],
      home: ActiveCprScreen(viewModel: viewModel),
    );
  }
}
