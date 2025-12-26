import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

import 'backup_service.dart';
import 'restore_service.dart';

class BackupRestorePage extends StatelessWidget {
  const BackupRestorePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Backup & Restore'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // 🔐 BACKUP
            Card(
              elevation: 6,
              child: ListTile(
                leading: const Icon(Icons.backup, color: Colors.green),
                title: const Text('Create Backup'),
                subtitle:
                const Text('Export all data to a backup file'),
                onTap: () async {
                  final file =
                  await BackupService.createBackup();

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                          'Backup saved successfully:\n${file.path}'),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),

            // ♻️ RESTORE
            Card(
              elevation: 6,
              child: ListTile(
                leading:
                const Icon(Icons.restore, color: Colors.red),
                title: const Text('Restore Backup'),
                subtitle: const Text(
                    'Restore data from backup file (Admin only)'),
                onTap: () async {
                  final confirm = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: const Text('Restore Data'),
                      content: const Text(
                        'This will ADD data from backup.\n'
                            'Existing data will NOT be deleted.\n\n'
                            'Continue?',
                      ),
                      actions: [
                        TextButton(
                          onPressed: () =>
                              Navigator.pop(context, false),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(context, true),
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red),
                          child: const Text('Restore'),
                        ),
                      ],
                    ),
                  );

                  if (confirm != true) return;

                  final result =
                  await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowedExtensions: ['json'],
                  );

                  if (result == null) return;

                  final file =
                  File(result.files.single.path!);

                  await RestoreService.restoreFromFile(file);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content:
                        Text('Restore completed successfully')),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
