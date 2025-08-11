import 'package:flutter/material.dart';
import 'models/turtle_record.dart';
import 'models/turtle.dart';
import 'models/sort_option.dart';
import 'services/turtle_service.dart';
import 'services/turtle_management_service.dart';
import 'services/sort_config_service.dart';
import 'widgets/turtle_tree.dart';
import 'pages/add_record_page.dart';
import 'pages/turtle_management_page.dart';
import 'pages/sort_settings_page.dart';

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
  SortConfig _sortConfig = SortConfig.defaultConfig;
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
      final sortConfig = await SortConfigService.getSortConfig();
      
      setState(() {
        _records = records;
        _turtles = turtles;
        _sortConfig = sortConfig;
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
        title: _turtles.isEmpty
            ? const Row(
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
              )
            : Row(
                children: [
                  const Icon(
                    Icons.pets,
                    color: Colors.white,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: null,
                        hint: Text(
                          _selectedTurtleIds.length == _turtles.length
                              ? '显示所有乌龟 (${_turtles.length})'
                              : '已选择 ${_selectedTurtleIds.length} 只乌龟',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        dropdownColor: Colors.green.shade600,
                        icon: const Icon(
                          Icons.arrow_drop_down,
                          color: Colors.white,
                        ),
                        items: [
                          DropdownMenuItem<String>(
                            value: 'all',
                            child: Row(
                              children: [
                                Icon(
                                  _selectedTurtleIds.length == _turtles.length
                                      ? Icons.check_box
                                      : Icons.check_box_outline_blank,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  '全选/全不选',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                          ),
                          ..._turtles.map((turtle) {
                            final isSelected = _selectedTurtleIds.contains(turtle.id);
                            return DropdownMenuItem<String>(
                              value: turtle.id,
                              child: Row(
                                children: [
                                  Icon(
                                    isSelected ? Icons.check_box : Icons.check_box_outline_blank,
                                    color: turtle.color,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: turtle.color,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      turtle.name,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                        onChanged: (value) {
                          setState(() {
                            if (value == 'all') {
                              if (_selectedTurtleIds.length == _turtles.length) {
                                _selectedTurtleIds.clear();
                              } else {
                                _selectedTurtleIds = _turtles.map((turtle) => turtle.id).toList();
                              }
                            } else if (value != null) {
                              if (_selectedTurtleIds.contains(value)) {
                                _selectedTurtleIds.remove(value);
                              } else {
                                _selectedTurtleIds.add(value);
                              }
                            }
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
        backgroundColor: Colors.green.shade600,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.sort,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SortSettingsPage(
                    currentConfig: _sortConfig,
                    onConfigChanged: (newConfig) async {
                      await SortConfigService.saveSortConfig(newConfig);
                      setState(() {
                        _sortConfig = newConfig;
                      });
                    },
                  ),
                ),
              );
            },
            tooltip: '排序设置',
          ),
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
          : TurtleTree(
              records: _records,
              turtles: _turtles,
              selectedTurtleIds: _selectedTurtleIds,
              sortConfig: _sortConfig,
              onRefresh: _loadData,
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (_turtles.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('请先添加至少一只乌龟'),
                backgroundColor: Colors.orange,
              ),
            );
            return;
          }
          
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddRecordPage(
                turtles: _turtles,
                onSaved: _loadData,
              ),
            ),
          );
        },
        backgroundColor: Colors.green.shade600,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
