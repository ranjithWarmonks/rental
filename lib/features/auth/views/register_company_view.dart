import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rental/features/auth/views/login_view.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_button.dart';
import 'package:rental/shared/widgets/app_text.dart';
import 'package:rental/shared/widgets/app_text_field.dart';
import '../controllers/auth_bloc.dart';
import '../controllers/auth_event.dart';
import '../controllers/auth_state.dart';
import '../models/register_company_model.dart';

class RegisterCompanyView extends StatelessWidget {
  const RegisterCompanyView({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      context.read<AuthBloc>();
      return const _RegisterCompanyForm();
    } catch (_) {
      return BlocProvider(
        create: (context) => AuthBloc(),
        child: const _RegisterCompanyForm(),
      );
    }
  }
}

class _RegisterCompanyForm extends StatefulWidget {
  const _RegisterCompanyForm();

  @override
  State<_RegisterCompanyForm> createState() => _RegisterCompanyFormState();
}

class _RegisterCompanyFormState extends State<_RegisterCompanyForm> {
  final _formKey = GlobalKey<FormState>();

  final _companyNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _gstController = TextEditingController();
  final _pincodeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _companyNameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _gstController.dispose();
    _pincodeController.dispose();
    super.dispose();
  }

  void _submitRegistration() {
    if (_formKey.currentState?.validate() ?? false) {
      final model = RegisterCompanyModel(
        companyName: _companyNameController.text.trim(),
        registeredAddress: _addressController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        contactEmail: _emailController.text.trim(),
        password: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
        gstNumber: _gstController.text.trim().isNotEmpty ? _gstController.text.trim() : null,
        pincode: _pincodeController.text.trim(),
      );

      context.read<AuthBloc>().add(RegisterCompanySubmitted(model));
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
              ),
            );
          } else if (state.status == AuthStatus.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Company registered successfully!',
                  style: TextStyle(color: Colors.white, fontFamily: 'Urbanist'),
                ),
                backgroundColor: buttonColor1,
                behavior: SnackBarBehavior.floating,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LoginView()),
            );
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 12),

                // Header Logo
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.real_estate_agent, color: buttonColor1, size: 28),
                    const SizedBox(width: 8),
                    AppText.h2(
                      'PropManage',
                      color: primaryColor,
                      fontSize: 22,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // Main Form Card Container
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText.h1(
                          'Create Your Company',
                          fontSize: 22,
                        ),
                        const SizedBox(height: 6),
                        AppText(
                          'Enter your company details to get started.',
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),

                        const SizedBox(height: 24),

                        // Company Name
                        AppTextField(
                          label: 'Company Name',
                          hintText: 'e.g. Acme Properties LLC',
                          controller: _companyNameController,
                          isRequired: true,
                          prefixIcon: Icons.business_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Company Name is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Registered Address
                        AppTextField(
                          label: 'Registered Address',
                          hintText: 'Street address, building, suite...',
                          controller: _addressController,
                          isRequired: true,
                          maxLines: 3,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Registered Address is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Phone Number
                        AppTextField(
                          label: 'Phone Number',
                          hintText: '(555) 000-0000',
                          controller: _phoneController,
                          isRequired: true,
                          keyboardType: TextInputType.phone,
                          prefixIcon: Icons.phone_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Phone Number is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Contact Email
                        AppTextField(
                          label: 'Contact Email',
                          hintText: 'hello@company.com',
                          controller: _emailController,
                          isRequired: true,
                          keyboardType: TextInputType.emailAddress,
                          prefixIcon: Icons.email_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Contact Email is required';
                            }
                            if (!val.contains('@')) {
                              return 'Enter a valid email address';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Password Field
                        AppTextField(
                          label: 'Password',
                          hintText: 'Enter password (min 6 chars)',
                          controller: _passwordController,
                          isRequired: true,
                          obscureText: _obscurePassword,
                          prefixIcon: Icons.lock_outline_rounded,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Password is required';
                            }
                            if (val.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // Confirm Password Field
                        AppTextField(
                          label: 'Confirm Password',
                          hintText: 'Re-enter password',
                          controller: _confirmPasswordController,
                          isRequired: true,
                          obscureText: _obscureConfirmPassword,
                          prefixIcon: Icons.lock_clock_outlined,
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                              color: Colors.grey,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Confirm Password is required';
                            }
                            if (val != _passwordController.text) {
                              return 'Passwords do not match';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 18),

                        // GST Number (Optional)
                        AppTextField(
                          label: 'GST Number',
                          hintText: 'Enter GSTIN',
                          controller: _gstController,
                          isOptional: true,
                          prefixIcon: Icons.receipt_long_outlined,
                        ),

                        const SizedBox(height: 18),

                        // Pincode / Zip
                        AppTextField(
                          label: 'Pincode / Zip',
                          hintText: 'e.g. 10001',
                          controller: _pincodeController,
                          isRequired: true,
                          keyboardType: TextInputType.number,
                          prefixIcon: Icons.location_on_outlined,
                          validator: (val) {
                            if (val == null || val.trim().isEmpty) {
                              return 'Pincode / Zip is required';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 28),

                        // Terms Footer
                        Center(
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey.shade600,
                                fontFamily: 'Urbanist',
                              ),
                              children: const [
                                TextSpan(text: 'By continuing, you agree to our '),
                                TextSpan(
                                  text: 'Terms of Service',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: ' and '),
                                TextSpan(
                                  text: 'Privacy Policy',
                                  style: TextStyle(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                TextSpan(text: '.'),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -3),
            ),
          ],
        ),
        child: SafeArea(
          child: BlocBuilder<AuthBloc, AuthState>(
            builder: (context, state) {
              return AppButton(
                text: 'Save & Continue',
                icon: Icons.arrow_forward_rounded,
                iconRight: true,
                isLoading: state.status == AuthStatus.loading,
                onPressed: _submitRegistration,
              );
            },
          ),
        ),
      ),
    );
  }
}
