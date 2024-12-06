import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../widgets/status_card.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';
import '../../services/mqtt_manager.dart';
import 'ideal_config_screen.dart';
import '../../widgets/ideal_config_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MqttManager mqttManager = MqttManager();

//topicos para os envio de informação dos botões manuais do app para o esp32 via mqtt
  final String irrigationTopic = 'estufa/controle/irrigacao';
  final String fanTopic = 'estufa/controle/exaustor';
  final String lightTopic = 'estufa/controle/iluminacao';
  final String ventilatorTopic = 'estufa/controle/ventilador';

//variaveis de controle dos botões
  bool irrigacaoLigada = false;
  bool exaustorLigado = false;
  bool ventilatorLigado = false;
  bool iluminacaoLigada = false;

  //as variaveis dos sensores
  String temperature = '0°C';
  String humidityAir = '0%';
  String soilMoisture = '0%';

  // variáveis para armazenar os valores configurados
  double temperaturaIdeal = 0;
  double umidadeArIdeal = 0;
  double umidadeSoloIdeal = 0;
  TimeOfDay horarioInicioIluminacao = TimeOfDay(hour: 0, minute: 0);
  TimeOfDay horarioFimIluminacao = TimeOfDay(hour: 0, minute: 0);
  Color corIluminacao = Colors.black;
  double intensidadeIluminacao = 0;

  @override
  void initState() {
    super.initState();
    connectMqtt(); // Estabelecer conexão ao inicializar a tela
  }

  Future<void> connectMqtt() async {
    await mqttManager.connect();

    // Inscrever-se nos tópicos relevantes
    mqttManager
        .subscribe('estufa/botoes'); // Inscrição para receber comandos de botão
    mqttManager.subscribe(
        'estufa/sensores'); // Inscrição para dados de sensores (já existente)

    mqttManager.client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttReceivedMessage<MqttMessage> message = c[0];
      final payload = message.payload as MqttPublishMessage;

      // Mensagem recebida como string JSON
      final String messageContent =
          MqttPublishPayload.bytesToStringAsString(payload.payload.message);

      try {
        final String topic = message.topic;

        if (topic == 'estufa/botoes') {
          // Processar mensagens de controle de botões
          final Map<String, dynamic> data = jsonDecode(messageContent);
          final String button = data['button'];
          final bool state = data['state'];

          setState(() {
            switch (button) {
              case 'bomba':
                irrigacaoLigada = state;
                break;
              case 'ledRgb':
                iluminacaoLigada = state;
                break;
              case 'cooler1':
                ventilatorLigado = state;
                break;
              case 'cooler2':
                exaustorLigado = state;
                break;
            }
          });
        } else if (topic == 'estufa/sensores') {
          // Processar mensagens de sensores (como no seu código atual)
          final Map<String, dynamic> data = jsonDecode(messageContent);
          setState(() {
            temperature = "${data['temperatura']}°C";
            humidityAir = "${data['umidade_ar']}%";
            soilMoisture = "${data['umidade_solo']}%";
          });
        }
      } catch (e) {
        print('Erro ao processar mensagem MQTT: $e');
      }
    });
  }

  @override
  void dispose() {
    mqttManager.disconnect();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.cyan,
        title: const Text('Estufa Automatizada'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SettingsScreen()),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.tune), // Ícone para configurações ideais
            onPressed: () async {
              // Navegar para a tela de configurações ideais e esperar pelos dados de volta
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      IdealConfigScreen(mqttManager: mqttManager),
                ),
              );

              if (result != null) {
                setState(() {
                  // Atualizar as configurações ideais com os dados retornados
                  temperaturaIdeal = result['temperaturaIdeal'];
                  umidadeArIdeal = result['umidadeArIdeal'];
                  umidadeSoloIdeal = result['umidadeSoloIdeal'];
                  horarioInicioIluminacao = result['horarioInicioIluminacao'];
                  horarioFimIluminacao = result['horarioFimIluminacao'];
                  corIluminacao = result['corIluminacao'];
                  intensidadeIluminacao = result['intensidadeIluminacao'];
                });
              }
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView( // Adicionei `child` aqui
          child: Column(
            children: [
              IdealConfigCard(
                temperaturaIdeal: temperaturaIdeal,
                umidadeArIdeal: umidadeArIdeal,
                umidadeSoloIdeal: umidadeSoloIdeal,
                horarioInicioIluminacao: horarioInicioIluminacao,
                horarioFimIluminacao: horarioFimIluminacao,
                corIluminacao: corIluminacao,
                intensidadeIluminacao: intensidadeIluminacao,
              ),
              StatusCard(
                title: 'Temperatura',
                value: temperature,
                icon: Icons.thermostat_outlined,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        title: 'Temperatura',
                        data: [
                          {'time': '08:00', 'value': '23°C'},
                          {'time': '12:00', 'value': '25°C'},
                        ],
                      ),
                    ),
                  );
                },
              ),
              StatusCard(
                title: 'Umidade do Ar',
                value: humidityAir,
                icon: Icons.water_drop,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        title: 'Umidade do Ar',
                        data: [
                          {'time': '08:00', 'value': '55%'},
                          {'time': '12:00', 'value': '60%'},
                        ],
                      ),
                    ),
                  );
                },
              ),
              StatusCard(
                title: 'Umidade do Solo',
                value: soilMoisture,
                icon: Icons.grass,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DetailScreen(
                        title: 'Umidade do Solo',
                        data: [
                          {'time': '08:00', 'value': '40%'},
                          {'time': '12:00', 'value': '45%'},
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              SwitchListTile(
                title: const Text('Irrigação'),
                value: irrigacaoLigada,
                onChanged: (bool value) {
                  setState(() {
                    irrigacaoLigada = value;
                  });
                  final String message = value ? 'ligar' : 'desligar';
                  mqttManager.publish(irrigationTopic, message);
                },
                secondary: Icon(
                  irrigacaoLigada ? Icons.water : Icons.water_outlined,
                  color: irrigacaoLigada ? Colors.blue : Colors.grey,
                ),
              ),
              SwitchListTile(
                title: const Text('Exaustor'),
                value: exaustorLigado,
                onChanged: (bool value) {
                  setState(() {
                    exaustorLigado = value;
                  });
                  final String message = value ? 'ligar' : 'desligar';
                  mqttManager.publish(fanTopic, message);
                },
                secondary: Icon(
                  exaustorLigado ? Icons.air : Icons.air_outlined,
                  color: exaustorLigado ? Colors.deepOrangeAccent : Colors.grey,
                ),
              ),
              SwitchListTile(
                title: const Text('Ventilador'),
                value: ventilatorLigado,
                onChanged: (bool value) {
                  setState(() {
                    ventilatorLigado = value;
                  });
                  final String message = value ? 'ligar' : 'desligar';
                  mqttManager.publish(ventilatorTopic, message);
                },
                secondary: Icon(
                  ventilatorLigado ? Icons.wind_power : Icons.wind_power_outlined,
                  color: ventilatorLigado ? Colors.cyan : Colors.grey,
                ),
              ),
              SwitchListTile(
                title: const Text('Iluminação'),
                value: iluminacaoLigada,
                onChanged: (bool value) {
                  setState(() {
                    iluminacaoLigada = value;
                  });
                  final String message = value ? 'ligar' : 'desligar';
                  mqttManager.publish(lightTopic, message);
                },
                secondary: Icon(
                  iluminacaoLigada ? Icons.lightbulb : Icons.lightbulb_outline,
                  color: iluminacaoLigada ? Colors.yellow : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
}
