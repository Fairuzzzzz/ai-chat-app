import 'package:aichatapp/services/ai/ai_service.dart';
import 'package:aichatapp/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
  bool _isBottom = true;
  final authService = AuthService();
  List<Map<String, String>> messages = [];
  bool _isClear = true;

  Groq? _groq;

  @override
  void initState() {
    super.initState();
    _initializeGroq();
    _scrollController.addListener(_scrollListener);
  }

  void _initializeGroq() async {
    _groq = await groqInit();
    _groq?.startChat();
  }

  void _scrollListener() {
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    if (currentScroll >= (maxScroll - 50)) {
      setState(() {
        _isBottom = true;
      });
    } else {
      setState(() {
        _isBottom = false;
      });
    }
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

  void logout() async {
    await authService.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 80,
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
              child: Stack(
                children: [
                  ListView.builder(
                      controller: _scrollController,
                      itemCount: _messages.length,
                      itemBuilder: (_, int index) => _messages[index]),
                  Visibility(
                    visible: _isClear ? !_isBottom : _isBottom,
                    child: Positioned(
                        right: 16,
                        bottom: 16,
                        child: ElevatedButton(
                            onPressed: () => _scrollToBottomWithDelay(
                                const Duration(milliseconds: 300)),
                            style: ElevatedButton.styleFrom(
                                shape: const CircleBorder(),
                                padding: const EdgeInsets.all(8),
                                backgroundColor: Colors.blue),
                            child: SvgPicture.asset(
                              'assets/icons/ChevronDown.svg',
                              color: Colors.white,
                              height: 20,
                              width: 20,
                            ))),
                  )
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 14),
              decoration: BoxDecoration(
                  color: const Color(0xFFf1f1f1),
                  borderRadius: BorderRadius.circular(40)),
              child: _buildTextComposer(),
            )
          ],
        )),
        backgroundColor: Colors.white,
        drawer: Drawer(
          child: Column(
            children: [
              const Spacer(),
              ListTile(
                leading: const Icon(size: 20, Icons.logout),
                title: const Text(
                  'Logout',
                  style: TextStyle(fontSize: 14, color: Colors.black),
                ),
                onTap: () {
                  logout();
                },
              )
            ],
          ),
        ));
  }

  Widget _buildClearChatButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          _messages.clear();
          _groq?.clearChat();
          _isClear = true;
          _isBottom = false;
        });

        Future.delayed(const Duration(microseconds: 300), () {
          if (mounted) {
            setState(() {
              _isClear = false;
            });
          }
        });
      },
      icon: const Icon(Icons.delete),
      tooltip: 'Clear Chat',
    );
  }

  Widget _buildTextComposer() {
    return IconTheme(
        data: IconThemeData(color: Theme.of(context).colorScheme.secondary),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Expanded(
                  child: TextField(
                controller: _textController,
                maxLines: null,
                minLines: 1,
                textInputAction: TextInputAction.newline,
                decoration: const InputDecoration(
                    hintText: 'Ask me anything...',
                    contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    border: InputBorder.none),
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              )),
              TextButton(
                  style: ButtonStyle(
                      backgroundColor:
                          WidgetStateProperty.all(const Color(0xFF5393f3))),
                  onPressed: () => _handleSubmitted(_textController.text),
                  child: const Text(
                    'Send',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w500),
                  ))
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
              : Text(
                  text ?? '',
                  style: TextStyle(
                      color: isUserMessage ? Colors.white : Colors.black,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
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
