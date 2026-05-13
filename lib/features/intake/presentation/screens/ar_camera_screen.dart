import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:go_router/go_router.dart';
import '../widgets/ar_overlay_painter.dart';

class ArCameraScreen extends StatefulWidget {
  const ArCameraScreen({super.key});

  @override
  State<ArCameraScreen> createState() => _ArCameraScreenState();
}

class _ArCameraScreenState extends State<ArCameraScreen> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  final List<Offset> _trackedPoints = [];
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _controller = CameraController(
          _cameras!.first,
          ResolutionPreset.max,
          enableAudio: false,
        );
        await _controller!.initialize();
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Error initializing camera: \$e');
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  void _addPoint(TapDownDetails details) {
    setState(() {
      _trackedPoints.add(details.localPosition);
    });
  }

  void _clearPoints() {
    setState(() {
      _trackedPoints.clear();
    });
  }

  Future<void> _captureAndAnalyze() async {
    if (_controller == null || !_controller!.value.isInitialized) return;

    setState(() => _isProcessing = true);

    try {
      final XFile photo = await _controller!.takePicture();
      // In a real app, we would pass 'photo.readAsBytes()' back to the intake screen
      // and trigger the Gemini service. Here we just pop back.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Site photo captured successfully!')),
        );
        context.pop(photo.path);
      }
    } catch (e) {
      debugPrint('Error taking picture: \$e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (_controller == null || !_controller!.value.isInitialized) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Camera Feed
          CameraPreview(_controller!),

          // 2. Interactive AR Overlay
          GestureDetector(
            onTapDown: _addPoint,
            child: Container(
              color: Colors.transparent, // Capture taps
              child: CustomPaint(
                painter: ArOverlayPainter(
                  points: _trackedPoints,
                  overlayColor: theme.colorScheme.secondary,
                ),
              ),
            ),
          ),

          // 3. UI Controls Overlay
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top Bar
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white, size: 32),
                        onPressed: () => context.pop(),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          'Tap to track pipe runs',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.undo, color: Colors.white, size: 32),
                        onPressed: _trackedPoints.isNotEmpty ? () {
                          setState(() => _trackedPoints.removeLast());
                        } : null,
                      ),
                    ],
                  ),
                ),

                // Bottom Bar
                Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white, size: 32),
                        onPressed: _clearPoints,
                      ),
                      GestureDetector(
                        onTap: _isProcessing ? null : _captureAndAnalyze,
                        child: Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 4),
                          ),
                          child: Container(
                            margin: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: _isProcessing ? Colors.grey : Colors.red,
                            ),
                            child: _isProcessing 
                                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                                : null,
                          ),
                        ),
                      ),
                      const SizedBox(width: 48), // Balance for delete icon
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
