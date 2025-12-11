import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import '../../../../core/di/injection.dart';
import '../../data/models/models.dart';
import '../../../groups/data/models/models.dart';
import '../../../students/data/models/models.dart';
import '../bloc/attendance_bloc.dart';

class AttendancePage extends StatelessWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => getIt<AttendanceBloc>()..add(const AttendanceLoadGroups()),
      child: const AttendanceView(),
    );
  }
}

class AttendanceView extends StatelessWidget {
  const AttendanceView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Attendance'),
      ),
      body: BlocConsumer<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is AttendanceSaved) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Attendance saved successfully'),
                backgroundColor: Colors.green,
              ),
            );
          }
        },
        builder: (context, state) {
          return state.when(
            initial: () => const SizedBox.shrink(),
            loading: () => const Center(child: CircularProgressIndicator()),
            groupsLoaded: (groups) => _buildGroupSelection(context, groups),
            ready: (groups, selectedGroup, selectedDate, students,
                    existingAttendance, absentStudentIds, hasExisting) =>
                _buildAttendanceForm(
              context,
              groups,
              selectedGroup,
              selectedDate,
              students,
              existingAttendance,
              absentStudentIds,
              hasExisting,
            ),
            saving: () => const Center(child: CircularProgressIndicator()),
            saved: () => const SizedBox.shrink(),
            error: (message) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(message),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => context
                        .read<AttendanceBloc>()
                        .add(const AttendanceLoadGroups()),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildGroupSelection(BuildContext context, List<Group> groups) {
    if (groups.isEmpty) {
      return const Center(child: Text('No groups available'));
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select a group to take attendance',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: groups.length,
              itemBuilder: (context, index) {
                final group = groups[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      child: Text(group.name[0].toUpperCase()),
                    ),
                    title: Text(group.name),
                    subtitle: Text('${group.teacherName} • ${group.studentsCount} students'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      context.read<AttendanceBloc>().add(
                            AttendanceSelectGroup(group: group),
                          );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttendanceForm(
    BuildContext context,
    List<Group> groups,
    Group selectedGroup,
    DateTime selectedDate,
    List<Student> students,
    List<Attendance> existingAttendance,
    Set<int> absentStudentIds,
    bool hasExistingAttendance,
  ) {
    final dateFormat = DateFormat('dd MMM yyyy');
    final presentCount = students.length - absentStudentIds.length;
    final absentCount = absentStudentIds.length;

    return Column(
      children: [
        // Header with group and date selection
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<Group>(
                      value: selectedGroup,
                      decoration: const InputDecoration(
                        labelText: 'Group',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      ),
                      items: groups.map((group) {
                        return DropdownMenuItem(
                          value: group,
                          child: Text(group.name),
                        );
                      }).toList(),
                      onChanged: (group) {
                        if (group != null) {
                          context.read<AttendanceBloc>().add(
                                AttendanceSelectGroup(group: group),
                              );
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: InkWell(
                      onTap: () => _selectDate(context, selectedDate),
                      child: InputDecorator(
                        decoration: const InputDecoration(
                          labelText: 'Date',
                          border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(dateFormat.format(selectedDate)),
                            const Icon(Icons.calendar_today, size: 18),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildStatChip(
                    context,
                    Icons.people,
                    'Total: ${students.length}',
                    Colors.blue,
                  ),
                  _buildStatChip(
                    context,
                    Icons.check_circle,
                    'Present: $presentCount',
                    Colors.green,
                  ),
                  _buildStatChip(
                    context,
                    Icons.cancel,
                    'Absent: $absentCount',
                    Colors.red,
                  ),
                ],
              ),
            ],
          ),
        ),

        // Status indicator
        if (hasExistingAttendance)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            color: Colors.orange.withOpacity(0.2),
            child: Row(
              children: [
                const Icon(Icons.info, color: Colors.orange, size: 18),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    'Attendance already recorded. Tap to modify individual status.',
                    style: TextStyle(color: Colors.orange),
                  ),
                ),
              ],
            ),
          ),

        // Student list
        Expanded(
          child: students.isEmpty
              ? const Center(child: Text('No students in this group'))
              : ListView.builder(
                  itemCount: students.length,
                  itemBuilder: (context, index) {
                    final student = students[index];
                    final isAbsent = absentStudentIds.contains(student.id);
                    final attendance = existingAttendance
                        .where((a) => a.studentId == student.id)
                        .firstOrNull;

                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isAbsent ? Colors.red : Colors.green,
                        child: Text(
                          student.fullName[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(student.fullName),
                      subtitle: Text(isAbsent ? 'Absent' : 'Present'),
                      trailing: hasExistingAttendance && attendance != null
                          ? PopupMenuButton<String>(
                              onSelected: (status) {
                                context.read<AttendanceBloc>().add(
                                      AttendanceUpdateStatus(
                                        attendanceId: attendance.id,
                                        status: status,
                                      ),
                                    );
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'PRESENT',
                                  child: Text('Mark Present'),
                                ),
                                const PopupMenuItem(
                                  value: 'ABSENT',
                                  child: Text('Mark Absent'),
                                ),
                              ],
                            )
                          : Switch(
                              value: !isAbsent,
                              activeColor: Colors.green,
                              onChanged: (_) {
                                context.read<AttendanceBloc>().add(
                                      AttendanceToggleStudent(studentId: student.id),
                                    );
                              },
                            ),
                    );
                  },
                ),
        ),

        // Save button (only if no existing attendance)
        if (!hasExistingAttendance && students.isNotEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  context.read<AttendanceBloc>().add(const AttendanceSave());
                },
                icon: const Icon(Icons.save),
                label: const Text('Save Attendance'),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String label,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context, DateTime currentDate) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: currentDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (picked != null && context.mounted) {
      context.read<AttendanceBloc>().add(AttendanceSelectDate(date: picked));
    }
  }
}