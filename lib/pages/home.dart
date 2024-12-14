import 'package:aichatapp/services/ai/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:groq/groq.dart';

class Home extends StatefulWidget {
  final String userId;
  const Home({super.key, required this.userId});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = <ChatMessage>[];
  final ScrollController _scrollController = ScrollController();

  Groq? _groq;

  @override
  void initState() {
    super.initState();
    _initializeGroq();
  }

  void _initializeGroq() async {
    _groq = await groqInit();
    _groq?.startChat();
  }

  void _handleSubmitted(String text) async {
    _textController.clear();
    ChatMessage message = ChatMessage(
      text: text,
      isUserMessage: true,
    );
    setState(() {
      _messages.add(message);
    });

    _scrollToBottomWithDelay(const Duration(milliseconds: 200));

    _sendMessage(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Chat',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        centerTitle: true,
        actions: [_buildClearChatButton()], // TODO: Cant clear chat
      ),
      body: SafeArea(
          child: Column(
        children: <Widget>[
          Flexible(
              child: ListView.builder(
            controller: _scrollController,
            itemCount: _messages.length,
            itemBuilder: (_, int index) => _messages[index],
          )),
          const Divider(height: 1),
          Container(
            decoration: BoxDecoration(color: Theme.of(context).cardColor),
            child: _buildTextComposer(),
          )
        ],
      )),
      drawer: const Drawer(
        child: Column(),
      ),
    );
  }

  Widget _buildClearChatButton() {
    return IconButton(
      onPressed: () {
        _groq?.clearChat();
      },
      icon: const Icon(Icons.delete),
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            children: <Widget>[
              Flexible(
                  child: TextField(
                controller: _textController,
                decoration: const InputDecoration(
                    hintText: 'Send a message...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none),
              )),
              IconButton(
                  onPressed: () => _handleSubmitted(_textController.text),
                  icon: const Icon(Icons.send))
            ],
          ),
        ));
  }

  _scrollToBottomWithDelay(Duration delay) async {
    await Future.delayed(delay);
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  _sendMessage(String text) async {
    try {
      GroqResponse? response = await _groq?.sendMessage(text);

      ChatMessage responseMessage = ChatMessage(
        text: response?.choices.first.message.content ?? 'No response',
        isUserMessage: false,
      );
      setState(() {
        _messages.add(responseMessage);
      });
    } on GroqException catch (error) {
      ErrorMessage errorMessage = ErrorMessage(text: error.message);

      setState(() {
        _messages.add(errorMessage);
      });
    }
    _scrollToBottomWithDelay(const Duration(milliseconds: 300));
  }
}

class ChatMessage extends StatelessWidget {
  final String text;
  final bool isUserMessage;
  const ChatMessage(
      {super.key, required this.text, this.isUserMessage = false});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CrossAxisAlignment crossAxisAlignment =
        isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: isUserMessage
                  ? theme.colorScheme.primaryContainer
                  : theme.colorScheme.tertiaryContainer,
              borderRadius: isUserMessage
                  ? const BorderRadius.only(
                      topLeft: Radius.circular(8),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(0))
                  : const BorderRadius.only(
                      topLeft: Radius.circular(0),
                      topRight: Radius.circular(8),
                      bottomLeft: Radius.circular(8),
                      bottomRight: Radius.circular(8))),
          child: Text(
            text ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }
}

class ErrorMessage extends ChatMessage {
  const ErrorMessage({super.key, required super.text});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
              color: theme.colorScheme.errorContainer,
              borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(0),
                  topRight: Radius.circular(8),
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(8))),
          child: Text(
            text,
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }
}
