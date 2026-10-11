/// Versión de la aplicación con formato `mayor.menor.parche` (por ejemplo `0.9.1`).
///
/// Ignora el número de compilación (`+3`) y las etiquetas (`-beta`): solo
/// importa el orden de los tres números.
class VersionApp implements Comparable<VersionApp> {
  const VersionApp(this.mayor, this.menor, this.parche);

  final int mayor;
  final int menor;
  final int parche;

  static final _formato = RegExp(r'^v?(\d+)\.(\d+)\.(\d+)(?:[-+].*)?$');

  /// Lanza [FormatException] si el texto no tiene el formato esperado.
  factory VersionApp.parse(String texto) {
    final coincidencia = _formato.firstMatch(texto.trim());
    if (coincidencia == null) {
      throw FormatException('Versión no válida', texto);
    }
    return VersionApp(
      int.parse(coincidencia.group(1)!),
      int.parse(coincidencia.group(2)!),
      int.parse(coincidencia.group(3)!),
    );
  }

  /// Igual que [parse], pero devuelve `null` si el texto no es válido.
  static VersionApp? intentar(String? texto) {
    if (texto == null) return null;
    try {
      return VersionApp.parse(texto);
    } on FormatException {
      return null;
    }
  }

  @override
  int compareTo(VersionApp otra) {
    if (mayor != otra.mayor) return mayor.compareTo(otra.mayor);
    if (menor != otra.menor) return menor.compareTo(otra.menor);
    return parche.compareTo(otra.parche);
  }

  bool operator <(VersionApp otra) => compareTo(otra) < 0;
  bool operator <=(VersionApp otra) => compareTo(otra) <= 0;
  bool operator >(VersionApp otra) => compareTo(otra) > 0;

  @override
  bool operator ==(Object otra) => otra is VersionApp && compareTo(otra) == 0;

  @override
  int get hashCode => Object.hash(mayor, menor, parche);

  @override
  String toString() => '$mayor.$menor.$parche';
}
