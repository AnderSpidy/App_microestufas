import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PresetDialog extends StatefulWidget {
  final Map<String, Object> configData; // Recebe os dados de configuração

  const PresetDialog({Key? key, required this.configData}) : super(key: key);

  @override
  _PresetDialogState createState() => _PresetDialogState();
}

class _PresetDialogState extends State<PresetDialog> {
  final TextEditingController _controller = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // Usando addPostFrameCallback para garantir que o diálogo seja exibido após a construção do widget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showPresetDialog(context);
    });
  }

  Future<void> _showPresetDialog(BuildContext context) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // O usuário não pode fechar sem preencher
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Nome do Preset'),
          content: TextField(
            controller: _controller,
            decoration:
                const InputDecoration(hintText: 'Digite o nome do preset'),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Fecha o dialog sem salvar
              },
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                String presetName = _controller.text.trim();
                if (presetName.isNotEmpty) {
                  await _savePreset(presetName,
                      widget.configData); // Chama a função para salvar o preset
                  Navigator.of(context).pop(); // Fecha o dialog após salvar
                } else {
                  // Exibe um erro caso o nome esteja vazio
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('O nome do preset não pode ser vazio.')),
                  );
                }
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  // Função para salvar o preset no Firestore
  Future<void> _savePreset(
      String presetName, Map<String, Object> configData) async {
    try {
      // Referência para o documento onde o preset será salvo
      DocumentReference presets =
          FirebaseFirestore.instance.collection('default-user').doc('presets');
      // Este default-user deve ser modificado futuramente para utilizar o ID do usuário autenticado

      // Salva o preset no documento com o nome dinâmico
      await presets.update({
        presetName: configData,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Preset salvo com sucesso!")),
      );

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao salvar preset: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
