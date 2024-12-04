import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';


class MqttManager {
  final String broker = '10.1.3.85'; // URL ou IP do seu broker MQTT
  final String clientId = 'AndroidTest01';
  final String username = ''; // Insira o usuário do broker MQTT se necessário
  final String password = ''; // Insira a senha do broker MQTT se necessário
  late MqttServerClient client;

  MqttManager() {
    client = MqttServerClient(broker, clientId);
    client.port = 1883; // Porta padrão do MQTT, ajuste se necessário
    client.keepAlivePeriod = 20;
    client.onDisconnected = onDisconnected;
    client.onConnected = onConnected;
    client.onSubscribed = onSubscribed;
  }

  // Método para conectar ao broker

  Future<void> connect() async {
    client.connectionMessage = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .withWillTopic('willtopic')
        .withWillMessage('Desconectado')
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    try {
      await client.connect(username, password);
    } catch (e) {
      print('Erro ao conectar: $e');
      disconnect();
    }
  }

  void disconnect() {
    client.disconnect();
  }

  // Callbacks de conexão
  void onConnected() {
    print('Conectado ao broker');
  }

  void onDisconnected() {
    print('Desconectado do broker');
  }

  void onSubscribed(String topic) {
    print('Inscrito no tópico: $topic');
  }

  // Método para se inscrever em um tópico
  void subscribe(String topic) {
    client.subscribe(topic, MqttQos.atLeastOnce);
  }
  //Método para publicar em um tópico
  void publish(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    client.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
  }
}
