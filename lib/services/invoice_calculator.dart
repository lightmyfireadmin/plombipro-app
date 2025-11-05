import 'package:intl/intl.dart';

class InvoiceCalculator {
  static double calculateLineTotal(double quantity, double unitPrice, int discountPercent) {
    final total = quantity * unitPrice;
    final discount = total * (discountPercent / 100);
    return total - discount;
  }

  static double calculateVAT({required double subtotal, required double tvaRate}) {
    return subtotal * (tvaRate / 100);
  }

  static double calculateDeposit({required double total, required double depositPercent}) {
    return total * (depositPercent / 100);
  }

  static String formatCurrency(double amount) {
    return NumberFormat.currency(locale: 'fr_FR', symbol: '€').format(amount);
  }

  static String formatDate(DateTime date) {
    return DateFormat('dd/MM/yyyy').format(date);
  }

  static String formatTime(DateTime date) {
    return DateFormat('HH:mm').format(date);
  }

  static String generateInvoiceNumber(int lastInvoiceNumber) {
    final now = DateTime.now();
    final year = now.year.toString().substring(2);
    final month = now.month.toString().padLeft(2, '0');
    final nextNumber = (lastInvoiceNumber + 1).toString().padLeft(4, '0');
    return 'FAC-$year$month-$nextNumber';
  }
}
