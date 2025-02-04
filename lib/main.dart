import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:task_management_app/providers/auth_provider.dart';
import 'package:task_management_app/providers/task_provider.dart';
import 'package:task_management_app/screens/login_screen.dart';
import 'package:task_management_app/screens/main_screen.dart';
import 'package:task_management_app/screens/admin_login.dart';
import 'package:task_management_app/screens/admin_dashboard.dart';
import 'package:task_management_app/screens/admin_tasks.dart';
import 'package:task_management_app/screens/admin_users.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
      ],
      child: MaterialApp(
        title: 'Task Management',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routes: {
          '/admin_login': (context) => const AdminLogin(),
          '/admin_dashboard': (context) => const AdminDashboard(),
          '/admin_tasks': (context) => const AdminTasks(),
          '/admin_users': (context) => const AdminUsers(),
          '/main_screen': (context) => const MainScreen(),
          '/login_screen': (context) => const LoginScreen(),
        },
        home: Consumer<AuthProvider>(
          builder: (context, auth, _) {
            print('Current user: ${auth.userId}, isAdmin: ${auth.isAdmin}');

            // If no user is logged in, show login screen
            if (auth.userId == null) {
              return const LoginScreen();
            }

            // If user is admin, force admin dashboard
            if (auth.userId == 'admin@gmail.com' && auth.isAdmin) {
              return const AdminDashboard();
            }

            // For all other users, show main screen
            if (auth.userId != 'admin@gmail.com') {
              return const MainScreen();
            }

            // Fallback to login screen
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
