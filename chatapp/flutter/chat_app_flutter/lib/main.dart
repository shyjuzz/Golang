import 'package:flutter/material.dart';
import 'package:web_socket_channel/io.dart';

void main() => runApp(ChatApp());

class ChatApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: ChatScreen(),
    );
  }
}

class ChatScreen extends StatefulWidget {
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _textController = TextEditingController();
  final _channel = IOWebSocketChannel.connect('ws://localhost:8080/ws');
  List<String> _messages = [];

  @override
  void initState() {
    super.initState();
    _channel.stream.listen((message) {
      setState(() {
        _messages.add(message);
      });
    });
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  void _sendMessage() {
    if (_textController.text.isNotEmpty) {
      _channel.sink.add(_textController.text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Real-time Chat')),
      body: Column(
        children: <Widget>[
          Expanded(
            child: ListView.builder(
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(_messages[index]),
                );
              },
            ),
          ),
          Container(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(hintText: 'Type your message...'),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
