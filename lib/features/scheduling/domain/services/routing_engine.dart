import 'package:flutter_riverpod/flutter_riverpod.dart';

final routingEngineProvider = Provider<RoutingEngine>((ref) {
  return RoutingEngine();
});

class RoutingJob {
  final String id;
  final String address;
  final double lat;
  final double lng;
  final String customer;

  RoutingJob(this.id, this.address, this.lat, this.lng, this.customer);
}

class RoutingEngine {
  Future<List<RoutingJob>> optimizeDailyRoute(List<RoutingJob> jobs) async {
    // Simulate AI / Google Maps Directions API request to solve the Traveling Salesperson Problem
    await Future.delayed(const Duration(seconds: 2));
    
    // Just reverse the list to simulate a "new" optimized order
    return jobs.reversed.toList();
  }

  List<RoutingJob> getMockJobs() {
    return [
      RoutingJob('1', '123 Fake St, Brisbane', -27.4698, 153.0251, 'John Smith'),
      RoutingJob('2', '45 Plumber Rd, Fortitude Valley', -27.4560, 153.0336, 'Jane Doe'),
      RoutingJob('3', '88 Pipe Ln, South Bank', -27.4786, 153.0210, 'Bob Builder'),
    ];
  }
}
