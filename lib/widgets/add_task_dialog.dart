import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddTaskDialog extends StatefulWidget {
  final Function(String title, String description, String category,
      DateTime startTime, DateTime endTime) onSubmit;

  const AddTaskDialog({
    super.key,
    required this.onSubmit,
  });

  @override
  State<AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<AddTaskDialog> {
  final titleController = TextEditingController();
  final descriptionController = TextEditingController();
  late String selectedCategory = 'Web Design';
  late DateTime startDate = DateTime.now();
  late DateTime endDate = DateTime.now().add(const Duration(hours: 2));

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Task'),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: selectedCategory,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: ['Web Design', 'Web Development', 'UI/UX', 'Mobile']
                  .map((category) => DropdownMenuItem(
                        value: category,
                        child: Text(category),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  selectedCategory = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Start Time'),
              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: startDate,
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(startDate),
                  );
                  if (time != null) {
                    setState(() {
                      startDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                      if (endDate.isBefore(startDate)) {
                        endDate = startDate.add(const Duration(hours: 1));
                      }
                    });
                  }
                }
              },
            ),
            ListTile(
              title: const Text('End Time'),
              subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(endDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: endDate,
                  firstDate: startDate,
                  lastDate: DateTime(2030),
                );
                if (date != null) {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.fromDateTime(endDate),
                  );
                  if (time != null) {
                    setState(() {
                      endDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  }
                }
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: () {
            if (titleController.text.isNotEmpty) {
              widget.onSubmit(
                titleController.text,
                descriptionController.text,
                selectedCategory,
                startDate,
                endDate,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Task created successfully'),
                ),
              );
            }
          },
          child: const Text('Add Task'),
        ),
      ],
    );
  }
}
