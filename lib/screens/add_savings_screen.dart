import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/savings_provider.dart';
import '../models/savings.dart';
import '../utils/currency_formatter.dart';

class AddSavingsScreen extends StatefulWidget {
  const AddSavingsScreen({super.key});

  @override
  State<AddSavingsScreen> createState() => _AddSavingsScreenState();
}

class _AddSavingsScreenState extends State<AddSavingsScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  late TextEditingController _notesController;
  late TextEditingController _targetAmountController;
  late TextEditingController _nominalController;
  late TextEditingController _targetDateController;

  RecurrenceType _selectedRecurrence = RecurrenceType.harian;
  DateTime? _selectedTargetDate;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
    _notesController = TextEditingController();
    _targetAmountController = TextEditingController();
    _nominalController = TextEditingController();
    _targetDateController = TextEditingController();

    _selectedTargetDate = DateTime.now().add(const Duration(days: 30));
    _targetDateController.text = _formatDate(_selectedTargetDate!);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    _targetAmountController.dispose();
    _nominalController.dispose();
    _targetDateController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTargetDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: Theme.of(context).colorScheme.primary, // header background color
              onPrimary: Colors.white, // header text color
              onSurface: Colors.black, // body text color
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(context).colorScheme.primary, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTargetDate = picked;
        _targetDateController.text = _formatDate(picked);
      });
    }
  }

  void _addSavings() async {
    if (_formKey.currentState!.validate()) {
      final targetStr = _targetAmountController.text.replaceAll('.', '');
      final nominalStr = _nominalController.text.replaceAll('.', '');
      final target = double.parse(targetStr);
      final nominal = double.parse(nominalStr);
      final totalContributions = nominal > 0 ? (target / nominal).ceil() : 0;

      final newSavings = Savings(
        id: '',
        title: _titleController.text.trim(),
        notes: _notesController.text.trim(),
        targetAmount: target,
        currentAmount: 0,
        remainingAmount: target,
        progressPercentage: 0,
        nominialPengisian: nominal,
        remainingContributions: totalContributions,
        recurrenceType: _selectedRecurrence,
        status: SavingsStatus.berlangsung,
        createdDate: DateTime.now(),
        targetDate: _selectedTargetDate!,
      );

      try {
        await context.read<SavingsProvider>().addSavings(newSavings);
        if (mounted) {
          Navigator.of(context).pop(true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menyimpan tabungan: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Buat Rencana Baru'),
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Mari Wujudkan\nImpian Anda!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: Theme.of(context).colorScheme.primary,
                    height: 1.2,
                    letterSpacing: -1,
                  ),
                ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.1),
                const SizedBox(height: 8),
                Text(
                  'Isi detail tabungan Anda di bawah ini.',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ).animate().fadeIn(delay: 200.ms),
                const SizedBox(height: 32),
                
                // Form Fields
                _buildInputField(
                  label: 'Nama Tabungan',
                  hint: 'Contoh: Beli Motor, Liburan...',
                  icon: Icons.flag_outlined,
                  controller: _titleController,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Tidak boleh kosong';
                    return null;
                  },
                ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 24),
                _buildInputField(
                  label: 'Target Terkumpul (Rp)',
                  hint: 'Contoh: 10.000.000',
                  icon: Icons.account_balance_wallet_outlined,
                  controller: _targetAmountController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Tidak boleh kosong';
                    final cleanValue = value.replaceAll('.', '');
                    if (double.tryParse(cleanValue) == null) return 'Harus berupa angka';
                    if (double.parse(cleanValue) <= 0) return 'Harus lebih dari 0';
                    return null;
                  },
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),
                _buildInputField(
                  label: 'Nominal Rutin (Rp)',
                  hint: 'Contoh: 50.000',
                  icon: Icons.payments_outlined,
                  controller: _nominalController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [CurrencyInputFormatter()],
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Tidak boleh kosong';
                    final cleanValue = value.replaceAll('.', '');
                    if (double.tryParse(cleanValue) == null) return 'Harus berupa angka';
                    if (double.parse(cleanValue) <= 0) return 'Harus lebih dari 0';
                    return null;
                  },
                ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),
                _buildDropdownField().animate().fadeIn(delay: 600.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),
                _buildInputField(
                  label: 'Target Selesai',
                  hint: 'Pilih Tanggal',
                  icon: Icons.calendar_today_outlined,
                  controller: _targetDateController,
                  readOnly: true,
                  onTap: () => _selectDate(context),
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Pilih tanggal target';
                    return null;
                  },
                ).animate().fadeIn(delay: 700.ms).slideY(begin: 0.2),

                const SizedBox(height: 24),
                _buildInputField(
                  label: 'Catatan (Opsional)',
                  hint: 'Tuliskan catatan tambahan di sini',
                  icon: Icons.notes_outlined,
                  controller: _notesController,
                  maxLines: 3,
                ).animate().fadeIn(delay: 800.ms).slideY(begin: 0.2),

                const SizedBox(height: 40),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _addSavings,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18),
                      elevation: 4,
                      shadowColor: Theme.of(context).colorScheme.primary.withOpacity(0.5),
                    ),
                    child: const Text(
                      'Simpan Rencana Tabungan',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ).animate().fadeIn(delay: 900.ms).scale(begin: const Offset(0.9, 0.9)),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          readOnly: readOnly,
          onTap: onTap,
          validator: validator,
          inputFormatters: inputFormatters,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[100],
            prefixIcon: Icon(icon, color: Theme.of(context).colorScheme.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Colors.red, width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Theme.of(context).colorScheme.primary, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Rencana Pengisian',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<RecurrenceType>(
              value: _selectedRecurrence,
              isExpanded: true,
              icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
              items: RecurrenceType.values.map((RecurrenceType value) {
                return DropdownMenuItem<RecurrenceType>(
                  value: value,
                  child: Row(
                    children: [
                      Icon(Icons.autorenew, size: 20, color: Colors.grey[600]),
                      const SizedBox(width: 12),
                      Text(_getRecurrenceName(value)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (RecurrenceType? newValue) {
                if (newValue != null) {
                  setState(() {
                    _selectedRecurrence = newValue;
                  });
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  String _getRecurrenceName(RecurrenceType type) {
    switch (type) {
      case RecurrenceType.harian:
        return 'Harian';
      case RecurrenceType.mingguan:
        return 'Mingguan';
      case RecurrenceType.bulanan:
        return 'Bulanan';
    }
  }
}
