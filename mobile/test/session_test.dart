import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mobile/utils/session.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Session', () {
    test('menyimpan dan membaca data akun untuk fallback lokal', () async {
      await Session.saveAuthData(
        token: 'test-token',
        remember: true,
        user: {
          'id': 7,
          'name': 'Guru Demo',
          'role': 'guru',
          'must_change_password': false,
        },
        profile: {
          'id': 12,
          'nama_lengkap': 'Guru Demo',
          'nip': '198001012005011001',
        },
        profileId: 12,
      );

      expect(await Session.getToken(), 'test-token');
      expect(await Session.getRememberedToken(), 'test-token');
      expect(await Session.getRole(), 'guru');
      expect(await Session.getUser(), {
        'id': 7,
        'name': 'Guru Demo',
        'role': 'guru',
        'must_change_password': false,
      });
      expect(await Session.getProfile(), {
        'id': 12,
        'nama_lengkap': 'Guru Demo',
        'nip': '198001012005011001',
      });
    });

    test(
      'menghapus seluruh data sesi tanpa menghapus status onboarding',
      () async {
        await Session.setOnboardingDone();
        await Session.saveAuthData(
          token: 'test-token',
          remember: true,
          user: {'role': 'siswa', 'name': 'Siswa Demo'},
        );

        await Session.clearLogin();

        expect(await Session.getToken(), isNull);
        expect(await Session.getRememberedToken(), isNull);
        expect(await Session.getRole(), isNull);
        expect(await Session.getUser(), isNull);
        expect(await Session.getProfile(), isNull);
        expect(await Session.isOnboardingDone(), isTrue);
      },
    );
  });
}
