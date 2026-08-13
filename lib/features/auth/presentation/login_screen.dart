import 'package:flutter/material.dart';
import 'signup_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/services/api_service.dart';
import '../../employer/presentation/employer_setup_screen.dart';
import '../../employer/presentation/employer_dashboard_screen.dart';
import '../../employee/presentation/employee_dashboard_screen.dart';
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();

  final _mobileController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _mobileController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  Future<void> _login() async {
  if (!_formKey.currentState!.validate()) {
    return;
  }

  try {
    final result = await ApiService.login(
      mobile: _mobileController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    final user = result['user'];
    final role = user['role'];
    final String token = result['token'];

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          result['message'] ?? 'Login successful',
        ),
      ),
    );

    if (role == 'employer') {
      final workspaceResult = await ApiService.getMyOrganization(
        token: token,
      );

      if (!mounted) return;

      final organization = workspaceResult['organization'];

      if (organization != null) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => EmployerDashboardScreen(
              businessName: organization['name'],
              inviteCode: organization['invite_code'],
              token: token,
            ),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => EmployerSetupScreen(
              token: token,
            ),
          ),
          (route) => false,
        );
      }
    } else if (role == 'employee') {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => EmployeeDashboardScreen(
            fullName: user['fullName'],
            organizationName: user['organizationName'],
          ),
        ),
        (route) => false,
      );
    }
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          error.toString().replaceFirst('Exception: ', ''),
        ),
      ),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 32,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 40),

                    // Logo
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.access_time_rounded,
                        color: Colors.white,
                        size: 34,
                      ),
                    ),

                    const SizedBox(height: 28),

                    Text(
                      'Welcome back',
                      style: Theme.of(context)
                          .textTheme
                          .headlineLarge,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Sign in to manage your attendance.',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium,
                    ),

                    const SizedBox(height: 36),

                    Text(
                      'Mobile Number',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _mobileController,
                      keyboardType: TextInputType.phone,
                      maxLength: 10,
                      decoration: const InputDecoration(
                        hintText: 'Enter mobile number',
                        counterText: '',
                        prefixIcon: Icon(
                          Icons.phone_outlined,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your mobile number';
                        }

                        if (value.length != 10) {
                          return 'Enter a valid 10-digit number';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 20),

                    Text(
                      'Password',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                    ),

                    const SizedBox(height: 8),

                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'Enter password',
                        prefixIcon: const Icon(
                          Icons.lock_outline_rounded,
                        ),
                        suffixIcon: IconButton(
                          onPressed: () {
                            setState(() {
                              _obscurePassword =
                                  !_obscurePassword;
                            });
                          },
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                          ),
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Enter your password';
                        }

                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }

                        return null;
                      },
                    ),

                    const SizedBox(height: 28),

                    ElevatedButton(
                      onPressed: _login,
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Create a new account',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}