import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/whiteboard_toolbar.dart';
import '../widgets/whiteboard_canvas.dart';

/// Provider for canvas key
final canvasKeyProvider = Provider<GlobalKey>((ref) {
  return GlobalKey();
});

/// Main whiteboard screen
class WhiteboardScreen extends ConsumerStatefulWidget {
  const WhiteboardScreen({super.key});

  @override
  ConsumerState<WhiteboardScreen> createState() => _WhiteboardScreenState();
}

class _WhiteboardScreenState extends ConsumerState<WhiteboardScreen> {
  @override
  void initState() {
    super.initState();
    // Set landscape orientation for IFP
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Set full screen mode for better IFP experience
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
  }

  @override
  void dispose() {
    // Reset orientation when leaving
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Reset system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final canvasKey = ref.watch(canvasKeyProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // Toolbar at the top
          WhiteboardToolbar(canvasKey: canvasKey),

          // Canvas taking remaining space
          Expanded(child: WhiteboardCanvas(key: canvasKey)),
        ],
      ),
    );
  }
}
