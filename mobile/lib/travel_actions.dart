import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'models.dart';

Future<String?> chooseTravelMode(BuildContext context) =>
    showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                'Como você vai?',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
            for (final mode in [
              ('walking', 'A pé', Icons.directions_walk),
              ('driving', 'De carro', Icons.directions_car),
              ('transit', 'Transporte público', Icons.directions_bus),
            ])
              ListTile(
                leading: Icon(mode.$3),
                title: Text(mode.$2),
                onTap: () => Navigator.pop(context, mode.$1),
              ),
          ],
        ),
      ),
    );

Uri routeUri(Place p, {String mode = 'walking', Place? origin}) =>
    Uri.https('www.google.com', '/maps/dir/', {
      'api': '1',
      'destination': '${p.lat},${p.lng}',
      'travelmode': mode,
      if (origin != null) 'origin': '${origin.lat},${origin.lng}',
    });

Future<void> shareTrip(BuildContext context, List<Place> places) async {
  final text =
      'Meu roteiro • Hippie Turismo\n\n${[for (var i = 0; i < places.length; i++) '${i + 1}. ${places[i].name}\n${places[i].address}\n${places[i].hours} • ${places[i].priceLabel}\n${routeUri(places[i])}'].join('\n\n')}\n\nEntradas estimadas: R\$ ${places.fold<double>(0, (sum, p) => sum + p.price).toStringAsFixed(2)}. Transporte e alimentação não incluídos.${places.any((p) => p.demo) ? '\nRoteiro demonstrativo com locais fictícios.' : ''}';
  await showModalBottomSheet<void>(
    context: context,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Compartilhar roteiro',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.copy),
            title: const Text('Copiar roteiro e links'),
            onTap: () async {
              await Clipboard.setData(ClipboardData(text: text));
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Roteiro copiado.')),
                );
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.chat_outlined),
            title: const Text('Enviar pelo WhatsApp'),
            onTap: () async {
              final ok = await launchUrl(
                Uri.https('wa.me', '/', {'text': text}),
                mode: LaunchMode.externalApplication,
              );
              if (context.mounted) {
                Navigator.pop(context);
                if (!ok) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Não foi possível abrir o WhatsApp. Use Copiar roteiro.',
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
    ),
  );
}

Future<void> showRecoveryCode(
  BuildContext context,
  String code,
) => showDialog<void>(
  context: context,
  barrierDismissible: false,
  builder: (context) => AlertDialog(
    title: const Text('Guarde seu código de recuperação'),
    content: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Este código permite trocar sua senha no ambiente local. Guarde-o em um lugar seguro; ele será exibido apenas agora.',
        ),
        const SizedBox(height: 16),
        SelectableText(code),
      ],
    ),
    actions: [
      TextButton(
        onPressed: () async {
          await Clipboard.setData(ClipboardData(text: code));
        },
        child: const Text('Copiar código'),
      ),
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Guardei o código'),
      ),
    ],
  ),
);
