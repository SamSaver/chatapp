import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class SendButton extends StatelessWidget {
  const SendButton({Key? key, required this.sendMessage}) : super(key: key);

  final sendMessage;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        sendMessage();
      },
      icon: Icon(
        Icons.send,
        color: Theme.of(context).colorScheme.secondary,
      ),
    );
  }
}
