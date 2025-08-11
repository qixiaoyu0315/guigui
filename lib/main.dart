import 'package:flutter/material.dart';
import 'models/turtle_record.dart';
import 'models/turtle.dart';
import 'services/turtle_service.dart';
import 'services/turtle_management_service.dart';
import 'widgets/turtle_tree.dart';
import 'pages/add_record_page.dart';
import 'pages/turtle_management_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '乌龟生长记录',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.green,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const TurtleGrowthHomePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class TurtleGrowthHomePage extends StatefulWidget {
  const TurtleGrowthHomePage({super.key});

  @override
  State<TurtleGrowthHomePage> createState() => _TurtleGrowthHomePageState();
}

class _TurtleGrowthHomePageState extends State<TurtleGrowthHomePage> {
  List<TurtleRecord> _records = [];
  List<Turtle> _turtles = [];
  List<String> _selectedTurtleIds = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final records = await TurtleService.getRecords();
      final turtles = await TurtleManagementService.getTurtles();
      
      setState(() {
        _records = records;
        _turtles = turtles;
        // 默认选择所有乌龟
        _selectedTurtleIds = turtles.map((turtle) => turtle.id).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('加载数据失败: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Row(
          children: [
            Icon(
              Icons.pets,
              color: Colors.white,
            ),
            SizedBox(width: 8),
            Text(
              '乌龟生长记录',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.manage_accounts,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const TurtleManagementPage(),
                ),
              ).then((_) => _loadData());
            },
            tooltip: '乌龟管理',
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Colors.white,
            ),
            onPressed: _loadData,
            tooltip: '刷新',
          ),
        ],
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
                    '正在加载记录...',
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                // 乌龟选择器
                if (_turtles.isNotEmpty) ...[
                  Container(
                    height: 60,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: _turtles.length,
                      itemBuilder: (context, index) {
                        final turtle = _turtles[index];
                        final isSelected = _selectedTurtleIds.contains(turtle.id);
                        
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: FilterChip(
                            label: Text(turtle.name),
                            selected: isSelected,
                            onSelected: (selected) {
                              setState(() {
                                if (selected) {
                                  _selectedTurtleIds.add(turtle.id);
                                } else {
                                  _selectedTurtleIds.remove(turtle.id);
                                }
                              });
                            },
                            backgroundColor: turtle.color.withOpacity(0.1),
                            selectedColor: turtle.color.withOpacity(0.3),
                            checkmarkColor: turtle.color,
                            labelStyle: TextStyle(
                              color: isSelected ? turtle.color : Colors.grey.shade700,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  const Divider(height: 1),
                ],
                // 时间轴树
                Expanded(
                  child: TurtleTree(
                    records: _records,
                    turtles: _turtles,
                    selectedTurtleIds: _selectedTurtleIds,
                    onRefresh: _loadData,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (_turtles.isEmpty) {
            // 如果没有乌龟，先跳转到乌龟管理页面
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const TurtleManagementPage(),
              ),
            ).then((_) => _loadData());
          } else {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddRecordPage(
                  turtles: _turtles,
                  onSaved: _loadData,
                ),
              ),
            );
          }
        },
        backgroundColor: Colors.green.shade600,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text(
          '添加记录',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 8,
      ),
    );
  }
}
