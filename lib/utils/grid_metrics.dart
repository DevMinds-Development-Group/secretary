/// Ancho de cada tarjeta en una rejilla de [columns] columnas separadas por [gap].
///
/// Nunca devuelve un ancho negativo ni infinito. Parece una precaución de más y no lo es: con la
/// ventana casi cerrada el ancho disponible llega a cero, la resta de los huecos se va a negativo
/// —con dos columnas y 12 de hueco, `(0 - 12) / 2 = -6`— y un `SizedBox` de ancho negativo no
/// desajusta la rejilla: tira la pantalla entera con una cascada de errores de layout.
double gridItemWidth({
  required double available,
  required int columns,
  required double gap,
}) {
  if (columns <= 0) return 0;
  final width = (available - (columns - 1) * gap) / columns;
  // Un ancho infinito rompe igual que uno negativo, así que también se descarta.
  return width.isFinite && width > 0 ? width : 0;
}
