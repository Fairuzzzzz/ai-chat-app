import 'package:aichatapp/services/ai/ai_service.dart';
import 'package:aichatapp/services/auth/auth_service.dart';
import 'package:aichatapp/services/chat/chat_model.dart';
import 'package:aichatapp/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:groq/groq.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

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
  final bool _isClear = true;
  String? username;
  final SupabaseClient _supabase = Supabase.instance.client;
  final ChatService _chatService = ChatService();
  String currentSessionId = DateTime.now().toIso8601String();
  List<Map<String, dynamic>> chatSession = [];
  String? currentTitle;

  Groq? _groq;

  @override
  void initState() {
    super.initState();
    _initializeGroq();
    _scrollController.addListener(_scrollListener);
    _loadUsername();
    _loadChatSession();
    _createNewSession();
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

      final userMessage = ChatMessageModel(
          message: text,
          role: 'user',
          sessionId: currentSessionId,
          messageTime: DateTime.now(),
          title: currentTitle!);

      await _chatService.saveMessage(userMessage, widget.userId);

      await _loadChatSession();

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

  Future<void> _loadUsername() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user != null) {
        final data = await _supabase
            .from('profiles')
            .select('username')
            .eq('id', user.id)
            .single();
        setState(() {
          username = data['username'];
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          username = 'User';
        });
      }
    }
  }

  String get getUsernameFirstLetter {
    if (username == null || username!.isEmpty) {
      return 'U';
    }
    return username![0].toUpperCase();
  }

  void _createNewSession() {
    currentSessionId = DateTime.now().toIso8601String();
    currentTitle = 'New Chat ${DateTime.now().toString().substring(0, 16)}';
    _loadChatSession();
  }

  Future<void> _loadChatSession() async {
    try {
      final sessions = await _chatService.getChatSession(widget.userId);
      setState(() {
        chatSession = sessions;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          chatSession = [];
        });
      }
    }
  }

  Future<void> _loadSessionMessages(String sessionId) async {
    try {
      final history = await _chatService.getChatHistory(widget.userId);
      final sessionMessages =
          history.where((msg) => msg['session_id'] == sessionId).toList();
      setState(() {
        _messages.clear();
        for (final msg in sessionMessages) {
          if (msg['role'] == 'user') {
            _messages.add(ChatMessage(
              text: msg['message'],
              isUserMessage: msg['role'] == 'user',
            ));
          } else {
            _messages.add(ChatMessage(
              widgets: _parseMessageContent(msg['message']),
              isUserMessage: false,
            ));
          }
          currentSessionId = sessionId;
        }
      });
      Navigator.pop(context);
    } catch (e) {
      throw Exception('Error load session messages');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appBar(),
        body: _body(),
        backgroundColor: Colors.white,
        drawer: _drawer());
  }

  Drawer _drawer() {
    return Drawer(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 70),
            child: CircleAvatar(
                radius: 30,
                backgroundColor: Colors.blue,
                child: Text(
                  getUsernameFirstLetter,
                  style: const TextStyle(color: Colors.white),
                )),
          ),
          const SizedBox(
            height: 20,
          ),
          Text(
            username ?? 'User',
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(
            height: 20,
          ),
          const ListTile(
            title: Text(
              'Chat',
              style: TextStyle(fontSize: 14),
            ),
          ),
          Expanded(
              child: ListView.builder(
                  itemCount: chatSession.length,
                  itemBuilder: (context, index) {
                    final session = chatSession[index];
                    return ListTile(
                      title: Text(
                        session['title'] ?? 'Chat ${index + 1}',
                        style:
                            const TextStyle(fontSize: 14, color: Colors.black),
                      ),
                      trailing: IconButton(
                          onPressed: () async {
                            try {
                              await _chatService.deleteSession(
                                  widget.userId, session['session_id']);
                              if (currentSessionId == session['session_id']) {
                                setState(() {
                                  _messages.clear();
                                  _groq?.clearChat();
                                  _createNewSession();
                                });
                              }

                              // Reload chat session
                              final updatedSession = await _chatService
                                  .getChatSession(widget.userId);
                              if (mounted) {
                                setState(() {
                                  chatSession = updatedSession;
                                });
                              }
                            } catch (e) {
                              throw Exception('Error deleting session');
                            }
                          },
                          icon: const Icon(Icons.delete, size: 20)),
                      onTap: () => _loadSessionMessages(session['session_id']),
                    );
                  })),
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
    );
  }

  SafeArea _body() {
    return SafeArea(
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
    ));
  }

  AppBar _appBar() {
    return AppBar(
      toolbarHeight: 80,
      title: const Text(
        'Chat',
        style: TextStyle(fontWeight: FontWeight.w500),
      ),
      centerTitle: true,
      actions: [_buildNewChatButton()],
      backgroundColor: Colors.white,
    );
  }

  Widget _buildNewChatButton() {
    return IconButton(
      onPressed: () {
        setState(() {
          _messages.clear();
          _groq?.clearChat();
          _createNewSession();
          _loadChatSession();
        });
      },
      icon: const Icon(Icons.add),
      tooltip: 'New Chat',
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

      final botMessage = ChatMessageModel(
          message: content,
          role: 'bot',
          sessionId: currentSessionId,
          messageTime: DateTime.now(),
          title: currentTitle!);

      await _chatService.saveMessage(botMessage, widget.userId);

      ChatMessage responseMessage = ChatMessage(
        widgets: _parseMessageContent(content),
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

  // Parse content for code block
  List<Widget> _parseMessageContent(String content) {
    List<Widget> messageWidget = [];
    RegExp codeBlockRegex = RegExp(r'```(?:.*\n)?([^`]+)```');

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
      messageWidget.add(_processTextWithBold(content.substring(lastMatchEnd)));
    }

    return messageWidget;
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

class ChatMessage extends StatefulWidget {
  final String? text;
  final List<Widget>? widgets;
  final bool isUserMessage;
  const ChatMessage(
      {super.key, this.text, this.widgets, this.isUserMessage = false});

  @override
  State<ChatMessage> createState() => _ChatMessageState();
}

class _ChatMessageState extends State<ChatMessage>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 300));

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.0, -0.5), end: Offset.zero).animate(
            CurvedAnimation(
                parent: _animationController, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _animationController, curve: Curves.easeOut));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Theme.of(context);
    final CrossAxisAlignment crossAxisAlignment = widget.isUserMessage
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Column(
          crossAxisAlignment: crossAxisAlignment,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                  color: widget.isUserMessage
                      ? const Color(0xFF5393f3)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(20)),
              child: widget.widgets != null
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: widget.widgets!,
                    )
                  : Text(
                      widget.text ?? '',
                      style: TextStyle(
                          color: widget.isUserMessage
                              ? Colors.white
                              : Colors.black,
                          fontSize: 14,
                          fontWeight: FontWeight.w500),
                    ),
            )
          ],
        ),
      ),
    );
  }
}

class ErrorMessage extends ChatMessage {
  const ErrorMessage({super.key, required super.text});

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
