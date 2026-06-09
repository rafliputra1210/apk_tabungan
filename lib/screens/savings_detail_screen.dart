import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../providers/savings_provider.dart';
import '../models/savings.dart';
import '../utils/currency_formatter.dart';

class SavingsDetailScreen extends StatefulWidget {
  final String savingsId;

  const SavingsDetailScreen({
    super.key,
    required this.savingsId,
  });

  @override
  State<SavingsDetailScreen> createState() => _SavingsDetailScreenState();
}

class _SavingsDetailScreenState extends State<SavingsDetailScreen> {
  late TextEditingController _contributionController;

  @override
  void initState() {
    super.initState();
    _contributionController = TextEditingController();
  }

  @override
  void dispose() {
    _contributionController.dispose();
    super.dispose();
  }

  void _addContribution() async {
    if (_contributionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan nominal pengisian')),
      );
      return;
    }

    try {
      final amount = double.parse(_contributionController.text.replaceAll('.', ''));
      if (amount <= 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Nominal harus lebih dari 0')),
        );
        return;
      }

      await context
          .read<SavingsProvider>()
          .addContribution(widget.savingsId, amount);

      _contributionController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengisian berhasil ditambahkan')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Input tidak valid')),
      );
    }
  }

  void _editSavings(Savings savings) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Tabungan'),
        content: const Text('Fitur edit akan datang segera'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tutup'),
          ),
        ],
      ),
    );
  }

  void _deleteSavings(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Tabungan'),
        content: const Text('Apakah Anda yakin ingin menghapus tabungan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<SavingsProvider>().deleteSavings(id);
              if (mounted) {
                Navigator.pop(context);
                Navigator.pop(context, true);
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  void _markAsAchieved(String id) async {
    await context
        .read<SavingsProvider>()
        .updateSavingsStatus(id, SavingsStatus.tercapai);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tabungan ditandai sebagai tercapai')),
      );
    }
  }

  void _markAsOngoing(String id) async {
    await context
        .read<SavingsProvider>()
        .updateSavingsStatus(id, SavingsStatus.berlangsung);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tabungan ditandai sebagai berlangsung')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return Consumer<SavingsProvider>(
      builder: (context, provider, _) {
        final savings = provider.getSavingsById(widget.savingsId);

        if (savings == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Tabungan')),
            body: const Center(child: Text('Tabungan tidak ditemukan')),
          );
        }

        final isAchieved = savings.status == SavingsStatus.tercapai;

        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              PopupMenuButton(
                icon: const Icon(Icons.more_vert),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 20),
                        SizedBox(width: 12),
                        Text('Edit'),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _editSavings(savings);
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: Row(
                      children: [
                        Icon(isAchieved ? Icons.refresh : Icons.check_circle_outline, size: 20),
                        const SizedBox(width: 12),
                        Text(isAchieved ? 'Tandai Berlangsung' : 'Tandai Tercapai'),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        if (isAchieved) {
                          _markAsOngoing(savings.id);
                        } else {
                          _markAsAchieved(savings.id);
                        }
                      });
                    },
                  ),
                  PopupMenuItem(
                    child: const Row(
                      children: [
                        Icon(Icons.delete_outline, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text('Hapus', style: TextStyle(color: Colors.red)),
                      ],
                    ),
                    onTap: () {
                      Future.delayed(const Duration(milliseconds: 100), () {
                        _deleteSavings(savings.id);
                      });
                    },
                  ),
                ],
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Hero Section
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Column(
                    children: [
                      Text(
                        savings.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          letterSpacing: -0.5,
                        ),
                      ).animate().fadeIn().slideY(begin: -0.2),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: isAchieved ? Colors.green[50] : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (isAchieved) ...[
                              const Icon(Icons.check_circle, size: 16, color: Colors.green),
                              const SizedBox(width: 6),
                            ],
                            Text(
                              isAchieved ? 'Target Tercapai!' : 'Sedang Berlangsung',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isAchieved ? Colors.green[700] : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: 32),
                      
                      // Big Circular Progress
                      CircularPercentIndicator(
                        radius: 100.0,
                        lineWidth: 16.0,
                        animation: true,
                        animationDuration: 1200,
                        percent: (savings.progressPercentage / 100).clamp(0.0, 1.0),
                        center: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "${savings.progressPercentage.toStringAsFixed(1)}%",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 32.0,
                                color: isAchieved ? Colors.green : Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            Text(
                              "Terkumpul",
                              style: TextStyle(
                                fontSize: 14.0,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        circularStrokeCap: CircularStrokeCap.round,
                        progressColor: isAchieved ? Colors.green : Theme.of(context).colorScheme.primary,
                        backgroundColor: Colors.grey[200]!,
                      ).animate().scale(delay: 200.ms, curve: Curves.easeOutBack),
                      
                      const SizedBox(height: 32),
                      
                      // Key Stats
                      Row(
                        children: [
                          Expanded(
                            child: _buildStatBox(
                              'Terkumpul',
                              currencyFormat.format(savings.currentAmount),
                              Icons.account_balance_wallet,
                              Theme.of(context).colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildStatBox(
                              'Target',
                              currencyFormat.format(savings.targetAmount),
                              Icons.flag,
                              Colors.orange,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                    ],
                  ),
                ),

                // Form Tambah Pengisian (hanya jika belum tercapai)
                if (!isAchieved)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.04),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Tambah Tabungan',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _contributionController,
                            keyboardType: TextInputType.number,
                            inputFormatters: [CurrencyInputFormatter()],
                            decoration: InputDecoration(
                              hintText: 'Masukkan nominal',
                              filled: true,
                              fillColor: Colors.grey[100],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none,
                              ),
                              prefixIcon: Icon(Icons.attach_money, color: Theme.of(context).colorScheme.primary),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildQuickAddButton(savings.nominialPengisian),
                              _buildQuickAddButton(savings.nominialPengisian * 2),
                              _buildQuickAddButton(savings.nominialPengisian * 5),
                            ],
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _addContribution,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('Top Up Sekarang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.2),
                  ),

                // Informasi Detail Lainnya
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Detail Rencana',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildDetailRow('Sisa Kekurangan', currencyFormat.format(savings.remainingAmount), Icons.pending_actions),
                        const Divider(height: 24),
                        _buildDetailRow('Nominal Rutin', currencyFormat.format(savings.nominialPengisian), Icons.payments_outlined),
                        const Divider(height: 24),
                        _buildDetailRow('Rencana', _getRecurrenceName(savings.recurrenceType), Icons.calendar_month_outlined),
                        const Divider(height: 24),
                        _buildDetailRow('Pengisian Tersisa', '${savings.remainingContributions} kali', Icons.format_list_numbered),
                        const Divider(height: 24),
                        _buildDetailRow('Tanggal Dibuat', DateFormat('dd MMM yyyy').format(savings.createdDate), Icons.event_available_outlined),
                        const Divider(height: 24),
                        _buildDetailRow('Target Selesai', DateFormat('dd MMM yyyy').format(savings.targetDate), Icons.event_outlined),
                        if (savings.notes.isNotEmpty) ...[
                          const Divider(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.notes, size: 20, color: Colors.grey[600]),
                                  const SizedBox(width: 12),
                                  Text(
                                    'Catatan',
                                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(savings.notes, style: const TextStyle(fontSize: 14, height: 1.5)),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatBox(String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickAddButton(double amount) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    return ActionChip(
      label: Text(currencyFormat.format(amount)),
      backgroundColor: Colors.white,
      side: BorderSide(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
      labelStyle: TextStyle(
        fontSize: 13,
        color: Theme.of(context).colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
      onPressed: () {
        _contributionController.text = amount.toStringAsFixed(0);
      },
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
