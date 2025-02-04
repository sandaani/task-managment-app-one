import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart'; // Add this package to pubspec.yaml
import '../providers/task_provider.dart';

class AnalyticsDashboard extends StatelessWidget {
  const AnalyticsDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Analytics'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Task Overview Card
            _buildOverviewCard(context),
            const SizedBox(height: 20),

            // Task Completion Trend
            _buildCompletionTrendChart(context),
            const SizedBox(height: 20),

            // Category Distribution
            _buildCategoryDistribution(context),
            const SizedBox(height: 20),

            // Task Status Breakdown
            _buildStatusBreakdown(context),
            const SizedBox(height: 20),

            // Productivity Score
            _buildProductivityScore(context),
            const SizedBox(height: 20),

            // Due Date Analysis
            _buildDueDateAnalysis(context),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final totalTasks = taskProvider.tasks.length;
        final completedTasks =
            taskProvider.tasks.where((t) => t.isCompleted).length;
        final upcomingTasks =
            taskProvider.tasks.where((t) => !t.isCompleted).length;
        final overdueTasks = taskProvider.tasks
            .where((t) => !t.isCompleted && t.endTime.isBefore(DateTime.now()))
            .length;

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Overview',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStatItem('Total', totalTasks, Colors.blue),
                    _buildStatItem('Completed', completedTasks, Colors.green),
                    _buildStatItem('Upcoming', upcomingTasks, Colors.orange),
                    _buildStatItem('Overdue', overdueTasks, Colors.red),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCompletionTrendChart(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final completionData = taskProvider.getCompletionTrendData();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Completion Trend',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      gridData: const FlGridData(show: true),
                      titlesData: const FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 22,
                          ),
                        ),
                      ),
                      borderData: const FlBorderData(show: true),
                      lineBarsData: [
                        LineChartBarData(
                          spots: completionData,
                          isCurved: true,
                          color: Colors.blue,
                          barWidth: 4,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryDistribution(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final categoryProgress = taskProvider.categoryProgress;
        final sections = categoryProgress.entries.map((entry) {
          final progress = entry.value;
          return PieChartSectionData(
            color: _getCategoryColor(entry.key),
            value: progress.totalTasks.toDouble(),
            title: '${entry.key}\n${progress.totalTasks}',
            radius: 100,
            titleStyle: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          );
        }).toList();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Category Distribution',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 200,
                  child: PieChart(
                    PieChartData(
                      sections: sections,
                      sectionsSpace: 2,
                      centerSpaceRadius: 0,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getCategoryColor(String category) {
    final colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
    ];

    return colors[category.hashCode % colors.length];
  }

  Widget _buildProductivityScore(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final score = taskProvider.calculateProductivityScore();

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Productivity Score',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        height: 150,
                        width: 150,
                        child: CircularProgressIndicator(
                          value: score / 100,
                          strokeWidth: 12,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            _getScoreColor(score),
                          ),
                        ),
                      ),
                      Text(
                        '${score.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 80) return Colors.green;
    if (score >= 60) return Colors.orange;
    return Colors.red;
  }

  Widget _buildStatItem(String label, int value, Color color) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            value.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBreakdown(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final tasks = taskProvider.tasks;
        final statusMap = {
          'completed': tasks.where((t) => t.isCompleted).length,
          'in progress': tasks
              .where((t) =>
                  !t.isCompleted &&
                  t.startTime.isBefore(DateTime.now()) &&
                  t.endTime.isAfter(DateTime.now()))
              .length,
          'upcoming': tasks
              .where(
                  (t) => !t.isCompleted && t.startTime.isAfter(DateTime.now()))
              .length,
          'overdue': tasks
              .where(
                  (t) => !t.isCompleted && t.endTime.isBefore(DateTime.now()))
              .length,
        };

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Task Status Breakdown',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...statusMap.entries
                    .map((entry) => Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 12,
                                    height: 12,
                                    decoration: BoxDecoration(
                                      color: _getStatusColor(entry.key),
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    entry.key.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text('${entry.value}'),
                                ],
                              ),
                              const SizedBox(height: 4),
                              LinearProgressIndicator(
                                value: tasks.isEmpty
                                    ? 0
                                    : entry.value / tasks.length,
                                backgroundColor: Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getStatusColor(entry.key),
                                ),
                              ),
                            ],
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDueDateAnalysis(BuildContext context) {
    return Consumer<TaskProvider>(
      builder: (context, taskProvider, _) {
        final tasks = taskProvider.tasks;
        final now = DateTime.now();

        final dueDateMap = {
          'Today': tasks
              .where((t) =>
                  !t.isCompleted &&
                  t.endTime.day == now.day &&
                  t.endTime.month == now.month &&
                  t.endTime.year == now.year)
              .length,
          'Tomorrow': tasks
              .where((t) =>
                  !t.isCompleted && t.endTime.difference(now).inDays == 1)
              .length,
          'This Week': tasks
              .where((t) =>
                  !t.isCompleted &&
                  t.endTime.difference(now).inDays <= 7 &&
                  t.endTime.difference(now).inDays > 1)
              .length,
          'Later': tasks
              .where(
                  (t) => !t.isCompleted && t.endTime.difference(now).inDays > 7)
              .length,
        };

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Due Date Analysis',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ...dueDateMap.entries
                    .map((entry) => ListTile(
                          leading: Icon(
                            _getDueDateIcon(entry.key),
                            color: _getDueDateColor(entry.key),
                          ),
                          title: Text(entry.key),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color:
                                  _getDueDateColor(entry.key).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              entry.value.toString(),
                              style: TextStyle(
                                color: _getDueDateColor(entry.key),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ))
                    .toList(),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getDueDateIcon(String dueDate) {
    switch (dueDate) {
      case 'Today':
        return Icons.today;
      case 'Tomorrow':
        return Icons.event;
      case 'This Week':
        return Icons.date_range;
      case 'Later':
        return Icons.calendar_month;
      default:
        return Icons.event;
    }
  }

  Color _getDueDateColor(String dueDate) {
    switch (dueDate) {
      case 'Today':
        return Colors.red;
      case 'Tomorrow':
        return Colors.orange;
      case 'This Week':
        return Colors.blue;
      case 'Later':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return Colors.green;
      case 'in progress':
        return Colors.blue;
      case 'upcoming':
        return Colors.orange;
      case 'overdue':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
