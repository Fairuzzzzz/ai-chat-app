import 'package:aichatapp/services/ai/ai_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
    if (_textController.text.isNotEmpty) {
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
        backgroundColor: Colors.white,
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
      backgroundColor: Colors.white,
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
                style: const TextStyle(fontSize: 14),
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
      String content = response?.choices.first.message.content ?? 'No Response';

      // Parse content for code block
      List<Widget> messageWidget = [];
      RegExp codeBlockRegex = RegExp(r'```(?:.*\n)?([^`]+)```');

      String remainingText = content;
      int lastMatchEnd = 0;

      for (Match match in codeBlockRegex.allMatches(content)) {
        if (match.start > lastMatchEnd) {
          String textBefore = content.substring(lastMatchEnd, match.start);
          messageWidget.add(_processTextWithBold(textBefore));
        }

        // Add code block
        String code = match.group(1)?.trim() ?? '';
        messageWidget.add(CodeBlock(code: code));
        lastMatchEnd = match.end;
      }

      if (lastMatchEnd < content.length) {
        messageWidget
            .add(_processTextWithBold(content.substring(lastMatchEnd)));
      }

      ChatMessage responseMessage = ChatMessage(
        widgets: messageWidget,
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

  Widget _processTextWithBold(String text) {
    RegExp boldPattern = RegExp(r'\*\*([^*]+)\*\*');
    List<TextSpan> spans = [];
    int lastMatchEnd = 0;

    for (Match match in boldPattern.allMatches(text)) {
      if (match.start > lastMatchEnd) {
        spans.add(TextSpan(text: text.substring(lastMatchEnd, match.start)));
      }
      spans.add(TextSpan(
          text: match.group(1),
          style: const TextStyle(fontWeight: FontWeight.bold)));
      lastMatchEnd = match.end;
    }
    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }
    return RichText(
        text: TextSpan(
            style: const TextStyle(color: Colors.black), children: spans));
  }
}

class ChatMessage extends StatelessWidget {
  final String? text;
  final List<Widget>? widgets;
  final bool isUserMessage;
  const ChatMessage(
      {super.key, this.text, this.widgets, this.isUserMessage = false});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final CrossAxisAlignment crossAxisAlignment =
        isUserMessage ? CrossAxisAlignment.end : CrossAxisAlignment.start;
    return Column(
      crossAxisAlignment: crossAxisAlignment,
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
              color: isUserMessage ? const Color(0xFF5393f3) : Colors.white,
              borderRadius: BorderRadius.circular(20)),
          child: widgets != null
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: widgets!,
                )
              : Text(text ?? '',
                  style: isUserMessage
                      ? const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.white)
                      : const TextStyle(
                          fontWeight: FontWeight.w500, color: Colors.black)),
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
            text ?? '',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        )
      ],
    );
  }
}

class CodeBlock extends StatelessWidget {
  final String code;
  const CodeBlock({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
          color: const Color(0xFF1F294A),
          borderRadius: BorderRadius.circular(16)),
      child: Stack(
        children: [
          Padding(
            padding:
                const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 56),
            child: SelectableText(
              code,
              style: const TextStyle(
                  fontFamily: 'monospace', color: Colors.white, fontSize: 14),
            ),
          ),
          Positioned(
              right: 8,
              bottom: 8,
              child: IconButton(
                  onPressed: () => Clipboard.setData(ClipboardData(text: code)),
                  icon: const Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: 18,
                  )))
        ],
      ),
    );
  }
}
