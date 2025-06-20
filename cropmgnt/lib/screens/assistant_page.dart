import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cropmgnt/services/farmai_service.dart';
import 'package:cropmgnt/utils/storage_service.dart';

class AssistantPage extends StatefulWidget {
  const AssistantPage({super.key});

  @override
  State<AssistantPage> createState() => _AssistantPageState();
}

class _AssistantPageState extends State<AssistantPage> {
  final List<Map<String, dynamic>> _messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isTyping = false;
  bool _isConnected = false;
  bool _isLoading = false;
  String? _errorMessage;
  Timer? _connectionTimer;
  final http.Client _httpClient = http.Client();

  @override
  void initState() {
    super.initState();
    _initializeChat();
    // Set up periodic connection checks
    _connectionTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _checkConnection();
    });
  }

  @override
  void dispose() {
    _connectionTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    _httpClient.close();
    super.dispose();
  }

  Future<void> _initializeChat() async {
    setState(() => _isLoading = true);
    await _checkConnection();
    if (_isConnected) {
      await _loadConversation();
    }
    setState(() => _isLoading = false);
  }

  Future<void> _checkConnection() async {
    try {
      final response = await _httpClient
          .get(
            Uri.parse('http://10.0.2.2:8080/health'),
            headers: await _getHeaders(),
          )
          .timeout(const Duration(seconds: 5));

      setState(() {
        _isConnected = response.statusCode == 200;
        _errorMessage = _isConnected ? null : 'Connection failed';
      });
    } catch (e) {
      setState(() {
        _isConnected = false;
        _errorMessage = 'Connection to FarmAI failed';
      });
    }
  }

  Future<void> _loadConversation() async {
    if (!_isConnected) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final history = await FarmAIService.getConversation();
      setState(() {
        _messages.clear();
        _messages.addAll(history);
      });
      _scrollToBottom();
    } catch (e) {
      setState(() => _errorMessage = e.toString());
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _sendMessage() async {
    if (_controller.text.isEmpty || !_isConnected || _isTyping) return;

    final userMessage = _controller.text;
    _addMessage(userMessage, 'user');
    _controller.clear();

    try {
      setState(() => _isTyping = true);
      final response = await FarmAIService.sendMessage(userMessage);
      _addMessage(
        response['response'] ?? 'No response',
        'ai',
      ); // Handle null response
    } catch (e) {
      setState(() => _errorMessage = e.toString());
      if (_messages.isNotEmpty && _messages.last['text'] == userMessage) {
        setState(() => _messages.removeLast());
      }
    } finally {
      setState(() => _isTyping = false);
    }
  }

  void _addMessage(String text, String sender) {
    if (!mounted) return;
    setState(() {
      _messages.add({'sender': sender, 'text': text, 'time': DateTime.now()});
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (!mounted || !_scrollController.hasClients) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await StorageService.getToken();
    return {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };
  }

  void _clearError() {
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FarmAI Assistant',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.green[800],
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _isConnected ? Icons.cloud_done : Icons.cloud_off,
              color: Colors.white,
            ),
            onPressed: _initializeChat,
            tooltip: 'Reconnect',
          ),
        ],
      ),
      body: Column(
        children: [
          if (_errorMessage != null) _buildErrorBanner(),
          Expanded(child: _buildChatContent()),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildErrorBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: Colors.red[100],
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(width: 8),
          Expanded(child: Text(_errorMessage!)),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: _clearError,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildChatContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_messages.isEmpty && !_isTyping) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.agriculture, size: 64, color: Colors.green[800]),
            const SizedBox(height: 16),
            Text(
              _isConnected
                  ? 'Ask about maize farming practices,\npest control, or crop management'
                  : 'Please check your internet connection',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey, fontSize: 16),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      itemCount: _messages.length + (_isTyping ? 1 : 0),
      padding: const EdgeInsets.all(16),
      itemBuilder: (context, index) {
        if (index < _messages.length) {
          return _buildMessageBubble(_messages[index]);
        }
        return _buildTypingIndicator();
      },
    );
  }

  Widget _buildMessageBubble(Map<String, dynamic> message) {
    final isUser = message['sender'] == 'user';

    // Handle potential null time
    final time =
        message['time'] != null
            ? message['time'] as DateTime
            : DateTime.now(); // Default to now if null

    final formattedTime =
        '${time.hour}:${time.minute.toString().padLeft(2, '0')}';

    // Handle potential null text
    final messageText =
        message['text'] ?? 'No message text'; // Default text if null

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: CircleAvatar(
                backgroundColor: Colors.green[100],
                child: const Icon(
                  Icons.smart_toy,
                  color: Colors.green,
                  size: 20,
                ),
              ),
            ),
          Flexible(
            child: Column(
              crossAxisAlignment:
                  isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  decoration: BoxDecoration(
                    color: isUser ? Colors.green[800] : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isUser ? 18 : 0),
                      bottomRight: Radius.circular(isUser ? 0 : 18),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    messageText,
                    style: TextStyle(
                      fontSize: 15,
                      color: isUser ? Colors.white : Colors.grey[800],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    formattedTime,
                    style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                  ),
                ),
              ],
            ),
          ),
          if (isUser)
            Container(
              margin: const EdgeInsets.only(left: 8),
              child: const CircleAvatar(
                backgroundColor: Colors.green,
                child: Icon(Icons.person, color: Colors.white, size: 18),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicator() {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: CircleAvatar(
              backgroundColor: Colors.green[100],
              child: const Icon(Icons.smart_toy, color: Colors.green, size: 20),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(18),
                topRight: Radius.circular(18),
                bottomRight: Radius.circular(18),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(Colors.green[300]!),
                const SizedBox(width: 4),
                _buildTypingDot(Colors.green[400]!),
                const SizedBox(width: 4),
                _buildTypingDot(Colors.green[500]!),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: Colors.green.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText:
                            _isConnected
                                ? 'Ask about your farm...'
                                : 'Connecting...',
                        hintStyle: const TextStyle(
                          color: Colors.grey,
                          fontSize: 15,
                        ),
                        border: InputBorder.none,
                      ),
                      style: const TextStyle(fontSize: 15),
                      maxLines: null,
                      onSubmitted: (_) => _sendMessage(),
                      enabled: _isConnected && !_isTyping,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [Colors.green[800]!, Colors.green[600]!],
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: IconButton(
              icon:
                  _isTyping
                      ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                      : const Icon(Icons.send, color: Colors.white),
              onPressed:
                  (_isConnected && !_isTyping && _controller.text.isNotEmpty)
                      ? _sendMessage
                      : null,
            ),
          ),
        ],
      ),
    );
  }
}
