import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/validation/app_validators.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() {
    return _SignInPageState();
  }
}

class _SignInPageState extends State<SignInPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _confirmPasswordController;

  bool _isCreatingAccount = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();

    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();

    super.dispose();
  }

  void _submit() {
    FocusScope.of(context).unfocus();

    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) {
      return;
    }

    final authCubit = context.read<AuthCubit>();

    if (_isCreatingAccount) {
      authCubit.createUserWithEmailAndPassword(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );

      return;
    }

    authCubit.signInWithEmailAndPassword(
      email: _emailController.text.trim(),
      password: _passwordController.text,
    );
  }

  void _changeMode() {
    FocusScope.of(context).unfocus();

    setState(() {
      _isCreatingAccount = !_isCreatingAccount;
      _obscurePassword = true;
      _obscureConfirmPassword = true;
    });

    _formKey.currentState?.reset();
    context.read<AuthCubit>().clearMessages();
  }

  Future<void> _showResetPasswordDialog() async {
    final emailController = TextEditingController(
      text: _emailController.text.trim(),
    );

    final resetFormKey = GlobalKey<FormState>();

    final email = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reset password'),
          content: Form(
            key: resetFormKey,
            child: TextFormField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.done,
              autofillHints: const [
                AutofillHints.email,
              ],
              validator: AppValidators.email,
              decoration: const InputDecoration(
                labelText: 'Email address',
                hintText: 'name@example.com',
                prefixIcon: Icon(
                  Icons.email_outlined,
                ),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final isValid =
                    resetFormKey.currentState?.validate() ?? false;

                if (!isValid) {
                  return;
                }

                Navigator.of(dialogContext).pop(
                  emailController.text.trim(),
                );
              },
              child: const Text('Send email'),
            ),
          ],
        );
      },
    );

    emailController.dispose();

    if (email == null || email.isEmpty || !mounted) {
      return;
    }

    await context.read<AuthCubit>().sendPasswordResetEmail(
      email: email,
    );
  }

  void _showMessage({
    required String message,
    required bool isError,
  }) {
    final colorScheme = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor:
          isError ? colorScheme.error : colorScheme.primary,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: BlocConsumer<AuthCubit, AuthState>(
          listenWhen: (previous, current) {
            return previous.errorMessage != current.errorMessage ||
                previous.successMessage != current.successMessage;
          },
          listener: (context, state) {
            final errorMessage = state.errorMessage;
            final successMessage = state.successMessage;

            if (errorMessage != null) {
              _showMessage(
                message: errorMessage,
                isError: true,
              );
            } else if (successMessage != null) {
              _showMessage(
                message: successMessage,
                isError: false,
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.isLoading;

            return SingleChildScrollView(
              keyboardDismissBehavior:
              ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(
                24,
                32,
                24,
                24,
              ),
              child: Form(
                key: _formKey,
                child: AutofillGroup(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 32),
                      if (_isCreatingAccount) ...[
                        TextFormField(
                          controller: _nameController,
                          enabled: !isLoading,
                          keyboardType: TextInputType.name,
                          textCapitalization:
                          TextCapitalization.words,
                          textInputAction: TextInputAction.next,
                          autofillHints: const [
                            AutofillHints.name,
                          ],
                          validator: AppValidators.name,
                          decoration: const InputDecoration(
                            labelText: 'Full name',
                            prefixIcon: Icon(
                              Icons.person_outline_rounded,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                      ],
                      TextFormField(
                        controller: _emailController,
                        enabled: !isLoading,
                        keyboardType:
                        TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.email,
                        ],
                        validator: AppValidators.email,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          hintText: 'name@example.com',
                          prefixIcon: Icon(
                            Icons.email_outlined,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _passwordController,
                        enabled: !isLoading,
                        obscureText: _obscurePassword,
                        textInputAction:
                        _isCreatingAccount
                            ? TextInputAction.next
                            : TextInputAction.done,
                        autofillHints: [
                          _isCreatingAccount
                              ? AutofillHints.newPassword
                              : AutofillHints.password,
                        ],
                        validator:
                        _isCreatingAccount
                            ? AppValidators.strongPassword
                            : AppValidators.password,
                        onFieldSubmitted: (_) {
                          if (!_isCreatingAccount) {
                            _submit();
                          }
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
                          prefixIcon: const Icon(
                            Icons.lock_outline_rounded,
                          ),
                          suffixIcon: IconButton(
                            tooltip:
                            _obscurePassword
                                ? 'Show password'
                                : 'Hide password',
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
                      ),
                      if (_isCreatingAccount) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          controller:
                          _confirmPasswordController,
                          enabled: !isLoading,
                          obscureText:
                          _obscureConfirmPassword,
                          textInputAction:
                          TextInputAction.done,
                          autofillHints: const [
                            AutofillHints.newPassword,
                          ],
                          validator: (value) {
                            return AppValidators.confirmPassword(
                              value: value,
                              password:
                              _passwordController.text,
                            );
                          },
                          onFieldSubmitted: (_) {
                            _submit();
                          },
                          decoration: InputDecoration(
                            labelText: 'Confirm password',
                            prefixIcon: const Icon(
                              Icons.lock_reset_rounded,
                            ),
                            suffixIcon: IconButton(
                              tooltip:
                              _obscureConfirmPassword
                                  ? 'Show password'
                                  : 'Hide password',
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                  !_obscureConfirmPassword;
                                });
                              },
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                              ),
                            ),
                          ),
                        ),
                      ],
                      if (!_isCreatingAccount)
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed:
                            isLoading
                                ? null
                                : _showResetPasswordDialog,
                            child: const Text(
                              'Forgot password?',
                            ),
                          ),
                        )
                      else
                        const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: FilledButton(
                          onPressed:
                          isLoading ? null : _submit,
                          child:
                          isLoading
                              ? const SizedBox(
                            width: 22,
                            height: 22,
                            child:
                            CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                              : Text(
                            _isCreatingAccount
                                ? 'Create account'
                                : 'Sign in',
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding:
                            const EdgeInsets.symmetric(
                              horizontal: 12,
                            ),
                            child: Text(
                              'or continue with',
                              style:
                              Theme.of(
                                context,
                              ).textTheme.bodySmall,
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),
                      const SizedBox(height: 18),
                      SizedBox(
                        height: 52,
                        child: OutlinedButton.icon(
                          onPressed:
                          isLoading
                              ? null
                              : () {
                            FocusScope.of(
                              context,
                            ).unfocus();

                            context
                                .read<AuthCubit>()
                                .signInWithGoogle();
                          },
                          icon: const Icon(
                            Icons.g_mobiledata_rounded,
                            size: 30,
                          ),
                          label: const Text(
                            'Continue with Google',
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment:
                        MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: Text(
                              _isCreatingAccount
                                  ? 'Already have an account?'
                                  : "Don't have an account?",
                            ),
                          ),
                          TextButton(
                            onPressed:
                            isLoading ? null : _changeMode,
                            child: Text(
                              _isCreatingAccount
                                  ? 'Sign in'
                                  : 'Create account',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By continuing, you agree to our Terms of Service and Privacy Policy.',
                        textAlign: TextAlign.center,
                        style:
                        Theme.of(
                          context,
                        ).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final theme = Theme.of(context);

    return Column(
      children: [
        Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(30),
          ),
          child: Icon(
            Icons.auto_stories_rounded,
            size: 52,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          _isCreatingAccount
              ? 'Create your account'
              : 'Welcome to ArticleFlow',
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineMedium,
        ),
        const SizedBox(height: 10),
        Text(
          _isCreatingAccount
              ? 'Create an account to save your favorite articles and continue reading anywhere.'
              : 'Sign in to discover inspiring stories and access your saved articles.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}