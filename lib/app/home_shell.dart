part of 'package:ticketmaster/main.dart';

class TicketmasterHomeShell extends StatefulWidget {
  const TicketmasterHomeShell({super.key});

  @override
  State<TicketmasterHomeShell> createState() => _TicketmasterHomeShellState();
}

class _TicketmasterHomeShellState extends State<TicketmasterHomeShell> {
  int _index = 0;
  int _previousIndex = 0;
  int _direction = 1;
  static const _navIconSize = 24.0;

  void _onNavTap(int newIndex) {
    if (newIndex == _index) return;
    setState(() {
      _previousIndex = _index;
      _direction = newIndex > _index ? 1 : -1;
      _index = newIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      const DiscoverScreen(),
      const ForYouScreen(),
      const MyTicketsScreen(),
      const SellScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      body: Stack(
        children: List.generate(pages.length, (i) {
          final isActive = i == _index;
          final isOutgoing = i == _previousIndex && _previousIndex != _index;
          return _AnimatedTabView(
            isActive: isActive,
            isOutgoing: isOutgoing,
            direction: _direction,
            child: pages[i],
          );
        }),
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: const BoxDecoration(
          border: Border(top: BorderSide(color: TmColors.divider, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: _index,
          onTap: _onNavTap,
          selectedItemColor: TmColors.brandBlue,
          unselectedItemColor: TmColors.navUnselected,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          selectedLabelStyle: TmTypography.navLabel,
          unselectedLabelStyle: TmTypography.navLabel,
          iconSize: 24,
          backgroundColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                TmAssets.bottomDiscover,
                width: _navIconSize,
                height: _navIconSize,
                cacheWidth: 72,
                cacheHeight: 72,
              ),
              activeIcon: Image.asset(
                TmAssets.bottomDiscoverOn,
                width: _navIconSize,
                height: _navIconSize,
                cacheWidth: 72,
                cacheHeight: 72,
              ),
              label: 'Discover',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                TmAssets.bottomForYou,
                width: _navIconSize,
                height: _navIconSize,
                cacheWidth: 72,
                cacheHeight: 72,
              ),
              activeIcon: Image.asset(
                TmAssets.bottomForYouOn,
                width: _navIconSize,
                height: _navIconSize,
                cacheWidth: 72,
                cacheHeight: 72,
              ),
              label: 'For You',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                TmAssets.bottomTickets,
                width: _navIconSize,
                height: _navIconSize,
                cacheWidth: 72,
                cacheHeight: 72,
              ),
              activeIcon: Image.asset(
                TmAssets.bottomTicketsOn,
                width: _navIconSize,
                height: _navIconSize,
                cacheWidth: 72,
                cacheHeight: 72,
              ),
              label: 'My Tickets',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                TmAssets.bottomSell,
                width: _navIconSize,
                height: _navIconSize,
                cacheWidth: 72,
                cacheHeight: 72,
              ),
              activeIcon: Image.asset(
                TmAssets.bottomSellOn,
                width: _navIconSize,
                height: _navIconSize,
                cacheWidth: 72,
                cacheHeight: 72,
              ),
              label: 'Sell',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                TmAssets.bottomAccount,
                width: _navIconSize,
                height: _navIconSize,
                cacheWidth: 72,
                cacheHeight: 72,
              ),
              activeIcon: Image.asset(
                TmAssets.bottomAccountOn,
                width: _navIconSize,
                height: _navIconSize,
                cacheWidth: 72,
                cacheHeight: 72,
              ),
              label: 'My Account',
            ),
          ],
        ),
      ),
    );
  }
}

class _AnimatedTabView extends StatelessWidget {
  const _AnimatedTabView({
    required this.isActive,
    required this.isOutgoing,
    required this.direction,
    required this.child,
  });

  final bool isActive;
  final bool isOutgoing;
  final int direction;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final offset = isActive
        ? Offset.zero
        : Offset(isOutgoing ? -0.08 * direction : 0.08 * direction, 0);

    // Direction-aware fade + slide for bottom tab switching.
    return IgnorePointer(
      ignoring: !isActive,
      child: AnimatedOpacity(
        opacity: isActive ? 1.0 : 0.0,
        duration: TmDurations.tabSwitch,
        curve: TmCurves.easeOut,
        child: AnimatedSlide(
          offset: offset,
          duration: TmDurations.tabSwitch,
          curve: TmCurves.easeOut,
          child: child,
        ),
      ),
    );
  }
}

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final feed = _discoverFeedEntries;
    return SafeArea(
      bottom: false,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _DiscoverHeader(),
          const SizedBox(height: 8),
          for (int index = 0; index < feed.length; index++) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: AnimatedCard(
                delay: Duration(milliseconds: 80 + ((index % 8) * 60)),
                child: index.isEven
                    ? _HeroCard(entry: feed[index])
                    : _TalentCard(entry: feed[index]),
              ),
            ),
            SizedBox(height: index == feed.length - 1 ? 20 : 16),
          ],
        ],
      ),
    );
  }
}

final List<_DiscoverFeedEntry> _discoverFeedEntries =
    _buildDiscoverFeedEntries();

class _DiscoverFeedEntry {
  const _DiscoverFeedEntry({
    required this.eyebrow,
    required this.title,
    required this.subtitle,
    required this.location,
    required this.dateLabel,
    required this.ctaLabel,
    required this.imageAsset,
    required this.primaryColor,
    required this.secondaryColor,
    required this.accentIcon,
  });

  final String eyebrow;
  final String title;
  final String subtitle;
  final String location;
  final String dateLabel;
  final String ctaLabel;
  final String imageAsset;
  final Color primaryColor;
  final Color secondaryColor;
  final IconData accentIcon;
}

List<_DiscoverFeedEntry> _buildDiscoverFeedEntries() {
  const eventNames = <String>[
    'Taylor Swift',
    'Coldplay',
    'Lakers vs Celtics',
    'Hamilton',
    'Nate Bargatze',
    'Bad Bunny',
    'SZA',
    'Billie Eilish',
    'The Lion King',
    'Kevin Hart',
    'Metallica',
    'Drake',
    'Shakira',
    'Arctic Monkeys',
    'UFC Fight Night',
    'New York Yankees vs Dodgers',
    'Wicked',
    'John Mulaney',
    'Bruno Mars',
    'Burna Boy',
  ];
  const eventTags = <String>[
    'Fan Presale',
    'Opening Weekend',
    'VIP Experience',
    'Late Night Show',
    'Final Stop',
  ];
  const categories = <String>[
    'CONCERTS',
    'SPORTS',
    'COMEDY',
    'THEATER',
    'FESTIVAL',
  ];
  const venues = <String>[
    'Madison Square Garden',
    'Crypto.com Arena',
    'Wrigley Field',
    'The Wiltern',
    'Red Rocks Amphitheatre',
    'Kia Forum',
    'United Center',
    'Fenway Park',
    'Beacon Theatre',
    'Paramount Theatre',
  ];
  const cities = <String>[
    'New York, NY',
    'Los Angeles, CA',
    'Chicago, IL',
    'Denver, CO',
    'Boston, MA',
    'Austin, TX',
    'Seattle, WA',
    'Atlanta, GA',
    'Miami, FL',
    'Nashville, TN',
  ];
  const blurbs = <String>[
    'Premium seats, verified resale, and last-minute drops.',
    'Trending now with strong fan demand and fresh inventory.',
    'New dates added for fans tracking popular weekend events.',
    'Great picks for friends planning a night out together.',
    'Top local shows with fast-selling upper bowl sections.',
    'Fresh recommendations based on popular Ticketmaster categories.',
  ];
  const ctas = <String>[
    'Find Tickets',
    'See Dates',
    'Unlock Presale',
    'View Event',
  ];
  const imageAssets = <String>[
    TmAssets.discoverHero,
    TmAssets.discoverPerson,
    TmAssets.sellHero,
    'assets/hero.jpg',
    'assets/talent.jpg',
    'assets/icon.jpg',
    'assets/icon_original.jpg',
    'assets/apk/images/rockies_cr.png',
    'assets/apk/images/icon_blue_white.png',
    'assets/apk/images/Landing_Icon.png',
    'assets/tm/ticket_resale.png',
    'assets/tm/tickets_resale_icon.png',
    'assets/tm/onboarding_favorite_icon.png',
    'assets/tm/tm_fanpass_account_icon.png',
  ];
  const palettes = <List<Color>>[
    <Color>[Color(0xFF0D1B2A), Color(0xFF1B263B)],
    <Color>[Color(0xFF3A0F23), Color(0xFF82204A)],
    <Color>[Color(0xFF0A2E36), Color(0xFF26798E)],
    <Color>[Color(0xFF2D1B0E), Color(0xFFD97706)],
    <Color>[Color(0xFF171717), Color(0xFF525252)],
    <Color>[Color(0xFF14213D), Color(0xFFFCA311)],
    <Color>[Color(0xFF1F2937), Color(0xFF2563EB)],
    <Color>[Color(0xFF172554), Color(0xFF7C3AED)],
    <Color>[Color(0xFF052E16), Color(0xFF16A34A)],
    <Color>[Color(0xFF3F0D12), Color(0xFFA71D31)],
  ];
  const icons = <IconData>[
    Icons.music_note_rounded,
    Icons.stadium_rounded,
    Icons.mic_rounded,
    Icons.theater_comedy_rounded,
    Icons.local_activity_rounded,
    Icons.celebration_rounded,
  ];
  const monthDays = <String>[
    'FRI, APR 11',
    'SAT, APR 19',
    'SUN, MAY 4',
    'THU, MAY 22',
    'FRI, JUN 6',
    'SAT, JUN 21',
    'SUN, JUL 13',
    'THU, AUG 7',
    'FRI, SEP 12',
    'SAT, OCT 18',
  ];

  return List<_DiscoverFeedEntry>.generate(102, (index) {
    final eventName = eventNames[index % eventNames.length];
    final eventTag = eventTags[(index ~/ eventNames.length) % eventTags.length];
    final location = cities[(index * 3) % cities.length];
    final venue = venues[(index * 5) % venues.length];
    final palette = palettes[index % palettes.length];
    return _DiscoverFeedEntry(
      eyebrow: categories[index % categories.length],
      title: '$eventName $eventTag',
      subtitle: blurbs[(index * 7) % blurbs.length],
      location: venue,
      dateLabel: '${monthDays[index % monthDays.length]} • $location',
      ctaLabel: ctas[index % ctas.length],
      imageAsset: imageAssets[index % imageAssets.length],
      primaryColor: palette[0],
      secondaryColor: palette[1],
      accentIcon: icons[index % icons.length],
    );
  });
}

class _DiscoverHeader extends StatelessWidget {
  const _DiscoverHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.only(top: 8, bottom: 12),
      child: Column(
        children: const [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _BrandRow(),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _FilterRow(),
          ),
          SizedBox(height: 8),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: _SearchBar(),
          ),
          SizedBox(height: 10),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: _CategoryRow(),
          ),
        ],
      ),
    );
  }
}

class ForYouScreen extends StatelessWidget {
  const ForYouScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ForYouMailScreen();
  }
}

class MyTicketsScreen extends StatefulWidget {
  const MyTicketsScreen({super.key});

  @override
  State<MyTicketsScreen> createState() => _MyTicketsScreenState();
}

class _TicketListEntry {
  const _TicketListEntry({
    required this.id,
    required this.displayTitle,
    required this.displayVenue,
    required this.displayDateLabel,
    required this.searchKeywords,
    this.ticketCount = 1,
    this.imageSelection,
  });

  final int id;
  final String displayTitle;
  final String displayVenue;
  final String displayDateLabel;
  final String searchKeywords;
  final int ticketCount;
  final TicketCardImageSelection? imageSelection;

  String textKey(String field) => 'ticket-$id-$field';

  String ticketInstanceTextKey(int ticketIndex, String field) =>
      'ticket-$id-instance-${ticketIndex + 1}-$field';

  String get editableTitle =>
      _EditableTextStore.valueFor(textKey('title'), displayTitle);

  String get editableVenue =>
      _EditableTextStore.valueFor(textKey('venue'), displayVenue);

  String get editableDateLabel =>
      _EditableTextStore.valueFor(textKey('date'), displayDateLabel);

  String get singleLineTitle => editableTitle
      .replaceAll('\n', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  String get primaryVenue => editableVenue.split('-').first.trim();

  String get detailsSubtitle => '$editableDateLabel • $primaryVenue';

  _TicketListEntry copyWith({
    TicketCardImageSelection? imageSelection,
    int? ticketCount,
  }) {
    return _TicketListEntry(
      id: id,
      displayTitle: displayTitle,
      displayVenue: displayVenue,
      displayDateLabel: displayDateLabel,
      searchKeywords: searchKeywords,
      ticketCount: ticketCount ?? this.ticketCount,
      imageSelection: imageSelection ?? this.imageSelection,
    );
  }
}

class _MyTicketsScreenState extends State<MyTicketsScreen> {
  static const String _defaultTicketTitle =
      'COLORADO ROCKIES VS.\nSAN DIEGO PADRES';
  static const String _defaultTicketVenue = 'Coors Field - Denver, CO';
  static const String _defaultTicketDate = 'MON, SEP 14 2026, 6:40 PM';

  final TextEditingController _ticketSearchController = TextEditingController();
  final FocusNode _ticketSearchFocusNode = FocusNode();

  late List<_TicketListEntry> _upcomingTickets;
  int? _activeTicketOptionsTicketId;
  bool _showSearchBar = false;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _upcomingTickets = _TicketmasterCloudStore.instance.hasSavedTickets
        ? _TicketmasterCloudStore.instance.upcomingTickets
        : List<_TicketListEntry>.generate(
            1,
            (index) => _buildTicketEntry(index),
          );
  }

  @override
  void dispose() {
    _ticketSearchController.dispose();
    _ticketSearchFocusNode.dispose();
    super.dispose();
  }

  _TicketListEntry _buildTicketEntry(int index) {
    final ticketNumber = index + 1;
    return _TicketListEntry(
      id: ticketNumber,
      displayTitle: _defaultTicketTitle,
      displayVenue: _defaultTicketVenue,
      displayDateLabel: _defaultTicketDate,
      searchKeywords:
          'ticket $ticketNumber colorado rockies padres coors field denver sep 14 2026 mobile',
    );
  }

  List<_TicketListEntry> get _visibleUpcomingTickets {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) {
      return _upcomingTickets;
    }
    return _upcomingTickets
        .where((ticket) {
          final haystack = [
            ticket.editableTitle,
            ticket.editableVenue,
            ticket.editableDateLabel,
            ticket.searchKeywords,
          ].join(' ').toLowerCase();
          return haystack.contains(query);
        })
        .toList(growable: false);
  }

  void _showTicketOptionsSheet(int ticketId) {
    if (_activeTicketOptionsTicketId == ticketId) return;
    setState(() {
      _activeTicketOptionsTicketId = ticketId;
    });
  }

  void _hideTicketOptions() {
    if (_activeTicketOptionsTicketId == null) return;
    setState(() {
      _activeTicketOptionsTicketId = null;
    });
  }

  Future<void> _showUpcomingTicketCountDialog() async {
    _hideTicketOptions();
    final count = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return _UpcomingTicketCountDialog(
          initialCount: _upcomingTickets.length,
        );
      },
    );
    if (!mounted || count == null) {
      return;
    }
    setState(() {
      final nextTickets = List<_TicketListEntry>.generate(count, (index) {
        if (index < _upcomingTickets.length) {
          return _upcomingTickets[index];
        }
        return _buildTicketEntry(index);
      });
      _upcomingTickets = nextTickets;
    });
    await _TicketmasterCloudStore.instance.saveUpcomingTickets(
      _upcomingTickets,
    );
  }

  Future<void> _showTicketQuantityDialog(_TicketListEntry ticket) async {
    _hideTicketOptions();
    final count = await showDialog<int>(
      context: context,
      builder: (dialogContext) {
        return _UpcomingTicketCountDialog(
          initialCount: ticket.ticketCount,
          title: 'Set ticket quantity',
          hintText: 'How many tickets inside this card?',
          confirmLabel: 'Save',
        );
      },
    );
    if (!mounted || count == null) {
      return;
    }
    setState(() {
      _upcomingTickets = _upcomingTickets
          .map((entry) {
            if (entry.id != ticket.id) {
              return entry;
            }
            return entry.copyWith(ticketCount: count);
          })
          .toList(growable: false);
    });
    await _TicketmasterCloudStore.instance.saveUpcomingTickets(
      _upcomingTickets,
    );
  }

  void _showPastSearch() {
    _hideTicketOptions();
    if (!_showSearchBar) {
      setState(() {
        _showSearchBar = true;
      });
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      _ticketSearchFocusNode.requestFocus();
    });
  }

  void _hidePastSearch() {
    _ticketSearchFocusNode.unfocus();
    setState(() {
      _showSearchBar = false;
      _searchQuery = '';
      _ticketSearchController.clear();
    });
  }

  Future<void> _pickTicketImage(TicketImageSource source, int ticketId) async {
    _hideTicketOptions();
    try {
      final bytes = await pickTicketImage(source);
      if (!mounted || bytes == null) {
        return;
      }
      final croppedSelection = await Navigator.of(context)
          .push<TicketCardImageSelection>(
            MaterialPageRoute(
              builder: (context) => TicketCardImageCropPage(
                imageBytes: bytes,
                targetAspectRatio:
                    ((MediaQuery.sizeOf(context).width - 28) / 180)
                        .clamp(1.6, 2.4)
                        .toDouble(),
              ),
            ),
          );
      if (!mounted || croppedSelection == null) {
        return;
      }
      setState(() {
        _upcomingTickets = _upcomingTickets
            .map((ticket) {
              if (ticket.id != ticketId) {
                return ticket;
              }
              return ticket.copyWith(imageSelection: croppedSelection);
            })
            .toList(growable: false);
      });
      await _TicketmasterCloudStore.instance.saveUpcomingTickets(
        _upcomingTickets,
      );
    } on PlatformException catch (error) {
      if (!mounted) return;
      final message = error.message ?? 'Unable to pick image right now.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    } on UnsupportedError catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message ?? 'Unsupported')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Image selection failed. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final visibleTickets = _visibleUpcomingTickets;

    return Container(
      color: const Color(0xFFE9E9E9),
      child: SafeArea(
        child: Column(
          children: [
            _TicketsHeader(
              upcomingCount: _upcomingTickets.length,
              onUpcomingDoubleTap: _showUpcomingTicketCountDialog,
              onPastDoubleTap: _showPastSearch,
            ),
            if (_showSearchBar)
              Padding(
                padding: const EdgeInsets.fromLTRB(14, 10, 14, 0),
                child: _TicketSearchBar(
                  controller: _ticketSearchController,
                  focusNode: _ticketSearchFocusNode,
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                  onClose: _hidePastSearch,
                ),
              ),
            Expanded(
              child: visibleTickets.isEmpty
                  ? const _TicketSearchEmptyState()
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 18),
                      itemCount: visibleTickets.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 14),
                      itemBuilder: (context, index) {
                        final ticket = visibleTickets[index];
                        final isShowingOptions =
                            _activeTicketOptionsTicketId == ticket.id;
                        return _TicketCard(
                          uploadedImageSelection: ticket.imageSelection,
                          ticketCount: ticket.ticketCount,
                          title: ticket.editableTitle,
                          venue: ticket.editableVenue,
                          dateLabel: ticket.editableDateLabel,
                          titleTextKey: ticket.textKey('title'),
                          venueTextKey: ticket.textKey('venue'),
                          dateTextKey: ticket.textKey('date'),
                          showTicketOptions: isShowingOptions,
                          onDismissTicketOptions: _hideTicketOptions,
                          onSelectGallery: () {
                            _pickTicketImage(
                              TicketImageSource.gallery,
                              ticket.id,
                            );
                          },
                          onSelectCamera: () {
                            _pickTicketImage(
                              TicketImageSource.camera,
                              ticket.id,
                            );
                          },
                          onDoubleTap: () {
                            _showTicketOptionsSheet(ticket.id);
                          },
                          onLongPress: () {
                            _showTicketOptionsSheet(ticket.id);
                          },
                          onCountDoubleTap: () {
                            _showTicketQuantityDialog(ticket);
                          },
                          onTap: () {
                            if (isShowingOptions) {
                              _hideTicketOptions();
                              return;
                            }
                            Navigator.of(context).push(
                              _MyTicketDetailsRoute(
                                ticket: ticket,
                                ticketCount: ticket.ticketCount,
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class SellScreen extends StatelessWidget {
  const SellScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const SafeArea(child: _SellLanding());
  }
}

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser;

    return SafeArea(
      child: Container(
        color: const Color(0xFF050608),
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        child: ListView(
          children: [
            const _TopBar(title: 'My Account'),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x24000000),
                    blurRadius: 26,
                    offset: Offset(0, 14),
                  ),
                ],
              ),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const material.Text(
                    'Signed In Account',
                    style: TextStyle(
                      color: Color(0xFF111827),
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  material.Text(
                    currentUser?.email ?? 'No account is signed in.',
                    style: const TextStyle(
                      color: Color(0xFF4B5563),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: currentUser == null
                    ? null
                    : () async {
                        await _TicketmasterCloudStore.instance.clearAuthSession(
                          releaseDeviceLock: true,
                        );
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) {
                          return;
                        }
                        Navigator.of(context).pushAndRemoveUntil(
                          _TicketmasterLoginRoute(),
                          (route) => false,
                        );
                      },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF101318),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  elevation: 0,
                ),
                child: const material.Text(
                  'Log Out',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SellLanding extends StatelessWidget {
  const _SellLanding();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: EdgeInsets.zero,
            children: const [
              _SellHero(),
              _SellListItem(
                iconAsset: 'assets/tm/tickets_icon_find.png',
                title: 'Tickets I’m Selling',
              ),
              _DividerLine(),
              _SellListItem(
                iconAsset: 'assets/tm/tickets_icon_voided_ticket.png',
                title: 'Sold Tickets',
              ),
              _DividerLine(),
              _SellListItem(
                iconAsset: 'assets/tm/tickets_icon_voided_tickets.png',
                title: 'Expired Tickets',
              ),
              _DividerLine(),
            ],
          ),
        ),
      ],
    );
  }
}

class _SellHero extends StatelessWidget {
  const _SellHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
      child: Column(
        children: [
          Image.asset(
            TmAssets.sellHero,
            width: 120,
            height: 120,
            fit: BoxFit.contain,
            cacheWidth: 240,
            cacheHeight: 240,
          ),
          const SizedBox(height: 18),
          const Text(
            'SELL TICKETS FROM ANY SITE',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Get access to millions of fans, even if you\ndidn’t buy tickets on Ticketmaster.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: TmColors.brandBlue,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(255, 255, 255, 0.3),
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white54),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: const Text('Learn how it works'),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: TmColors.brandBlue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text('Sell Your Tickets'),
            ),
          ),
        ],
      ),
    );
  }
}

class _SellListItem extends StatelessWidget {
  const _SellListItem({required this.iconAsset, required this.title});

  final String iconAsset;
  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Image.asset(iconAsset, width: 24, height: 24),
          const SizedBox(width: 14),
          Text(title, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

class _DividerLine extends StatelessWidget {
  const _DividerLine();

  @override
  Widget build(BuildContext context) {
    return const Divider(height: 1, thickness: 1, color: Color(0xFFE5E5E5));
  }
}

class EmptyState extends StatefulWidget {
  const EmptyState({
    super.key,
    required this.illustration,
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    this.secondaryButtonLabel,
  });

  final IconData illustration;
  final String title;
  final String subtitle;
  final String buttonLabel;
  final String? secondaryButtonLabel;

  @override
  State<EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<EmptyState> {
  bool _showIllustration = false;
  bool _showText = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    // Staggered entrance: illustration -> text -> buttons.
    Future.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      setState(() => _showIllustration = true);
    });
    Future.delayed(const Duration(milliseconds: 260), () {
      if (!mounted) return;
      setState(() => _showText = true);
    });
    Future.delayed(const Duration(milliseconds: 380), () {
      if (!mounted) return;
      setState(() => _showButton = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: const Color(0xFFF2F2F2),
      alignment: Alignment.center,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          AnimatedOpacity(
            opacity: _showIllustration ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 280),
            curve: TmCurves.easeOut,
            child: AnimatedScale(
              scale: _showIllustration ? 1.0 : 0.95,
              duration: const Duration(milliseconds: 280),
              curve: TmCurves.easeOut,
              child: CircleAvatar(
                radius: 64,
                backgroundColor: Colors.white,
                child: Icon(
                  widget.illustration,
                  size: 64,
                  color: TmColors.brandBlue,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _showText ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 260),
            curve: TmCurves.easeOut,
            child: AnimatedSlide(
              offset: _showText ? Offset.zero : const Offset(0, 0.06),
              duration: const Duration(milliseconds: 260),
              curve: TmCurves.easeOut,
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Text(
                      widget.subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          AnimatedOpacity(
            opacity: _showButton ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 240),
            curve: TmCurves.easeOut,
            child: AnimatedSlide(
              offset: _showButton ? Offset.zero : const Offset(0, 0.08),
              duration: const Duration(milliseconds: 240),
              curve: TmCurves.easeOut,
              child: Column(
                children: [
                  if (widget.secondaryButtonLabel != null)
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.black87,
                        side: const BorderSide(color: Colors.black54),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 12,
                        ),
                      ),
                      child: Text(widget.secondaryButtonLabel!),
                    ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TmColors.brandBlue,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 48,
                        vertical: 14,
                      ),
                    ),
                    child: Text(widget.buttonLabel),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class AnimatedCard extends StatefulWidget {
  const AnimatedCard({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  State<AnimatedCard> createState() => _AnimatedCardState();
}

class _AnimatedCardState extends State<AnimatedCard> {
  bool _visible = false;
  Timer? _revealTimer;

  @override
  void initState() {
    super.initState();
    // Implicit list appearance to keep scrolling smooth at 60fps.
    _revealTimer = Timer(widget.delay, () {
      if (!mounted) return;
      setState(() => _visible = true);
    });
  }

  @override
  void dispose() {
    _revealTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _visible ? 1.0 : 0.0,
      duration: TmDurations.listAppear,
      curve: TmCurves.easeOut,
      child: AnimatedSlide(
        offset: _visible ? Offset.zero : const Offset(0, 0.06),
        duration: TmDurations.listAppear,
        curve: TmCurves.easeOut,
        child: Material(
          elevation: 2,
          clipBehavior: Clip.antiAlias,
          borderRadius: BorderRadius.circular(8),
          child: widget.child,
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TmColors.headerBlack,
      padding: const EdgeInsets.only(top: 12, left: 16, right: 16, bottom: 10),
      alignment: Alignment.centerLeft,
      child: Text(title, style: TmTypography.header),
    );
  }
}

class _TicketsHeader extends StatelessWidget {
  const _TicketsHeader({
    required this.upcomingCount,
    this.onUpcomingDoubleTap,
    this.onPastDoubleTap,
  });

  final int upcomingCount;
  final VoidCallback? onUpcomingDoubleTap;
  final VoidCallback? onPastDoubleTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: TmColors.ticketHeader,
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
            child: Row(
              children: [
                const SizedBox(width: 48),
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'My Tickets',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 19,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 31,
                        height: 31,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white38, width: 1.3),
                        ),
                        padding: const EdgeInsets.all(2),
                        child: ClipOval(
                          child: Image.asset(
                            TmAssets.flag,
                            fit: BoxFit.cover,
                            cacheWidth: 62,
                            cacheHeight: 62,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  width: 48,
                  child: Text(
                    'Help',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(
            width: double.infinity,
            height: 1,
            child: ColoredBox(color: Color(0xFF303133)),
          ),
          SizedBox(
            height: 48,
            child: Stack(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onDoubleTap: onUpcomingDoubleTap,
                        onLongPress: onUpcomingDoubleTap,
                        child: Center(
                          child: material.Text(
                            'Upcoming ($upcomingCount)',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onDoubleTap: onPastDoubleTap,
                        onLongPress: onPastDoubleTap,
                        child: const Center(
                          child: material.Text(
                            'Past (0)',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const Align(
                  alignment: Alignment.bottomLeft,
                  child: FractionallySizedBox(
                    widthFactor: 0.5,
                    child: SizedBox(
                      height: 2,
                      child: ColoredBox(color: Colors.white),
                    ),
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

class _TicketSearchBar extends StatelessWidget {
  const _TicketSearchBar({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onClose,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8D8D8)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.search, color: Color(0xFF646C76), size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              focusNode: focusNode,
              onChanged: onChanged,
              decoration: const InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'Search tickets by name or keyword',
                hintStyle: TextStyle(color: Color(0xFF9098A3), fontSize: 14),
              ),
              style: const TextStyle(
                color: Color(0xFF171A1F),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          GestureDetector(
            onTap: onClose,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(4),
              child: Icon(Icons.close, color: Color(0xFF646C76), size: 18),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketSearchEmptyState extends StatelessWidget {
  const _TicketSearchEmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.search_off_rounded, size: 54, color: Color(0xFF8C939C)),
            SizedBox(height: 14),
            Text(
              'No matching tickets found',
              style: TextStyle(
                color: Color(0xFF20242A),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Try another ticket name or keyword.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF707780),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _UpcomingTicketCountDialog extends StatefulWidget {
  const _UpcomingTicketCountDialog({
    required this.initialCount,
    this.title = 'Create upcoming tickets',
    this.hintText = 'How many ticket cards?',
    this.confirmLabel = 'Create',
  });

  final int initialCount;
  final String title;
  final String hintText;
  final String confirmLabel;

  @override
  State<_UpcomingTicketCountDialog> createState() =>
      _UpcomingTicketCountDialogState();
}

class _UpcomingTicketCountDialogState
    extends State<_UpcomingTicketCountDialog> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: '${widget.initialCount}');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final count = int.tryParse(_controller.text.trim());
    if (count == null || count < 1) {
      return;
    }
    Navigator.of(context).pop(count);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: material.Text(widget.title),
      content: TextField(
        controller: _controller,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        autofocus: true,
        decoration: InputDecoration(
          hintText: widget.hintText,
          border: OutlineInputBorder(),
        ),
        onSubmitted: (_) => _submit(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const material.Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _submit,
          child: material.Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

class _BrandRow extends StatelessWidget {
  const _BrandRow();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 36,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Image.asset(
              TmAssets.brandLogo,
              height: 16,
              fit: BoxFit.contain,
              cacheHeight: 32,
            ),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white54, width: 1.2),
              ),
              child: ClipOval(
                child: Image.asset(
                  TmAssets.flag,
                  fit: BoxFit.cover,
                  cacheWidth: 48,
                  cacheHeight: 48,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FilterRow extends StatelessWidget {
  const _FilterRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _FilterTile(
            leadingAsset: TmAssets.locationIcon,
            label: 'LOCATION',
            value: 'Los Angeles',
            showClear: true,
          ),
        ),
        SizedBox(width: 8),
        SizedBox(
          height: 36,
          child: VerticalDivider(color: Colors.white24, thickness: 1),
        ),
        SizedBox(width: 8),
        Expanded(
          child: _FilterTile(
            leadingAsset: TmAssets.dateIcon,
            label: 'DATES',
            value: 'All Dates',
            showDropdown: true,
          ),
        ),
      ],
    );
  }
}

class _FilterTile extends StatelessWidget {
  const _FilterTile({
    required this.leadingAsset,
    required this.label,
    required this.value,
    this.showDropdown = false,
    this.showClear = false,
  });

  final String leadingAsset;
  final String label;
  final String value;
  final bool showDropdown;
  final bool showClear;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Image.asset(
          leadingAsset,
          width: 18,
          height: 18,
          color: Colors.white70,
          cacheWidth: 36,
          cacheHeight: 36,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.7,
                ),
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (showDropdown) ...[
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.keyboard_arrow_down,
                      size: 16,
                      color: Colors.white70,
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (showClear)
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              border: Border.all(color: Colors.white38, width: 1),
            ),
            child: const Icon(Icons.close, size: 12, color: Colors.white70),
          ),
      ],
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black12),
        boxShadow: const [
          BoxShadow(
            color: Color.fromRGBO(0, 0, 0, 0.08),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'SEARCH',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: Colors.black54,
                    letterSpacing: 0.6,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Artist, Event or Venue',
                  style: TextStyle(color: TmColors.hintGrey),
                ),
              ],
            ),
          ),
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: TmColors.brandBlue, width: 1.2),
            ),
            child: Image.asset(
              TmAssets.searchIcon,
              width: 16,
              height: 16,
              fit: BoxFit.contain,
              cacheWidth: 48,
              cacheHeight: 48,
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryRow extends StatelessWidget {
  const _CategoryRow();

  @override
  Widget build(BuildContext context) {
    final items = ['Concerts', 'Sports', 'Arts, Theater & Comedy'];
    return Row(
      children: [
        for (int i = 0; i < items.length; i++) ...[
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.black,
                border: Border.all(color: Colors.white24),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                items[i],
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          if (i != items.length - 1) const SizedBox(width: 8),
        ],
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.entry});

  final _DiscoverFeedEntry entry;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 220,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [entry.primaryColor, entry.secondaryColor],
                ),
              ),
            ),
            LayoutBuilder(
              builder: (context, constraints) {
                final dpr = MediaQuery.of(context).devicePixelRatio;
                final cacheWidth = (constraints.maxWidth * dpr).round();
                return Image.asset(
                  entry.imageAsset,
                  fit: BoxFit.cover,
                  cacheWidth: cacheWidth,
                  color: Colors.black.withValues(alpha: 0.14),
                  colorBlendMode: BlendMode.darken,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: entry.primaryColor,
                      child: const Center(
                        child: Text(
                          'Hero Image',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.68),
                    ],
                  ),
                ),
              ),
            ),
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.16),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(entry.accentIcon, size: 14, color: Colors.white),
                        const SizedBox(width: 6),
                        Text(
                          entry.eyebrow,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    entry.title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    entry.location,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.86),
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: entry.primaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(3),
                      ),
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      entry.ctaLabel,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TalentCard extends StatelessWidget {
  const _TalentCard({required this.entry});

  final _DiscoverFeedEntry entry;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 176,
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [entry.primaryColor, entry.secondaryColor],
                  ),
                ),
              ),
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final dpr = MediaQuery.of(context).devicePixelRatio;
                    final cacheWidth = (constraints.maxWidth * dpr).round();
                    return Image.asset(
                      entry.imageAsset,
                      height: 176,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      cacheWidth: cacheWidth,
                      color: Colors.black.withValues(alpha: 0.12),
                      colorBlendMode: BlendMode.darken,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          height: 176,
                          color: entry.primaryColor,
                          alignment: Alignment.center,
                          child: const Text(
                            'Talent Image',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.34),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(entry.accentIcon, color: Colors.white, size: 18),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.eyebrow,
                style: TextStyle(
                  letterSpacing: 1.1,
                  fontSize: 12,
                  color: entry.primaryColor.withValues(alpha: 0.78),
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                entry.subtitle,
                style: const TextStyle(
                  color: Color(0xFF5A5F66),
                  fontSize: 13,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      entry.dateLabel,
                      style: const TextStyle(
                        color: Color(0xFF5A5F66),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      foregroundColor: entry.primaryColor,
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      entry.ctaLabel,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
