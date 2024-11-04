// lib/widgets/message_form.dart
import 'package:flutter/material.dart';

class MessageForm extends StatefulWidget {
  final ValueChanged<String> onMessageChanged;

  const MessageForm({
    super.key,
    required this.onMessageChanged,
  });

  @override
  _MessageFormState createState() => _MessageFormState();
}

class _MessageFormState extends State<MessageForm> {
  final TextEditingController _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      title: const Text(
        'Agregar mensaje (opcional)',
        style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
      ),
      initiallyExpanded: false,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: TextField(
            controller: _messageController,
            decoration: const InputDecoration(
              labelText: 'Mensaje',
            ),
            maxLines: 3,
            onChanged: (text) {
              widget.onMessageChanged(text);
            },
          ),
        ),
      ],
    );
  }
}
