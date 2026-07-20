import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/settings.dart';

/// Modern Notifier for managing the current active tab in settings
class SettingsTabNotifier extends Notifier<SettingsTab> {
  @override
  SettingsTab build() => SettingsTab.store;

  void setTab(SettingsTab tab) => state = tab;
}

final currentSettingsTabProvider = NotifierProvider<SettingsTabNotifier, SettingsTab>(SettingsTabNotifier.new);

/// Modern Notifier for managing the store's profile and configuration
class StoreSettingsNotifier extends Notifier<StoreSettings> {
  @override
  StoreSettings build() {
    return const StoreSettings(
      storeName: 'PharmaTrack Store',
      address: '123 Medical Street, Healthcare City',
      phoneNumber: '+1 (555) 123-4567',
      email: 'info@pharmatrack.com',
      licenseNumber: 'PH-2024-001',
      gstNumber: 'GST123456789',
    );
  }

  void updateSettings(StoreSettings settings) {
    state = settings;
  }

  void updateStoreName(String name) => state = state.copyWith(storeName: name);
  void updateAddress(String address) => state = state.copyWith(address: address);
  void updatePhoneNumber(String phone) => state = state.copyWith(phoneNumber: phone);
  void updateEmail(String email) => state = state.copyWith(email: email);
  void updateLicenseNumber(String license) => state = state.copyWith(licenseNumber: license);
  void updateGstNumber(String gst) => state = state.copyWith(gstNumber: gst);
}

final storeSettingsProvider = NotifierProvider<StoreSettingsNotifier, StoreSettings>(StoreSettingsNotifier.new);

/// Notifier for Security & Backup settings
class SecuritySettingsNotifier extends Notifier<SecuritySettings> {
  @override
  SecuritySettings build() {
    return const SecuritySettings();
  }

  void updateRequireStrongPassword(bool value) => state = state.copyWith(requireStrongPassword: value);
  void updateForcePasswordChange(bool value) => state = state.copyWith(forcePasswordChange: value);
  void updateTwoFactorAuth(bool value) => state = state.copyWith(twoFactorAuth: value);
  void updateAutoBackupDaily(bool value) => state = state.copyWith(autoBackupDaily: value);
  void updateCloudBackupEnabled(bool value) => state = state.copyWith(cloudBackupEnabled: value);
}

final securitySettingsProvider = NotifierProvider<SecuritySettingsNotifier, SecuritySettings>(SecuritySettingsNotifier.new);

/// Notifier for Stock Management settings
class StockSettingsNotifier extends Notifier<StockSettings> {
  @override
  StockSettings build() {
    return const StockSettings();
  }

  void updateMinStockLevel(int value) => state = state.copyWith(minStockLevel: value);
  void updateExpiryAlertDays(int value) => state = state.copyWith(expiryAlertDays: value);
  void updateAutoReorder(bool value) => state = state.copyWith(autoReorder: value);
  void updateLowStockAlerts(bool value) => state = state.copyWith(lowStockAlerts: value);
}

final stockSettingsProvider = NotifierProvider<StockSettingsNotifier, StockSettings>(StockSettingsNotifier.new);

/// Notifier for Billing Configuration settings
class BillingSettingsNotifier extends Notifier<BillingSettings> {
  @override
  BillingSettings build() {
    return const BillingSettings();
  }

  void updateTaxRate(double value) => state = state.copyWith(taxRate: value);
  void updateCurrency(String value) => state = state.copyWith(currency: value);
  void updateInvoicePrefix(String value) => state = state.copyWith(invoicePrefix: value);
  void updateCashEnabled(bool value) => state = state.copyWith(cashEnabled: value);
  void updateCardEnabled(bool value) => state = state.copyWith(cardEnabled: value);
  void updateUpiEnabled(bool value) => state = state.copyWith(upiEnabled: value);
  void updateChequeEnabled(bool value) => state = state.copyWith(chequeEnabled: value);
  void updateAutoPrintInvoice(bool value) => state = state.copyWith(autoPrintInvoice: value);
  void updateEmailInvoice(bool value) => state = state.copyWith(emailInvoice: value);
}

final billingSettingsProvider = NotifierProvider<BillingSettingsNotifier, BillingSettings>(BillingSettingsNotifier.new);

/// Notifier for Notification Preferences settings
class NotificationSettingsNotifier extends Notifier<NotificationSettings> {
  @override
  NotificationSettings build() {
    return const NotificationSettings();
  }

  void updateEmailNotifications(bool value) => state = state.copyWith(emailNotifications: value);
  void updateSmsNotifications(bool value) => state = state.copyWith(smsNotifications: value);
  void updatePushNotifications(bool value) => state = state.copyWith(pushNotifications: value);
  void updateDailySalesReports(bool value) => state = state.copyWith(dailySalesReports: value);
  void updateWeeklySummaryReports(bool value) => state = state.copyWith(weeklySummaryReports: value);
}

final notificationSettingsProvider = NotifierProvider<NotificationSettingsNotifier, NotificationSettings>(NotificationSettingsNotifier.new);
