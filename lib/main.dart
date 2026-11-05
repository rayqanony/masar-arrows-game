import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );
  runApp(const MasarArrowsApp());
}

class MasarArrowsApp extends StatelessWidget {
  const MasarArrowsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'مسار الأسهم',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'EG'),
      supportedLocales: const [Locale('ar', 'EG'), Locale('en', 'US')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
          primary: const Color(0xFF1976D2),
        ),
      ),
      home: const GameScreen(),
    );
  }
}

/// اتجاه رأس السهم
enum ArrowDir { up, down, left, right }

extension ArrowDirOffset on ArrowDir {
  Point<int> get delta {
    switch (this) {
      case ArrowDir.up:
        return const Point(0, -1);
      case ArrowDir.down:
        return const Point(0, 1);
      case ArrowDir.left:
        return const Point(-1, 0);
      case ArrowDir.right:
        return const Point(1, 0);
    }
  }

  Offset get unitOffset {
    switch (this) {
      case ArrowDir.up:
        return const Offset(0, -1);
      case ArrowDir.down:
        return const Offset(0, 1);
      case ArrowDir.left:
        return const Offset(-1, 0);
      case ArrowDir.right:
        return const Offset(1, 0);
    }
  }
}

/// نقطة على الشبكة (عمود، صف)
class Point<T extends num> {
  final T x;
  final T y;
  const Point(this.x, this.y);

  @override
  bool operator ==(Object other) =>
      other is Point && other.x == x && other.y == y;

  @override
  int get hashCode => Object.hash(x, y);
}

/// نموذج السهم الواحد: يتكون من سلسلة نقاط متتالية على الشبكة من الذيل إلى الرأس
class ArrowItem {
  final String id;
  final List<Point<int>> cells; // من الذيل [0] إلى الرأس [last]
  final ArrowDir headDir;
  bool isCleared;

  ArrowItem({
    required this.id,
    required this.cells,
    required this.headDir,
    this.isCleared = false,
  });

  Point<int> get head => cells.last;

  ArrowItem copy() => ArrowItem(
        id: id,
        cells: List<Point<int>>.from(cells),
        headDir: headDir,
        isCleared: isCleared,
      );
}

/// بيانات المستوى
class LevelConfig {
  final int levelNumber;
  final String difficultyLabel;
  final int gridCols;
  final int gridRows;
  final List<ArrowItem> arrows;

  const LevelConfig({
    required this.levelNumber,
    required this.difficultyLabel,
    required this.gridCols,
    required this.gridRows,
    required this.arrows,
  });
}

/// مستودع أول 10 مستويات مصممة بعناية ومتدرجة الصعوبة وقابلة للحل 100%
class LevelsRepository {
  static List<LevelConfig> getAllLevels() {
    return [
      // المستوى 1: سهل جداً (تعليمي - 4 أسهم ملتفة حول المركز)
      LevelConfig(
        levelNumber: 1,
        difficultyLabel: 'سهل',
        gridCols: 5,
        gridRows: 5,
        arrows: [
          ArrowItem(
            id: 'a1',
            cells: const [Point(1, 2), Point(1, 1), Point(2, 1), Point(3, 1)],
            headDir: ArrowDir.right,
          ),
          ArrowItem(
            id: 'a2',
            cells: const [Point(3, 3), Point(3, 2), Point(2, 2)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'a3',
            cells: const [Point(2, 3), Point(1, 3)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'a4',
            cells: const [Point(2, 4), Point(3, 4), Point(4, 4), Point(4, 3), Point(4, 2)],
            headDir: ArrowDir.up,
          ),
        ],
      ),

      // المستوى 2: عادي (مطابق تماماً للصورة الثانية المرفقة - الحلزون المتداخل)
      LevelConfig(
        levelNumber: 2,
        difficultyLabel: 'عادي',
        gridCols: 6,
        gridRows: 6,
        arrows: [
          ArrowItem(
            id: 'l2_1',
            cells: const [Point(1, 0), Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l2_2',
            cells: const [Point(2, 5), Point(3, 5), Point(4, 5), Point(5, 5), Point(5, 4), Point(5, 3), Point(5, 2), Point(5, 1), Point(5, 0), Point(4, 0), Point(3, 0), Point(2, 0)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'l2_3',
            cells: const [Point(3, 4), Point(4, 4), Point(4, 3), Point(4, 2)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l2_4',
            cells: const [Point(1, 3), Point(1, 2), Point(1, 1), Point(2, 1), Point(3, 1), Point(4, 1)],
            headDir: ArrowDir.right,
          ),
          ArrowItem(
            id: 'l2_5',
            cells: const [Point(2, 4), Point(1, 4)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'l2_6',
            cells: const [Point(3, 3), Point(3, 2), Point(2, 2), Point(2, 3)],
            headDir: ArrowDir.down,
          ),
        ],
      ),

      // المستوى 3: عادي (مطابق للصورة الأولى المرفقة - شبكة متشابكة)
      LevelConfig(
        levelNumber: 3,
        difficultyLabel: 'عادي',
        gridCols: 6,
        gridRows: 6,
        arrows: [
          ArrowItem(
            id: 'l3_1',
            cells: const [Point(0, 0), Point(1, 0), Point(2, 0), Point(2, 1), Point(1, 1), Point(0, 1)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'l3_2',
            cells: const [Point(3, 0), Point(4, 0), Point(5, 0), Point(5, 1), Point(5, 2)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l3_3',
            cells: const [Point(5, 3), Point(5, 4), Point(5, 5), Point(4, 5), Point(3, 5)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'l3_4',
            cells: const [Point(2, 5), Point(1, 5), Point(0, 5), Point(0, 4), Point(0, 3), Point(0, 2)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l3_5',
            cells: const [Point(3, 4), Point(4, 4), Point(4, 3), Point(4, 2), Point(4, 1)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l3_6',
            cells: const [Point(2, 2), Point(3, 2), Point(3, 3)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l3_7',
            cells: const [Point(2, 3), Point(1, 3), Point(1, 2)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l3_8',
            cells: const [Point(1, 4), Point(2, 4)],
            headDir: ArrowDir.right,
          ),
        ],
      ),

      // المستوى 4: عادي (المروحة الرباعية المتداخلة)
      LevelConfig(
        levelNumber: 4,
        difficultyLabel: 'عادي',
        gridCols: 6,
        gridRows: 6,
        arrows: [
          ArrowItem(
            id: 'l4_1',
            cells: const [Point(0, 2), Point(0, 1), Point(0, 0), Point(1, 0), Point(2, 0)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l4_2',
            cells: const [Point(5, 2), Point(5, 1), Point(5, 0), Point(4, 0), Point(3, 0)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'l4_3',
            cells: const [Point(3, 5), Point(4, 5), Point(5, 5), Point(5, 4), Point(5, 3)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l4_4',
            cells: const [Point(0, 3), Point(0, 4), Point(0, 5), Point(1, 5), Point(2, 5)],
            headDir: ArrowDir.right,
          ),
          ArrowItem(
            id: 'l4_5',
            cells: const [Point(1, 2), Point(1, 1), Point(2, 1), Point(3, 1), Point(4, 1)],
            headDir: ArrowDir.right,
          ),
          ArrowItem(
            id: 'l4_6',
            cells: const [Point(4, 2), Point(4, 3), Point(4, 4), Point(3, 4), Point(2, 4), Point(1, 4), Point(1, 3)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l4_7',
            cells: const [Point(2, 2), Point(3, 2), Point(3, 3), Point(2, 3)],
            headDir: ArrowDir.left,
          ),
        ],
      ),

      // المستوى 5: متوسط (بوابة القلعة)
      LevelConfig(
        levelNumber: 5,
        difficultyLabel: 'متوسط',
        gridCols: 6,
        gridRows: 6,
        arrows: [
          ArrowItem(
            id: 'l5_1',
            cells: const [Point(1, 0), Point(2, 0), Point(3, 0), Point(4, 0)],
            headDir: ArrowDir.right,
          ),
          ArrowItem(
            id: 'l5_2',
            cells: const [Point(5, 4), Point(5, 3), Point(5, 2), Point(5, 1), Point(5, 0)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l5_3',
            cells: const [Point(1, 5), Point(2, 5), Point(3, 5), Point(4, 5), Point(5, 5)],
            headDir: ArrowDir.right,
          ),
          ArrowItem(
            id: 'l5_4',
            cells: const [Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l5_5',
            cells: const [Point(2, 1), Point(1, 1), Point(1, 2), Point(1, 3), Point(1, 4)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l5_6',
            cells: const [Point(3, 1), Point(4, 1), Point(4, 2), Point(4, 3), Point(4, 4)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l5_7',
            cells: const [Point(2, 4), Point(2, 3), Point(2, 2)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l5_8',
            cells: const [Point(3, 2), Point(3, 3), Point(3, 4)],
            headDir: ArrowDir.down,
          ),
        ],
      ),

      // المستوى 6: متوسط (المتاهة المتقاطعة 7x7)
      LevelConfig(
        levelNumber: 6,
        difficultyLabel: 'متوسط',
        gridCols: 7,
        gridRows: 7,
        arrows: [
          ArrowItem(
            id: 'l6_1',
            cells: const [Point(2, 0), Point(1, 0), Point(0, 0)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'l6_2',
            cells: const [Point(3, 2), Point(3, 1), Point(3, 0), Point(4, 0), Point(5, 0), Point(6, 0)],
            headDir: ArrowDir.right,
          ),
          ArrowItem(
            id: 'l6_3',
            cells: const [Point(6, 4), Point(6, 3), Point(6, 2), Point(6, 1)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l6_4',
            cells: const [Point(4, 6), Point(5, 6), Point(6, 6), Point(6, 5)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l6_5',
            cells: const [Point(3, 4), Point(3, 5), Point(3, 6), Point(2, 6), Point(1, 6), Point(0, 6)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'l6_6',
            cells: const [Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l6_7',
            cells: const [Point(2, 2), Point(2, 1), Point(1, 1), Point(1, 2), Point(1, 3), Point(1, 4), Point(1, 5)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l6_8',
            cells: const [Point(4, 2), Point(4, 1), Point(5, 1), Point(5, 2), Point(5, 3), Point(5, 4), Point(5, 5)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l6_9',
            cells: const [Point(2, 5), Point(2, 4), Point(2, 3), Point(3, 3), Point(4, 3), Point(4, 4), Point(4, 5)],
            headDir: ArrowDir.down,
          ),
        ],
      ),

      // المستوى 7: متوسط (عقدة السلسلة)
      LevelConfig(
        levelNumber: 7,
        difficultyLabel: 'متوسط',
        gridCols: 7,
        gridRows: 7,
        arrows: [
          ArrowItem(
            id: 'l7_1',
            cells: const [Point(0, 2), Point(0, 1), Point(0, 0), Point(1, 0), Point(2, 0), Point(3, 0)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l7_2',
            cells: const [Point(4, 0), Point(5, 0), Point(6, 0), Point(6, 1), Point(6, 2), Point(6, 3)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l7_3',
            cells: const [Point(6, 4), Point(6, 5), Point(6, 6), Point(5, 6), Point(4, 6), Point(3, 6)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'l7_4',
            cells: const [Point(2, 6), Point(1, 6), Point(0, 6), Point(0, 5), Point(0, 4), Point(0, 3)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l7_5',
            cells: const [Point(1, 3), Point(1, 2), Point(1, 1), Point(2, 1), Point(3, 1), Point(4, 1), Point(5, 1)],
            headDir: ArrowDir.right,
          ),
          ArrowItem(
            id: 'l7_6',
            cells: const [Point(5, 2), Point(5, 3), Point(5, 4), Point(5, 5), Point(4, 5), Point(3, 5), Point(2, 5), Point(1, 5), Point(1, 4)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l7_7',
            cells: const [Point(4, 2), Point(3, 2), Point(2, 2), Point(2, 3), Point(2, 4)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l7_8',
            cells: const [Point(3, 4), Point(4, 4), Point(4, 3), Point(3, 3)],
            headDir: ArrowDir.left,
          ),
        ],
      ),

      // المستوى 8: صعب (الدرع المزدوج)
      LevelConfig(
        levelNumber: 8,
        difficultyLabel: 'صعب',
        gridCols: 7,
        gridRows: 7,
        arrows: [
          ArrowItem(
            id: 'l8_1',
            cells: const [Point(2, 0), Point(1, 0), Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l8_2',
            cells: const [Point(4, 0), Point(5, 0), Point(6, 0), Point(6, 1), Point(6, 2), Point(6, 3)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l8_3',
            cells: const [Point(0, 4), Point(0, 5), Point(0, 6), Point(1, 6), Point(2, 6)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l8_4',
            cells: const [Point(6, 4), Point(6, 5), Point(6, 6), Point(5, 6), Point(4, 6)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l8_5',
            cells: const [Point(3, 2), Point(3, 1), Point(3, 0)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l8_6',
            cells: const [Point(3, 4), Point(3, 5), Point(3, 6)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l8_7',
            cells: const [Point(2, 3), Point(2, 2), Point(2, 1), Point(1, 1), Point(1, 2), Point(1, 3), Point(1, 4), Point(1, 5), Point(2, 5)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l8_8',
            cells: const [Point(4, 3), Point(4, 2), Point(4, 1), Point(5, 1), Point(5, 2), Point(5, 3), Point(5, 4), Point(5, 5), Point(4, 5)],
            headDir: ArrowDir.down,
          ),
        ],
      ),

      // المستوى 9: صعب (المصفوفة المعقدة 8x8)
      LevelConfig(
        levelNumber: 9,
        difficultyLabel: 'صعب',
        gridCols: 8,
        gridRows: 8,
        arrows: [
          ArrowItem(
            id: 'l9_1',
            cells: const [Point(3, 0), Point(2, 0), Point(1, 0), Point(0, 0)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'l9_2',
            cells: const [Point(4, 0), Point(5, 0), Point(6, 0), Point(7, 0)],
            headDir: ArrowDir.right,
          ),
          ArrowItem(
            id: 'l9_3',
            cells: const [Point(0, 4), Point(0, 3), Point(0, 2), Point(0, 1)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l9_4',
            cells: const [Point(7, 4), Point(7, 3), Point(7, 2), Point(7, 1)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l9_5',
            cells: const [Point(0, 5), Point(0, 6), Point(0, 7), Point(1, 7), Point(2, 7), Point(3, 7)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l9_6',
            cells: const [Point(7, 5), Point(7, 6), Point(7, 7), Point(6, 7), Point(5, 7), Point(4, 7)],
            headDir: ArrowDir.left,
          ),
          ArrowItem(
            id: 'l9_7',
            cells: const [Point(3, 1), Point(2, 1), Point(1, 1), Point(1, 2), Point(1, 3), Point(1, 4), Point(1, 5), Point(1, 6)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l9_8',
            cells: const [Point(4, 1), Point(5, 1), Point(6, 1), Point(6, 2), Point(6, 3), Point(6, 4), Point(6, 5), Point(6, 6)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l9_9',
            cells: const [Point(2, 6), Point(3, 6), Point(4, 6), Point(5, 6)],
            headDir: ArrowDir.right,
          ),
          ArrowItem(
            id: 'l9_10',
            cells: const [Point(5, 2), Point(4, 2), Point(3, 2), Point(2, 2), Point(2, 3), Point(2, 4), Point(2, 5)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l9_11',
            cells: const [Point(3, 5), Point(4, 5), Point(5, 5), Point(5, 4), Point(5, 3), Point(4, 3), Point(3, 3), Point(3, 4)],
            headDir: ArrowDir.left,
          ),
        ],
      ),

      // المستوى 10: تحدي الزعيم (الحلزون الملكي الكامل 8x8)
      LevelConfig(
        levelNumber: 10,
        difficultyLabel: 'تحدي خاص',
        gridCols: 8,
        gridRows: 8,
        arrows: [
          ArrowItem(
            id: 'l10_1',
            cells: const [Point(7, 0), Point(6, 0), Point(5, 0), Point(4, 0), Point(3, 0), Point(2, 0), Point(1, 0), Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5), Point(0, 6), Point(0, 7)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l10_2',
            cells: const [Point(1, 7), Point(2, 7), Point(3, 7), Point(4, 7), Point(5, 7), Point(6, 7), Point(7, 7), Point(7, 6), Point(7, 5), Point(7, 4), Point(7, 3), Point(7, 2), Point(7, 1)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l10_3',
            cells: const [Point(6, 1), Point(5, 1), Point(4, 1), Point(3, 1), Point(2, 1), Point(1, 1), Point(1, 2), Point(1, 3), Point(1, 4), Point(1, 5), Point(1, 6)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l10_4',
            cells: const [Point(2, 6), Point(3, 6), Point(4, 6), Point(5, 6), Point(6, 6), Point(6, 5), Point(6, 4), Point(6, 3), Point(6, 2)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l10_5',
            cells: const [Point(5, 2), Point(4, 2), Point(3, 2), Point(2, 2), Point(2, 3), Point(2, 4), Point(2, 5)],
            headDir: ArrowDir.down,
          ),
          ArrowItem(
            id: 'l10_6',
            cells: const [Point(3, 5), Point(4, 5), Point(5, 5), Point(5, 4), Point(5, 3)],
            headDir: ArrowDir.up,
          ),
          ArrowItem(
            id: 'l10_7',
            cells: const [Point(4, 3), Point(3, 3), Point(3, 4), Point(4, 4)],
            headDir: ArrowDir.right,
          ),
        ],
      ),
    ];
  }
}

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with TickerProviderStateMixin {
  late final List<LevelConfig> _allLevels;
  int _currentLevelIndex = 0;

  late List<ArrowItem> _activeArrows;
  int _hearts = 3;
  int _hintsCount = 2;
  bool _rulerEnabled = false;
  String? _hintedArrowId;

  // تحريك السهم عند الخروج (حركة ثعبانية على نفس مساره) أو الاصطدام
  String? _animatingArrowId;
  bool _isBlockedAnimation = false;
  double _BlockedMaxSteps = 0.25;
  late AnimationController _moveController;
  late AnimationController _sunburstController;

  bool _isLevelCompleted = false;
  bool _soundEnabled = true;
  bool _vibrationEnabled = true;
  bool _adsRemoved = false;

  @override
  void initState() {
    super.initState();
    _allLevels = LevelsRepository.getAllLevels();
    _moveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 520),
    )..addListener(() {
        setState(() {});
      });

    _sunburstController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();

    _loadLevel(_currentLevelIndex);
  }

  @override
  void dispose() {
    _moveController.dispose();
    _sunburstController.dispose();
    super.dispose();
  }

  void _loadLevel(int index) {
    final config = _allLevels[index];
    setState(() {
      _currentLevelIndex = index;
      _activeArrows = config.arrows.map((a) => a.copy()).toList();
      _hearts = 3;
      _rulerEnabled = false;
      _hintedArrowId = null;
      _animatingArrowId = null;
      _isBlockedAnimation = false;
      _isLevelCompleted = false;
    });
  }

  LevelConfig get _currentConfig => _allLevels[_currentLevelIndex];

  double get _progressFraction {
    if (_activeArrows.isEmpty) return 0;
    final cleared = _activeArrows.where((a) => a.isCleared).length;
    return cleared / _activeArrows.length;
  }

  /// حساب عدد الخلايا الفارغة أمام رأس السهم قبل الاصطدام (أو -1 إذا كان مفتوحاً للنهاية)
  int _freeCellsAhead(ArrowItem arrow) {
    final occupied = <Point<int>, String>{};
    for (final other in _activeArrows) {
      if (other.isCleared || other.id == arrow.id) continue;
      for (final cell in other.cells) {
        occupied[cell] = other.id;
      }
    }

    final delta = arrow.headDir.delta;
    var checkX = arrow.head.x + delta.x;
    var checkY = arrow.head.y + delta.y;
    int freeSteps = 0;

    while (checkX >= 0 &&
        checkX < _currentConfig.gridCols &&
        checkY >= 0 &&
        checkY < _currentConfig.gridRows) {
      if (occupied.containsKey(Point(checkX, checkY))) {
        return freeSteps;
      }
      freeSteps++;
      checkX += delta.x;
      checkY += delta.y;
    }
    return -1; // مفتوح بالكامل حتى خارج الشاشة
  }

  bool _isArrowFree(ArrowItem arrow) => _freeCellsAhead(arrow) == -1;

  void _onArrowTapped(ArrowItem arrow) {
    if (_animatingArrowId != null || arrow.isCleared || _isLevelCompleted) {
      return;
    }

    final freeSteps = _freeCellsAhead(arrow);
    final free = freeSteps == -1;

    setState(() {
      _animatingArrowId = arrow.id;
      _isBlockedAnimation = !free;
      // إذا كان هناك مسافة صغيرة قبل العائق، يتحرك السهم عبر مساره المتني حتى يلمس العائق ثم يرجع!
      _BlockedMaxSteps = free ? 0.0 : (freeSteps + 0.38);
      if (_hintedArrowId == arrow.id) {
        _hintedArrowId = null;
      }
    });

    if (free) {
      if (_vibrationEnabled) HapticFeedback.lightImpact();
      // سرعة انسيابية متناسبة مع طول السهم لكي نرى الجزء المتني وهو ينفرد ويمشي في مسار الرأس
      final totalCells = arrow.cells.length + _currentConfig.gridCols + 3;
      final durationMs = (totalCells * 36).clamp(380, 720);
      _moveController.duration = Duration(milliseconds: durationMs);
      _moveController.forward(from: 0).then((_) {
        if (!mounted) return;
        setState(() {
          arrow.isCleared = true;
          _animatingArrowId = null;
          if (_activeArrows.every((a) => a.isCleared)) {
            _isLevelCompleted = true;
          }
        });
      });
    } else {
      if (_vibrationEnabled) HapticFeedback.heavyImpact();
      _moveController.duration = const Duration(milliseconds: 340);
      _moveController.forward(from: 0).then((_) {
        if (!mounted) return;
        setState(() {
          _animatingArrowId = null;
          _isBlockedAnimation = false;
          _hearts = math.max(0, _hearts - 1);
        });
        if (_hearts == 0) {
          _showOutOfHeartsDialog();
        }
      });
    }
  }

  void _useHint() {
    if (_hintsCount <= 0 || _isLevelCompleted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: const Text(
            'انتهت التلميحات! أعد المستوى أو شاهد إعلاناً للحصول على تلميحات إضافية.',
            textAlign: TextAlign.center,
          ),
          action: SnackBarAction(
            label: '+2 مجاناً',
            textColor: const Color(0xFFFFCA28),
            onPressed: () {
              setState(() => _hintsCount += 2);
            },
          ),
        ),
      );
      return;
    }

    for (final arrow in _activeArrows) {
      if (!arrow.isCleared && _isArrowFree(arrow)) {
        setState(() {
          _hintedArrowId = arrow.id;
          _hintsCount--;
        });
        return;
      }
    }
  }

  void _showOutOfHeartsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Column(
          children: [
            Icon(Icons.heart_broken_rounded, color: Color(0xFFE53935), size: 54),
            SizedBox(height: 10),
            Text(
              'نفدت القلوب!',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w900, fontSize: 24),
            ),
          ],
        ),
        content: const Text(
          'اصطدمت الأسهم ببعضها 3 مرات.\nتأكد من إخراج الأسهم التي طريقها مفتوح أولاً!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Color(0xFF4B5563), height: 1.4),
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF1976D2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                _loadLevel(_currentLevelIndex);
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text(
                'إعادة المحاولة',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _openLevelsSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 44,
                height: 5,
                decoration: BoxDecoration(
                  color: const Color(0xFFD1D5DB),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'اختر المستوى (1 - 10)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              GridView.builder(
                shrinkWrap: true,
                itemCount: _allLevels.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 5,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                ),
                itemBuilder: (context, idx) {
                  final isCurrent = idx == _currentLevelIndex;
                  return InkWell(
                    onTap: () {
                      Navigator.pop(ctx);
                      _loadLevel(idx);
                    },
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: isCurrent
                            ? const LinearGradient(
                                colors: [Color(0xFF2196F3), Color(0xFF1565C0)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isCurrent ? null : const Color(0xFFF0F5FF),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isCurrent
                              ? const Color(0xFF1565C0)
                              : const Color(0xFFDBEAFE),
                          width: 1.5,
                        ),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: isCurrent
                              ? Colors.white
                              : const Color(0xFF1E3A8A),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _openSettingsModal() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SettingsScreen(
          soundEnabled: _soundEnabled,
          vibrationEnabled: _vibrationEnabled,
          adsRemoved: _adsRemoved,
          onSoundChanged: (v) => setState(() => _soundEnabled = v),
          onVibrationChanged: (v) => setState(() => _vibrationEnabled = v),
          onRemoveAds: () {
            setState(() => _adsRemoved = true);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('تم تفعيل وضع بدون إعلانات!')),
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLevelCompleted) {
      return _buildVictoryScreen();
    }

    // فرض تخطيط الهيدر والأدوات بنفس توزيع اللعبة الأصلية تماماً
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 1. الهيدر العلوي المطابق للصورة الثانية تماماً:
              // ترس الإعدادات على اليسار | المستوى والصعوبة في الوسط | سهم المستويات على اليمين
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: _openSettingsModal,
                      icon: const Icon(
                        Icons.settings_outlined,
                        color: Color(0xFF1976D2),
                        size: 33,
                      ),
                      tooltip: 'الإعدادات',
                    ),
                    Directionality(
                      textDirection: TextDirection.rtl,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'المستوى ${_currentConfig.levelNumber}',
                            style: const TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF111827),
                              height: 1.15,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _currentConfig.difficultyLabel,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color(0xFF757F8C),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: _openLevelsSelector,
                      icon: const Icon(
                        Icons.chevron_right_rounded,
                        color: Color(0xFF1976D2),
                        size: 38,
                      ),
                      tooltip: 'المستويات',
                    ),
                  ],
                ),
              ),

              // 2. صف القلوب الثلاثة بتأثير ثلاثي الأبعاد ناعم مطابق للصورة
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(3, (index) {
                    final active = index < _hearts;
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 6),
                      child: AnimatedScale(
                        scale: active ? 1.0 : 0.82,
                        duration: const Duration(milliseconds: 260),
                        curve: Curves.easeOutBack,
                        child: CustomPaint(
                          size: const Size(34, 32),
                          painter: GlossyHeartPainter(isActive: active),
                        ),
                      ),
                    );
                  }),
                ),
              ),

              const SizedBox(height: 6),

              // 3. شريط التقدم الرمادي الفاتح النحيف أسفل القلوب
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _progressFraction,
                    minHeight: 5,
                    backgroundColor: const Color(0xFFE9EDF2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF1E88E5),
                    ),
                  ),
                ),
              ),

              // 4. مساحة شبكة اللعب في المنتصف مع تقاطعات نقطية خفيفة وحركة السهم المتني الحقيقية
              Expanded(
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1,
                    child: Padding(
                      padding: const EdgeInsets.all(34.0),
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final boardSize = constraints.biggest.shortestSide;
                          return GestureDetector(
                            behavior: HitTestBehavior.opaque,
                            onTapUp: (details) => _handleBoardTap(
                              details.localPosition,
                              boardSize,
                            ),
                            child: CustomPaint(
                              size: Size(boardSize, boardSize),
                              painter: ArrowBoardPainter(
                                gridCols: _currentConfig.gridCols,
                                gridRows: _currentConfig.gridRows,
                                arrows: _activeArrows,
                                rulerEnabled: _rulerEnabled,
                                hintedArrowId: _hintedArrowId,
                                animatingArrowId: _animatingArrowId,
                                isBlockedAnimation: _isBlockedAnimation,
                                blockedMaxSteps: _BlockedMaxSteps,
                                animationValue: Curves.easeInOutCubic
                                    .transform(_moveController.value),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // 5. أزرار الأدوات المساعدة السفلية (المسطرة المائلة البنفسجية على اليسار + المصباح المائل الذهبي مع شارة العدد أعلى اليسار)
              Padding(
                padding: const EdgeInsets.only(bottom: 24, top: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // زر المسطرة
                    _buildNeumorphicPowerButton(
                      isActive: _rulerEnabled,
                      badgeText: null,
                      onTap: () {
                        if (_vibrationEnabled) HapticFeedback.selectionClick();
                        setState(() => _rulerEnabled = !_rulerEnabled);
                      },
                      customChild: Transform.rotate(
                        angle: -0.55,
                        child: Container(
                          width: 44,
                          height: 20,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7986CB), Color(0xFF5C6BC0)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.white, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5C6BC0).withOpacity(0.35),
                                blurRadius: 6,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: CustomPaint(painter: RulerMarksPainter()),
                        ),
                      ),
                    ),
                    const SizedBox(width: 36),
                    // زر المصباح
                    _buildNeumorphicPowerButton(
                      isActive: _hintedArrowId != null,
                      badgeText: '$_hintsCount',
                      onTap: _useHint,
                      customChild: Transform.rotate(
                        angle: -0.35,
                        child: const Icon(
                          Icons.lightbulb_rounded,
                          size: 42,
                          color: Color(0xFFFFB300),
                          shadows: [
                            Shadow(
                              color: Color(0x55FFA000),
                              blurRadius: 10,
                              offset: Offset(0, 4),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // 6. الشريط السفلي الرمادي الفاتح (منطقة الإعلان السفلية كما في الصورة الثانية)
              if (!_adsRemoved)
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE5EAEF),
                    border: Border(
                      top: BorderSide(color: Color(0xFFD5DCE4), width: 1),
                    ),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'مساحة إعلانية (Google AdMob Banner)',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFF8C96A5),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// التفاعل الذكي باللمس: يلتقط أقرب سهم لمكان إصبع اللاعب حتى لو لمس بجانب الخط قليلاً
  void _handleBoardTap(Offset localPos, double boardSize) {
    final cellW = boardSize / _currentConfig.gridCols;
    final cellH = boardSize / _currentConfig.gridRows;

    ArrowItem? bestArrow;
    double minDistance = cellW * 0.68; // نطاق لمس مريح جداً

    for (final arrow in _activeArrows) {
      if (arrow.isCleared) continue;
      for (int i = 0; i < arrow.cells.length; i++) {
        final c = arrow.cells[i];
        final center = Offset((c.x + 0.5) * cellW, (c.y + 0.5) * cellH);
        final dist = (localPos - center).distance;
        if (dist < minDistance) {
          minDistance = dist;
          bestArrow = arrow;
        }
      }
    }

    if (bestArrow != null) {
      _onArrowTapped(bestArrow);
    }
  }

  Widget _buildNeumorphicPowerButton({
    required bool isActive,
    required String? badgeText,
    required VoidCallback onTap,
    required Widget customChild,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? [const Color(0xFFE3F2FD), const Color(0xFFBBDEFB)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFF3F6FA)],
              ),
              border: Border.all(
                color: isActive
                    ? const Color(0xFF1E88E5)
                    : const Color(0xFFEBF0F5),
                width: 2.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF90A4AE).withOpacity(0.22),
                  blurRadius: 18,
                  spreadRadius: 1,
                  offset: const Offset(0, 8),
                ),
                const BoxShadow(
                  color: Colors.white,
                  blurRadius: 6,
                  offset: Offset(-3, -3),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: customChild,
          ),
          if (badgeText != null)
            Positioned(
              top: -2,
              left: -2, // في أعلى اليسار تماماً مثل الصورة الثانية
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: const Color(0xFF2196F3),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2.2),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF2196F3).withOpacity(0.35),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// شاشة "اكتمل المستوى!" المطابقة للصورة الأولى المرفقة
  Widget _buildVictoryScreen() {
    final nextLevelIndex = (_currentLevelIndex + 1) % _allLevels.length;
    final nextLevelNumber = _allLevels[nextLevelIndex].levelNumber;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
            // خلفية الأشعة الزرقاء المتحركة
            AnimatedBuilder(
              animation: _sunburstController,
              builder: (context, _) {
                return CustomPaint(
                  size: MediaQuery.of(context).size,
                  painter: SunburstPainter(
                    rotation: _sunburstController.value * 2 * math.pi,
                  ),
                );
              },
            ),
            SafeArea(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(height: 45),
                  const Text(
                    'اكتمل المستوى!',
                    style: TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: 0.3,
                    ),
                  ),
                  // البطاقة البيضاء في المنتصف التي تعرض رسمة المستوى المكتمل
                  Container(
                    width: 225,
                    height: 225,
                    padding: const EdgeInsets.all(34),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(22),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF0D47A1).withOpacity(0.28),
                          blurRadius: 30,
                          offset: const Offset(0, 14),
                        ),
                      ],
                    ),
                    child: CustomPaint(
                      painter: ArrowBoardPainter(
                        gridCols: _currentConfig.gridCols,
                        gridRows: _currentConfig.gridRows,
                        arrows: _currentConfig.arrows,
                        rulerEnabled: false,
                        hintedArrowId: null,
                        animatingArrowId: null,
                        isBlockedAnimation: false,
                        blockedMaxSteps: 0,
                        animationValue: 0,
                        ignoreClearedState: true,
                      ),
                    ),
                  ),
                  // أزرار الانتقال للمستوى التالي أو الرئيسية
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 34,
                      vertical: 28,
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          width: double.infinity,
                          height: 68,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: const Color(0xFF1976D2),
                              elevation: 4,
                              shadowColor: Colors.black26,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(36),
                              ),
                            ),
                            onPressed: () => _loadLevel(nextLevelIndex),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'اللعبة التالية',
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1976D2),
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'المستوى $nextLevelNumber',
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFF64B5F6),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: _openLevelsSelector,
                          child: const Text(
                            'الرئيسية',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// رسام علامات المسطرة الصغيرة داخل أيقونة المسطرة
class RulerMarksPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.85)
      ..strokeWidth = 1.4
      ..strokeCap = StrokeCap.round;

    for (int i = 1; i < 8; i++) {
      final x = (size.width / 8) * i;
      final h = (i % 2 == 0) ? size.height * 0.45 : size.height * 0.28;
      canvas.drawLine(Offset(x, 0), Offset(x, h), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// رسام القلب اللامع ثلاثي الأبعاد المطابق للصورة الثانية
class GlossyHeartPainter extends CustomPainter {
  final bool isActive;
  GlossyHeartPainter({required this.isActive});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final path = Path()
      ..moveTo(w * 0.5, h * 0.92)
      ..cubicTo(w * 0.12, h * 0.62, -w * 0.05, h * 0.30, w * 0.18, h * 0.10)
      ..cubicTo(w * 0.34, -h * 0.02, w * 0.46, h * 0.10, w * 0.5, h * 0.22)
      ..cubicTo(w * 0.54, h * 0.10, w * 0.66, -h * 0.02, w * 0.82, h * 0.10)
      ..cubicTo(w * 1.05, h * 0.30, w * 0.88, h * 0.62, w * 0.5, h * 0.92)
      ..close();

    if (!isActive) {
      final inactivePaint = Paint()
        ..color = const Color(0xFFE2E8F0)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, inactivePaint);
      return;
    }

    // ظل سفلي خفيف للقلب
    canvas.drawShadow(path, const Color(0xFFB71C1C).withOpacity(0.35), 4, true);

    final rect = Offset.zero & size;
    final fillPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFF6B5B),
          Color(0xFFE53935),
          Color(0xFFC62828),
        ],
      ).createShader(rect);

    canvas.drawPath(path, fillPaint);

    // لمعة علوية بيضاء ناعمة لإعطاء مظهر 3D
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.28)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.18, h * 0.13, w * 0.16, h * 0.10),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GlossyHeartPainter oldDelegate) =>
      oldDelegate.isActive != isActive;
}

/// محرك رسم شبكة الأسهم مع الحركة الثعبانية الحقيقية (Snake Path-Following)
/// بحيث يتبع الجزء المتني من السهم مسار السهم الأصلي وينفرد تدريجياً في اتجاه الرأس!
class ArrowBoardPainter extends CustomPainter {
  final int gridCols;
  final int gridRows;
  final List<ArrowItem> arrows;
  final bool rulerEnabled;
  final String? hintedArrowId;
  final String? animatingArrowId;
  final bool isBlockedAnimation;
  final double blockedMaxSteps;
  final double animationValue;
  final bool ignoreClearedState;

  ArrowBoardPainter({
    required this.gridCols,
    required this.gridRows,
    required this.arrows,
    required this.rulerEnabled,
    required this.hintedArrowId,
    required this.animatingArrowId,
    required this.isBlockedAnimation,
    required this.blockedMaxSteps,
    required this.animationValue,
    this.ignoreClearedState = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / gridCols;
    final cellH = size.height / gridRows;
    final strokeW = math.min(cellW, cellH) * 0.135;

    Offset centerOf(double col, double row) {
      return Offset((col + 0.5) * cellW, (row + 0.5) * cellH);
    }

    // 1. رسم نقاط خفيفة جداً لمواضع الشبكة عند تفعيل المسطرة لزيادة الدقة البصرية
    if (rulerEnabled && !ignoreClearedState) {
      final dotPaint = Paint()
        ..color = const Color(0xFFCBD5E1)
        ..style = PaintingStyle.fill;
      for (int r = 0; r < gridRows; r++) {
        for (int c = 0; c < gridCols; c++) {
          canvas.drawCircle(centerOf(c.toDouble(), r.toDouble()), 2.2, dotPaint);
        }
      }

      // رسم خطوط المسطرة الإرشادية المتقطعة
      final guidePaint = Paint()
        ..color = const Color(0xFF64B5F6).withOpacity(0.65)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      for (final arrow in arrows) {
        if (arrow.isCleared) continue;
        final start = centerOf(
          arrow.head.x.toDouble(),
          arrow.head.y.toDouble(),
        );
        final delta = arrow.headDir.delta;
        final end = Offset(
          start.dx + delta.x * size.width * 1.1,
          start.dy + delta.y * size.height * 1.1,
        );
        _drawDashedLine(canvas, start, end, guidePaint);
      }
    }

    // 2. رسم كل سهم مع حساب مسار انزلاق الجزء المتني (Snake Uncoiling)
    for (final arrow in arrows) {
      if (!ignoreClearedState && arrow.isCleared) continue;

      final isHinted = arrow.id == hintedArrowId;
      final isAnimating = arrow.id == animatingArrowId;

      Color arrowColor = const Color(0xFF071A3E); // الكحلي الداكن الأصلي
      if (isHinted) {
        arrowColor = const Color(0xFFFF9800); // ذهبي للتلميح
      } else if (isAnimating && isBlockedAnimation) {
        arrowColor = const Color(0xFFE53935); // أحمر عند الاصطدام
      }

      // مقدار التقدم بالخلايا (Steps) على امتداد مسار السهم نفسه
      double shiftCells = 0.0;
      if (isAnimating) {
        if (isBlockedAnimation) {
          // يتحرك السهم للأمام على مساره حتى يلمس العائق ثم يرتد لمكانه!
          shiftCells = math.sin(animationValue * math.pi) * blockedMaxSteps;
        } else {
          // يتحرك السهم بالكامل على مساره المتني ثم يخرج في اتجاه الرأس خارج الشاشة
          final totalEscapeSteps =
              arrow.cells.length + math.max(gridCols, gridRows) + 3.0;
          shiftCells = animationValue * totalEscapeSteps;
        }
      }

      final polylinePoints = _computeSnakePolyline(
        arrow: arrow,
        shiftCells: shiftCells,
        cellW: cellW,
        cellH: cellH,
      );

      if (polylinePoints.length < 2) continue;

      // تأثير توهج ناعم إذا كان السهم مُلمّحاً بالمصباح
      if (isHinted) {
        final glowPaint = Paint()
          ..color = const Color(0xFFFFB300).withOpacity(0.35)
          ..strokeWidth = strokeW * 2.4
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        final glowPath = _buildRoundedCornerPath(polylinePoints, cellW * 0.16);
        canvas.drawPath(glowPath, glowPaint);
      }

      final linePaint = Paint()
        ..color = arrowColor
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      // رسم جسم السهم مع زوايا منحنية ناعمة ومستديرة قليلاً كما في اللعبة الأصلية
      final arrowPath = _buildRoundedCornerPath(polylinePoints, cellW * 0.15);
      canvas.drawPath(arrowPath, linePaint);

      // رسم رأس السهم المثلث عند مقدمة المسار المتحرك
      _drawArrowHead(
        canvas,
        polylinePoints.last,
        arrow.headDir,
        strokeW * 2.55,
        arrowColor,
      );
    }
  }

  /// الدالة الأساسية التي تجعل الحتة المتنية (الذيل والمفاصل) تمشي داخل مسار السهم الأصلي
  /// وتلتف عند الزوايا ثم تنفرد في اتجاه الرأس تماماً مثل الثعبان أو القطار على القضبان!
  List<Offset> _computeSnakePolyline({
    required ArrowItem arrow,
    required double shiftCells,
    required double cellW,
    required double cellH,
  }) {
    final baseOffsets = arrow.cells
        .map((c) => Offset((c.x + 0.5) * cellW, (c.y + 0.5) * cellH))
        .toList();

    final N = baseOffsets.length;
    final dirUnit = arrow.headDir.unitOffset;
    final stepVec = Offset(dirUnit.dx * cellW, dirUnit.dy * cellH);

    // دالة تعطي موقع أي نقطة افتراضية على سكة السهم (سواء داخل الخلايا أو بعد خروجها من الرأس)
    Offset pointAtRail(double s) {
      if (s <= N - 1) {
        final idx = s.floor().clamp(0, N - 2);
        final frac = s - idx;
        return Offset.lerp(baseOffsets[idx], baseOffsets[idx + 1], frac)!;
      } else {
        final extra = s - (N - 1);
        return baseOffsets.last + stepVec * extra;
      }
    }

    if (shiftCells <= 0.0001) {
      return baseOffsets;
    }

    final startS = shiftCells;
    final endS = (N - 1) + shiftCells;

    final result = <Offset>[];
    // 1. موقع الذيل الجديد بعد تحركه على السكة
    result.add(pointAtRail(startS));

    // 2. إضافة جميع مفاصل وزوايا السهم الأصلية التي لم يتجاوزها الذيل بعد!
    // هذا يضمن أن الجزء المتني يظل ماشياً في مساره الأصلي وينفرد زاوية بزاوية عند الرأس
    final firstCorner = startS.floor() + 1;
    for (int k = firstCorner; k <= N - 1; k++) {
      if (k > startS + 0.001 && k < endS - 0.001) {
        result.add(baseOffsets[k]);
      }
    }

    // 3. موقع الرأس الجديد المنطلق في اتجاه السهم
    result.add(pointAtRail(endS));
    return result;
  }

  /// تحويل نقاط المفاصل إلى مسار ذي زوايا ناعمة غير حادة
  Path _buildRoundedCornerPath(List<Offset> pts, double cornerRadius) {
    final path = Path();
    if (pts.isEmpty) return path;
    path.moveTo(pts.first.dx, pts.first.dy);
    if (pts.length == 2) {
      path.lineTo(pts.last.dx, pts.last.dy);
      return path;
    }

    for (int i = 1; i < pts.length - 1; i++) {
      final prev = pts[i - 1];
      final curr = pts[i];
      final next = pts[i + 1];

      final v1 = curr - prev;
      final v2 = next - curr;
      final len1 = v1.distance;
      final len2 = v2.distance;

      if (len1 < 0.001 || len2 < 0.001) {
        path.lineTo(curr.dx, curr.dy);
        continue;
      }

      // إذا كانت النقاط على استقامة واحدة لا نحتاج لمنحنى
      final u1 = v1 / len1;
      final u2 = v2 / len2;
      if ((u1 - u2).distance < 0.01) {
        path.lineTo(curr.dx, curr.dy);
        continue;
      }

      final r = math.min(cornerRadius, math.min(len1, len2) * 0.35);
      final pStart = curr - u1 * r;
      final pEnd = curr + u2 * r;

      path.lineTo(pStart.dx, pStart.dy);
      path.quadraticBezierTo(curr.dx, curr.dy, pEnd.dx, pEnd.dy);
    }

    path.lineTo(pts.last.dx, pts.last.dy);
    return path;
  }

  void _drawArrowHead(
    Canvas canvas,
    Offset tip,
    ArrowDir dir,
    double headSize,
    Color color,
  ) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeJoin = StrokeJoin.round;

    double angle = 0;
    switch (dir) {
      case ArrowDir.right:
        angle = 0;
        break;
      case ArrowDir.down:
        angle = math.pi / 2;
        break;
      case ArrowDir.left:
        angle = math.pi;
        break;
      case ArrowDir.up:
        angle = -math.pi / 2;
        break;
    }

    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);

    final path = Path()
      ..moveTo(headSize * 0.48, 0)
      ..lineTo(-headSize * 0.52, -headSize * 0.52)
      ..lineTo(-headSize * 0.52, headSize * 0.52)
      ..close();

    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    const dashWidth = 6.0;
    const dashSpace = 5.0;
    final dx = p2.dx - p1.dx;
    final dy = p2.dy - p1.dy;
    final distance = math.sqrt(dx * dx + dy * dy);
    if (distance == 0) return;
    final ux = dx / distance;
    final uy = dy / distance;

    double current = 0;
    while (current < distance) {
      final start = Offset(p1.dx + ux * current, p1.dy + uy * current);
      final endDist = math.min(current + dashWidth, distance);
      final end = Offset(p1.dx + ux * endDist, p1.dy + uy * endDist);
      canvas.drawLine(start, end, paint);
      current += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant ArrowBoardPainter oldDelegate) => true;
}

/// رسام خلفية الأشعة الزرقاء الاحتفالية في شاشة الفوز
class SunburstPainter extends CustomPainter {
  final double rotation;
  SunburstPainter({required this.rotation});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final bgPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(0, -0.1),
        radius: 0.95,
        colors: [Color(0xFF29B6F6), Color(0xFF1976D2)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final center = Offset(size.width / 2, size.height * 0.44);
    final radius = math.max(size.width, size.height) * 1.25;
    const raysCount = 28;
    final rayPaint = Paint()
      ..color = Colors.white.withOpacity(0.08)
      ..style = PaintingStyle.fill;

    for (int i = 0; i < raysCount; i += 2) {
      final startAngle = rotation + (i * 2 * math.pi / raysCount);
      final sweepAngle = 2 * math.pi / raysCount;
      final path = Path()
        ..moveTo(center.dx, center.dy)
        ..arcTo(
          Rect.fromCircle(center: center, radius: radius),
          startAngle,
          sweepAngle,
          false,
        )
        ..close();
      canvas.drawPath(path, rayPaint);
    }
  }

  @override
  bool shouldRepaint(covariant SunburstPainter oldDelegate) =>
      oldDelegate.rotation != rotation;
}

/// شاشة الإعدادات المطابقة للصورة الثالثة تماماً (الأيقونة الملونة يمين، النص يمين، السهم يسار، زر "تم" أزرق يسار، وعنوان "الإعدادات" سليم 100%)
class SettingsScreen extends StatefulWidget {
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool adsRemoved;
  final ValueChanged<bool> onSoundChanged;
  final ValueChanged<bool> onVibrationChanged;
  final VoidCallback onRemoveAds;

  const SettingsScreen({
    super.key,
    required this.soundEnabled,
    required this.vibrationEnabled,
    required this.adsRemoved,
    required this.onSoundChanged,
    required this.onVibrationChanged,
    required this.onRemoveAds,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool _sound;
  late bool _vibration;

  @override
  void initState() {
    super.initState();
    _sound = widget.soundEnabled;
    _vibration = widget.vibrationEnabled;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFEBEEF2),
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: const Text(
            'الإعدادات',
            style: TextStyle(
              color: Color(0xFF111827),
              fontWeight: FontWeight.w800,
              fontSize: 23,
            ),
          ),
          // في وضع RTL: actions تظهر في أقصى اليسار تماماً مثل كلمة "تم" في الصورة الثالثة
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'تم',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.w800,
                  fontSize: 19,
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 24),
          children: [
            // البطاقة الأولى: الإعدادات
            _buildCardGroup([
              _buildMenuRow(
                title: 'الإعدادات',
                icon: Icons.settings_rounded,
                iconBgColor: const Color(0xFF1E88E5),
                onTap: () => _showAudioSettingsSheet(context),
              ),
            ]),
            const SizedBox(height: 22),

            // البطاقة الثانية: المساعدة، حول اللعبة، حقوق الخصوصية، تفضيلات الخصوصية
            _buildCardGroup([
              _buildMenuRow(
                title: 'المساعدة',
                icon: Icons.help_rounded,
                iconBgColor: const Color(0xFF2ECC71),
                onTap: () => _showInfoDialog(
                  context,
                  'المساعدة',
                  'اضغط على الأسهم التي يكون طريقها مفتوحاً لإخراجها من الشبكة.\n\n'
                      '• عند خروج السهم، ينفرد الجزء المتني ويمشي في نفس مسار السهم الأصلي.\n'
                      '• إذا كان أمام السهم سهم آخر، سيرتد السهم وتفقد قلباً واحداً.\n'
                      '• استخدم المسطرة لإظهار المسارات والمصباح للتلميح الذكي.',
                ),
              ),
              const Divider(height: 1, indent: 18, endIndent: 18, color: Color(0xFFF1F5F9)),
              _buildMenuRow(
                title: 'حول اللعبة',
                icon: Icons.info_rounded,
                iconBgColor: const Color(0xFF1E88E5),
                onTap: () => _showInfoDialog(
                  context,
                  'حول اللعبة',
                  'لعبة مسار الأسهم (الإصدار 1.1.0)\nتم تطويرها بواجهة عربية احترافية وحركة أسهم انسيابية.',
                ),
              ),
              const Divider(height: 1, indent: 18, endIndent: 18, color: Color(0xFFF1F5F9)),
              _buildMenuRow(
                title: 'حقوق الخصوصية',
                icon: Icons.assignment_turned_in_rounded,
                iconBgColor: const Color(0xFF5C6BC0),
                onTap: () => _showInfoDialog(
                  context,
                  'حقوق الخصوصية',
                  'تحترم اللعبة خصوصية المستخدمين ولا تقوم بجمع أي بيانات شخصية. يتم حفظ تقدمك محلياً على جهازك.',
                ),
              ),
              const Divider(height: 1, indent: 18, endIndent: 18, color: Color(0xFFF1F5F9)),
              _buildMenuRow(
                title: 'تفضيلات الخصوصية',
                icon: Icons.manage_accounts_rounded,
                iconBgColor: const Color(0xFF00ACC1),
                onTap: () => _showInfoDialog(
                  context,
                  'تفضيلات الخصوصية',
                  'يمكنك إدارة تفضيلات الإعلانات والبيانات من هنا عند ربط Google AdMob.',
                ),
              ),
            ]),
            const SizedBox(height: 22),

            // البطاقة الثالثة: إزالة الإعلانات
            _buildCardGroup([
              _buildMenuRow(
                title: widget.adsRemoved
                    ? 'تمت إزالة الإعلانات ✓'
                    : 'إزالة الإعلانات',
                icon: Icons.block_flipped,
                iconBgColor: const Color(0xFFE53935),
                showChevron: false,
                onTap: widget.onRemoveAds,
              ),
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildCardGroup(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuRow({
    required String title,
    required IconData icon,
    required Color iconBgColor,
    required VoidCallback onTap,
    bool showChevron = true,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        child: Row(
          children: [
            // في وضع RTL: أول عنصر يظهر على اليمين (الأيقونة الملونة)
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(icon, color: Colors.white, size: 26),
            ),
            const SizedBox(width: 16),
            // النص بجانب الأيقونة من اليمين
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
            ),
            // سهم الانتقال الصغير في أقصى اليسار يشير لليسار (<) تماماً مثل الصورة الثالثة
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded, // في RTL ينعكس تلقائياً ليشير لليسار <
                color: Color(0xFFB0B8C4),
                size: 28,
              ),
          ],
        ),
      ),
    );
  }

  void _showAudioSettingsSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setModalState) {
              return Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'إعدادات الصوت والاهتزاز',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    SwitchListTile(
                      title: const Text('المؤثرات الصوتية'),
                      value: _sound,
                      onChanged: (val) {
                        setModalState(() => _sound = val);
                        setState(() => _sound = val);
                        widget.onSoundChanged(val);
                      },
                    ),
                    SwitchListTile(
                      title: const Text('الاهتزاز التفاعلي'),
                      value: _vibration,
                      onChanged: (val) {
                        setModalState(() => _vibration = val);
                        setState(() => _vibration = val);
                        widget.onVibrationChanged(val);
                      },
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(message, style: const TextStyle(height: 1.5, fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}