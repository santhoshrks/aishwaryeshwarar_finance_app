import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:ui';

import 'backup_service.dart';
import 'restore_service.dart';

class BackupRestorePage extends StatelessWidget {
  const BackupRestorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Theme.of(context).primaryColor, Colors.black87],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              iconTheme: const IconThemeData(color: Colors.white),
              title: Text('Backup & Restore', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildGlassCard(
                    child: ListTile(
                      leading: const Icon(Icons.backup, color: Colors.white70, size: 32),
                      title: Text('Create Backup', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: const Text('Export all data to a backup file', style: TextStyle(color: Colors.white70)),
                      onTap: () async {
                        final file = await BackupService.createBackup();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Backup saved successfully:\n${file.path}')),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  _buildGlassCard(
                    child: ListTile(
                      leading: const Icon(Icons.restore, color: Colors.white70, size: 32),
                      title: Text('Restore Backup', style: GoogleFonts.lato(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      subtitle: const Text('Restore data from backup file (Admin only)', style: TextStyle(color: Colors.white70)),
                      onTap: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Restore Data'),
                            content: const Text('This will ADD data from backup. Existing data will NOT be deleted.\n\nContinue?'),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                child: const Text('Restore'),
                              ),
                            ],
                          ),
                        );
                        if (confirm != true) return;

                        final result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['json']);
                        if (result == null) return;

                        final file = File(result.files.single.path!);
                        await RestoreService.restoreFromFile(file);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Restore completed successfully')),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlassCard({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.2)),
          ),
          child: child,
        ),
      ),
    );
  }
}
