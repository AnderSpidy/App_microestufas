import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../widgets/status_card.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';
import '../../services/mqtt_manager.dart';
import 'ideal_config_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MqttManager mqttManager = MqttManager();

  final String irrigationTopic = 'estufa/controle/irrigacao';
  final String fanTopic = 'estufa/controle/exaustor';
  final String lightTopic = 'estufa/controle/iluminacao';

  String temperature = '0°C';
  String humidityAir = '0%';
  String soilMoisture = '0%';

  @override
  void initState() {
    super.initState();
    connectMqtt();
  }

  Future<void> connectMqtt() async {
    await mqttManager.connect();
    mqttManager.subscribe('estufa/sensores'); // Ouvir o tópico correto

    mqttManager.client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttReceivedMessage<MqttMessage> message = c[0];
      final payload = message.payload as MqttPublishMessage;

      // Mensagem recebida como string JSON
      final String messageContent =
          MqttPublishPayload.bytesToStringAsString(payload.payload.message);

      try {
        // Decodificar o JSON
        final Map<String, dynamic> data = jsonDecode(messageContent);

        // Atualizar os estados com os valores recebidos
        setState(() {
          temperature = "${data['temperatura']}°C";
          humidityAir = "${data['umidade_ar']}%";
          soilMoisture = "${data['umidade_solo']}%";
        });
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

  bool irrigacaoLigada = false;
  bool exaustorLigado = false;
  bool iluminacaoLigada = false;

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
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      IdealConfigScreen(mqttManager: mqttManager),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
                // Lógica para ativar/desativar a irrigação via MQTT
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
                color: exaustorLigado ? Colors.green : Colors.grey,
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
                // Lógica para ativar/desativar a iluminação via MQTT
              },
              secondary: Icon(
                iluminacaoLigada ? Icons.lightbulb : Icons.lightbulb_outline,
                color: iluminacaoLigada ? Colors.yellow : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
