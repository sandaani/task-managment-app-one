import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/task_provider.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, taskProvider, child) {
          final tasks = taskProvider.tasks;
          
          if (tasks.isEmpty) {
            return const Center(
              child: Text('No tasks to analyze'),
            );
          }

          final completedTasks = tasks.where((task) => task.isCompleted).length;
          final pendingTasks = tasks.length - completedTasks;
          final completionRate = (completedTasks / tasks.length * 100).toStringAsFixed(1);
          final pendingRate = (pendingTasks / tasks.length * 100).toStringAsFixed(1);
          
          final categoryData = <String, int>{};
          for (final task in tasks) {
            categoryData[task.category] = (categoryData[task.category] ?? 0) + 1;
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryCards(completedTasks, pendingTasks, tasks.length),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Task Completion Rate',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Total: ${tasks.length} tasks',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 200,
                        child: PieChart(
                          PieChartData(
                            sections: [
                              PieChartSectionData(
                                value: completedTasks.toDouble(),
                                title: '$completionRate%',
                                color: Colors.green,
                                radius: 100,
                                titleStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                              PieChartSectionData(
                                value: pendingTasks.toDouble(),
                                title: '$pendingRate%',
                                color: Colors.orange,
                                radius: 100,
                                titleStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                            sectionsSpace: 2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildLegendItem(
                          'Completed',
                          completedTasks,
                          '$completionRate%',
                          Colors.green,
                        ),
                        const SizedBox(height: 16),
                        _buildLegendItem(
                          'Pending',
                          pendingTasks,
                          '$pendingRate%',
                          Colors.orange,
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'Tasks by Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: BarChart(
                    BarChartData(
                      alignment: BarChartAlignment.spaceAround,
                      maxY: categoryData.values
                              .reduce((a, b) => a > b ? a : b)
                              .toDouble() +
                          1,
                      titlesData: FlTitlesData(
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              final categories = categoryData.keys.toList();
                              if (value >= 0 && value < categories.length) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    categories[value.toInt()],
                                    style: const TextStyle(fontSize: 10),
                                  ),
                                );
                              }
                              return const SizedBox.shrink();
                            },
                            reservedSize: 42,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 30,
                            interval: 1,
                          ),
                        ),
                        topTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                        rightTitles: const AxisTitles(
                          sideTitles: SideTitles(showTitles: false),
                        ),
                      ),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                      barGroups: List.generate(
                        categoryData.length,
                        (index) => BarChartGroupData(
                          x: index,
                          barRods: [
                            BarChartRodData(
                              toY: categoryData.values.elementAt(index).toDouble(),
                              color: Colors.blue,
                              width: 20,
                              borderRadius: const BorderRadius.vertical(
                                top: Radius.circular(4),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildLegendItem(String title, int count, String percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '$count tasks ($percentage)',
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSummaryCards(int completed, int pending, int total) {
    return Row(
      children: [
        _SummaryCard(
          title: 'Completed',
          count: completed,
          color: Colors.green,
          percentage: (completed / total * 100).toStringAsFixed(1),
        ),
        const SizedBox(width: 16),
        _SummaryCard(
          title: 'Pending',
          count: pending,
          color: Colors.orange,
          percentage: (pending / total * 100).toStringAsFixed(1),
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final String percentage;

  const _SummaryCard({
    required this.title,
    required this.count,
    required this.color,
    required this.percentage,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withOpacity(0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$percentage%',
                  style: TextStyle(
                    fontSize: 16,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
