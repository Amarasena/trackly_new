// lib/screens/driver/add_bus_schedule.dart

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddBusSchedule extends StatefulWidget {
  @override
  _AddBusScheduleState createState() => _AddBusScheduleState();
}

class _AddBusScheduleState extends State<AddBusSchedule> {
  final Map<String, TimeOfDay> _schedule = {};

  Future<void> _saveSchedule() async {
    // Save schedule data to Firestore
    for (var day in _schedule.keys) {
      final scheduleData = {
        "day": day,
        "departureTime": _schedule[day]?.format(context),
        "createdAt": FieldValue.serverTimestamp(),
      };

      await FirebaseFirestore.instance.collection('schedules').add(scheduleData);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Schedules saved successfully!")),
    );
  }

  Future<void> _selectTime(String day) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      setState(() {
        _schedule[day] = pickedTime;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Bus Schedule')),
      body: ListView(
        children: [
          for (var day in ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday'])
            ListTile(
              title: Text(day),
              trailing: IconButton(
                icon: Icon(Icons.access_time),
                onPressed: () => _selectTime(day),
              ),
            ),
          ElevatedButton(
            onPressed: _saveSchedule,
            child: Text('Save Schedules'),
          ),
        ],
      ),
    );
  }
}
