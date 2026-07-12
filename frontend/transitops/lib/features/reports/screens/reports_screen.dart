import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:transitops/core/constants/enums.dart';
import 'package:transitops/features/authentication/blocs/auth_bloc.dart';
import 'package:transitops/features/authentication/blocs/auth_state.dart';
import 'package:transitops/features/reports/blocs/report_bloc.dart';
import 'package:transitops/features/reports/blocs/report_event.dart';
import 'package:transitops/features/reports/blocs/report_state.dart';
import 'package:transitops/core/widgets/app_dropdown_field.dart';

// Design system tokens matching the shell
const _kBg = Color(0xFF090D16);
const _kSurface = Color(0xFF111827);
const _kSurfaceRaised = Color(0xFF1E293B);
const _kTextPrimary = Color(0xFFF8FAFC);
const _kTextSecondary = Color(0xFF94A3B8);
const _kBorder = Color(0xFF1E293B);
const _kAccent = Color(0xFFA855F7); // Purple accent   for Reports

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  String _selectedReportType = 'roi';

  @override
  void initState() {
    super.initState();
    context.read<ReportBloc>().add(const FetchReportData());
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.read<AuthBloc>().state;
    final userRole =
        userState is Authenticated && userState.user.roles.isNotEmpty
        ? userState.user.roles.first
        : UserRole.driver;
    final isAuthorized =
        userRole == UserRole.fleetManager ||
        userRole == UserRole.financialAnalyst;

    if (!isAuthorized) {
      return Scaffold(
        backgroundColor: _kBg,
        body: Center(
          child: Text(
            'Access denied. Only Fleet Managers or Financial Analysts are authorized to view reports.',
            style: GoogleFonts.outfit(
              color: Colors.redAccent,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _kBg,
      body: BlocListener<ReportBloc, ReportState>(
        listener: (ctx, state) {
          if (state is ReportExportSuccess) {
            _showExportDialog(ctx, state.reportType, state.csvContent);
          } else if (state is ReportError) {
            _showSnackBar(ctx, state.message, Colors.redAccent);
          }
        },
        child: BlocBuilder<ReportBloc, ReportState>(
          builder: (ctx, state) {
            if (state is ReportLoading) {
              return const Center(
                child: CircularProgressIndicator(color: _kAccent),
              );
            }

            if (state is! ReportLoaded) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Failed to load report data',
                      style: GoogleFonts.outfit(color: _kTextSecondary),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _kAccent,
                      ),
                      onPressed: () =>
                          ctx.read<ReportBloc>().add(const FetchReportData()),
                      child: Text(
                        'Retry',
                        style: GoogleFonts.outfit(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              );
            }

            final kpis = state.kpis;
            final roiList = state.roiReport;

            // Calculate costs for expenses breakdown chart
            double totalFuelCost = 0;
            double totalMaintCost = 0;
            for (final roi in roiList) {
              totalFuelCost += (roi['fuel_cost'] as num? ?? 0).toDouble();
              totalMaintCost += (roi['maintenance_cost'] as num? ?? 0)
                  .toDouble();
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Dashboard KPIs',
                    style: GoogleFonts.outfit(
                      color: _kTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildKpiGrid(kpis),
                  const SizedBox(height: 28),
                  LayoutBuilder(
                    builder: (ctx, c) {
                      final isWeb = c.maxWidth >= 750;
                      if (isWeb) {
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(flex: 3, child: _buildExportCard()),
                            const SizedBox(width: 16),
                            Expanded(
                              flex: 3,
                              child: _buildExpensesBreakdown(
                                totalFuelCost,
                                totalMaintCost,
                              ),
                            ),
                          ],
                        );
                      } else {
                        return Column(
                          children: [
                            _buildExportCard(),
                            const SizedBox(height: 16),
                            _buildExpensesBreakdown(
                              totalFuelCost,
                              totalMaintCost,
                            ),
                          ],
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Vehicle ROI Report',
                    style: GoogleFonts.outfit(
                      color: _kTextPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildRoiTable(roiList),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildKpiGrid(Map<String, dynamic> kpis) {
    final activeVeh = kpis['active_vehicles'] ?? 0;
    final availVeh = kpis['available_vehicles'] ?? 0;
    final shopVeh = kpis['vehicles_in_maintenance'] ?? 0;
    final activeTrips = kpis['active_trips'] ?? 0;
    final driversOnDuty = kpis['drivers_on_duty'] ?? 0;
    final utilPct = (kpis['fleet_utilization_pct'] as num? ?? 0).toDouble();

    final statItems = [
      _StatItem(
        'Active Vehicles',
        '$activeVeh',
        Icons.directions_car,
        const Color(0xFF10B981),
      ),
      _StatItem(
        'Available Vehicles',
        '$availVeh',
        Icons.check_circle_outline,
        const Color(0xFF6366F1),
      ),
      _StatItem('In Shop', '$shopVeh', Icons.build, const Color(0xFFF97316)),
      _StatItem(
        'Active Trips',
        '$activeTrips',
        Icons.navigation,
        const Color(0xFF3B82F6),
      ),
      _StatItem(
        'Drivers On Duty',
        '$driversOnDuty',
        Icons.person,
        const Color(0xFFA855F7),
      ),
      _StatItem(
        'Utilization Rate',
        '${utilPct.toStringAsFixed(1)}%',
        Icons.trending_up,
        const Color(0xFFEF4444),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: statItems.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemBuilder: (ctx, i) {
        final item = statItems[i];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _kSurface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kBorder),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Icon(item.icon, color: item.color, size: 20),
                  Text(
                    'Metric',
                    style: GoogleFonts.outfit(
                      color: _kTextSecondary,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                item.value,
                style: GoogleFonts.outfit(
                  color: _kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                item.label,
                style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 11),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildExportCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Spreadsheet Exporter',
            style: GoogleFonts.outfit(
              color: _kTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Download fleet logs directly as .CSV files',
            style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 12),
          ),
          const SizedBox(height: 20),
          AppDropdownField<String>(
            label: 'Report Category',
            value: _selectedReportType,
            items: const [
              DropdownMenuItem(value: 'roi', child: Text('Vehicle ROI Report')),
              DropdownMenuItem(
                value: 'utilization',
                child: Text('Utilization Report'),
              ),
              DropdownMenuItem(
                value: 'efficiency',
                child: Text('Fuel Efficiency'),
              ),
              DropdownMenuItem(value: 'cost', child: Text('Operational Costs')),
            ],
            onChanged: (val) {
              if (val != null) {
                setState(() => _selectedReportType = val);
              }
            },
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _kAccent,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            icon: const Icon(Icons.download, size: 18),
            label: Text(
              'EXPORT SPREADSHEET (.CSV)',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
            onPressed: () {
              context.read<ReportBloc>().add(
                ExportCsvReport(_selectedReportType),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildExpensesBreakdown(double fuel, double maintenance) {
    final total = fuel + maintenance;
    final fuelPct = total == 0 ? 0.0 : (fuel / total) * 100;
    final maintPct = total == 0 ? 0.0 : (maintenance / total) * 100;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Expenses Breakdown',
            style: GoogleFonts.outfit(
              color: _kTextPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Fuel vs Maintenance Costs comparison',
            style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 12),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 30,
                sections: [
                  PieChartSectionData(
                    color: const Color(0xFFF97316),
                    value: fuelPct == 0 ? 50 : fuelPct,
                    title: '${fuelPct.toStringAsFixed(0)}%',
                    radius: 35,
                    titleStyle: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  PieChartSectionData(
                    color: const Color(0xFFF59E0B),
                    value: maintPct == 0 ? 50 : maintPct,
                    title: '${maintPct.toStringAsFixed(0)}%',
                    radius: 35,
                    titleStyle: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem(
                'Fuel Cost (\$${fuel.toStringAsFixed(0)})',
                const Color(0xFFF97316),
              ),
              const SizedBox(width: 20),
              _buildLegendItem(
                'Maintenance (\$${maintenance.toStringAsFixed(0)})',
                const Color(0xFFF59E0B),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildRoiTable(List<Map<String, dynamic>> roiList) {
    return Container(
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _kBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(_kSurfaceRaised),
            dataRowColor: WidgetStateProperty.all(_kSurface),
            columns: [
              DataColumn(
                label: Text(
                  'Registration',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Acquisition Cost',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Revenue',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Maintenance Cost',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Fuel Cost',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              DataColumn(
                label: Text(
                  'Net ROI (%)',
                  style: GoogleFonts.outfit(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
            rows: roiList.map((roi) {
              final registration = roi['registration_number'] ?? 'N/A';
              final cost = roi['acquisition_cost'] ?? 0;
              final rev = roi['revenue'] ?? 0;
              final maint = roi['maintenance_cost'] ?? 0;
              final fuel = roi['fuel_cost'] ?? 0;
              final roiPct = roi['roi'] ?? 0;

              return DataRow(
                cells: [
                  DataCell(
                    Text(
                      registration,
                      style: GoogleFonts.outfit(
                        color: _kTextPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '\$$cost',
                      style: GoogleFonts.outfit(color: _kTextSecondary),
                    ),
                  ),
                  DataCell(
                    Text(
                      '\$$rev',
                      style: GoogleFonts.outfit(
                        color: Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  DataCell(
                    Text(
                      '\$$maint',
                      style: GoogleFonts.outfit(color: _kTextSecondary),
                    ),
                  ),
                  DataCell(
                    Text(
                      '\$$fuel',
                      style: GoogleFonts.outfit(color: _kTextSecondary),
                    ),
                  ),
                  DataCell(
                    Text(
                      '$roiPct%',
                      style: GoogleFonts.outfit(
                        color: _kAccent,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showExportDialog(BuildContext context, String type, String content) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _kSurface,
          title: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green),
              const SizedBox(width: 10),
              Text(
                'CSV Report Exported',
                style: GoogleFonts.outfit(
                  color: _kTextPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Successfully compiled spreadsheet for category: ${type.toUpperCase()}',
                style: GoogleFonts.outfit(
                  color: _kTextPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                height: 180,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _kBg,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    content.isEmpty ? '(Empty spreadsheet dataset)' : content,
                    style: const TextStyle(
                      fontFamily: 'Courier',
                      fontSize: 11,
                      color: _kTextSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Close', style: GoogleFonts.outfit(color: _kAccent)),
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.outfit(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

class _StatItem {
  final String label, value;
  final IconData icon;
  final Color color;
  const _StatItem(this.label, this.value, this.icon, this.color);
}
