import 'package:flutter/material.dart';
import '../database/db_helper.dart';
import '../models/task.dart';

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  late Stream<List<Task>> _tasksStream;
  final TextEditingController _editController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tasksStream = _dbHelper.tasksStream;
    _dbHelper.refreshData();
  }

  Future<void> _showEditDialog(Task task) async {
    _editController.text = task.title;
    
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Tarefa'),
        content: TextField(
          controller: _editController,
          autofocus: true,
          decoration: const InputDecoration(
            hintText: 'Digite o novo texto',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (_editController.text.isNotEmpty) {
                await _dbHelper.update(
                  task.copyWith(title: _editController.text)
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Task>>(
      stream: _tasksStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Erro: ${snapshot.error}'));
        if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: snapshot.data!.length,
          itemBuilder: (context, index) {
            final task = snapshot.data![index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.symmetric(vertical: 4),
              child: ListTile(
                leading: Checkbox(
                  value: task.isDone,
                  onChanged: (value) async {
                    await _dbHelper.update(task.copyWith(isDone: value!));
                  },
                ),
                title: GestureDetector(
                  onTap: () => _showEditDialog(task),
                  child: Text(
                    task.title,
                    style: TextStyle(
                      decoration: task.isDone 
                          ? TextDecoration.lineThrough 
                          : TextDecoration.none,
                      color: task.isDone ? Colors.grey : Colors.black,
                    ),
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () async {
                    await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Confirmar exclusão'),
                        content: Text('Excluir "${task.title}"?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Cancelar'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              _dbHelper.delete(task.id!);
                            },
                            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }
}