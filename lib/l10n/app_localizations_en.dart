// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'dispatcherZ';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get japanese => 'Japanese';

  @override
  String get newDispatch => 'Create New Dispatch';

  @override
  String get closeDispatch => 'Close Dispatch';

  @override
  String get fileMenu => 'File';

  @override
  String get viewMenu => 'View';

  @override
  String get reservationList => 'Reservation List';

  @override
  String get dashboardGeneral => 'Dashboard (General)';

  @override
  String get dashboardAdmin => 'Dashboard (Admin)';

  @override
  String get settingsMenu => 'Settings';

  @override
  String get modeChangeMenu => 'Change Mode';

  @override
  String get lightMode => 'Light Mode';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get colorMode => 'Color Mode';

  @override
  String get saveDeleteLayout => 'Save/Delete Layout';

  @override
  String get loadSavedLayout => 'Load Saved Layout';

  @override
  String get noSavedLayouts => 'No saved layouts';

  @override
  String get changeAdminPin => 'Change Admin PIN';

  @override
  String get helpMenu => 'Help';

  @override
  String get aboutApp => 'About dispatcherZ';

  @override
  String get exitApp => 'Exit App';

  @override
  String get customerNumberAuto => 'Customer No. (Auto)';

  @override
  String get customerName => 'Customer Name';

  @override
  String get phoneNumberRequired => 'Phone Number (Required)';

  @override
  String get phoneHint => 'Enter without hyphens, press Enter to search';

  @override
  String get pickupLocation1 => 'Pickup Location 1';

  @override
  String get pickupLocation2 => 'Pickup Location 2';

  @override
  String get pickupLocation3 => 'Pickup Location 3';

  @override
  String get dispatchDateTime => 'Dispatch Date/Time';

  @override
  String get completionDateTime => 'Completion Date/Time';

  @override
  String get monthLabel => 'Month';

  @override
  String get dayLabel => 'Day';

  @override
  String get hourLabel => 'Hour';

  @override
  String get minuteLabel => 'Minute';

  @override
  String get callArea => 'Call Area (Radio)';

  @override
  String get guidance => 'Guidance (For Mobile Unit)';

  @override
  String get destination => 'Destination (Car No.)';

  @override
  String get saveComplete => 'Save / Complete';

  @override
  String get resaveChanges => 'Save Changes';

  @override
  String get closeButton => 'Close';

  @override
  String get saveButton => 'Save';

  @override
  String get savedButton => 'Saved';

  @override
  String get cancelButton => 'Cancel';

  @override
  String get closeDispatchConfirmTitle => 'Close Dispatch?';

  @override
  String get closeDispatchConfirmContent =>
      'Please save before closing if necessary.';

  @override
  String get searchMapTooltip => 'Search map and save coordinates';

  @override
  String get zoomIn => 'Zoom In';

  @override
  String get zoomOut => 'Zoom Out';

  @override
  String get reservationListTitle => 'Reservation List (Pending)';

  @override
  String get noWaitingReservations => 'No pending reservations';

  @override
  String get dashboardTitleGeneral => 'Dispatch History & Dashboard';

  @override
  String get dashboardTitleAdmin => 'Dispatch History & Dashboard (Admin)';

  @override
  String get allFilters => 'All';

  @override
  String get reservedOnlyFilter => 'Reserved Only';

  @override
  String get completedOnlyFilter => 'Completed Only';

  @override
  String get cancelFilter => 'Canceled';

  @override
  String get searchHint => 'Search by phone or name...';

  @override
  String get noDateLimit => 'No date limit (All)';

  @override
  String get periodPrefix => 'Period:';

  @override
  String get colCustomerNo => 'Customer No.';

  @override
  String get colDispatchId => 'Dispatch ID';

  @override
  String get colDispatchDate => 'Dispatch Date';

  @override
  String get colCompletionDate => 'Completion Date';

  @override
  String get colStatus => 'Status';

  @override
  String get colDestination => 'Car No.';

  @override
  String get statusReserved => 'Reserved';

  @override
  String get statusCompleted => 'Completed';

  @override
  String get statusCanceled => 'Canceled';

  @override
  String get statusUnknown => 'Unknown';

  @override
  String get tooltipImportCsv => 'Import data from CSV';

  @override
  String get tooltipExportCsv => 'Export displayed data to CSV (Admin only)';

  @override
  String get tooltipRefresh => 'Refresh data from MySQL';

  @override
  String get tooltipCloseTab => 'Close this dashboard tab';

  @override
  String get colPhone => 'Phone Number';

  @override
  String get exitConfirmTitle => 'Good work today';

  @override
  String get exitConfirmContent =>
      'Do you want to end the dispatch operation and close the window?';

  @override
  String get exitButton => 'Exit';

  @override
  String get aboutTitle => 'About dispatcherZ';

  @override
  String get aboutAuthor => 'Author: Morihiro Toshida';

  @override
  String get aboutSource => 'Source Code:';

  @override
  String get aboutLicense => 'This software is licensed under GPL 3.0.';

  @override
  String get pinChangeTitle => 'Change Admin PIN';

  @override
  String get pinChangeInstruction => 'Enter your current PIN and a new PIN.';

  @override
  String get currentPin => 'Current PIN';

  @override
  String get newPin => 'New PIN';

  @override
  String get confirmNewPin => 'Confirm New PIN';

  @override
  String get pinMismatch => 'New PINs do not match.';

  @override
  String get fillAllFields => 'Please fill in all fields.';

  @override
  String get pinChangeSuccess => 'Admin PIN changed successfully.';

  @override
  String get pinChangeFailed => 'Current PIN is incorrect.';

  @override
  String get commError => 'Communication error occurred.';

  @override
  String get saveChangesButton => 'Save Changes';

  @override
  String get tabNewDispatch => '　New Dispatch (Empty)　';

  @override
  String get tabDashboardGeneral => '　Dashboard (General)　';

  @override
  String get tabDashboardAdmin => '　Dashboard (Admin)　';

  @override
  String get layoutDialogTitle => 'Save/Delete Layout';

  @override
  String get layoutDialogContent =>
      'Enter the dispatcher\'s name or shift name (e.g., \'Yamada\', \'Night Shift\').';

  @override
  String get layoutNameLabel => 'Layout Name';

  @override
  String get deleteLayoutBtn => 'Delete Layout';

  @override
  String get saveLayoutBtn => 'Save Layout';

  @override
  String layoutDeletedMsg(String name) {
    return 'Layout \'$name\' deleted.';
  }

  @override
  String layoutSavedMsg(String name) {
    return 'Layout saved as \'$name\'.';
  }

  @override
  String get tooltipTabList => 'Show list of open tabs';

  @override
  String get tooltipSearchCustomer => 'Search customer by phone number';

  @override
  String get errorPhoneRequired =>
      'Phone number is required. Please enter numbers only.';

  @override
  String layoutLoadedMsg(String profile) {
    return 'Layout \'$profile\' loaded.';
  }

  @override
  String snackIncomingCall(String phone) {
    return '📞 Incoming call! Phone: $phone';
  }

  @override
  String get snackCustomerFound => 'Customer info loaded from history.';

  @override
  String get snackCustomerNotFound => 'New customer. No history found.';

  @override
  String snackAdminAuthError(String statusCode, String body) {
    return 'Error $statusCode: $body';
  }

  @override
  String get dialogAdminAuthTitle => '🔐 Admin Auth';

  @override
  String get dialogAdminAuthContent =>
      'Open the admin dashboard.\nPlease enter the Admin PIN.';

  @override
  String get authButton => 'Authenticate';

  @override
  String snackStatusChanged(String id, String status) {
    return 'Dispatch #$id status changed to \'$status\'.';
  }

  @override
  String get snackStatusChangeFailed => 'Failed to change status.';

  @override
  String dialogStatusChangeTitle(String id) {
    return 'Change Status: #$id';
  }

  @override
  String dialogStatusChangeContent(String name) {
    return 'Select a new status for the dispatch ($name).';
  }

  @override
  String get backButton => 'Back';

  @override
  String get revertReservationBtn => 'Revert to Reserved';

  @override
  String snackCsvExportSuccess(String path) {
    return 'CSV exported to:\n$path';
  }

  @override
  String snackCsvExportFailed(String error) {
    return 'Failed to export CSV: $error';
  }

  @override
  String get snackCsvImportSuccess => 'CSV data imported successfully!';

  @override
  String get snackCsvImportFailed =>
      'Import failed. Please check the file format.';

  @override
  String snackErrorOccurred(String error) {
    return 'An error occurred: $error';
  }

  @override
  String get snackDataRefreshed => 'Data refreshed from MySQL.';

  @override
  String snackDateRangeLimit(String limit) {
    return '⚠️ To protect the database, search period is limited to $limit.';
  }

  @override
  String get limitOneYear => '1 year';

  @override
  String get limitThreeMonths => '3 months';

  @override
  String tabIncomingCall(String phone) {
    return '  📞Call: $phone  ';
  }

  @override
  String tabEditingCustomer(String name) {
    return '  $name (Editing)  ';
  }

  @override
  String tabSavedDispatch(String title) {
    return '  $title (Saved)  ';
  }

  @override
  String get adminPinLabel => 'Admin PIN';

  @override
  String get unnamedCustomer => 'Unnamed';

  @override
  String tabCustomerName(String name) {
    return ' $name ';
  }

  @override
  String listCustomerName(String name) {
    return '$name';
  }
}
