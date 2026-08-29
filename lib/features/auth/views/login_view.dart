import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/presentaion/home/home_screen.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_text.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../controllers/auth_bloc.dart';
import '../controllers/auth_event.dart';
import '../controllers/auth_state.dart';
import 'register_company_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _submitLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      FocusScope.of(context).unfocus();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text;
      context.read<AuthBloc>().add(LoginPhoneChanged(phone));
      context.read<AuthBloc>().add(LoginPasswordChanged(password));
      context.read<AuthBloc>().add(const LoginSubmitted());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: scaffoldColor,
      body: BlocListener<AuthBloc, AuthState>(
        listenWhen: (previous, current) => previous.status != current.status,
        listener: (context, state) {
          if (state.status == AuthStatus.failure && state.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage!,
                  style: const TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
                ),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );
          } else if (state.status == AuthStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Welcome back, ${state.user?.name ?? 'User'}!',
                  style: const TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
                ),
                backgroundColor: buttonColor1,
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            );

            // Connection / Navigation to Dashboard
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        },
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Logo & Branding
                    Center(
                      child: Container(
                        width: 72,
                        height: 72,
                        decoration: BoxDecoration(
                          color: primaryColor,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: primaryColor.withValues(alpha: 0.15),
                              blurRadius: 15,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.real_estate_agent,
                          size: 36,
                          color: buttonColor1, // #059669
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Welcome Title
                    const Center(
                      child: AppText.h1(
                        'Welcome Back',
                        fontSize: 24,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Center(
                      child: AppText(
                        'Sign in to access your rental dashboard',
                        color: Colors.grey.shade600,
                      ),
                    ),

                    const SizedBox(height: 36),

                    // Phone Number Input Field
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) => previous.phone != current.phone,
                      builder: (context, state) {
                        return AppTextField(
                          label: 'Phone Number',
                          hintText: 'Enter your phone number',
                          controller: _phoneController,
                          isRequired: true,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          onChanged: (value) {
                            context.read<AuthBloc>().add(LoginPhoneChanged(value));
                          },
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Phone number is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Password Input Field
                    BlocBuilder<AuthBloc, AuthState>(
                      buildWhen: (previous, current) =>
                          previous.isPasswordObscured != current.isPasswordObscured ||
                          previous.password != current.password,
                      builder: (context, state) {
                        return AppTextField(
                          label: 'Password',
                          hintText: 'Enter your password',
                          controller: _passwordController,
                          isRequired: true,
                          obscureText: state.isPasswordObscured,
                          prefixIcon: Icons.lock_outline,
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.isPasswordObscured
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                              color: Colors.grey.shade600,
                            ),
                            onPressed: () {
                              context.read<AuthBloc>().add(const TogglePasswordVisibility());
                            },
                          ),
                          onChanged: (value) {
                            context.read<AuthBloc>().add(LoginPasswordChanged(value));
                          },
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Password is required';
                            }
                            return null;
                          },
                        );
                      },
                    ),

                    const SizedBox(height: 14),

                    // Remember Me & Forgot Password Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        BlocBuilder<AuthBloc, AuthState>(
                          buildWhen: (previous, current) =>
                              previous.rememberMe != current.rememberMe,
                          builder: (context, state) {
                            return Row(
                              children: [
                                SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: Checkbox(
                                    value: state.rememberMe,
                                    activeColor: buttonColor1,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (_) {
                                      context.read<AuthBloc>().add(const ToggleRememberMe());
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                GestureDetector(
                                  onTap: () {
                                    context.read<AuthBloc>().add(const ToggleRememberMe());
                                  },
                                  child: const AppText.label(
                                    'Remember me',
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                        TextButton(
                          onPressed: () {},
                          style: TextButton.styleFrom(
                            padding: EdgeInsets.zero,
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(
                              fontSize: 13,
                              color: buttonColor1,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Login Button (Green buttonColor1: #059669)
                    BlocBuilder<AuthBloc, AuthState>(
                      builder: (context, state) {
                        return AppButton(
                          text: 'Sign In',
                          backgroundColor: buttonColor1, // #059669
                          isLoading: state.status == AuthStatus.loading,
                          onPressed: _submitLogin,
                        );
                      },
                    ),

                    const SizedBox(height: 36),

                    // Footer Sign-Up Prompt Connection
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AppText(
                          "Don't have an account? ",
                          color: Colors.grey.shade600,
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const RegisterCompanyView(),
                              ),
                            );
                          },
                          child: const Text(
                            'Sign Up',
                            style: TextStyle(
                              color: buttonColor1,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                              fontFamily: 'Urbanist',
                            ),
                          ),
                        ),
                      ],
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
