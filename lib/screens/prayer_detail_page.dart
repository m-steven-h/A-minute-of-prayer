// screens/prayer_details_page.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class PrayerDetailsPage extends StatefulWidget {
  final String prayerId;
  final String prayerName;
  const PrayerDetailsPage({
    super.key,
    required this.prayerId,
    required this.prayerName,
  });

  @override
  State<PrayerDetailsPage> createState() => _PrayerDetailsPageState();
}

class _PrayerDetailsPageState extends State<PrayerDetailsPage>
    with SingleTickerProviderStateMixin {
  late List<PrayerSection> _sections;
  int _selectedIndex = 0;
  final Set<int> _completedSections = {};
  late TabController _tabController;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _loadSections();
    _tabController = TabController(length: _sections.length, vsync: this);
    _pageController = PageController();
  }

  void _loadSections() {
    switch (widget.prayerId) {
      case 'morning':
        _sections = _getMorningPrayerSections();
        break;
      case 'third_hour':
        _sections = _getThirdHourSections();
        break;
      case 'sixth_hour':
        _sections = _getSixthHourSections();
        break;
      case 'ninth_hour':
        _sections = _getNinthHourSections();
        break;
      case 'sunset':
        _sections = _getSunsetSections();
        break;
      case 'bedtime':
        _sections = _getBedtimeSections();
        break;
      default:
        _sections = _getMorningPrayerSections();
    }
    _tabController = TabController(length: _sections.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleComplete(int index) {
    setState(() {
      if (_completedSections.contains(index)) {
        _completedSections.remove(index);
      } else {
        _completedSections.add(index);
      }
    });
  }

  void _goToNextSection() {
    if (_selectedIndex < _sections.length - 1) {
      setState(() {
        _selectedIndex++;
        _tabController.animateTo(_selectedIndex);
        _pageController.animateToPage(
          _selectedIndex,
          duration: Duration.zero,
          curve: Curves.linear,
        );
      });
    }
  }

  void _goToPreviousSection() {
    if (_selectedIndex > 0) {
      setState(() {
        _selectedIndex--;
        _tabController.animateTo(_selectedIndex);
        _pageController.animateToPage(
          _selectedIndex,
          duration: Duration.zero,
          curve: Curves.linear,
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: themeProvider.backgroundColor,
        appBar: AppBar(
          backgroundColor: themeProvider.cardColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon:
                const Icon(Icons.arrow_back_rounded, color: Color(0xFF4ADE80)),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            widget.prayerName,
            style: GoogleFonts.cairo(
              fontWeight: FontWeight.w900,
              color: const Color(0xFF4ADE80),
              fontSize: 20 * themeProvider.fontScale,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(50),
            child: Container(
              height: 50,
              margin: const EdgeInsets.only(bottom: 8),
              child: TabBar(
                controller: _tabController,
                isScrollable: true,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                labelColor: Colors.white,
                unselectedLabelColor: themeProvider.textColor,
                indicator: BoxDecoration(
                  color: const Color(0xFF4ADE80),
                  borderRadius: BorderRadius.circular(30),
                ),
                dividerColor: Colors.transparent,
                labelStyle: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                unselectedLabelStyle: GoogleFonts.cairo(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
                tabs: List.generate(_sections.length, (index) {
                  final isCompleted = _completedSections.contains(index);
                  return Tab(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isCompleted)
                            const Icon(Icons.check_circle, size: 16),
                          if (isCompleted) const SizedBox(width: 6),
                          Text(_sections[index].title),
                        ],
                      ),
                    ),
                  );
                }),
                onTap: (index) {
                  setState(() {
                    _selectedIndex = index;
                    _pageController.animateToPage(
                      index,
                      duration: Duration.zero,
                      curve: Curves.linear,
                    );
                  });
                },
              ),
            ),
          ),
        ),
        body: GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity != null &&
                details.primaryVelocity! < -200) {
              _goToNextSection();
            } else if (details.primaryVelocity != null &&
                details.primaryVelocity! > 200) {
              _goToPreviousSection();
            }
          },
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (index) {
                    setState(() {
                      _selectedIndex = index;
                      _tabController.animateTo(index);
                    });
                  },
                  children: List.generate(_sections.length, (index) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: themeProvider.cardColor,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              _sections[index].content,
                              style: GoogleFonts.cairo(
                                fontSize: 16 * themeProvider.fontScale,
                                color: themeProvider.textColor,
                                height: 1.7,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _toggleComplete(index),
                                  icon: Icon(
                                    _completedSections.contains(index)
                                        ? Icons.check_circle
                                        : Icons.check_circle_outline,
                                    size: 20,
                                  ),
                                  label: Text(
                                    _completedSections.contains(index)
                                        ? 'تم الإكمال ✓'
                                        : 'إكمال',
                                    style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4ADE80),
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => Navigator.pop(context),
                                  icon: const Icon(Icons.close, size: 20),
                                  label: Text(
                                    'إغلاق',
                                    style: GoogleFonts.cairo(
                                        fontWeight: FontWeight.bold),
                                  ),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: const Color(0xFF4ADE80),
                                    side: const BorderSide(
                                        color: Color(0xFF4ADE80)),
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ==================== صلاة باكر ====================
  List<PrayerSection> _getMorningPrayerSections() {
    return [
      PrayerSection(title: 'الصلاة الربانية', content: _MORNING_LORD_PRAYER),
      PrayerSection(title: 'صلاة الشكر', content: _MORNING_THANKSGIVING),
      PrayerSection(title: 'المزمور الخمسون', content: _MORNING_PSALM_50),
      PrayerSection(title: 'هلم نسجد', content: _MORNING_COME_WORSHIP),
      PrayerSection(title: 'البولس (أفسس 4:1-5)', content: _MORNING_EPHESIANS),
      PrayerSection(title: 'من إيمان الكنيسة', content: _MORNING_CREED_SHORT),
      PrayerSection(title: 'بدء الصلاة', content: _MORNING_START),
      PrayerSection(title: 'مزمور 1: طوبى للرجل', content: _MORNING_PSALM_1),
      PrayerSection(
          title: 'مزمور 2: لماذا ارتجت الأمم', content: _MORNING_PSALM_2),
      PrayerSection(
          title: 'مزمور 3: يارب لماذا كثر', content: _MORNING_PSALM_3),
      PrayerSection(
          title: 'مزمور 4: إذ دعوت استجبت لي', content: _MORNING_PSALM_4),
      PrayerSection(
          title: 'مزمور 5: أنصت يارب لكلماتي', content: _MORNING_PSALM_5),
      PrayerSection(
          title: 'مزمور 6: يارب لا تبكتني بغضبك', content: _MORNING_PSALM_6),
      PrayerSection(
          title: 'مزمور 8: أيها الرب ربنا', content: _MORNING_PSALM_8),
      PrayerSection(title: 'مزمور 11: خلصني يارب', content: _MORNING_PSALM_11),
      PrayerSection(
          title: 'مزمور 12: إلى متى يارب تنساني', content: _MORNING_PSALM_12),
      PrayerSection(
          title: 'مزمور 14: يارب من يسكن في مسكنك', content: _MORNING_PSALM_14),
      PrayerSection(
          title: 'مزمور 15: احفظني يا رب', content: _MORNING_PSALM_15),
      PrayerSection(
          title: 'مزمور 18: السموات تحدث بمجد الله',
          content: _MORNING_PSALM_18),
      PrayerSection(
          title: 'مزمور 24: إليك يارب رفعت نفسي', content: _MORNING_PSALM_24),
      PrayerSection(
          title: 'مزمور 26: الرب نوري وخلاصي', content: _MORNING_PSALM_26),
      PrayerSection(
          title: 'مزمور 62: يا الله إلهي إليك أبكر',
          content: _MORNING_PSALM_62),
      PrayerSection(
          title: 'مزمور 66: ليتراءف الله علينا', content: _MORNING_PSALM_66),
      PrayerSection(
          title: 'مزمور 69: اللهم التفت إلى معونتي',
          content: _MORNING_PSALM_69),
      PrayerSection(
          title: 'مزمور 112: سبحوا الرب أيها الفتيان',
          content: _MORNING_PSALM_112),
      PrayerSection(
          title: 'مزمور 142: يارب اسمع صلاتي', content: _MORNING_PSALM_142),
      PrayerSection(title: 'الإنجيل (يوحنا 1:1-17)', content: _MORNING_GOSPEL),
      PrayerSection(title: 'القطعة الأولى', content: _MORNING_PIECE_1),
      PrayerSection(title: 'القطعة الثانية', content: _MORNING_PIECE_2),
      PrayerSection(title: 'القطعة الثالثة', content: _MORNING_PIECE_3),
      PrayerSection(title: 'تسبحة الملائكة', content: _MORNING_ANGELS_PRAISE),
      PrayerSection(title: 'الثلاث تقديسات', content: _MORNING_THREE_HOLIES),
      PrayerSection(title: 'الصلاة الربانية', content: _MORNING_LORD_PRAYER),
      PrayerSection(title: 'السلام لك', content: _MORNING_PEACE),
      PrayerSection(title: 'بدء قانون الإيمان', content: _MORNING_START_CREED),
      PrayerSection(title: 'قانون الإيمان', content: _MORNING_CREED_FULL),
      PrayerSection(title: 'يارب ارحم 41 مرة', content: _MORNING_KYRIE_41),
      PrayerSection(title: 'قدوس قدوس قدوس', content: _MORNING_HOLY),
      PrayerSection(title: 'الصلاة الربانية', content: _MORNING_LORD_PRAYER),
      PrayerSection(title: 'التحليل', content: _MORNING_ABSOLUTION_1),
      PrayerSection(title: 'تحليل آخر', content: _MORNING_ABSOLUTION_2),
      PrayerSection(
          title: 'طلبات آخر كل ساعة', content: _MORNING_LAST_REQUESTS),
    ];
  }

  // ==================== صلاة الساعة الثالثة ====================
  List<PrayerSection> _getThirdHourSections() {
    return [
      PrayerSection(title: 'الصلاة الربانية', content: _THIRD_LORD_PRAYER),
      PrayerSection(title: 'صلاة الشكر', content: _THIRD_THANKSGIVING),
      PrayerSection(title: 'المزمور الخمسون', content: _THIRD_PSALM_50),
      PrayerSection(title: 'بدء الصلاة', content: _THIRD_START),
      PrayerSection(
          title: 'مزمور 19: يستجيب لك الرب', content: _THIRD_PSALM_19),
      PrayerSection(title: 'مزمور 22: الرب يرعاني', content: _THIRD_PSALM_22),
      PrayerSection(
          title: 'مزمور 23: للرب الأرض وملؤها', content: _THIRD_PSALM_23),
      PrayerSection(title: 'مزمور 25: احكم لي يا رب', content: _THIRD_PSALM_25),
      PrayerSection(
          title: 'مزمور 28: قدموا للرب يا أبناء الله',
          content: _THIRD_PSALM_28),
      PrayerSection(title: 'مزمور 29: أعظمك يا رب', content: _THIRD_PSALM_29),
      PrayerSection(
          title: 'مزمور 33: أبارك الرب في كل وقت', content: _THIRD_PSALM_33),
      PrayerSection(
          title: 'مزمور 40: طوبى لمن يتعطف على المسكين',
          content: _THIRD_PSALM_40),
      PrayerSection(title: 'مزمور 42: احكم لي يا رب', content: _THIRD_PSALM_42),
      PrayerSection(title: 'مزمور 44: فاض قلبي', content: _THIRD_PSALM_44),
      PrayerSection(
          title: 'مزمور 45: إلهنا ملجأنا وقوتنا', content: _THIRD_PSALM_45),
      PrayerSection(
          title: 'مزمور 46: يا جميع الأمم صفقوا بأيديكم',
          content: _THIRD_PSALM_46),
      PrayerSection(title: 'الإنجيل (يوحنا 14:15-26)', content: _THIRD_GOSPEL),
      PrayerSection(title: 'القطعة الأولى', content: _THIRD_PIECE_1),
      PrayerSection(title: 'القطعة الثانية', content: _THIRD_PIECE_2),
      PrayerSection(title: 'القطعة الثالثة', content: _THIRD_PIECE_3),
      PrayerSection(title: 'القطعة الرابعة', content: _THIRD_PIECE_4),
      PrayerSection(title: 'القطعة الخامسة', content: _THIRD_PIECE_5),
      PrayerSection(title: 'القطعة السادسة', content: _THIRD_PIECE_6),
      PrayerSection(title: 'يارب ارحم 41 مرة', content: _THIRD_KYRIE_41),
      PrayerSection(title: 'قدوس قدوس قدوس', content: _THIRD_HOLY),
      PrayerSection(title: 'الصلاة الربانية', content: _THIRD_LORD_PRAYER),
      PrayerSection(title: 'التحليل', content: _THIRD_ABSOLUTION),
      PrayerSection(
          title: 'طلبة تقال آخر كل ساعة', content: _THIRD_LAST_REQUESTS),
    ];
  }

  // ==================== صلاة الساعة السادسة ====================
  List<PrayerSection> _getSixthHourSections() {
    return [
      PrayerSection(title: 'الصلاة الربانية', content: _SIXTH_LORD_PRAYER),
      PrayerSection(
          title: 'صلاة الشكر والمزمور الخمسون',
          content: _SIXTH_THANKSGIVING_PSALM),
      PrayerSection(title: 'بدء الصلاة', content: _SIXTH_START),
      PrayerSection(
          title: 'مزمور 53: اللهم باسمك خلصني', content: _SIXTH_PSALM_53),
      PrayerSection(
          title: 'مزمور 56: ارحمني يا الله ارحمني', content: _SIXTH_PSALM_56),
      PrayerSection(
          title: 'مزمور 60: استمع يا الله طلبتي', content: _SIXTH_PSALM_60),
      PrayerSection(
          title: 'مزمور 62: يا الله إلهي إليك أبكر', content: _SIXTH_PSALM_62),
      PrayerSection(
          title: 'مزمور 66: ليتراءف الله علينا', content: _SIXTH_PSALM_66),
      PrayerSection(
          title: 'مزمور 69: اللهم التفت إلى معونتي', content: _SIXTH_PSALM_69),
      PrayerSection(title: 'مزمور 83: مساكنك محبوبة', content: _SIXTH_PSALM_83),
      PrayerSection(
          title: 'مزمور 84: أمل يا رب أذنك', content: _SIXTH_PSALM_84),
      PrayerSection(
          title: 'مزمور 85: أمال يا رب أذنك', content: _SIXTH_PSALM_85),
      PrayerSection(
          title: 'مزمور 86: أساساته في الجبال المقدسة',
          content: _SIXTH_PSALM_86),
      PrayerSection(
          title: 'مزمور 90: السكن في عون العلى', content: _SIXTH_PSALM_90),
      PrayerSection(title: 'مزمور 92: الرب قد ملك', content: _SIXTH_PSALM_92),
      PrayerSection(title: 'الإنجيل (متى 5:1-16)', content: _SIXTH_GOSPEL),
      PrayerSection(title: 'القطعة الأولى', content: _SIXTH_PIECE_1),
      PrayerSection(title: 'القطعة الثانية', content: _SIXTH_PIECE_2),
      PrayerSection(title: 'القطعة الثالثة', content: _SIXTH_PIECE_3),
      PrayerSection(title: 'القطعة الرابعة', content: _SIXTH_PIECE_4),
      PrayerSection(title: 'القطعة الخامسة', content: _SIXTH_PIECE_5),
      PrayerSection(title: 'القطعة السادسة', content: _SIXTH_PIECE_6),
      PrayerSection(title: 'يارب ارحم 41 مرة', content: _SIXTH_KYRIE_41),
      PrayerSection(title: 'قدوس قدوس قدوس', content: _SIXTH_HOLY),
      PrayerSection(title: 'الصلاة الربانية', content: _SIXTH_LORD_PRAYER),
      PrayerSection(title: 'التحليل', content: _SIXTH_ABSOLUTION),
      PrayerSection(
          title: 'طلبة تقال آخر كل ساعة', content: _SIXTH_LAST_REQUESTS),
    ];
  }

  // ==================== صلاة الساعة التاسعة ====================
  List<PrayerSection> _getNinthHourSections() {
    return [
      PrayerSection(title: 'الصلاة الربانية', content: _NINTH_LORD_PRAYER),
      PrayerSection(title: 'صلاة الشكر', content: _NINTH_THANKSGIVING),
      PrayerSection(title: 'المزمور الخمسون', content: _NINTH_PSALM_50),
      PrayerSection(title: 'بدء الصلاة', content: _NINTH_START),
      PrayerSection(
          title: 'مزمور 95: سبحوا الرب تسبيحاً جديداً',
          content: _NINTH_PSALM_95),
      PrayerSection(
          title: 'مزمور 96: الرب قد ملك فلتتهلل الأرض',
          content: _NINTH_PSALM_96),
      PrayerSection(
          title: 'مزمور 97: سبحوا الرب تسبيحاً جديداً',
          content: _NINTH_PSALM_97),
      PrayerSection(
          title: 'مزمور 98: الرب قد ملك فلترتعد الشعوب',
          content: _NINTH_PSALM_98),
      PrayerSection(
          title: 'مزمور 99: هللوا للرب يا كل الأرض', content: _NINTH_PSALM_99),
      PrayerSection(
          title: 'مزمور 100: لرحمتك وعدلك', content: _NINTH_PSALM_100),
      PrayerSection(
          title: 'مزمور 109: قال الرب لربي', content: _NINTH_PSALM_109),
      PrayerSection(
          title: 'مزمور 110: أعترف لك يا رب', content: _NINTH_PSALM_110),
      PrayerSection(
          title: 'مزمور 111: طوبى للرجل الخائف الرب',
          content: _NINTH_PSALM_111),
      PrayerSection(
          title: 'مزمور 112: سبحوا الرب أيها الفتيان',
          content: _NINTH_PSALM_112),
      PrayerSection(
          title: 'مزمور 114: أحببت أن يسمع الرب', content: _NINTH_PSALM_114),
      PrayerSection(
          title: 'مزمور 115: آمنت لذلك تكلمت', content: _NINTH_PSALM_115),
      PrayerSection(title: 'الإنجيل (لوقا 9:10-17)', content: _NINTH_GOSPEL),
      PrayerSection(title: 'القطعة الأولى', content: _NINTH_PIECE_1),
      PrayerSection(title: 'القطعة الثانية', content: _NINTH_PIECE_2),
      PrayerSection(title: 'القطعة الثالثة', content: _NINTH_PIECE_3),
      PrayerSection(title: 'القطعة الرابعة', content: _NINTH_PIECE_4),
      PrayerSection(title: 'القطعة الخامسة', content: _NINTH_PIECE_5),
      PrayerSection(title: 'القطعة السادسة', content: _NINTH_PIECE_6),
      PrayerSection(title: 'يارب ارحم 41 مرة', content: _NINTH_KYRIE_41),
      PrayerSection(title: 'قدوس قدوس قدوس', content: _NINTH_HOLY),
      PrayerSection(title: 'الصلاة الربانية', content: _NINTH_LORD_PRAYER),
      PrayerSection(title: 'التحليل', content: _NINTH_ABSOLUTION),
      PrayerSection(
          title: 'طلبات تقال آخر كل ساعة', content: _NINTH_LAST_REQUESTS),
    ];
  }

  // ==================== صلاة الغروب ====================
  List<PrayerSection> _getSunsetSections() {
    return [
      PrayerSection(title: 'الصلاة الربانية', content: _SUNSET_LORD_PRAYER),
      PrayerSection(title: 'صلاة الشكر', content: _SUNSET_THANKSGIVING),
      PrayerSection(title: 'المزمور الخمسون', content: _SUNSET_PSALM_50),
      PrayerSection(title: 'بدء الصلاة', content: _SUNSET_START),
      PrayerSection(
          title: 'مزمور 116: سبحوا الرب يا جميع الأمم',
          content: _SUNSET_PSALM_116),
      PrayerSection(
          title: 'مزمور 117: اعترفوا للرب لأنه صالح',
          content: _SUNSET_PSALM_117),
      PrayerSection(
          title: 'مزمور 119: إليك يا رب صرخت', content: _SUNSET_PSALM_119),
      PrayerSection(
          title: 'مزمور 120: رفعت عيني إلى الجبال', content: _SUNSET_PSALM_120),
      PrayerSection(
          title: 'مزمور 121: فرحت بقائلين لي', content: _SUNSET_PSALM_121),
      PrayerSection(
          title: 'مزمور 122: إليك رفعت عيني', content: _SUNSET_PSALM_122),
      PrayerSection(
          title: 'مزمور 123: لولا أن الرب كان معنا',
          content: _SUNSET_PSALM_123),
      PrayerSection(
          title: 'مزمور 124: المتوكلون على الرب', content: _SUNSET_PSALM_124),
      PrayerSection(
          title: 'مزمور 125: إذا ما رد الرب سبي صهيون',
          content: _SUNSET_PSALM_125),
      PrayerSection(
          title: 'مزمور 126: إن لم يبن الرب البيت', content: _SUNSET_PSALM_126),
      PrayerSection(
          title: 'مزمور 127: طوبى لجميع الذين يتقون الرب',
          content: _SUNSET_PSALM_127),
      PrayerSection(
          title: 'مزمور 128: مراراً كثيرة حاربوني', content: _SUNSET_PSALM_128),
      PrayerSection(title: 'الإنجيل (لوقا 4:38-41)', content: _SUNSET_GOSPEL),
      PrayerSection(title: 'القطعة الأولى', content: _SUNSET_PIECE_1),
      PrayerSection(title: 'القطعة الثانية', content: _SUNSET_PIECE_2),
      PrayerSection(title: 'القطعة الثالثة', content: _SUNSET_PIECE_3),
      PrayerSection(title: 'يارب ارحم 41 مرة', content: _SUNSET_KYRIE_41),
      PrayerSection(title: 'قدوس قدوس قدوس', content: _SUNSET_HOLY),
      PrayerSection(title: 'الصلاة الربانية', content: _SUNSET_LORD_PRAYER),
      PrayerSection(title: 'التحليل', content: _SUNSET_ABSOLUTION),
      PrayerSection(
          title: 'طلبات تقال آخر كل ساعة', content: _SUNSET_LAST_REQUESTS),
    ];
  }

  // ==================== صلاة النوم ====================
  List<PrayerSection> _getBedtimeSections() {
    return [
      PrayerSection(title: 'الصلاة الربانية', content: _BEDTIME_LORD_PRAYER),
      PrayerSection(title: 'صلاة الشكر', content: _BEDTIME_THANKSGIVING),
      PrayerSection(title: 'المزمور الخمسون', content: _BEDTIME_PSALM_50),
      PrayerSection(title: 'بدء الصلاة', content: _BEDTIME_START),
      PrayerSection(
          title: 'مزمور 129: من الأعماق صرخت إليك يا رب',
          content: _BEDTIME_PSALM_129),
      PrayerSection(
          title: 'مزمور 130: يا رب لم يرتفع قلبي', content: _BEDTIME_PSALM_130),
      PrayerSection(
          title: 'مزمور 131: اذكر يا رب داود وكل مذلته',
          content: _BEDTIME_PSALM_131),
      PrayerSection(
          title: 'مزمور 132: هوذا ما أحسن وما أحلى',
          content: _BEDTIME_PSALM_132),
      PrayerSection(
          title: 'مزمور 133: ها باركوا الرب', content: _BEDTIME_PSALM_133),
      PrayerSection(
          title: 'مزمور 136: على أنهار بابل', content: _BEDTIME_PSALM_136),
      PrayerSection(
          title: 'مزمور 137: اعترف لك يا رب', content: _BEDTIME_PSALM_137),
      PrayerSection(
          title: 'مزمور 140: يا رب إليك صرخت', content: _BEDTIME_PSALM_140),
      PrayerSection(
          title: 'مزمور 141: بصوتي إلى الرب صرخت', content: _BEDTIME_PSALM_141),
      PrayerSection(
          title: 'مزمور 145: سبحي يا نفسي الرب', content: _BEDTIME_PSALM_145),
      PrayerSection(
          title: 'مزمور 146: سبحوا الرب فإن المزمور جيد',
          content: _BEDTIME_PSALM_146),
      PrayerSection(
          title: 'مزمور 147: سبحي الرب يا أورشليم',
          content: _BEDTIME_PSALM_147),
      PrayerSection(title: 'الإنجيل (لوقا 2:25-32)', content: _BEDTIME_GOSPEL),
      PrayerSection(title: 'القطعة الأولى', content: _BEDTIME_PIECE_1),
      PrayerSection(title: 'القطعة الثانية', content: _BEDTIME_PIECE_2),
      PrayerSection(title: 'القطعة الثالثة', content: _BEDTIME_PIECE_3),
      PrayerSection(title: 'تفضل يا رب', content: _BEDTIME_PLEASE_LORD),
      PrayerSection(title: 'الثلاث تقديسات', content: _BEDTIME_THREE_HOLIES),
      PrayerSection(title: 'الصلاة الربانية', content: _BEDTIME_LORD_PRAYER),
      PrayerSection(title: 'السلام عليكم', content: _BEDTIME_PEACE),
      PrayerSection(title: 'بدء قانون الإيمان', content: _BEDTIME_START_CREED),
      PrayerSection(title: 'قانون الإيمان', content: _BEDTIME_CREED),
      PrayerSection(title: 'يارب ارحم 14 مرة', content: _BEDTIME_KYRIE_14),
      PrayerSection(title: 'قدوس قدوس قدوس', content: _BEDTIME_HOLY),
      PrayerSection(title: 'الصلاة الربانية', content: _BEDTIME_LORD_PRAYER),
      PrayerSection(title: 'التحليل', content: _BEDTIME_ABSOLUTION),
      PrayerSection(
          title: 'طلبات تقال آخر كل ساعة', content: _BEDTIME_LAST_REQUESTS),
    ];
  }

  // ============================================================
  // ==================== نصوص صلاة باكر ====================
  // ============================================================

  final String _MORNING_LORD_PRAYER = '''
📖 الصلاة الربانية

(هنا هتكتبي نص الصلاة الربانية الخاص بصلاة باكر)
''';

  final String _MORNING_THANKSGIVING = '''
📖 صلاة الشكر

(هنا هتكتبي نص صلاة الشكر الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_50 = '''
📖 المزمور الخمسون

(هنا هتكتبي نص المزمور الخمسون الخاص بصلاة باكر)
''';

  final String _MORNING_COME_WORSHIP = '''
📖 هلم نسجد

(هنا هتكتبي نص هلم نسجد الخاص بصلاة باكر)
''';

  final String _MORNING_EPHESIANS = '''
📖 البولس (أفسس 4:1-5)

(هنا هتكتبي نص البولس الخاص بصلاة باكر)
''';

  final String _MORNING_CREED_SHORT = '''
📖 من إيمان الكنيسة

(هنا هتكتبي نص قانون الإيمان المختصر الخاص بصلاة باكر)
''';

  final String _MORNING_START = '''
📖 بدء الصلاة

(هنا هتكتبي نص بدء الصلاة الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_1 = '''
📖 مزمور 1: طوبى للرجل

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_2 = '''
📖 مزمور 2: لماذا ارتجت الأمم

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_3 = '''
📖 مزمور 3: يارب لماذا كثر

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_4 = '''
📖 مزمور 4: إذ دعوت استجبت لي

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_5 = '''
📖 مزمور 5: أنصت يارب لكلماتي

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_6 = '''
📖 مزمور 6: يارب لا تبكتني بغضبك

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_8 = '''
📖 مزمور 8: أيها الرب ربنا

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_11 = '''
📖 مزمور 11: خلصني يارب

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_12 = '''
📖 مزمور 12: إلى متى يارب تنساني

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_14 = '''
📖 مزمور 14: يارب من يسكن في مسكنك

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_15 = '''
📖 مزمور 15: احفظني يا رب

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_18 = '''
📖 مزمور 18: السموات تحدث بمجد الله

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_24 = '''
📖 مزمور 24: إليك يارب رفعت نفسي

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_26 = '''
📖 مزمور 26: الرب نوري وخلاصي

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_62 = '''
📖 مزمور 62: يا الله إلهي إليك أبكر

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_66 = '''
📖 مزمور 66: ليتراءف الله علينا

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_69 = '''
📖 مزمور 69: اللهم التفت إلى معونتي

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_112 = '''
📖 مزمور 112: سبحوا الرب أيها الفتيان

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_PSALM_142 = '''
📖 مزمور 142: يارب اسمع صلاتي

(هنا هتكتبي نص المزمور الخاص بصلاة باكر)
''';

  final String _MORNING_GOSPEL = '''
📖 الإنجيل (يوحنا 1:1-17)

(هنا هتكتبي نص الإنجيل الخاص بصلاة باكر)
''';

  final String _MORNING_PIECE_1 = '''
📖 القطعة الأولى

(هنا هتكتبي نص القطعة الأولى الخاص بصلاة باكر)
''';

  final String _MORNING_PIECE_2 = '''
📖 القطعة الثانية

(هنا هتكتبي نص القطعة الثانية الخاص بصلاة باكر)
''';

  final String _MORNING_PIECE_3 = '''
📖 القطعة الثالثة

(هنا هتكتبي نص القطعة الثالثة الخاص بصلاة باكر)
''';

  final String _MORNING_ANGELS_PRAISE = '''
📖 تسبحة الملائكة

(هنا هتكتبي نص تسبحة الملائكة الخاص بصلاة باكر)
''';

  final String _MORNING_THREE_HOLIES = '''
📖 الثلاث تقديسات

(هنا هتكتبي نص الثلاث تقديسات الخاص بصلاة باكر)
''';

  final String _MORNING_PEACE = '''
📖 السلام لك

(هنا هتكتبي نص السلام لك الخاص بصلاة باكر)
''';

  final String _MORNING_START_CREED = '''
📖 بدء قانون الإيمان

(هنا هتكتبي النص)
''';

  final String _MORNING_CREED_FULL = '''
📖 قانون الإيمان

(هنا هتكتبي نص قانون الإيمان الكامل الخاص بصلاة باكر)
''';

  final String _MORNING_KYRIE_41 = '''
📖 يارب ارحم 41 مرة

(هنا هتكتبي الصلاة)
''';

  final String _MORNING_HOLY = '''
📖 قدوس قدوس قدوس

(هنا هتكتبي النص)
''';

  final String _MORNING_ABSOLUTION_1 = '''
📖 التحليل

(هنا هتكتبي نص التحليل الأول الخاص بصلاة باكر)
''';

  final String _MORNING_ABSOLUTION_2 = '''
📖 تحليل آخر

(هنا هتكتبي نص التحليل الثاني الخاص بصلاة باكر)
''';

  final String _MORNING_LAST_REQUESTS = '''
📖 طلبات آخر كل ساعة

(هنا هتكتبي الطلبات الخاصة بصلاة باكر)
''';

  // ============================================================
  // ==================== نصوص صلاة الساعة الثالثة ====================
  // ============================================================

  final String _THIRD_LORD_PRAYER = '''
📖 الصلاة الربانية

(هنا هتكتبي نص الصلاة الربانية الخاص بصلاة الساعة الثالثة)
''';

  final String _THIRD_THANKSGIVING = '''
📖 صلاة الشكر

(هنا هتكتبي نص صلاة الشكر الخاص بصلاة الساعة الثالثة)
''';

  final String _THIRD_PSALM_50 = '''
📖 المزمور الخمسون

(هنا هتكتبي نص المزمور الخمسون الخاص بصلاة الساعة الثالثة)
''';

  final String _THIRD_START = '''
📖 بدء الصلاة

(هنا هتكتبي نص بدء الصلاة الخاص بصلاة الساعة الثالثة)
''';

  final String _THIRD_PSALM_19 =
      '📖 مزمور 19: يستجيب لك الرب\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_22 =
      '📖 مزمور 22: الرب يرعاني\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_23 =
      '📖 مزمور 23: للرب الأرض وملؤها\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_25 =
      '📖 مزمور 25: احكم لي يا رب\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_28 =
      '📖 مزمور 28: قدموا للرب يا أبناء الله\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_29 =
      '📖 مزمور 29: أعظمك يا رب\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_33 =
      '📖 مزمور 33: أبارك الرب في كل وقت\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_40 =
      '📖 مزمور 40: طوبى لمن يتعطف على المسكين\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_42 =
      '📖 مزمور 42: احكم لي يا رب\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_44 = '📖 مزمور 44: فاض قلبي\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_45 =
      '📖 مزمور 45: إلهنا ملجأنا وقوتنا\n\n(هنا هتكتبي النص)';
  final String _THIRD_PSALM_46 =
      '📖 مزمور 46: يا جميع الأمم صفقوا بأيديكم\n\n(هنا هتكتبي النص)';
  final String _THIRD_GOSPEL =
      '📖 الإنجيل (يوحنا 14:15-26)\n\n(هنا هتكتبي نص الإنجيل الخاص بصلاة الساعة الثالثة)';
  final String _THIRD_PIECE_1 = '📖 القطعة الأولى\n\n(هنا هتكتبي النص)';
  final String _THIRD_PIECE_2 = '📖 القطعة الثانية\n\n(هنا هتكتبي النص)';
  final String _THIRD_PIECE_3 = '📖 القطعة الثالثة\n\n(هنا هتكتبي النص)';
  final String _THIRD_PIECE_4 = '📖 القطعة الرابعة\n\n(هنا هتكتبي النص)';
  final String _THIRD_PIECE_5 = '📖 القطعة الخامسة\n\n(هنا هتكتبي النص)';
  final String _THIRD_PIECE_6 = '📖 القطعة السادسة\n\n(هنا هتكتبي النص)';
  final String _THIRD_KYRIE_41 = '📖 يارب ارحم 41 مرة\n\n(هنا هتكتبي الصلاة)';
  final String _THIRD_HOLY = '📖 قدوس قدوس قدوس\n\n(هنا هتكتبي النص)';
  final String _THIRD_ABSOLUTION = '📖 التحليل\n\n(هنا هتكتبي النص)';
  final String _THIRD_LAST_REQUESTS =
      '📖 طلبة تقال آخر كل ساعة\n\n(هنا هتكتبي الطلبات)';

  // ============================================================
  // ==================== نصوص صلاة الساعة السادسة ====================
  // ============================================================

  final String _SIXTH_LORD_PRAYER =
      '📖 الصلاة الربانية\n\n(هنا هتكتبي النص الخاص بصلاة الساعة السادسة)';
  final String _SIXTH_THANKSGIVING_PSALM =
      '📖 صلاة الشكر والمزمور الخمسون\n\n(هنا هتكتبي النص)';
  final String _SIXTH_START = '📖 بدء الصلاة\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_53 =
      '📖 مزمور 53: اللهم باسمك خلصني\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_56 =
      '📖 مزمور 56: ارحمني يا الله ارحمني\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_60 =
      '📖 مزمور 60: استمع يا الله طلبتي\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_62 =
      '📖 مزمور 62: يا الله إلهي إليك أبكر\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_66 =
      '📖 مزمور 66: ليتراءف الله علينا\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_69 =
      '📖 مزمور 69: اللهم التفت إلى معونتي\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_83 =
      '📖 مزمور 83: مساكنك محبوبة\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_84 =
      '📖 مزمور 84: أمل يا رب أذنك\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_85 =
      '📖 مزمور 85: أمال يا رب أذنك\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_86 =
      '📖 مزمور 86: أساساته في الجبال المقدسة\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_90 =
      '📖 مزمور 90: السكن في عون العلى\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PSALM_92 =
      '📖 مزمور 92: الرب قد ملك\n\n(هنا هتكتبي النص)';
  final String _SIXTH_GOSPEL = '📖 الإنجيل (متى 5:1-16)\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PIECE_1 = '📖 القطعة الأولى\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PIECE_2 = '📖 القطعة الثانية\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PIECE_3 = '📖 القطعة الثالثة\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PIECE_4 = '📖 القطعة الرابعة\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PIECE_5 = '📖 القطعة الخامسة\n\n(هنا هتكتبي النص)';
  final String _SIXTH_PIECE_6 = '📖 القطعة السادسة\n\n(هنا هتكتبي النص)';
  final String _SIXTH_KYRIE_41 = '📖 يارب ارحم 41 مرة\n\n(هنا هتكتبي الصلاة)';
  final String _SIXTH_HOLY = '📖 قدوس قدوس قدوس\n\n(هنا هتكتبي النص)';
  final String _SIXTH_ABSOLUTION = '📖 التحليل\n\n(هنا هتكتبي النص)';
  final String _SIXTH_LAST_REQUESTS =
      '📖 طلبة تقال آخر كل ساعة\n\n(هنا هتكتبي الطلبات)';

  // ============================================================
  // ==================== نصوص صلاة الساعة التاسعة ====================
  // ============================================================

  final String _NINTH_LORD_PRAYER =
      '📖 الصلاة الربانية\n\n(هنا هتكتبي النص الخاص بصلاة الساعة التاسعة)';
  final String _NINTH_THANKSGIVING = '📖 صلاة الشكر\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_50 = '📖 المزمور الخمسون\n\n(هنا هتكتبي النص)';
  final String _NINTH_START = '📖 بدء الصلاة\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_95 = '📖 مزمور 95\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_96 = '📖 مزمور 96\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_97 = '📖 مزمور 97\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_98 = '📖 مزمور 98\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_99 = '📖 مزمور 99\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_100 = '📖 مزمور 100\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_109 = '📖 مزمور 109\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_110 = '📖 مزمور 110\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_111 = '📖 مزمور 111\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_112 = '📖 مزمور 112\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_114 = '📖 مزمور 114\n\n(هنا هتكتبي النص)';
  final String _NINTH_PSALM_115 = '📖 مزمور 115\n\n(هنا هتكتبي النص)';
  final String _NINTH_GOSPEL = '📖 الإنجيل (لوقا 9:10-17)\n\n(هنا هتكتبي النص)';
  final String _NINTH_PIECE_1 = '📖 القطعة الأولى\n\n(هنا هتكتبي النص)';
  final String _NINTH_PIECE_2 = '📖 القطعة الثانية\n\n(هنا هتكتبي النص)';
  final String _NINTH_PIECE_3 = '📖 القطعة الثالثة\n\n(هنا هتكتبي النص)';
  final String _NINTH_PIECE_4 = '📖 القطعة الرابعة\n\n(هنا هتكتبي النص)';
  final String _NINTH_PIECE_5 = '📖 القطعة الخامسة\n\n(هنا هتكتبي النص)';
  final String _NINTH_PIECE_6 = '📖 القطعة السادسة\n\n(هنا هتكتبي النص)';
  final String _NINTH_KYRIE_41 = '📖 يارب ارحم 41 مرة\n\n(هنا هتكتبي الصلاة)';
  final String _NINTH_HOLY = '📖 قدوس قدوس قدوس\n\n(هنا هتكتبي النص)';
  final String _NINTH_ABSOLUTION = '📖 التحليل\n\n(هنا هتكتبي النص)';
  final String _NINTH_LAST_REQUESTS =
      '📖 طلبات تقال آخر كل ساعة\n\n(هنا هتكتبي الطلبات)';

  // ============================================================
  // ==================== نصوص صلاة الغروب ====================
  // ============================================================

  final String _SUNSET_LORD_PRAYER =
      '📖 الصلاة الربانية\n\n(هنا هتكتبي النص الخاص بصلاة الغروب)';
  final String _SUNSET_THANKSGIVING = '📖 صلاة الشكر\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_50 = '📖 المزمور الخمسون\n\n(هنا هتكتبي النص)';
  final String _SUNSET_START = '📖 بدء الصلاة\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_116 = '📖 مزمور 116\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_117 = '📖 مزمور 117\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_119 = '📖 مزمور 119\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_120 = '📖 مزمور 120\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_121 = '📖 مزمور 121\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_122 = '📖 مزمور 122\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_123 = '📖 مزمور 123\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_124 = '📖 مزمور 124\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_125 = '📖 مزمور 125\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_126 = '📖 مزمور 126\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_127 = '📖 مزمور 127\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PSALM_128 = '📖 مزمور 128\n\n(هنا هتكتبي النص)';
  final String _SUNSET_GOSPEL =
      '📖 الإنجيل (لوقا 4:38-41)\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PIECE_1 = '📖 القطعة الأولى\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PIECE_2 = '📖 القطعة الثانية\n\n(هنا هتكتبي النص)';
  final String _SUNSET_PIECE_3 = '📖 القطعة الثالثة\n\n(هنا هتكتبي النص)';
  final String _SUNSET_KYRIE_41 = '📖 يارب ارحم 41 مرة\n\n(هنا هتكتبي الصلاة)';
  final String _SUNSET_HOLY = '📖 قدوس قدوس قدوس\n\n(هنا هتكتبي النص)';
  final String _SUNSET_ABSOLUTION = '📖 التحليل\n\n(هنا هتكتبي النص)';
  final String _SUNSET_LAST_REQUESTS =
      '📖 طلبات تقال آخر كل ساعة\n\n(هنا هتكتبي الطلبات)';

  // ============================================================
  // ==================== نصوص صلاة النوم ====================
  // ============================================================

  final String _BEDTIME_LORD_PRAYER =
      '📖 الصلاة الربانية\n\n(هنا هتكتبي النص الخاص بصلاة النوم)';
  final String _BEDTIME_THANKSGIVING = '📖 صلاة الشكر\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_50 = '📖 المزمور الخمسون\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_START = '📖 بدء الصلاة\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_129 = '📖 مزمور 129\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_130 = '📖 مزمور 130\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_131 = '📖 مزمور 131\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_132 = '📖 مزمور 132\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_133 = '📖 مزمور 133\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_136 = '📖 مزمور 136\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_137 = '📖 مزمور 137\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_140 = '📖 مزمور 140\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_141 = '📖 مزمور 141\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_145 = '📖 مزمور 145\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_146 = '📖 مزمور 146\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PSALM_147 = '📖 مزمور 147\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_GOSPEL =
      '📖 الإنجيل (لوقا 2:25-32)\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PIECE_1 = '📖 القطعة الأولى\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PIECE_2 = '📖 القطعة الثانية\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PIECE_3 = '📖 القطعة الثالثة\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PLEASE_LORD = '📖 تفضل يا رب\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_THREE_HOLIES = '📖 الثلاث تقديسات\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_PEACE = '📖 السلام عليكم\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_START_CREED =
      '📖 بدء قانون الإيمان\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_CREED = '📖 قانون الإيمان\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_KYRIE_14 = '📖 يارب ارحم 14 مرة\n\n(هنا هتكتبي الصلاة)';
  final String _BEDTIME_HOLY = '📖 قدوس قدوس قدوس\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_ABSOLUTION = '📖 التحليل\n\n(هنا هتكتبي النص)';
  final String _BEDTIME_LAST_REQUESTS =
      '📖 طلبات تقال آخر كل ساعة\n\n(هنا هتكتبي الطلبات)';
}

class PrayerSection {
  final String title;
  final String content;
  PrayerSection({
    required this.title,
    required this.content,
  });
}
