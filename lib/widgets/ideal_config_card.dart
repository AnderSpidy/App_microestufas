import 'package:flutter/material.dart';

class IdealConfigCard extends StatelessWidget {
  final double temperaturaIdeal;
  final double umidadeArIdeal;
  final double umidadeSoloIdeal;
  final TimeOfDay horarioInicioIluminacao;
  final TimeOfDay horarioFimIluminacao;
  final Color corIluminacao;
  final double intensidadeIluminacao;

  const IdealConfigCard({
    Key? key,
    required this.temperaturaIdeal,
    required this.umidadeArIdeal,
    required this.umidadeSoloIdeal,
    required this.horarioInicioIluminacao,
    required this.horarioFimIluminacao,
    required this.corIluminacao,
    required this.intensidadeIluminacao,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Configurações Ideais",
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text("Temperatura: ${temperaturaIdeal.toStringAsFixed(1)}°C"),
            Text("Umidade do Ar: ${umidadeArIdeal.toStringAsFixed(1)}%"),
            Text("Umidade do Solo: ${umidadeSoloIdeal.toStringAsFixed(1)}%"),
            Text(
              "Iluminação: ${horarioInicioIluminacao.format(context)} - ${horarioFimIluminacao.format(context)}",
            ),
            Row(
              children: [
                const Text("Cor da Iluminação:"),
                const SizedBox(width: 8),
                Container(
                  width: 24,
                  height: 24,
                  color: corIluminacao,
                ),
              ],
            ),
            Text("Intensidade da Iluminação: ${intensidadeIluminacao.toStringAsFixed(0)}%"),
          ],
        ),
      ),
    );
  }
}
