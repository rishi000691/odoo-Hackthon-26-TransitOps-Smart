import 'package:flutter/material.dart';
import 'package:transitops/core/extensions/context_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transitops/core/constants/enums.dart';
import 'package:transitops/features/authentication/blocs/auth_bloc.dart';
import 'package:transitops/features/authentication/blocs/auth_state.dart';
import 'package:transitops/features/trips/blocs/trip_bloc.dart';
import 'package:transitops/features/trips/blocs/trip_event.dart';
import 'package:transitops/features/trips/blocs/trip_state.dart';
import 'package:transitops/features/trips/models/trip_model.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_bloc.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_event.dart';
import 'package:transitops/features/vehicles/blocs/vehicle_state.dart';
import 'package:transitops/features/drivers/blocs/driver_bloc.dart';
import 'package:transitops/features/drivers/blocs/driver_event.dart';
import 'package:transitops/features/drivers/blocs/driver_state.dart';
import 'package:transitops/core/widgets/app_text_field.dart';
import 'package:transitops/core/widgets/app_dropdown_field.dart';

// Design system tokens matching the shell
const _kAccent = Color(0xFF6366F1); // Indigo/Purple accent for Trips

class TripsScreen extends StatefulWidget {
  const TripsScreen({super.key});

  @override
  State<TripsScreen> createState() => _TripsScreenState();
}

class _TripsScreenState extends State<TripsScreen> {
  String _searchQuery = '';
  String? _selectedStatusFilter;
  Trip? _selectedTrip;

  @override
  void initState() {
    super.initState();
    context.read<TripBloc>().add(const FetchTrips());
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.read<AuthBloc>().state;
    final userRole = userState is Authenticated && userState.user.roles.isNotEmpty
        ? userState.user.roles.first
        : UserRole.driver;
    final canManage = userRole == UserRole.fleetManager || userRole == UserRole.driver;

    return Scaffold(
      backgroundColor: context.kBg,
      body: BlocListener<TripBloc, TripState>(
        listener: (ctx, state) {
          if (state is TripOperationSuccess) {
            _showSnackBar(ctx, state.message, Colors.green);
            ctx.read<TripBloc>().add(const FetchTrips());
            setState(() => _selectedTrip = null);
          } else if (state is TripDetailLoaded) {
            _showSnackBar(ctx, 'Trip status updated to ${state.trip.status.value}', Colors.green);
            ctx.read<TripBloc>().add(const FetchTrips());
            setState(() => _selectedTrip = state.trip);
          } else if (state is TripError) {
            _showSnackBar(ctx, state.message, Colors.redAccent);
          }
        },
        child: BlocBuilder<TripBloc, TripState>(
          builder: (ctx, state) {
            List<Trip> list = [];
            bool loading = state is TripLoading;

            if (state is TripsLoaded) {
              list = state.trips;
            }

            // Apply search & filters
            final filtered = list.where((t) {
              final matchSearch = t.source.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  t.destination.toLowerCase().contains(_searchQuery.toLowerCase());
              final matchStatus = _selectedStatusFilter == null || t.status.value == _selectedStatusFilter;
              return matchSearch && matchStatus;
            }).toList();

            return LayoutBuilder(
              builder: (context, constraints) {
                final isWeb = constraints.maxWidth >= 900;
                if (isWeb) {
                  return Row(
                    children: [
                      Expanded(
                        flex: 6,
                        child: _buildListPane(filtered, loading, canManage, isWeb),
                      ),
                      VerticalDivider(width: 1, color: context.kBorder),
                      Expanded(
                        flex: 4,
                        child: _buildDetailsPane(_selectedTrip, canManage, isWeb),
                      ),
                    ],
                  );
                } else {
                  return _buildListPane(filtered, loading, canManage, isWeb);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildListPane(List<Trip> list, bool loading, bool canManage, bool isWeb) {
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
                    hintText: 'Search source or destination...',
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
              if (canManage) ...[
                const SizedBox(width: 12),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _kAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('Schedule', style: GoogleFonts.outfit(fontWeight: FontWeight.w700)),
                  onPressed: () => _showCreateTripDialog(context),
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
                _buildFilterChip('All Trips', null, _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = null)),
                _buildFilterChip('Draft', 'Draft', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'Draft')),
                _buildFilterChip('Dispatched', 'Dispatched', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'Dispatched')),
                _buildFilterChip('Completed', 'Completed', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'Completed')),
                _buildFilterChip('Cancelled', 'Cancelled', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'Cancelled')),
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
                          'No trips scheduled',
                          style: GoogleFonts.outfit(color: context.kTextSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, index) {
                          final trip = list[index];
                          final isSelected = _selectedTrip?.id == trip.id;
                          return _buildTripCard(trip, isSelected, isWeb);
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
          color: active ? _kAccent.withValues(alpha: 0.12) : context.kSurface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: active ? _kAccent : context.kBorder),
        ),
        child: Text(
          label,
          style: GoogleFonts.outfit(
            color: active ? _kAccent : context.kTextSecondary,
            fontSize: 12,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildTripCard(Trip trip, bool isSelected, bool isWeb) {
    Color statusColor = Colors.green;
    switch (trip.status) {
      case TripStatus.draft:
        statusColor = const Color(0xFF94A3B8);
        break;
      case TripStatus.dispatched:
        statusColor = const Color(0xFFF59E0B);
        break;
      case TripStatus.completed:
        statusColor = const Color(0xFF10B981);
        break;
      case TripStatus.cancelled:
        statusColor = const Color(0xFFF87171);
        break;
    }

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
          child: const Icon(Icons.route, color: _kAccent, size: 20),
        ),
        title: Text(
          '${trip.source} ➔ ${trip.destination}',
          style: GoogleFonts.outfit(
            color: context.kTextPrimary,
            fontWeight: FontWeight.w700,
            fontSize: 15,
          ),
        ),
        subtitle: Text(
          'Distance: ${trip.plannedDistance} km • Cargo: ${trip.cargoWeight} kg',
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
                trip.status.value,
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
            _selectedTrip = trip;
          });
          if (!isWeb) {
            _showMobileDetailsSheet(context, trip);
          }
        },
      ),
    );
  }

  Widget _buildDetailsPane(Trip? trip, bool canManage, bool isWeb) {
    if (trip == null) {
      return Container(
        color: context.kBg,
        child: Center(
          child: Text(
            'Select a trip to inspect details',
            style: GoogleFonts.outfit(color: context.kTextSecondary),
          ),
        ),
      );
    }

    return Container(
      color: context.kBg,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Trip Detail',
              style: GoogleFonts.outfit(
                color: context.kTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Status: ${trip.status.value}',
              style: GoogleFonts.outfit(color: context.kTextSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            Divider(color: context.kBorder),
            const SizedBox(height: 16),
            _buildInfoRow('Source', trip.source),
            _buildInfoRow('Destination', trip.destination),
            _buildInfoRow('Cargo Weight', '${trip.cargoWeight} kg'),
            _buildInfoRow('Planned Distance', '${trip.plannedDistance} km'),
            if (trip.actualDistance != null) _buildInfoRow('Actual Distance', '${trip.actualDistance} km'),
            if (trip.fuelConsumed != null) _buildInfoRow('Fuel Consumed', '${trip.fuelConsumed} Liters'),
            _buildInfoRow('Revenue generated', '\$${trip.revenue}'),
            _buildInfoRow('Created On', trip.createdAt.toString().split(' ').first),
            if (trip.completedAt != null) _buildInfoRow('Completed On', trip.completedAt.toString().split(' ').first),
            const SizedBox(height: 24),
            if (canManage) ...[
              if (trip.status == TripStatus.draft) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF59E0B),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.send_rounded),
                  label: Text('DISPATCH TRIP', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  onPressed: () {
                    context.read<TripBloc>().add(DispatchTrip(trip.id));
                  },
                ),
                const SizedBox(height: 10),
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                  onPressed: () {
                    context.read<TripBloc>().add(CancelTrip(trip.id));
                  },
                  child: Text('Cancel Trip', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                ),
              ] else if (trip.status == TripStatus.dispatched) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF10B981),
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: const Icon(Icons.check_circle_outline_rounded),
                  label: Text('COMPLETE TRIP', style: GoogleFonts.outfit(fontWeight: FontWeight.bold)),
                  onPressed: () => _showCompleteTripForm(context, trip),
                ),
              ],
            ],
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
          Text(value, style: GoogleFonts.outfit(color: context.kTextPrimary, fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  void _showMobileDetailsSheet(BuildContext context, Trip trip) {
    final userState = context.read<AuthBloc>().state;
    final userRole = userState is Authenticated && userState.user.roles.isNotEmpty
        ? userState.user.roles.first
        : UserRole.driver;
    final canManage = userRole == UserRole.fleetManager || userRole == UserRole.driver;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.kBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<TripBloc>(),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: _buildDetailsPane(trip, canManage, false),
          ),
        );
      },
    );
  }

  void _showCreateTripDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final srcCtrl = TextEditingController();
    final destCtrl = TextEditingController();
    final weightCtrl = TextEditingController();
    final distCtrl = TextEditingController();
    
    // Fetch available vehicles & drivers
    context.read<VehicleBloc>().add(const FetchVehicles(status: 'Available'));
    context.read<DriverBloc>().add(const FetchDrivers(status: 'Available'));

    String? selectedVehicleId;
    String? selectedDriverId;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.kSurface,
          title: Text('Schedule Trip (Draft)', style: GoogleFonts.outfit(color: context.kTextPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'Source Location',
                    hintText: 'e.g. Houston, TX',
                    controller: srcCtrl,
                    validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Destination Location',
                    hintText: 'e.g. Dallas, TX',
                    controller: destCtrl,
                    validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<VehicleBloc, VehicleState>(
                    builder: (context, vState) {
                      List<DropdownMenuItem<String>> items = [];
                      if (vState is VehiclesLoaded) {
                        items = vState.vehicles
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
                            hintText: 'Select Available Vehicle',
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  BlocBuilder<DriverBloc, DriverState>(
                    builder: (context, dState) {
                      List<DropdownMenuItem<String>> items = [];
                      if (dState is DriversLoaded) {
                        items = dState.drivers
                            .map((d) => DropdownMenuItem(
                                  value: d.id,
                                  child: Text('${d.name} (Score: ${d.safetyScore})', style: const TextStyle(fontSize: 13)),
                                ))
                            .toList();
                      }
                      return StatefulBuilder(
                        builder: (context, setDialogState) {
                          return AppDropdownField<String>(
                            label: 'Select Driver',
                            value: selectedDriverId,
                            items: items,
                            onChanged: (val) {
                              setDialogState(() => selectedDriverId = val);
                            },
                            hintText: 'Select Available Driver',
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Cargo Weight (kg)',
                    hintText: 'e.g. 8000',
                    controller: weightCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Planned Distance (km)',
                    hintText: 'e.g. 240',
                    controller: distCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                // Re-fetch all to clean filters
                context.read<VehicleBloc>().add(const FetchVehicles());
                context.read<DriverBloc>().add(const FetchDrivers());
                Navigator.pop(ctx);
              },
              child: Text('Cancel', style: GoogleFonts.outfit(color: context.kTextSecondary)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: _kAccent),
              onPressed: () {
                if (formKey.currentState!.validate()) {
                  if (selectedVehicleId == null || selectedDriverId == null) {
                    _showSnackBar(context, 'Please select both vehicle and driver', Colors.redAccent);
                    return;
                  }
                  context.read<TripBloc>().add(CreateTrip(
                        source: srcCtrl.text,
                        destination: destCtrl.text,
                        vehicleId: selectedVehicleId!,
                        driverId: selectedDriverId!,
                        cargoWeight: double.parse(weightCtrl.text),
                        plannedDistance: double.parse(distCtrl.text),
                      ));
                  // Clean up dropdown list queries
                  context.read<VehicleBloc>().add(const FetchVehicles());
                  context.read<DriverBloc>().add(const FetchDrivers());
                  Navigator.pop(ctx);
                }
              },
              child: Text('Schedule', style: GoogleFonts.outfit(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  void _showCompleteTripForm(BuildContext context, Trip trip) {
    final formKey = GlobalKey<FormState>();
    final actDistCtrl = TextEditingController(text: trip.plannedDistance.toString());
    final fuelCtrl = TextEditingController();
    final revCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.kSurface,
          title: Text('Complete Trip Report', style: GoogleFonts.outfit(color: context.kTextPrimary, fontWeight: FontWeight.bold)),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AppTextField(
                  label: 'Actual Distance (km)',
                  controller: actDistCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Fuel Consumed (Liters)',
                  hintText: 'e.g. 95.0',
                  controller: fuelCtrl,
                  keyboardType: TextInputType.number,
                  validator: (v) => double.tryParse(v ?? '') == null ? 'Enter valid number' : null,
                ),
                const SizedBox(height: 12),
                AppTextField(
                  label: 'Revenue generated (\$)',
                  hintText: 'e.g. 1500.0',
                  controller: revCtrl,
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
                  context.read<TripBloc>().add(CompleteTrip(
                        id: trip.id,
                        actualDistance: double.parse(actDistCtrl.text),
                        fuelConsumed: double.parse(fuelCtrl.text),
                        revenue: double.parse(revCtrl.text),
                      ));
                  Navigator.pop(ctx);
                }
              },
              child: Text('Complete', style: GoogleFonts.outfit(color: Colors.white)),
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
