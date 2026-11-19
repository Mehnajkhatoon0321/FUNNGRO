/// Centralized user-facing strings to prevent inline text duplication.
class AppStrings {
  AppStrings._();

  // App General
  static const String appName = 'Funngro Assessment';
  static const String assessmentTitle = 'Funngro Mobile Engineering';
  static const String assessmentSubtitle =
      'Assessment Solutions & Implementation\nby Mobile Engineer Candidate';
  static const String demonstrations = 'Demonstrations';
  static const String optimizedForBudgetDevices =
      'Optimized for ₹8,000 Android Devices';

  // Earnings Screen
  static const String myEarnings = 'My Earnings';
  static const String earningsDetail = 'Earnings Detail';
  static const String noEarningsTitle = 'No earnings yet!';
  static const String noEarningsSubtitle =
      'Complete projects to start earning real money.';
  static const String newPayoutReceived = 'New payout received';
  static const String somethingWentWrong = 'Something went wrong';
  static const String tryAgain = 'Try Again';
  static const String refresh = 'Refresh';

  // Detail Screen
  static const String project = 'Project';
  static const String client = 'Client';
  static const String date = 'Date';
  static const String transactionRef = 'Transaction Ref';

  // Projects Screen
  static const String exploreProjects = 'Explore Projects';
  static const String fetchingProjects = 'Fetching latest projects...';
  static const String loadingMoreProjects = 'Loading more projects...';
  static const String couldNotLoadProjects = 'Could not load projects';
  static const String noProjectsAvailable =
      'No projects available at the moment.';
  static const String retry = 'Retry';
  static const String endOfListMessage = 'No more data available';

  // Navigation Cards
  static const String part1Title = 'Part 1: Rewritten Earnings Screen';
  static const String part1Subtitle =
      'BLoC-driven virtualized list of 1,000+ items with stream updates, error handling, precomputed formatting & OOM protection.';
  static const String part2Title = 'Part 2: Paginated Projects Screen';
  static const String part2Subtitle =
      'BLoC-driven infinite scroll pagination against flaky API (pages 0-7, 20% fail rate), retry logic & non-destructive error handling.';
}
