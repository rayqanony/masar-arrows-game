import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
        scaffoldBackgroundColor: const Color(0xFFF7F8FA),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1E88E5),
          primary: const Color(0xFF1E88E5),
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

      // المستوى 2: عادي (مستوحى مباشرة من الصورة الثانية المرفقة - حلزون متداخل)
      LevelConfig(
        levelNumber: 2,
        difficultyLabel: 'عادي',
        gridCols: 6,
        gridRows: 6,
        arrows: [
          // السهم الخارجي الأيسر المتجه للأسفل (مفتوح مباشرة)
          ArrowItem(
            id: 'l2_1',
            cells: const [Point(1, 0), Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5)],
            headDir: ArrowDir.down,
          ),
          // السهم الخارجي الأيمن والأعلى المتجه لليسار (يفتح بعد خروج l2_1)
          ArrowItem(
            id: 'l2_2',
            cells: const [Point(2, 5), Point(3, 5), Point(4, 5), Point(5, 5), Point(5, 4), Point(5, 3), Point(5, 2), Point(5, 1), Point(5, 0), Point(4, 0), Point(3, 0), Point(2, 0)],
            headDir: ArrowDir.left,
          ),
          // السهم الداخلي الأيمن المتجه للأعلى (يفتح بعد خروج l2_2)
          ArrowItem(
            id: 'l2_3',
            cells: const [Point(3, 4), Point(4, 4), Point(4, 3), Point(4, 2)],
            headDir: ArrowDir.up,
          ),
          // السهم الداخلي الأعلى المتجه لليمين (يفتح بعد خروج l2_2 و l2_3)
          ArrowItem(
            id: 'l2_4',
            cells: const [Point(1, 3), Point(1, 2), Point(1, 1), Point(2, 1), Point(3, 1), Point(4, 1)],
            headDir: ArrowDir.right,
          ),
          // السهم السفلي القصير المتجه لليسار (يفتح بعد خروج l2_1)
          ArrowItem(
            id: 'l2_5',
            cells: const [Point(2, 4), Point(1, 4)],
            headDir: ArrowDir.left,
          ),
          // السهم القلبي الأوسط المتجه للأسفل (يفتح بعد خروج l2_5 و l2_2)
          ArrowItem(
            id: 'l2_6',
            cells: const [Point(3, 3), Point(3, 2), Point(2, 2), Point(2, 3)],
            headDir: ArrowDir.down,
          ),
        ],
      ),

      // المستوى 3: عادي (مستوحى من الصورة الأولى المرفقة - شبكة متشابكة)
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
  int _hintsCount = 3;
  bool _rulerEnabled = false;
  String? _hintedArrowId;

  // تحريك السهم عند الخروج أو الاصطدام
  String? _animatingArrowId;
  bool _isBlockedAnimation = false;
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
      duration: const Duration(milliseconds: 350),
    )..addListener(() {
        setState(() {});
      });

    _sunburstController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 12),
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

  /// فحص ما إذا كان طريق السهم مفتوحاً تماماً حتى حافة الشبكة
  bool _isArrowFree(ArrowItem arrow) {
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

    while (checkX >= 0 &&
        checkX < _currentConfig.gridCols &&
        checkY >= 0 &&
        checkY < _currentConfig.gridRows) {
      if (occupied.containsKey(Point(checkX, checkY))) {
        return false;
      }
      checkX += delta.x;
      checkY += delta.y;
    }
    return true;
  }

  void _onArrowTapped(ArrowItem arrow) {
    if (_animatingArrowId != null || arrow.isCleared || _isLevelCompleted) {
      return;
    }

    final free = _isArrowFree(arrow);
    setState(() {
      _animatingArrowId = arrow.id;
      _isBlockedAnimation = !free;
      if (_hintedArrowId == arrow.id) {
        _hintedArrowId = null;
      }
    });

    if (free) {
      if (_vibrationEnabled) HapticFeedback.lightImpact();
      _moveController.duration = const Duration(milliseconds: 380);
      _moveController.forward(from: 0).then((_) {
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
      _moveController.duration = const Duration(milliseconds: 280);
      _moveController.forward(from: 0).then((_) {
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
        const SnackBar(
          content: Text('انتهت التلميحات! يمكنك إعادة المستوى أو مشاهدة إعلان.'),
          duration: Duration(seconds: 2),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'نفدت القلوب! 💔',
          textAlign: TextAlign.center,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'اصطدمت الأسهم ببعضها 3 مرات. هل ترغب في إعادة المحاولة في هذا المستوى؟',
          textAlign: TextAlign.center,
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton.icon(
            onPressed: () {
              Navigator.pop(ctx);
              _loadLevel(_currentLevelIndex);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('إعادة المستوى'),
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
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'اختر المستوى (أول 10 مستويات)',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
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
                        color: isCurrent
                            ? const Color(0xFF1E88E5)
                            : const Color(0xFFE3F2FD),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '${idx + 1}',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isCurrent
                              ? Colors.white
                              : const Color(0xFF0D47A1),
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
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

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            // الشريط العلوي (الإعدادات - رقم المستوى والصعوبة - اختيار المستوى)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: _openSettingsModal,
                    icon: const Icon(
                      Icons.settings_outlined,
                      color: Color(0xFF1E88E5),
                      size: 32,
                    ),
                    tooltip: 'الإعدادات',
                  ),
                  Column(
                    children: [
                      Text(
                        'المستوى ${_currentConfig.levelNumber}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF111827),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        _currentConfig.difficultyLabel,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF6B7280),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: _openLevelsSelector,
                    icon: const Icon(
                      Icons.arrow_forward_ios_rounded,
                      color: Color(0xFF1E88E5),
                      size: 28,
                    ),
                    tooltip: 'المستويات',
                  ),
                ],
              ),
            ),

            // صف القلوب الثلاثة
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(3, (index) {
                final active = index < _hearts;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: AnimatedScale(
                    scale: active ? 1.0 : 0.85,
                    duration: const Duration(milliseconds: 250),
                    child: Icon(
                      Icons.favorite_rounded,
                      size: 34,
                      color: active
                          ? const Color(0xFFE53935)
                          : const Color(0xFFE5E7EB),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 14),

            // شريط تقدم تفكيك الأسهم
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: LinearProgressIndicator(
                  value: _progressFraction,
                  minHeight: 6,
                  backgroundColor: const Color(0xFFE5E7EB),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
                ),
              ),
            ),

            // مساحة شبكة اللعب التفاعلية
            Expanded(
              child: Center(
                child: AspectRatio(
                  aspectRatio: 1,
                  child: Padding(
                    padding: const EdgeInsets.all(28.0),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boardSize = constraints.biggest.shortestSide;
                        return GestureDetector(
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
                              animationValue: _moveController.value,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // أزرار الأدوات المساعدة السفلية (المسطرة + المصباح)
            Padding(
              padding: const EdgeInsets.only(bottom: 32, top: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // زر المسطرة
                  _buildPowerUpButton(
                    icon: Icons.straighten_rounded,
                    iconColor: const Color(0xFF5C6BC0),
                    isActive: _rulerEnabled,
                    badgeText: null,
                    onTap: () {
                      setState(() {
                        _rulerEnabled = !_rulerEnabled;
                      });
                    },
                  ),
                  const SizedBox(width: 36),
                  // زر التلميح (المصباح)
                  _buildPowerUpButton(
                    icon: Icons.lightbulb_rounded,
                    iconColor: const Color(0xFFFFB300),
                    isActive: _hintedArrowId != null,
                    badgeText: '$_hintsCount',
                    onTap: _useHint,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handleBoardTap(Offset localPos, double boardSize) {
    final cellW = boardSize / _currentConfig.gridCols;
    final cellH = boardSize / _currentConfig.gridRows;
    final col = (localPos.dx / cellW).floor();
    final row = (localPos.dy / cellH).floor();
    final tappedPoint = Point<int>(col, row);

    for (final arrow in _activeArrows) {
      if (arrow.isCleared) continue;
      if (arrow.cells.contains(tappedPoint)) {
        _onArrowTapped(arrow);
        return;
      }
    }
  }

  Widget _buildPowerUpButton({
    required IconData icon,
    required Color iconColor,
    required bool isActive,
    required String? badgeText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 78,
            height: 78,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive ? const Color(0xFFE3F2FD) : Colors.white,
              border: Border.all(
                color: isActive
                    ? const Color(0xFF1E88E5)
                    : const Color(0xFFE5E7EB),
                width: isActive ? 2.5 : 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, size: 38, color: iconColor),
          ),
          if (badgeText != null)
            Positioned(
              top: -4,
              right: -4,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFF1E88E5),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                alignment: Alignment.center,
                child: Text(
                  badgeText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
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

    return Scaffold(
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
                const SizedBox(height: 40),
                const Text(
                  'اكتمل المستوى!',
                  style: TextStyle(
                    fontSize: 38,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        blurRadius: 12,
                        offset: Offset(0, 4),
                      ),
                    ],
                  ),
                ),
                // البطاقة البيضاء في المنتصف التي تعرض رسمة المستوى المكتمل
                Container(
                  width: 230,
                  height: 230,
                  padding: const EdgeInsets.all(26),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.18),
                        blurRadius: 28,
                        offset: const Offset(0, 12),
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
                      animationValue: 0,
                      ignoreClearedState: true,
                    ),
                  ),
                ),
                // أزرار الانتقال للمستوى التالي أو الرئيسية
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 32, vertical: 32),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 68,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF1565C0),
                            elevation: 6,
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
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF1565C0),
                                ),
                              ),
                              Text(
                                'المستوى $nextLevelNumber',
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: Color(0xFF64B5F6),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      TextButton(
                        onPressed: _openLevelsSelector,
                        child: const Text(
                          'الرئيسية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
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
    );
  }
}

/// محرك رسم شبكة الأسهم (يرسم الأسهم الملتفة، رؤوس الأسهم، والمسطرة، وحركة الخروج)
class ArrowBoardPainter extends CustomPainter {
  final int gridCols;
  final int gridRows;
  final List<ArrowItem> arrows;
  final bool rulerEnabled;
  final String? hintedArrowId;
  final String? animatingArrowId;
  final bool isBlockedAnimation;
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
    required this.animationValue,
    this.ignoreClearedState = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / gridCols;
    final cellH = size.height / gridRows;
    final strokeW = math.min(cellW, cellH) * 0.14;

    Offset centerOf(double col, double row) {
      return Offset((col + 0.5) * cellW, (row + 0.5) * cellH);
    }

    // 1. رسم خطوط المسطرة الإرشادية عند تفعيل أداة المسطرة
    if (rulerEnabled) {
      final guidePaint = Paint()
        ..color = const Color(0xFF90CAF9).withOpacity(0.55)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      for (final arrow in arrows) {
        if (!ignoreClearedState && arrow.isCleared) continue;
        final start = centerOf(
          arrow.head.x.toDouble(),
          arrow.head.y.toDouble(),
        );
        final delta = arrow.headDir.delta;
        final end = Offset(
          start.dx + delta.x * size.width * 1.2,
          start.dy + delta.y * size.height * 1.2,
        );
        _drawDashedLine(canvas, start, end, guidePaint);
      }
    }

    // 2. رسم كل سهم
    for (final arrow in arrows) {
      if (!ignoreClearedState && arrow.isCleared) continue;

      final isHinted = arrow.id == hintedArrowId;
      final isAnimating = arrow.id == animatingArrowId;

      Color arrowColor = const Color(0xFF0A1931); // الكحلي الداكن الأصلي
      if (isHinted) {
        arrowColor = const Color(0xFFFF8F00); // ذهبي للتلميح
      } else if (isAnimating && isBlockedAnimation) {
        arrowColor = const Color(0xFFE53935); // أحمر عند الاصطدام
      }

      // حساب نقاط المسار
      List<Offset> points = arrow.cells
          .map((c) => centerOf(c.x.toDouble(), c.y.toDouble()))
          .toList();

      if (isAnimating) {
        final delta = arrow.headDir.delta;
        if (isBlockedAnimation) {
          // ارتداد قصير عند الاصطدام
          final bump = math.sin(animationValue * math.pi) * (cellW * 0.22);
          points = points
              .map((p) => Offset(p.dx + delta.x * bump, p.dy + delta.y * bump))
              .toList();
        } else {
          // انزلاق السهم للخارج على امتداد مساره ثم خارج الشاشة
          final shiftDistance = animationValue * (size.width * 1.35);
          points = points
              .map(
                (p) => Offset(
                  p.dx + delta.x * shiftDistance,
                  p.dy + delta.y * shiftDistance,
                ),
              )
              .toList();
        }
      }

      final linePaint = Paint()
        ..color = arrowColor
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      final path = Path();
      if (points.isNotEmpty) {
        path.moveTo(points.first.dx, points.first.dy);
        for (int i = 1; i < points.length; i++) {
          path.lineTo(points[i].dx, points[i].dy);
        }
      }
      canvas.drawPath(path, linePaint);

      // رسم رأس السهم المثلث عند آخر نقطة
      if (points.isNotEmpty) {
        _drawArrowHead(
          canvas,
          points.last,
          arrow.headDir,
          strokeW * 2.5,
          arrowColor,
        );
      }
    }
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
      ..style = PaintingStyle.fill;

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
      ..moveTo(headSize * 0.45, 0)
      ..lineTo(-headSize * 0.55, -headSize * 0.52)
      ..lineTo(-headSize * 0.55, headSize * 0.52)
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
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
      ).createShader(rect);
    canvas.drawRect(rect, bgPaint);

    final center = Offset(size.width / 2, size.height * 0.43);
    final radius = math.max(size.width, size.height) * 1.2;
    const raysCount = 24;
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

/// شاشة الإعدادات المطابقة للصورة الثالثة مع تصحيح كتابة العنوان العربي بالكامل
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
    return Scaffold(
      backgroundColor: const Color(0xFFEEF1F6),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: const Text(
          'الإعدادات',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'تم',
              style: TextStyle(
                color: Color(0xFF1E88E5),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          // بطاقة الإعدادات الصوتية والاهتزاز
          _buildCardGroup([
            _buildMenuRow(
              title: 'الإعدادات (الصوت والاهتزاز)',
              icon: Icons.settings_rounded,
              iconBgColor: const Color(0xFF1E88E5),
              onTap: () => _showAudioSettingsSheet(context),
            ),
          ]),
          const SizedBox(height: 18),

          // بطاقة المساعدة والمعلومات والخصوصية
          _buildCardGroup([
            _buildMenuRow(
              title: 'المساعدة',
              icon: Icons.help_outline_rounded,
              iconBgColor: const Color(0xFF2ECC71),
              onTap: () => _showInfoDialog(
                context,
                'كيف تلعب؟',
                'اضغط على الأسهم التي يكون طريقها مفتوحاً لإخراجها من الشبكة.\n\n'
                    '• إذا كان أمام السهم سهم آخر، سيرتد السهم وتفقد قلباً واحداً.\n'
                    '• استخدم أداة المسطرة لإظهار خطوط المسار.\n'
                    '• استخدم المصباح لتحديد السهم الصحيح التالي.',
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildMenuRow(
              title: 'حول اللعبة',
              icon: Icons.info_outline_rounded,
              iconBgColor: const Color(0xFF1E88E5),
              onTap: () => _showInfoDialog(
                context,
                'حول اللعبة',
                'لعبة مسار الأسهم (الإصدار 1.0.0)\nنسخة أولية تحتوي على أول 10 مستويات جاهزة للتجربة والنشر على Google Play.',
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildMenuRow(
              title: 'حقوق الخصوصية',
              icon: Icons.assignment_turned_in_rounded,
              iconBgColor: const Color(0xFF5C6BC0),
              onTap: () => _showInfoDialog(
                context,
                'سياسة الخصوصية',
                'تحترم اللعبة خصوصية المستخدمين ولا تقوم بجمع أي بيانات شخصية حساسة. يتم حفظ تقدمك في المستويات محلياً على جهازك.',
              ),
            ),
            const Divider(height: 1, indent: 16, endIndent: 16),
            _buildMenuRow(
              title: 'تفضيلات الخصوصية',
              icon: Icons.verified_user_rounded,
              iconBgColor: const Color(0xFF00ACC1),
              onTap: () => _showInfoDialog(
                context,
                'تفضيلات الخصوصية',
                'يمكنك التحكم في تفضيلات الإعلانات المخصصة عند ربط حزمة Google AdMob قبل النشر النهائي على المتجر.',
              ),
            ),
          ]),
          const SizedBox(height: 18),

          // بطاقة إزالة الإعلانات
          _buildCardGroup([
            _buildMenuRow(
              title: widget.adsRemoved
                  ? 'تمت إزالة الإعلانات ✓'
                  : 'إزالة الإعلانات',
              icon: Icons.block_rounded,
              iconBgColor: const Color(0xFFE53935),
              showChevron: false,
              onTap: widget.onRemoveAds,
            ),
          ]),
        ],
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
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      onTap: onTap,
      leading: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: iconBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Color(0xFF1F2937),
        ),
      ),
      trailing: showChevron
          ? const Icon(
              Icons.chevron_right_rounded,
              color: Color(0xFF9CA3AF),
              size: 28,
            )
          : null,
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
        return StatefulBuilder(
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
        );
      },
    );
  }

  void _showInfoDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Text(message, style: const TextStyle(height: 1.5)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('حسناً'),
          ),
        ],
      ),
    );
  }
}
