import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import '../../widgets/status_card.dart';
import 'detail_screen.dart';
import 'settings_screen.dart';
import '../../services/mqtt_manager.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final MqttManager mqttManager = MqttManager();

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
    mqttManager.subscribe('sensor/temperatura');
    mqttManager.subscribe('sensor/umidade_ar');
    mqttManager.subscribe('sensor/umidade_solo');

    // Aqui você deve adicionar um listener para os tópicos

    mqttManager.client.updates!.listen((List<MqttReceivedMessage<MqttMessage>> c) {
      final MqttReceivedMessage<MqttMessage> message = c[0];
      final String topic = message.topic;
      final payload = message.payload as MqttPublishMessage;

      // Agora, você pode acessar a mensagem da seguinte forma
      final String messageContent = MqttPublishPayload.bytesToStringAsString(payload.payload.message);

      // Verifique qual tópico recebeu e atualize os valores
      switch (topic) {
        case 'sensor/temperatura':
          setState(() {
            temperature = messageContent; // Assumindo que o valor recebido é uma string
          });
          break;
        case 'sensor/umidade_ar':
          setState(() {
            humidityAir = messageContent;
          });
          break;
        case 'sensor/umidade_solo':
          setState(() {
            soilMoisture = messageContent;
          });
          break;
      }
    });

  }
  @override
  void dispose() {
    mqttManager.disconnect();
    super.dispose();
  }

  // Variáveis de estado para cada controle
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
            // Switch para Irrigação
            SwitchListTile(
              title: const Text('Irrigação'),
              value: irrigacaoLigada,
              onChanged: (bool value) {
                setState(() {
                  irrigacaoLigada = value;
                });
                // Adicione a lógica para ativar/desativar a irrigação via MQTT aqui
              },
              secondary: Icon(
                irrigacaoLigada ? Icons.water : Icons.water_outlined,
                color: irrigacaoLigada ? Colors.blue : Colors.grey,
              ),
            ),
            // Switch para Exaustor
            SwitchListTile(
              title: const Text('Exaustor'),
              value: exaustorLigado,
              onChanged: (bool value) {
                setState(() {
                  exaustorLigado = value;
                });
                // Adicione a lógica para ativar/desativar o exaustor via MQTT aqui
              },
              secondary: Icon(
                exaustorLigado ? Icons.air : Icons.air_outlined,
                color: exaustorLigado ? Colors.green : Colors.grey,
              ),
            ),
            // Switch para Iluminação
            SwitchListTile(
              title: const Text('Iluminação'),
              value: iluminacaoLigada,
              onChanged: (bool value) {
                setState(() {
                  iluminacaoLigada = value;
                });
                // Adicione a lógica para ativar/desativar a iluminação via MQTT aqui
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
