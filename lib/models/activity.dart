
enum ActivityType { quote, invoice, payment }

class Activity {
  final dynamic item;
  final DateTime date;
  final ActivityType type;

  Activity({required this.item, required this.date, required this.type});
}
