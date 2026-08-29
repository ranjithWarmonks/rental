// Rentapp REST API Reference (v1) Base URL & Endpoints Registry
const String baseUrl = "https://www.renwala.com/api/v1/";

// 1. AUTHENTICATION & REGISTRATION
const String loginApiName = "${baseUrl}auth/login";
const String registerCompanyApiName = "${baseUrl}auth/register-company";
const String logoutApiName = "${baseUrl}auth/logout";
const String logoutAllApiName = "${baseUrl}auth/logout-all";

// 2. USER PROFILE & CONTEXT
const String meApiName = "${baseUrl}me";
const String meLocationContextApiName = "${baseUrl}me/location-context";
const String mePasswordApiName = "${baseUrl}me/password";
const String tenantApiName = "${baseUrl}tenant";

// 3. STAFF / USERS & ROLES
const String rolesApiName = "${baseUrl}roles";
String roleDetailApiName(int id) => "${baseUrl}roles/$id";
const String usersApiName = "${baseUrl}users";
String userDetailApiName(int id) => "${baseUrl}users/$id";

// 4. STORE LOCATIONS
const String locationsApiName = "${baseUrl}locations";
String locationDetailApiName(int id) => "${baseUrl}locations/$id";

// 5. DASHBOARD STATS
const String dashboardSummaryApiName = "${baseUrl}dashboard/summary";

// 6. CUSTOMER MANAGEMENT
const String customersApiName = "${baseUrl}customers";
const String customersQuickApiName = "${baseUrl}customers/quick";
String customerDetailApiName(int id) => "${baseUrl}customers/$id";

// 7. INVENTORY ITEMS
const String itemsApiName = "${baseUrl}items";
const String itemsCreateMetaApiName = "${baseUrl}items/create";
String itemDetailApiName(int id) => "${baseUrl}items/$id";
String itemEditMetaApiName(int id) => "${baseUrl}items/$id/edit";
String itemImageApiName(int id) => "${baseUrl}items/$id/image";
String itemStockHistoryApiName(int id) => "${baseUrl}items/$id/stock-history";
String itemAvailabilityApiName(int id) => "${baseUrl}items/$id/availability";

// 8. STOCK ENTRIES (INWARD)
const String stockEntriesApiName = "${baseUrl}stock-entries";
String stockEntryDetailApiName(int id) => "${baseUrl}stock-entries/$id";

// 9. STOCK ADJUSTMENTS
const String stockAdjustmentsApiName = "${baseUrl}stock-adjustments";
String stockAdjustmentDetailApiName(int id) => "${baseUrl}stock-adjustments/$id";

// 10. RENTALS & RETURNS
const String rentalsApiName = "${baseUrl}rentals";
const String rentalsCreateMetaApiName = "${baseUrl}rentals/create";
const String rentalsDueApiName = "${baseUrl}rentals/due";
String rentalDetailApiName(int id) => "${baseUrl}rentals/$id";
String rentalReturnApiName(int id) => "${baseUrl}rentals/$id/return";
String rentalCancelApiName(int id) => "${baseUrl}rentals/$id/cancel";
String rentalReceiptApiName(int id) => "${baseUrl}rentals/$id/receipt";

// 11. SALES & PAYMENTS
const String salesApiName = "${baseUrl}sales";
const String salesCreateMetaApiName = "${baseUrl}sales/create";
String saleDetailApiName(int id) => "${baseUrl}sales/$id";
String salePaymentsApiName(int id) => "${baseUrl}sales/$id/payments";
String saleReceiptApiName(int id) => "${baseUrl}sales/$id/receipt";
String saleReturnableItemsApiName(int id) => "${baseUrl}sales/$id/returnable-items";

// 12. LEDGER (INCOME & EXPENSE)
const String ledgerApiName = "${baseUrl}ledger";
const String ledgerBulkApiName = "${baseUrl}ledger/bulk";
String ledgerDetailApiName(int id) => "${baseUrl}ledger/$id";
const String ledgerCategoriesApiName = "${baseUrl}ledger-categories";
String ledgerCategoryDetailApiName(int id) => "${baseUrl}ledger-categories/$id";

// 13. SYSTEM METADATA & REPORTS
const String categoriesApiName = "${baseUrl}categories";
String categoryDetailApiName(int id) => "${baseUrl}categories/$id";
const String unitsApiName = "${baseUrl}units";
String unitDetailApiName(int id) => "${baseUrl}units/$id";
const String customFieldsApiName = "${baseUrl}custom-fields";
const String reportsRentalsApiName = "${baseUrl}reports/rentals";
const String reportsReturnsApiName = "${baseUrl}reports/returns";
const String reportsExportApiName = "${baseUrl}reports/export";
const String financialReportApiName = "${baseUrl}financial-report";
const String healthApiName = "${baseUrl}health";
