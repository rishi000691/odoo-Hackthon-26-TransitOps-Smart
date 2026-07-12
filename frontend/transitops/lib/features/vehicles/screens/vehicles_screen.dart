import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transitops/core/constants/enums.dart';
import 'package:transitops/features/authentication/blocs/auth_bloc.dart';
import 'package:transitops/features/authentication/blocs/auth_state.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_bloc.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_event.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_state.dart';
import 'package:transitops/features/vehicles/models/vehicle_model.dart';
import 'package:transitops/features/expenses/blocs/expense_bloc.dart';
import 'package:transitops/features/expenses/blocs/expense_event.dart';
import 'package:transitops/features/expenses/blocs/expense_state.dart';
import 'package:transitops/core/widgets/app_text_field.dart';
import 'package:transitops/core/widgets/app_dropdown_field.dart';

// Design system tokens matching the shell
const _kBg = Color(0xFF090D16);
const _kSurface = Color(0xFF111827);
const _kTextPrimary = Color(0xFFF8FAFC);
const _kTextSecondary = Color(0xFF94A3B8);
const _kBorder = Color(0xFF1E293B);
const _kAccent = Color(0xFFF59E0B); // Yellow/Orange accent for Vehicles

class VehiclesScreen extends StatefulWidget {
  const VehiclesScreen({super.key});

  @override
  State<VehiclesScreen> createState() => _VehiclesScreenState();
}

class _VehiclesScreenState extends State<VehiclesScreen> {
  String _searchQuery = '';
  String? _selectedTypeFilter;
  String? _selectedStatusFilter;
  Vehicle? _selectedVehicle;

  @override
  void initState() {
    super.initState();
    context.read<VehicleBloc>().add(const FetchVehicles());
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.read<AuthBloc>().state;
    final isManager = userState is Authenticated &&
        userState.user.roles.contains(UserRole.fleetManager);

    return Scaffold(
      backgroundColor: _kBg,
      body: MultiBlocListener(
        listeners: [
          BlocListener<VehicleBloc, VehicleState>(
            listener: (ctx, state) {
              if (state is VehicleOperationSuccess) {
                _showSnackBar(ctx, state.message, Colors.green);
                ctx.read<VehicleBloc>().add(const FetchVehicles());
                setState(() => _selectedVehicle = null);
              } else if (state is VehicleError) {
                _showSnackBar(ctx, state.message, Colors.redAccent);
              }
            },
          ),
          BlocListener<ExpenseBloc, ExpenseState>(
            listener: (ctx, state) {
              if (state is ExpenseOperationSuccess) {
                _showSnackBar(ctx, state.message, Colors.green);
                if (_selectedVehicle != null) {
                  ctx.read<ExpenseBloc>().add(FetchVehicleFuelLogs(_selectedVehicle!.id));
                  ctx.read<ExpenseBloc>().add(FetchVehicleExpenses(_selectedVehicle!.id));
                }
              } else if (state is ExpenseError) {
                _showSnackBar(ctx, state.message, Colors.redAccent);
              }
            },
          ),
        ],
        child: BlocBuilder<VehicleBloc, VehicleState>(
          builder: (ctx, state) {
            List<Vehicle> list = [];
            bool loading = state is VehicleLoading;

            if (state is VehiclesLoaded) {
              list = state.vehicles;
            } else if (state is VehicleDetailLoaded) {
              // Keep showing list by querying again if detail loaded
              list = [];
              final currentBloc = ctx.read<VehicleBloc>();
              if (currentBloc.state is! VehiclesLoaded) {
                currentBloc.add(const FetchVehicles());
              }
            }

            // Apply search & filters
            final filtered = list.where((v) {
              final matchSearch = v.registrationNumber.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  v.model.toLowerCase().contains(_searchQuery.toLowerCase());
              final matchType = _selectedTypeFilter == null || v.type == _selectedTypeFilter;
              final matchStatus = _selectedStatusFilter == null || v.status.value == _selectedStatusFilter;
              return matchSearch && matchType && matchStatus;
            }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth >= 900;
                if (isWeb) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildListPane(filtered, loading, isManager, isWeb),
                      ),
                      const VerticalDivider(width: 1, color: _kBorder),
                      Expanded(
                        flex: 4,
                        child: _buildDetailsPane(_selectedVehicle, isManager, isWeb),
                      ),
                    ],
                  );
                } else {
                  return _buildListPane(filtered, loading, isManager, isWeb);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildListPane(List<Vehicle> list, bool loading, bool isManager, bool isWeb) {
    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  style: GoogleFonts.outfit(color: _kTextPrimary),
                  decoration: InputDecoration(
                    hintText: 'Search registration or model...',
                    hintStyle: GoogleFonts.outfit(color: _kTextSecondary),
                    fillColor: _kSurface,
                    filled: true,
                    prefixIcon: const Icon(Icons.search, color: _kTextSecondary),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: const BorderSide(color: _kBorder),
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
                  label: Text('Add', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  onPressed: () => _showRegisterVehicleDialog(context),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildFilterChip('All Types', null, _selectedTypeFilter, (v) => setState(() => _selectedTypeFilter = null)),
                _buildFilterChip('Trucks', 'Truck', _selectedTypeFilter, (v) => setState(() => _selectedTypeFilter = 'Truck')),
                _buildFilterChip('Vans', 'Van', _selectedTypeFilter, (v) => setState(() => _selectedTypeFilter = 'Van')),
                _buildFilterChip('Sedans', 'Sedan', _selectedTypeFilter, (v) => setState(() => _selectedTypeFilter = 'Sedan')),
                const SizedBox(width: 16),
                const Icon(Icons.lens, size: 4, color: _kTextSecondary),
                const SizedBox(width: 16),
                _buildFilterChip('All Statuses', null, _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = null)),
                _buildFilterChip('Available', 'Available', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'Available')),
                _buildFilterChip('On Trip', 'On Trip', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'On Trip')),
                _buildFilterChip('In Shop', 'In Shop', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'In Shop')),
                _buildFilterChip('Retired', 'Retired', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'Retired')),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: loading && list.isEmpty
                ? const Center(child: CircularProgressIndicator(color: _kAccent))
                : list.isEmpty
                    ? Center(
                        child: Text(
                          'No vehicles found',
                          style: GoogleFonts.outfit(color: _kTextSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, index) {
                          final vehicle = list[index];
                          final isSelected = _selectedVehicle?.id == vehicle.id;
                          return _buildVehicleCard(vehicle, isSelected, isWeb);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, String? value, String? groupValue, ValueChanged<String?> onSelected) {
    final active = value == groupValue;
    return GestureDetector(
      onTap: () => onSelected(value),
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? _kAccent.withValues(alpha: 0.12) : _kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? _kAccent : _kBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: active ? _kAccent : _kTextSecondary,
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildVehicleCard(Vehicle vehicle, bool isSelected, bool isWeb) {
    Color statusColor = Colors.green;
    switch (vehicle.status) {
      case VehicleStatus.available:
        statusColor = const Color(0xFF10B981);
        break;
      case VehicleStatus.onTrip:
        statusColor = const Color(0xFF6366F1);
        break;
      case VehicleStatus.inShop:
        statusColor = const Color(0xFFF97316);
        break;
      case VehicleStatus.retired:
        statusColor = const Color(0xFFF87171);
        break;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? _kAccent.withValues(alpha: 0.05) : _kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isSelected ? _kAccent : _kBorder),
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
          child: const Icon(Icons.directions_car, color: _kAccent, size: 20),
        ),
        title: Text(
          vehicle.registrationNumber,
          style: GoogleFonts.outfit(
            color: _kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          '${vehicle.model} • ${vehicle.type}',
          style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 13),
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
                vehicle.status.value,
                style: GoogleFonts.outfit(
                  color: statusColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right, color: _kTextSecondary),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedVehicle = vehicle;
          });
          // Fetch costs history for this vehicle
          context.read<ExpenseBloc>().add(FetchVehicleFuelLogs(vehicle.id));
          context.read<ExpenseBloc>().add(FetchVehicleExpenses(vehicle.id));

          if (!isWeb) {
            _showMobileDetailsSheet(context, vehicle);
          }
        },
      ),
    );
  }

  Widget _buildDetailsPane(Vehicle? vehicle, bool isManager, bool isWeb) {
    if (vehicle == null) {
      return Container(
        color: _kBg,
        child: Center(
          child: Text(
            'Select a vehicle to inspect details',
            style: GoogleFonts.outfit(color: _kTextSecondary),
          ),
        ),
      );
    }

    return Container(
      color: _kBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        vehicle.registrationNumber,
                        style: GoogleFonts.outfit(
                          color: _kTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${vehicle.model} • ${vehicle.type}',
                        style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (isManager && vehicle.status != VehicleStatus.retired) ...[
                  IconButton(
                    icon: const Icon(Icons.edit, color: _kAccent),
                    tooltip: 'Update status',
                    onPressed: () => _showUpdateStatusDialog(context, vehicle),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_forever, color: Colors.redAccent),
                    tooltip: 'Retire vehicle',
                    onPressed: () => _showRetireConfirmation(context, vehicle),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: _kBorder),
            const SizedBox(height: 16),
            _buildInfoRow('Region', vehicle.region ?? 'Unspecified'),
            _buildInfoRow('Max Load Capacity', '${vehicle.maxLoadCapacity} kg'),
            _buildInfoRow('Current Odometer', '${vehicle.currentOdometer} km'),
            _buildInfoRow('Acquisition Cost', '\$${vehicle.acquisitionCost}'),
            _buildInfoRow('Registered On', vehicle.createdAt.toString().split(' ').first),
            const SizedBox(height: 24),
            const Divider(color: _kBorder),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Operations Logs', style: GoogleFonts.outfit(color: _kTextPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
                if (vehicle.status != VehicleStatus.retired)
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.add_circle_outline, color: _kAccent),
                    color: _kSurface,
                    onSelected: (action) {
                      if (action == 'fuel') {
                        _showLogFuelDialog(context, vehicle);
                      } else {
                        _showLogExpenseDialog(context, vehicle);
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(value: 'fuel', child: Text('Record Fuel Log', style: TextStyle(color: _kTextPrimary))),
                      const PopupMenuItem(value: 'expense', child: Text('Record Expense', style: TextStyle(color: _kTextPrimary))),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 12),
            BlocBuilder<ExpenseBloc, ExpenseState>(
              builder: (ctx, expenseState) {
                if (expenseState is ExpenseLoading) {
                  return const Center(child: CircularProgressIndicator(color: _kAccent));
                }
                
                List<Widget> logWidgets = [];
                
                if (expenseState is FuelLogsLoaded) {
                  logWidgets.add(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Fuel Logs:', style: GoogleFonts.outfit(color: _kAccent, fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        if (expenseState.fuelLogs.isEmpty)
                          Text('No fuel logs', style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 12))
                        else
                          ...expenseState.fuelLogs.map((log) => _buildLogItem(
                                Icons.local_gas_station,
                                '${log.liters} Liters',
                                '\$${log.cost}',
                                log.date.toString().split(' ').first,
                              )),
                      ],
                    ),
                  );
                }
                
                // Add spacer if fuel logs are showing
                if (logWidgets.isNotEmpty) {
                  logWidgets.add(const SizedBox(height: 16));
                }

                if (expenseState is ExpensesLoaded) {
                  logWidgets.add(
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Other Expenses:', style: GoogleFonts.outfit(color: _kAccent, fontWeight: FontWeight.w600, fontSize: 12)),
                        const SizedBox(height: 6),
                        if (expenseState.expenses.isEmpty)
                          Text('No other expenses', style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 12))
                        else
                          ...expenseState.expenses.map((exp) => _buildLogItem(
                                Icons.receipt_long,
                                exp.expenseType.value,
                                '\$${exp.cost}',
                                exp.date.toString().split(' ').first,
                              )),
                      ],
                    ),
                  );
                }

                if (logWidgets.isEmpty) {
                  return Text('Click a vehicle to load its operations logs', style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 13));
                }

                return Column(
                  children: logWidgets,
                );
              },
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
          Text(label, style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 13)),
          Text(value, style: GoogleFonts.outfit(color: _kTextPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildLogItem(IconData icon, String title, String amount, String date) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _kSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: _kBorder),
      ),
      child: Row(
        children: [
          Icon(icon, color: _kTextSecondary, size: 16),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: GoogleFonts.outfit(color: _kTextPrimary, fontSize: 13, fontWeight: FontWeight.w600)),
                Text(date, style: GoogleFonts.outfit(color: _kTextSecondary, fontSize: 11)),
              ],
            ),
          ),
          Text(amount, style: GoogleFonts.outfit(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
        ],
      ),
    );
  }

  void _showMobileDetailsSheet(BuildContext context, Vehicle vehicle) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: _kBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return FractionallySizedBox(
          heightFactor: 0.85,
          child: BlocProvider.value(
            value: context.read<ExpenseBloc>(),
            child: BlocProvider.value(
              value: context.read<VehicleBloc>(),
              child: _buildDetailsPane(vehicle, true, false),
            ),
          ),
        );
      },
    );
  }

  void _showRegisterVehicleDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final regCtrl = TextEditingController();
    final modelCtrl = TextEditingController();
    final capCtrl = TextEditingController();
    final odomCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    String vehicleType = 'Truck';
    String region = 'Texas';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _kSurface,
          title: Text('Register New Vehicle', style: GoogleFonts.outfit(color: _kTextPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'Registration Number',
                    hintText: 'e.g. TX-9988-AB',
                    controller: regCtrl,
                    validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Model',
                    hintText: 'e.g. Freightliner M2',
                    controller: modelCtrl,
                    validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setDialogState) {
                      return AppDropdownField<String>(
                        label: 'Type',
                        value: vehicleType,
                        items: const [
                          DropdownMenuItem(value: 'Truck', child: Text('Truck')),
                          DropdownMenuItem(value: 'Van', child: Text('Van')),
                          DropdownMenuItem(value: 'Sedan', child: Text('Sedan')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => vehicleType = val);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Max Load Capacity (kg)',
                    hintText: 'e.g. 15000',
                    controller: capCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Current Odometer (km)',
                    hintText: 'e.g. 120500',
                    controller: odomCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Acquisition Cost (\$)',
                    hintText: 'e.g. 85000',
                    controller: costCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setDialogState) {
                      return AppDropdownField<String>(
                        label: 'Region',
                        value: region,
                        items: const [
                          DropdownMenuItem(value: 'Texas', child: Text('Texas')),
                          DropdownMenuItem(value: 'California', child: Text('California')),
                          DropdownMenuItem(value: 'Illinois', child: Text('Illinois')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => region = val);
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.outfit(color: _kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<VehicleBloc>().add(AddVehicle(
                        registrationNumber: regCtrl.text,
                        model: modelCtrl.text,
                        type: vehicleType,
                        maxLoadCapacity: double.parse(capCtrl.text),
                        currentOdometer: double.parse(odomCtrl.text),
                        acquisitionCost: double.parse(costCtrl.text),
                      ));
                  Navigator.pop(ctx);
                }
              },
              child: Text('Register', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showUpdateStatusDialog(BuildContext context, Vehicle vehicle) {
    VehicleStatus activeStatus = vehicle.status;
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _kSurface,
          title: Text('Update Vehicle Status', style: GoogleFonts.outfit(color: _kTextPrimary, fontWeight: FontWeight.bold)),
          content: StatefulBuilder(
            builder: (context, setDialogState) {
              return AppDropdownField<VehicleStatus>(
                label: 'Status',
                value: activeStatus,
                items: const [
                  DropdownMenuItem(value: VehicleStatus.available, child: Text('Available')),
                  DropdownMenuItem(value: VehicleStatus.onTrip, child: Text('On Trip')),
                  DropdownMenuItem(value: VehicleStatus.inShop, child: Text('In Shop')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    setDialogState(() => activeStatus = val);
                  }
                },
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.outfit(color: _kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
              onPressed: () {
                context.read<VehicleBloc>().add(UpdateVehicle(
                      id: vehicle.id,
                      fields: {'status': activeStatus.value},
                    ));
                Navigator.pop(ctx);
              },
              child: Text('Save', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showRetireConfirmation(BuildContext context, Vehicle vehicle) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _kSurface,
          title: Text('Retire Vehicle', style: GoogleFonts.outfit(color: _kTextPrimary, fontWeight: FontWeight.bold)),
          content: Text(
            'Are you sure you want to retire GJ-05-AB-1234? This is a soft delete action and will change status to Retired.',
            style: GoogleFonts.outfit(color: _kTextSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text('Cancel', style: GoogleFonts.outfit(color: _kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              onPressed: () {
                context.read<VehicleBloc>().add(DeleteVehicle(vehicle.id));
                Navigator.pop(ctx);
              },
              child: Text('Retire', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showLogFuelDialog(BuildContext context, Vehicle vehicle) {
    final formKey = GlobalKey<FormState>();
    final litersCtrl = TextEditingController();
    final costCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _kSurface,
          title: Text('Record Fuel Log', style: GoogleFonts.outfit(color: _kTextPrimary, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Fuel Liters',
                  hintText: 'e.g. 120',
                  controller: litersCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Cost (\$)',
                  hintText: 'e.g. 180',
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
              child: Text('Cancel', style: GoogleFonts.outfit(color: _kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<ExpenseBloc>().add(RecordFuelLog(
                        vehicleId: vehicle.id,
                        liters: double.parse(litersCtrl.text),
                        cost: double.parse(costCtrl.text),
                      ));
                  Navigator.pop(ctx);
                }
              },
              child: Text('Record', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showLogExpenseDialog(BuildContext context, Vehicle vehicle) {
    final formKey = GlobalKey<FormState>();
    final costCtrl = TextEditingController();
    String expenseType = 'Toll';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: _kSurface,
          title: Text('Record Other Expense', style: GoogleFonts.outfit(color: _kTextPrimary, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                StatefulBuilder(
                  builder: (context, setDialogState) {
                    return AppDropdownField<String>(
                      label: 'Expense Type',
                      value: expenseType,
                      items: const [
                        DropdownMenuItem(value: 'Toll', child: Text('Toll')),
                        DropdownMenuItem(value: 'Maintenance', child: Text('Maintenance')),
                        DropdownMenuItem(value: 'Insurance', child: Text('Insurance')),
                        DropdownMenuItem(value: 'Other', child: Text('Other')),
                      ],
                      onChanged: (val) {
                        if (val != null) {
                          setDialogState(() => expenseType = val);
                        }
                      },
                    );
                  },
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Cost (\$)',
                  hintText: 'e.g. 45',
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
              child: Text('Cancel', style: GoogleFonts.outfit(color: _kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  context.read<ExpenseBloc>().add(RecordOtherExpense(
                        vehicleId: vehicle.id,
                        expenseType: expenseType,
                        cost: double.parse(costCtrl.text),
                      ));
                  Navigator.pop(ctx);
                }
              },
              child: Text('Record', style: GoogleFonts.outfit(color: Colors.white)),
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
