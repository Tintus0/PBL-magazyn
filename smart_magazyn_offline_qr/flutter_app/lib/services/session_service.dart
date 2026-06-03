import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

class SessionService {
  AppUser? currentUser;

  Future<void> load() async {
    // Sesja jest trzymana tylko pomocniczo; właściwe logowanie i tak idzie po lokalnej bazie.
  }

  Future<void> login(AppUser user) async {
    currentUser = user;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('last_user_id', user.id);
  }

  Future<void> logout() async {
    currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('last_user_id');
  }
}
