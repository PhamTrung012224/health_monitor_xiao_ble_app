import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:user_repository/user_repository.dart';
import 'package:fl_chart/fl_chart.dart';

class StepHistoricalScreen extends StatefulWidget {
  const StepHistoricalScreen({super.key});

  @override
  State<StepHistoricalScreen> createState() => _StepHistoricalScreenState();
}

class _StepHistoricalScreenState extends State<StepHistoricalScreen> {
  final UserRepository _userRepository = FirebaseUserRepository();
  List<StepEntry> _stepHistory = [];
  bool _isLoading = true;
  String _errorMessage = '';
  int _stepGoal = 10000; // Default step goal
  final _goalController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Please login to view your step history';
        });
        return;
      }

      // Load user data to get step goal
      final userData = await _userRepository.getUserData(currentUser.uid);

      // Load step history
      final stepHistory = await _userRepository.getStepHistory(currentUser.uid);
      stepHistory.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        _stepHistory = stepHistory;
        _stepGoal = userData.stepGoal;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading step history: $e';
      });
    }
  }

  void _showGoalSettingDialog() {
    _goalController.text = _stepGoal.toString();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Set Daily Step Goal'),
        content: TextField(
          controller: _goalController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Steps',
            hintText: 'Enter your daily step goal',
          ),
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('CANCEL'),
          ),
          ElevatedButton(
            onPressed: () async {
              // Validate and save the new goal
              final newGoal = int.tryParse(_goalController.text) ?? 10000;
              if (newGoal > 0) {
                final currentUser = FirebaseAuth.instance.currentUser;
                if (currentUser != null) {
                  await _userRepository.updateStepGoal(
                      currentUser.uid, newGoal);
                  setState(() {
                    _stepGoal = newGoal;
                  });
                }
              }
              Navigator.pop(context);
            },
            child: const Text('SAVE'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Step History'),
        centerTitle: true,
        leading: GestureDetector(
            onTap: () {
              context.go('/');
            },
            child: const Icon(
              Icons.arrow_back,
              size: 32,
            )),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage.isNotEmpty
              ? Center(child: Text(_errorMessage))
              : _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_stepHistory.isEmpty) {
      return const Center(child: Text('No step history available'));
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Today's stats
          _buildTodayCard(),

          // Chart
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Last 50 Days Activity',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: _buildBarChart(),
                ),
              ],
            ),
          ),

          // History list
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Daily History',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount:
                      _stepHistory.length > 50 ? 50 : _stepHistory.length,
                  itemBuilder: (context, index) {
                    final entry = _stepHistory[index];
                    return _buildHistoryItem(entry);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTodayCard() {
    // Find today's entry
    final today = DateTime.now();
    final todayEntry = _stepHistory.firstWhere(
      (entry) =>
          entry.date.year == today.year &&
          entry.date.month == today.month &&
          entry.date.day == today.day,
      orElse: () => StepEntry(date: today, steps: 0),
    );

    final progressPercent = (todayEntry.steps / _stepGoal).clamp(0.0, 1.0);

    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Row(
                  children: [
                    Icon(Icons.calendar_today, color: Color(0xFF015164)),
                    SizedBox(width: 8),
                    Text(
                      'Today',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                // Add goal edit button
                IconButton(
                  icon:
                      const Icon(Icons.edit_outlined, color: Color(0xFF015164)),
                  onPressed: _showGoalSettingDialog,
                  tooltip: 'Edit daily step goal',
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 100,
                      height: 100,
                      child: CircularProgressIndicator(
                        value: progressPercent,
                        strokeWidth: 10,
                        backgroundColor: Colors.grey[100],
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _getColorForProgress(progressPercent)),
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${(progressPercent * 100).toInt()}%',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          'of goal',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${todayEntry.steps}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF015164),
                        ),
                      ),
                      const Text(
                        'steps',
                        style: TextStyle(
                          fontSize: 18,
                          color: Color(0xFF015164),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Goal: $_stepGoal steps',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${_stepGoal - todayEntry.steps} steps to go',
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // The rest of your methods remain largely the same, but update references to the goal
  Widget _buildBarChart() {
    // Get last 50 days for chart
    final chartData = _getLast50DaysData();
    final maxSteps = _getMaxSteps(chartData);

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.center,
        maxY: maxSteps * 1.2, // Add 20% margin
        minY: 0,
        groupsSpace: 8,
        barTouchData: BarTouchData(
          enabled: true,
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: Colors.white.withOpacity(0.8),
            tooltipMargin: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final entry = chartData[group.x.toInt()];
              return BarTooltipItem(
                '${DateFormat('MMM d').format(entry.date)}\n${entry.steps} steps',
                const TextStyle(
                    color: Color(0xFF015164), fontWeight: FontWeight.bold),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 30,
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= chartData.length) {
                  return const SizedBox();
                }

                if (index % 5 == 0 ||
                    index == 0 ||
                    index == chartData.length - 1) {
                  return Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Transform.rotate(
                      angle: -0.5,
                      child: Text(
                        DateFormat('MM/dd').format(chartData[index].date),
                        style: const TextStyle(fontSize: 10),
                      ),
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 40,
              interval: 2500,
              getTitlesWidget: (value, meta) {
                return Text(
                  '${value.toInt()}',
                  style: const TextStyle(fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
            left: BorderSide(color: Colors.grey.withOpacity(0.5), width: 1),
          ),
        ),
        gridData: FlGridData(
          show: true,
          horizontalInterval: 2500,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: Colors.grey.withOpacity(0.3),
              strokeWidth: 1,
            );
          },
          drawVerticalLine: false,
        ),
        barGroups: List.generate(chartData.length, (index) {
          final steps = chartData[index].steps.toDouble();
          final color = _getColorForSteps(chartData[index].steps);
          return BarChartGroupData(
            x: index,
            barRods: [
              BarChartRodData(
                toY: steps,
                color: color,
                width: chartData.length > 30 ? 6 : 8,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(4),
                  topRight: Radius.circular(4),
                ),
              ),
            ],
            barsSpace: 4, // Add space between bars
          );
        }),
      ),
    );
  }

  Widget _buildHistoryItem(StepEntry entry) {
    final dateFormat = DateFormat.yMMMd();
    final isToday = _isToday(entry.date);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isToday ? const Color(0xFF015164) : Colors.grey[300],
          ),
          child: Icon(
            Icons.directions_walk,
            color: isToday ? Colors.white : Colors.black54,
            size: 28,
          ),
        ),
        title: Text(
          dateFormat.format(entry.date),
          style: TextStyle(
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
            fontSize: 16,
          ),
        ),
        subtitle: LinearProgressIndicator(
          value: (entry.steps / _stepGoal).clamp(0.0, 1.0), // Use dynamic goal
          backgroundColor: Colors.grey[200],
          valueColor:
              AlwaysStoppedAnimation<Color>(_getColorForSteps(entry.steps)),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '${entry.steps}',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: _getColorForSteps(entry.steps),
              ),
            ),
            Text(
              'steps',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Helper methods
  List<StepEntry> _getLast50DaysData() {
    final result = <StepEntry>[];
    final now = DateTime.now();

    // Take up to 50 most recent entries
    final int days = _stepHistory.length > 50 ? 50 : _stepHistory.length;

    for (int i = 0; i < days; i++) {
      result.add(_stepHistory[i]);
    }

    // Sort by date (oldest to newest for the chart)
    result.sort((a, b) => a.date.compareTo(b.date));

    return result;
  }

  double _getMaxSteps(List<StepEntry> entries) {
    if (entries.isEmpty) return _stepGoal.toDouble(); // Use dynamic goal
    int max = entries.fold(
        0, (prev, entry) => entry.steps > prev ? entry.steps : prev);
    return max > 0 ? max.toDouble() : _stepGoal.toDouble(); // Use dynamic goal
  }

  bool _isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  Color _getColorForSteps(int steps) {
    double percentage = steps / _stepGoal; // Use dynamic goal
    if (percentage >= 1.0) return Colors.green;
    if (percentage >= 0.75) return Color.fromARGB(255, 221, 221, 79);
    if (percentage >= 0.5) return Colors.orange;
    return Colors.red;
  }

  Color _getColorForProgress(double progress) {
    if (progress >= 1.0) return Colors.green;
    if (progress >= 0.75) return Color.fromARGB(255, 221, 221, 79);
    if (progress >= 0.5) return Colors.orange;
    return Colors.red;
  }
}
