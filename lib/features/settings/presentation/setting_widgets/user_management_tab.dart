import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserManagementTab extends ConsumerWidget {
  const UserManagementTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mockUsers = [
      {'name': 'Admin User', 'email': 'admin@gmail.com', 'role': 'Admin', 'status': 'Active', 'lastLogin': '1/21/2024 3:30 PM'},
      {'name': 'John Manager', 'email': 'john@pharmapos.com', 'role': 'Manager', 'status': 'Active', 'lastLogin': '1/20/2024 8:45 PM'},
      {'name': 'Sarah Cashier', 'email': 'sarah@pharmapos.com', 'role': 'Cashier', 'status': 'Active', 'lastLogin': '1/21/2024 2:15 PM'},
      {'name': 'Mike Assistant', 'email': 'mike@pharmapos.com', 'role': 'Cashier', 'status': 'Inactive', 'lastLogin': '1/18/2024 7:20 PM'},
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE5E7EB)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'User Management',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF111827)),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Manage user accounts, roles, and permissions',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: () {},
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Add User'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 32),
          _buildUserTable(users: mockUsers),
        ],
      ),
    );
  }

  Widget _buildUserTable({required List<Map<String, String>> users}) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(flex: 3, child: _tableHeader('Name')),
              Expanded(flex: 4, child: _tableHeader('Email')),
              Expanded(flex: 2, child: _tableHeader('Role')),
              Expanded(flex: 2, child: _tableHeader('Status')),
              Expanded(flex: 3, child: _tableHeader('Last Login')),
              const SizedBox(width: 90, child: Text('Actions', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: Color(0xFF6B7280)))),
            ],
          ),
        ),
        const Divider(height: 1, color: Color(0xFFF3F4F6)),
        ...users.map((user) => _buildUserRow(user)),
      ],
    );
  }

  Widget _tableHeader(String text) {
    return Text(
      text,
      style: const TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600, fontSize: 13),
    );
  }

  Widget _buildUserRow(Map<String, String> user) {
    return Container(
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF3F4F6))),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(user['name']!, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF111827), fontSize: 14)),
          ),
          Expanded(
            flex: 4,
            child: Text(user['email']!, style: const TextStyle(color: Color(0xFF4B5563), fontSize: 14)),
          ),
          Expanded(flex: 2, child: _buildRoleChip(user['role']!)),
          Expanded(flex: 2, child: _buildStatusChip(user['status']!)),
          Expanded(
            flex: 3,
            child: Text(user['lastLogin']!, style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13)),
          ),
          SizedBox(
            width: 90,
            child: Row(
              children: [
                _buildActionIcon(Icons.edit_outlined, () {}),
                const SizedBox(width: 10),
                _buildActionIcon(Icons.delete_outline, () {}, isDelete: true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleChip(String role) {
    Color bg;
    Color text;

    switch (role.toLowerCase()) {
      case 'admin':
        bg = const Color(0xFFFEF2F2);
        text = const Color(0xFFEF4444);
        break;
      case 'manager':
        bg = const Color(0xFFEFF6FF);
        text = const Color(0xFF3B82F6);
        break;
      case 'cashier':
        bg = const Color(0xFFECFDF5);
        text = const Color(0xFF10B981);
        break;
      default:
        bg = const Color(0xFFF3F4F6);
        text = const Color(0xFF4B5563);
    }

    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(6)),
        child: Text(role, style: TextStyle(color: text, fontSize: 12, fontWeight: FontWeight.bold)),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    final isActive = status == 'Active';
    return UnconstrainedBox(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFFECFDF5) : const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(6),
          border: isActive ? null : Border.all(color: const Color(0xFFE5E7EB)),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: isActive ? const Color(0xFF10B981) : const Color(0xFF6B7280),
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildActionIcon(IconData icon, VoidCallback onTap, {bool isDelete = false}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFE5E7EB)),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: isDelete ? Colors.red.shade400 : const Color(0xFF4B5563)),
      ),
    );
  }
}
