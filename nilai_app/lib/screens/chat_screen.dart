// ─────────────────────────────────────────────────────────────────────────────
//  screens/chat_screen.dart  —  AI Chat + Voice Input/Output
// ─────────────────────────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../constants.dart';
import '../services/language_service.dart';
import '../models/chat_message.dart';
import '../services/groq_service.dart';
import '../widgets/bouncing_dots.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});
  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  // ── State ─────────────────────────────────────────────────────────────────
  final List<ChatMessage> _msgs = [];
  final TextEditingController _ctrl = TextEditingController();
  final ScrollController _scroll = ScrollController();

  bool _loading = false;
  bool _isListening = false;
  bool _isSpeaking = false;
  bool _ttsEnabled = true;
  String _voiceText = '';
  String? _speakingMsgId;

  // ── Voice ─────────────────────────────────────────────────────────────────
  final SpeechToText _speech = SpeechToText();
  final FlutterTts _tts = FlutterTts();
  bool _speechAvailable = false;

  // ── Quick questions ────────────────────────────────────────────────────────
  static const _quick = [
    '🍅 Tomato price today?',
    '🧅 Onion market rate?',
    '🌾 Fertilizer tips?',
    '📅 Best day to sell?',
    '🌦️ Rain affect crops?',
  ];

  @override
  void initState() {
    super.initState();
    langService.addListener(_onLang);
    _initSpeech();
    _initTts();
    _msgs.add(ChatMessage(
      text: '🌾 வணக்கம்! Farmer AI Assistant இங்கே!\n\n'
          '• Crop prices & market rates\n'
          '• Farming tips & weather info\n'
          '• Government schemes & loans\n\n'
          '🎤 Mic button — Tamil-ல் பேசுங்கள்!\n'
          '🔊 AI reply-ஐ Tamil-ல் சொல்லும்!',
      role: Role.assistant,
    ));
  }

  Future<void> _initSpeech() async {
    _speechAvailable = await _speech.initialize(
      onStatus: (s) {
        if (s == 'done' || s == 'notListening') {
          if (mounted) setState(() => _isListening = false);
          if (_voiceText.isNotEmpty) {
            _send(_voiceText);
          }
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );
    if (mounted) setState(() {});
  }

  Future<void> _initTts() async {
    await _tts.setLanguage('ta-IN');
    await _tts.setSpeechRate(0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    _tts.setCompletionHandler(() {
      if (mounted)
        setState(() {
          _isSpeaking = false;
          _speakingMsgId = null;
        });
    });
    _tts.setCancelHandler(() {
      if (mounted)
        setState(() {
          _isSpeaking = false;
          _speakingMsgId = null;
        });
    });
  }

  @override
  void dispose() {
    langService.removeListener(_onLang);
    _ctrl.dispose();
    _scroll.dispose();
    _speech.cancel();
    _tts.stop();
    super.dispose();
  }

  void _onLang() {
    if (mounted) setState(() {});
  }

  void _scrollBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  // ── Voice Listen ──────────────────────────────────────────────────────────
  Future<void> _toggleListen() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }
    if (!_speechAvailable) {
      _snack('🎤 Microphone permission வேணும்!');
      return;
    }
    if (_isSpeaking) await _tts.stop();

    setState(() {
      _isListening = true;
      _voiceText = '';
    });

    await _speech.listen(
      onResult: (r) {
        setState(() => _voiceText = r.recognizedWords);
        if (r.finalResult && r.recognizedWords.isNotEmpty) {
          setState(() => _isListening = false);
          _send(r.recognizedWords);
        }
      },
      localeId: 'ta_IN',
      listenMode: ListenMode.confirmation,
      cancelOnError: true,
      partialResults: true,
    );
  }

  // ── TTS Speak ─────────────────────────────────────────────────────────────
  Future<void> _speak(String text, String id) async {
    if (!_ttsEnabled) return;
    if (_isSpeaking && _speakingMsgId == id) {
      await _tts.stop();
      setState(() {
        _isSpeaking = false;
        _speakingMsgId = null;
      });
      return;
    }
    await _tts.stop();
    setState(() {
      _isSpeaking = true;
      _speakingMsgId = id;
    });
    await _tts.speak(text);
  }

  // ── Send Message ──────────────────────────────────────────────────────────
  Future<void> _send([String? quick]) async {
    final text = quick ?? _ctrl.text.trim();
    if (text.isEmpty || _loading) return;

    if (_isListening) await _speech.stop();
    if (_isSpeaking) await _tts.stop();

    setState(() {
      _msgs.add(ChatMessage(text: text, role: Role.user));
      _loading = true;
      _voiceText = '';
      _isListening = false;
    });
    _ctrl.clear();
    _scrollBottom();

    try {
      final reply = await GroqService.chat(_msgs);
      setState(() {
        _msgs.add(ChatMessage(text: reply, role: Role.assistant));
        _loading = false;
      });
      _scrollBottom();

      if (_ttsEnabled && reply.isNotEmpty) {
        await Future.delayed(const Duration(milliseconds: 400));
        final id = _msgs.last.time.toIso8601String();
        await _speak(reply, id);
      }
    } catch (e) {
      setState(() {
        _msgs.add(ChatMessage(
          text: '⚠️ ${e.toString().replaceFirst('Exception: ', '')}',
          role: Role.assistant,
        ));
        _loading = false;
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  WIDGETS
  // ─────────────────────────────────────────────────────────────────────────

  Widget _bubble(ChatMessage msg) {
    final isUser = msg.role == Role.user;
    final time = '${msg.time.hour.toString().padLeft(2, '0')}:'
        '${msg.time.minute.toString().padLeft(2, '0')}';
    final id = msg.time.toIso8601String();
    final speaking = _speakingMsgId == id && _isSpeaking;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Bot avatar
          if (!isUser)
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(right: 6, bottom: 2),
              decoration: BoxDecoration(
                color: kGreen900,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Center(
                child: Text('🤖', style: TextStyle(fontSize: 16)),
              ),
            ),

          // Message bubble
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(14, 10, 10, 8),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.73,
              ),
              decoration: BoxDecoration(
                color: isUser ? kGreen700 : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(18),
                  topRight: const Radius.circular(18),
                  bottomLeft: Radius.circular(isUser ? 18 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    msg.text,
                    style: TextStyle(
                      color: isUser ? Colors.white : const Color(0xFF1A1A1A),
                      fontSize: 14.5,
                      height: 1.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 10,
                          color: isUser
                              ? Colors.white.withOpacity(0.6)
                              : Colors.grey[400],
                        ),
                      ),

                      // Speak button — bot messages only
                      if (!isUser) ...[
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => _speak(msg.text, id),
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: speaking ? kGreen700 : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              speaking
                                  ? Icons.stop_rounded
                                  : Icons.volume_up_rounded,
                              size: 14,
                              color: speaking ? Colors.white : Colors.grey[500],
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

          // User avatar
          if (isUser)
            Container(
              width: 34,
              height: 34,
              margin: const EdgeInsets.only(left: 6, bottom: 2),
              decoration: BoxDecoration(
                color: kAmber,
                borderRadius: BorderRadius.circular(17),
              ),
              child: const Center(
                child: Text('👨‍🌾', style: TextStyle(fontSize: 16)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _listeningBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 6),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(19),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: const Icon(Icons.mic, color: Colors.white, size: 20),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langService.t('listening'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: Colors.red,
                  ),
                ),
                Text(
                  _voiceText.isEmpty
                      ? langService.t('speak_tamil')
                      : _voiceText,
                  style: TextStyle(
                    fontSize: 12,
                    color: _voiceText.isEmpty ? Colors.grey : Colors.black87,
                    fontStyle: _voiceText.isEmpty
                        ? FontStyle.italic
                        : FontStyle.normal,
                  ),
                ),
              ],
            ),
          ),
          GestureDetector(
            onTap: _toggleListen,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child:
                  const Icon(Icons.stop_rounded, color: Colors.red, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // TTS toggle
            GestureDetector(
              onTap: () {
                setState(() => _ttsEnabled = !_ttsEnabled);
                if (!_ttsEnabled) _tts.stop();
                _snack(_ttsEnabled
                    ? langService.t('voice_on')
                    : langService.t('voice_off'));
              },
              child: Container(
                width: 40,
                height: 40,
                margin: const EdgeInsets.only(right: 6, bottom: 1),
                decoration: BoxDecoration(
                  color: _ttsEnabled ? kGreen100 : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _ttsEnabled
                      ? Icons.volume_up_rounded
                      : Icons.volume_off_rounded,
                  color: _ttsEnabled ? kGreen700 : Colors.grey[500],
                  size: 20,
                ),
              ),
            ),

            // Text input
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: kGreen50,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: TextField(
                  controller: _ctrl,
                  minLines: 1,
                  maxLines: 4,
                  style:
                      const TextStyle(fontSize: 14.5, color: Color(0xFF1A1A1A)),
                  decoration: InputDecoration(
                    hintText: langService.t('type_or_voice'),
                    hintStyle: TextStyle(color: Colors.grey[400], fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    border: InputBorder.none,
                  ),
                  onSubmitted: (_) => _send(),
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Mic button
            GestureDetector(
              onTap: _toggleListen,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _isListening ? Colors.red : Colors.orange[700],
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: [
                    BoxShadow(
                      color: (_isListening ? Colors.red : Colors.orange)
                          .withOpacity(0.4),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Icon(
                  _isListening ? Icons.mic_off_rounded : Icons.mic_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
            const SizedBox(width: 8),

            // Send button
            GestureDetector(
              onTap: () => _send(),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: _loading
                      ? null
                      : const LinearGradient(
                          colors: [kGreen500, kGreen700],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                  color: _loading ? Colors.grey[300] : null,
                  borderRadius: BorderRadius.circular(22),
                  boxShadow: _loading
                      ? []
                      : [
                          BoxShadow(
                            color: kGreen700.withOpacity(0.4),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                ),
                child: Icon(
                  Icons.arrow_upward_rounded,
                  color: _loading ? Colors.grey[500] : Colors.white,
                  size: 22,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  //  BUILD
  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kGreen50,
      appBar: AppBar(
        backgroundColor: kGreen700,
        foregroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              margin: const EdgeInsets.only(left: 4),
              decoration: BoxDecoration(
                color: kGreen900,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Center(
                child: Text('🤖', style: TextStyle(fontSize: 19)),
              ),
            ),
            SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  langService.t('chat_title'),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                Text(
                  langService.t('chat_subtitle'),
                  style: TextStyle(
                    fontSize: 10,
                    color: Color(0xFFA5D6A7),
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          // TTS status
          Container(
            margin: const EdgeInsets.only(right: 4),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _ttsEnabled ? Icons.volume_up : Icons.volume_off,
                  color: Colors.white70,
                  size: 14,
                ),
                SizedBox(width: 3),
                Text(
                  _ttsEnabled
                      ? langService.t('voice_on')
                      : langService.t('voice_off'),
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                ),
              ],
            ),
          ),

          // Clear
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            onPressed: () {
              _tts.stop();
              setState(() {
                _msgs.clear();
                _msgs.add(ChatMessage(
                  text: '🌾 Chat cleared! கேளுங்கள்!\n🎤 Voice or type!',
                  role: Role.assistant,
                ));
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(12, 16, 12, 8),
              itemCount: _msgs.length + (_loading ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (_loading && i == _msgs.length) {
                  return const BouncingDots();
                }
                return _bubble(_msgs[i]);
              },
            ),
          ),

          // Listening indicator
          if (_isListening) _listeningBar(),

          // Quick chips
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: _quick.map((q) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(
                      label: Text(q, style: const TextStyle(fontSize: 12)),
                      backgroundColor: kGreen100,
                      side: const BorderSide(color: kGreen700),
                      onPressed: () => _send(q),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Input bar
          _inputBar(),
        ],
      ),
    );
  }
}
