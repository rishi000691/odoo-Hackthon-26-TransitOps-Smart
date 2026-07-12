import 'package:flutter/material.dart';
import 'package:transitops/core/extensions/context_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transitops/core/constants/enums.dart';
import 'package:transitops/features/authentication/blocs/auth_bloc.dart';
import 'package:transitops/features/authentication/blocs/auth_state.dart';
import 'package:transitops/features/maintenance/blocs/maintenance_bloc.dart';
import 'package:transitops/features/maintenance/blocs/maintenance_event.dart';
import 'package:transitops/features/maintenance/blocs/maintenance_state.dart';
import 'package:transitops/features/maintenance/models/maintenance_log_model.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_bloc.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_event.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_state.dart';
import 'package:transitops/core/widgets/app_text_field.dart';
import 'package:transitops/core/widgets/app_dropdown_field.dart';

// Design system tokens matching the shell
const _kAccent = Color(0xFFF97316); // Orange accent for Maintenance

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _searchQuery = '';
  MaintenanceLog? _selectedLog;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<MaintenanceBloc>().add(const FetchMaintenanceLogs());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.read<AuthBloc>().state;
    final isManager = userState is Authenticated &&
        userState.user.roles.contains(UserRole.fleetManager);

    return Scaffold(
      backgroundColor: context.kBg,
      body: BlocListener<MaintenanceBloc, MaintenanceState>(
        listener: (ctx, state) {
          if (state is MaintenanceOperationSuccess) {
            _showSnackBar(ctx, state.message, Colors.green);
            ctx.read<MaintenanceBloc>().add(const FetchMaintenanceLogs());
            setState(() => _selectedLog = null);
          } else if (state is MaintenanceDetailLoaded) {
            _showSnackBar(ctx, 'Maintenance log closed successfully', Colors.green);
            ctx.read<MaintenanceBloc>().add(const FetchMaintenanceLogs());
            setState(() => _selectedLog = state.log);
          } else if (state is MaintenanceError) {
            _showSnackBar(ctx, state.message, Colors.redAccent);
          }
        },
        child: BlocBuilder<MaintenanceBloc, MaintenanceState>(
          builder: (ctx, state) {
            List<MaintenanceLog> list = [];
            bool loading = state is MaintenanceLoading;

            if (state is MaintenanceLogsLoaded) {
              list = state.logs;
            }

            // Apply search filter
            final filtered = list.where((log) {
              final matchSearch = log.description.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  log.vehicleId.toLowerCase().contains(_searchQuery.toLowerCase());
              return matchSearch;
            }).toList();

            final activeLogs = filtered.where((l) => l.status == MaintenanceStatus.active).toList();
            final closedLogs = filtered.where((l) => l.status == MaintenanceStatus.closed).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth >= 900;
                if (isWeb) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildListPane(activeLogs, closedLogs, loading, isManager, isWeb),
                      ),
                      VerticalDivider(width: 1, color: context.kBorder),
                      Expanded(
                        flex: 4,
                        child: _buildDetailsPane(_selectedLog, isManager, isWeb),
                      ),
                    ],
                  );
                } else {
                  return _buildListPane(activeLogs, closedLogs, loading, isManager, isWeb);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildListPane(
    List<MaintenanceLog> activeList,
    List<MaintenanceLog> closedList,
    bool loading,
    bool isManager,
    bool isWeb,
  ) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: GoogleFonts.outfit(color: context.kTextPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search description...',
                    hintStyle: GoogleFonts.outfit(color: context.kTextSecondary),
                    fillColor: context.kSurface,
                    filled: true,
                    prefixIcon: Icon(Icons.search, color: context.kTextSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: context.kBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kAccent),
                    ),
                  ),
                  onChanged: (v) => setState(() => _searchQuery = v),
                ),
              ),
              if (isManager) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Log', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  onPressed: () => _showLogMaintenanceDialog(context),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          TabBar(
            controller: _tabController,
            indicatorColor: _kAccent,
            labelColor: _kAccent,
            unselectedLabelColor: context.kTextSecondary,
            tabs: const [
              Tab(text: 'Active'),
              Tab(text: 'Closed'),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: loading && activeList.isEmpty && closedList.isEmpty
                ? const Center(child: CircularProgressIndicator(color: _kAccent))
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLogListView(activeList, isWeb),
                      _buildLogListView(closedList, isWeb),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogListView(List<MaintenanceLog> logs, bool isWeb) {
    if (logs.isEmpty) {
      return Center(
        child: Text(
          'No maintenance logs found',
          style: GoogleFonts.outfit(color: context.kTextSecondary),
        ),
      );
    }

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (ctx, index) {
        final log = logs[index];
        final isSelected = _selectedLog?.id == log.id;
        return _buildLogCard(log, isSelected, isWeb);
      },
    );
  }

  Widget _buildLogCard(MaintenanceLog log, bool isSelected, bool isWeb) {
    final isActive = log.status == MaintenanceStatus.active;
    final statusColor = isActive ? const Color(0xFFF97316) : const Color(0xFF10B981);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? _kAccent.withValues(alpha: 0.05) : context.kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? _kAccent : context.kBorder),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: _kAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(Icons.build_circle, color: _kAccent, size: 20),
        ),
        title: Text(
          log.description,
          style: GoogleFonts.outfit(
            color: context.kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(
          'Vehicle ID: ${log.vehicleId.substring(0, 8)}... • Cost: \$${log.cost}',
          style: GoogleFonts.outfit(color: context.kTextSecondary, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                log.status.value,
                style: GoogleFonts.outfit(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: context.kTextSecondary),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedLog = log;
          });
          if (!isWeb) {
            _showMobileDetailsSheet(context, log);
          }
        },
      ),
    );
  }

  Widget _buildDetailsPane(MaintenanceLog? log, bool isManager, bool isWeb) {
    if (log == null) {
      return Container(
        color: context.kBg,
        child: Center(
          child: Text(
            'Select a log to inspect details',
            style: GoogleFonts.outfit(color: context.kTextSecondary),
          ),
        ),
      );
    }

    final isActive = log.status == MaintenanceStatus.active;
    final statusColor = isActive ? const Color(0xFFF97316) : const Color(0xFF10B981);

    return Container(
      color: context.kBg,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Maintenance Detail',
              style: GoogleFonts.outfit(
                color: context.kTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${log.status.value}',
              style: GoogleFonts.outfit(color: statusColor, fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            Divider(color: context.kBorder),
            const SizedBox(height: 16),
            _buildInfoRow('Vehicle UUID', log.vehicleId),
            _buildInfoRow('Description', log.description),
            _buildInfoRow('Cost reported', '\$${log.cost}'),
            _buildInfoRow('Started Date', log.startDate.toString().split(' ').first),
            if (log.endDate != null) _buildInfoRow('Finished Date', log.endDate.toString().split(' ').first),
            const SizedBox(height: 24),
            if (isManager && isActive)
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF10B981),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check_circle_outline_rounded),
                label: Text('CLOSE MAINTENANCE LOG', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                onPressed: () => _showCloseLogDialog(context, log),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: context.kTextSecondary, fontSize: 13)),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: GoogleFonts.outfit(color: context.kTextPrimary, fontWeight: FontWeight.w600, fontSize: 13),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileDetailsSheet(BuildContext context, MaintenanceLog log) {
    final userState = context.read<AuthBloc>().state;
    final isManager = userState is Authenticated &&
        userState.user.roles.contains(UserRole.fleetManager);

    showModalBottomSheet(
      context: context,
      backgroundColor: context.kBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<MaintenanceBloc>(),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildDetailsPane(log, isManager, false),
          ),
        );
      },
    );
  }

  void _showLogMaintenanceDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final descCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    
    // Fetch all vehicles to pick
    context.read<VehicleBloc>().add(const FetchVehicles());
    String? selectedVehicleId;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.kSurface,
          title: Text('Log Maintenance Log', style: GoogleFonts.outfit(color: context.kTextPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  BlocBuilder<VehicleBloc, VehicleState>(
                    builder: (context, vState) {
                      List<DropdownMenuItem<String>> items = [];
                      if (vState is VehiclesLoaded) {
                        items = vState.vehicles
                            .where((v) => v.status != VehicleStatus.retired)
                            .map((v) => DropdownMenuItem(
                                  value: v.id,
                                  child: Text('${v.registrationNumber} (${v.model})', style: const TextStyle(fontSize: 13)),
                                ))
                            .toList();
                      }
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AppDropdownField<String>(
                            label: 'Select Vehicle',
                            value: selectedVehicleId,
                            items: items,
                            onChanged: (val) {
                              setDialogState(() => selectedVehicleId = val);
                            },
                            hintText: 'Select Vehicle',
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Description',
                    hintText: 'e.g. Brake pad replacement',
                    controller: descCtrl,
                    validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Estimated Cost (\$)',
                    hintText: 'e.g. 450.0',
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.outfit(color: context.kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (selectedVehicleId == null) {
                    _showSnackBar(context, 'Please select a vehicle', Colors.redAccent);
                    return;
                  }
                  context.read<MaintenanceBloc>().add(CreateMaintenanceLog(
                        vehicleId: selectedVehicleId!,
                        description: descCtrl.text,
                        cost: double.parse(costCtrl.text),
                      ));
                  Navigator.pop(ctx);
                }
              },
              child: Text('Log', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCloseLogDialog(BuildContext context, MaintenanceLog log) {
    final formKey = GlobalKey<FormState>();
    final costCtrl = TextEditingController(text: log.cost.toString());

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.kSurface,
          title: Text('Close Maintenance Log', style: GoogleFonts.outfit(color: context.kTextPrimary, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Final Cost (\$)',
                  controller: costCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.outfit(color: context.kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF10B981)),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<MaintenanceBloc>().add(CloseMaintenanceLog(
                        id: log.id,
                        cost: double.parse(costCtrl.text),
                      ));
                  Navigator.pop(ctx);
                }
              },
              child: Text('Close Log', style: GoogleFonts.outfit(color: Colors.white)),
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
