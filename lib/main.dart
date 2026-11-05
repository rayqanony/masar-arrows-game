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

/// نموذج السهم الواحد:
/// يستنتج اتجاه الرأس والخروج تلقائياً 100% من اتجاه آخر قطعة في السهم (من النقطة قبل الأخيرة إلى الأخيرة)
/// مما يمنع نهائياً أن ينحني السهم للداخل ويخرج للخارج!
class ArrowItem {
  final String id;
  final List<Point<int>> cells; // من الذيل [0] إلى الرأس [last]
  bool isCleared;
  bool isQueuedRed; // عندما يصطدم السهم يتحول للأحمر وينتظر فتح الطريق ليخرج لوحده

  ArrowItem({
    required this.id,
    required this.cells,
    this.isCleared = false,
    this.isQueuedRed = false,
  }) : assert(cells.length >= 2, 'Arrow must have at least 2 cells');

  Point<int> get head => cells.last;

  /// اتجاه الرأس مطابق دائماً لاتجاه آخر مفصل في السهم
  ArrowDir get headDir {
    final prev = cells[cells.length - 2];
    final last = cells.last;
    final dx = last.x - prev.x;
    final dy = last.y - prev.y;
    if (dx > 0) return ArrowDir.right;
    if (dx < 0) return ArrowDir.left;
    if (dy > 0) return ArrowDir.down;
    return ArrowDir.up;
  }

  ArrowItem copy() => ArrowItem(
        id: id,
        cells: List<Point<int>>.from(cells),
        isCleared: isCleared,
        isQueuedRed: isQueuedRed,
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

/// مستودع أول 10 مستويات مصممة ومفحوصة هندسياً بحيث يتطابق اتجاه الرأس مع آخر قطعة 100%
class LevelsRepository {
  static List<LevelConfig> getAllLevels() {
    return [
      // المستوى 1: سهل (تعليمي - 4 أسهم ملتفة حول المركز)
      LevelConfig(
        levelNumber: 1,
        difficultyLabel: 'سهل',
        gridCols: 5,
        gridRows: 5,
        arrows: [
          ArrowItem(
            id: 'a1',
            cells: const [Point(1, 2), Point(1, 1), Point(2, 1), Point(3, 1)], // يتجه يميناً
          ),
          ArrowItem(
            id: 'a2',
            cells: const [Point(3, 3), Point(3, 2), Point(2, 2)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'a3',
            cells: const [Point(2, 3), Point(1, 3)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'a4',
            cells: const [Point(2, 4), Point(3, 4), Point(4, 4), Point(4, 3), Point(4, 2)], // يتجه لأعلى
          ),
        ],
      ),

      // المستوى 2: عادي (الحلزون المتداخل من الصورة المرفقة)
      LevelConfig(
        levelNumber: 2,
        difficultyLabel: 'عادي',
        gridCols: 6,
        gridRows: 6,
        arrows: [
          ArrowItem(
            id: 'l2_1',
            cells: const [Point(1, 0), Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l2_2',
            cells: const [Point(2, 5), Point(3, 5), Point(4, 5), Point(5, 5), Point(5, 4), Point(5, 3), Point(5, 2), Point(5, 1), Point(5, 0), Point(4, 0), Point(3, 0), Point(2, 0)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'l2_3',
            cells: const [Point(3, 4), Point(4, 4), Point(4, 3), Point(4, 2)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l2_4',
            cells: const [Point(1, 3), Point(1, 2), Point(1, 1), Point(2, 1), Point(3, 1), Point(4, 1)], // يتجه يميناً
          ),
          ArrowItem(
            id: 'l2_5',
            cells: const [Point(2, 4), Point(1, 4)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'l2_6',
            cells: const [Point(3, 3), Point(3, 2), Point(2, 2), Point(2, 3)], // يتجه لأسفل
          ),
        ],
      ),

      // المستوى 3: عادي (شبكة متشابكة من الصورة الأولى)
      LevelConfig(
        levelNumber: 3,
        difficultyLabel: 'عادي',
        gridCols: 6,
        gridRows: 6,
        arrows: [
          ArrowItem(
            id: 'l3_1',
            cells: const [Point(0, 0), Point(1, 0), Point(2, 0), Point(2, 1), Point(1, 1), Point(0, 1)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'l3_2',
            cells: const [Point(3, 0), Point(4, 0), Point(5, 0), Point(5, 1), Point(5, 2)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l3_3',
            cells: const [Point(5, 3), Point(5, 4), Point(5, 5), Point(4, 5), Point(3, 5)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'l3_4',
            cells: const [Point(2, 5), Point(1, 5), Point(0, 5), Point(0, 4), Point(0, 3), Point(0, 2)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l3_5',
            cells: const [Point(3, 4), Point(4, 4), Point(4, 3), Point(4, 2), Point(4, 1)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l3_6',
            cells: const [Point(2, 2), Point(3, 2), Point(3, 3)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l3_7',
            cells: const [Point(2, 3), Point(1, 3), Point(1, 2)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l3_8',
            cells: const [Point(1, 4), Point(2, 4)], // يتجه يميناً
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
            cells: const [Point(2, 0), Point(1, 0), Point(0, 0)], // يتجه يساراً (مفتوح)
          ),
          ArrowItem(
            id: 'l4_2',
            cells: const [Point(5, 2), Point(5, 1), Point(5, 0), Point(4, 0), Point(3, 0)], // يتجه يساراً (يفتح بعد خروج l4_1)
          ),
          ArrowItem(
            id: 'l4_3',
            cells: const [Point(3, 5), Point(4, 5), Point(5, 5), Point(5, 4), Point(5, 3)], // يتجه لأعلى (يفتح بعد خروج l4_2)
          ),
          ArrowItem(
            id: 'l4_4',
            cells: const [Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5), Point(1, 5), Point(2, 5)], // يتجه يميناً (يفتح بعد خروج l4_3)
          ),
          ArrowItem(
            id: 'l4_5',
            cells: const [Point(1, 2), Point(1, 1), Point(2, 1), Point(3, 1), Point(4, 1)], // يتجه يميناً
          ),
          ArrowItem(
            id: 'l4_6',
            cells: const [Point(4, 2), Point(4, 3), Point(4, 4), Point(3, 4), Point(2, 4), Point(1, 4), Point(1, 3)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l4_7',
            cells: const [Point(2, 2), Point(3, 2), Point(3, 3), Point(2, 3)], // يتجه يساراً
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
            cells: const [Point(1, 0), Point(2, 0), Point(3, 0), Point(4, 0)], // يتجه يميناً
          ),
          ArrowItem(
            id: 'l5_2',
            cells: const [Point(5, 4), Point(5, 3), Point(5, 2), Point(5, 1), Point(5, 0)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l5_3',
            cells: const [Point(1, 5), Point(2, 5), Point(3, 5), Point(4, 5), Point(5, 5)], // يتجه يميناً
          ),
          ArrowItem(
            id: 'l5_4',
            cells: const [Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l5_5',
            cells: const [Point(2, 1), Point(1, 1), Point(1, 2), Point(1, 3), Point(1, 4)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l5_6',
            cells: const [Point(3, 1), Point(4, 1), Point(4, 2), Point(4, 3), Point(4, 4)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l5_7',
            cells: const [Point(2, 4), Point(2, 3), Point(2, 2)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l5_8',
            cells: const [Point(3, 2), Point(3, 3), Point(3, 4)], // يتجه لأسفل
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
            cells: const [Point(2, 0), Point(1, 0), Point(0, 0)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'l6_2',
            cells: const [Point(3, 2), Point(3, 1), Point(3, 0), Point(4, 0), Point(5, 0), Point(6, 0)], // يتجه يميناً
          ),
          ArrowItem(
            id: 'l6_3',
            cells: const [Point(6, 4), Point(6, 3), Point(6, 2), Point(6, 1)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l6_4',
            cells: const [Point(4, 6), Point(5, 6), Point(6, 6), Point(6, 5)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l6_5',
            cells: const [Point(3, 4), Point(3, 5), Point(3, 6), Point(2, 6), Point(1, 6), Point(0, 6)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'l6_6',
            cells: const [Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l6_7',
            cells: const [Point(2, 2), Point(2, 1), Point(1, 1), Point(1, 2), Point(1, 3), Point(1, 4), Point(1, 5)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l6_8',
            cells: const [Point(4, 2), Point(4, 1), Point(5, 1), Point(5, 2), Point(5, 3), Point(5, 4), Point(5, 5)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l6_9',
            cells: const [Point(2, 5), Point(2, 4), Point(2, 3), Point(3, 3), Point(4, 3), Point(4, 4), Point(4, 5)], // يتجه لأسفل
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
            cells: const [Point(0, 3), Point(0, 2), Point(0, 1), Point(0, 0)], // يتجه لأعلى (مفتوح)
          ),
          ArrowItem(
            id: 'l7_2',
            cells: const [Point(6, 3), Point(6, 2), Point(6, 1), Point(6, 0), Point(5, 0), Point(4, 0), Point(3, 0), Point(2, 0), Point(1, 0)], // يتجه يساراً (يفتح بعد خروج l7_1)
          ),
          ArrowItem(
            id: 'l7_3',
            cells: const [Point(6, 4), Point(6, 5), Point(6, 6), Point(5, 6), Point(4, 6), Point(3, 6)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'l7_4',
            cells: const [Point(2, 6), Point(1, 6), Point(0, 6), Point(0, 5), Point(0, 4)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l7_5',
            cells: const [Point(1, 3), Point(1, 2), Point(1, 1), Point(2, 1), Point(3, 1), Point(4, 1), Point(5, 1)], // يتجه يميناً
          ),
          ArrowItem(
            id: 'l7_6',
            cells: const [Point(5, 2), Point(5, 3), Point(5, 4), Point(5, 5), Point(4, 5), Point(3, 5), Point(2, 5), Point(1, 5), Point(1, 4)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l7_7',
            cells: const [Point(4, 2), Point(3, 2), Point(2, 2), Point(2, 3), Point(2, 4)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l7_8',
            cells: const [Point(3, 4), Point(4, 4), Point(4, 3), Point(3, 3)], // يتجه يساراً
          ),
        ],
      ),

      // المستوى 8: صعب (الدرع المزدوج - تم إصلاح السهمين الداخليين ليتطابق اتجاه الرأس مع الانحناء 100%)
      LevelConfig(
        levelNumber: 8,
        difficultyLabel: 'صعب',
        gridCols: 7,
        gridRows: 7,
        arrows: [
          ArrowItem(
            id: 'l8_1',
            cells: const [Point(2, 0), Point(1, 0), Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5)], // يتجه لأسفل (يفتح بعد خروج l8_3)
          ),
          ArrowItem(
            id: 'l8_2',
            cells: const [Point(4, 0), Point(5, 0), Point(6, 0), Point(6, 1), Point(6, 2), Point(6, 3), Point(6, 4), Point(6, 5)], // يتجه لأسفل (يفتح بعد خروج l8_4)
          ),
          ArrowItem(
            id: 'l8_3',
            cells: const [Point(2, 6), Point(1, 6), Point(0, 6)], // يتجه يساراً (مفتوح)
          ),
          ArrowItem(
            id: 'l8_4',
            cells: const [Point(4, 6), Point(5, 6), Point(6, 6)], // يتجه يميناً (مفتوح)
          ),
          ArrowItem(
            id: 'l8_5',
            cells: const [Point(3, 2), Point(3, 1), Point(3, 0)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l8_6',
            cells: const [Point(3, 4), Point(3, 5), Point(3, 6)], // يتجه لأسفل
          ),
          // السهم الأيسر الداخلي: ينحني للأسفل ويخرج للأسفل في خط مستقيم أنيق
          ArrowItem(
            id: 'l8_7',
            cells: const [Point(2, 4), Point(2, 3), Point(2, 2), Point(2, 1), Point(1, 1), Point(1, 2), Point(1, 3), Point(1, 4), Point(1, 5)], // يتجه لأسفل
          ),
          // السهم الأيمن الداخلي: ينحني للأسفل ويخرج للأسفل في خط مستقيم أنيق
          ArrowItem(
            id: 'l8_8',
            cells: const [Point(4, 4), Point(4, 3), Point(4, 2), Point(4, 1), Point(5, 1), Point(5, 2), Point(5, 3), Point(5, 4), Point(5, 5)], // يتجه لأسفل
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
            cells: const [Point(3, 0), Point(2, 0), Point(1, 0), Point(0, 0)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'l9_2',
            cells: const [Point(4, 0), Point(5, 0), Point(6, 0), Point(7, 0)], // يتجه يميناً
          ),
          ArrowItem(
            id: 'l9_3',
            cells: const [Point(0, 4), Point(0, 3), Point(0, 2), Point(0, 1)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l9_4',
            cells: const [Point(7, 4), Point(7, 3), Point(7, 2), Point(7, 1)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l9_5',
            cells: const [Point(3, 7), Point(2, 7), Point(1, 7), Point(0, 7), Point(0, 6), Point(0, 5)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l9_6',
            cells: const [Point(7, 5), Point(7, 6), Point(7, 7), Point(6, 7), Point(5, 7), Point(4, 7)], // يتجه يساراً
          ),
          ArrowItem(
            id: 'l9_7',
            cells: const [Point(3, 1), Point(2, 1), Point(1, 1), Point(1, 2), Point(1, 3), Point(1, 4), Point(1, 5), Point(1, 6)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l9_8',
            cells: const [Point(4, 1), Point(5, 1), Point(6, 1), Point(6, 2), Point(6, 3), Point(6, 4), Point(6, 5), Point(6, 6)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l9_9',
            cells: const [Point(2, 6), Point(3, 6), Point(4, 6), Point(5, 6)], // يتجه يميناً
          ),
          ArrowItem(
            id: 'l9_10',
            cells: const [Point(5, 2), Point(4, 2), Point(3, 2), Point(2, 2), Point(2, 3), Point(2, 4), Point(2, 5)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l9_11',
            cells: const [Point(3, 4), Point(3, 5), Point(4, 5), Point(5, 5), Point(5, 4), Point(5, 3), Point(4, 3), Point(3, 3)], // يتجه يساراً
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
            cells: const [Point(7, 0), Point(6, 0), Point(5, 0), Point(4, 0), Point(3, 0), Point(2, 0), Point(1, 0), Point(0, 0), Point(0, 1), Point(0, 2), Point(0, 3), Point(0, 4), Point(0, 5), Point(0, 6), Point(0, 7)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l10_2',
            cells: const [Point(1, 7), Point(2, 7), Point(3, 7), Point(4, 7), Point(5, 7), Point(6, 7), Point(7, 7), Point(7, 6), Point(7, 5), Point(7, 4), Point(7, 3), Point(7, 2), Point(7, 1)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l10_3',
            cells: const [Point(6, 1), Point(5, 1), Point(4, 1), Point(3, 1), Point(2, 1), Point(1, 1), Point(1, 2), Point(1, 3), Point(1, 4), Point(1, 5), Point(1, 6)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l10_4',
            cells: const [Point(2, 6), Point(3, 6), Point(4, 6), Point(5, 6), Point(6, 6), Point(6, 5), Point(6, 4), Point(6, 3), Point(6, 2)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l10_5',
            cells: const [Point(5, 2), Point(4, 2), Point(3, 2), Point(2, 2), Point(2, 3), Point(2, 4), Point(2, 5)], // يتجه لأسفل
          ),
          ArrowItem(
            id: 'l10_6',
            cells: const [Point(3, 5), Point(4, 5), Point(5, 5), Point(5, 4), Point(5, 3)], // يتجه لأعلى
          ),
          ArrowItem(
            id: 'l10_7',
            cells: const [Point(4, 3), Point(3, 3), Point(3, 4), Point(4, 4)], // يتجه يميناً
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

  // تحريك السهم عند الخروج أو الاصطدام
  String? _animatingArrowId;
  bool _isBlockedAnimation = false;
  double _blockedMaxSteps = 0.25;
  late AnimationController _moveController;
  late AnimationController _sunburstController;
  late AnimationController _ambientGlowController; // نبض إضاءة المصباح والقلوب

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

    _ambientGlowController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1900),
    )..repeat(reverse: true);

    _loadLevel(_currentLevelIndex);
  }

  @override
  void dispose() {
    _moveController.dispose();
    _sunburstController.dispose();
    _ambientGlowController.dispose();
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

  /// تشغيل خروج سهم طريقه مفتوح (يتحول لونه إلى الأزرق وينطلق خارجاً، ثم يفحص الأسهم الحمراء المنتظرة!)
  void _launchFreeArrow(ArrowItem arrow) {
    setState(() {
      arrow.isQueuedRed = false;
      _animatingArrowId = arrow.id;
      _isBlockedAnimation = false;
      if (_hintedArrowId == arrow.id) {
        _hintedArrowId = null;
      }
    });

    if (_vibrationEnabled) HapticFeedback.lightImpact();
    final totalCells = arrow.cells.length + _currentConfig.gridCols + 3;
    final durationMs = (totalCells * 34).clamp(360, 680);
    _moveController.duration = Duration(milliseconds: durationMs);
    _moveController.forward(from: 0).then((_) {
      if (!mounted) return;
      setState(() {
        arrow.isCleared = true;
        _animatingArrowId = null;
      });

      // فحص هل هناك سهم أحمر في وضع الانتظار (Queued) انفتح طريقه الآن ليخرج لوحده!
      _checkAndTriggerQueuedRedArrows();
    });
  }

  /// فحص الأسهم الحمراء المنتظرة: إذا انفتح طريق أي منها يخرج تلقائياً باللون الأزرق!
  void _checkAndTriggerQueuedRedArrows() {
    for (final candidate in _activeArrows) {
      if (!candidate.isCleared &&
          candidate.isQueuedRed &&
          _isArrowFree(candidate)) {
        _launchFreeArrow(candidate);
        return;
      }
    }

    // إذا لم يتبقَ أي سهم في الشبكة، اكتمل المستوى!
    if (_activeArrows.every((a) => a.isCleared)) {
      setState(() {
        _isLevelCompleted = true;
      });
    }
  }

  void _onArrowTapped(ArrowItem arrow) {
    if (_animatingArrowId != null || arrow.isCleared || _isLevelCompleted) {
      return;
    }

    final freeSteps = _freeCellsAhead(arrow);
    final free = freeSteps == -1;

    if (free) {
      _launchFreeArrow(arrow);
    } else {
      // السهم مسدود: يتحول للون الأحمر ويدخل في وضع الانتظار (isQueuedRed = true)
      setState(() {
        arrow.isQueuedRed = true;
        _animatingArrowId = arrow.id;
        _isBlockedAnimation = true;
        _blockedMaxSteps = freeSteps + 0.38;
        if (_hintedArrowId == arrow.id) {
          _hintedArrowId = null;
        }
      });

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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: const Text(
            'انتهت التلميحات! شاهد إعلاناً للحصول على تلميحات إضافية.',
            textAlign: TextAlign.center,
          ),
          action: SnackBarAction(
            label: '+2 مجاناً',
            textColor: const Color(0xFFFFAB3D),
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
        if (_vibrationEnabled) HapticFeedback.selectionClick();
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
            Icon(Icons.heart_broken_rounded,
                color: Color(0xFFE53935), size: 54),
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

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
          child: Column(
            children: [
              // 1. الهيدر العلوي: ترس الإعدادات يسار | المستوى والصعوبة وسط | سهم المستويات يمين
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

              // 2. صف القلوب الثلاثة المحسّن بتوهج Rose/Ruby متعدد الطبقات مستوحى من ملف Neon Lamp
              AnimatedBuilder(
                animation: _ambientGlowController,
                builder: (context, _) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(3, (index) {
                        final active = index < _hearts;
                        return Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 6),
                          child: AnimatedScale(
                            scale: active
                                ? 1.0 + (_ambientGlowController.value * 0.035)
                                : 0.82,
                            duration: const Duration(milliseconds: 240),
                            child: CustomPaint(
                              size: const Size(36, 34),
                              painter: GlossyHeartPainter(
                                isActive: active,
                                glowPulse: _ambientGlowController.value,
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  );
                },
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
                      Color(0xFF2196F3),
                    ),
                  ),
                ),
              ),

              // 4. مساحة شبكة اللعب مع نقاط الشبكة الهادئة وحركة الأسهم (أزرق عند الخروج، أحمر في الانتظار)
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
                                blockedMaxSteps: _blockedMaxSteps,
                                animationValue: Curves.easeInOutCubic
                                    .transform(_moveController.value),
                                glowPulse: _ambientGlowController.value,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),

              // 5. أزرار الأدوات المساعدة السفلية (المسطرة البنفسجية + اللمبة النيون المضيئة Amber Neon Lamp)
              AnimatedBuilder(
                animation: _ambientGlowController,
                builder: (context, _) {
                  final hasHintActive = _hintedArrowId != null;
                  final lampGlow = _ambientGlowController.value;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24, top: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // زر المسطرة
                        _buildNeumorphicPowerButton(
                          isActive: _rulerEnabled,
                          badgeText: null,
                          ambientGlowColor: const Color(0xFF5C6BC0),
                          glowIntensity: _rulerEnabled ? 0.8 : 0.15,
                          onTap: () {
                            if (_vibrationEnabled) {
                              HapticFeedback.selectionClick();
                            }
                            setState(() => _rulerEnabled = !_rulerEnabled);
                          },
                          customChild: Transform.rotate(
                            angle: -0.55,
                            child: Container(
                              width: 44,
                              height: 20,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF7986CB),
                                    Color(0xFF5C6BC0)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: BorderRadius.circular(5),
                                border:
                                    Border.all(color: Colors.white, width: 1.5),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF5C6BC0)
                                        .withOpacity(0.35),
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: CustomPaint(painter: RulerMarksPainter()),
                            ),
                          ),
                        ),
                        const SizedBox(width: 38),
                        // زر اللمبة المضيئة المستوحاة من 10-Neon Lamp Login Form (Amber Warm Spectrum)
                        _buildNeumorphicPowerButton(
                          isActive: hasHintActive,
                          badgeText: '$_hintsCount',
                          ambientGlowColor: const Color(0xFFFFAB3D),
                          glowIntensity:
                              hasHintActive ? 1.0 : (0.45 + lampGlow * 0.45),
                          onTap: _useHint,
                          customChild: CustomPaint(
                            size: const Size(54, 54),
                            painter: NeonLampBulbPainter(
                              glowPulse: lampGlow,
                              isBoosted: hasHintActive,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),

              // 6. الشريط السفلي الرمادي الفاتح
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

  /// التفاعل الذكي باللمس
  void _handleBoardTap(Offset localPos, double boardSize) {
    final cellW = boardSize / _currentConfig.gridCols;
    final cellH = boardSize / _currentConfig.gridRows;

    ArrowItem? bestArrow;
    double minDistance = cellW * 0.68;

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
    required Color ambientGlowColor,
    required double glowIntensity,
    required VoidCallback onTap,
    required Widget customChild,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isActive
                    ? [const Color(0xFFFFF8E7), const Color(0xFFFFECB3)]
                    : [const Color(0xFFFFFFFF), const Color(0xFFF4F7FB)],
              ),
              border: Border.all(
                color: isActive
                    ? ambientGlowColor.withOpacity(0.8)
                    : const Color(0xFFEBF0F5),
                width: 2.5,
              ),
              boxShadow: [
                // إضاءة محيطية ناعمة (Ambient Radial Glow) مستوحاة من ملف Neon Lamp
                BoxShadow(
                  color: ambientGlowColor.withOpacity(0.24 * glowIntensity),
                  blurRadius: 22 + (8 * glowIntensity),
                  spreadRadius: 2 * glowIntensity,
                  offset: const Offset(0, 4),
                ),
                BoxShadow(
                  color: const Color(0xFF90A4AE).withOpacity(0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 7),
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
              left: -2,
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

  /// شاشة "اكتمل المستوى!"
  Widget _buildVictoryScreen() {
    final nextLevelIndex = (_currentLevelIndex + 1) % _allLevels.length;
    final nextLevelNumber = _allLevels[nextLevelIndex].levelNumber;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Stack(
          children: [
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
                        glowPulse: 0,
                        ignoreClearedState: true,
                      ),
                    ),
                  ),
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

/// رسام اللمبة المضيئة المستوحاة من ملف (10-Neon Lamp Login Form):
/// يستخدم نفس طيف الألوان الكهرماني الدافئ (--lamp-accent: #ffab3d, --lamp-glow: #ffe194)
/// مع قاعدة نحاسية ثلاثية الأبعاد (#ffe299 -> #c99738 -> #805915) وهالة ضوئية ناعمة نابضة
class NeonLampBulbPainter extends CustomPainter {
  final double glowPulse;
  final bool isBoosted;

  NeonLampBulbPainter({
    required this.glowPulse,
    required this.isBoosted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-0.35); // الزاوية المائلة المميزة للمبة في اللعبة

    // 1. الهالة الضوئية المحيطية الخفيفة (Volumetric Radial Beam & Bulb Glow Filter)
    final glowRadius = 22.0 + (glowPulse * 5.0) + (isBoosted ? 6.0 : 0.0);
    final ambientPaint = Paint()
      ..shader = RadialGradient(
        colors: [
          const Color(0xFFFFE194).withOpacity(isBoosted ? 0.70 : 0.45),
          const Color(0xFFFFAB3D).withOpacity(isBoosted ? 0.35 : 0.20),
          const Color(0xFFFFAB3D).withOpacity(0.0),
        ],
        stops: const [0.0, 0.55, 1.0],
      ).createShader(
        Rect.fromCircle(center: const Offset(0, -4), radius: glowRadius),
      );
    canvas.drawCircle(const Offset(0, -4), glowRadius, ambientPaint);

    // 2. القاعدة النحاسية الحلزونية للمبة (Brass Joint Gradient من ملف الـ SVG)
    final baseRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-6.5, 9.0, 13.0, 8.5),
      const Radius.circular(3.0),
    );
    final brassPaint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Color(0xFFFFE299),
          Color(0xFFC99738),
          Color(0xFF805915),
        ],
      ).createShader(baseRect.outerRect);
    canvas.drawRRect(baseRect, brassPaint);

    // طرف التوصيل السفلي المعدني الداكن
    final tipRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-4.0, 16.5, 8.0, 3.2),
      const Radius.circular(2.0),
    );
    canvas.drawRRect(tipRect, Paint()..color = const Color(0xFF3E434A));

    // حلقات القاعدة النحاسية
    final threadPaint = Paint()
      ..color = const Color(0xFF805915).withOpacity(0.55)
      ..strokeWidth = 1.1;
    canvas.drawLine(const Offset(-5.5, 12.0), const Offset(5.5, 12.0), threadPaint);
    canvas.drawLine(const Offset(-5.5, 14.5), const Offset(5.5, 14.5), threadPaint);

    // 3. الزجاج الكروي المضيء للمبة (ReflectorOn Radial Gradient من ملف الـ SVG)
    final bulbPath = Path()
      ..moveTo(-6.5, 9.5)
      ..cubicTo(-6.5, 5.0, -13.5, 1.5, -13.5, -6.0)
      ..arcToPoint(
        const Offset(13.5, -6.0),
        radius: const Radius.circular(13.5),
        clockwise: true,
      )
      ..cubicTo(13.5, 1.5, 6.5, 5.0, 6.5, 9.5)
      ..close();

    final bulbRect = const Rect.fromLTWH(-14, -20, 28, 30);
    final bulbPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.35),
        radius: 0.85,
        colors: [
          Color(0xFFFFFFFF), // قلب أبيض ساطع
          Color(0xFFFFE194), // توهج ذهبي فاتح (--lamp-glow)
          Color(0xFFFFAB3D), // كهرماني دافئ (--lamp-accent)
          Color(0xFFD48B28), // حدود دافئة (--lamp-secondary)
        ],
        stops: [0.0, 0.32, 0.72, 1.0],
      ).createShader(bulbRect);

    canvas.drawPath(bulbPath, bulbPaint);

    // 4. فتيل النيون الداخلي المتوهج (Glowing Filament)
    final filamentPaint = Paint()
      ..color = Colors.white.withOpacity(0.75 + glowPulse * 0.25)
      ..strokeWidth = 1.6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final filamentPath = Path()
      ..moveTo(-3.2, 8.0)
      ..lineTo(-3.2, -2.0)
      ..arcToPoint(
        const Offset(3.2, -2.0),
        radius: const Radius.circular(3.5),
        clockwise: true,
      )
      ..lineTo(3.2, 8.0);
    canvas.drawPath(filamentPath, filamentPaint);

    // 5. لمعة زجاجية خارجية ناعمة
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.55)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      const Rect.fromLTWH(-9.5, -14.5, 5.5, 8.5),
      highlightPaint,
    );

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant NeonLampBulbPainter oldDelegate) =>
      oldDelegate.glowPulse != glowPulse || oldDelegate.isBoosted != isBoosted;
}

/// رسام علامات المسطرة الصغيرة
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

/// رسام القلب اللامع ثلاثي الأبعاد مع إضاءة نيون وردية/ياقوتية ناعمة
class GlossyHeartPainter extends CustomPainter {
  final bool isActive;
  final double glowPulse;

  GlossyHeartPainter({
    required this.isActive,
    required this.glowPulse,
  });

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

    // هالة ضوئية ناعمة حول القلب مستوحاة من طيف Rose Light في ملف النيون
    final glowPaint = Paint()
      ..color = const Color(0xFFFF3366).withOpacity(0.18 + glowPulse * 0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
    canvas.drawPath(path.shift(const Offset(0, 2)), glowPaint);

    final rect = Offset.zero & size;
    final fillPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 1.1,
        colors: [
          Color(0xFFFF8A80), // مركز مضيء
          Color(0xFFFF5252), // أحمر ياقوتي حيوي
          Color(0xFFD32F2F), // أطراف عميقة
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawPath(path, fillPaint);

    // لمعة زجاجية مزدوجة أعلى يسار القلب
    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.38)
      ..style = PaintingStyle.fill;
    canvas.drawOval(
      Rect.fromLTWH(w * 0.17, h * 0.13, w * 0.17, h * 0.11),
      highlightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant GlossyHeartPainter oldDelegate) =>
      oldDelegate.isActive != isActive || oldDelegate.glowPulse != glowPulse;
}

/// محرك رسم شبكة الأسهم:
/// 1. يرسم نقاط الشبكة الخفيفة (Grid Dots) دائماً كما في الصورة المرفقة.
/// 2. يحول لون السهم إلى الأزرق السماوي (#2196F3) عند خروجه الصح.
/// 3. يحول لون السهم إلى الأحمر (#E53935) عند الاصطدام ويبقيه أحمر في وضع الانتظار حتى يُفتح طريقه فيخرج لوحده!
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
  final double glowPulse;
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
    required this.glowPulse,
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

    // 1. رسم نقاط الشبكة الرمادية الهادئة (Grid Dots) في خلفية اللوحة كما في لقطة الشاشة الأصلية
    if (!ignoreClearedState) {
      final dotPaint = Paint()
        ..color = const Color(0xFFD0D7E2)
        ..style = PaintingStyle.fill;
      final dotRadius = math.min(cellW, cellH) * 0.048;
      for (int r = 0; r < gridRows; r++) {
        for (int c = 0; c < gridCols; c++) {
          canvas.drawCircle(
            centerOf(c.toDouble(), r.toDouble()),
            dotRadius,
            dotPaint,
          );
        }
      }
    }

    // 2. رسم خطوط المسطرة الإرشادية عند تفعيل أداة المسطرة
    if (rulerEnabled && !ignoreClearedState) {
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

    // 3. رسم الأسهم
    for (final arrow in arrows) {
      if (!ignoreClearedState && arrow.isCleared) continue;

      final isHinted = arrow.id == hintedArrowId;
      final isAnimating = arrow.id == animatingArrowId;

      // تحديد لون السهم بدقة حسب حالته:
      // - إذا كان يخرج بشكل صحيح: أزرق سماوي (#2196F3) مطابق للصورة
      // - إذا كان مسدوداً أو في وضع الانتظار بعد خطأ: أحمر (#E53935)
      // - إذا كان مُلمّحاً بالمصباح: كهرماني مضيء (#FFAB3D)
      // - الوضع العادي: كحلي داكن (#071A3E)
      Color arrowColor = const Color(0xFF071A3E);
      if (isAnimating && !isBlockedAnimation) {
        arrowColor = const Color(0xFF2196F3); // أزرق عند الخروج الصحيح!
      } else if ((isAnimating && isBlockedAnimation) || arrow.isQueuedRed) {
        arrowColor = const Color(0xFFE53935); // أحمر عند الغلط وفي الانتظار!
      } else if (isHinted) {
        arrowColor = const Color(0xFFFF9800);
      }

      double shiftCells = 0.0;
      if (isAnimating) {
        if (isBlockedAnimation) {
          shiftCells = math.sin(animationValue * math.pi) * blockedMaxSteps;
        } else {
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

      // هالة ضوئية حول السهم المُلمّح أو السهم الأزرق المنطلق
      if (isHinted || (isAnimating && !isBlockedAnimation)) {
        final glowColor = (isAnimating && !isBlockedAnimation)
            ? const Color(0xFF2196F3).withOpacity(0.22)
            : const Color(0xFFFFAB3D).withOpacity(0.32 + glowPulse * 0.15);
        final glowPaint = Paint()
          ..color = glowColor
          ..strokeWidth = strokeW * 2.3
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

      final arrowPath = _buildRoundedCornerPath(polylinePoints, cellW * 0.15);
      canvas.drawPath(arrowPath, linePaint);

      _drawArrowHead(
        canvas,
        polylinePoints.last,
        arrow.headDir,
        strokeW * 2.55,
        arrowColor,
      );
    }
  }

  /// تحريك السهم المتني في نفس مساره الأصلي (Snake Path-Following)
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
    result.add(pointAtRail(startS));

    final firstCorner = startS.floor() + 1;
    for (int k = firstCorner; k <= N - 1; k++) {
      if (k > startS + 0.001 && k < endS - 0.001) {
        result.add(baseOffsets[k]);
      }
    }

    result.add(pointAtRail(endS));
    return result;
  }

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

/// شاشة الإعدادات العربية السليمة
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
            _buildCardGroup([
              _buildMenuRow(
                title: 'الإعدادات',
                icon: Icons.settings_rounded,
                iconBgColor: const Color(0xFF1E88E5),
                onTap: () => _showAudioSettingsSheet(context),
              ),
            ]),
            const SizedBox(height: 22),
            _buildCardGroup([
              _buildMenuRow(
                title: 'المساعدة',
                icon: Icons.help_rounded,
                iconBgColor: const Color(0xFF2ECC71),
                onTap: () => _showInfoDialog(
                  context,
                  'المساعدة',
                  'اضغط على الأسهم التي يكون طريقها مفتوحاً لإخراجها من الشبكة.\n\n'
                      '• عند الضغط على سهم صحيح يتحول للأزرق وينطلق خارجاً.\n'
                      '• عند الضغط على سهم مسدود يتحول للأحمر ويدخل في وضع الانتظار، وبمجرد فتح طريقه ينطلق تلقائياً لوحده!',
                ),
              ),
              const Divider(
                  height: 1,
                  indent: 18,
                  endIndent: 18,
                  color: Color(0xFFF1F5F9)),
              _buildMenuRow(
                title: 'حول اللعبة',
                icon: Icons.info_rounded,
                iconBgColor: const Color(0xFF1E88E5),
                onTap: () => _showInfoDialog(
                  context,
                  'حول اللعبة',
                  'لعبة مسار الأسهم (الإصدار 1.2.0)\nمزودة بإضاءة نيون تفاعلية ونظام الانتظار الذكي للأسهم.',
                ),
              ),
              const Divider(
                  height: 1,
                  indent: 18,
                  endIndent: 18,
                  color: Color(0xFFF1F5F9)),
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
              const Divider(
                  height: 1,
                  indent: 18,
                  endIndent: 18,
                  color: Color(0xFFF1F5F9)),
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
            if (showChevron)
              const Icon(
                Icons.chevron_right_rounded,
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title:
              Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
          content:
              Text(message, style: const TextStyle(height: 1.5, fontSize: 16)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('حسناً',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}