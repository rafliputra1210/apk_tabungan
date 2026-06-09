import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    } else if (newValue.text.compareTo(oldValue.text) != 0) {
      // Hanya biarkan angka
      String cleanText = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
      if (cleanText.isEmpty) return newValue.copyWith(text: '');
      
      final int value = int.parse(cleanText);
      
      final formatter = NumberFormat('#,###', 'id_ID');
      String newText = formatter.format(value);

      return TextEditingValue(
        text: newText,
        selection: TextSelection.collapsed(offset: newText.length),
      );
    }
    return newValue;
  }
}
