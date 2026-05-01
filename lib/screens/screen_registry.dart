import '../theme/tm_tokens.dart';

class ScreenSpec {
  const ScreenSpec({
    required this.name,
    required this.widgetClass,
    required this.sourceFile,
    required this.referenceAssets,
    this.notes = '',
  });

  final String name;
  final String widgetClass;
  final String sourceFile;
  final List<String> referenceAssets;
  final String notes;
}

class ScreenRegistry {
  static const List<ScreenSpec> screens = [
    ScreenSpec(
      name: 'Splash',
      widgetClass: 'TicketmasterSplash',
      sourceFile: 'lib/app/app_core.dart',
      referenceAssets: [TmAssets.splashLogo],
      notes: 'No XML layouts in APK; Flutter splash is animated in Dart.',
    ),
    ScreenSpec(
      name: 'Discover',
      widgetClass: 'DiscoverScreen',
      sourceFile: 'lib/app/home_shell.dart',
      referenceAssets: [
        TmAssets.brandLogo,
        TmAssets.flag,
        TmAssets.locationIcon,
        TmAssets.dateIcon,
        TmAssets.searchIcon,
        TmAssets.discoverHero,
        TmAssets.discoverPerson,
      ],
      notes:
          'Hero and cards are placeholder data; event list would be server-driven.',
    ),
    ScreenSpec(
      name: 'For You',
      widgetClass: 'ForYouScreen',
      sourceFile: 'lib/app/home_shell.dart',
      referenceAssets: [TmAssets.forYouEmpty],
      notes: 'Empty state; favorites content is server-driven.',
    ),
    ScreenSpec(
      name: 'My Tickets',
      widgetClass: 'MyTicketsScreen',
      sourceFile: 'lib/app/home_shell.dart',
      referenceAssets: [TmAssets.flag],
      notes: 'Ticket cards and counts are server-driven.',
    ),
    ScreenSpec(
      name: 'Sell',
      widgetClass: 'SellScreen',
      sourceFile: 'lib/app/home_shell.dart',
      referenceAssets: [TmAssets.sellHero],
      notes: 'Sell carousel and list items are server-driven.',
    ),
    ScreenSpec(
      name: 'Account',
      widgetClass: 'AccountScreen',
      sourceFile: 'lib/app/home_shell.dart',
      referenceAssets: [],
      notes: 'Placeholder screen; account content is server-driven.',
    ),
  ];
}
