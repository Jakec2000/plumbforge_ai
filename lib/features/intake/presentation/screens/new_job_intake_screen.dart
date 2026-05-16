import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../ai_takeoff/data/services/gemini_service.dart';
import '../../../ai_takeoff/domain/models/takeoff_result.dart';
import '../../../pricing/domain/services/pricing_engine.dart';
import '../../../historical_learning/domain/services/historical_engine.dart';
import '../../../field_mode/providers/field_mode_provider.dart';
import '../../../pricing/data/services/supplier_api_service.dart';

class NewJobIntakeScreen extends ConsumerStatefulWidget {
  const NewJobIntakeScreen({super.key});

  @override
  ConsumerState<NewJobIntakeScreen> createState() => _NewJobIntakeScreenState();
}

class _NewJobIntakeScreenState extends ConsumerState<NewJobIntakeScreen> {
  bool _isRecording = false;
  bool _isProcessing = false;
  String? _capturedPhotoPath;
  String _mockTranscript = "Customer needs the vanity replaced and wants the toilet moved. Existing drain is 100mm.";
  TakeoffResult? _result;

  Future<void> _processTakeoff() async {
    setState(() => _isProcessing = true);
    
    try {
      final geminiService = ref.read(geminiServiceProvider);
      // In a real device, we load the bytes from _capturedPhotoPath
      // Uint8List imageBytes = await File(_capturedPhotoPath!).readAsBytes();
      Uint8List dummyImageBytes = Uint8List.fromList([0]); 
      
      final result = await geminiService.analyzeJobSite(dummyImageBytes, _mockTranscript);
      
      final historicalEngine = ref.read(historicalEngineProvider);
      final insight = historicalEngine.analyzeForTrends(result);
      
      setState(() => _result = result);

      if (insight.hasTrend && mounted) {
        bool acceptInsight = await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: Row(
              children: [
                Icon(Icons.lightbulb, color: Theme.of(context).colorScheme.error),
                const SizedBox(width: 8),
                const Expanded(child: Text('AI Historical Suggestion')),
              ],
            ),
            content: Text(insight.reason),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Reject'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Accept & Add Buffer'),
              ),
            ],
          ),
        ) ?? false;
        
        final pricingEngine = ref.read(pricingEngineProvider);
        final supplier = ref.read(supplierApiProvider);
        final summary = await pricingEngine.generateQuote(result, supplier, insight: acceptInsight ? insight : null);
        
        if (mounted) {
          context.pushNamed('quote-preview', extra: {
            'summary': summary,
            'result': result,
          });
        }
      } else {
        final pricingEngine = ref.read(pricingEngineProvider);
        final supplier = ref.read(supplierApiProvider);
        final summary = await pricingEngine.generateQuote(result, supplier);
        
        if (mounted) {
          context.pushNamed('quote-preview', extra: {
            'summary': summary,
            'result': result,
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: \$e')));
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isFieldMode = ref.watch(fieldModeProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: Text(isFieldMode ? 'FIELD MODE - NEW JOB' : 'New Job Intake'),
        backgroundColor: isFieldMode ? theme.colorScheme.error : Colors.transparent,
        foregroundColor: isFieldMode ? Colors.white : theme.colorScheme.primary,
        elevation: isFieldMode ? 4 : 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: () async {
                final photoPath = await context.pushNamed<String>('ar-camera');
                if (photoPath != null) {
                  setState(() => _capturedPhotoPath = photoPath);
                }
              },
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: _capturedPhotoPath != null ? theme.colorScheme.secondary.withOpacity(0.1) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: _capturedPhotoPath != null ? theme.colorScheme.secondary : Colors.grey[300]!, 
                    width: 2,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      _capturedPhotoPath != null ? Icons.check_circle : Icons.add_a_photo, 
                      size: 48, 
                      color: _capturedPhotoPath != null ? theme.colorScheme.secondary : Colors.grey[500],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _capturedPhotoPath != null ? 'Photo Captured with AR Markup' : 'Tap to Open AR Camera', 
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: _capturedPhotoPath != null ? theme.colorScheme.secondary : Colors.grey[600]
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            
            Text('Voice Note', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTapDown: (_) => setState(() => _isRecording = true),
              onTapUp: (_) => setState(() => _isRecording = false),
              onTapCancel: () => setState(() => _isRecording = false),
              child: Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _isRecording ? theme.colorScheme.error : theme.colorScheme.primary,
                  boxShadow: [
                    if (_isRecording)
                      BoxShadow(color: theme.colorScheme.error.withOpacity(0.4), blurRadius: 20, spreadRadius: 5)
                  ],
                ),
                child: Icon(_isRecording ? Icons.mic : Icons.mic_none, size: 48, color: Colors.white),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _isRecording ? 'Recording... Release to stop' : (isFieldMode ? 'AUTO-PILOT ACTIVE: SPEAK NOW' : 'Hold to describe job & client details'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: isFieldMode ? FontWeight.bold : FontWeight.normal,
                color: isFieldMode ? theme.colorScheme.error : null,
              ),
            ),
            
            const SizedBox(height: 48),
            ElevatedButton(
              onPressed: _isProcessing ? null : _processTakeoff,
              child: _isProcessing 
                  ? const CircularProgressIndicator(color: Colors.white) 
                  : const Text('Generate Quote & Compliance Report'),
            ),
            
            if (_result != null) ...[
              const SizedBox(height: 40),
              Text('AI Takeoff Results', style: theme.textTheme.displayLarge),
              const Divider(),
              Text('Fixtures: \${_result!.detectedFixtures.join(", ")}'),
              const SizedBox(height: 8),
              Text('Compliance Flags:', style: TextStyle(color: theme.colorScheme.error, fontWeight: FontWeight.bold)),
              ..._result!.complianceFlags.map((flag) => Text('• \$flag')),
              const SizedBox(height: 8),
              Text('Recommendation: \${_result!.recommendedSolution}'),
            ]
          ],
        ),
      ),
    );
  }
}
