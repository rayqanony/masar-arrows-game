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

/// أشكال نهاية السهم (عادية أو مزخرفة بـ ❤️ أو ⭐)
enum ArrowBadgeStyle { none, heart, star }

/// المجموعات البصرية للمستويات (Visual Stage Themes):
/// تغير الخلفية والإضاءة المحيطية ولون شريط التقدم والأسهم بهدوء دون تعقيد قواعد اللعب
enum StageVisualTheme {
  clean,    // المستويات 1-4: البداية النقية (أبيض ناصع وأزرق كلاسيكي)
  ocean,    // المستويات المتوسطة الكثيفة: تدرج محيطي بارد وهادئ
  heart,    // مستويات القلب ❤️: لمسة وردية/ياقوتية دافئة متناسقة مع شكل القلب
  star,     // مستويات النجمة ⭐: لمسة ذهبية/كهرمانية مشرقة
  diamond,  // مستوى الماسة 💎: طابع كريستالي سماوي
  twilight, // المستويات المتقدمة 16-19: طابع الشفق البنفسجي الهادئ
  crown,    // المستوى 20 الختامي 👑: طابع ملكي فاخر بلمسات ذهبية وبنفسجية
}

class StagePalette {
  final Color bgTop;
  final Color bgBottom;
  final Color boardCardColor;
  final Color boardGlowColor;
  final Color arrowNormalColor;
  final Color progressColor;
  final Color gridDotColor;
  final String? badgeEmoji;

  const StagePalette({
    required this.bgTop,
    required this.bgBottom,
    required this.boardCardColor,
    required this.boardGlowColor,
    required this.arrowNormalColor,
    required this.progressColor,
    required this.gridDotColor,
    this.badgeEmoji,
  });

  static StagePalette of(StageVisualTheme theme) {
    switch (theme) {
      case StageVisualTheme.clean:
        return const StagePalette(
          bgTop: Color(0xFFFFFFFF),
          bgBottom: Color(0xFFF8FAFC),
          boardCardColor: Color(0xFFFFFFFF),
          boardGlowColor: Color(0x081976D2),
          arrowNormalColor: Color(0xFF0A1D3B),
          progressColor: Color(0xFF2196F3),
          gridDotColor: Color(0xFFD0D7E2),
        );
      case StageVisualTheme.ocean:
        return const StagePalette(
          bgTop: Color(0xFFF4F9FF),
          bgBottom: Color(0xFFEBF3FE),
          boardCardColor: Color(0xFFFAFCFF),
          boardGlowColor: Color(0x181E88E5),
          arrowNormalColor: Color(0xFF0C2244),
          progressColor: Color(0xFF1976D2),
          gridDotColor: Color(0xFFC5D4E8),
        );
      case StageVisualTheme.heart:
        return const StagePalette(
          bgTop: Color(0xFFFFF5F7),
          bgBottom: Color(0xFFFFEBEF),
          boardCardColor: Color(0xFFFFFBFC),
          boardGlowColor: Color(0x22E91E63),
          arrowNormalColor: Color(0xFF2C1024),
          progressColor: Color(0xFFE91E63),
          gridDotColor: Color(0xFFEBC5D0),
          badgeEmoji: '❤️',
        );
      case StageVisualTheme.star:
        return const StagePalette(
          bgTop: Color(0xFFFFFBF0),
          bgBottom: Color(0xFFFFF3D6),
          boardCardColor: Color(0xFFFFFEFA),
          boardGlowColor: Color(0x26FFA000),
          arrowNormalColor: Color(0xFF1F2438),
          progressColor: Color(0xFFFF9800),
          gridDotColor: Color(0xFFE5D5B5),
          badgeEmoji: '⭐',
        );
      case StageVisualTheme.diamond:
        return const StagePalette(
          bgTop: Color(0xFFF0FDFA),
          bgBottom: Color(0xFFE0F7FA),
          boardCardColor: Color(0xFFFAFFFF),
          boardGlowColor: Color(0x2400ACC1),
          arrowNormalColor: Color(0xFF0A2E36),
          progressColor: Color(0xFF00ACC1),
          gridDotColor: Color(0xFFB8DCE0),
          badgeEmoji: '💎',
        );
      case StageVisualTheme.twilight:
        return const StagePalette(
          bgTop: Color(0xFFF6F4FF),
          bgBottom: Color(0xFFEDE9FE),
          boardCardColor: Color(0xFFFCFAFF),
          boardGlowColor: Color(0x205E35B1),
          arrowNormalColor: Color(0xFF1A1438),
          progressColor: Color(0xFF5E35B1),
          gridDotColor: Color(0xFFD0C8E8),
        );
      case StageVisualTheme.crown:
        return const StagePalette(
          bgTop: Color(0xFFFAF5FF),
          bgBottom: Color(0xFFFFF7E6),
          boardCardColor: Color(0xFFFFFDF9),
          boardGlowColor: Color(0x28D97706),
          arrowNormalColor: Color(0xFF241538),
          progressColor: Color(0xFFD97706),
          gridDotColor: Color(0xFFDECFE8),
          badgeEmoji: '👑',
        );
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
/// يستنتج اتجاه الرأس والخروج تلقائياً 100% من اتجاه آخر قطعة في السهم
class ArrowItem {
  final String id;
  final List<Point<int>> cells; // من الذيل [0] إلى الرأس [last]
  final ArrowBadgeStyle badge;
  bool isCleared;
  bool isQueuedRed;

  ArrowItem({
    required this.id,
    required this.cells,
    this.badge = ArrowBadgeStyle.none,
    this.isCleared = false,
    this.isQueuedRed = false,
  }) : assert(cells.length >= 2, 'Arrow must have at least 2 cells');

  Point<int> get head => cells.last;

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
        badge: badge,
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
  final StageVisualTheme stageTheme;
  final List<ArrowItem> arrows;

  const LevelConfig({
    required this.levelNumber,
    required this.difficultyLabel,
    required this.gridCols,
    required this.gridRows,
    this.stageTheme = StageVisualTheme.clean,
    required this.arrows,
  });
}

/// مستودع الـ 20 مستوى عالية الكثافة والعمق (مفحوصة بخوارزمية free0=1..2 وعمق متسلسل 11..25)
class LevelsRepository {
  static List<LevelConfig> getAllLevels() {
    return [
      // المستوى 1: سهل • البداية (6x6 | n=11 | free0=1 | depth=11 | E=111.8)
      LevelConfig(
        levelNumber: 1,
        difficultyLabel: 'سهل • البداية',
        gridCols: 6,
        gridRows: 6,
        stageTheme: StageVisualTheme.clean,
        arrows: [
          ArrowItem(id: 'l1_1', cells: const [Point(0, 5), Point(0, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l1_2', cells: const [Point(0, 0), Point(0, 1), Point(1, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l1_3', cells: const [Point(2, 0), Point(2, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l1_4', cells: const [Point(2, 4), Point(3, 4), Point(3, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l1_5', cells: const [Point(3, 0), Point(4, 0), Point(5, 0), Point(5, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l1_6', cells: const [Point(5, 3), Point(5, 2), Point(4, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l1_7', cells: const [Point(4, 1), Point(3, 1), Point(3, 2), Point(2, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l1_8', cells: const [Point(0, 2), Point(1, 2), Point(1, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l1_9', cells: const [Point(1, 5), Point(2, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l1_10', cells: const [Point(3, 5), Point(4, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l1_11', cells: const [Point(4, 3), Point(4, 4), Point(5, 4), Point(5, 5)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 2: سهل • خطوة للأمام (7x7 | n=15 | free0=2 | depth=11 | E=113.6)
      LevelConfig(
        levelNumber: 2,
        difficultyLabel: 'سهل • خطوة للأمام',
        gridCols: 7,
        gridRows: 7,
        stageTheme: StageVisualTheme.clean,
        arrows: [
          ArrowItem(id: 'l2_1', cells: const [Point(0, 5), Point(0, 6), Point(1, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_2', cells: const [Point(2, 6), Point(2, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_3', cells: const [Point(1, 1), Point(2, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_4', cells: const [Point(6, 1), Point(6, 0), Point(5, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_5', cells: const [Point(3, 0), Point(3, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_6', cells: const [Point(4, 4), Point(3, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_7', cells: const [Point(0, 4), Point(1, 4), Point(1, 3), Point(2, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_8', cells: const [Point(6, 3), Point(6, 2), Point(5, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_9', cells: const [Point(4, 1), Point(4, 2), Point(3, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_10', cells: const [Point(0, 3), Point(0, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_11', cells: const [Point(0, 1), Point(0, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_12', cells: const [Point(4, 3), Point(5, 3), Point(5, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_13', cells: const [Point(4, 5), Point(5, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_14', cells: const [Point(6, 4), Point(6, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l2_15', cells: const [Point(3, 6), Point(4, 6), Point(5, 6), Point(6, 6)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 3: عادي • تشابك خفيف (8x8 | n=16 | free0=2 | depth=13 | E=147.5)
      LevelConfig(
        levelNumber: 3,
        difficultyLabel: 'عادي • تشابك خفيف',
        gridCols: 8,
        gridRows: 8,
        stageTheme: StageVisualTheme.clean,
        arrows: [
          ArrowItem(id: 'l3_1', cells: const [Point(1, 1), Point(0, 1), Point(0, 0), Point(1, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_2', cells: const [Point(7, 0), Point(7, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_3', cells: const [Point(7, 2), Point(7, 3), Point(6, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_4', cells: const [Point(1, 2), Point(1, 3), Point(0, 3), Point(0, 4), Point(1, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_5', cells: const [Point(1, 5), Point(2, 5), Point(2, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_6', cells: const [Point(2, 0), Point(3, 0), Point(3, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_7', cells: const [Point(3, 4), Point(3, 5), Point(3, 6), Point(4, 6), Point(4, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_8', cells: const [Point(4, 1), Point(5, 1), Point(5, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_9', cells: const [Point(5, 6), Point(6, 6), Point(6, 7), Point(5, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_10', cells: const [Point(4, 7), Point(3, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_11', cells: const [Point(2, 7), Point(2, 6), Point(1, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_12', cells: const [Point(0, 5), Point(0, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_13', cells: const [Point(1, 7), Point(0, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_14', cells: const [Point(4, 3), Point(4, 4), Point(5, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_15', cells: const [Point(6, 5), Point(6, 4), Point(7, 4), Point(7, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l3_16', cells: const [Point(7, 6), Point(7, 7)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 4: عادي • مسار متداخل (9x9 | n=20 | free0=2 | depth=18 | E=194.5)
      LevelConfig(
        levelNumber: 4,
        difficultyLabel: 'عادي • مسار متداخل',
        gridCols: 9,
        gridRows: 9,
        stageTheme: StageVisualTheme.clean,
        arrows: [
          ArrowItem(id: 'l4_1', cells: const [Point(8, 2), Point(8, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_2', cells: const [Point(7, 7), Point(8, 7), Point(8, 8), Point(7, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_3', cells: const [Point(5, 7), Point(5, 8), Point(6, 8), Point(6, 7), Point(6, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_4', cells: const [Point(6, 3), Point(5, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_5', cells: const [Point(3, 2), Point(3, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_6', cells: const [Point(3, 8), Point(3, 7), Point(2, 7), Point(2, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_7', cells: const [Point(2, 1), Point(1, 1), Point(1, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_8', cells: const [Point(2, 3), Point(2, 4), Point(1, 4), Point(1, 5), Point(2, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_9', cells: const [Point(4, 6), Point(4, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_10', cells: const [Point(3, 5), Point(3, 4), Point(4, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_11', cells: const [Point(8, 4), Point(8, 5), Point(7, 5), Point(7, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_12', cells: const [Point(8, 1), Point(8, 0), Point(7, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_13', cells: const [Point(6, 0), Point(5, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_14', cells: const [Point(1, 0), Point(0, 0), Point(0, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_15', cells: const [Point(0, 2), Point(0, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_16', cells: const [Point(0, 4), Point(0, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_17', cells: const [Point(1, 6), Point(0, 6), Point(0, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_18', cells: const [Point(1, 7), Point(1, 8), Point(0, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_19', cells: const [Point(4, 3), Point(4, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l4_20', cells: const [Point(5, 2), Point(5, 1), Point(4, 1), Point(4, 0)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 5: متوسط • المتاهة (10x10 | n=22 | free0=2 | depth=19 | E=201.8)
      LevelConfig(
        levelNumber: 5,
        difficultyLabel: 'متوسط • المتاهة',
        gridCols: 10,
        gridRows: 10,
        stageTheme: StageVisualTheme.ocean,
        arrows: [
          ArrowItem(id: 'l5_1', cells: const [Point(2, 6), Point(3, 6), Point(3, 5)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l5_2', cells: const [Point(2, 4), Point(3, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_3', cells: const [Point(8, 3), Point(8, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_4', cells: const [Point(9, 7), Point(8, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_5', cells: const [Point(1, 7), Point(1, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_6', cells: const [Point(1, 1), Point(1, 2), Point(2, 2), Point(3, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_7', cells: const [Point(6, 1), Point(6, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_8', cells: const [Point(5, 8), Point(6, 8), Point(6, 7), Point(5, 7), Point(5, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_9', cells: const [Point(6, 3), Point(5, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_10', cells: const [Point(3, 3), Point(4, 3), Point(4, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_11', cells: const [Point(3, 8), Point(3, 9), Point(4, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_12', cells: const [Point(8, 8), Point(8, 9), Point(7, 9), Point(7, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_13', cells: const [Point(7, 7), Point(7, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_14', cells: const [Point(8, 1), Point(8, 0), Point(7, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_15', cells: const [Point(2, 0), Point(1, 0), Point(0, 0), Point(0, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_16', cells: const [Point(0, 2), Point(0, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_17', cells: const [Point(1, 4), Point(0, 4), Point(0, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_18', cells: const [Point(0, 6), Point(0, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_19', cells: const [Point(1, 9), Point(1, 8), Point(0, 8), Point(0, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_20', cells: const [Point(8, 5), Point(8, 6), Point(9, 6), Point(9, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_21', cells: const [Point(9, 4), Point(9, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l5_22', cells: const [Point(9, 2), Point(9, 1)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 6: تشكيل القلب ❤️ (10x10 | n=20 | free0=2 | depth=16 | E=168.1)
      LevelConfig(
        levelNumber: 6,
        difficultyLabel: 'تشكيل القلب ❤️',
        gridCols: 10,
        gridRows: 10,
        stageTheme: StageVisualTheme.heart,
        arrows: [
          ArrowItem(id: 'l6_1', cells: const [Point(0, 2), Point(0, 3)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l6_2', cells: const [Point(1, 7), Point(0, 7), Point(0, 6), Point(1, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_3', cells: const [Point(8, 6), Point(8, 5), Point(8, 4), Point(7, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_4', cells: const [Point(2, 3), Point(2, 4)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l6_5', cells: const [Point(2, 7), Point(3, 7), Point(4, 7), Point(4, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_6', cells: const [Point(3, 3), Point(4, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_7', cells: const [Point(9, 3), Point(9, 4)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l6_8', cells: const [Point(9, 5), Point(9, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_9', cells: const [Point(9, 7), Point(8, 7), Point(7, 7), Point(7, 8), Point(6, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_10', cells: const [Point(4, 9), Point(5, 9), Point(5, 8)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l6_11', cells: const [Point(5, 7), Point(6, 7), Point(6, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_12', cells: const [Point(6, 1), Point(5, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_13', cells: const [Point(3, 1), Point(3, 2), Point(4, 2)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l6_14', cells: const [Point(5, 2), Point(6, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_15', cells: const [Point(6, 3), Point(7, 3), Point(7, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_16', cells: const [Point(7, 1), Point(8, 1)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l6_17', cells: const [Point(7, 5), Point(6, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_18', cells: const [Point(1, 5), Point(1, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l6_19', cells: const [Point(1, 3), Point(1, 2)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l6_20', cells: const [Point(2, 2), Point(2, 1), Point(1, 1)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 7: صعب • عقدة المسار (10x10 | n=23 | free0=2 | depth=18 | E=202.9)
      LevelConfig(
        levelNumber: 7,
        difficultyLabel: 'صعب • عقدة المسار',
        gridCols: 10,
        gridRows: 10,
        stageTheme: StageVisualTheme.ocean,
        arrows: [
          ArrowItem(id: 'l7_1', cells: const [Point(7, 5), Point(6, 5)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l7_2', cells: const [Point(1, 5), Point(1, 6), Point(0, 6), Point(0, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_3', cells: const [Point(0, 3), Point(0, 4), Point(1, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_4', cells: const [Point(7, 3), Point(8, 3), Point(8, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_5', cells: const [Point(9, 9), Point(9, 8), Point(8, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_6', cells: const [Point(7, 8), Point(6, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_7', cells: const [Point(4, 9), Point(5, 9), Point(5, 8), Point(4, 8), Point(4, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_8', cells: const [Point(3, 6), Point(4, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_9', cells: const [Point(9, 6), Point(9, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_10', cells: const [Point(8, 2), Point(8, 1), Point(9, 1), Point(9, 0), Point(8, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_11', cells: const [Point(6, 1), Point(6, 0), Point(5, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_12', cells: const [Point(2, 0), Point(2, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_13', cells: const [Point(1, 3), Point(2, 3), Point(2, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_14', cells: const [Point(3, 4), Point(3, 5), Point(2, 5), Point(2, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_15', cells: const [Point(3, 7), Point(3, 8), Point(2, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_16', cells: const [Point(2, 7), Point(1, 7), Point(1, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_17', cells: const [Point(2, 9), Point(1, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_18', cells: const [Point(0, 7), Point(0, 8), Point(0, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_19', cells: const [Point(7, 0), Point(7, 1), Point(7, 2), Point(6, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_20', cells: const [Point(5, 2), Point(4, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_21', cells: const [Point(3, 2), Point(2, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_22', cells: const [Point(1, 2), Point(1, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l7_23', cells: const [Point(1, 0), Point(0, 0)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 8: صعب • الممر الضيق (10x10 | n=20 | free0=1 | depth=20 | E=207.3)
      LevelConfig(
        levelNumber: 8,
        difficultyLabel: 'صعب • الممر الضيق',
        gridCols: 10,
        gridRows: 10,
        stageTheme: StageVisualTheme.ocean,
        arrows: [
          ArrowItem(id: 'l8_1', cells: const [Point(0, 7), Point(0, 6)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l8_2', cells: const [Point(0, 2), Point(1, 2), Point(1, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_3', cells: const [Point(0, 4), Point(0, 5), Point(1, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_4', cells: const [Point(4, 6), Point(5, 6), Point(5, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_5', cells: const [Point(5, 2), Point(6, 2), Point(6, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_6', cells: const [Point(6, 8), Point(6, 9), Point(5, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_7', cells: const [Point(2, 9), Point(2, 8), Point(2, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_8', cells: const [Point(2, 6), Point(2, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_9', cells: const [Point(1, 1), Point(2, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_10', cells: const [Point(8, 1), Point(9, 1), Point(9, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_11', cells: const [Point(9, 3), Point(9, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_12', cells: const [Point(9, 5), Point(8, 5), Point(8, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_13', cells: const [Point(8, 9), Point(7, 9), Point(7, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_14', cells: const [Point(6, 1), Point(7, 1), Point(7, 0), Point(6, 0), Point(5, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_15', cells: const [Point(2, 0), Point(3, 0), Point(3, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_16', cells: const [Point(3, 3), Point(3, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_17', cells: const [Point(3, 8), Point(3, 7), Point(4, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_18', cells: const [Point(4, 8), Point(5, 8), Point(5, 7), Point(6, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_19', cells: const [Point(9, 6), Point(9, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l8_20', cells: const [Point(8, 7), Point(8, 8), Point(9, 8)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 9: صعب • الشبكة المقفلة (10x10 | n=22 | free0=2 | depth=17 | E=186.4)
      LevelConfig(
        levelNumber: 9,
        difficultyLabel: 'صعب • الشبكة المقفلة',
        gridCols: 10,
        gridRows: 10,
        stageTheme: StageVisualTheme.ocean,
        arrows: [
          ArrowItem(id: 'l9_1', cells: const [Point(0, 3), Point(0, 2), Point(1, 2)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l9_2', cells: const [Point(7, 2), Point(8, 2), Point(8, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_3', cells: const [Point(8, 4), Point(7, 4), Point(6, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_4', cells: const [Point(4, 3), Point(4, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_5', cells: const [Point(3, 5), Point(4, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_6', cells: const [Point(8, 6), Point(9, 6), Point(9, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_7', cells: const [Point(8, 0), Point(9, 0), Point(9, 1), Point(8, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_8', cells: const [Point(6, 1), Point(7, 1), Point(7, 0), Point(6, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_9', cells: const [Point(5, 0), Point(5, 1), Point(5, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_10', cells: const [Point(6, 9), Point(6, 8), Point(5, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_11', cells: const [Point(2, 8), Point(2, 7), Point(2, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_12', cells: const [Point(2, 5), Point(2, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_13', cells: const [Point(2, 3), Point(1, 3), Point(1, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_14', cells: const [Point(1, 5), Point(0, 5), Point(0, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_15', cells: const [Point(0, 7), Point(1, 7), Point(1, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_16', cells: const [Point(2, 9), Point(1, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_17', cells: const [Point(0, 8), Point(0, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_18', cells: const [Point(3, 8), Point(3, 7), Point(4, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_19', cells: const [Point(5, 6), Point(5, 7), Point(6, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_20', cells: const [Point(7, 6), Point(7, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_21', cells: const [Point(7, 8), Point(7, 9), Point(8, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l9_22', cells: const [Point(9, 8), Point(9, 9)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 10: تشكيل النجمة ⭐ (11x11 | n=14 | free0=3 | depth=9 | E=96.0)
      LevelConfig(
        levelNumber: 10,
        difficultyLabel: 'تشكيل النجمة ⭐',
        gridCols: 11,
        gridRows: 11,
        stageTheme: StageVisualTheme.star,
        arrows: [
          ArrowItem(id: 'l10_1', cells: const [Point(5, 2), Point(4, 2), Point(4, 3), Point(5, 3)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l10_2', cells: const [Point(9, 3), Point(8, 3), Point(8, 4), Point(8, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l10_3', cells: const [Point(8, 8), Point(8, 9), Point(7, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l10_4', cells: const [Point(2, 9), Point(3, 9), Point(3, 8)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l10_5', cells: const [Point(4, 6), Point(3, 6), Point(3, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l10_6', cells: const [Point(4, 4), Point(3, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l10_7', cells: const [Point(2, 5), Point(2, 4), Point(2, 3), Point(1, 3), Point(1, 4)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l10_8', cells: const [Point(3, 7), Point(4, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l10_9', cells: const [Point(6, 8), Point(6, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l10_10', cells: const [Point(6, 6), Point(7, 6), Point(7, 5)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l10_11', cells: const [Point(7, 4), Point(6, 4), Point(6, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l10_12', cells: const [Point(6, 1), Point(5, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l10_13', cells: const [Point(5, 4), Point(5, 5)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l10_14', cells: const [Point(5, 6), Point(5, 7)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 11: صعب • تقاطع الأسهم (10x10 | n=22 | free0=2 | depth=19 | E=222.3)
      LevelConfig(
        levelNumber: 11,
        difficultyLabel: 'صعب • تقاطع الأسهم',
        gridCols: 10,
        gridRows: 10,
        stageTheme: StageVisualTheme.ocean,
        arrows: [
          ArrowItem(id: 'l11_1', cells: const [Point(8, 3), Point(7, 3)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l11_2', cells: const [Point(2, 2), Point(3, 2), Point(3, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_3', cells: const [Point(2, 3), Point(2, 4), Point(3, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_4', cells: const [Point(5, 2), Point(5, 3), Point(4, 3), Point(4, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_5', cells: const [Point(3, 9), Point(4, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_6', cells: const [Point(8, 8), Point(8, 9), Point(7, 9), Point(7, 8), Point(6, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_7', cells: const [Point(3, 8), Point(3, 7), Point(4, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_8', cells: const [Point(9, 8), Point(9, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_9', cells: const [Point(9, 6), Point(8, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_10', cells: const [Point(6, 6), Point(5, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_11', cells: const [Point(4, 6), Point(3, 6), Point(3, 5), Point(4, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_12', cells: const [Point(7, 5), Point(6, 5), Point(6, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_13', cells: const [Point(6, 1), Point(7, 1), Point(7, 0), Point(6, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_14', cells: const [Point(3, 1), Point(2, 1), Point(2, 0), Point(1, 0), Point(1, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_15', cells: const [Point(0, 2), Point(1, 2), Point(1, 3), Point(0, 3), Point(0, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_16', cells: const [Point(0, 5), Point(1, 5), Point(2, 5), Point(2, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_17', cells: const [Point(2, 8), Point(1, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_18', cells: const [Point(1, 6), Point(1, 7), Point(0, 7), Point(0, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_19', cells: const [Point(1, 9), Point(0, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_20', cells: const [Point(8, 4), Point(8, 5), Point(9, 5), Point(9, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_21', cells: const [Point(9, 3), Point(9, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l11_22', cells: const [Point(7, 2), Point(8, 2), Point(8, 1), Point(9, 1), Point(9, 0)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 12: القلب الكبير ❤️ (11x11 | n=22 | free0=2 | depth=18 | E=200.0)
      LevelConfig(
        levelNumber: 12,
        difficultyLabel: 'القلب الكبير ❤️',
        gridCols: 11,
        gridRows: 11,
        stageTheme: StageVisualTheme.heart,
        arrows: [
          ArrowItem(id: 'l12_1', cells: const [Point(10, 7), Point(10, 8), Point(9, 8)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l12_2', cells: const [Point(4, 9), Point(4, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_3', cells: const [Point(4, 1), Point(5, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_4', cells: const [Point(6, 1), Point(6, 2)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l12_5', cells: const [Point(6, 3), Point(7, 3), Point(8, 3), Point(8, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_6', cells: const [Point(8, 5), Point(7, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_7', cells: const [Point(7, 4), Point(6, 4), Point(6, 5)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l12_8', cells: const [Point(6, 9), Point(7, 9), Point(7, 10), Point(6, 10)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_9', cells: const [Point(4, 10), Point(3, 10), Point(3, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_10', cells: const [Point(2, 9), Point(2, 8), Point(3, 8), Point(3, 7)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l12_11', cells: const [Point(4, 7), Point(4, 6), Point(3, 6), Point(3, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_12', cells: const [Point(3, 2), Point(4, 2), Point(5, 2), Point(5, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_13', cells: const [Point(4, 5), Point(4, 4), Point(5, 4), Point(5, 5)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l12_14', cells: const [Point(6, 7), Point(5, 7), Point(5, 6), Point(6, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_15', cells: const [Point(9, 7), Point(9, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_16', cells: const [Point(10, 5), Point(9, 5), Point(9, 4)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l12_17', cells: const [Point(9, 3), Point(9, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_18', cells: const [Point(8, 1), Point(9, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_19', cells: const [Point(1, 3), Point(1, 4)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l12_20', cells: const [Point(1, 6), Point(0, 6), Point(0, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_21', cells: const [Point(0, 4), Point(0, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l12_22', cells: const [Point(0, 2), Point(1, 2), Point(2, 2), Point(2, 1)], badge: ArrowBadgeStyle.heart),
        ],
      ),
      // المستوى 13: صعب • الحصار (11x11 | n=22 | free0=1 | depth=22 | E=235.0)
      LevelConfig(
        levelNumber: 13,
        difficultyLabel: 'صعب • الحصار',
        gridCols: 11,
        gridRows: 11,
        stageTheme: StageVisualTheme.ocean,
        arrows: [
          ArrowItem(id: 'l13_1', cells: const [Point(3, 6), Point(4, 6)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l13_2', cells: const [Point(7, 5), Point(7, 6), Point(8, 6), Point(8, 7), Point(7, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_3', cells: const [Point(1, 7), Point(1, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_4', cells: const [Point(0, 3), Point(1, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_5', cells: const [Point(7, 3), Point(8, 3), Point(8, 4), Point(7, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_6', cells: const [Point(3, 4), Point(2, 4), Point(2, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_7', cells: const [Point(2, 7), Point(2, 8), Point(3, 8), Point(4, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_8', cells: const [Point(8, 8), Point(9, 8), Point(9, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_9', cells: const [Point(9, 6), Point(9, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_10', cells: const [Point(9, 2), Point(8, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_11', cells: const [Point(4, 3), Point(5, 3), Point(5, 2), Point(6, 2), Point(6, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_12', cells: const [Point(5, 5), Point(5, 4), Point(6, 4), Point(6, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_13', cells: const [Point(6, 10), Point(5, 10)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_14', cells: const [Point(0, 10), Point(0, 9), Point(1, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_15', cells: const [Point(3, 10), Point(3, 9), Point(4, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_16', cells: const [Point(10, 10), Point(10, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_17', cells: const [Point(10, 2), Point(10, 1), Point(9, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_18', cells: const [Point(1, 1), Point(1, 0), Point(2, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_19', cells: const [Point(3, 1), Point(3, 0), Point(4, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_20', cells: const [Point(5, 1), Point(5, 0), Point(6, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_21', cells: const [Point(7, 1), Point(7, 0), Point(8, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l13_22', cells: const [Point(9, 0), Point(10, 0)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 14: صعب • المتاهة العميقة (11x11 | n=24 | free0=2 | depth=19 | E=223.3)
      LevelConfig(
        levelNumber: 14,
        difficultyLabel: 'صعب • المتاهة العميقة',
        gridCols: 11,
        gridRows: 11,
        stageTheme: StageVisualTheme.ocean,
        arrows: [
          ArrowItem(id: 'l14_1', cells: const [Point(5, 6), Point(6, 6), Point(6, 5)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l14_2', cells: const [Point(6, 3), Point(6, 4), Point(5, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_3', cells: const [Point(1, 4), Point(1, 3), Point(1, 2), Point(2, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_4', cells: const [Point(8, 2), Point(7, 2), Point(7, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_5', cells: const [Point(6, 9), Point(7, 9), Point(7, 8), Point(6, 8), Point(5, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_6', cells: const [Point(1, 9), Point(1, 8), Point(0, 8), Point(0, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_7', cells: const [Point(1, 1), Point(0, 1), Point(0, 0), Point(1, 0), Point(2, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_8', cells: const [Point(4, 0), Point(4, 1), Point(5, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_9', cells: const [Point(10, 1), Point(10, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_10', cells: const [Point(10, 3), Point(9, 3), Point(9, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_11', cells: const [Point(9, 10), Point(8, 10), Point(7, 10)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_12', cells: const [Point(3, 10), Point(3, 9), Point(3, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_13', cells: const [Point(2, 1), Point(3, 1), Point(3, 2), Point(4, 2), Point(4, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_14', cells: const [Point(2, 3), Point(3, 3), Point(3, 4), Point(4, 4), Point(4, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_15', cells: const [Point(4, 6), Point(4, 7), Point(5, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_16', cells: const [Point(6, 7), Point(7, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_17', cells: const [Point(9, 6), Point(10, 6), Point(10, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_18', cells: const [Point(10, 8), Point(9, 8), Point(8, 8), Point(8, 9), Point(9, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_19', cells: const [Point(10, 9), Point(10, 10)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_20', cells: const [Point(2, 4), Point(2, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_21', cells: const [Point(3, 6), Point(2, 6), Point(2, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_22', cells: const [Point(2, 8), Point(2, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_23', cells: const [Point(2, 10), Point(1, 10)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l14_24', cells: const [Point(0, 9), Point(0, 10)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 15: تشكيل الماسة 💎 (11x11 | n=16 | free0=2 | depth=15 | E=154.6)
      LevelConfig(
        levelNumber: 15,
        difficultyLabel: 'تشكيل الماسة 💎',
        gridCols: 11,
        gridRows: 11,
        stageTheme: StageVisualTheme.diamond,
        arrows: [
          ArrowItem(id: 'l15_1', cells: const [Point(9, 3), Point(9, 4), Point(8, 4)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l15_2', cells: const [Point(6, 4), Point(6, 3), Point(6, 2), Point(5, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l15_3', cells: const [Point(4, 2), Point(4, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l15_4', cells: const [Point(3, 5), Point(4, 5)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l15_5', cells: const [Point(4, 4), Point(5, 4), Point(5, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l15_6', cells: const [Point(6, 9), Point(5, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l15_7', cells: const [Point(4, 9), Point(3, 9), Point(3, 8), Point(4, 8)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l15_8', cells: const [Point(8, 8), Point(7, 8), Point(7, 7), Point(6, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l15_9', cells: const [Point(1, 7), Point(1, 6), Point(1, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l15_10', cells: const [Point(1, 4), Point(2, 4), Point(2, 5)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l15_11', cells: const [Point(2, 7), Point(2, 6), Point(3, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l15_12', cells: const [Point(4, 6), Point(5, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l15_13', cells: const [Point(8, 6), Point(7, 6), Point(7, 5)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l15_14', cells: const [Point(7, 2), Point(7, 1), Point(6, 1), Point(5, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l15_15', cells: const [Point(3, 2), Point(3, 1), Point(4, 1), Point(4, 0), Point(5, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l15_16', cells: const [Point(0, 4), Point(0, 5)], badge: ArrowBadgeStyle.star),
        ],
      ),
      // المستوى 16: محترف • الشفق (11x11 | n=23 | free0=2 | depth=21 | E=221.7)
      LevelConfig(
        levelNumber: 16,
        difficultyLabel: 'محترف • الشفق',
        gridCols: 11,
        gridRows: 11,
        stageTheme: StageVisualTheme.twilight,
        arrows: [
          ArrowItem(id: 'l16_1', cells: const [Point(10, 0), Point(10, 1)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l16_2', cells: const [Point(10, 10), Point(9, 10)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_3', cells: const [Point(7, 10), Point(7, 9), Point(6, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_4', cells: const [Point(2, 10), Point(3, 10), Point(3, 9), Point(4, 9), Point(4, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_5', cells: const [Point(3, 3), Point(4, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_6', cells: const [Point(6, 3), Point(5, 3), Point(5, 4), Point(5, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_7', cells: const [Point(6, 7), Point(6, 6), Point(5, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_8', cells: const [Point(1, 6), Point(1, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_9', cells: const [Point(1, 4), Point(0, 4), Point(0, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_10', cells: const [Point(0, 9), Point(1, 9), Point(2, 9), Point(2, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_11', cells: const [Point(1, 7), Point(2, 7), Point(2, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_12', cells: const [Point(1, 2), Point(2, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_13', cells: const [Point(4, 2), Point(5, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_14', cells: const [Point(8, 1), Point(8, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_15', cells: const [Point(7, 8), Point(8, 8), Point(8, 9), Point(9, 9), Point(9, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_16', cells: const [Point(9, 7), Point(9, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_17', cells: const [Point(9, 0), Point(8, 0), Point(7, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_18', cells: const [Point(6, 1), Point(6, 0), Point(5, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_19', cells: const [Point(4, 1), Point(4, 0), Point(3, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_20', cells: const [Point(2, 1), Point(2, 0), Point(1, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_21', cells: const [Point(1, 1), Point(0, 1), Point(0, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_22', cells: const [Point(6, 4), Point(6, 5), Point(7, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l16_23', cells: const [Point(8, 5), Point(8, 4), Point(8, 3), Point(9, 3)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 17: محترف • القلعة (11x11 | n=25 | free0=2 | depth=22 | E=238.8)
      LevelConfig(
        levelNumber: 17,
        difficultyLabel: 'محترف • القلعة',
        gridCols: 11,
        gridRows: 11,
        stageTheme: StageVisualTheme.twilight,
        arrows: [
          ArrowItem(id: 'l17_1', cells: const [Point(9, 2), Point(9, 1), Point(8, 1)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l17_2', cells: const [Point(3, 1), Point(4, 1), Point(4, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_3', cells: const [Point(4, 10), Point(4, 9), Point(5, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_4', cells: const [Point(7, 9), Point(6, 9), Point(6, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_5', cells: const [Point(6, 6), Point(5, 6), Point(5, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_6', cells: const [Point(6, 5), Point(6, 4), Point(5, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_7', cells: const [Point(0, 4), Point(0, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_8', cells: const [Point(0, 9), Point(1, 9), Point(1, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_9', cells: const [Point(1, 6), Point(2, 6), Point(2, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_10', cells: const [Point(1, 0), Point(2, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_11', cells: const [Point(9, 0), Point(10, 0), Point(10, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_12', cells: const [Point(10, 3), Point(9, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_13', cells: const [Point(9, 4), Point(8, 4), Point(8, 3), Point(7, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_14', cells: const [Point(6, 3), Point(5, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_15', cells: const [Point(4, 3), Point(3, 3), Point(3, 4), Point(3, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_16', cells: const [Point(2, 7), Point(3, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_17', cells: const [Point(3, 6), Point(4, 6), Point(4, 7), Point(5, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_18', cells: const [Point(9, 6), Point(8, 6), Point(8, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_19', cells: const [Point(6, 7), Point(7, 7), Point(7, 8), Point(8, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_20', cells: const [Point(10, 8), Point(10, 7), Point(9, 7), Point(9, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_21', cells: const [Point(9, 10), Point(8, 10), Point(8, 9), Point(9, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_22', cells: const [Point(10, 9), Point(10, 10)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_23', cells: const [Point(3, 2), Point(2, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_24', cells: const [Point(0, 3), Point(0, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l17_25', cells: const [Point(1, 1), Point(0, 1)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 18: نجمة السماء ⭐ (12x12 | n=15 | free0=3 | depth=13 | E=124.4)
      LevelConfig(
        levelNumber: 18,
        difficultyLabel: 'نجمة السماء ⭐',
        gridCols: 12,
        gridRows: 12,
        stageTheme: StageVisualTheme.star,
        arrows: [
          ArrowItem(id: 'l18_1', cells: const [Point(6, 1), Point(6, 0), Point(5, 0)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l18_2', cells: const [Point(2, 4), Point(3, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l18_3', cells: const [Point(5, 4), Point(6, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l18_4', cells: const [Point(7, 4), Point(7, 5)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l18_5', cells: const [Point(7, 7), Point(7, 6), Point(6, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l18_6', cells: const [Point(5, 5), Point(5, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l18_7', cells: const [Point(6, 7), Point(5, 7)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l18_8', cells: const [Point(4, 7), Point(3, 7), Point(3, 8), Point(4, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l18_9', cells: const [Point(5, 8), Point(6, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l18_10', cells: const [Point(8, 9), Point(7, 9), Point(7, 8), Point(8, 8), Point(8, 7)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l18_11', cells: const [Point(8, 6), Point(8, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l18_12', cells: const [Point(8, 4), Point(9, 4), Point(9, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l18_13', cells: const [Point(9, 10), Point(8, 10)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l18_14', cells: const [Point(2, 10), Point(3, 10), Point(3, 9), Point(2, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l18_15', cells: const [Point(5, 1), Point(5, 2), Point(6, 2)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 19: محترف • التحدي الأقصى (12x12 | n=25 | free0=1 | depth=25 | E=257.6)
      LevelConfig(
        levelNumber: 19,
        difficultyLabel: 'محترف • التحدي الأقصى',
        gridCols: 12,
        gridRows: 12,
        stageTheme: StageVisualTheme.twilight,
        arrows: [
          ArrowItem(id: 'l19_1', cells: const [Point(3, 11), Point(4, 11), Point(4, 10), Point(5, 10)], badge: ArrowBadgeStyle.heart),
          ArrowItem(id: 'l19_2', cells: const [Point(8, 11), Point(8, 10)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_3', cells: const [Point(9, 2), Point(9, 3), Point(8, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_4', cells: const [Point(1, 4), Point(1, 3), Point(0, 3), Point(0, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_5', cells: const [Point(0, 5), Point(0, 6), Point(1, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_6', cells: const [Point(11, 6), Point(11, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_7', cells: const [Point(11, 1), Point(10, 1), Point(9, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_8', cells: const [Point(3, 1), Point(2, 1), Point(2, 0), Point(3, 0)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_9', cells: const [Point(6, 0), Point(6, 1)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_10', cells: const [Point(6, 10), Point(7, 10), Point(7, 9)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_11', cells: const [Point(6, 3), Point(7, 3), Point(7, 2), Point(6, 2)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_12', cells: const [Point(3, 2), Point(2, 2), Point(2, 3)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_13', cells: const [Point(2, 5), Point(2, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_14', cells: const [Point(2, 9), Point(2, 8), Point(3, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_15', cells: const [Point(5, 8), Point(6, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_16', cells: const [Point(9, 8), Point(9, 7), Point(8, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_17', cells: const [Point(6, 7), Point(5, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_18', cells: const [Point(4, 9), Point(4, 8), Point(4, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_19', cells: const [Point(4, 4), Point(5, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_20', cells: const [Point(10, 3), Point(10, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_21', cells: const [Point(9, 5), Point(10, 5), Point(10, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_22', cells: const [Point(10, 7), Point(10, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_23', cells: const [Point(10, 10), Point(10, 9), Point(9, 9), Point(9, 10)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_24', cells: const [Point(9, 11), Point(10, 11)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l19_25', cells: const [Point(11, 10), Point(11, 11)], badge: ArrowBadgeStyle.none),
        ],
      ),
      // المستوى 20: التاج الملكي 👑 (12x12 | n=16 | free0=2 | depth=14 | E=152.4)
      LevelConfig(
        levelNumber: 20,
        difficultyLabel: 'التاج الملكي 👑',
        gridCols: 12,
        gridRows: 12,
        stageTheme: StageVisualTheme.crown,
        arrows: [
          ArrowItem(id: 'l20_1', cells: const [Point(6, 8), Point(6, 9), Point(5, 9)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l20_2', cells: const [Point(0, 9), Point(0, 8), Point(0, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l20_3', cells: const [Point(0, 6), Point(0, 5), Point(1, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l20_4', cells: const [Point(5, 5), Point(5, 6), Point(6, 6)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l20_5', cells: const [Point(6, 7), Point(7, 7), Point(7, 6)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l20_6', cells: const [Point(6, 5), Point(7, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l20_7', cells: const [Point(11, 7), Point(11, 6), Point(11, 5), Point(10, 5), Point(10, 6)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l20_8', cells: const [Point(10, 8), Point(10, 9), Point(9, 9), Point(9, 8)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l20_9', cells: const [Point(8, 5), Point(8, 6), Point(9, 6), Point(9, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l20_10', cells: const [Point(10, 4), Point(9, 4)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l20_11', cells: const [Point(6, 4), Point(5, 4)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l20_12', cells: const [Point(1, 4), Point(2, 4), Point(2, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l20_13', cells: const [Point(2, 8), Point(2, 9), Point(3, 9), Point(4, 9), Point(4, 8)], badge: ArrowBadgeStyle.star),
          ArrowItem(id: 'l20_14', cells: const [Point(3, 6), Point(4, 6), Point(4, 5)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l20_15', cells: const [Point(2, 7), Point(2, 6), Point(1, 6), Point(1, 7)], badge: ArrowBadgeStyle.none),
          ArrowItem(id: 'l20_16', cells: const [Point(1, 8), Point(1, 9)], badge: ArrowBadgeStyle.star),
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

  // هل اللاعب في الصفحة الرئيسية أم داخل اللعب؟
  bool _isInHomeScreen = true;

  late List<ArrowItem> _activeArrows;
  int _hearts = 3;
  int _hintsCount = 3;
  bool _rulerEnabled = false;
  String? _hintedArrowId;

  // تحريك السهم عند الخروج أو الاصطدام (يعمل فقط لحظة لمس السهم لتوفير البطارية 100%)
  String? _animatingArrowId;
  bool _isBlockedAnimation = false;
  double _blockedMaxSteps = 0.25;
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
    );

    // لا يعمل _sunburstController إلا عند فتح شاشة الفوز فقط لتوفير البطارية!
    _sunburstController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    );

    _loadLevel(_currentLevelIndex, stayInHome: true);
  }

  @override
  void dispose() {
    _moveController.dispose();
    _sunburstController.dispose();
    super.dispose();
  }

  void _loadLevel(int index, {bool stayInHome = false}) {
    _moveController.stop();
    _moveController.reset();
    _sunburstController.stop();
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
      if (!stayInHome) {
        _isInHomeScreen = false;
      }
    });
  }

  void _goToHomeScreen() {
    _moveController.stop();
    _sunburstController.stop();
    setState(() {
      _isInHomeScreen = true;
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
    if (_moveController.isAnimating) return;

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
    final durationMs = (totalCells * 28).clamp(320, 620);
    _moveController.duration = Duration(milliseconds: durationMs);
    _moveController.forward(from: 0).then((_) {
      if (!mounted || _animatingArrowId != arrow.id) return;
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
      _sunburstController.repeat();
      setState(() {
        _isLevelCompleted = true;
      });
    }
  }

  void _onArrowTapped(ArrowItem arrow) {
    if (_animatingArrowId != null ||
        _moveController.isAnimating ||
        arrow.isCleared ||
        _isLevelCompleted) {
      return;
    }

    final freeSteps = _freeCellsAhead(arrow);
    final free = freeSteps == -1;

    if (free) {
      _launchFreeArrow(arrow);
    } else {
      final wasAlreadyQueued = arrow.isQueuedRed;
      setState(() {
        arrow.isQueuedRed = true;
        _animatingArrowId = arrow.id;
        _isBlockedAnimation = true;
        _blockedMaxSteps = freeSteps + 0.36;
        if (_hintedArrowId == arrow.id) {
          _hintedArrowId = null;
        }
      });

      if (_vibrationEnabled) HapticFeedback.heavyImpact();
      _moveController.duration = const Duration(milliseconds: 320);
      _moveController.forward(from: 0).then((_) {
        if (!mounted || _animatingArrowId != arrow.id) return;
        setState(() {
          _animatingArrowId = null;
          _isBlockedAnimation = false;
          if (!wasAlreadyQueued) {
            _hearts = math.max(0, _hearts - 1);
          }
        });
        if (_hearts == 0) {
          _showOutOfHeartsDialog();
        }
      });
    }
  }

  void _useHint() {
    if (_animatingArrowId != null || _isLevelCompleted) return;

    if (_hintsCount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          content: const Text(
            'انتهت التلميحات! اضغط للحصول على تلميحات مجانية.',
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
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
            'اصطدمت الأسهم ببعضها 3 مرات.\nابحث عن السهم الوحيد المفتوح في البداية لفك عقدة المتاهة!',
            textAlign: TextAlign.center,
            style:
                TextStyle(fontSize: 16, color: Color(0xFF4B5563), height: 1.4),
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
      ),
    );
  }

  void _openLevelsSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (ctx) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
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
                  'اختر المستوى (1 - 20)',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _allLevels.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemBuilder: (context, idx) {
                    final isCurrent = idx == _currentLevelIndex;
                    final palette =
                        StagePalette.of(_allLevels[idx].stageTheme);
                    final shapeEmoji = palette.badgeEmoji;

                    return InkWell(
                      onTap: () {
                        Navigator.pop(ctx);
                        _loadLevel(idx);
                      },
                      borderRadius: BorderRadius.circular(16),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: isCurrent
                              ? LinearGradient(
                                  colors: [
                                    palette.progressColor,
                                    const Color(0xFF1565C0)
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isCurrent ? null : palette.bgBottom,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFF1565C0)
                                : const Color(0xFFDBEAFE),
                            width: 1.5,
                          ),
                        ),
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${idx + 1}',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                height: 1.1,
                                color: isCurrent
                                    ? Colors.white
                                    : const Color(0xFF1E3A8A),
                              ),
                            ),
                            if (shapeEmoji != null)
                              Text(
                                shapeEmoji,
                                style: const TextStyle(fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
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

  void _showAboutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Row(
            children: [
              Icon(Icons.auto_awesome_rounded, color: Color(0xFF1976D2)),
              SizedBox(width: 10),
              Text(
                'حول لعبة مسار الأسهم',
                style: TextStyle(fontWeight: FontWeight.w800, fontSize: 20),
              ),
            ],
          ),
          content: const Text(
            'لعبة ألغاز منطقية تعتمد على التركيز وترتيب خطوات تفكيك الأسهم المتشابكة ذات المسار العميق دون اصطدام.\n\n'
            '• تضم 20 مستوى متدرج الصعوبة بشبكات كثيفة (حتى 12×12 و26 سهماً متداخلاً).\n'
            '• كل مستوى يبدأ بسهم أو سهمين مفتوحين فقط لفتح سلسلة المتاهة بالكامل.\n'
            '• مزودة بمجموعات بصرية متنوعة وتشكيلات القلب ❤️ والنجمة ⭐ والماسة 💎 والتاج 👑.',
            style:
                TextStyle(fontSize: 16, height: 1.5, color: Color(0xFF374151)),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'حسناً',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // إصلاح زر الرجوع في أندرويد: إذا كان اللاعب داخل المستوى أو شاشة الفوز، يعود للرئيسية بدلاً من قفل اللعبة!
    return PopScope(
      canPop: _isInHomeScreen,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_isInHomeScreen) {
          _goToHomeScreen();
        }
      },
      child: _buildCurrentView(context),
    );
  }

  Widget _buildCurrentView(BuildContext context) {
    if (_isInHomeScreen) {
      return _buildHomeScreen();
    }

    if (_isLevelCompleted) {
      return _buildVictoryScreen();
    }

    final palette = StagePalette.of(_currentConfig.stageTheme);

    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        body: AnimatedContainer(
          duration: const Duration(milliseconds: 450),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [palette.bgTop, palette.bgBottom],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 1. الهيدر العلوي: الإعدادات والرئيسية يسار | المستوى والصعوبة وسط | اختيار المستوى يمين
                Padding(
                  padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            onPressed: _openSettingsModal,
                            icon: Icon(
                              Icons.settings_outlined,
                              color: palette.progressColor,
                              size: 30,
                            ),
                            tooltip: 'الإعدادات',
                          ),
                          IconButton(
                            onPressed: _goToHomeScreen,
                            icon: Icon(
                              Icons.home_outlined,
                              color: palette.progressColor,
                              size: 30,
                            ),
                            tooltip: 'الرئيسية',
                          ),
                        ],
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
                              style: TextStyle(
                                fontSize: 14,
                                color: palette.progressColor.withOpacity(0.85),
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        onPressed: _openLevelsSelector,
                        icon: Icon(
                          Icons.grid_view_rounded,
                          color: palette.progressColor,
                          size: 29,
                        ),
                        tooltip: 'المستويات',
                      ),
                    ],
                  ),
                ),

                // 2. صف القلوب الثلاثة (ثابت بدون إعادة رسم 60fps لتوفير البطارية 100%)
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
                          duration: const Duration(milliseconds: 240),
                          child: CustomPaint(
                            size: const Size(36, 34),
                            painter: GlossyHeartPainter(
                              isActive: active,
                              glowPulse: 0.6,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),

                const SizedBox(height: 6),

                // 3. شريط التقدم المتناغم مع الطابع البصري للمرحلة
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progressFraction,
                      minHeight: 5,
                      backgroundColor: Colors.black.withOpacity(0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        palette.progressColor,
                      ),
                    ),
                  ),
                ),

                // 4. مساحة شبكة اللعب الكثيفة (Zero Idle Repaints: لا تعيد الرسم إلا لحظة تحرك السهم فقط!)
                Expanded(
                  child: Center(
                    child: AspectRatio(
                      aspectRatio: 1,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                          decoration: BoxDecoration(
                            color: palette.boardCardColor,
                            borderRadius: BorderRadius.circular(26),
                            boxShadow: [
                              BoxShadow(
                                color: palette.boardGlowColor,
                                blurRadius: 28,
                                spreadRadius: 2,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(14.0),
                          child: LayoutBuilder(
                            builder: (context, constraints) {
                              final boardSize =
                                  constraints.biggest.shortestSide;
                              return RepaintBoundary(
                                child: GestureDetector(
                                  behavior: HitTestBehavior.opaque,
                                  onTapUp: (details) => _handleBoardTap(
                                    details.localPosition,
                                    boardSize,
                                  ),
                                  child: AnimatedBuilder(
                                    animation: _moveController,
                                    builder: (context, _) {
                                      return CustomPaint(
                                        size: Size(boardSize, boardSize),
                                        painter: ArrowBoardPainter(
                                          gridCols: _currentConfig.gridCols,
                                          gridRows: _currentConfig.gridRows,
                                          arrows: _activeArrows,
                                          rulerEnabled: _rulerEnabled,
                                          hintedArrowId: _hintedArrowId,
                                          animatingArrowId: _animatingArrowId,
                                          isBlockedAnimation:
                                              _isBlockedAnimation,
                                          blockedMaxSteps: _blockedMaxSteps,
                                          animationValue: Curves.easeOutCubic
                                              .transform(_moveController.value),
                                          palette: palette,
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ),
                ),

                // 5. أزرار الأدوات المساعدة السفلية (توهج ثابت أنيق بدون استنزاف البطارية)
                Padding(
                  padding: const EdgeInsets.only(bottom: 22, top: 6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // زر المسطرة
                      _buildNeumorphicPowerButton(
                        isActive: _rulerEnabled,
                        badgeText: null,
                        ambientGlowColor: const Color(0xFF5C6BC0),
                        glowIntensity: _rulerEnabled ? 0.85 : 0.20,
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
                      // زر اللمبة المضيئة
                      _buildNeumorphicPowerButton(
                        isActive: _hintedArrowId != null,
                        badgeText: '$_hintsCount',
                        ambientGlowColor: const Color(0xFFFFAB3D),
                        glowIntensity: _hintedArrowId != null ? 1.0 : 0.65,
                        onTap: _useHint,
                        customChild: CustomPaint(
                          size: const Size(54, 54),
                          painter: NeonLampBulbPainter(
                            glowPulse: 0.7,
                            isBoosted: _hintedArrowId != null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 6. الشريط السفلي الرمادي الفاتح
                if (!_adsRemoved)
                  Container(
                    width: double.infinity,
                    height: 52,
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
      ),
    );
  }

  /// 🏠 الصفحة الرئيسية البسيطة والاحترافية (بدون أنيميشن لا نهائي يستهلك البطارية)
  Widget _buildHomeScreen() {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFF4F8FF),
                Color(0xFFFFFFFF),
                Color(0xFFEFF6FF),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // 1. في الأعلى: الشعار البصري + اسم اللعبة
                  Column(
                    children: [
                      const SizedBox(height: 24),
                      Container(
                        width: 126,
                        height: 126,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(34),
                          border: Border.all(
                            color: const Color(0xFFDBEAFE),
                            width: 2.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1976D2).withOpacity(0.16),
                              blurRadius: 28,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(22),
                        child: CustomPaint(
                          painter: HomeLogoPainter(pulse: 0.5),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'مسار الأسهم',
                        style: TextStyle(
                          fontSize: 38,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                          letterSpacing: 0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'فكّك الأسهم المتشابكة بذكاء • المستوى ${_currentConfig.levelNumber} من ${_allLevels.length}',
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),

                  // 2. في المنتصف: زر كبير وواضح "▶️ ابدأ اللعب"
                  Column(
                    children: [
                      Container(
                        width: double.infinity,
                        height: 74,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(38),
                          gradient: const LinearGradient(
                            colors: [
                              Color(0xFF2196F3),
                              Color(0xFF1565C0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF1976D2).withOpacity(0.38),
                              blurRadius: 24,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(38),
                            onTap: () {
                              if (_vibrationEnabled) {
                                HapticFeedback.mediumImpact();
                              }
                              setState(() {
                                _isInHomeScreen = false;
                              });
                            },
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 38,
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'ابدأ اللعب',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextButton.icon(
                        onPressed: _openLevelsSelector,
                        icon: const Icon(
                          Icons.grid_view_rounded,
                          size: 20,
                          color: Color(0xFF1976D2),
                        ),
                        label: Text(
                          'اختيار المستوى (1 - ${_allLevels.length})',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF1976D2),
                          ),
                        ),
                      ),
                    ],
                  ),

                  // 3. أسفل الصفحة: أزرار صغيرة ومنظمة (⚙️ الإعدادات | ℹ️ حول اللعبة)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildHomeFooterButton(
                          icon: Icons.settings_rounded,
                          label: 'الإعدادات',
                          onTap: _openSettingsModal,
                        ),
                        const SizedBox(width: 16),
                        _buildHomeFooterButton(
                          icon: Icons.info_outline_rounded,
                          label: 'حول اللعبة',
                          onTap: _showAboutDialog,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHomeFooterButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFE2E8F0), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: const Color(0xFF1E88E5)),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF334155),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// التفاعل الدقيق باللمس
  void _handleBoardTap(Offset localPos, double boardSize) {
    if (_animatingArrowId != null || _moveController.isAnimating) return;

    final cellW = boardSize / _currentConfig.gridCols;
    final cellH = boardSize / _currentConfig.gridRows;

    ArrowItem? bestArrow;
    double minDistance = cellW * 0.58;

    Offset centerOf(Point<int> p) =>
        Offset((p.x + 0.5) * cellW, (p.y + 0.5) * cellH);

    for (final arrow in _activeArrows) {
      if (arrow.isCleared) continue;
      for (int i = 0; i < arrow.cells.length - 1; i++) {
        final a = centerOf(arrow.cells[i]);
        final b = centerOf(arrow.cells[i + 1]);
        final dist = _distanceToSegment(localPos, a, b);
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

  double _distanceToSegment(Offset p, Offset a, Offset b) {
    final ab = b - a;
    final ap = p - a;
    final lenSq = ab.dx * ab.dx + ab.dy * ab.dy;
    if (lenSq == 0) return ap.distance;
    final t = ((ap.dx * ab.dx + ap.dy * ab.dy) / lenSq).clamp(0.0, 1.0);
    final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
    return (p - proj).distance;
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

  /// شاشة "اكتمل المستوى!" مع معالجة خاصة عند إنهاء المستوى الأخير (المستوى 20)
  Widget _buildVictoryScreen() {
    final isLastLevel = _currentLevelIndex >= _allLevels.length - 1;
    final nextLevelIndex = isLastLevel ? 0 : _currentLevelIndex + 1;
    final nextLevelNumber = _allLevels[nextLevelIndex].levelNumber;
    final palette = StagePalette.of(_currentConfig.stageTheme);

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
                  Column(
                    children: [
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(3, (i) {
                          final earned = i < _hearts;
                          return Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Icon(
                              Icons.star_rounded,
                              size: i == 1 ? 52 : 42,
                              color: earned
                                  ? const Color(0xFFFFD54F)
                                  : Colors.white.withOpacity(0.35),
                              shadows: earned
                                  ? const [
                                      Shadow(
                                        color: Color(0x66FF8F00),
                                        blurRadius: 12,
                                        offset: Offset(0, 4),
                                      )
                                    ]
                                  : null,
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        isLastLevel
                            ? 'أتممت جميع المستويات! 🏆'
                            : 'اكتمل المستوى!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                      ),
                      if (isLastLevel)
                        const Padding(
                          padding: EdgeInsets.only(top: 6),
                          child: Text(
                            'أحسنت! نجحت في حل جميع المتاهات الـ 20 بنجاح',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Container(
                    width: 225,
                    height: 225,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(26),
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
                        palette: palette,
                        ignoreClearedState: true,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 34,
                      vertical: 24,
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
                            onPressed: () {
                              if (isLastLevel) {
                                _goToHomeScreen();
                              } else {
                                _loadLevel(nextLevelIndex);
                              }
                            },
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  isLastLevel
                                      ? 'العودة إلى القائمة الرئيسية'
                                      : 'اللعبة التالية',
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF1976D2),
                                    height: 1.1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  isLastLevel
                                      ? 'اختر أي مستوى أو أعد التحدي'
                                      : 'المستوى $nextLevelNumber',
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
                        const SizedBox(height: 14),
                        TextButton(
                          onPressed: () {
                            if (isLastLevel) {
                              _loadLevel(0);
                            } else {
                              _goToHomeScreen();
                            }
                          },
                          child: Text(
                            isLastLevel
                                ? 'إعادة اللعب من المستوى 1'
                                : 'الرئيسية',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 19,
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

/// رسام شعار الصفحة الرئيسية
class HomeLogoPainter extends CustomPainter {
  final double pulse;
  HomeLogoPainter({required this.pulse});

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final strokeW = w * 0.115;

    final bluePath = Path()
      ..moveTo(w * 0.22, h * 0.78)
      ..lineTo(w * 0.22, h * 0.36)
      ..quadraticBezierTo(w * 0.22, h * 0.20, w * 0.38, h * 0.20)
      ..lineTo(w * 0.76, h * 0.20);

    final bluePaint = Paint()
      ..color = const Color(0xFF1E88E5)
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(bluePath, bluePaint);

    final headPaint1 = Paint()
      ..color = const Color(0xFF1E88E5)
      ..style = PaintingStyle.fill;
    final head1 = Path()
      ..moveTo(w * 0.88, h * 0.20)
      ..lineTo(w * 0.68, h * 0.08)
      ..lineTo(w * 0.68, h * 0.32)
      ..close();
    canvas.drawPath(head1, headPaint1);

    final navyPath = Path()
      ..moveTo(w * 0.78, h * 0.44)
      ..lineTo(w * 0.78, h * 0.64)
      ..quadraticBezierTo(w * 0.78, h * 0.80, w * 0.62, h * 0.80)
      ..lineTo(w * 0.42, h * 0.80);

    final navyPaint = Paint()
      ..color = const Color(0xFF0A1931)
      ..strokeWidth = strokeW
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    canvas.drawPath(navyPath, navyPaint);

    final headPaint2 = Paint()
      ..color = const Color(0xFF0A1931)
      ..style = PaintingStyle.fill;
    final head2 = Path()
      ..moveTo(w * 0.30, h * 0.80)
      ..lineTo(w * 0.50, h * 0.68)
      ..lineTo(w * 0.50, h * 0.92)
      ..close();
    canvas.drawPath(head2, headPaint2);

    final starCenter = Offset(w * 0.52, h * 0.50);
    final starRadius = w * (0.12 + pulse * 0.02);
    final starPaint = Paint()
      ..color = const Color(0xFFFFB300)
      ..style = PaintingStyle.fill;
    final starPath = Path();
    for (int i = 0; i < 10; i++) {
      final r = i.isEven ? starRadius : starRadius * 0.45;
      final angle = -math.pi / 2 + i * (math.pi / 5);
      final pt = Offset(
        starCenter.dx + r * math.cos(angle),
        starCenter.dy + r * math.sin(angle),
      );
      if (i == 0) {
        starPath.moveTo(pt.dx, pt.dy);
      } else {
        starPath.lineTo(pt.dx, pt.dy);
      }
    }
    starPath.close();
    canvas.drawPath(starPath, starPaint);
  }

  @override
  bool shouldRepaint(covariant HomeLogoPainter oldDelegate) =>
      oldDelegate.pulse != pulse;
}

/// رسام اللمبة المضيئة المستوحاة من ملف (10-Neon Lamp Login Form)
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
    canvas.rotate(-0.35);

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

    final tipRect = RRect.fromRectAndRadius(
      const Rect.fromLTWH(-4.0, 16.5, 8.0, 3.2),
      const Radius.circular(2.0),
    );
    canvas.drawRRect(tipRect, Paint()..color = const Color(0xFF3E434A));

    final threadPaint = Paint()
      ..color = const Color(0xFF805915).withOpacity(0.55)
      ..strokeWidth = 1.1;
    canvas.drawLine(
        const Offset(-5.5, 12.0), const Offset(5.5, 12.0), threadPaint);
    canvas.drawLine(
        const Offset(-5.5, 14.5), const Offset(5.5, 14.5), threadPaint);

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

    const bulbRect = Rect.fromLTWH(-14, -20, 28, 30);
    final bulbPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.25, -0.35),
        radius: 0.85,
        colors: [
          Color(0xFFFFFFFF),
          Color(0xFFFFE194),
          Color(0xFFFFAB3D),
          Color(0xFFD48B28),
        ],
        stops: [0.0, 0.32, 0.72, 1.0],
      ).createShader(bulbRect);

    canvas.drawPath(bulbPath, bulbPaint);

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

/// رسام القلب اللامع ثلاثي الأبعاد
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

    final glowPaint = Paint()
      ..color = const Color(0xFFFF3366).withOpacity(0.24)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(path.shift(const Offset(0, 2)), glowPaint);

    final rect = Offset.zero & size;
    final fillPaint = Paint()
      ..shader = const RadialGradient(
        center: Alignment(-0.3, -0.4),
        radius: 1.1,
        colors: [
          Color(0xFFFF8A80),
          Color(0xFFFF5252),
          Color(0xFFD32F2F),
        ],
        stops: [0.0, 0.45, 1.0],
      ).createShader(rect);

    canvas.drawPath(path, fillPaint);

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
      oldDelegate.isActive != isActive;
}

/// محرك رسم شبكة الأسهم المحسن (يدعم الشبكات الكثيفة 10x10 و12x12 بكفاءة عالية)
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
  final StagePalette palette;
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
    required this.palette,
    this.ignoreClearedState = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cellW = size.width / gridCols;
    final cellH = size.height / gridRows;
    final strokeW = math.min(cellW, cellH) * 0.165;

    Offset centerOf(double col, double row) {
      return Offset((col + 0.5) * cellW, (row + 0.5) * cellH);
    }

    // 1. رسم نقاط الشبكة الهادئة
    if (!ignoreClearedState) {
      final dotPaint = Paint()
        ..color = palette.gridDotColor
        ..style = PaintingStyle.fill;
      final dotRadius = math.min(cellW, cellH) * 0.052;
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

    // 2. رسم خطوط المسطرة الإرشادية
    if (rulerEnabled && !ignoreClearedState) {
      final guidePaint = Paint()
        ..color = const Color(0xFF64B5F6).withOpacity(0.65)
        ..strokeWidth = 1.8
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

      Color arrowColor = palette.arrowNormalColor;
      if (isAnimating && !isBlockedAnimation) {
        arrowColor = const Color(0xFF2196F3); // أزرق عند الخروج الصحيح
      } else if ((isAnimating && isBlockedAnimation) || arrow.isQueuedRed) {
        arrowColor = const Color(0xFFE53935); // أحمر عند الاصطدام والانتظار
      } else if (isHinted) {
        arrowColor = const Color(0xFFFF9800); // ذهبي للتلميح
      }

      double shiftCells = 0.0;
      Offset shakeOffset = Offset.zero;

      if (isAnimating) {
        if (isBlockedAnimation) {
          shiftCells = math.sin(animationValue * math.pi) * blockedMaxSteps;
          final shake = math.sin(animationValue * math.pi * 4) * 2.2;
          shakeOffset = Offset(shake, 0);
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
      ).map((p) => p + shakeOffset).toList();

      if (polylinePoints.length < 2) continue;

      final arrowPath = _buildRoundedCornerPath(polylinePoints, cellW * 0.18);

      // أ) ظل ناعم تحت السهم
      if (!ignoreClearedState) {
        final shadowPaint = Paint()
          ..color = const Color(0xFF0F172A).withOpacity(0.10)
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(arrowPath.shift(const Offset(0, 2.0)), shadowPaint);
      }

      // ب) هالة ضوئية حول السهم المُلمّح أو السهم الأزرق المنطلق
      if (isHinted || (isAnimating && !isBlockedAnimation)) {
        final glowColor = (isAnimating && !isBlockedAnimation)
            ? const Color(0xFF2196F3).withOpacity(0.24)
            : const Color(0xFFFFAB3D).withOpacity(0.45);
        final glowPaint = Paint()
          ..color = glowColor
          ..strokeWidth = strokeW * 2.3
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round;
        canvas.drawPath(arrowPath, glowPaint);
      }

      // ج) رسم جسم السهم
      final linePaint = Paint()
        ..color = arrowColor
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(arrowPath, linePaint);

      // د) رسم شكل ❤️ أو ⭐ صغير عند ذيل السهم المميز
      if (arrow.badge != ArrowBadgeStyle.none && !ignoreClearedState) {
        _drawTailBadge(
          canvas,
          polylinePoints.first,
          arrow.badge,
          strokeW * 1.15,
        );
      }

      // هـ) رسم رأس السهم
      _drawArrowHead(
        canvas,
        polylinePoints.last,
        arrow.headDir,
        strokeW * 2.45,
        arrowColor,
        hasShadow: !ignoreClearedState,
      );
    }
  }

  void _drawTailBadge(
    Canvas canvas,
    Offset center,
    ArrowBadgeStyle badge,
    double radius,
  ) {
    final bgPaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    final borderPaint = Paint()
      ..color = badge == ArrowBadgeStyle.heart
          ? const Color(0xFFFF5252)
          : const Color(0xFFFFB300)
      ..strokeWidth = 1.3
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(center, radius * 1.05, bgPaint);
    canvas.drawCircle(center, radius * 1.05, borderPaint);

    if (badge == ArrowBadgeStyle.heart) {
      final w = radius * 1.3;
      final h = radius * 1.3;
      canvas.save();
      canvas.translate(center.dx - w / 2, center.dy - h / 2);
      final path = Path()
        ..moveTo(w * 0.5, h * 0.90)
        ..cubicTo(w * 0.10, h * 0.60, -w * 0.05, h * 0.28, w * 0.20, h * 0.10)
        ..cubicTo(w * 0.35, 0, w * 0.46, h * 0.12, w * 0.5, h * 0.24)
        ..cubicTo(w * 0.54, h * 0.12, w * 0.65, 0, w * 0.80, h * 0.10)
        ..cubicTo(w * 1.05, h * 0.28, w * 0.90, h * 0.60, w * 0.5, h * 0.90)
        ..close();
      canvas.drawPath(
        path,
        Paint()
          ..color = const Color(0xFFFF5252)
          ..style = PaintingStyle.fill,
      );
      canvas.restore();
    } else if (badge == ArrowBadgeStyle.star) {
      final starPath = Path();
      final rOuter = radius * 0.78;
      final rInner = rOuter * 0.45;
      for (int i = 0; i < 10; i++) {
        final r = i.isEven ? rOuter : rInner;
        final angle = -math.pi / 2 + i * (math.pi / 5);
        final pt = Offset(
          center.dx + r * math.cos(angle),
          center.dy + r * math.sin(angle),
        );
        if (i == 0) {
          starPath.moveTo(pt.dx, pt.dy);
        } else {
          starPath.lineTo(pt.dx, pt.dy);
        }
      }
      starPath.close();
      canvas.drawPath(
        starPath,
        Paint()
          ..color = const Color(0xFFFFB300)
          ..style = PaintingStyle.fill,
      );
    }
  }

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

      final r = math.min(cornerRadius, math.min(len1, len2) * 0.40);
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
    Color color, {
    bool hasShadow = true,
  }) {
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
      ..moveTo(headSize * 0.50, 0)
      ..lineTo(-headSize * 0.50, -headSize * 0.52)
      ..quadraticBezierTo(
          -headSize * 0.36, 0, -headSize * 0.50, headSize * 0.52)
      ..close();

    if (hasShadow) {
      final shadowPaint = Paint()
        ..color = const Color(0xFF0F172A).withOpacity(0.12)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path.shift(const Offset(1.5, 1.5)), shadowPaint);
    }

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, paint);

    final strokePaint = Paint()
      ..color = color
      ..strokeWidth = headSize * 0.14
      ..style = PaintingStyle.stroke
      ..strokeJoin = StrokeJoin.round;
    canvas.drawPath(path, strokePaint);

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
                      '• كل مستوى يبدأ بسهم أو سهمين مفتوحين فقط، وإخراجهما يفتح الطريق لباقي الأسهم بالتتابع.\n'
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
                  'لعبة مسار الأسهم (الإصدار 1.4.0)\nتضم 20 مستوى عالي الكثافة والعمق مع توفير كامل للبطارية وأيقونة خارجية مخصصة.',
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