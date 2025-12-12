import 'package:flutter/material.dart';
import '../../../../core/network/api_constants.dart';
import '../../../../core/network/dio_client.dart';
import '../../../groups/data/models/group.dart';

class AddToGroupDialog extends StatefulWidget {
  final int studentId;

  const AddToGroupDialog({super.key, required this.studentId});

  @override
  State<AddToGroupDialog> createState() => _AddToGroupDialogState();
}

class _AddToGroupDialogState extends State<AddToGroupDialog> {
  List<Group> _groups = [];
  bool _isLoading = true;
  String? _error;
  int? _selectedGroupId;

  @override
  void initState() {
    super.initState();
    _loadGroups();
  }

  Future<void> _loadGroups() async {
    try {
      final response = await DioClient.instance.get(ApiConstants.groups);
      final list = response.data as List;
      final groups = list.map((json) => Group.fromJson(json)).toList();
      setState(() {
        _groups = groups;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add to Group'),
      content: SizedBox(
        width: double.maxFinite,
        height: 400,
        child: _buildContent(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _selectedGroupId != null
              ? () => Navigator.pop(context, _selectedGroupId)
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(_error!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _isLoading = true;
                  _error = null;
                });
                _loadGroups();
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_groups.isEmpty) {
      return const Center(
        child: Text('No groups available'),
      );
    }

    return ListView.builder(
      itemCount: _groups.length,
      itemBuilder: (context, index) {
        final group = _groups[index];
        final isSelected = _selectedGroupId == group.id;

        return Card(
          color: isSelected
              ? Theme.of(context).colorScheme.primaryContainer
              : null,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Colors.grey[300],
              child: Icon(
                Icons.group,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
            title: Text(
              group.name,
              style: TextStyle(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              'Teacher: ${group.teacherName}\n'
              'Fee: \$${group.monthlyFee.toStringAsFixed(2)}/month',
            ),
            trailing: isSelected
                ? Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
                  )
                : null,
            isThreeLine: true,
            onTap: () {
              setState(() {
                _selectedGroupId = group.id;
              });
            },
          ),
        );
      },
    );
  }
}