// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => 'dispatcherZ';

  @override
  String get language => '언어';

  @override
  String get english => 'English';

  @override
  String get japanese => '日本語';

  @override
  String get newDispatch => '새 전표 작성';

  @override
  String get closeDispatch => '전표 닫기';

  @override
  String get fileMenu => '파일';

  @override
  String get viewMenu => '보기';

  @override
  String get reservationList => '예약 목록';

  @override
  String get dashboardGeneral => '내역·예약 목록 (일반)';

  @override
  String get dashboardAdmin => '내역·예약 목록 (관리자)';

  @override
  String get settingsMenu => '설정';

  @override
  String get modeChangeMenu => '모드 변경';

  @override
  String get lightMode => '라이트 모드';

  @override
  String get darkMode => '다크 모드';

  @override
  String get colorMode => '컬러 모드';

  @override
  String get saveDeleteLayout => '화면 저장/삭제';

  @override
  String get loadSavedLayout => '저장된 화면 불러오기';

  @override
  String get noSavedLayouts => '저장된 화면이 없습니다';

  @override
  String get changeAdminPin => '관리자 PIN 변경';

  @override
  String get helpMenu => '도움말';

  @override
  String get aboutApp => 'dispatcherZ 정보';

  @override
  String get exitApp => '배차 업무 종료';

  @override
  String get customerNumberAuto => '고객 번호 (자동 생성)';

  @override
  String get customerName => '고객명';

  @override
  String get phoneNumberRequired => '전화번호 (필수)';

  @override
  String get phoneHint => '하이픈 없이 입력 후 Enter를 눌러 고객 정보 검색';

  @override
  String get pickupLocation1 => '배차 장소 1';

  @override
  String get pickupLocation2 => '배차 장소 2';

  @override
  String get pickupLocation3 => '배차 장소 3';

  @override
  String get dispatchDateTime => '배차 일시';

  @override
  String get completionDateTime => '배차 완료 일시';

  @override
  String get monthLabel => '월';

  @override
  String get dayLabel => '일';

  @override
  String get hourLabel => '시';

  @override
  String get minuteLabel => '분';

  @override
  String get callArea => '호출 (무선 콜 에어리어)';

  @override
  String get guidance => '안내지 (이동국 유도 안내)';

  @override
  String get destination => '배차지 (이동국 번호)';

  @override
  String get saveComplete => '데이터 저장 / 완료';

  @override
  String get resaveChanges => '변경 사항 다시 저장';

  @override
  String get closeButton => '닫기';

  @override
  String get saveButton => '저장하기';

  @override
  String get savedButton => '저장됨';

  @override
  String get cancelButton => '취소';

  @override
  String get closeDispatchConfirmTitle => '전표를 닫으시겠습니까?';

  @override
  String get closeDispatchConfirmContent => '필요한 경우 저장한 후 닫아주세요.';

  @override
  String get searchMapTooltip => '지도를 검색하여 좌표 저장';

  @override
  String get zoomIn => '지도 확대';

  @override
  String get zoomOut => '지도 축소';

  @override
  String get reservationListTitle => '예약 목록 (미배차)';

  @override
  String get noWaitingReservations => '대기 중인 예약이 없습니다';

  @override
  String get dashboardTitleGeneral => '내역·예약 통합 관리 대시보드';

  @override
  String get dashboardTitleAdmin => '내역·예약 통합 관리 대시보드 (관리자)';

  @override
  String get allFilters => '전체';

  @override
  String get reservedOnlyFilter => '예약 배차만';

  @override
  String get completedOnlyFilter => '배차 완료만';

  @override
  String get cancelFilter => '취소';

  @override
  String get searchHint => '전화번호, 이름으로 검색...';

  @override
  String get noDateLimit => '기간 지정 없음 (전체)';

  @override
  String get periodPrefix => '기간:';

  @override
  String get colCustomerNo => '고객 번호';

  @override
  String get colDispatchId => '전표 ID';

  @override
  String get colDispatchDate => '배차 일시';

  @override
  String get colCompletionDate => '배차 완료 일시';

  @override
  String get colStatus => '상태';

  @override
  String get colDestination => '이동국';

  @override
  String get statusReserved => '예약 배차';

  @override
  String get statusCompleted => '배차 완료';

  @override
  String get statusCanceled => '취소';

  @override
  String get statusUnknown => '알 수 없음';

  @override
  String get tooltipImportCsv => 'CSV 파일에서 데이터 일괄 가져오기';

  @override
  String get tooltipExportCsv => '표시 중인 데이터를 CSV로 내보내기 (관리자 전용)';

  @override
  String get tooltipRefresh => 'MySQL에서 최신 데이터 가져오기';

  @override
  String get tooltipCloseTab => '이 대시보드 탭 닫기';

  @override
  String get colPhone => '전화번호';

  @override
  String get exitConfirmTitle => '오늘도 수고하셨습니다';

  @override
  String get exitConfirmContent => '배차 업무를 종료하고 창을 닫으시겠습니까?';

  @override
  String get exitButton => '종료하기';

  @override
  String get aboutTitle => 'dispatcherZ 정보';

  @override
  String get aboutAuthor => '제작자: 토시다 모리히로';

  @override
  String get aboutSource => '소스 코드:';

  @override
  String get aboutLicense => '본 소프트웨어는 GPL 3.0 라이선스를 따릅니다.';

  @override
  String get pinChangeTitle => '관리자 PIN 코드 변경';

  @override
  String get pinChangeInstruction => '현재 PIN 코드와 새 PIN 코드를 입력해 주세요.';

  @override
  String get currentPin => '현재 PIN 코드';

  @override
  String get newPin => '새 PIN 코드';

  @override
  String get confirmNewPin => '새 PIN 코드 (확인용)';

  @override
  String get pinMismatch => '새 PIN 코드가 일치하지 않습니다.';

  @override
  String get fillAllFields => '모든 항목을 입력해 주세요.';

  @override
  String get pinChangeSuccess => '관리자 PIN 코드를 변경했습니다.';

  @override
  String get pinChangeFailed => '현재 PIN 코드가 올바르지 않습니다.';

  @override
  String get commError => '통신 오류가 발생했습니다.';

  @override
  String get saveChangesButton => '변경 사항 저장';

  @override
  String get tabNewDispatch => '  새 전표 (미입력)  ';

  @override
  String get tabDashboardGeneral => '  내역·예약 목록 (일반)  ';

  @override
  String get tabDashboardAdmin => '  내역·예약 목록 (관리자)  ';

  @override
  String get layoutDialogTitle => '화면 저장/삭제';

  @override
  String get layoutDialogContent =>
      '배차 담당자 이름이나 교대 근무명(\'야마다용\', \'야간\' 등)을 입력해 주세요.';

  @override
  String get layoutNameLabel => '레이아웃 이름';

  @override
  String get deleteLayoutBtn => '화면 삭제';

  @override
  String get saveLayoutBtn => '화면 저장';

  @override
  String layoutDeletedMsg(String name) {
    return '레이아웃 \'$name\'을(를) 삭제했습니다.';
  }

  @override
  String layoutSavedMsg(String name) {
    return '레이아웃을 \'$name\'(으)로 저장했습니다.';
  }

  @override
  String get tooltipTabList => '열려 있는 탭 목록 표시';

  @override
  String get tooltipSearchCustomer => '전화번호로 고객 검색';

  @override
  String get errorPhoneRequired => '전화번호는 필수 항목입니다. 숫자를 입력해 주세요.';

  @override
  String layoutLoadedMsg(String profile) {
    return '레이아웃 \'$profile\'을(를) 불러왔습니다.';
  }

  @override
  String snackIncomingCall(String phone) {
    return '📞 수신 전화가 있습니다! 전화번호: $phone';
  }

  @override
  String get snackCustomerFound => '과거 기록에서 고객 정보를 불러왔습니다.';

  @override
  String get snackCustomerNotFound => '신규 고객입니다. 해당 전화번호의 기록이 없습니다.';

  @override
  String snackAdminAuthError(String statusCode, String body) {
    return '오류 $statusCode: $body';
  }

  @override
  String get dialogAdminAuthTitle => '🔐 관리자 인증';

  @override
  String get dialogAdminAuthContent => '관리자용 대시보드를 엽니다.\n관리자 PIN 코드를 입력해 주세요.';

  @override
  String get authButton => '인증';

  @override
  String snackStatusChanged(String id, String status) {
    return '전표 #$id의 상태를 \'$status\'(으)로 변경했습니다.';
  }

  @override
  String get snackStatusChangeFailed => '상태 변경에 실패했습니다.';

  @override
  String dialogStatusChangeTitle(String id) {
    return '상태 변경: #$id';
  }

  @override
  String dialogStatusChangeContent(String name) {
    return '전표($name 님)의 새로운 상태를 선택해 주세요.';
  }

  @override
  String get backButton => '뒤로';

  @override
  String get revertReservationBtn => '예약 배차로 되돌리기';

  @override
  String snackCsvExportSuccess(String path) {
    return 'CSV를 내보냈습니다:\n$path';
  }

  @override
  String snackCsvExportFailed(String error) {
    return 'CSV 내보내기에 실패했습니다: $error';
  }

  @override
  String get snackCsvImportSuccess => 'CSV 데이터 가져오기에 성공했습니다!';

  @override
  String get snackCsvImportFailed => '가져오기에 실패했습니다. 파일 형식을 확인해 주세요.';

  @override
  String snackErrorOccurred(String error) {
    return '오류가 발생했습니다: $error';
  }

  @override
  String get snackDataRefreshed => 'MySQL에서 데이터를 최신으로 업데이트했습니다.';

  @override
  String snackDateRangeLimit(String limit) {
    return '⚠️ 데이터베이스 보호를 위해 한 번에 검색할 수 있는 기간은 최대 $limit까지로 제한됩니다.';
  }

  @override
  String get limitOneYear => '1년';

  @override
  String get limitThreeMonths => '3개월';

  @override
  String tabIncomingCall(String phone) {
    return '  📞수신: $phone  ';
  }

  @override
  String tabEditingCustomer(String name) {
    return '  $name (입력 중)  ';
  }

  @override
  String tabSavedDispatch(String title) {
    return '  $title (저장됨)  ';
  }

  @override
  String get adminPinLabel => '관리자 PIN 코드';
}
