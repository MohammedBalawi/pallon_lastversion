import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dash_chat_2/dash_chat_2.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:pallon_lastversion/Core/Utils/manager_fonts.dart';

import '../../../models/user_model.dart';
import '../../AddStaff/function/add_staff_function.dart';
import '../../MainScreen/function/main_function.dart';
import '../../Requset/functions/req_functions.dart';
import '../function/chat_function.dart';

class ChatWidget extends StatefulWidget {
  const ChatWidget({super.key});

  @override
  State<ChatWidget> createState() => _ChatWidget();
}

class _ChatWidget extends State<ChatWidget> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  ChatUser? _me;
  UserModel userModel = UserModel(
    doc: "",
    email: "",
    phone: "",
    name: "",
    pic: "",
    type: "",
  );
  List<UserModel> staff = [];

  final TextEditingController _msgCtrl = TextEditingController();
  final FocusNode _msgFocus = FocusNode();
  final ScrollController _scrollCtrl = ScrollController();
  bool _sending = false;

  static const Color primaryGreen = Color(0xFF07933E);
  static const Color darkGreen = Color(0xFF007530);
  static const Color bg = Color(0xFFF4F6F8);

  bool get _isRtl => Get.locale?.languageCode == 'ar';
  String get _localeCode => Get.locale?.toLanguageTag() ?? 'en';

  @override
  void initState() {
    super.initState();
    _loadChatData();
  }

  @override
  void dispose() {
    _msgCtrl.dispose();
    _msgFocus.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadChatData() async {
    try {
      final uid = _auth.currentUser?.uid;
      if (uid == null) return;

      userModel = (await GetUserData(uid)) ?? userModel;
      staff = await GetAllStaff();

      _me = ChatUser(
        id: userModel.doc,
        firstName: (userModel.name.isEmpty || userModel.name == "name")
            ? userModel.email
            : userModel.name,
        profileImage: userModel.pic,
      );

      if (!mounted) return;
      setState(() {});
    } catch (e) {
      debugPrint(" Chat load error: $e");
    }
  }

  String _fmtTime(DateTime? dt) {
    final d = dt ?? DateTime.now();
    return DateFormat('h:mm a').format(d);
  }

  String _fmtDayHeader(DateTime? dt) {
    final d = dt ?? DateTime.now();
    return "${DateFormat('EEEE').format(d)} • ${DateFormat('dd/MM/yyyy').format(d)}";
  }




  DateTime _normalizeDay(DateTime d) => DateTime(d.year, d.month, d.day);

  void _scrollToBottom({bool animated = true}) {
    if (!_scrollCtrl.hasClients) return;
    if (animated) {
      _scrollCtrl.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    } else {
      _scrollCtrl.jumpTo(0.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: bg,

      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: AppBar(
          elevation: 0,
          centerTitle: false,
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          flexibleSpace: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryGreen, darkGreen],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          titleSpacing: 12,
          title: Row(
            children: [
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Chat".tr,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize:32,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      (userModel.name.isEmpty || userModel.name == "name")
                          ? userModel.email
                          : userModel.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        color: Colors.white.withOpacity(0.85),
                        fontWeight: FontWeight.w600,
                        fontSize: sw * 0.033,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),

      body: _me == null
          ? const Center(
        child: CircularProgressIndicator(
          backgroundColor: primaryGreen,
        ),
      )
          : SafeArea(
        top: false,
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  Positioned.fill(
                    child: CustomPaint(painter: _ChatWallpaperPainter()),
                  ),
                  StreamBuilder<List<ChatMessage>>(
                    stream: chatStream(),
                    builder: (context, snapshot) {
                      final messages = snapshot.data ?? [];

                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        _scrollToBottom(animated: true);
                      });

                      return ListView.builder(
                        controller: _scrollCtrl,
                        reverse: true,
                        padding:
                        const EdgeInsets.fromLTRB(12, 12, 12, 12),
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          final m = messages[index];
                          final isMe = (m.user.id == _me!.id);

                          final currDay =
                          _normalizeDay(m.createdAt ?? DateTime.now());

                          DateTime? prevDay;
                          if (index + 1 < messages.length) {
                            prevDay = _normalizeDay(messages[index + 1]
                                .createdAt ??
                                DateTime.now());
                          }

                          final bool showDayHeader =
                              (prevDay == null) || (currDay != prevDay);

                          return Column(
                            children: [
                              if (showDayHeader)
                                _DaySeparator(
                                  text: _fmtDayHeader(
                                      m.createdAt ?? DateTime.now()),
                                ),
                              _MessageBubble(
                                isMe: isMe,
                                text: m.text,
                                name: (m.user.firstName ?? "User"),
                                timeText: _fmtTime(m.createdAt),
                                avatarUrl: m.user.profileImage,
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
            ),

            _buildInputBar(sw),
          ],
        ),
      ),
    );
  }

  Widget _buildInputBar(double sw) {
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.98),
        border: Border(top: BorderSide(color: Colors.grey.withOpacity(0.15))),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _msgCtrl,
              focusNode: _msgFocus,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _handleSend(),
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
                fontSize: sw * 0.040,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: "Type a message...".tr,
                hintStyle: TextStyle(
                  fontFamily: ManagerFontFamily.fontFamily,
                  color: Colors.grey.shade500,
                  fontSize: sw * 0.040,
                ),
                filled: true,
                fillColor: const Color(0xFFF6F7F9),
                contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(22),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _handleSend,
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [primaryGreen, darkGreen],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: primaryGreen.withOpacity(0.35),
                    blurRadius: 12,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Icon(Icons.send_rounded,
                  color: Colors.white, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSend() async {
    if (_sending) return;
    final text = _msgCtrl.text.trim();
    if (text.isEmpty) return;

    _sending = true;

    _msgCtrl.clear();
    _msgFocus.requestFocus();

    final msg = ChatMessage(
      user: _me!,
      text: text,
      createdAt: DateTime.now(),
    );

    try {
      await _sendMessage(msg);
    } finally {
      _sending = false;
    }
  }


  Future<void> _sendMessage(ChatMessage message) async {
    try {
      message.createdAt ??= DateTime.now();

      await sendChatMessage(message);

      final usersSnap = await FirebaseFirestore.instance.collection('user').get();
      final futures = <Future>[];

      for (final doc in usersSnap.docs) {
        final data = doc.data();

        final userId = doc.id;
        if (userId == userModel.doc) continue;

        final type = (data['type'] ?? '').toString().toLowerCase().trim();
        if (type == 'Client'||type == 'client') continue;

        final token = (data['token'] ?? '').toString().trim();
        if (token.isEmpty) continue;

        futures.add(() async {
          try {
            await sendNotification(
              token,
              message.user.firstName.toString(),
              message.text,
              "chat",
              userDocId: userId,
              dataExtras: const {"type": "chat"},
            );
          } catch (e) {
            debugPrint(" Notification failed for $userId: $e");
          }
        }());
      }

      await Future.wait(futures);

    } catch (e) {
      debugPrint(" send message error: $e");
    }
  }
}


class _DaySeparator extends StatelessWidget {
  const _DaySeparator({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Divider(color: Colors.black.withOpacity(0.08), thickness: 1),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.92),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.black.withOpacity(0.06)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                fontFamily: ManagerFontFamily.fontFamily,
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Divider(color: Colors.black.withOpacity(0.08), thickness: 1),
          ),
        ],
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({
    required this.isMe,
    required this.text,
    required this.name,
    required this.timeText,
    required this.avatarUrl,
  });

  final bool isMe;
  final String text;
  final String name;
  final String timeText;
  final String? avatarUrl;

  static const Color primaryGreen = Color(0xFF07933E);

  @override
  Widget build(BuildContext context) {
    final sw = MediaQuery.of(context).size.width;

    final bubbleColor = isMe ? primaryGreen : Colors.white;
    final textColor = isMe ? Colors.white : Colors.black87;
    final metaColor =
    isMe ? Colors.white.withOpacity(0.85) : Colors.grey.shade600;

    final maxBubbleWidth = sw * 0.72;
    const minBubbleWidth = 110.0;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment:
        isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            _SmallAvatar(url: avatarUrl),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxBubbleWidth,
              minWidth: minBubbleWidth,
            ),
            child: Align(
              alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: bubbleColor,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(18),
                    topRight: const Radius.circular(18),
                    bottomLeft: Radius.circular(isMe ? 18 : 6),
                    bottomRight: Radius.circular(isMe ? 6 : 18),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                  border: isMe
                      ? null
                      : Border.all(color: Colors.grey.withOpacity(0.12)),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        color: metaColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      text,
                      style: TextStyle(
                        fontFamily: ManagerFontFamily.fontFamily,
                        fontSize: 12.8,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          timeText,
                          style: TextStyle(
                            fontFamily: ManagerFontFamily.fontFamily,
                            fontSize: 8,
                            fontWeight: FontWeight.w700,
                            color: metaColor,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          if (isMe) ...[
            const SizedBox(width: 8),
            _SmallAvatar(url: avatarUrl),
          ],
        ],
      ),
    );
  }
}

class _SmallAvatar extends StatelessWidget {
  const _SmallAvatar({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final u = (url ?? "").trim();
    final isNet = u.startsWith("http");

    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.grey.shade200,
        border: Border.all(color: Colors.white, width: 1.3),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: ClipOval(
        child: isNet
            ? Image.network(
          u,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => Icon(Icons.person,
              color: Colors.grey.shade700, size: 18),
        )
            : Icon(Icons.person, color: Colors.grey.shade700, size: 18),
      ),
    );
  }
}



class _ChatWallpaperPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF000000).withOpacity(0.03);
    const double r = 10;

    for (double y = 28; y < size.height; y += 46) {
      for (double x = 22; x < size.width; x += 46) {
        canvas.drawCircle(Offset(x, y), r, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
