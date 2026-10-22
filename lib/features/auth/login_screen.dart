import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/custom_text_field.dart';
import '../../services/app_state_provider.dart';
import '../volunteer/volunteer_dashboard.dart';
import '../organization/organization_dashboard.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final String? initialRole; // 'volunteer' or 'organization'

  const LoginScreen({
    super.key,
    this.initialRole,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  late String _selectedRole; // 'volunteer' or 'organization'

  @override
  void initState() {
    super.initState();
    _selectedRole = widget.initialRole ?? 'volunteer';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final provider = context.read<AppStateProvider>();
    final success = await provider.login(
      _emailController.text,
      _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final user = provider.currentUser!;
      if (user.isOrganization) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const OrganizationDashboard()),
          (route) => false,
        );
      } else {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const VolunteerDashboard()),
          (route) => false,
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Authentication failed'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppStateProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _selectedRole == 'organization'
              ? 'NGO / Organization Sign In'
              : 'Volunteer Sign In',
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedRole == 'organization'
                      ? 'Welcome, Organization Partner! 🏛️'
                      : 'Welcome Back, Volunteer! 🌱',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textMain,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _selectedRole == 'organization'
                      ? 'Sign in to post opportunities and verify student attendance.'
                      : 'Sign in to explore campus service tasks and earn credits.',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 20),

                // Role Selector Segmented Tabs
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.outline),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = 'volunteer';
                              _emailController.clear();
                              _passwordController.clear();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'volunteer' ? AppColors.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: _selectedRole == 'volunteer'
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.volunteer_activism,
                                  size: 18,
                                  color: _selectedRole == 'volunteer' ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Volunteer Login',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _selectedRole == 'volunteer' ? FontWeight.w700 : FontWeight.w500,
                                    color: _selectedRole == 'volunteer' ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedRole = 'organization';
                              _emailController.clear();
                              _passwordController.clear();
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _selectedRole == 'organization' ? AppColors.surface : Colors.transparent,
                              borderRadius: BorderRadius.circular(9),
                              boxShadow: _selectedRole == 'organization'
                                  ? [
                                      BoxShadow(
                                        color: Colors.black.withValues(alpha: 0.06),
                                        blurRadius: 4,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.business,
                                  size: 18,
                                  color: _selectedRole == 'organization' ? AppColors.primary : AppColors.textSecondary,
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'NGO / Org Login',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: _selectedRole == 'organization' ? FontWeight.w700 : FontWeight.w500,
                                    color: _selectedRole == 'organization' ? AppColors.primary : AppColors.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                CustomTextField(
                  controller: _emailController,
                  label: _selectedRole == 'organization'
                      ? 'Organization Official Email'
                      : 'Volunteer Student Email',
                  hint: _selectedRole == 'organization'
                      ? 'e.g. contact@greenearth.org'
                      : 'e.g. alex.chen@student.edu',
                  prefixIcon: _selectedRole == 'organization'
                      ? Icons.business_outlined
                      : Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (val) {
                    if (val == null || val.trim().isEmpty) return 'Email is required';
                    if (!val.contains('@')) return 'Enter a valid email';
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                CustomTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: '••••••••',
                  prefixIcon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: AppColors.textSecondary,
                      size: 20,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  validator: (val) {
                    if (val == null || val.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 28),

                ElevatedButton(
                  onPressed: provider.isLoading ? null : _handleLogin,
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          _selectedRole == 'organization'
                              ? 'Sign In as NGO Partner'
                              : 'Sign In as Volunteer',
                        ),
                ),
                const SizedBox(height: 16),

                // 1-Tap Quick Demo Logins for Hackathon Evaluators
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.outline),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.flash_on, size: 16, color: AppColors.warning),
                          const SizedBox(width: 6),
                          Text(
                            _selectedRole == 'organization'
                                ? 'Demo NGO Account'
                                : 'Demo Volunteer Account',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textMain,
                            ),
                          ),
                          const Spacer(),
                          const Text(
                            '1-Tap Demo',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      InkWell(
                        onTap: () {
                          if (_selectedRole == 'organization') {
                            _emailController.text = 'contact@greenearth.org';
                            _passwordController.text = 'password123';
                          } else {
                            _emailController.text = 'alex.chen@student.edu';
                            _passwordController.text = 'password123';
                          }
                          _handleLogin();
                        },
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.outline),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                _selectedRole == 'organization'
                                    ? Icons.domain_rounded
                                    : Icons.account_circle_rounded,
                                size: 20,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      _selectedRole == 'organization'
                                          ? 'GreenEarth Foundation (NGO)'
                                          : 'Alex Chen (Gardening & Sunday Match)',
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.textMain,
                                      ),
                                    ),
                                    Text(
                                      _selectedRole == 'organization'
                                          ? 'contact@greenearth.org'
                                          : 'alex.chen@student.edu',
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(Icons.arrow_forward_ios, size: 12, color: AppColors.primary),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Don’t have an account?',
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(builder: (_) => const RegisterScreen()),
                        );
                      },
                      child: const Text('Register Here'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
