part of 'package:ticketmaster/main.dart';

class _ForYouMailEntry {
  const _ForYouMailEntry({
    required this.id,
    required this.sender,
    required this.receivedLabel,
    required this.subject,
    required this.preview,
    required this.eventTitle,
    required this.venueName,
    required this.venueCity,
    required this.dateLine,
    required this.timeRange,
    required this.section,
    required this.row,
    required this.seat,
    required this.reservedCount,
    required this.orderNumber,
    required this.purchaseDate,
    required this.paidAmount,
  });

  final String id;
  final String sender;
  final String receivedLabel;
  final String subject;
  final String preview;
  final String eventTitle;
  final String venueName;
  final String venueCity;
  final String dateLine;
  final String timeRange;
  final String section;
  final String row;
  final String seat;
  final int reservedCount;
  final String orderNumber;
  final String purchaseDate;
  final String paidAmount;

  String get venueDisplay =>
      venueCity.trim().isEmpty ? venueName : '$venueName - $venueCity';

  String get seatRange => reservedCount <= 1
      ? '$seat - $seat'
      : '$seat - ${int.tryParse(seat) == null ? seat : int.parse(seat) + reservedCount - 1}';

  static const _ForYouMailEntry sample = _ForYouMailEntry(
    id: 'sample-ticketmaster-confirmation',
    sender: 'Ticketmaster',
    receivedLabel: 'May 1',
    subject: 'Access Your Washington Nationals vs. Minnesota Twins Tickets Now',
    preview: "Here's everything you need to access your tickets.",
    eventTitle: 'Washington Nationals vs. Minnesota Twins',
    venueName: 'Nationals Park',
    venueCity: 'Washington',
    dateLine: 'Tue, May 5 @ 6:45 PM',
    timeRange: 'Tue, May 5 • 6:45 PM - 7:45 PM\n(GMT+06:00)',
    section: '317',
    row: 'D',
    seat: '21',
    reservedCount: 1,
    orderNumber: '#2900-0650-5250-4071-1',
    purchaseDate: 'Apr 30, 2026',
    paidAmount: r'$14.22',
  );

  factory _ForYouMailEntry.fromTicket({
    required _TicketListEntry ticket,
    required int selectedCount,
  }) {
    final title =
        ticket.singleLineTitle.isEmpty ? 'Your Event' : ticket.singleLineTitle;
    final venueName =
        ticket.primaryVenue.isEmpty ? 'Nationals Park' : ticket.primaryVenue;
    final venueCity = _mailVenueCity(ticket.editableVenue);
    final compactDate = _mailCompactDate(ticket.editableDateLabel);
    final now = DateTime.now();
    final orderSuffix =
        '${now.millisecondsSinceEpoch % 9000 + 1000}-${ticket.id.toString().padLeft(4, '0')}-${selectedCount.toString().padLeft(2, '0')}';

    return _ForYouMailEntry(
      id: 'transfer-mail-${now.microsecondsSinceEpoch}',
      sender: 'Ticketmaster',
      receivedLabel: 'Today',
      subject: 'Access Your $title Tickets Now',
      preview: "Here's everything you need to access your tickets.",
      eventTitle: title,
      venueName: venueName,
      venueCity: venueCity,
      dateLine: compactDate,
      timeRange: '$compactDate - 7:45 PM\n(GMT+06:00)',
      section: _EditableTextStore.valueFor(
        ticket.ticketInstanceTextKey(0, 'section-value'),
        '317',
      ),
      row: _EditableTextStore.valueFor(
        ticket.ticketInstanceTextKey(0, 'row-value'),
        'D',
      ),
      seat: _EditableTextStore.valueFor(
        ticket.ticketInstanceTextKey(0, 'seat-value'),
        '21',
      ),
      reservedCount: selectedCount.clamp(1, 99).toInt(),
      orderNumber: '#2900-0650-$orderSuffix',
      purchaseDate: _mailTodayLabel(now),
      paidAmount: r'$14.22',
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'sender': sender,
      'receivedLabel': receivedLabel,
      'subject': subject,
      'preview': preview,
      'eventTitle': eventTitle,
      'venueName': venueName,
      'venueCity': venueCity,
      'dateLine': dateLine,
      'timeRange': timeRange,
      'section': section,
      'row': row,
      'seat': seat,
      'reservedCount': reservedCount,
      'orderNumber': orderNumber,
      'purchaseDate': purchaseDate,
      'paidAmount': paidAmount,
    };
  }

  static _ForYouMailEntry? fromJson(Object? raw) {
    if (raw is! Map) {
      return null;
    }
    String readString(String key, String fallback) {
      final value = raw[key];
      return value is String && value.isNotEmpty ? value : fallback;
    }

    final rawReservedCount = raw['reservedCount'];
    return _ForYouMailEntry(
      id: readString('id', 'mail-${raw.hashCode}'),
      sender: readString('sender', 'Ticketmaster'),
      receivedLabel: readString('receivedLabel', 'Today'),
      subject: readString(
        'subject',
        _ForYouMailEntry.sample.subject,
      ),
      preview: readString('preview', _ForYouMailEntry.sample.preview),
      eventTitle: readString('eventTitle', _ForYouMailEntry.sample.eventTitle),
      venueName: readString('venueName', _ForYouMailEntry.sample.venueName),
      venueCity: readString('venueCity', _ForYouMailEntry.sample.venueCity),
      dateLine: readString('dateLine', _ForYouMailEntry.sample.dateLine),
      timeRange: readString('timeRange', _ForYouMailEntry.sample.timeRange),
      section: readString('section', _ForYouMailEntry.sample.section),
      row: readString('row', _ForYouMailEntry.sample.row),
      seat: readString('seat', _ForYouMailEntry.sample.seat),
      reservedCount: rawReservedCount is int
          ? rawReservedCount
          : (rawReservedCount is num
              ? rawReservedCount.toInt()
              : _ForYouMailEntry.sample.reservedCount),
      orderNumber: readString(
        'orderNumber',
        _ForYouMailEntry.sample.orderNumber,
      ),
      purchaseDate: readString(
        'purchaseDate',
        _ForYouMailEntry.sample.purchaseDate,
      ),
      paidAmount: readString('paidAmount', _ForYouMailEntry.sample.paidAmount),
    );
  }
}

class _ForYouMailScreen extends StatefulWidget {
  const _ForYouMailScreen();

  @override
  State<_ForYouMailScreen> createState() => _ForYouMailScreenState();
}

class _ForYouMailScreenState extends State<_ForYouMailScreen> {
  String? _openedMailId;

  @override
  Widget build(BuildContext context) {
    final store = _TicketmasterCloudStore.instance;
    return SafeArea(
      bottom: false,
      child: ValueListenableBuilder<int>(
        valueListenable: store.forYouMailRevision,
        builder: (context, value, child) {
          final mails = store.forYouMails;
          final openedMail = _openedMailId == null
              ? null
              : _firstMailWhere(mails, _openedMailId!);
          if (openedMail != null) {
            return _GmailMailDetail(
              mail: openedMail,
              onBack: () => setState(() => _openedMailId = null),
            );
          }
          return _GmailInbox(
            mails: mails,
            onOpenMail: (mail) => setState(() => _openedMailId = mail.id),
          );
        },
      ),
    );
  }
}

class _GmailInbox extends StatelessWidget {
  const _GmailInbox({required this.mails, required this.onOpenMail});

  final List<_ForYouMailEntry> mails;
  final ValueChanged<_ForYouMailEntry> onOpenMail;

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[
      const _GmailSearchHeader(),
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 18, 16, 12),
        child: Text(
          'Primary',
          key: ValueKey('gmail-primary-label'),
          style: TextStyle(
            color: Color(0xFF3D4349),
            fontSize: 17,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
      const _PromotionsCard(),
      const _GmailMessageRow.staticGrey(
        sender: 'MLB Morning Lineup',
        subject: 'The biggest storylines heading into May',
        preview: 'Plus: Two walk-offs for one team?! Frida...',
        receivedLabel: 'May 1',
      ),
      const _GmailMessageRow.mlb(
        sender: 'MLB.com',
        subject: 'Verify your email address',
        preview: 'MLB We need to verify this email addres...',
        receivedLabel: 'May 1',
      ),
      const _GmailMessageRow.mlb(
        sender: 'MLB.com Account Service  2',
        subject: 'Your MLB sign in request',
        preview: 'Hey there, You requested to sign into yo...',
        receivedLabel: 'May 1',
      ),
      const _GmailMessageRow.staticGrey(
        sender: 'Nationals',
        subject: 'Tell us about your ticket purchase',
        preview: 'Give feedback May 1, 2026 View Online...',
        receivedLabel: 'May 1',
      ),
      const _GmailMessageRow.google(),
    ];

    for (final mail in mails) {
      rows.add(
        _GmailMessageRow.ticketmaster(
          mail: mail,
          onTap: () => onOpenMail(mail),
        ),
      );
    }

    return Container(
      color: const Color(0xFFEFF3F8),
      child: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.only(bottom: 96),
            children: rows,
          ),
          Positioned(
            right: 28,
            bottom: 30,
            child: _ComposeButton(),
          ),
        ],
      ),
    );
  }
}

class _GmailSearchHeader extends StatelessWidget {
  const _GmailSearchHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      child: Row(
        children: [
          const Icon(Icons.menu, size: 28, color: Color(0xFF384047)),
          const SizedBox(width: 18),
          Expanded(
            child: Container(
              height: 58,
              decoration: BoxDecoration(
                color: const Color(0xFFF9FBFD),
                borderRadius: BorderRadius.circular(36),
              ),
              alignment: Alignment.center,
              child: const Text(
                'Search in mail',
                key: ValueKey('gmail-search-placeholder'),
                style: TextStyle(
                  color: Color(0xFF4C535A),
                  fontSize: 18,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF607C88),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFDEE5EC)),
            ),
            alignment: Alignment.center,
            child: const Text(
              'E',
              key: ValueKey('gmail-account-initial'),
              style: TextStyle(color: Colors.white, fontSize: 22),
            ),
          ),
        ],
      ),
    );
  }
}

class _PromotionsCard extends StatelessWidget {
  const _PromotionsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
      padding: const EdgeInsets.fromLTRB(28, 14, 18, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFE),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.sell_outlined, color: Color(0xFF1D9A58), size: 30),
          SizedBox(width: 28),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Promotions',
                  key: ValueKey('gmail-promotions-title'),
                  style: TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'MLB.com Insider - Hi Baseball Fan, you...',
                  key: ValueKey('gmail-promotions-preview'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Color(0xFF202124),
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum _GmailAvatarKind { grey, mlb, ticketmaster, google }

class _GmailMessageRow extends StatelessWidget {
  const _GmailMessageRow({
    required this.sender,
    required this.subject,
    required this.preview,
    required this.receivedLabel,
    required this.avatarKind,
    this.onTap,
    this.starred = false,
    this.rowKeyPrefix = 'static',
  });

  const _GmailMessageRow.staticGrey({
    required String sender,
    required String subject,
    required String preview,
    required String receivedLabel,
  }) : this(
          sender: sender,
          subject: subject,
          preview: preview,
          receivedLabel: receivedLabel,
          avatarKind: _GmailAvatarKind.grey,
          rowKeyPrefix: sender,
        );

  const _GmailMessageRow.mlb({
    required String sender,
    required String subject,
    required String preview,
    required String receivedLabel,
  }) : this(
          sender: sender,
          subject: subject,
          preview: preview,
          receivedLabel: receivedLabel,
          avatarKind: _GmailAvatarKind.mlb,
          rowKeyPrefix: sender,
        );

  const _GmailMessageRow.google()
      : this(
          sender: 'Google',
          subject: '✅ Era, finish setting up your iPhone wit...',
          preview: 'Finish your setup',
          receivedLabel: 'May 1',
          avatarKind: _GmailAvatarKind.google,
          rowKeyPrefix: 'Google setup',
        );

  factory _GmailMessageRow.ticketmaster({
    required _ForYouMailEntry mail,
    required VoidCallback onTap,
  }) {
    return _GmailMessageRow(
      sender: mail.sender,
      subject: mail.subject,
      preview: mail.preview,
      receivedLabel: mail.receivedLabel,
      avatarKind: _GmailAvatarKind.ticketmaster,
      onTap: onTap,
      starred: true,
      rowKeyPrefix: mail.id,
    );
  }

  final String sender;
  final String subject;
  final String preview;
  final String receivedLabel;
  final _GmailAvatarKind avatarKind;
  final VoidCallback? onTap;
  final bool starred;
  final String rowKeyPrefix;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFF5F8FC),
      child: InkWell(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.fromLTRB(8, 0, 8, 4),
          padding: const EdgeInsets.fromLTRB(16, 15, 14, 14),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F9FD),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _MailAvatar(kind: avatarKind),
              const SizedBox(width: 18),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            sender,
                            key: ValueKey('gmail-row-$rowKeyPrefix-sender'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF3F454B),
                              fontSize: 20,
                              fontWeight: FontWeight.w400,
                              height: 1.05,
                            ),
                          ),
                        ),
                        Text(
                          receivedLabel,
                          key: ValueKey('gmail-row-$rowKeyPrefix-date'),
                          style: const TextStyle(
                            color: Color(0xFF3F454B),
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subject,
                      key: ValueKey('gmail-row-$rowKeyPrefix-subject'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFF3F454B),
                        fontSize: 16,
                        height: 1.16,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            preview,
                            key: ValueKey('gmail-row-$rowKeyPrefix-preview'),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Color(0xFF5A6169),
                              fontSize: 16,
                              height: 1.16,
                            ),
                          ),
                        ),
                        Icon(
                          starred ? Icons.star : Icons.star_border,
                          color: starred
                              ? const Color(0xFF4A90AF)
                              : const Color(0xFF59626B),
                          size: 28,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MailAvatar extends StatelessWidget {
  const _MailAvatar({required this.kind});

  final _GmailAvatarKind kind;

  @override
  Widget build(BuildContext context) {
    switch (kind) {
      case _GmailAvatarKind.ticketmaster:
        return const _TicketmasterCircleAvatar(radius: 28);
      case _GmailAvatarKind.google:
        return Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFFB847C8),
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const Text(
            'G',
            key: ValueKey('gmail-google-avatar'),
            style: TextStyle(color: Colors.white, fontSize: 28),
          ),
        );
      case _GmailAvatarKind.mlb:
        return Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
          ),
          alignment: Alignment.center,
          child: const _MlbMiniLogo(width: 40, height: 28),
        );
      case _GmailAvatarKind.grey:
        return Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: Color(0xFF9CA3AA),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.person, color: Colors.white, size: 38),
        );
    }
  }
}

class _ComposeButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: BoxDecoration(
        color: const Color(0xFFCFEAFF),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.edit, color: Color(0xFF092333), size: 28),
          SizedBox(width: 18),
          Text(
            'Compose',
            key: ValueKey('gmail-compose-label'),
            style: TextStyle(
              color: Color(0xFF092333),
              fontSize: 19,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _GmailMailDetail extends StatelessWidget {
  const _GmailMailDetail({required this.mail, required this.onBack});

  final _ForYouMailEntry mail;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8ECF2),
      child: Stack(
        children: [
          Column(
            children: [
              _MailDetailToolbar(onBack: onBack),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(14, 16, 14, 116),
                  children: [
                    _MailSubjectHeader(mail: mail),
                    const SizedBox(height: 16),
                    _MailCalendarSummary(mail: mail),
                    const SizedBox(height: 18),
                    const _MailFeedbackRow(),
                    const SizedBox(height: 10),
                    _MailSenderCard(mail: mail),
                    _MailBody(mail: mail),
                  ],
                ),
              ),
            ],
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _MailReplyBar(),
          ),
        ],
      ),
    );
  }
}

class _MailDetailToolbar extends StatelessWidget {
  const _MailDetailToolbar({required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            icon: const Icon(Icons.arrow_back, size: 31),
            color: const Color(0xFF202124),
          ),
          const Spacer(),
          const Icon(Icons.archive_outlined,
              size: 27, color: Color(0xFF202124)),
          const SizedBox(width: 28),
          const Icon(Icons.delete_outline, size: 30, color: Color(0xFF202124)),
          const SizedBox(width: 26),
          const Icon(Icons.mark_email_unread_outlined, size: 30),
          const SizedBox(width: 20),
          const Icon(Icons.more_vert, size: 30),
          const SizedBox(width: 10),
        ],
      ),
    );
  }
}

class _MailSubjectHeader extends StatelessWidget {
  const _MailSubjectHeader({required this.mail});

  final _ForYouMailEntry mail;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Text(
            mail.subject,
            key: ValueKey('${mail.id}-subject-detail'),
            style: const TextStyle(
              color: Color(0xFF202124),
              fontSize: 30,
              fontWeight: FontWeight.w400,
              height: 1.18,
            ),
          ),
        ),
        Container(
          margin: const EdgeInsets.only(left: 10, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 3),
          decoration: BoxDecoration(
            color: const Color(0xFFD0E9FC),
            borderRadius: BorderRadius.circular(5),
          ),
          child: const Text(
            'Inbox',
            key: ValueKey('gmail-detail-inbox-chip'),
            style: TextStyle(color: Color(0xFF43515C), fontSize: 15),
          ),
        ),
        const Padding(
          padding: EdgeInsets.only(left: 10, bottom: 0),
          child: Icon(Icons.star, color: Color(0xFF4A90AF), size: 36),
        ),
      ],
    );
  }
}

class _MailCalendarSummary extends StatelessWidget {
  const _MailCalendarSummary({required this.mail});

  final _ForYouMailEntry mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      padding: const EdgeInsets.fromLTRB(24, 18, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mail.timeRange,
                      key: ValueKey('${mail.id}-summary-time'),
                      style: const TextStyle(
                        color: Color(0xFF202124),
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        height: 1.12,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      mail.eventTitle,
                      key: ValueKey('${mail.id}-summary-title'),
                      style: const TextStyle(
                        color: Color(0xFF202124),
                        fontSize: 30,
                        fontWeight: FontWeight.w400,
                        height: 1.12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 14),
              const _CalendarIllustration(),
            ],
          ),
          const SizedBox(height: 26),
          _SummaryIconLine(
            icon: Icons.location_on_outlined,
            text: mail.venueName,
            textKey: '${mail.id}-summary-venue',
          ),
          const SizedBox(height: 28),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.only(top: 3),
                child: Icon(
                  Icons.event_seat_outlined,
                  color: Color(0xFF42484E),
                  size: 34,
                ),
              ),
              const SizedBox(width: 28),
              Expanded(
                child: Row(
                  children: [
                    _SeatInfoColumn(
                      title: 'Section',
                      value: mail.section,
                      titleKey: '${mail.id}-summary-section-label',
                      valueKey: '${mail.id}-summary-section-value',
                    ),
                    _SeatInfoColumn(
                      title: 'Row',
                      value: mail.row,
                      titleKey: '${mail.id}-summary-row-label',
                      valueKey: '${mail.id}-summary-row-value',
                    ),
                    _SeatInfoColumn(
                      title: 'Seat',
                      value: mail.seatRange,
                      titleKey: '${mail.id}-summary-seat-label',
                      valueKey: '${mail.id}-summary-seat-value',
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          _SummaryIconLine(
            icon: Icons.group_outlined,
            text: 'Reserved for ${mail.reservedCount}',
            textKey: '${mail.id}-summary-reserved',
          ),
          const SizedBox(height: 28),
          Row(
            children: const [
              _GoogleCalendarIcon(),
              SizedBox(width: 28),
              Text(
                'On your Google Calendar',
                key: ValueKey('gmail-google-calendar-label'),
                style: TextStyle(
                  color: Color(0xFF202124),
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: const [
                _SummaryPill(label: 'Invite others', dark: true),
                SizedBox(width: 12),
                _SummaryPill(label: 'Directions'),
                SizedBox(width: 12),
                _SummaryPill(label: 'View reservation'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryIconLine extends StatelessWidget {
  const _SummaryIconLine({
    required this.icon,
    required this.text,
    required this.textKey,
  });

  final IconData icon;
  final String text;
  final String textKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF42484E), size: 34),
        const SizedBox(width: 28),
        Expanded(
          child: Text(
            text,
            key: ValueKey(textKey),
            style: const TextStyle(
              color: Color(0xFF4F565D),
              fontSize: 20,
              height: 1.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _SeatInfoColumn extends StatelessWidget {
  const _SeatInfoColumn({
    required this.title,
    required this.value,
    required this.titleKey,
    required this.valueKey,
  });

  final String title;
  final String value;
  final String titleKey;
  final String valueKey;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            key: ValueKey(titleKey),
            style: const TextStyle(
              color: Color(0xFF202124),
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            key: ValueKey(valueKey),
            style: const TextStyle(
              color: Color(0xFF4F565D),
              fontSize: 17,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryPill extends StatelessWidget {
  const _SummaryPill({required this.label, this.dark = false});

  final String label;
  final bool dark;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      decoration: BoxDecoration(
        color: dark ? const Color(0xFF4F6571) : const Color(0xFFD6EAF9),
        borderRadius: BorderRadius.circular(30),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        key: ValueKey('gmail-summary-pill-$label'),
        style: TextStyle(
          color: dark ? Colors.white : const Color(0xFF1F2931),
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _CalendarIllustration extends StatelessWidget {
  const _CalendarIllustration();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: const Color(0xFFE5F6FF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Transform.rotate(
          angle: -0.10,
          child: Container(
            width: 58,
            height: 54,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(9),
              border: Border.all(color: const Color(0xFFDADCE0), width: 1.2),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x22000000),
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  height: 13,
                  decoration: const BoxDecoration(
                    color: Color(0xFF4285F4),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(8),
                    ),
                  ),
                ),
                const Expanded(
                  child: Center(
                    child: Text(
                      '5',
                      key: ValueKey('gmail-calendar-date-number'),
                      style: TextStyle(
                        color: Color(0xFF5F6368),
                        fontSize: 26,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _GoogleCalendarIcon extends StatelessWidget {
  const _GoogleCalendarIcon();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 34,
      height: 34,
      child: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const Positioned(
              left: 0,
              top: 0,
              right: 0,
              height: 8,
              child: ColoredBox(color: Color(0xFF4285F4))),
          const Positioned(
              left: 0,
              bottom: 0,
              width: 8,
              height: 26,
              child: ColoredBox(color: Color(0xFF34A853))),
          const Positioned(
              right: 0,
              bottom: 0,
              width: 8,
              height: 26,
              child: ColoredBox(color: Color(0xFFFBBC05))),
          const Center(
            child: Text(
              '31',
              key: ValueKey('gmail-calendar-icon-31'),
              style: TextStyle(
                color: Color(0xFF4285F4),
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MailFeedbackRow extends StatelessWidget {
  const _MailFeedbackRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'Based on this email',
            key: ValueKey('gmail-based-on-this-email'),
            style: TextStyle(color: Color(0xFF5F6368), fontSize: 16),
          ),
        ),
        Text(
          'Correct?',
          key: ValueKey('gmail-correct-label'),
          style: TextStyle(color: Color(0xFF5F6368), fontSize: 16),
        ),
        SizedBox(width: 18),
        Icon(Icons.thumb_up_alt_outlined, size: 26, color: Color(0xFF3C4043)),
        SizedBox(width: 16),
        Icon(Icons.thumb_down_alt_outlined, size: 26, color: Color(0xFF3C4043)),
      ],
    );
  }
}

class _MailSenderCard extends StatelessWidget {
  const _MailSenderCard({required this.mail});

  final _ForYouMailEntry mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFFF8FAFD),
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const _TicketmasterCircleAvatar(radius: 34),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Ticketmas...',
                        key: ValueKey('${mail.id}-sender-short'),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF202124),
                          fontSize: 21,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.verified,
                      color: Color(0xFF1A73E8),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      mail.receivedLabel == 'Today' ? 'Today' : 'Yesterday',
                      key: ValueKey('${mail.id}-sender-date'),
                      style: const TextStyle(
                        color: Color(0xFF5F6368),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 7),
                Row(
                  children: const [
                    Text(
                      'to me',
                      key: ValueKey('gmail-to-me-label'),
                      style: TextStyle(
                        color: Color(0xFF5F6368),
                        fontSize: 17,
                      ),
                    ),
                    SizedBox(width: 4),
                    Icon(
                      Icons.keyboard_arrow_down,
                      size: 20,
                      color: Color(0xFF5F6368),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Icon(Icons.emoji_emotions_outlined,
              size: 32, color: Color(0xFF6F7780)),
          const SizedBox(width: 22),
          const Icon(Icons.reply, size: 30, color: Color(0xFF202124)),
          const SizedBox(width: 16),
          const Icon(Icons.more_vert, size: 30, color: Color(0xFF202124)),
        ],
      ),
    );
  }
}

class _MailBody extends StatelessWidget {
  const _MailBody({required this.mail});

  final _ForYouMailEntry mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF8FAFD),
      padding: const EdgeInsets.fromLTRB(14, 0, 14, 20),
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            const SizedBox(height: 6),
            const SizedBox(
                height: 7, child: ColoredBox(color: Color(0xFF0074D9))),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
              child: Column(
                children: [
                  const Text(
                    'If this email is not displaying correctly, view in browser version.',
                    key: ValueKey('gmail-browser-version-label'),
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF202124), fontSize: 13),
                  ),
                  const SizedBox(height: 24),
                  const _MailBrandLogos(),
                  const SizedBox(height: 22),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              color: const Color(0xFF0C56E8),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  Text(
                    'Moon, Your Order is Confirmed',
                    key: ValueKey('${mail.id}-confirmed-title'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Order ${mail.orderNumber}',
                    key: ValueKey('${mail.id}-order-number-header'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Color(0xFFE1ECFF),
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            _EmailEventCard(mail: mail),
            _BallparkAccessSection(mail: mail),
            _OrderStatusSection(mail: mail),
            _CannotEnterSection(mail: mail),
            _EmailFooter(),
          ],
        ),
      ),
    );
  }
}

class _MailBrandLogos extends StatelessWidget {
  const _MailBrandLogos();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: Text(
            'ticketmaster',
            key: ValueKey('email-ticketmaster-logo-text'),
            style: TextStyle(
              color: Color(0xFF0A72CE),
              fontSize: 26,
              fontWeight: FontWeight.w800,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
        _MlbMiniLogo(width: 54, height: 36),
        SizedBox(width: 8),
        Text(
          'BALLPARK',
          key: ValueKey('email-ballpark-logo-text'),
          style: TextStyle(
            color: Color(0xFF0B1B35),
            fontSize: 24,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.5,
          ),
        ),
      ],
    );
  }
}

class _EmailEventCard extends StatelessWidget {
  const _EmailEventCard({required this.mail});

  final _ForYouMailEntry mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(18, 28, 18, 34),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFCED1D5)),
      ),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Center(child: _NationalsCard()),
          const SizedBox(height: 26),
          Text(
            mail.eventTitle,
            key: ValueKey('${mail.id}-email-event-title'),
            style: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          _EmailIconLine(
            icon: Icons.location_on,
            text: '${mail.venueName} - ${mail.venueCity},',
            textKey: '${mail.id}-email-venue',
          ),
          const SizedBox(height: 18),
          _EmailIconLine(
            icon: Icons.calendar_month_outlined,
            text: mail.dateLine,
            textKey: '${mail.id}-email-date',
          ),
        ],
      ),
    );
  }
}

class _EmailIconLine extends StatelessWidget {
  const _EmailIconLine({
    required this.icon,
    required this.text,
    required this.textKey,
  });

  final IconData icon;
  final String text;
  final String textKey;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: const Color(0xFF0067B9), size: 32),
        const SizedBox(width: 18),
        Expanded(
          child: Text(
            text,
            key: ValueKey(textKey),
            style: const TextStyle(
              color: Color(0xFF2E3135),
              fontSize: 23,
              height: 1.16,
            ),
          ),
        ),
      ],
    );
  }
}

class _BallparkAccessSection extends StatelessWidget {
  const _BallparkAccessSection({required this.mail});

  final _ForYouMailEntry mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(18, 0, 18, 32),
      color: const Color(0xFFF5F5F5),
      padding: const EdgeInsets.fromLTRB(28, 26, 28, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Access Your Tickets via the MLB Ballpark App',
            key: ValueKey('email-access-title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 19,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            'Download the app and use your Ticketmaster email to access and manage your tickets.',
            key: ValueKey('email-access-copy-one'),
            style:
                TextStyle(color: Color(0xFF202124), fontSize: 19, height: 1.18),
          ),
          const SizedBox(height: 22),
          const Text(
            'Create an account with the same email address you used to purchase your tickets on Ticketmaster.',
            key: ValueKey('email-access-copy-two'),
            style:
                TextStyle(color: Color(0xFF202124), fontSize: 19, height: 1.18),
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 17),
            decoration: BoxDecoration(
              color: const Color(0xFF0878DD),
              borderRadius: BorderRadius.circular(4),
            ),
            child: const Text(
              'Manage My Tickets',
              key: ValueKey('email-manage-my-tickets-button'),
              style: TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 34),
          const Center(child: _BallparkPromoArt()),
        ],
      ),
    );
  }
}

class _OrderStatusSection extends StatelessWidget {
  const _OrderStatusSection({required this.mail});

  final _ForYouMailEntry mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF4F4F4),
      padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              Icon(Icons.confirmation_num_outlined,
                  color: Color(0xFF9A4CB5), size: 38),
              SizedBox(width: 18),
              Expanded(
                child: Text(
                  'Order Status: Tickets Ready',
                  key: ValueKey('email-order-status-title'),
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 28),
          const Text(
            'Delivery Method: Mobile Tickets via MLB Ballpark',
            key: ValueKey('email-delivery-method'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w700,
              height: 1.18,
            ),
          ),
          const SizedBox(height: 30),
          Text(
            'Your tickets were issued by MLB Ballpark, the original ticket provider for this event.',
            key: ValueKey('${mail.id}-email-issued-copy'),
            style: const TextStyle(
                color: Colors.black, fontSize: 20, height: 1.18),
          ),
          const SizedBox(height: 26),
          const Text(
            'How to Access Your Tickets',
            key: ValueKey('email-how-to-access-title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 22),
          const Text(
            '1. Download the MLB Ballpark app.\n\n'
            '2. Create an account with the same email address you used to purchase your tickets on Ticketmaster and complete the email verification.\n\n'
            '3. Once you are signed in, you can view your tickets in the Home tab or through your wallet in the Tickets tab. Your phone is your ticket.',
            key: ValueKey('email-how-to-access-steps'),
            style: TextStyle(color: Colors.black, fontSize: 20, height: 1.16),
          ),
          const SizedBox(height: 24),
          const Text(
            "Can't Access Tickets?",
            key: ValueKey('email-cant-access-title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Make sure you are logged in to your MLB account with the same email used to purchase your tickets.\n\n'
            'Your tickets should appear on the Home or Tickets tab of the MLB App.\n\n'
            "If tickets don't appear, verify your email address or try refreshing the tab by pulling down on the screen.\n\n"
            'For more information, visit our Help Center.',
            key: ValueKey('email-cant-access-copy'),
            style: TextStyle(color: Colors.black, fontSize: 20, height: 1.16),
          ),
        ],
      ),
    );
  }
}

class _CannotEnterSection extends StatelessWidget {
  const _CannotEnterSection({required this.mail});

  final _ForYouMailEntry mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(18, 32, 18, 36),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THIS EMAIL CANNOT BE USED FOR ENTRY',
            key: ValueKey('email-cannot-be-used-title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 28),
          _YourOrderCard(mail: mail),
          const SizedBox(height: 28),
          _PaymentCard(mail: mail),
          const SizedBox(height: 34),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD1D5DB)),
            ),
            padding: const EdgeInsets.fromLTRB(28, 28, 28, 28),
            child: const Text(
              'TICKETS MUST BE ACCEPTED FROM MLB BALLPARK FOR EVENT ENTRY.\nTHIS EMAIL IS NOT YOUR TICKET.',
              key: ValueKey('email-ticket-warning'),
              style: TextStyle(
                color: Colors.black,
                fontSize: 24,
                fontWeight: FontWeight.w800,
                height: 1.18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YourOrderCard extends StatelessWidget {
  const _YourOrderCard({required this.mail});

  final _ForYouMailEntry mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 232,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      padding: const EdgeInsets.fromLTRB(26, 24, 22, 26),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Order',
            key: ValueKey('email-your-order-title'),
            style: TextStyle(
              color: Colors.black,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              const Icon(Icons.confirmation_num_outlined,
                  color: Color(0xFF0B78D0), size: 34),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  '${mail.reservedCount}x Resale ticket',
                  key: ValueKey('${mail.id}-email-ticket-count'),
                  style: const TextStyle(
                    color: Colors.black,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(height: 1, color: Color(0xFFE6E8EB)),
          const SizedBox(height: 16),
          Row(
            children: [
              _OrderSeatColumn(
                label: 'Section',
                value: mail.section,
                labelKey: '${mail.id}-email-order-section-label',
                valueKey: '${mail.id}-email-order-section-value',
              ),
              _OrderSeatColumn(
                label: 'Row',
                value: mail.row,
                labelKey: '${mail.id}-email-order-row-label',
                valueKey: '${mail.id}-email-order-row-value',
              ),
              _OrderSeatColumn(
                label: 'Seat',
                value: mail.seat,
                labelKey: '${mail.id}-email-order-seat-label',
                valueKey: '${mail.id}-email-order-seat-value',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _OrderSeatColumn extends StatelessWidget {
  const _OrderSeatColumn({
    required this.label,
    required this.value,
    required this.labelKey,
    required this.valueKey,
  });

  final String label;
  final String value;
  final String labelKey;
  final String valueKey;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            key: ValueKey(labelKey),
            style: const TextStyle(
              color: Color(0xFF0074D9),
              fontSize: 17,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            key: ValueKey(valueKey),
            style: const TextStyle(color: Colors.black, fontSize: 17),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard({required this.mail});

  final _ForYouMailEntry mail;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 270,
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFFD1D5DB)),
      ),
      padding: const EdgeInsets.fromLTRB(26, 22, 26, 24),
      child: Column(
        children: [
          _PaymentRow(
            label: 'Purchased:',
            value: mail.purchaseDate,
            keyPrefix: '${mail.id}-purchased',
          ),
          const SizedBox(height: 22),
          _PaymentRow(
            label: 'You Paid:',
            value: mail.paidAmount,
            keyPrefix: '${mail.id}-paid',
          ),
        ],
      ),
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({
    required this.label,
    required this.value,
    required this.keyPrefix,
  });

  final String label;
  final String value;
  final String keyPrefix;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          label,
          key: ValueKey('$keyPrefix-label'),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        Text(
          value,
          key: ValueKey('$keyPrefix-value'),
          style: const TextStyle(color: Colors.black, fontSize: 18),
        ),
      ],
    );
  }
}

class _EmailFooter extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: const Color(0xFF172029),
      padding: const EdgeInsets.fromLTRB(26, 32, 26, 38),
      child: Column(
        children: const [
          _FooterSocialRow(),
          SizedBox(height: 28),
          Text(
            'Ticketmaster | Help | Privacy | Terms of Use',
            key: ValueKey('email-footer-links'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF17E5E5),
              fontSize: 20,
              fontWeight: FontWeight.w800,
              decoration: TextDecoration.underline,
            ),
          ),
          SizedBox(height: 24),
          Text(
            'This email confirms your ticket order so save it for future reference. All purchases are subject to credit card approval and billing address verification. We make every effort to be accurate, but we cannot be responsible for changes, cancellations or postponements announced after this email is sent.\n\n'
            '© 2026 Ticketmaster. All rights reserved.\n\n'
            'Please do not reply to this email. Replies to this email will not be responded to or read. If you have any questions or comments, contact us.',
            key: ValueKey('email-footer-copy'),
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              height: 1.24,
            ),
          ),
        ],
      ),
    );
  }
}

class _FooterSocialRow extends StatelessWidget {
  const _FooterSocialRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        _FooterSocial(label: 'BLOG', small: true),
        SizedBox(width: 18),
        _FooterSocial(label: 'f'),
        SizedBox(width: 18),
        _FooterSocial(label: 'X', large: true),
        SizedBox(width: 18),
        _FooterSocial(label: 'You\nTube', small: true),
        SizedBox(width: 18),
        _FooterSocial(label: '◎'),
      ],
    );
  }
}

class _FooterSocial extends StatelessWidget {
  const _FooterSocial({
    required this.label,
    this.small = false,
    this.large = false,
  });

  final String label;
  final bool small;
  final bool large;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: large ? 68 : 54,
      height: large ? 68 : 54,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 2),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        key: ValueKey('email-footer-social-$label'),
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: small ? 11 : (large ? 42 : 30),
          fontWeight: FontWeight.w600,
          height: 0.95,
        ),
      ),
    );
  }
}

class _MailReplyBar extends StatelessWidget {
  const _MailReplyBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFE8ECF2),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Row(
        children: const [
          Expanded(
            child: _ReplyButton(icon: Icons.reply, label: 'Reply'),
          ),
          SizedBox(width: 14),
          Expanded(
            child: _ReplyButton(icon: Icons.forward, label: 'Forward'),
          ),
          SizedBox(width: 10),
          CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFDDE3EA),
            child:
                Icon(Icons.emoji_emotions_outlined, color: Color(0xFF7B838C)),
          ),
        ],
      ),
    );
  }
}

class _ReplyButton extends StatelessWidget {
  const _ReplyButton({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 62,
      decoration: BoxDecoration(
        color: const Color(0xFF4D6370),
        borderRadius: BorderRadius.circular(32),
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(width: 12),
          Text(
            label,
            key: ValueKey('gmail-reply-bar-$label'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketmasterCircleAvatar extends StatelessWidget {
  const _TicketmasterCircleAvatar({required this.radius});

  final double radius;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: radius * 2,
      height: radius * 2,
      decoration: const BoxDecoration(
        color: Color(0xFF006FE8),
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        't',
        key: ValueKey('ticketmaster-avatar-$radius'),
        style: TextStyle(
          color: Colors.white,
          fontSize: radius * 1.75,
          fontWeight: FontWeight.w800,
          fontStyle: FontStyle.italic,
          height: 0.86,
        ),
      ),
    );
  }
}

class _NationalsCard extends StatelessWidget {
  const _NationalsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      height: 126,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        gradient: const LinearGradient(
          colors: [Color(0xFFC90013), Color(0xFF930006)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: const Center(
        child: Text(
          'W',
          key: ValueKey('nationals-w-logo'),
          style: TextStyle(
            color: Colors.white,
            fontSize: 72,
            fontWeight: FontWeight.w900,
            fontStyle: FontStyle.italic,
            fontFamily: 'Times New Roman',
          ),
        ),
      ),
    );
  }
}

class _BallparkPromoArt extends StatelessWidget {
  const _BallparkPromoArt();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      height: 354,
      color: const Color(0xFFE8E1D3),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 128,
            height: 128,
            decoration: BoxDecoration(
              color: const Color(0xFF108C3E),
              borderRadius: BorderRadius.circular(28),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x33000000),
                  blurRadius: 12,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: Container(
              width: 96,
              height: 64,
              color: Colors.white,
              alignment: Alignment.center,
              child: const Text(
                'BALLPARK',
                key: ValueKey('ballpark-promo-logo'),
                style: TextStyle(
                  color: Color(0xFF0B1B35),
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
          const SizedBox(height: 40),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 22),
            child: Text(
              'Download the official MLB\nBallpark app. Available on\nboth iOS and Android.',
              key: ValueKey('ballpark-promo-copy'),
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF0B2440),
                fontSize: 22,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MlbMiniLogo extends StatelessWidget {
  const _MlbMiniLogo({required this.width, required this.height});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(width, height),
      painter: const _MlbMiniLogoPainter(),
    );
  }
}

class _MlbMiniLogoPainter extends CustomPainter {
  const _MlbMiniLogoPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final bluePaint = Paint()..color = const Color(0xFF0B2E5F);
    final redPaint = Paint()..color = const Color(0xFFE41E32);
    final whitePaint = Paint()..color = Colors.white;
    final rect = Offset.zero & size;
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      bluePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.58, 0, size.width * 0.42, size.height),
      redPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.52, size.height * 0.48),
      size.height * 0.25,
      whitePaint,
    );
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.28,
        size.height * 0.54,
        size.width * 0.36,
        size.height * 0.12,
      ),
      whitePaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.76, size.height * 0.36),
      size.height * 0.07,
      whitePaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

_ForYouMailEntry? _firstMailWhere(
  List<_ForYouMailEntry> mails,
  String mailId,
) {
  for (final mail in mails) {
    if (mail.id == mailId) {
      return mail;
    }
  }
  return null;
}

String _mailVenueCity(String venue) {
  final parts = venue.split('-');
  if (parts.length > 1) {
    return parts.last.trim();
  }
  return 'Washington';
}

String _mailCompactDate(String rawDate) {
  final trimmed =
      rawDate.replaceAll('\n', ' ').replaceAll(RegExp(r'\s+'), ' ').trim();
  if (trimmed.isEmpty) {
    return _ForYouMailEntry.sample.dateLine;
  }
  if (trimmed.contains('@')) {
    return _mailTitleCaseWords(trimmed);
  }

  final parts = trimmed.split(',').map((part) => part.trim()).toList();
  if (parts.length >= 3) {
    final day = _mailTitleCaseWords(parts.first);
    final date = _mailTitleCaseWords(
      parts[1].replaceAll(RegExp(r'\s+20\d{2}\b'), '').trim(),
    );
    final time = parts.sublist(2).join(', ').trim();
    return '$day, $date @ $time';
  }

  return _mailTitleCaseWords(
    trimmed.replaceAll(RegExp(r'\s+20\d{2},?'), ''),
  );
}

String _mailTitleCaseWords(String value) {
  return value.split(' ').map((part) {
    if (part.isEmpty || part.contains(':') || part == '@') {
      return part;
    }
    final lettersOnly = part.replaceAll(RegExp(r'[^A-Za-z]'), '');
    if (lettersOnly == 'AM' || lettersOnly == 'PM') {
      return part;
    }
    return part[0].toUpperCase() + part.substring(1).toLowerCase();
  }).join(' ');
}

String _mailTodayLabel(DateTime date) {
  const months = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'May',
    'Jun',
    'Jul',
    'Aug',
    'Sep',
    'Oct',
    'Nov',
    'Dec',
  ];
  return '${months[date.month - 1]} ${date.day}, ${date.year}';
}
