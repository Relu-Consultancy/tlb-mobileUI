import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../core/app_snackbar.dart';
import '../core/responsive.dart';
import '../models/help_ticket_model.dart';
import '../providers/auth_state.dart';
import '../services/help_service.dart';

/// Chat-style view for a single support ticket.
///
/// Behaviour:
///  • Loads the full message list once on open (no `since`).
///  • Polls every 12 s for incrementals using the latest `created_at` as
///    the `since` parameter (cheap — server only returns newer rows).
///  • Sending a message appends it locally on 201; the next poll will be
///    a no-op for that row since it's already in the list (de-duped by id).
class TicketDetailScreen extends StatefulWidget {
  final HelpTicket ticket;
  const TicketDetailScreen({super.key, required this.ticket});

  @override
  State<TicketDetailScreen> createState() => _TicketDetailScreenState();
}

class _TicketDetailScreenState extends State<TicketDetailScreen> {
  static const _pollInterval = Duration(seconds: 12);

  final _scrollCtrl = ScrollController();
  final _inputCtrl = TextEditingController();
  Timer? _poller;

  bool _loadingInitial = true;
  bool _sending = false;
  String? _initialError;
  final List<HelpTicketMessage> _messages = [];

  @override
  void initState() {
    super.initState();
    _loadInitial();
  }

  @override
  void dispose() {
    _poller?.cancel();
    _scrollCtrl.dispose();
    _inputCtrl.dispose();
    super.dispose();
  }

  bool get _isClosed {
    final s = widget.ticket.status.toLowerCase();
    return s == 'closed' || s == 'resolved';
  }

  Future<void> _loadInitial() async {
    final token = AuthState.accessToken;
    if (token == null) {
      setState(() {
        _loadingInitial = false;
        _initialError = 'Please log in to view this ticket.';
      });
      return;
    }
    final result = await HelpService.getMessages(
      accessToken: token,
      ticketId: widget.ticket.id,
    );
    if (!mounted) return;
    if (result['success'] == true) {
      final fetched = (result['messages'] as List<HelpTicketMessage>);
      fetched.sort((a, b) {
        final aD = a.createdAt;
        final bD = b.createdAt;
        if (aD == null && bD == null) return 0;
        if (aD == null) return -1;
        if (bD == null) return 1;
        return aD.compareTo(bD);
      });
      setState(() {
        _messages
          ..clear()
          ..addAll(fetched);
        _loadingInitial = false;
      });
      _scrollToBottom();
      _startPoller();
    } else {
      setState(() {
        _loadingInitial = false;
        _initialError = (result['message'] as String?) ?? 'Could not load messages.';
      });
    }
  }

  void _startPoller() {
    _poller?.cancel();
    _poller = Timer.periodic(_pollInterval, (_) => _pollOnce());
  }

  Future<void> _pollOnce() async {
    if (!mounted) return;
    final token = AuthState.accessToken;
    if (token == null) return;
    DateTime? since;
    if (_messages.isNotEmpty) {
      // Pick the most recent created_at across all rows we already have.
      for (final m in _messages) {
        if (m.createdAt == null) continue;
        if (since == null || m.createdAt!.isAfter(since)) {
          since = m.createdAt;
        }
      }
    }
    final result = await HelpService.getMessages(
      accessToken: token,
      ticketId: widget.ticket.id,
      since: since,
    );
    if (!mounted) return;
    if (result['success'] != true) return;
    final newMessages = (result['messages'] as List<HelpTicketMessage>);
    if (newMessages.isEmpty) return;
    final seen = _messages.map((m) => m.id).toSet();
    final additions = newMessages.where((m) => !seen.contains(m.id)).toList();
    if (additions.isEmpty) return;
    additions.sort((a, b) {
      final aD = a.createdAt;
      final bD = b.createdAt;
      if (aD == null && bD == null) return 0;
      if (aD == null) return -1;
      if (bD == null) return 1;
      return aD.compareTo(bD);
    });
    setState(() => _messages.addAll(additions));
    _scrollToBottom();
  }

  Future<void> _send() async {
    final text = _inputCtrl.text.trim();
    if (text.isEmpty) return;
    final token = AuthState.accessToken;
    if (token == null) {
      AppSnackBar.error(context, 'Please log in to send a message.');
      return;
    }
    setState(() => _sending = true);
    final result = await HelpService.sendMessage(
      accessToken: token,
      ticketId: widget.ticket.id,
      body: text,
    );
    if (!mounted) return;
    setState(() => _sending = false);
    if (result['success'] == true) {
      final msg = result['message_obj'] as HelpTicketMessage;
      // Append if the poller hasn't already snuck it in.
      final already = _messages.any((m) => m.id == msg.id);
      if (!already) {
        setState(() => _messages.add(msg));
        _scrollToBottom();
      }
      _inputCtrl.clear();
    } else {
      AppSnackBar.error(
        context,
        (result['message'] as String?) ?? 'Could not send message.',
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollCtrl.hasClients) return;
      _scrollCtrl.animateTo(
        _scrollCtrl.position.maxScrollExtent,
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final cat = HelpCategory.fromSlug(widget.ticket.category);
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F2F7),
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1A1A2E)),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.ticket.subject.isEmpty
                  ? '(no subject)'
                  : widget.ticket.subject,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.poppins(
                fontSize: Responsive.sp(context, 15),
                fontWeight: FontWeight.w500,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            Text(
              '${cat.label} · ${_statusLabel(widget.ticket.status)}',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(child: _body()),
          if (_isClosed) _closedFooter() else _composer(),
        ],
      ),
    );
  }

  String _statusLabel(String s) {
    if (s.isEmpty) return 'Open';
    return s
        .split('_')
        .map((w) => w.isEmpty ? w : w[0].toUpperCase() + w.substring(1))
        .join(' ');
  }

  Widget _body() {
    if (_loadingInitial) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
        ),
      );
    }
    if (_initialError != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline, size: 48, color: Colors.grey.shade400),
              const SizedBox(height: 12),
              Text(
                _initialError!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  color: Colors.grey.shade700,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _loadingInitial = true;
                    _initialError = null;
                  });
                  _loadInitial();
                },
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF2563EB),
                  side: const BorderSide(color: Color(0xFF2563EB)),
                ),
              ),
            ],
          ),
        ),
      );
    }
    if (_messages.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Text(
            'No messages yet. Send the first reply below.',
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13,
              color: Colors.grey.shade600,
            ),
          ),
        ),
      );
    }
    return ListView.builder(
      controller: _scrollCtrl,
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
      itemCount: _messages.length,
      itemBuilder: (_, i) => _Bubble(message: _messages[i]),
    );
  }

  Widget _composer() {
    return SafeArea(
      top: false,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 6,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _inputCtrl,
                enabled: !_sending,
                minLines: 1,
                maxLines: 4,
                maxLength: 2000,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: 'Type your message...',
                  hintStyle: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey.shade400,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF2F2F7),
                  counterText: '',
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: GoogleFonts.poppins(fontSize: 14),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: const Color(0xFF2563EB),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _sending ? null : _send,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: _sending
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Icon(Icons.send_rounded,
                          color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _closedFooter() {
    return SafeArea(
      top: false,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
        color: const Color(0xFFF1F1F4),
        child: Text(
          'This ticket is ${_statusLabel(widget.ticket.status).toLowerCase()}. '
          'Open a new ticket if you need more help.',
          textAlign: TextAlign.center,
          style: GoogleFonts.poppins(
            fontSize: 12.5,
            color: Colors.grey.shade700,
            height: 1.4,
          ),
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final HelpTicketMessage message;
  const _Bubble({required this.message});

  @override
  Widget build(BuildContext context) {
    final mine = message.isFromCustomer;
    final bg = mine ? const Color(0xFF2563EB) : Colors.white;
    final fg = mine ? Colors.white : const Color(0xFF1A1A2E);
    final timeColor = mine ? Colors.white70 : Colors.grey.shade500;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment:
            mine ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!mine) _avatar(message),
          if (!mine) const SizedBox(width: 8),
          Flexible(
            child: Container(
              padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.72,
              ),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(14),
                  topRight: const Radius.circular(14),
                  bottomLeft: Radius.circular(mine ? 14 : 4),
                  bottomRight: Radius.circular(mine ? 4 : 14),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!mine && message.senderEmail.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        _displayName(message),
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  Text(
                    message.body,
                    style: GoogleFonts.poppins(
                      fontSize: 13.5,
                      color: fg,
                      height: 1.4,
                    ),
                  ),
                  if (message.createdAt != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        _formatTime(message.createdAt!),
                        style: GoogleFonts.poppins(
                          fontSize: 10,
                          color: timeColor,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatar(HelpTicketMessage m) {
    final isSupport = m.senderRole == 'support' || m.senderRole == 'admin';
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        color: isSupport
            ? const Color(0xFFEDF4FF)
            : const Color(0xFFFFF8E1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        isSupport ? Icons.support_agent_rounded : Icons.person_outline,
        size: 16,
        color: isSupport ? const Color(0xFF2563EB) : const Color(0xFFB45309),
      ),
    );
  }

  String _displayName(HelpTicketMessage m) {
    if (m.senderRole == 'support' || m.senderRole == 'admin') {
      return 'TLB Support';
    }
    final email = m.senderEmail;
    final at = email.indexOf('@');
    return at > 0 ? email.substring(0, at) : email;
  }

  String _formatTime(DateTime d) {
    final local = d.toLocal();
    final hh = local.hour.toString().padLeft(2, '0');
    final mm = local.minute.toString().padLeft(2, '0');
    final now = DateTime.now();
    if (local.year == now.year &&
        local.month == now.month &&
        local.day == now.day) {
      return '$hh:$mm';
    }
    return '${local.day}/${local.month} · $hh:$mm';
  }
}
