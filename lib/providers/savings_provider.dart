import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/savings.dart';

class SavingsProvider with ChangeNotifier {
  List<Savings> _allSavings = [];

  // Getter untuk memisahkan tabungan yang Berlangsung dan Tercapai di UI
  List<Savings> get ongoingSavings =>
      _allSavings.where((s) => s.status == SavingsStatus.berlangsung).toList();

  List<Savings> get achievedSavings =>
      _allSavings.where((s) => s.status == SavingsStatus.tercapai).toList();

  // Ambil satu tabungan berdasarkan ID
  Savings? getSavingsById(String id) {
    try {
      return _allSavings.firstWhere((s) => s.id == id);
    } catch (e) {
      return null;
    }
  }

  // 1. Ambil data dari Cloud Firestore
  Future<void> loadSavings() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('savings')
          .orderBy('createdAt', descending: true)
          .get();

      _allSavings = snapshot.docs.map((doc) => Savings.fromFirestore(doc.id, doc.data())).toList();

      notifyListeners();
    } catch (e) {
      debugPrint('❌ Gagal memuat data dari Firebase: $e');
    }
  }

  // 2. Tambah tabungan baru ke Firestore
  Future<void> addSavings(Savings savings) async {
    try {
      final remaining = savings.targetAmount - savings.currentAmount;
      final totalContributions = savings.nominialPengisian > 0
          ? (remaining / savings.nominialPengisian).ceil()
          : 0;

      await FirebaseFirestore.instance.collection('savings').add({
        'title': savings.title,
        'notes': savings.notes,
        'targetAmount': savings.targetAmount,
        'currentAmount': savings.currentAmount,
        'remainingAmount': remaining,
        'progressPercentage': savings.targetAmount > 0
            ? (savings.currentAmount / savings.targetAmount) * 100
            : 0.0,
        'nominialPengisian': savings.nominialPengisian,
        'remainingContributions': totalContributions,
        'recurrenceType': savings.recurrenceType.name,
        'status': savings.status.name,
        'createdAt': Timestamp.now(),
        'targetDate': Timestamp.fromDate(savings.targetDate),
      });

      debugPrint('✅ Tabungan baru berhasil disimpan ke Firebase!');
      await loadSavings();
    } catch (e) {
      debugPrint('❌ Gagal menambah tabungan: $e');
      rethrow;
    }
  }

  // 3. Tambah pengisian (setoran) ke tabungan yang ada
  Future<void> addContribution(String savingsId, double amount) async {
    try {
      final savings = getSavingsById(savingsId);
      if (savings == null) return;

      final newCurrentAmount = savings.currentAmount + amount;
      var newRemainingAmount = savings.targetAmount - newCurrentAmount;
      if (newRemainingAmount < 0) newRemainingAmount = 0;

      var newProgress = savings.targetAmount > 0
          ? (newCurrentAmount / savings.targetAmount) * 100
          : 0;
      if (newProgress > 100) newProgress = 100;

      final newRemainingContributions = savings.nominialPengisian > 0
          ? (newRemainingAmount / savings.nominialPengisian).ceil()
          : 0;

      final newStatus =
          newCurrentAmount >= savings.targetAmount ? 'tercapai' : 'berlangsung';

      await FirebaseFirestore.instance
          .collection('savings')
          .doc(savingsId)
          .update({
        'currentAmount': newCurrentAmount,
        'remainingAmount': newRemainingAmount,
        'progressPercentage': newProgress,
        'remainingContributions': newRemainingContributions,
        'status': newStatus,
      });

      debugPrint('✅ Pengisian berhasil ditambahkan!');
      await loadSavings();
    } catch (e) {
      debugPrint('❌ Gagal menambah pengisian: $e');
      rethrow;
    }
  }

  // 4. Update status tabungan (berlangsung / tercapai)
  Future<void> updateSavingsStatus(
      String savingsId, SavingsStatus newStatus) async {
    try {
      await FirebaseFirestore.instance
          .collection('savings')
          .doc(savingsId)
          .update({'status': newStatus.name});

      debugPrint('✅ Status tabungan berhasil diperbarui!');
      await loadSavings();
    } catch (e) {
      debugPrint('❌ Gagal memperbarui status: $e');
      rethrow;
    }
  }

  // 5. Hapus tabungan dari Firestore
  Future<void> deleteSavings(String savingsId) async {
    try {
      await FirebaseFirestore.instance
          .collection('savings')
          .doc(savingsId)
          .delete();

      debugPrint('✅ Tabungan berhasil dihapus!');
      await loadSavings();
    } catch (e) {
      debugPrint('❌ Gagal menghapus data dari Firebase: $e');
      rethrow;
    }
  }
}