import '../models/usuario.dart';

// Usuario que inició sesión (se guarda en memoria).
class Sesion {
  static Usuario? usuario;
  static bool get haySesion => usuario != null;

  static int get userId => usuario!.id;
  static bool get esAdmin => usuario?.rol == 'admin';
  static bool get esStaff => usuario?.rol == 'admin' || usuario?.rol == 'seller';

  static void limpiar() {
    usuario = null;
  }
}
