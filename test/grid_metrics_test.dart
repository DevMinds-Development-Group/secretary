import 'package:Koinos/utils/grid_metrics.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ancho de las tarjetas de una rejilla', () {
    test('reparte el ancho disponible descontando los huecos', () {
      expect(gridItemWidth(available: 512, columns: 2, gap: 12), 250);
      expect(gridItemWidth(available: 324, columns: 3, gap: 12), 100);
    });

    test('con la ventana casi cerrada no devuelve negativo', () {
      // Este es el caso que tiraba la pantalla: (0 - 12) / 2 = -6.
      expect(gridItemWidth(available: 0, columns: 2, gap: 12), 0);
      expect(gridItemWidth(available: 10, columns: 5, gap: 12), 0);
    });

    test('sin ancho acotado tampoco devuelve infinito', () {
      expect(gridItemWidth(available: double.infinity, columns: 2, gap: 12), 0);
    });

    test('sin columnas no divide por cero', () {
      expect(gridItemWidth(available: 500, columns: 0, gap: 12), 0);
    });
  });
}
