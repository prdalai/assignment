# 🖍 IFP Whiteboard Application

A comprehensive whiteboard application designed specifically for Android-based Interactive Flat Panels (IFPs) used in educational environments. Built with Flutter and Riverpod for optimal performance on large touch screens.

## 🎯 Features

### ✏️ Drawing Tools
- **Freehand Drawing**: Smooth pen strokes with customizable color and width
- **Eraser**: Pixel-based erasing with real-time feedback
- **Multiple Stroke Widths**: Thin, Medium, Thick options (1px, 3px, 6px, 12px)
- **Color Palette**: 8 predefined colors (Black, Red, Blue, Green, Yellow, Purple, Orange, Pink)

### 🔺 Shape Tools
- **Rectangle**: Draw rectangles by dragging
- **Circle**: Draw circles and ellipses
- **Line**: Draw straight lines
- **Polygon**: Custom polygons with 3-8 sides
- **Real-time Preview**: See shapes as you draw

### 🔠 Text Tools
- **Text Insertion**: Tap to add text boxes
- **Text Editing**: In-place text editing with dialog
- **Font Size Control**: Adjustable text size
- **Color Customization**: Text color selection

### 💾 File Management
- **Local Storage**: All files saved locally using `path_provider`
- **JSON Format**: Structured data storage for easy parsing
- **Auto-naming**: Files named with timestamp (e.g., `whiteboard_20241201_143022.json`)
- **Load/Save**: Complete whiteboard state preservation

### 🔄 History Management
- **Undo/Redo**: Full undo/redo functionality
- **State Preservation**: Maintains drawing history
- **Memory Efficient**: Optimized for large drawings

### 🎨 UI/UX Features
- **Landscape Orientation**: Optimized for IFP screens
- **Large Touch Targets**: Designed for finger and stylus input
- **Responsive Design**: Scales to different screen sizes
- **Intuitive Interface**: Clean, modern toolbar design

## 🏗️ Architecture

### Project Structure
```
lib/
├── models/
│   ├── stroke.dart          # Stroke data model
│   ├── shape.dart           # Shape data model
│   ├── text_element.dart    # Text element model
│   └── whiteboard_state.dart # Main state model
├── services/
│   ├── storage_service.dart # File I/O operations
│   └── whiteboard_provider.dart # Riverpod providers
├── widgets/
│   ├── whiteboard_canvas.dart # Drawing canvas
│   └── whiteboard_toolbar.dart # Tool controls
├── screens/
│   └── whiteboard_screen.dart # Main screen
└── main.dart               # App entry point
```

### State Management
- **Riverpod**: Modern state management solution
- **Immutable State**: All state changes create new objects
- **Provider Pattern**: Clean separation of concerns
- **Reactive UI**: Automatic UI updates on state changes

### Data Models

#### Stroke Model
```dart
class Stroke {
  final List<Offset> points;
  final Color color;
  final double width;
}
```

#### Shape Model
```dart
class Shape {
  final String id;
  final ShapeType type;
  final Offset topLeft;
  final Offset bottomRight;
  final Color color;
  final double strokeWidth;
  final int? polygonSides;
}
```

#### Text Element Model
```dart
class TextElement {
  final String id;
  final String text;
  final Offset position;
  final Color color;
  final double fontSize;
}
```

### JSON Schema
```json
{
  "strokes": [
    {
      "points": [[10, 10], [15, 20], [20, 30]],
      "color": 4278190080,
      "width": 3.0
    }
  ],
  "shapes": [
    {
      "id": "1234567890",
      "type": "rectangle",
      "topLeft": [50, 50],
      "bottomRight": [150, 100],
      "color": 4278190335,
      "strokeWidth": 2.0
    }
  ],
  "texts": [
    {
      "id": "1234567891",
      "text": "Hello IFP!",
      "position": [300, 400],
      "color": 4278190080,
      "fontSize": 24.0
    }
  ]
}
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.7.2 or higher)
- Android Studio / VS Code
- Android device or emulator

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd assignment
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the application**
   ```bash
   flutter run
   ```

### Building for IFP

1. **Android APK**
   ```bash
   flutter build apk --release
   ```

2. **Install on IFP**
   - Transfer APK to IFP device
   - Install via file manager or ADB
   - Grant necessary permissions

## 📱 IFP Optimization

### Screen Considerations
- **Large Screens**: Optimized for 65", 75", 85" displays
- **Touch Interface**: Large touch targets for easy interaction
- **Landscape Mode**: Default orientation for better workspace
- **High DPI**: Supports high-resolution displays

### Performance Features
- **CustomPainter**: Efficient rendering using Flutter Canvas API
- **RepaintBoundary**: Optimized repainting for smooth performance
- **Memory Management**: Efficient state handling for large drawings
- **Gesture Handling**: Optimized for touch and stylus input

### File Storage
- **Local Storage**: All files stored in app documents directory
- **No Internet Required**: Fully offline functionality
- **Structured Data**: JSON format for easy data management
- **Timestamp Naming**: Automatic file organization

## 🛠️ Usage Guide

### Drawing
1. Select **Pen** tool from toolbar
2. Choose color and stroke width
3. Draw on canvas with finger or stylus

### Erasing
1. Select **Eraser** tool
2. Touch and drag over elements to erase
3. Supports both pixel-based and selection-based erasing

### Shapes
1. Select **Shape** tool
2. Choose shape type (Rectangle, Circle, Line, Polygon)
3. For polygons, select number of sides
4. Drag on canvas to draw shape

### Text
1. Select **Text** tool
2. Tap on canvas to add text
3. Edit text in dialog that appears
4. Text can be moved and edited later

### File Operations
1. **Save**: Click save button to save current state
2. **Load**: Click load button to browse and load saved files
3. **Clear**: Click clear button to start fresh
4. **Undo/Redo**: Use undo/redo buttons for history navigation

## 🔧 Technical Details

### Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.5.1    # State management
  path_provider: ^2.1.4       # File storage
  flutter_colorpicker: ^1.0.3 # Color selection
  image: ^4.1.7              # Image export
  permission_handler: ^11.3.1 # Permissions
```

### Key Components

#### CustomPainter
- Efficient rendering of strokes, shapes, and text
- Smooth curve interpolation
- Real-time drawing feedback

#### Gesture Detection
- Multi-touch support
- Pan gesture handling
- Tap detection for text insertion

#### State Management
- Immutable state updates
- Undo/redo stack management
- Provider-based state distribution

## 🎯 Future Enhancements

### Planned Features
- **Image Export**: Export whiteboard as PNG/JPG
- **Zoom & Pan**: Interactive canvas navigation
- **Layer Management**: Multiple drawing layers
- **Collaboration**: Real-time multi-user support
- **Templates**: Pre-designed whiteboard templates
- **Audio Recording**: Voice notes integration

### Performance Optimizations
- **Canvas Caching**: Improved rendering performance
- **Memory Optimization**: Better large drawing handling
- **Gesture Optimization**: Enhanced touch responsiveness

## 📄 License

This project is developed as an assignment for educational purposes.

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📞 Support

For technical support or questions about the IFP whiteboard application, please refer to the project documentation or create an issue in the repository.

---

**Built with ❤️ for Interactive Flat Panels**
