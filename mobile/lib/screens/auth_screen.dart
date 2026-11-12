import '../travel_actions.dart';
import 'package:flutter/material.dart';
import '../app_state.dart';
import '../app_theme.dart';
import '../config.dart';
import '../widgets/travel_art.dart';

class AuthScreen extends StatefulWidget {
  final AppState state;
  const AuthScreen({super.key, required this.state});
  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController(),
      _password = TextEditingController(),
      _name = TextEditingController();
  bool _register = false, _busy = false, _obscure = true;
  String? _error;
  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _name.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await widget.state.authenticate(
        _email.text.trim(),
        _password.text,
        name: _register ? _name.text.trim() : null,
      );
    } catch (e) {
      if (mounted) setState(() => _error = messageFor(e));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _recover() async {
    final email = TextEditingController(text: _email.text.trim());
    final code = TextEditingController();
    final password = TextEditingController();
    final form = GlobalKey<FormState>();
    var busy = false;
    String? failure;
    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Recuperar acesso'),
          content: SingleChildScrollView(
            child: Form(
              key: form,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    Config.demo
                        ? 'Use o código que você guardou ao criar sua conta.'
                        : 'Enviaremos as instruções para seu e-mail.',
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: email,
                    decoration: const InputDecoration(labelText: 'E-mail'),
                    validator: (v) => v != null && v.contains('@')
                        ? null
                        : 'Informe um e-mail válido.',
                  ),
                  if (Config.demo) ...[
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: code,
                      decoration: const InputDecoration(
                        labelText: 'Código de recuperação',
                      ),
                      validator: (v) => (v ?? '').trim().length == 32
                          ? null
                          : 'Informe o código de 32 caracteres.',
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: password,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: 'Nova senha',
                      ),
                      validator: (v) => (v ?? '').length >= 8
                          ? null
                          : 'Use pelo menos 8 caracteres.',
                    ),
                  ],
                  if (failure != null) Text(failure!),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: busy ? null : () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: busy
                  ? null
                  : () async {
                      if (!form.currentState!.validate()) return;
                      setDialog(() => busy = true);
                      try {
                        final next = await widget.state.recoverPassword(
                          email.text.trim(),
                          code: code.text.trim(),
                          password: password.text,
                        );
                        if (!context.mounted) return;
                        Navigator.pop(context);
                        if (next != null && mounted) {
                          await showRecoveryCode(this.context, next);
                        }
                        if (mounted) {
                          ScaffoldMessenger.of(this.context).showSnackBar(
                            SnackBar(
                              content: Text(
                                Config.demo
                                    ? 'Senha atualizada. Entre com a nova senha.'
                                    : 'Se a conta existir, você receberá as instruções por e-mail.',
                              ),
                            ),
                          );
                        }
                      } catch (e) {
                        if (context.mounted) {
                          setDialog(() => failure = messageFor(e));
                        }
                      } finally {
                        if (context.mounted) setDialog(() => busy = false);
                      }
                    },
              child: Text(busy ? 'Aguarde…' : 'Recuperar'),
            ),
          ],
        ),
      ),
    );
    // Wait for the closing transition before disposing controllers.
    await Future<void>.delayed(const Duration(milliseconds: 300));
    email.dispose();
    code.dispose();
    password.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.primaryDark,
    body: Stack(
      children: [
        const Positioned.fill(child: _AuthBackdrop()),
        SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 30),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 460),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: HippieWordmark(light: true),
                    ),
                    const SizedBox(height: 30),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _register
                                ? 'Comece uma nova\nhistória.'
                                : 'O mundo está\nlogo ali.',
                            style: const TextStyle(
                              fontSize: 40,
                              height: .98,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -1.8,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 13),
                          Text(
                            _register
                                ? 'Crie sua conta e guarde cada descoberta.'
                                : 'Entre para descobrir lugares, caminhos e sabores perto de você.',
                            style: TextStyle(
                              fontSize: 16,
                              height: 1.45,
                              color: Colors.white.withValues(alpha: .78),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    AnimatedSize(
                      duration: const Duration(milliseconds: 280),
                      curve: Curves.easeOutCubic,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
                        decoration: BoxDecoration(
                          color: AppColors.background,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x45000000),
                              blurRadius: 38,
                              offset: Offset(0, 18),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _form,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 42,
                                    height: 42,
                                    decoration: BoxDecoration(
                                      color: AppColors.accentSoft,
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Icon(
                                      _register
                                          ? Icons.person_add_alt_1_rounded
                                          : Icons.waving_hand_rounded,
                                      color: AppColors.accent,
                                      size: 22,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _register
                                              ? 'Crie sua conta'
                                              : 'Que bom ter você aqui',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.titleLarge,
                                        ),
                                        Text(
                                          _register
                                              ? 'Leva menos de um minuto'
                                              : 'Continue sua jornada',
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodyMedium,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (Config.demo) ...[
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 13,
                                    vertical: 10,
                                  ),
                                  decoration: BoxDecoration(
                                    color: AppColors.accentSoft,
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.science_outlined,
                                        size: 18,
                                        color: AppColors.accent,
                                      ),
                                      SizedBox(width: 9),
                                      Expanded(
                                        child: Text(
                                          'Modo local • atrações reais e exemplos • dados salvos neste servidor',
                                          style: TextStyle(
                                            fontSize: 12.5,
                                            height: 1.35,
                                            color: AppColors.accentDark,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              const SizedBox(height: 18),
                              if (_register) ...[
                                TextFormField(
                                  controller: _name,
                                  textCapitalization: TextCapitalization.words,
                                  textInputAction: TextInputAction.next,
                                  decoration: const InputDecoration(
                                    labelText: 'Como podemos chamar você?',
                                    prefixIcon: Icon(
                                      Icons.person_outline_rounded,
                                    ),
                                  ),
                                  validator: (v) => (v ?? '').trim().length < 2
                                      ? 'Informe seu nome.'
                                      : null,
                                ),
                                const SizedBox(height: 13),
                              ],
                              TextFormField(
                                controller: _email,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Seu e-mail',
                                  prefixIcon: Icon(
                                    Icons.alternate_email_rounded,
                                  ),
                                ),
                                validator: (v) =>
                                    !RegExp(
                                      r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                    ).hasMatch(v?.trim() ?? '')
                                    ? 'Informe um e-mail válido.'
                                    : null,
                              ),
                              const SizedBox(height: 13),
                              TextFormField(
                                controller: _password,
                                obscureText: _obscure,
                                autofillHints: [
                                  _register
                                      ? AutofillHints.newPassword
                                      : AutofillHints.password,
                                ],
                                onFieldSubmitted: (_) =>
                                    _busy ? null : _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Sua senha',
                                  helperText: _register
                                      ? 'Pelo menos 8 caracteres'
                                      : null,
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: IconButton(
                                    tooltip: _obscure
                                        ? 'Mostrar senha'
                                        : 'Ocultar senha',
                                    onPressed: () =>
                                        setState(() => _obscure = !_obscure),
                                    icon: Icon(
                                      _obscure
                                          ? Icons.visibility_outlined
                                          : Icons.visibility_off_outlined,
                                    ),
                                  ),
                                ),
                                validator: (v) => (v ?? '').length < 8
                                    ? 'Use pelo menos 8 caracteres.'
                                    : null,
                              ),
                              if (!_register)
                                TextButton(
                                  onPressed: _busy ? null : _recover,
                                  child: const Text('Esqueci minha senha'),
                                ),
                              TextButton.icon(
                                onPressed: _busy
                                    ? null
                                    : () async {
                                        try {
                                          await widget.state.openOffline();
                                        } catch (e) {
                                          if (mounted) {
                                            setState(
                                              () => _error = messageFor(e),
                                            );
                                          }
                                        }
                                      },
                                icon: const Icon(Icons.offline_pin_outlined),
                                label: const Text('Consultar roteiro baixado'),
                              ),
                              if (_error != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 14),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.errorContainer,
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Text(
                                      _error!,
                                      style: TextStyle(
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.onErrorContainer,
                                      ),
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: FilledButton(
                                  onPressed: _busy ? null : _submit,
                                  child: _busy
                                      ? const SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              _register
                                                  ? 'Criar minha conta'
                                                  : 'Entrar e explorar',
                                            ),
                                            const SizedBox(width: 8),
                                            const Icon(
                                              Icons.arrow_forward_rounded,
                                              size: 19,
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Center(
                                child: TextButton(
                                  onPressed: _busy
                                      ? null
                                      : () => setState(() {
                                          _register = !_register;
                                          _error = null;
                                        }),
                                  child: Text(
                                    _register
                                        ? 'Já tenho conta • Entrar'
                                        : 'Primeira viagem? Crie sua conta',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.location_on_outlined,
                            size: 17,
                            color: Colors.white.withValues(alpha: .64),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Sua localização só é acessada com sua autorização.',
                              style: TextStyle(
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: .68),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

class _AuthBackdrop extends StatelessWidget {
  const _AuthBackdrop();
  @override
  Widget build(BuildContext context) =>
      CustomPaint(painter: _AuthBackdropPainter());
}

class _AuthBackdropPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final glow = Paint()
      ..shader =
          RadialGradient(
            colors: [
              AppColors.accent.withValues(alpha: .24),
              Colors.transparent,
            ],
          ).createShader(
            Rect.fromCircle(
              center: Offset(size.width * .92, size.height * .06),
              radius: size.width * .72,
            ),
          );
    canvas.drawRect(Offset.zero & size, glow);
    final hill = Path()
      ..moveTo(0, size.height * .28)
      ..quadraticBezierTo(
        size.width * .28,
        size.height * .19,
        size.width * .55,
        size.height * .3,
      )
      ..quadraticBezierTo(
        size.width * .8,
        size.height * .37,
        size.width,
        size.height * .23,
      )
      ..lineTo(size.width, 0)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(hill, Paint()..color = Colors.white.withValues(alpha: .08));
    for (var i = 0; i < 8; i++) {
      canvas.drawCircle(
        Offset(30.0 + i * 63, size.height * .22 + (i.isEven ? 8 : -4)),
        2.2,
        Paint()..color = AppColors.secondary.withValues(alpha: .70),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
