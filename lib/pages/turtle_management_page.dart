import 'package:flutter/material.dart';
import '../models/turtle.dart';
import '../services/turtle_management_service.dart';
import 'add_turtle_page.dart';

class TurtleManagementPage extends StatefulWidget {
  const TurtleManagementPage({Key? key}) : super(key: key);

  @override
  State<TurtleManagementPage> createState() => _TurtleManagementPageState();
}

class _TurtleManagementPageState extends State<TurtleManagementPage> {
  List<Turtle> _turtles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTurtles();
  }

  Future<void> _loadTurtles() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final turtles = await TurtleManagementService.getTurtles();
      setState(() {
        _turtles = turtles;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载乌龟列表失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade50,
      appBar: AppBar(
        title: const Text(
          '乌龟管理',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.green.shade600,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '正在加载乌龟列表...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : _turtles.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.pets,
                        size: 80,
                        color: Colors.green.shade300,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '还没有添加乌龟\n点击右下角按钮添加第一只乌龟',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _turtles.length,
                  itemBuilder: (context, index) {
                    final turtle = _turtles[index];
                    return _buildTurtleCard(turtle);
                  },
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddTurtlePage(
                onSaved: _loadTurtles,
              ),
            ),
          );
        },
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          '添加乌龟',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 8,
      ),
    );
  }

  Widget _buildTurtleCard(Turtle turtle) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.white,
              turtle.color.withOpacity(0.1),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          turtle.color.withOpacity(0.7),
                          turtle.color,
                        ],
                      ),
                    ),
                    child: const Icon(
                      Icons.pets,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          turtle.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          turtle.species,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  PopupMenuButton<String>(
                    onSelected: (value) {
                      if (value == 'edit') {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AddTurtlePage(
                              turtleToEdit: turtle,
                              onSaved: _loadTurtles,
                            ),
                          ),
                        );
                      } else if (value == 'delete') {
                        _showDeleteDialog(turtle);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit, size: 20),
                            SizedBox(width: 8),
                            Text('编辑'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete, size: 20, color: Colors.red),
                            SizedBox(width: 8),
                            Text('删除', style: TextStyle(color: Colors.red)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildInfoChip(
                    Icons.cake,
                    '年龄: ${turtle.ageDescription}',
                    Colors.orange,
                  ),
                  const SizedBox(width: 12),
                  _buildInfoChip(
                    Icons.date_range,
                    '出生: ${turtle.birthDate.month}/${turtle.birthDate.day}',
                    Colors.blue,
                  ),
                ],
              ),
              if (turtle.description != null && turtle.description!.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  turtle.description!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade700,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Turtle turtle) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('删除乌龟'),
          content: Text('确定要删除 "${turtle.name}" 吗？删除后无法恢复，相关的所有记录也会被删除。'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                await TurtleManagementService.deleteTurtle(turtle.id);
                _loadTurtles();
                Navigator.pop(context);
              },
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
              ),
              child: const Text('删除'),
            ),
          ],
        );
      },
    );
  }
}
