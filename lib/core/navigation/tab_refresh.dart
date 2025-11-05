/// Simple interface for pages that want to refresh when their bottom tab
/// becomes selected in the AppShell.
abstract class TabRefresh {
  void onTabSelected();
}
