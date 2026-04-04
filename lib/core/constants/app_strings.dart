/// All user-facing strings in one place for easy localisation later.
class AppStrings {
  AppStrings._();

  // App
  static const String appName = 'SplitMate';
  static const String appTagline = 'Split expenses, not friendships';

  // Groups screen
  static const String groups = 'Groups';
  static const String noGroups = 'No groups yet.\nTap + to create your first group!';
  static const String createGroup = 'Create Group';
  static const String groupName = 'Group Name';
  static const String groupNameHint = 'e.g. Bali Trip, Flatmates…';
  static const String groupDescription = 'Description (optional)';
  static const String deleteGroup = 'Delete Group';
  static const String deleteGroupConfirm = 'Are you sure you want to delete this group? All expenses will be lost.';

  // Members
  static const String members = 'Members';
  static const String addMember = 'Add Member';
  static const String memberName = 'Member Name';
  static const String memberNameHint = 'e.g. Alice';
  static const String noMembers = 'No members yet. Add some!';
  static const String removeMember = 'Remove Member';
  static const String removeMemberConfirm = 'Remove this member from the group?';

  // Expenses
  static const String expenses = 'Expenses';
  static const String addExpense = 'Add Expense';
  static const String expenseTitle = 'Expense Title';
  static const String expenseTitleHint = 'e.g. Dinner at Nobu';
  static const String amount = 'Amount';
  static const String amountHint = '0.00';
  static const String paidBy = 'Paid by';
  static const String splitAmong = 'Split among';
  static const String noExpenses = 'No expenses yet.\nTap + to record one!';
  static const String selectLocation = 'Attach Location (optional)';
  static const String locationAttached = 'Location attached';

  // Summary / Settlement
  static const String summary = 'Summary';
  static const String settlement = 'Settlement';
  static const String noDebts = 'Everyone is settled up!';
  static const String owes = 'owes';
  static const String totalExpenses = 'Total Expenses';
  static const String yourShare = 'Your Share';
  static const String balances = 'Balances';
  static const String suggestedPayments = 'Suggested Payments';

  // Map
  static const String pickLocation = 'Pick a Location';
  static const String confirmLocation = 'Confirm Location';
  static const String tapToSelectLocation = 'Tap on the map to select a location';

  // WebView
  static const String financialTips = 'Financial Tips';

  // Actions
  static const String save = 'Save';
  static const String cancel = 'Cancel';
  static const String delete = 'Delete';
  static const String confirm = 'Confirm';
  static const String add = 'Add';

  // Validation
  static const String fieldRequired = 'This field is required';
  static const String invalidAmount = 'Enter a valid amount greater than 0';
  static const String selectAtLeastOneMember = 'Select at least one participant';
  static const String selectPayer = 'Please select who paid';
  static const String addAtLeastTwoMembers = 'Add at least 2 members to record an expense';
}
