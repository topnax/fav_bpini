import 'package:favbpini/utils/numbers.dart';
import 'package:test/test.dart';

void main() {
  test('Digit parts of the string should be considered as digit by the function', () {
    expect(isDigit("0A1 CDEF", 0), true);
    expect(isDigit("0A1 CDEF", 1), false);
    expect(isDigit("0A1 CDEF", 2), true);
    expect(isDigit("0A1 CDEF", 3), false);
    expect(isDigit("0A1 CDEF", 4), false);
    expect(isDigit("0A1 CDEF", 5), false);
  });
}
