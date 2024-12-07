import 'dart:convert';
import 'package:estufas_automatizadas/widgets/save_preset.dart';
import 'package:flutter/material.dart';
import '../../services/mqtt_manager.dart';

class IdealConfigScreen extends StatefulWidget {
  final MqttManager mqttManager;

  const IdealConfigScreen({Key? key, required this.mqttManager})
      : super(key: key);

  @override
  _IdealConfigScreenState createState() => _IdealConfigScreenState();
}

class _IdealConfigScreenState extends State<IdealConfigScreen> {
  // Variáveis de controle
  double temperaturaIdeal = 15;
  double umidadeArIdeal = 20;
  double umidadeSoloIdeal = 10;
  TimeOfDay horarioInicioIluminacao = const TimeOfDay(hour: 0, minute: 0);
  TimeOfDay horarioFimIluminacao = const TimeOfDay(hour: 0, minute: 0);
  Color corIluminacao = Colors.black;
  double intensidadeIluminacao = 0;

  // Componentes RGB
  double red = 0;
  double green = 0;
  double blue = 0;

  // Métodos auxiliares para horário
  Future<void> _selecionarHorarioInicio(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horarioInicioIluminacao,
    );
    if (picked != null && picked != horarioInicioIluminacao) {
      setState(() {
        horarioInicioIluminacao = picked;
      });
    }
  }

  Future<void> _selecionarHorarioFim(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: horarioFimIluminacao,
    );
    if (picked != null && picked != horarioFimIluminacao) {
      setState(() {
        horarioFimIluminacao = picked;
      });
    }
  }

  void _atualizarCorIluminacao() {
    setState(() {
      corIluminacao =
          Color.fromRGBO(red.toInt(), green.toInt(), blue.toInt(), 1);
    });
  }

  // Método para salvar configurações
  void _saveConfigurations() {
    final configData = {
      'temperaturaIdeal': temperaturaIdeal,
      'umidadeArIdeal': umidadeArIdeal,
      'umidadeSoloIdeal': umidadeSoloIdeal,
      'horarioInicioIluminacao':
          '${horarioInicioIluminacao.hour}:${horarioInicioIluminacao.minute}',
      'horarioFimIluminacao':
          '${horarioFimIluminacao.hour}:${horarioFimIluminacao.minute}',
      'corIluminacaoR': '#${corIluminacao.red.toString()}',
      'corIluminacaoG': '#${corIluminacao.green.toString()}',
      'corIluminacaoB': '#${corIluminacao.blue.toString()}',
      'intensidadeIluminacao': intensidadeIluminacao.toInt(),
    };

    final jsonString = jsonEncode(configData);
    widget.mqttManager.publish('estufa/config', jsonString);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Configurações enviadas com sucesso!")),
    );
  }

  // Método para exibir o PresetDialog
  void _callPresetDialog(BuildContext context) {
    final configData = {
      'temperaturaIdeal': temperaturaIdeal,
      'umidadeArIdeal': umidadeArIdeal,
      'umidadeSoloIdeal': umidadeSoloIdeal,
      'horarioInicioIluminacao':
          '${horarioInicioIluminacao.hour}:${horarioInicioIluminacao.minute}',
      'horarioFimIluminacao':
          '${horarioFimIluminacao.hour}:${horarioFimIluminacao.minute}',
      'corIluminacaoR': '#${corIluminacao.red.toString()}',
      'corIluminacaoG': '#${corIluminacao.green.toString()}',
      'corIluminacaoB': '#${corIluminacao.blue.toString()}',
      'intensidadeIluminacao': intensidadeIluminacao.toInt(),
    };

    // Exibe o PresetDialog passando os dados de configuração
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return PresetDialog(configData: configData);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações Ideais"),
        backgroundColor: Colors.cyan,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Configuração de Temperatura
            Text('Temperatura Ideal: ${temperaturaIdeal.toStringAsFixed(1)}°C'),
            Slider(
              value: temperaturaIdeal,
              min: 15,
              max: 35,
              divisions: 20,
              label: "${temperaturaIdeal.toStringAsFixed(1)}°C",
              onChanged: (value) {
                setState(() {
                  temperaturaIdeal = value;
                });
              },
            ),
            const Divider(),

            // Configuração de Umidade do Ar
            Text('Umidade do Ar Ideal: ${umidadeArIdeal.toStringAsFixed(1)}%'),
            Slider(
              value: umidadeArIdeal,
              min: 20,
              max: 80,
              divisions: 60,
              label: "${umidadeArIdeal.toStringAsFixed(1)}%",
              onChanged: (value) {
                setState(() {
                  umidadeArIdeal = value;
                });
              },
            ),
            const Divider(),

            // Configuração de Umidade do Solo
            Text(
                'Umidade do Solo Ideal: ${umidadeSoloIdeal.toStringAsFixed(1)}%'),
            Slider(
              value: umidadeSoloIdeal,
              min: 10,
              max: 60,
              divisions: 50,
              label: "${umidadeSoloIdeal.toStringAsFixed(1)}%",
              onChanged: (value) {
                setState(() {
                  umidadeSoloIdeal = value;
                });
              },
            ),
            const Divider(),

            // Configuração de Horário de Iluminação
            ListTile(
              title: const Text('Horário Início Iluminação'),
              subtitle: Text(horarioInicioIluminacao.format(context)),
              trailing: const Icon(Icons.timer),
              onTap: () => _selecionarHorarioInicio(context),
            ),
            ListTile(
              title: const Text('Horário Fim Iluminação'),
              subtitle: Text(horarioFimIluminacao.format(context)),
              trailing: const Icon(Icons.timer_off),
              onTap: () => _selecionarHorarioFim(context),
            ),
            const Divider(),

            // Configuração de Cor da Iluminação com RGB
            ListTile(
              title: const Text('Cor da Iluminação (RGB)'),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Vermelho: ${red.toInt()}'),
                  Slider(
                    value: red,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: red.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        red = value;
                        _atualizarCorIluminacao();
                      });
                    },
                  ),
                  Text('Verde: ${green.toInt()}'),
                  Slider(
                    value: green,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: green.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        green = value;
                        _atualizarCorIluminacao();
                      });
                    },
                  ),
                  Text('Azul: ${blue.toInt()}'),
                  Slider(
                    value: blue,
                    min: 0,
                    max: 255,
                    divisions: 255,
                    label: blue.toInt().toString(),
                    onChanged: (value) {
                      setState(() {
                        blue = value;
                        _atualizarCorIluminacao();
                      });
                    },
                  ),
                ],
              ),
              trailing: Container(
                width: 24,
                height: 24,
                color: corIluminacao,
              ),
            ),
            const Divider(),

            // Configuração de Intensidade da Iluminação
            Text(
                'Intensidade da Iluminação: ${intensidadeIluminacao.toStringAsFixed(0)}%'),
            Slider(
              value: intensidadeIluminacao,
              min: 0,
              max: 100,
              divisions: 100,
              label: "${intensidadeIluminacao.toStringAsFixed(0)}%",
              onChanged: (value) {
                setState(() {
                  intensidadeIluminacao = value;
                });
              },
            ),
            const SizedBox(height: 32),

            ElevatedButton(
              onPressed: _saveConfigurations,
              child: const Text("Salvar Configurações"),
            ),
            ElevatedButton(
              onPressed: () =>
                  _callPresetDialog(context), // Chama o PresetDialog
              child: const Text("Salvar como favorito"),
            ),
          ],
        ),
      ),
    );
  }
}
