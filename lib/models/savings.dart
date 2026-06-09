enum RecurrenceType { harian, mingguan, bulanan }
enum SavingsStatus { berlangsung, tercapai }

class Savings {

  Savings({
    required this.id,
    required this.title,
    required this.targetAmount, required this.currentAmount, required this.remainingAmount, required this.progressPercentage, required this.nominialPengisian, required this.remainingContributions, required this.recurrenceType, required this.status, required this.createdDate, required this.targetDate, this.notes = '',
  });

  // Fungsi untuk membaca data dari Cloud Firestore
  factory Savings.fromFirestore(String id, Map<String, dynamic> data) {
    // Konversi text string dari Firebase ke Enum RecurrenceType
    var recType = RecurrenceType.harian;
    if (data['recurrenceType'] == 'mingguan') recType = RecurrenceType.mingguan;
    if (data['recurrenceType'] == 'bulanan') recType = RecurrenceType.bulanan;

    // Konversi text string dari Firebase ke Enum SavingsStatus
    var savStatus = SavingsStatus.berlangsung;
    if (data['status'] == 'tercapai') savStatus = SavingsStatus.tercapai;

    // Konversi Timestamp Firestore ke DateTime
    var createdDate = DateTime.now();
    if (data['createdAt'] != null) {
      createdDate = (data['createdAt'] as dynamic).toDate();
    }

    var targetDate = DateTime.now().add(const Duration(days: 30));
    if (data['targetDate'] != null) {
      targetDate = (data['targetDate'] as dynamic).toDate();
    }

    return Savings(
      id: id,
      title: data['title'] ?? '',
      notes: data['notes'] ?? '',
      targetAmount: (data['targetAmount'] ?? 0.0).toDouble(),
      currentAmount: (data['currentAmount'] ?? 0.0).toDouble(),
      remainingAmount: (data['remainingAmount'] ?? 0.0).toDouble(),
      progressPercentage: (data['progressPercentage'] ?? 0.0).toDouble(),
      nominialPengisian: (data['nominialPengisian'] ?? 0.0).toDouble(),
      remainingContributions: data['remainingContributions'] ?? 0,
      recurrenceType: recType,
      status: savStatus,
      createdDate: createdDate,
      targetDate: targetDate,
    );
  }
  final String id;
  final String title;
  final String notes;
  final double targetAmount;
  final double currentAmount;
  final double remainingAmount;
  final double progressPercentage;
  final double nominialPengisian;
  final int remainingContributions;
  final RecurrenceType recurrenceType;
  final SavingsStatus status;
  final DateTime createdDate;
  final DateTime targetDate;
}