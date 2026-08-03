import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/emergency_contact.dart';

class ContactsProvider with ChangeNotifier {
  List<EmergencyContact> _contacts = [];

  ContactsProvider() {
    _loadContacts();
  }

  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);

  void _loadContacts() {
    try {
      final box = Hive.box<EmergencyContact>('emergency_contacts');
      _contacts = box.values.toList();
    } catch (e) {
      debugPrint('Error loading contacts from Hive: $e');
      _contacts = [];
    }
  }

  Future<void> addContact(EmergencyContact contact) async {
    try {
      final box = Hive.box<EmergencyContact>('emergency_contacts');
      await box.put(contact.id, contact);
      _contacts = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error adding contact: $e');
    }
  }

  Future<void> deleteContact(String id) async {
    try {
      final box = Hive.box<EmergencyContact>('emergency_contacts');
      await box.delete(id);
      _contacts = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error deleting contact: $e');
    }
  }

  Future<void> updateContact(EmergencyContact contact) async {
    try {
      final box = Hive.box<EmergencyContact>('emergency_contacts');
      await box.put(contact.id, contact);
      _contacts = box.values.toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error updating contact: $e');
    }
  }
}
