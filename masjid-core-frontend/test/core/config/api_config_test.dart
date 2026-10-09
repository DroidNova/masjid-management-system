import 'package:flutter_test/flutter_test.dart';
import 'package:masjid_core_frontend/core/config/api_config.dart';

void main() {
  test('a full address is used as is', () {
    expect(
      ApiConfig.resolveBaseUrl(
        'https://masjid.example/api/v1',
        Uri.parse('http://localhost:8080/#/main/home'),
      ),
      'https://masjid.example/api/v1',
    );
  });

  test("a path means the website's own address", () {
    expect(
      ApiConfig.resolveBaseUrl(
        '/api/v1',
        Uri.parse('http://localhost:8080/#/main/home'),
      ),
      'http://localhost:8080/api/v1',
    );
    expect(
      ApiConfig.resolveBaseUrl(
        '/api/v1',
        Uri.parse('https://celtic.ngrok-free.dev/#/auth'),
      ),
      'https://celtic.ngrok-free.dev/api/v1',
    );
  });
}
