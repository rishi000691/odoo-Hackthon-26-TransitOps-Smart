import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:transitops/features/reports/repositories/report_repository.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final ReportRepository reportRepository;

  ReportBloc({required this.reportRepository}) : super(ReportInitial()) {
    on<FetchReportData>(_onFetchReportData);
    on<ExportCsvReport>(_onExportCsvReport);
  }

  Future<void> _onFetchReportData(
    FetchReportData event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    try {
      final kpis = await reportRepository.getDashboardKpis();
      final roi = await reportRepository.getRoiReport();
      emit(ReportLoaded(kpis: kpis, roiReport: roi));
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }

  Future<void> _onExportCsvReport(
    ExportCsvReport event,
    Emitter<ReportState> emit,
  ) async {
    final currentState = state;
    emit(ReportLoading());
    try {
      final csv = await reportRepository.exportReportCsv(event.reportType);
      emit(ReportExportSuccess(csvContent: csv, reportType: event.reportType));
      
      // Restore previous state if it was loaded
      if (currentState is ReportLoaded) {
        emit(currentState);
      }
    } catch (e) {
      emit(ReportError(e.toString()));
      if (currentState is ReportLoaded) {
        emit(currentState);
      }
    }
  }
}
