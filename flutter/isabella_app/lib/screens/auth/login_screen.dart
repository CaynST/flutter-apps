import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/auth_exception.dart';
import '../../core/theme.dart';
import '../../core/validators.dart';
import '../../services/analytics_service.dart';
import '../../services/auth_service.dart';
import '../../widgets/seal.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
    required this.authService,
    this.analytics,
    this.googleSignInAvailable = kIsWeb,
  });

  final AuthService authService;
  final AnalyticsService? analytics;
  final bool googleSignInAvailable;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  Future<void> _run(Future<void> Function() action) async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await action();
    } on AuthException catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'No se pudo completar la operación. Inténtalo de nuevo.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    await _run(() async {
      await widget.authService.signIn(
        email: _email.text,
        password: _password.text,
      );
      await widget.analytics?.logLogin('password');
      await widget.analytics?.setUserPlan('free');
    });
  }

  Future<void> _google() async {
    if (!widget.googleSignInAvailable) {
      setState(
        () => _error = 'El acceso con Google está disponible en la versión web.',
      );
      return;
    }
    await _run(() async {
      await widget.authService.signInWithGoogle();
      await widget.analytics?.logLogin('google');
    });
  }

  Future<void> _resetPassword() async {
    final String email = _email.text.trim();
    if (email.isEmpty) {
      setState(() => _error = 'Escribe tu correo primero.');
      return;
    }
    await _run(() async {
      await widget.authService.sendPasswordReset(email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Te enviamos un correo para restablecer la contraseña.'),
          ),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(28, 40, 28, 32),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 380),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  const Center(child: Seal(label: 'I', size: 64)),
                  const SizedBox(height: 22),
                  Text(
                    'Isabella',
                    textAlign: TextAlign.center,
                    style: fraunces(size: 38, letterSpacing: -0.8),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Lo que tengas que hacer,\nen una sola página.',
                    textAlign: TextAlign.center,
                    style: karla(size: 15, color: pencil, height: 1.5),
                  ),
                  const SizedBox(height: 40),
                  TextFormField(
                    key: const Key('login-email'),
                    controller: _email,
                    keyboardType: TextInputType.emailAddress,
                    autofillHints: const <String>[AutofillHints.email],
                    style: karla(size: 16),
                    decoration: const InputDecoration(labelText: 'Correo'),
                    validator: emailValidator,
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    key: const Key('login-password'),
                    controller: _password,
                    obscureText: true,
                    autofillHints: const <String>[AutofillHints.password],
                    style: karla(size: 16),
                    decoration: const InputDecoration(labelText: 'Contraseña'),
                    validator: passwordValidator,
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  if (_error != null) ...<Widget>[
                    const SizedBox(height: 14),
                    Text(
                      _error!,
                      style: karla(size: 13.5, color: errorInk),
                    ),
                  ],
                  const SizedBox(height: 28),
                  FilledButton(
                    key: const Key('login-submit'),
                    onPressed: _loading ? null : _submit,
                    child: _loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: paper,
                            ),
                          )
                        : const Text('Entrar'),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: <Widget>[
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          'o',
                          style: karla(size: 12, color: pencil),
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 20),
                  OutlinedButton.icon(
                    key: const Key('login-google'),
                    onPressed: _loading ? null : _google,
                    icon: const Icon(Icons.g_mobiledata, size: 26),
                    label: const Text('Continuar con Google'),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: _loading ? null : _resetPassword,
                    child: const Text('¿Olvidaste tu contraseña?'),
                  ),
                  const SizedBox(height: 4),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: <Widget>[
                      Text(
                        '¿No tienes cuenta?',
                        style: karla(size: 14, color: pencil),
                      ),
                      TextButton(
                        onPressed: _loading
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => RegisterScreen(
                                      authService: widget.authService,
                                      analytics: widget.analytics,
                                    ),
                                  ),
                                ),
                        child: const Text('Regístrate'),
                      ),
                    ],
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
