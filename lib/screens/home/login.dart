import 'package:Koinos/colors.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../routes/routes.dart';
import '../../services/auth_service.dart';
import '../../utils/window_size.dart';
import '../../widgets/auth_background.dart';
import '../../widgets/button.dart';
import '../../widgets/custom_text_form_field.dart';

class Login extends StatefulWidget {
  const Login({super.key});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authService = Provider.of<AuthService>(context, listen: false);
    final error = await authService.signIn(
      username: _usernameController.text,
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);
    if (error != null) {
      final String message;
      switch (error) {
        case 'CREDENTIALS_ERROR':
          message = 'Usuario o contraseña incorrectos';
          break;
        case 'NETWORK_ERROR':
          message = 'No hay conexión con el servidor';
          break;
        default:
          message = 'Error al intentar iniciar sesión';
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), backgroundColor: negativeColor),
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.dashboard,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: secondaryBackground,
      resizeToAvoidBottomInset: true,
      body: context.isCompact ? _buildMobile(context) : _buildWeb(context),
    );
  }

  // --- WEB: panel azul de marca + panel blanco con formulario ---
  Widget _buildWeb(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: BlobBackground(
            child: Stack(
              children: [
                SafeArea(
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: infoColor),
                      onPressed: () => Navigator.maybePop(context),
                    ),
                  ),
                ),
                const Center(child: BrandLockup()),
              ],
            ),
          ),
        ),
        Expanded(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 400),
                      child: _buildForm(context),
                    ),
                  ),
                ),
              ),
              const AuthFooter(color: secondaryText),
            ],
          ),
        ),
      ],
    );
  }

  // --- MÓVIL: top azul con onda + formulario blanco (desplazable) ---
  Widget _buildMobile(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ClipPath(
            clipper: BottomWaveClipper(),
            child: SizedBox(
              height: 280,
              child: BlobBackground(
                child: SafeArea(
                  bottom: false,
                  child: Stack(
                    children: [
                      Align(
                        alignment: Alignment.topLeft,
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: infoColor),
                          onPressed: () => Navigator.maybePop(context),
                        ),
                      ),
                      const Center(child: BrandLockup(compact: true)),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 8),
            child: _buildForm(context),
          ),
          const AuthFooter(color: secondaryText),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildForm(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Bienvenido', style: textTheme.headlineMedium),
          const SizedBox(height: 4),
          Text(
            'Inicia sesión para continuar',
            style: textTheme.bodyMedium?.copyWith(color: secondaryText),
          ),
          const SizedBox(height: 28),
          CustomTextFormField(
            controller: _usernameController,
            keyboardType: TextInputType.text,
            labelText: 'Nombre de usuario',
            isRequired: true,
            prefixIcon: const Icon(Icons.person_outline),
            textInputAction: TextInputAction.next,
            validator: (value) =>
                value!.isEmpty ? 'Ingresa tu usuario' : null,
          ),
          const SizedBox(height: 18),
          CustomTextFormField(
            controller: _passwordController,
            obscureText: true,
            labelText: 'Contraseña',
            isRequired: true,
            prefixIcon: const Icon(Icons.lock_outline),
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => _handleLogin(),
            validator: (value) =>
                value!.length < 3 ? 'Mínimo 3 caracteres' : null,
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            child: Button(
              size: const Size.fromHeight(52),
              text: 'Iniciar sesión',
              icon: Icons.login_rounded,
              isLoading: _isLoading,
              onPressed: _handleLogin,
            ),
          ),
        ],
      ),
    );
  }
}
