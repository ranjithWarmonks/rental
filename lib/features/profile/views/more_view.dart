import 'package:flutter/material.dart';
import 'package:rental/presentaion/inventory/inventory_screen.dart';
import 'package:rental/presentaion/login/screen/login_screen.dart';
import 'package:rental/shared/theme/app_color.dart';
import 'package:rental/shared/widgets/app_bottom_nav_bar.dart';
import 'package:rental/shared/widgets/app_dialog.dart';
import 'package:rental/shared/widgets/app_text.dart';
import '../models/user_profile_model.dart';
import '../services/user_profile_service.dart';
import '../../auth/services/auth_service.dart';
import '../../ledger/views/category_head_view.dart';
import '../../categories/views/categories_view.dart';
import '../../units/views/units_view.dart';
import '../../inventory/views/stock_adjustments_view.dart';
import '../../inventory/views/stock_entries_view.dart';
import '../../inventory/views/item_availability_view.dart';
import '../../locations/views/locations_view.dart';
import 'profile_view.dart';
import 'company_profile_view.dart';
import 'staff_management_view.dart';
import 'roles_management_view.dart';
import '../../notifications/views/notifications_view.dart';
import '../../../shared/utils/permission_manager.dart';
import '../../auth/models/auth_models.dart';
import '../../../shared/localization/app_language_controller.dart';

class MoreView extends StatefulWidget {
  const MoreView({super.key});

  @override
  State<MoreView> createState() => _MoreViewState();
}

class _MoreViewState extends State<MoreView> {
  AuthUserModel? _authUser;
  UserProfileModel _user = UserProfileModel(
    name: 'Loading...',
    phone: '',
    email: '',
    role: 'Business Owner',
    companyName: 'PropManager Pro Rentals',
    appVersion: 'v1.0.0',
    buildNumber: '100',
  );

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final authUser = await PermissionManager.getLoggedInUser();
    final cached = await UserProfileService().getCachedProfile();
    if (mounted) {
      setState(() {
        _authUser = authUser;
        _user = cached;
      });
    }
    final latest = await UserProfileService().fetchProfile();
    if (mounted) {
      setState(() {
        _user = latest;
      });
    }
  }

  bool _hasPerm(String perm) {
    if (_authUser == null) return true;
    return _authUser!.hasPermission(perm);
  }

  void _handleLogout(BuildContext context) {
    AppDialog.show(
      context: context,
      title: 'Log Out',
      message: 'Are you sure you want to log out of your account?',
      type: AppDialogType.warning,
      primaryButtonText: 'Yes, Log Out',
      secondaryButtonText: 'Cancel',
      onPrimaryPressed: () async {
        Navigator.pop(context); // Close dialog
        await AuthService().logout();
        if (context.mounted) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const LoginScreen()),
            (route) => false,
          );
        }
      },
    );
  }

  void _openProfileView() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProfileView(userProfile: _user),
      ),
    );
    _loadUserProfile();
  }

  void _showLanguageSelectionModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        final langController = AppLanguageController();
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        langController.text('select_language'),
                        style: const TextStyle(
                          fontFamily: 'Urbanist',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: primaryColor,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Divider(height: 1),
                  const SizedBox(height: 8),
                  ...AppLanguageController.supportedLanguages.map((langOption) {
                    final isSelected = langOption.code == langController.currentLanguageCode;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Material(
                        color: isSelected ? buttonColor1.withValues(alpha: 0.08) : Colors.transparent,
                        borderRadius: BorderRadius.circular(12),
                        child: ListTile(
                          onTap: () {
                            langController.changeLanguage(langOption.code);
                            Navigator.pop(context);
                          },
                          leading: Text(langOption.flag, style: const TextStyle(fontSize: 24)),
                          title: Text(
                            '${langOption.nativeName} (${langOption.name})',
                            style: TextStyle(
                              fontFamily: 'Urbanist',
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                              color: isSelected ? buttonColor1 : primaryColor,
                            ),
                          ),
                          trailing: isSelected
                              ? const Icon(Icons.check_circle_rounded, color: buttonColor1)
                              : null,
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
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
        automaticallyImplyLeading: false,
        backgroundColor: scaffoldColor,
        elevation: 0,
        titleSpacing: 20,
        title: AppText.h1(lang.text('more_options'), fontSize: 24),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Profile Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade200),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: InkWell(
                  onTap: _openProfileView,
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: buttonColor1.withValues(alpha: 0.1),
                        child: const Icon(Icons.person, color: buttonColor1, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText.h3(_user.name, fontSize: 18),
                            const SizedBox(height: 2),
                            AppText.caption(
                              _user.companyName.isNotEmpty
                                  ? '${_user.role} • ${_user.companyName}'
                                  : _user.role,
                              fontSize: 12,
                            ),
                            if (_user.phone.isNotEmpty) ...[
                              const SizedBox(height: 2),
                              AppText.caption(_user.phone, fontSize: 12),
                            ],
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right_rounded, color: primaryColor, size: 22),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              AppText.caption(lang.text('account_settings'), fontWeight: FontWeight.bold, letterSpacing: 0.5),
              const SizedBox(height: 10),

              // Menu Group Container
              Material(
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: Column(
                  children: [
                    _buildTile(
                      icon: Icons.language_rounded,
                      title: lang.text('language'),
                      subtitle: '${lang.currentLanguage.flag} ${lang.currentLanguage.nativeName} (${lang.currentLanguage.name})',
                      onTap: () => _showLanguageSelectionModal(context),
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildTile(
                      icon: Icons.person_outline_rounded,
                      title: lang.text('my_profile'),
                      subtitle: lang.text('my_profile_sub'),
                      onTap: _openProfileView,
                    ),
                    if (_hasPerm('user-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.people_outline_rounded,
                        title: lang.text('staff_users'),
                        subtitle: lang.text('staff_users_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StaffManagementView(),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_hasPerm('role-view') || _hasPerm('user-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.admin_panel_settings_outlined,
                        title: lang.text('roles_permissions'),
                        subtitle: lang.text('roles_permissions_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const RolesManagementView(),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_hasPerm('category_head-view') || _hasPerm('category-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.category_outlined,
                        title: lang.text('category_head'),
                        subtitle: lang.text('category_head_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoryHeadView(),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_hasPerm('category-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.grid_view_rounded,
                        title: lang.text('item_categories'),
                        subtitle: lang.text('item_categories_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CategoriesView(),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_hasPerm('unit-view') || _hasPerm('category-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.straighten_rounded,
                        title: lang.text('units'),
                        subtitle: lang.text('units_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UnitsView(),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_hasPerm('location-view') || _hasPerm('inventory-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.storefront_rounded,
                        title: lang.text('store_locations'),
                        subtitle: lang.text('store_locations_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const LocationsView(),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_hasPerm('stock_adjustment-view') || _hasPerm('inventory-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.tune_rounded,
                        title: lang.text('stock_adjustments'),
                        subtitle: lang.text('stock_adjustments_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StockAdjustmentsView(),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_hasPerm('stock_entry-view') || _hasPerm('inventory-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.move_to_inbox_rounded,
                        title: lang.text('stock_entries'),
                        subtitle: lang.text('stock_entries_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const StockEntriesView(),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_hasPerm('item_availability-view') || _hasPerm('inventory-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.event_available_rounded,
                        title: lang.text('availability_checker'),
                        subtitle: lang.text('availability_checker_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const ItemAvailabilityView(),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_hasPerm('inventory-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.inventory_2_outlined,
                        title: lang.text('inventory_items'),
                        subtitle: lang.text('inventory_items_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const InventoryScreen(),
                            ),
                          );
                        },
                      ),
                    ],
                    if (_hasPerm('company_profile-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.business_outlined,
                        title: lang.text('company_profile'),
                        subtitle: _user.companyName.isNotEmpty ? _user.companyName : lang.text('company_profile_sub'),
                        onTap: () async {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CompanyProfileView(),
                            ),
                          );
                          _loadUserProfile();
                        },
                      ),
                    ],
                    if (_hasPerm('notification-view')) ...[
                      const Divider(height: 1, indent: 50),
                      _buildTile(
                        icon: Icons.notifications_none_rounded,
                        title: lang.text('notifications'),
                        subtitle: lang.text('notifications_sub'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const NotificationsView(),
                            ),
                          );
                        },
                      ),
                    ],
                    const Divider(height: 1, indent: 50),
                    _buildTile(
                      icon: Icons.settings_outlined,
                      title: lang.text('app_settings'),
                      subtitle: lang.text('app_settings_sub'),
                      onTap: () {
                        AppDialog.show(
                          context: context,
                          title: lang.text('app_settings'),
                          message: 'Default Currency: ₹ (INR)',
                        );
                      },
                    ),
                    const Divider(height: 1, indent: 50),
                    _buildTile(
                      icon: Icons.help_outline_rounded,
                      title: lang.text('help_support'),
                      subtitle: lang.text('help_support_sub'),
                      onTap: () {
                        AppDialog.show(
                          context: context,
                          title: lang.text('help_support'),
                          message: 'Email: support@propmanager.com\nPhone: +1 (800) 123-4567',
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Logout Button Container
              Material(
                color: Colors.white,
                clipBehavior: Clip.antiAlias,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.grey.shade200),
                ),
                child: ListTile(
                  onTap: () => _handleLogout(context),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFEE2E2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.logout_rounded, color: Color(0xFFDC2626), size: 20),
                  ),
                  title: Text(
                    lang.text('log_out'),
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Color(0xFFDC2626),
                    ),
                  ),
                  subtitle: Text(
                    lang.text('log_out_sub'),
                    style: const TextStyle(
                      fontFamily: 'Urbanist',
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                  ),
                  trailing: const Icon(Icons.chevron_right_rounded, color: Color(0xFFDC2626), size: 22),
                ),
              ),

              const SizedBox(height: 32),

              // App Version Name Display Footer
              Center(
                child: Column(
                  children: [
                    Icon(Icons.inventory_2_outlined, size: 28, color: Colors.grey.shade400),
                    const SizedBox(height: 6),
                    Text(
                      'PropManager Pro',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Version ${_user.appVersion} (Build ${_user.buildNumber})',
                      style: TextStyle(
                        fontFamily: 'Urbanist',
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNavBar(currentIndex: 4),
    );
  }

  Widget _buildTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        onTap: onTap,
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: primaryColor.withValues(alpha: 0.06),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: primaryColor, size: 20),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Urbanist',
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: primaryColor,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontFamily: 'Urbanist',
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: primaryColor, size: 22),
      ),
    );
  }
}
