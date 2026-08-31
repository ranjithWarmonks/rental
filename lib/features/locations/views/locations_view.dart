import 'package:flutter/material.dart';
import 'package:rental/features/auth/models/auth_models.dart';
import 'package:rental/shared/localization/app_language_controller.dart';
import 'package:rental/shared/services/location_service.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_text.dart';
import 'package:rental/shared/widgets/app_text_field.dart';

class LocationsView extends StatefulWidget {
  const LocationsView({super.key});

  @override
  State<LocationsView> createState() => _LocationsViewState();
}

class _LocationsViewState extends State<LocationsView> {
  final LocationService _locationService = LocationService();
  List<StoreLocationModel> _locations = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLocations();
  }

  Future<void> _fetchLocations() async {
    setState(() => _isLoading = true);
    try {
      final list = await _locationService.getLocations();
      if (mounted) {
        setState(() {
          _locations = list;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _openAddLocationModal() {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController();
    final codeController = TextEditingController();
    final addressController = TextEditingController();
    bool isActive = true;
    bool isDefault = false;
    bool isSaving = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Container(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: buttonColor1.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.storefront_rounded, color: buttonColor1, size: 22),
                          ),
                          const SizedBox(width: 12),
                          const AppText.h2('Add New Location', fontSize: 18),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Name Field
                      AppTextField(
                        label: 'Location Name',
                        hintText: 'e.g. Warehouse North, Main Store',
                        controller: nameController,
                        isRequired: true,
                        prefixIcon: Icons.business_outlined,
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Location name is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Code Field
                      AppTextField(
                        label: 'Location Code',
                        hintText: 'e.g. WH_NORTH, MAIN01',
                        controller: codeController,
                        isOptional: true,
                        prefixIcon: Icons.qr_code_outlined,
                      ),
                      const SizedBox(height: 14),

                      // Address Field
                      AppTextField(
                        label: 'Address / Details',
                        hintText: 'e.g. 456 North Ave, Chicago',
                        controller: addressController,
                        isOptional: true,
                        prefixIcon: Icons.location_on_outlined,
                      ),
                      const SizedBox(height: 14),

                      // Switches
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText('Active Status', fontWeight: FontWeight.bold, fontSize: 14),
                                    AppText.caption('Enable location for rentals and stock', fontSize: 12),
                                  ],
                                ),
                                Switch(
                                  value: isActive,
                                  activeTrackColor: buttonColor1,
                                  activeThumbColor: Colors.white,
                                  onChanged: (val) => setModalState(() => isActive = val),
                                ),
                              ],
                            ),
                            const Divider(height: 1),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    AppText('Default Location', fontWeight: FontWeight.bold, fontSize: 14),
                                    AppText.caption('Pre-select as primary store', fontSize: 12),
                                  ],
                                ),
                                Switch(
                                  value: isDefault,
                                  activeTrackColor: buttonColor1,
                                  activeThumbColor: Colors.white,
                                  onChanged: (val) => setModalState(() => isDefault = val),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Action Buttons
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: isSaving ? null : () => Navigator.pop(ctx),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              ),
                              child: const Text('Cancel', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, color: primaryColor)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: isSaving
                                  ? null
                                  : () async {
                                      if (formKey.currentState?.validate() ?? false) {
                                        setModalState(() => isSaving = true);
                                        final messenger = ScaffoldMessenger.of(context);
                                        final navigator = Navigator.of(ctx);
                                        try {
                                          await _locationService.createLocation(
                                            name: nameController.text.trim(),
                                            code: codeController.text.trim(),
                                            address: addressController.text.trim(),
                                            isActive: isActive,
                                            isDefault: isDefault,
                                          );
                                          navigator.pop();
                                          messenger.showSnackBar(
                                            const SnackBar(
                                              content: Text('Store location created successfully!'),
                                              backgroundColor: buttonColor1,
                                            ),
                                          );
                                          _fetchLocations();
                                        } catch (e) {
                                          setModalState(() => isSaving = false);
                                          messenger.showSnackBar(
                                            SnackBar(
                                              content: Text(e.toString().replaceAll('Exception: ', '')),
                                              backgroundColor: Colors.redAccent,
                                            ),
                                          );
                                        }
                                      }
                                    },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: buttonColor1,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                elevation: 0,
                              ),
                              child: isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                                    )
                                  : const Text('CREATE LOCATION', style: TextStyle(fontFamily: 'Urbanist', fontWeight: FontWeight.bold, color: Colors.white)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final lang = AppLanguageController();

    return Scaffold(
      backgroundColor: scaffoldColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: AppText.h2(lang.text('store_locations'), fontSize: 18),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: primaryColor),
            onPressed: _fetchLocations,
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: buttonColor1))
            : _locations.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 16),
                        const AppText.h3('No Locations Found', color: Colors.grey),
                        const SizedBox(height: 8),
                        const AppText.caption('Tap + Add Location to create your first store location.'),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.all(20),
                    itemCount: _locations.length,
                    separatorBuilder: (ctx, idx) => const SizedBox(height: 12),
                    itemBuilder: (ctx, idx) {
                      final loc = _locations[idx];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: loc.isDefault ? buttonColor1.withValues(alpha: 0.3) : Colors.grey.shade200,
                            width: loc.isDefault ? 1.5 : 1,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.02),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: loc.isDefault ? buttonColor1.withValues(alpha: 0.1) : Colors.grey.shade100,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                Icons.storefront_rounded,
                                color: loc.isDefault ? buttonColor1 : Colors.grey.shade700,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: AppText(
                                          loc.name,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      if (loc.code != null && loc.code!.isNotEmpty)
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: Colors.grey.shade100,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Text(
                                            loc.code!,
                                            style: TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey.shade700,
                                              fontFamily: 'Urbanist',
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (loc.address != null && loc.address!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      loc.address!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                        fontFamily: 'Urbanist',
                                      ),
                                    ),
                                  ],
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: loc.isActive ? Colors.green.shade50 : Colors.red.shade50,
                                          borderRadius: BorderRadius.circular(6),
                                        ),
                                        child: Text(
                                          loc.isActive ? 'ACTIVE' : 'INACTIVE',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                            color: loc.isActive ? Colors.green.shade700 : Colors.red.shade700,
                                            fontFamily: 'Urbanist',
                                          ),
                                        ),
                                      ),
                                      if (loc.isDefault) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                          decoration: BoxDecoration(
                                            color: buttonColor1.withValues(alpha: 0.1),
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: const Text(
                                            'DEFAULT STORE',
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.bold,
                                              color: buttonColor1,
                                              fontFamily: 'Urbanist',
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddLocationModal,
        backgroundColor: buttonColor1,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text(
          'Add Location',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontFamily: 'Urbanist'),
        ),
      ),
    );
  }
}
