import 'package:flutter_test/flutter_test.dart';
import 'package:platform_core_frontend/features/admin/data/models/admin_user_detail_model.dart';
import 'package:platform_core_frontend/features/admin/data/models/admin_user_summary_model.dart';

void main() {
  group('Admin user model mapping', () {
    test('maps fullName in summary payload to name', () {
      final model = AdminUserSummaryModel.fromJson(const {
        'id': '83a1f45e-9e44-4b11-89ed-9a27e77e0c8b',
        'fullName': 'ashim',
        'email': 'aa@aa.aaa',
        'status': 'ACTIVE',
      });

      expect(model.name, 'ashim');
    });

    test('maps fullName in detail payload to name', () {
      final model = AdminUserDetailModel.fromJson(const {
        'id': '415bed25-d835-479c-90b9-ec53e13899ce',
        'fullName': 'Platform Super Admin',
        'email': 'superadmin@example.com',
        'status': 'ACTIVE',
        'roles': ['SUPER_ADMIN'],
        'permissions': ['users.update', 'roles.assign'],
      });

      expect(model.name, 'Platform Super Admin');
    });
  });
}
