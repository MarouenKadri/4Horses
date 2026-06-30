import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app/navigation/root_nav.dart';
import 'app/auth_provider.dart';
import 'core/design/app_design_system.dart';
import 'features/messaging/messaging_provider.dart';
import 'features/mission/presentation/mission_provider.dart';
import 'features/notifications/notifications.dart';
import 'features/story/story_provider.dart';
import 'features/profile/profile_provider.dart';
import 'features/profile/data/repositories/supabase_freelancer_catalog_repository.dart';
import 'features/reviews/presentation/providers/review_provider.dart';
import 'features/profile/presentation/payment_methods_provider.dart';

final GlobalKey<NavigatorState> appNavigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  final supabaseUrl = dotenv.env['SUPABASE_URL'];
  final supabaseAnonKey = dotenv.env['SUPABASE_ANON_KEY'];

  if (supabaseUrl == null || supabaseUrl.isEmpty) {
    throw StateError('Missing SUPABASE_URL in .env');
  }
  if (supabaseAnonKey == null || supabaseAnonKey.isEmpty) {
    throw StateError('Missing SUPABASE_ANON_KEY in .env');
  }
  if (supabaseUrl == 'https://your-project.supabase.co') {
    throw StateError('SUPABASE_URL is still using the example value in .env');
  }
  if (supabaseAnonKey == 'your-anon-key-here') {
    throw StateError(
      'SUPABASE_ANON_KEY is still using the example value in .env',
    );
  }

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);

  final stripeKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ?? '';
  if (stripeKey.isNotEmpty && !stripeKey.contains('your-stripe')) {
    Stripe.publishableKey = stripeKey;
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MissionProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => StoryProvider()),
        ChangeNotifierProvider(create: (_) => MessagingProvider()),
        ChangeNotifierProvider(
          create: (_) => ProfileProvider(
            freelancerCatalogRepository: SupabaseFreelancerCatalogRepository(),
          ),
        ),
        ChangeNotifierProvider(create: (_) => ReviewProvider()),
        ChangeNotifierProvider(create: (_) => PaymentMethodsProvider()),
      ],
      child: MaterialApp(
        navigatorKey: appNavigatorKey,
        debugShowCheckedModeBanner: false,
        locale: const Locale('fr', 'FR'),
        supportedLocales: const [Locale('fr', 'FR'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: AppThemeData.theme,
        darkTheme: AppThemeData.darkTheme,
        themeMode: ThemeMode.system,
        home: const RootNav(),
      ),
    );
  }
}
