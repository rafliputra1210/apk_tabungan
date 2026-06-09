import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:percent_indicator/percent_indicator.dart';

import '../models/savings.dart';
import '../providers/savings_provider.dart';
import 'add_savings_screen.dart';
import 'savings_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SavingsProvider>().loadSavings();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: Column(
            children: [
              _buildDashboardHeader(context),
              TabBar(
                controller: _tabController,
                indicatorColor: Theme.of(context).colorScheme.primary,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Colors.grey,
                indicatorWeight: 3,
                tabs: const [
                  Tab(text: 'Berlangsung'),
                  Tab(text: 'Tercapai'),
                ],
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildOngoingTab(),
                    _buildAchievedTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () async {
            final result = await Navigator.of(context).push<bool>(
              MaterialPageRoute(
                builder: (context) => const AddSavingsScreen(),
              ),
            );
            if (result == true && mounted) {
              context.read<SavingsProvider>().loadSavings();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Tabungan baru berhasil ditambahkan!')),
              );
            }
          },
          backgroundColor: Theme.of(context).colorScheme.primary,
          icon: const Icon(Icons.add, color: Colors.white),
          label: const Text('Tabungan', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          elevation: 4,
        ).animate().scale(delay: 400.ms, duration: 400.ms, curve: Curves.easeOutBack),
      );

  Widget _buildDashboardHeader(BuildContext context) {
    return Consumer<SavingsProvider>(
      builder: (context, provider, _) {
        double totalSaved = 0;
        for (var s in provider.ongoingSavings) {
          totalSaved += s.currentAmount;
        }
        for (var s in provider.achievedSavings) {
          totalSaved += s.currentAmount;
        }

        final currencyFormat = NumberFormat.currency(
          locale: 'id_ID',
          symbol: 'Rp ',
          decimalDigits: 0,
        );

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(32),
              bottomRight: Radius.circular(32),
            ),
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
                'Total Saldo Terkumpul',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ).animate().fadeIn(duration: 400.ms).slideY(begin: -0.2),
              const SizedBox(height: 8),
              Text(
                currencyFormat.format(totalSaved),
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                  color: Theme.of(context).colorScheme.primary,
                  letterSpacing: -1,
                ),
              ).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.9, 0.9)),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOngoingTab() => Consumer<SavingsProvider>(
        builder: (context, provider, _) {
          final ongoingSavings = provider.ongoingSavings;

          if (ongoingSavings.isEmpty) {
            return _buildEmptyState('Belum ada tabungan yang berlangsung', Icons.savings_outlined);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: ongoingSavings.length,
            itemBuilder: (context, index) => _buildSavingsCard(context, ongoingSavings[index])
                .animate()
                .fadeIn(delay: (index * 100).ms)
                .slideY(begin: 0.1, delay: (index * 100).ms),
          );
        },
      );

  Widget _buildAchievedTab() => Consumer<SavingsProvider>(
        builder: (context, provider, _) {
          final achievedSavings = provider.achievedSavings;

          if (achievedSavings.isEmpty) {
            return _buildEmptyState('Belum ada tabungan yang tercapai', Icons.emoji_events_outlined);
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: achievedSavings.length,
            itemBuilder: (context, index) => _buildSavingsCard(context, achievedSavings[index])
                .animate()
                .fadeIn(delay: (index * 100).ms)
                .slideY(begin: 0.1, delay: (index * 100).ms),
          );
        },
      );

  Widget _buildEmptyState(String message, IconData icon) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
          ).animate().scale(duration: 500.ms, curve: Curves.easeOutBack),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ).animate().fadeIn(delay: 200.ms),
        ],
      ),
    );
  }

  Widget _buildSavingsCard(BuildContext context, Savings savings) {
    final currencyFormat = NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    );

    final isAchieved = savings.status == SavingsStatus.tercapai;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(
          color: isAchieved ? Colors.green.withOpacity(0.3) : Colors.grey.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: () async {
          final result = await Navigator.of(context).push<bool>(
            MaterialPageRoute(
              builder: (context) => SavingsDetailScreen(savingsId: savings.id),
            ),
          );
          if (result == true && mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Tabungan berhasil diperbarui')),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          savings.title,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Rencana: ${_getRecurrenceName(savings.recurrenceType)}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isAchieved ? Colors.green[50] : Theme.of(context).colorScheme.primary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAchieved) ...[
                          const Icon(Icons.check_circle, size: 16, color: Colors.green),
                          const SizedBox(width: 4),
                        ],
                        Text(
                          isAchieved ? 'Tercapai' : 'Berlangsung',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: isAchieved ? Colors.green[700] : Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  CircularPercentIndicator(
                    radius: 36.0,
                    lineWidth: 8.0,
                    animation: true,
                    percent: (savings.progressPercentage / 100).clamp(0.0, 1.0),
                    center: Text(
                      "${savings.progressPercentage.toStringAsFixed(0)}%",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14.0,
                        color: isAchieved ? Colors.green : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    circularStrokeCap: CircularStrokeCap.round,
                    progressColor: isAchieved ? Colors.green : Theme.of(context).colorScheme.primary,
                    backgroundColor: Colors.grey[200]!,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow('Terkumpul', currencyFormat.format(savings.currentAmount), isBold: true),
                        const SizedBox(height: 8),
                        _buildInfoRow('Target', currencyFormat.format(savings.targetAmount), isBold: false),
                        if (!isAchieved) ...[
                          const SizedBox(height: 8),
                          _buildInfoRow('Sisa', currencyFormat.format(savings.remainingAmount), isBold: false),
                        ]
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey[600],
            fontWeight: isBold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            color: isBold ? Colors.black87 : Colors.grey[800],
          ),
        ),
      ],
    );
  }

  void _confirmDeleteSavings(BuildContext context, String savingsId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Hapus Tabungan'),
        content: const Text('Apakah Anda yakin ingin menghapus tabungan yang sudah tercapai ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              await context.read<SavingsProvider>().deleteSavings(savingsId);
              if (mounted) {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tabungan berhasil dihapus')),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
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
