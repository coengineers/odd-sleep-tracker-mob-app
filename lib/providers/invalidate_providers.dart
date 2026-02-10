import 'home_providers.dart';
import 'insights_providers.dart';

/// Invalidate all sleep-data providers so screens refresh after mutations.
void invalidateSleepProviders(dynamic ref) {
  ref.invalidate(todaySummaryProvider);
  ref.invalidate(recentDurationsProvider);
  ref.invalidate(allEntriesProvider);
  ref.invalidate(insightsDataProvider);
}
