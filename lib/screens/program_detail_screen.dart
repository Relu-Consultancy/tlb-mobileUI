import 'package:flutter/material.dart';
import '../models/event_model.dart';
import 'class_detail_screen.dart';
import 'select_program_batch_screen.dart';

class ProgramDetailScreen extends StatelessWidget {
  final EventModel event;

  const ProgramDetailScreen({super.key, required this.event});

  @override
  Widget build(BuildContext context) {
    return ClassDetailScreen(
      event: event,
      buttonLabel: 'Check Availability',
      onBookTapped: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => SelectProgramBatchScreen(event: event),
        ),
      ),
    );
  }
}
