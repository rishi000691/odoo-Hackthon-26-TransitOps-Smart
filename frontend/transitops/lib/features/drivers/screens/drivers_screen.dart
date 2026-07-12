import 'package:flutter/material.dart';
import 'package:transitops/core/extensions/context_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:transitops/core/constants/enums.dart';
import 'package:transitops/features/authentication/blocs/auth_bloc.dart';
import 'package:transitops/features/authentication/blocs/auth_state.dart';
import 'package:transitops/features/drivers/blocs/driver_bloc.dart';
import 'package:transitops/features/drivers/blocs/driver_event.dart';
import 'package:transitops/features/drivers/blocs/driver_state.dart';
import 'package:transitops/features/drivers/models/driver_model.dart';
import 'package:transitops/core/widgets/app_text_field.dart';
import 'package:transitops/core/widgets/app_dropdown_field.dart';

// Design system tokens matching the shell
const _kAccent = Color(0xFF10B981); // Emerald green accent for Drivers

class DriversScreen extends StatefulWidget {
  const DriversScreen({super.key});

  @override
  State<DriversScreen> createState() => _DriversScreenState();
}

class _DriversScreenState extends State<DriversScreen> {
  String _searchQuery = '';
  String? _selectedStatusFilter;
  Driver? _selectedDriver;

  @override
  void initState() {
    super.initState();
    context.read<DriverBloc>().add(const FetchDrivers());
  }

  @override
  Widget build(BuildContext context) {
    final userState = context.read<AuthBloc>().state;
    final userRole = userState is Authenticated && userState.user.roles.isNotEmpty
        ? userState.user.roles.first
        : UserRole.driver;
    final canRegister = userRole == UserRole.fleetManager || userRole == UserRole.safetyOfficer;
    final isSafetyOfficer = userRole == UserRole.safetyOfficer;

    return Scaffold(
      backgroundColor: context.kBg,
      body: BlocListener<DriverBloc, DriverState>(
        listener: (ctx, state) {
          if (state is DriverOperationSuccess) {
            _showSnackBar(ctx, state.message, Colors.green);
            ctx.read<DriverBloc>().add(const FetchDrivers());
            setState(() => _selectedDriver = null);
          } else if (state is DriverError) {
            _showSnackBar(ctx, state.message, Colors.redAccent);
          }
        },
        child: BlocBuilder<DriverBloc, DriverState>(
          builder: (ctx, state) {
            List<Driver> list = [];
            bool loading = state is DriverLoading;

            if (state is DriversLoaded) {
              list = state.drivers;
            } else if (state is DriverDetailLoaded) {
              // Maintain local selection and refresh listing
              list = [];
              final currentBloc = ctx.read<DriverBloc>();
              if (currentBloc.state is! DriversLoaded) {
                currentBloc.add(const FetchDrivers());
              }
            }

            // Apply search & filters
            final filtered = list.where((d) {
              final matchSearch = d.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  d.licenseNumber.toLowerCase().contains(_searchQuery.toLowerCase());
              final matchStatus = _selectedStatusFilter == null || d.status.value == _selectedStatusFilter;
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
                        child: _buildListPane(filtered, loading, canRegister, isSafetyOfficer, isWeb),
                      ),
                      VerticalDivider(width: 1, color: context.kBorder),
                      Expanded(
                        flex: 4,
                        child: _buildDetailsPane(_selectedDriver, isSafetyOfficer, isWeb),
                      ),
                    ],
                  );
                } else {
                  return _buildListPane(filtered, loading, canRegister, isSafetyOfficer, isWeb);
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildListPane(List<Driver> list, bool loading, bool canRegister, bool isSafetyOfficer, bool isWeb) {
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
                    hintText: 'Search driver name or license...',
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
              if (canRegister) ...[
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
                  onPressed: () => _showRegisterDriverDialog(context),
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
                _buildFilterChip('All', null, _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = null)),
                _buildFilterChip('Available', 'Available', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'Available')),
                _buildFilterChip('On Trip', 'On Trip', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'On Trip')),
                _buildFilterChip('Off Duty', 'Off Duty', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'Off Duty')),
                _buildFilterChip('Suspended', 'Suspended', _selectedStatusFilter, (v) => setState(() => _selectedStatusFilter = 'Suspended')),
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
                          'No drivers found',
                          style: GoogleFonts.outfit(color: context.kTextSecondary),
                        ),
                      )
                    : ListView.builder(
                        itemCount: list.length,
                        itemBuilder: (ctx, index) {
                          final driver = list[index];
                          final isSelected = _selectedDriver?.id == driver.id;
                          return _buildDriverCard(driver, isSelected, isWeb);
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

  Widget _buildDriverCard(Driver driver, bool isSelected, bool isWeb) {
    Color statusColor = Colors.green;
    switch (driver.status) {
      case DriverStatus.available:
        statusColor = const Color(0xFF10B981);
        break;
      case DriverStatus.onTrip:
        statusColor = const Color(0xFF6366F1);
        break;
      case DriverStatus.offDuty:
        statusColor = const Color(0xFF94A3B8);
        break;
      case DriverStatus.suspended:
        statusColor = const Color(0xFFF87171);
        break;
    }

    final score = driver.safetyScore;
    Color scoreColor = Colors.green;
    if (score < 80) {
      scoreColor = Colors.redAccent;
    } else if (score < 90) {
      scoreColor = Colors.orangeAccent;
    }

    // Safety check for license expiry
    final now = DateTime.now();
    final difference = driver.licenseExpiryDate.difference(now).inDays;
    final isExpiringSoon = difference <= 14;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? _kAccent.withValues(alpha: 0.05) : context.kSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected
              ? _kAccent
              : (isExpiringSoon ? Colors.redAccent.withValues(alpha: 0.5) : context.kBorder),
        ),
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
          child: const Icon(Icons.person, color: _kAccent, size: 20),
        ),
        title: Row(
          children: [
            Text(
              driver.name,
              style: GoogleFonts.outfit(
                color: context.kTextPrimary,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
            if (isExpiringSoon) ...[
              const SizedBox(width: 6),
              const Icon(Icons.warning, color: Colors.redAccent, size: 14),
            ],
          ],
        ),
        subtitle: Text(
          'License: ${driver.licenseNumber} (${driver.licenseCategory})',
          style: GoogleFonts.outfit(color: context.kTextSecondary, fontSize: 13),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    driver.status.value,
                    style: GoogleFonts.outfit(
                      color: statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Score: ${score.toStringAsFixed(1)}',
                  style: GoogleFonts.outfit(color: scoreColor, fontWeight: FontWeight.bold, fontSize: 11),
                ),
              ],
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right, color: context.kTextSecondary),
          ],
        ),
        onTap: () {
          setState(() {
            _selectedDriver = driver;
          });
          if (!isWeb) {
            _showMobileDetailsSheet(context, driver);
          }
        },
      ),
    );
  }

  Widget _buildDetailsPane(Driver? driver, bool isSafetyOfficer, bool isWeb) {
    if (driver == null) {
      return Container(
        color: context.kBg,
        child: Center(
          child: Text(
            'Select a driver to inspect details',
            style: GoogleFonts.outfit(color: context.kTextSecondary),
          ),
        ),
      );
    }

    final score = driver.safetyScore;
    Color scoreColor = Colors.green;
    if (score < 80) {
      scoreColor = Colors.redAccent;
    } else if (score < 90) {
      scoreColor = Colors.orangeAccent;
    }

    final expiryText = driver.licenseExpiryDate.toString().split(' ').first;
    final now = DateTime.now();
    final daysLeft = driver.licenseExpiryDate.difference(now).inDays;
    final isExpiringSoon = daysLeft <= 14;

    return Container(
      color: context.kBg,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
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
                        driver.name,
                        style: GoogleFonts.outfit(
                          color: context.kTextPrimary,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Status: ${driver.status.value}',
                        style: GoogleFonts.outfit(color: context.kTextSecondary, fontSize: 14),
                      ),
                    ],
                  ),
                ),
                if (isSafetyOfficer && driver.status != DriverStatus.suspended)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                    onPressed: () => _suspendDriver(driver),
                    child: Text('Suspend', style: GoogleFonts.outfit(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(color: context.kBorder),
            const SizedBox(height: 16),
            _buildInfoRow('Contact Number', driver.contactNumber),
            _buildInfoRow('License Number', driver.licenseNumber),
            _buildInfoRow('License Category', driver.licenseCategory),
            _buildInfoRow(
              'License Expiry',
              isExpiringSoon ? '$expiryText ($daysLeft days left!)' : expiryText,
              valueColor: isExpiringSoon ? Colors.redAccent : context.kTextPrimary,
            ),
            _buildInfoRow(
              'Safety Score',
              score.toStringAsFixed(1),
              valueColor: scoreColor,
            ),
            _buildInfoRow('Registered On', driver.createdAt.toString().split(' ').first),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.outfit(color: context.kTextSecondary, fontSize: 13)),
          Text(
            value,
            style: GoogleFonts.outfit(
              color: valueColor ?? context.kTextPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  void _showMobileDetailsSheet(BuildContext context, Driver driver) {
    final userState = context.read<AuthBloc>().state;
    final userRole = userState is Authenticated && userState.user.roles.isNotEmpty
        ? userState.user.roles.first
        : UserRole.driver;
    final isSafetyOfficer = userRole == UserRole.safetyOfficer;

    showModalBottomSheet(
      context: context,
      backgroundColor: context.kBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return BlocProvider.value(
          value: context.read<DriverBloc>(),
          child: Container(
            padding: const EdgeInsets.only(bottom: 24),
            child: _buildDetailsPane(driver, isSafetyOfficer, false),
          ),
        );
      },
    );
  }

  void _showRegisterDriverDialog(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final nameCtrl = TextEditingController();
    final licenseCtrl = TextEditingController();
    final categoryCtrl = TextEditingController(text: 'A');
    final contactCtrl = TextEditingController();
    final scoreCtrl = TextEditingController(text: '100.0');
    DateTime expiryDate = DateTime.now().add(const Duration(days: 365));

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: context.kSurface,
          title: Text('Register New Driver', style: GoogleFonts.outfit(color: context.kTextPrimary, fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppTextField(
                    label: 'Driver Name',
                    hintText: 'e.g. John Doe',
                    controller: nameCtrl,
                    validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'License Number',
                    hintText: 'e.g. DL-12345678',
                    controller: licenseCtrl,
                    validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setDialogState) {
                      return AppDropdownField<String>(
                        label: 'License Category',
                        value: categoryCtrl.text,
                        items: const [
                          DropdownMenuItem(value: 'A', child: Text('Category A')),
                          DropdownMenuItem(value: 'B', child: Text('Category B')),
                          DropdownMenuItem(value: 'C', child: Text('Category C')),
                          DropdownMenuItem(value: 'D', child: Text('Category D')),
                        ],
                        onChanged: (val) {
                          if (val != null) setDialogState(() => categoryCtrl.text = val);
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  StatefulBuilder(
                    builder: (context, setDialogState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'License Expiry Date',
                            style: GoogleFonts.outfit(color: context.kTextPrimary, fontSize: 13, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: context.kSurfaceRaised,
                              foregroundColor: context.kTextPrimary,
                              alignment: Alignment.centerLeft,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            icon: const Icon(Icons.calendar_today, size: 16),
                            label: Text(expiryDate.toString().split(' ').first),
                            onPressed: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: expiryDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime.now().add(const Duration(days: 3650)),
                              );
                              if (picked != null) {
                                setDialogState(() => expiryDate = picked);
                              }
                            },
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Contact Number',
                    hintText: 'e.g. +15550199',
                    controller: contactCtrl,
                    keyboardType: TextInputType.phone,
                    validator: (v) => v == null || v.isEmpty ? 'Field required' : null,
                  ),
                  const SizedBox(height: 12),
                  AppTextField(
                    label: 'Initial Safety Score',
                    controller: scoreCtrl,
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
                  context.read<DriverBloc>().add(AddDriver(
                        name: nameCtrl.text,
                        licenseNumber: licenseCtrl.text,
                        licenseCategory: categoryCtrl.text,
                        licenseExpiryDate: expiryDate,
                        contactNumber: contactCtrl.text,
                        safetyScore: double.parse(scoreCtrl.text),
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

  void _suspendDriver(Driver driver) {
    context.read<DriverBloc>().add(UpdateDriver(
          id: driver.id,
          fields: {'status': 'Suspended'},
        ));
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
