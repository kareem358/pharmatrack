import 'package:flutter/material.dart';

class StoreSettings {
  final String storeName;
  final String address;
  final String phoneNumber;
  final String email;
  final String licenseNumber;
  final String gstNumber;

  const StoreSettings({
    required this.storeName,
    required this.address,
    required this.phoneNumber,
    required this.email,
    required this.licenseNumber,
    required this.gstNumber,
  });

  StoreSettings copyWith({
    String? storeName,
    String? address,
    String? phoneNumber,
    String? email,
    String? licenseNumber,
    String? gstNumber,
  }) {
    return StoreSettings(
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      gstNumber: gstNumber ?? this.gstNumber,
    );
  }
}

class SecuritySettings {
  final bool requireStrongPassword;
  final bool forcePasswordChange;
  final bool twoFactorAuth;
  final bool autoBackupDaily;
  final bool cloudBackupEnabled;

  const SecuritySettings({
    this.requireStrongPassword = true,
    this.forcePasswordChange = true,
    this.twoFactorAuth = false,
    this.autoBackupDaily = true,
    this.cloudBackupEnabled = true,
  });

  SecuritySettings copyWith({
    bool? requireStrongPassword,
    bool? forcePasswordChange,
    bool? twoFactorAuth,
    bool? autoBackupDaily,
    bool? cloudBackupEnabled,
  }) {
    return SecuritySettings(
      requireStrongPassword: requireStrongPassword ?? this.requireStrongPassword,
      forcePasswordChange: forcePasswordChange ?? this.forcePasswordChange,
      twoFactorAuth: twoFactorAuth ?? this.twoFactorAuth,
      autoBackupDaily: autoBackupDaily ?? this.autoBackupDaily,
      cloudBackupEnabled: cloudBackupEnabled ?? this.cloudBackupEnabled,
    );
  }
}

class StockSettings {
  final int minStockLevel;
  final int expiryAlertDays;
  final bool autoReorder;
  final bool lowStockAlerts;

  const StockSettings({
    this.minStockLevel = 10,
    this.expiryAlertDays = 30,
    this.autoReorder = false,
    this.lowStockAlerts = true,
  });

  StockSettings copyWith({
    int? minStockLevel,
    int? expiryAlertDays,
    bool? autoReorder,
    bool? lowStockAlerts,
  }) {
    return StockSettings(
      minStockLevel: minStockLevel ?? this.minStockLevel,
      expiryAlertDays: expiryAlertDays ?? this.expiryAlertDays,
      autoReorder: autoReorder ?? this.autoReorder,
      lowStockAlerts: lowStockAlerts ?? this.lowStockAlerts,
    );
  }
}

class BillingSettings {
  final double taxRate;
  final String currency;
  final String invoicePrefix;
  final bool cashEnabled;
  final bool cardEnabled;
  final bool upiEnabled;
  final bool chequeEnabled;
  final bool autoPrintInvoice;
  final bool emailInvoice;

  const BillingSettings({
    this.taxRate = 18.0,
    this.currency = 'PKR (Rs.)',
    this.invoicePrefix = 'INV',
    this.cashEnabled = true,
    this.cardEnabled = true,
    this.upiEnabled = true,
    this.chequeEnabled = false,
    this.autoPrintInvoice = true,
    this.emailInvoice = false,
  });

  BillingSettings copyWith({
    double? taxRate,
    String? currency,
    String? invoicePrefix,
    bool? cashEnabled,
    bool? cardEnabled,
    bool? upiEnabled,
    bool? chequeEnabled,
    bool? autoPrintInvoice,
    bool? emailInvoice,
  }) {
    return BillingSettings(
      taxRate: taxRate ?? this.taxRate,
      currency: currency ?? this.currency,
      invoicePrefix: invoicePrefix ?? this.invoicePrefix,
      cashEnabled: cashEnabled ?? this.cashEnabled,
      cardEnabled: cardEnabled ?? this.cardEnabled,
      upiEnabled: upiEnabled ?? this.upiEnabled,
      chequeEnabled: chequeEnabled ?? this.chequeEnabled,
      autoPrintInvoice: autoPrintInvoice ?? this.autoPrintInvoice,
      emailInvoice: emailInvoice ?? this.emailInvoice,
    );
  }
}

class NotificationSettings {
  final bool emailNotifications;
  final bool smsNotifications;
  final bool pushNotifications;
  final bool dailySalesReports;
  final bool weeklySummaryReports;

  const NotificationSettings({
    this.emailNotifications = true,
    this.smsNotifications = false,
    this.pushNotifications = true,
    this.dailySalesReports = true,
    this.weeklySummaryReports = false,
  });

  NotificationSettings copyWith({
    bool? emailNotifications,
    bool? smsNotifications,
    bool? pushNotifications,
    bool? dailySalesReports,
    bool? weeklySummaryReports,
  }) {
    return NotificationSettings(
      emailNotifications: emailNotifications ?? this.emailNotifications,
      smsNotifications: smsNotifications ?? this.smsNotifications,
      pushNotifications: pushNotifications ?? this.pushNotifications,
      dailySalesReports: dailySalesReports ?? this.dailySalesReports,
      weeklySummaryReports: weeklySummaryReports ?? this.weeklySummaryReports,
    );
  }
}

enum SettingsTab {
  store,
  users,
  billing,
  stock,
  notifications,
  security;

  String get label {
    switch (this) {
      case SettingsTab.store:
        return 'Store';
      case SettingsTab.users:
        return 'Users';
      case SettingsTab.billing:
        return 'Billing';
      case SettingsTab.stock:
        return 'Stock';
      case SettingsTab.notifications:
        return 'Notifications';
      case SettingsTab.security:
        return 'Security';
    }
  }

  IconData get icon {
    switch (this) {
      case SettingsTab.store:
        return Icons.storefront;
      case SettingsTab.users:
        return Icons.people;
      case SettingsTab.billing:
        return Icons.receipt_long;
      case SettingsTab.stock:
        return Icons.inventory_2;
      case SettingsTab.notifications:
        return Icons.notifications;
      case SettingsTab.security:
        return Icons.security;
    }
  }
}
