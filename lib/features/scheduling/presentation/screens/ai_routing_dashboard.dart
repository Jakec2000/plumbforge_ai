import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/services/routing_engine.dart';

class AiRoutingDashboard extends ConsumerStatefulWidget {
  const AiRoutingDashboard({super.key});

  @override
  ConsumerState<AiRoutingDashboard> createState() => _AiRoutingDashboardState();
}

class _AiRoutingDashboardState extends ConsumerState<AiRoutingDashboard> {
  List<RoutingJob> _jobs = [];
  bool _isOptimizing = false;

  @override
  void initState() {
    super.initState();
    _jobs = ref.read(routingEngineProvider).getMockJobs();
  }

  void _optimizeRoute() async {
    setState(() => _isOptimizing = true);
    final engine = ref.read(routingEngineProvider);
    final optimized = await engine.optimizeDailyRoute(_jobs);
    if (mounted) {
      setState(() {
        _jobs = optimized;
        _isOptimizing = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Route optimized! Saved 14km of driving.'),
        backgroundColor: Colors.green,
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          color: Theme.of(context).colorScheme.primaryContainer,
          child: Row(
            children: [
              const Icon(Icons.map, size: 32),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Today's Jobs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    Text('3 Jobs • 45km Total driving'),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _isOptimizing ? null : _optimizeRoute,
                icon: _isOptimizing 
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator()) 
                  : const Icon(Icons.route),
                label: const Text('AI Optimize'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _jobs.length,
            itemBuilder: (context, index) {
              final job = _jobs[index];
              return ListTile(
                leading: CircleAvatar(child: Text('\${index + 1}')),
                title: Text(job.customer),
                subtitle: Text(job.address),
                trailing: const Icon(Icons.navigation),
              );
            },
          ),
        ),
      ],
    );
  }
}
