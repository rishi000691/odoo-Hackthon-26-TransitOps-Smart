abstract class ReportState {
  const ReportState();
}

class ReportInitial extends ReportState {}

class ReportLoading extends ReportState {}

class ReportLoaded extends ReportState {
  final Map<String, dynamic> kpis;
  final List<Map<String, dynamic>> roiReport;

  const ReportLoaded({required this.kpis, required this.roiReport});
}

class ReportExportSuccess extends ReportState {
  final String csvContent;
  final String reportType;
  const ReportExportSuccess({required this.csvContent, required this.reportType});
}

class ReportError extends ReportState {
  final String message;
  const ReportError(this.message);
}
