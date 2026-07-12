abstract class ReportEvent {
  const ReportEvent();
}

class FetchReportData extends ReportEvent {
  const FetchReportData();
}

class ExportCsvReport extends ReportEvent {
  final String reportType;
  const ExportCsvReport(this.reportType);
}
