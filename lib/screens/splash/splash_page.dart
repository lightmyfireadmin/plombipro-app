import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) {
      return;
    }

    print('🔍 === SPLASH PAGE AUTH CHECK ===');
    final session = Supabase.instance.client.auth.currentSession;
    final user = Supabase.instance.client.auth.currentUser;

    print('  Session exists: ${session != null}');
    print('  User exists: ${user != null}');
    print('  User ID: ${user?.id}');
    print('  Access Token exists: ${session?.accessToken != null}');
    if (session?.accessToken != null) {
      print('  Token preview: ${session!.accessToken!.substring(0, 20)}...');
    }

    if (session != null && user != null) {
      print('✅ User authenticated - navigating to home');
      context.go('/home-enhanced');
    } else {
      print('❌ No valid session - navigating to login');
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}