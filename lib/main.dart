import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'webview_platform.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  registerWebViewPlatform();

  // تشغيل البرنامج بكامل الشاشة مع دعم التدوير التلقائي.
  await SystemChrome.setPreferredOrientations(const [
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  if (!kIsWeb) {
    await SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.immersiveSticky,
    );
  }

  runApp(const NoorAlQuranApp());

  // رسالة ترحيبية صوتية عند أول تشغيل للتطبيق.
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    // نحاول بعد اكتمال الواجهة، وإذا كان محرك النطق ما زال قيد التهيئة نعيد المحاولة.
    await Future<void>.delayed(const Duration(seconds: 1));
    var played = await _playWelcomeVoiceOnce();
    if (!played) {
      await Future<void>.delayed(const Duration(seconds: 3));
      played = await _playWelcomeVoiceOnce();
    }
    if (!played) {
      await Future<void>.delayed(const Duration(seconds: 3));
      await _playWelcomeVoiceOnce();
    }
  });
}

Future<bool> _playWelcomeVoiceOnce() async {
  return _speakWelcomeVoice(force: false);
}

Future<bool> _speakWelcomeVoice({bool force = false}) async {
  try {
    final prefs = await SharedPreferences.getInstance();
    if (!force && prefs.getBool('noor_welcome_voice_played_v5') == true) return true;
    await Future<void>.delayed(const Duration(seconds: 2));
    final tts = FlutterTts();
    if (!kIsWeb && Platform.isIOS) {
      try {
        await tts.setSharedInstance(true);
        await tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [IosTextToSpeechAudioCategoryOptions.duckOthers],
          IosTextToSpeechAudioMode.voicePrompt,
        );
      } catch (_) {}
    }
    try { await tts.stop(); } catch (_) {}
    String language = 'ar-SA';
    try {
      final available = await tts.getLanguages;
      final languages = available is List ? available.map((e) => e.toString()).toList() : <String>[];
      final candidates = <String>['ar-SA', 'ar-IQ', 'ar', 'ar-EG', 'ar-AE'];
      language = candidates.firstWhere(
        (candidate) => languages.contains(candidate),
        orElse: () => languages.firstWhere((e) => e.toLowerCase().startsWith('ar'), orElse: () => 'ar-SA'),
      );
    } catch (_) {}
    await tts.setLanguage(language);
    // على iOS نختار صوتًا عربيًا صريحًا إن كان متوفرًا بدل الاعتماد على الصوت الافتراضي.
    try {
      final voices = await tts.getVoices;
      if (voices is List) {
        final arabicVoice = voices.cast<dynamic>().firstWhere(
          (voice) => voice is Map && '${voice['locale'] ?? ''}'.toLowerCase().startsWith('ar'),
          orElse: () => null,
        );
        if (arabicVoice is Map) {
          final name = arabicVoice['name']?.toString();
          final locale = arabicVoice['locale']?.toString();
          if (name != null && name.isNotEmpty && locale != null && locale.isNotEmpty) {
            await tts.setVoice({'name': name, 'locale': locale});
          }
        }
      }
    } catch (_) {}
    await tts.setSpeechRate(0.38);
    await tts.setPitch(0.95);
    await tts.setVolume(1.0);
    await tts.awaitSpeakCompletion(true);
    const welcomeMessage =
        'السلام عليكم ورحمة الله وبركاته. أهلاً وسهلاً بكم في نور القرآن. '
        'اجعل القرآن رفيق يومك، واقرأ ورتّل القرآن ترتيلاً. '
        'نسأل الله أن يجعل هذا التطبيق نوراً في قلوبكم وحياتكم.';
    dynamic result;
    try { result = await tts.speak(welcomeMessage); } catch (_) { result = null; }
    final accepted = result == 1 || result == '1' || result == true;
    if (!accepted) return false;
    await Future<void>.delayed(const Duration(milliseconds: 250));
    await prefs.setBool('noor_welcome_voice_played_v5', true);
    return true;
  } catch (_) {
    return false;
  }
}

class NoorAlQuranApp extends StatelessWidget {
  const NoorAlQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نور القرآن',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        scaffoldBackgroundColor: const Color(0xFFF7F4EC),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF173F35),
          brightness: Brightness.light,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFF7F4EC),
          foregroundColor: Color(0xFF173F35),
          elevation: 0,
          centerTitle: true,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor: Colors.white,
          indicatorColor: Color(0xFFDDEBE5),
          labelTextStyle: WidgetStatePropertyAll(
            TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          ),
        ),
      ),
      home: const HomePage(),
    );
  }
}

const List<String> surahNames = [
  'الفاتحة',
  'البقرة',
  'آل عمران',
  'النساء',
  'المائدة',
  'الأنعام',
  'الأعراف',
  'الأنفال',
  'التوبة',
  'يونس',
  'هود',
  'يوسف',
  'الرعد',
  'إبراهيم',
  'الحجر',
  'النحل',
  'الإسراء',
  'الكهف',
  'مريم',
  'طه',
  'الأنبياء',
  'الحج',
  'المؤمنون',
  'النور',
  'الفرقان',
  'الشعراء',
  'النمل',
  'القصص',
  'العنكبوت',
  'الروم',
  'لقمان',
  'السجدة',
  'الأحزاب',
  'سبأ',
  'فاطر',
  'يس',
  'الصافات',
  'ص',
  'الزمر',
  'غافر',
  'فصلت',
  'الشورى',
  'الزخرف',
  'الدخان',
  'الجاثية',
  'الأحقاف',
  'محمد',
  'الفتح',
  'الحجرات',
  'ق',
  'الذاريات',
  'الطور',
  'النجم',
  'القمر',
  'الرحمن',
  'الواقعة',
  'الحديد',
  'المجادلة',
  'الحشر',
  'الممتحنة',
  'الصف',
  'الجمعة',
  'المنافقون',
  'التغابن',
  'الطلاق',
  'التحريم',
  'الملك',
  'القلم',
  'الحاقة',
  'المعارج',
  'نوح',
  'الجن',
  'المزمل',
  'المدثر',
  'القيامة',
  'الإنسان',
  'المرسلات',
  'النبأ',
  'النازعات',
  'عبس',
  'التكوير',
  'الانفطار',
  'المطففين',
  'الانشقاق',
  'البروج',
  'الطارق',
  'الأعلى',
  'الغاشية',
  'الفجر',
  'البلد',
  'الشمس',
  'الليل',
  'الضحى',
  'الشرح',
  'التين',
  'العلق',
  'القدر',
  'البينة',
  'الزلزلة',
  'العاديات',
  'القارعة',
  'التكاثر',
  'العصر',
  'الهمزة',
  'الفيل',
  'قريش',
  'الماعون',
  'الكوثر',
  'الكافرون',
  'النصر',
  'المسد',
  'الإخلاص',
  'الفلق',
  'الناس',
];
const List<int> surahStartPages = [
  1, 2, 50, 77, 106, 128, 151, 177, 187, 208,
  221, 235, 249, 255, 262, 267, 282, 293, 305, 312,
  322, 332, 342, 350, 359, 367, 377, 385, 396, 404,
  411, 415, 418, 428, 434, 440, 446, 453, 458, 467,
  477, 483, 489, 496, 499, 502, 507, 511, 515, 518,
  520, 523, 526, 528, 531, 534, 537, 542, 545, 549,
  551, 553, 554, 556, 558, 560, 562, 564, 566, 568,
  570, 572, 574, 575, 577, 578, 580, 582, 583, 585,
  586, 587, 587, 589, 590, 591, 591, 592, 593, 594,
  595, 595, 596, 596, 597, 597, 598, 598, 599, 599,
  600, 600, 601, 601, 601, 602, 602, 602, 603, 603,
  603, 604, 604, 604
];

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int currentIndex = 0;

  final List<Widget> pages = const [
    HomeContent(),
    QuranPage(),
    AdhkarPage(),
    PrayerTimesPage(),
    LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          NavigationDestination(
            icon: Icon(Icons.menu_book_outlined),
            selectedIcon: Icon(Icons.menu_book),
            label: 'القرآن',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_border),
            selectedIcon: Icon(Icons.favorite),
            label: 'الأذكار',
          ),
          NavigationDestination(
            icon: Icon(Icons.access_time_outlined),
            selectedIcon: Icon(Icons.access_time_filled),
            label: 'الصلاة',
          ),
          NavigationDestination(
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'المكتبة',
          ),
        ],
      ),
    );
  }
}
class ContinueReadingCard extends StatefulWidget {
  const ContinueReadingCard({super.key});

  @override
  State<ContinueReadingCard> createState() => _ContinueReadingCardState();
}

class _ContinueReadingCardState extends State<ContinueReadingCard> {
  int? _surah;
  int? _page;
  String? _ayah;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPosition();
  }

  Future<void> _loadPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      int? surah = prefs.getInt('noor_last_read_surah');
      int? page = prefs.getInt('noor_last_read_page_global');
      String? ayah = prefs.getString('noor_last_read_ayah_global');

      // توافق مع النسخ الأقدم: إذا لم تكن المفاتيح العامة موجودة،
      // نبحث عن آخر موضع محفوظ لكل سورة بدل فتح قائمة السور.
      if (surah == null || surah < 1 || surah > 114) {
        int? bestSurah;
        int bestTimestamp = -1;
        for (var i = 1; i <= 114; i++) {
          final ts = prefs.getInt('noor_last_read_updated_at_$i') ?? -1;
          if (ts > bestTimestamp) {
            final p = prefs.getInt('noor_last_read_page_$i');
            if (p != null && p >= 1 && p <= 604) {
              bestTimestamp = ts;
              bestSurah = i;
            }
          }
        }
        if (bestSurah != null) surah = bestSurah;
      }

      if (surah != null && surah >= 1 && surah <= 114) {
        page ??= prefs.getInt('noor_last_read_page_$surah');
        ayah ??= prefs.getString('noor_last_read_ayah_$surah');
      }

      if (page == null && surah != null && surah >= 1 && surah <= 114) {
        page = surahStartPages[surah - 1];
      }

      if (!mounted) return;
      setState(() {
        _surah = (surah != null && surah >= 1 && surah <= 114) ? surah : null;
        _page = (page != null && page >= 1 && page <= 604) ? page : null;
        _ayah = ayah;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openLastReading() async {
    if (_surah == null || _surah! < 1 || _surah! > 114) return;
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => QuranReaderPage(
          surahNumber: _surah!,
          surahName: surahNames[_surah! - 1],
          initialPage: _page,
          initialAyah: _ayah,
        ),
      ),
    );
    await _loadPosition();
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF123D32);
    const gold = Color(0xFFD4B36A);
    const paper = Color(0xFFFFFCF4);
    final hasPosition = _surah != null && _page != null;
    final ayahNumber = _ayah?.contains(':') == true
        ? _ayah!.split(':').last
        : null;

    return Container(
      margin: const EdgeInsets.fromLTRB(18, 18, 18, 0),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: paper,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: gold.withOpacity(.38)),
        boxShadow: const [
          BoxShadow(color: Color(0x12000000), blurRadius: 18, offset: Offset(0, 7)),
        ],
      ),
      child: _loading
          ? const SizedBox(height: 86, child: Center(child: CircularProgressIndicator()))
          : Directionality(
              textDirection: TextDirection.rtl,
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.bookmark_added_rounded, color: gold, size: 26),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('متابعة القراءة', style: TextStyle(color: green, fontSize: 17, fontWeight: FontWeight.w900)),
                        const SizedBox(height: 4),
                        Text(
                          hasPosition
                              ? 'آخر موضع: سورة ${surahNames[_surah! - 1]} • الصفحة $_page${ayahNumber != null ? ' • الآية $ayahNumber' : ''}'
                              : 'لم تبدأ القراءة بعد — ابدأ من المصحف الآن',
                          textAlign: TextAlign.right,
                          style: const TextStyle(color: Color(0xFF70766F), fontSize: 11.5, height: 1.45),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: hasPosition ? _openLastReading : () async {
                      await Navigator.of(context).push(MaterialPageRoute(builder: (_) => const QuranPage()));
                      await _loadPosition();
                    },
                    style: FilledButton.styleFrom(
                      backgroundColor: gold,
                      foregroundColor: green,
                      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    ),
                    child: Text(hasPosition ? 'متابعة' : 'ابدأ', style: const TextStyle(fontWeight: FontWeight.w900)),
                  ),
                ],
              ),
            ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  static const _green = Color(0xFF123D32);
  static const _deepGreen = Color(0xFF0B2D25);
  static const _gold = Color(0xFFD4B36A);
  static const _ivory = Color(0xFFF6F1E5);
  static const _paper = Color(0xFFFBF9F3);
  static const _ink = Color(0xFF25352F);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _ivory,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final horizontal = wide ? 48.0 : 18.0;
            final crossAxisCount = wide ? 4 : 2;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1120),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontal, 14, horizontal, 10),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: _green,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: _gold.withOpacity(.65), width: 1.2),
                              ),
                              child: const Icon(Icons.auto_awesome_rounded, color: _gold, size: 25),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('نور القرآن', textDirection: TextDirection.rtl,
                                    style: TextStyle(color: _deepGreen, fontSize: 22, fontWeight: FontWeight.w900)),
                                  SizedBox(height: 2),
                                  Text('رفيقك في القرآن والذكر والعبادة', textDirection: TextDirection.rtl,
                                    style: TextStyle(color: Color(0xFF6E746E), fontSize: 11.5)),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'تشغيل الترحيب الصوتي',
                              onPressed: () => _speakWelcomeVoice(force: true),
                              icon: const Icon(Icons.volume_up_rounded),
                              color: _green,
                            ),
                            IconButton(
                              tooltip: 'الإعدادات',
                              onPressed: () => _open(context, const LibraryPage()),
                              icon: const Icon(Icons.settings_outlined),
                              color: _green,
                            ),
                          ],
                        ),
                      ),
                    ),

                    // Premium Abbasid-inspired daily Quran مجلس. No external images.
                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          height: wide ? 315 : 300,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(32),
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xFF0B352B), Color(0xFF173F35), Color(0xFF0D2A23)],
                            ),
                            boxShadow: [
                              BoxShadow(color: _deepGreen.withOpacity(.25), blurRadius: 28, offset: const Offset(0, 14)),
                            ],
                            border: Border.all(color: _gold.withOpacity(.45), width: 1),
                          ),
                          child: Stack(
                            children: [
                              Positioned.fill(child: CustomPaint(painter: _AbbasidHomePainter())),
                              Positioned(
                                top: 18,
                                right: 18,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(.075),
                                    borderRadius: BorderRadius.circular(18),
                                    border: Border.all(color: _gold.withOpacity(.45)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    textDirection: TextDirection.rtl,
                                    children: [
                                      Icon(Icons.auto_awesome_rounded, color: _gold, size: 15),
                                      SizedBox(width: 7),
                                      Text('مَجْلِسُ نُورٍ وَتِلَاوَة', textDirection: TextDirection.rtl,
                                        style: TextStyle(color: _gold, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: .2)),
                                    ],
                                  ),
                                ),
                              ),
                              Positioned.fill(
                                child: Padding(
                                  padding: const EdgeInsets.fromLTRB(22, 70, 22, 20),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Row(
                                        textDirection: TextDirection.rtl,
                                        children: [
                                          Expanded(
                                            child: Text('مجلسك اليومي مع القرآن', textDirection: TextDirection.rtl,
                                              textAlign: TextAlign.right,
                                              style: const TextStyle(color: Colors.white, fontSize: 27, fontWeight: FontWeight.w900, height: 1.3)),
                                          ),
                                          IconButton(
                                            tooltip: 'تشغيل الترحيب الصوتي',
                                            onPressed: () async {
                                              final ok = await _speakWelcomeVoice(force: true);
                                              if (context.mounted && !ok) {
                                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تعذر تشغيل الصوت. تأكدي من رفع صوت الجهاز وتوفر صوت عربي في إعدادات النطق.')));
                                              }
                                            },
                                            icon: const Icon(Icons.volume_up_rounded, color: Colors.white),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 7),
                                      const Text('تلاوة هادئة • ذكر • صلاة • قبلة • مناسك', textDirection: TextDirection.rtl,
                                        style: TextStyle(color: Color(0xFFD9E7E0), fontSize: 12.5, fontWeight: FontWeight.w600)),
                                      const Spacer(),
                                      Container(
                                        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                                        decoration: BoxDecoration(
                                          color: Colors.black.withOpacity(.13),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(color: Colors.white.withOpacity(.10)),
                                        ),
                                        child: Row(
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Container(
                                              width: 44,
                                              height: 44,
                                              decoration: BoxDecoration(
                                                color: _gold,
                                                borderRadius: BorderRadius.circular(14),
                                              ),
                                              child: const Icon(Icons.menu_book_rounded, color: _deepGreen, size: 24),
                                            ),
                                            const SizedBox(width: 11),
                                            const Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.end,
                                                children: [
                                                  Text('وردك الحالي', textDirection: TextDirection.rtl,
                                                    style: TextStyle(color: Color(0xFFB9C9C2), fontSize: 10.5, fontWeight: FontWeight.w700)),
                                                  SizedBox(height: 2),
                                                  Text('سورة المزمل • الآية 4', textDirection: TextDirection.rtl,
                                                    style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(width: 10),
                                            FilledButton(
                                              onPressed: () => _open(context, const QuranPage()),
                                              style: FilledButton.styleFrom(
                                                backgroundColor: _gold,
                                                foregroundColor: _deepGreen,
                                                padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
                                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                              ),
                                              child: const Text('ابدأ التلاوة', style: TextStyle(fontWeight: FontWeight.w900)),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),

                    const SliverToBoxAdapter(child: ContinueReadingCard()),

                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 10),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: const [
                            Text('بوابة العبادة', textDirection: TextDirection.rtl,
                              style: TextStyle(color: _deepGreen, fontSize: 19, fontWeight: FontWeight.w900)),
                            Spacer(),
                            Text('الوصول السريع', textDirection: TextDirection.rtl,
                              style: TextStyle(color: Color(0xFF7B817C), fontSize: 11.5)),
                          ],
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.symmetric(horizontal: horizontal),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate([
                          _AbbasidFeatureCard(icon: Icons.menu_book_rounded, title: 'القرآن الكريم', subtitle: 'تلاوة وتصفح المصحف', onTap: () => _open(context, const QuranPage())),
                          _AbbasidFeatureCard(icon: Icons.wb_sunny_rounded, title: 'الأذكار', subtitle: 'الصباح والمساء وغيرها', onTap: () => _open(context, const AdhkarPage()), gold: true),
                          _AbbasidFeatureCard(icon: Icons.auto_awesome_rounded, title: 'الأدعية', subtitle: 'أدعية مختارة', onTap: () => _open(context, const DuasPage())),
                          _AbbasidFeatureCard(icon: Icons.access_time_filled_rounded, title: 'مواقيت الصلاة', subtitle: 'حسب موقعك', onTap: () => _open(context, const PrayerTimesPage())),
                          _AbbasidFeatureCard(icon: Icons.explore_rounded, title: 'القبلة', subtitle: 'اتجاه القبلة بالبوصلة', onTap: () => _open(context, const QiblaPage())),
                          _AbbasidFeatureCard(icon: Icons.mosque_rounded, title: 'مناسك الحج', subtitle: 'دليل واسع وتفاعلي', onTap: () => _open(context, const HajjGuidePage()), gold: true),
                          _AbbasidFeatureCard(icon: Icons.download_rounded, title: 'التنزيلات', subtitle: 'الأصوات المحفوظة أوفلاين', onTap: () => _open(context, const DownloadsPage())),
                          _AbbasidFeatureCard(icon: Icons.touch_app_rounded, title: 'التسبيح', subtitle: 'عداد إلكتروني', onTap: () => _open(context, const TasbihPage())),
                          _AbbasidFeatureCard(icon: Icons.library_books_rounded, title: 'المكتبة', subtitle: 'كل محتوى نور القرآن', onTap: () => _open(context, const LibraryPage())),
                        ]),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: crossAxisCount,
                          crossAxisSpacing: 11,
                          mainAxisSpacing: 11,
                          childAspectRatio: wide ? 1.18 : 1.10,
                        ),
                      ),
                    ),

                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 30),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(20, 18, 20, 18),
                          decoration: BoxDecoration(
                            color: _paper,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: _gold.withOpacity(.35)),
                          ),
                          child: Row(
                            textDirection: TextDirection.rtl,
                            children: [
                              Container(
                                width: 45,
                                height: 45,
                                decoration: BoxDecoration(color: _green, borderRadius: BorderRadius.circular(14)),
                                child: const Icon(Icons.format_quote_rounded, color: _gold, size: 24),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(child: DailyAyahCard()),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class DailyAyahCard extends StatelessWidget {
  const DailyAyahCard({super.key});
  static const _ayahs = <Map<String, String>>[
    {'text': 'إِنَّ مَعَ الْعُسْرِ يُسْرًا', 'ref': 'سورة الشرح • 6'},
    {'text': 'فَاذْكُرُونِي أَذْكُرْكُمْ وَاشْكُرُوا لِي وَلَا تَكْفُرُونِ', 'ref': 'سورة البقرة • 152'},
    {'text': 'إِنَّ اللَّهَ مَعَ الصَّابِرِينَ', 'ref': 'سورة البقرة • 153'},
    {'text': 'وَقُلْ رَبِّ زِدْنِي عِلْمًا', 'ref': 'سورة طه • 114'},
    {'text': 'وَمَن يَتَّقِ اللَّهَ يَجْعَل لَّهُ مَخْرَجًا', 'ref': 'سورة الطلاق • 2'},
    {'text': 'وَمَن يَتَوَكَّلْ عَلَى اللَّهِ فَهُوَ حَسْبُهُ', 'ref': 'سورة الطلاق • 3'},
    {'text': 'إِنَّ اللَّهَ لَا يُغَيِّرُ مَا بِقَوْمٍ حَتَّىٰ يُغَيِّرُوا مَا بِأَنفُسِهِمْ', 'ref': 'سورة الرعد • 11'},
    {'text': 'وَلَا تَيْأَسُوا مِن رَّوْحِ اللَّهِ', 'ref': 'سورة يوسف • 87'},
    {'text': 'إِنَّ اللَّهَ يُحِبُّ التَّوَّابِينَ وَيُحِبُّ الْمُتَطَهِّرِينَ', 'ref': 'سورة البقرة • 222'},
    {'text': 'إِنَّ أَكْرَمَكُمْ عِندَ اللَّهِ أَتْقَاكُمْ', 'ref': 'سورة الحجرات • 13'},
    {'text': 'وَبَشِّرِ الصَّابِرِينَ', 'ref': 'سورة البقرة • 155'},
    {'text': 'وَاللَّهُ مَعَ الصَّابِرِينَ', 'ref': 'سورة الأنفال • 46'},
    {'text': 'وَاذْكُر رَّبَّكَ إِذَا نَسِيتَ', 'ref': 'سورة الكهف • 24'},
    {'text': 'إِنَّ رَبِّي قَرِيبٌ مُّجِيبٌ', 'ref': 'سورة هود • 61'},
    {'text': 'إِنَّ اللَّهَ يَأْمُرُ بِالْعَدْلِ وَالْإِحْسَانِ', 'ref': 'سورة النحل • 90'},
    {'text': 'وَقُولُوا لِلنَّاسِ حُسْنًا', 'ref': 'سورة البقرة • 83'},
    {'text': 'إِنَّ اللَّهَ غَفُورٌ رَّحِيمٌ', 'ref': 'سورة البقرة • 173'},
    {'text': 'وَمَا تَوْفِيقِي إِلَّا بِاللَّهِ', 'ref': 'سورة هود • 88'},
    {'text': 'حَسْبِيَ اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ', 'ref': 'سورة التوبة • 129'},
    {'text': 'إِنَّ اللَّهَ يُحِبُّ الْمُحْسِنِينَ', 'ref': 'سورة البقرة • 195'},
    {'text': 'وَاسْتَعِينُوا بِالصَّبْرِ وَالصَّلَاةِ', 'ref': 'سورة البقرة • 45'},
    {'text': 'أَلَا بِذِكْرِ اللَّهِ تَطْمَئِنُّ الْقُلُوبُ', 'ref': 'سورة الرعد • 28'},
    {'text': 'وَقُلْ لِعِبَادِي يَقُولُوا الَّتِي هِيَ أَحْسَنُ', 'ref': 'سورة الإسراء • 53'},
    {'text': 'وَاخْفِضْ لَهُمَا جَنَاحَ الذُّلِّ مِنَ الرَّحْمَةِ', 'ref': 'سورة الإسراء • 24'},
    {'text': 'وَقُلْ رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا', 'ref': 'سورة الإسراء • 24'},
    {'text': 'إِنَّ اللَّهَ عَلَىٰ كُلِّ شَيْءٍ قَدِيرٌ', 'ref': 'سورة البقرة • 20'},
    {'text': 'إِنَّ اللَّهَ مَعَ الَّذِينَ اتَّقَوا وَالَّذِينَ هُم مُّحْسِنُونَ', 'ref': 'سورة النحل • 128'},
    {'text': 'وَلَا تَهِنُوا وَلَا تَحْزَنُوا', 'ref': 'سورة آل عمران • 139'},
    {'text': 'وَتَوَكَّلْ عَلَى الْحَيِّ الَّذِي لَا يَمُوتُ', 'ref': 'سورة الفرقان • 58'},
    {'text': 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا', 'ref': 'سورة الشرح • 5'},
  ];
  @override
  Widget build(BuildContext context) {
    final dayIndex = DateTime.now().difference(DateTime(2026, 1, 1)).inDays % _ayahs.length;
    final ayah = _ayahs[dayIndex < 0 ? 0 : dayIndex];
    return Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
      const Text('آية اليوم', textDirection: TextDirection.rtl, style: TextStyle(color: _deepGreen, fontSize: 13, fontWeight: FontWeight.w900)),
      const SizedBox(height: 4),
      Text(ayah['text']!, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: const TextStyle(color: _ink, fontSize: 20, height: 1.7, fontWeight: FontWeight.w800)),
      Text(ayah['ref']!, textDirection: TextDirection.rtl, style: const TextStyle(color: Color(0xFF777C76), fontSize: 10.5)),
    ]);
  }
}

class _AbbasidFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool gold;

  const _AbbasidFeatureCard({required this.icon, required this.title, required this.subtitle, required this.onTap, this.gold = false});

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF123D32);
    const goldColor = Color(0xFFD4B36A);
    return Material(
      color: const Color(0xFFFBF9F3),
      borderRadius: BorderRadius.circular(21),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(21),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: goldColor.withOpacity(gold ? .52 : .24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: green,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: goldColor.withOpacity(.55)),
                ),
                child: Icon(icon, color: goldColor, size: 23),
              ),
              const Spacer(),
              Text(title, textDirection: TextDirection.rtl,
                style: const TextStyle(color: Color(0xFF25352F), fontSize: 13.5, fontWeight: FontWeight.w900)),
              const SizedBox(height: 3),
              Text(subtitle, textDirection: TextDirection.rtl, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF7B817C), fontSize: 10.5)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AbbasidHomePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final gold = Paint()..color = const Color(0xFFD4B36A)..style = PaintingStyle.stroke..strokeWidth = 1.1;
    final faint = Paint()..color = Colors.white.withOpacity(.055)..style = PaintingStyle.stroke..strokeWidth = 1;
    final r = Rect.fromLTWH(size.width * .48, -30, size.width * .70, size.height + 60);
    canvas.drawOval(r, faint);
    canvas.drawOval(Rect.fromCenter(center: Offset(size.width * .82, size.height * .52), width: size.height * 1.35, height: size.height * 1.35), faint);

    // Eight-point geometric rosettes inspired by Abbasid ornament, kept subtle so text stays readable.
    for (var row = -1; row < 5; row++) {
      for (var col = 0; col < 6; col++) {
        final x = size.width * .70 + col * 34 + (row.isOdd ? 17 : 0);
        final y = 12 + row * 34.0;
        if (x > size.width + 18 || y > size.height + 18) continue;
        final c = Offset(x, y);
        for (var i = 0; i < 8; i++) {
          final a = i * math.pi / 4;
          final p1 = Offset(c.dx + math.cos(a) * 9, c.dy + math.sin(a) * 9);
          final p2 = Offset(c.dx + math.cos(a + math.pi / 4) * 4, c.dy + math.sin(a + math.pi / 4) * 4);
          canvas.drawLine(p1, p2, faint);
        }
      }
    }

    // Stylized pointed arch.
    final arch = Path()
      ..moveTo(size.width * .08, size.height)
      ..lineTo(size.width * .08, size.height * .62)
      ..quadraticBezierTo(size.width * .22, size.height * .25, size.width * .36, size.height * .62)
      ..lineTo(size.width * .36, size.height);
    canvas.drawPath(arch, gold);
    final inner = Path()
      ..moveTo(size.width * .13, size.height)
      ..lineTo(size.width * .13, size.height * .65)
      ..quadraticBezierTo(size.width * .22, size.height * .40, size.width * .31, size.height * .65)
      ..lineTo(size.width * .31, size.height);
    canvas.drawPath(inner, Paint()..color = Colors.white.withOpacity(.07)..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _ModernFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final Color iconColor;
  final VoidCallback onTap;

  const _ModernFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(14)),
                child: Icon(icon, color: iconColor, size: 23),
              ),
              const Spacer(),
              Text(
                title,
                textDirection: TextDirection.rtl,
                style: const TextStyle(color: Color(0xFF27312C), fontSize: 14, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                textDirection: TextDirection.rtl,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: Color(0xFF7B817C), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  List<int> get _filteredIndices {
    final query = _query.trim().toLowerCase();
    if (query.isEmpty) {
      return List<int>.generate(surahNames.length, (index) => index);
    }

    return List<int>.generate(surahNames.length, (index) => index)
        .where((index) {
      final number = (index + 1).toString();
      final name = surahNames[index].toLowerCase();
      return name.contains(query) || number == query;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _openSurah(int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranReaderPage(
          surahNumber: index + 1,
          surahName: surahNames[index],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredIndices;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F1E8),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF174A43),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'القرآن الكريم',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: const Color(0xFF174A43),
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 18),
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: 'ابحث باسم السورة أو رقمها',
                  hintTextDirection: TextDirection.rtl,
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isNotEmpty
                      ? IconButton(
                          tooltip: 'مسح البحث',
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFFFFFCF5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 8),
              child: Row(
                textDirection: TextDirection.rtl,
                children: [
                  const Expanded(
                    child: Text(
                      'السور',
                      textAlign: TextAlign.right,
                      style: TextStyle(
                        color: Color(0xFF24332D),
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  Text(
                    '${results.length} سورة',
                    style: const TextStyle(
                      color: Color(0xFF7B817C),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: results.isEmpty
                  ? const Center(
                      child: Text(
                        'لم أجد سورة بهذا الاسم أو الرقم',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          color: Color(0xFF6F756F),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(14, 4, 14, 24),
                      itemCount: results.length,
                      separatorBuilder: (_, __) =>
                          const SizedBox(height: 8),
                      itemBuilder: (context, position) {
                        final index = results[position];
                        final number = index + 1;

                        return Material(
                          color: const Color(0xFFFFFCF5),
                          borderRadius: BorderRadius.circular(18),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(18),
                            onTap: () => _openSurah(index),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 12,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: const Color(0xFFE2D9C8),
                                ),
                              ),
                              child: Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Container(
                                    width: 46,
                                    height: 46,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFE8F0EB),
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    alignment: Alignment.center,
                                    child: Text(
                                      '$number',
                                      style: const TextStyle(
                                        color: Color(0xFF174A43),
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.end,
                                      children: [
                                        Text(
                                          'سورة ${surahNames[index]}',
                                          textDirection: TextDirection.rtl,
                                          style: const TextStyle(
                                            color: Color(0xFF24332D),
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'تبدأ من الصفحة ${surahStartPages[index]}',
                                          textDirection: TextDirection.rtl,
                                          style: const TextStyle(
                                            color: Color(0xFF7B817C),
                                            fontSize: 11,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.arrow_back_ios_new_rounded,
                                    size: 16,
                                    color: Color(0xFF8A918B),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class TimingRead {
  final int id;
  final String name;
  final String rewaya;
  final String folderUrl;
  final int soarCount;

  const TimingRead({
    required this.id,
    required this.name,
    required this.rewaya,
    required this.folderUrl,
    required this.soarCount,
  });

  factory TimingRead.fromJson(Map<String, dynamic> json) {
    return TimingRead(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString().trim() ?? '',
      rewaya: json['rewaya']?.toString().trim() ?? '',
      folderUrl: json['folder_url']?.toString() ?? '',
      soarCount: int.tryParse(json['soar_count']?.toString() ?? '') ?? 0,
    );
  }
}

class AyahTiming {
  final int ayah;
  final int startTime;
  final int endTime;
  final String? polygon;
  final int? page;

  const AyahTiming({
    required this.ayah,
    required this.startTime,
    required this.endTime,
    this.polygon,
    this.page,
  });

  factory AyahTiming.fromJson(Map<String, dynamic> json) {
    final pageUrl = json['page']?.toString();
    final pageMatch = pageUrl == null
        ? null
        : RegExp(r'/([0-9]{3})\.svg').firstMatch(pageUrl);
    return AyahTiming(
      ayah: int.tryParse(json['ayah']?.toString() ?? '') ?? -1,
      startTime: int.tryParse(json['start_time']?.toString() ?? '') ?? 0,
      endTime: int.tryParse(json['end_time']?.toString() ?? '') ?? 0,
      polygon: json['polygon']?.toString(),
      page: int.tryParse(pageMatch?.group(1) ?? ''),
    );
  }
}


class SurahInfo {
  final String revelationPlace;
  final int ayahCount;
  final String context;
  final String? sabab;

  const SurahInfo({
    required this.revelationPlace,
    required this.ayahCount,
    required this.context,
    this.sabab,
  });
}

// عدد الآيات وفق عدّ حفص المتداول في مصحف المدينة. التصنيف المكي/المدني
// هو التصنيف المشهور، مع وجود خلاف في بعض السور عند أهل العلم.
const List<int> _surahAyahCounts = [
  7,286,200,176,120,165,206,75,129,109,123,111,43,52,99,128,111,110,98,135,112,78,118,64,77,227,93,88,69,60,34,30,73,54,45,83,182,88,75,85,54,53,89,59,37,35,38,29,18,45,60,49,62,55,78,96,29,22,24,13,14,11,11,18,12,12,30,52,52,44,28,28,20,56,40,31,50,40,46,42,29,19,36,25,22,17,19,26,30,20,15,21,11,8,8,19,5,8,8,11,11,8,3,9,5,4,7,3,6,3,5,4,5,6,
];

// التصنيف المشهور، مع الإشارة داخل الواجهة إلى أن بعض السور فيها خلاف.
const List<String> _surahRevelationPlaces = [
  'مكية','مدنية','مدنية','مدنية','مدنية','مكية','مكية','مدنية','مدنية','مكية',
  'مكية','مكية','مكية','مكية','مكية','مكية','مكية','مكية','مكية','مكية',
  'مكية','مدنية','مكية','مدنية','مكية','مكية','مكية','مكية','مكية','مكية',
  'مكية','مكية','مدنية','مكية','مكية','مكية','مكية','مكية','مكية','مكية',
  'مكية','مكية','مكية','مكية','مكية','مكية','مدنية','مدنية','مدنية','مكية',
  'مكية','مكية','مكية','مكية','مكية','مكية','مدنية','مدنية','مدنية','مدنية',
  'مدنية','مدنية','مدنية','مدنية','مدنية','مدنية','مكية','مكية','مكية','مكية',
  'مكية','مكية','مكية','مكية','مكية','مدنية','مكية','مكية','مكية','مكية',
  'مكية','مكية','مكية','مكية','مكية','مكية','مكية','مكية','مكية','مكية',
  'مكية','مكية','مكية','مكية','مكية','مكية','مكية','مكية','مكية','مكية',
  'مكية','مكية','مكية','مكية','مكية','مكية','مكية','مكية','مدنية','مكية',
  'مكية','مكية','مكية','مكية',
];

final Map<int, String> _surahContext = {
  1: 'فاتحة الكتاب، تجمع أصول الثناء على الله والعبادة والاستعانة وطلب الهداية.',
  2: 'سورة طويلة مدنية تبني أصول العقيدة والعبادة والتشريع وتعرض نماذج من تاريخ بني إسرائيل وأهل الكتاب.',
  3: 'تركز على التوحيد، والثبات، وقصة آل عمران، وأحداث غزوة أُحد والحوار مع أهل الكتاب.',
  4: 'تتناول بناء المجتمع المسلم، والعدل، وحقوق الضعفاء والأسرة والنساء والأيتام.',
  5: 'تتناول الوفاء بالعقود، والأحكام، والطعام، والعلاقات مع أهل الكتاب، وإكمال الدين.',
  9: 'تتناول البراءة من المشركين، وأحوال المنافقين، والتوبة والجهاد والصدق.',
  12: 'قصة يوسف عليه السلام في سياق متكامل، وفيها دروس الصبر والعفة والعفو وحسن العاقبة.',
  18: 'تعرض قصص أصحاب الكهف وصاحب الجنتين وموسى والخضر وذي القرنين، وتبرز فتن الدين والمال والعلم والسلطان.',
  24: 'تتناول العفة وآداب المجتمع، وحادثة الإفك، وغض البصر، والاستئذان، ونور الله.',
  33: 'تتناول تنظيم المجتمع والأسرة، وأحكام النبي ﷺ وأزواجه، وغزوة الأحزاب.',
  48: 'تتناول صلح الحديبية وفتحًا قريبًا، وما فيه من نصر وطمأنينة وبيعة الرضوان.',
  49: 'سورة آداب المجتمع: التثبت من الأخبار، إصلاح ذات البين، خفض الصوت، ترك السخرية والغيبة، وتقوى الله.',
  55: 'تعدد نعم الله وآلائه على الإنس والجن، وتدعو إلى الاعتراف بالنعم وشكر المنعم.',
  58: 'تبدأ بحادثة المرأة التي جادلت النبي ﷺ في شأن زوجها، ثم تبين أحكام الظهار وآداب المجالس والولاء.',
  59: 'تتناول إجلاء بني النضير، وأحكام الفيء، وصفات المهاجرين والأنصار، وخاتمتها أسماء الله الحسنى.',
  60: 'تتناول البراءة من موالاة أعداء الدين، مع بيان ضوابط التعامل والبر والإقساط لمن لم يقاتل المسلمين.',
  67: 'تدعو إلى التفكر في خلق السماوات والأرض، وإثبات قدرة الله وعلمه والبعث.',
  93: 'تذكّر بنعم الله على النبي ﷺ، وتبعث على اليقين بأن العسر لا يدوم وأن العاقبة للخير.',
  94: 'تتحدث عن شرح الصدر ورفع الذكر، وتؤكد اقتران العسر باليسر والدعوة إلى مواصلة العمل والعبادة.',
  96: 'من أوائل ما نزل، وتبدأ بالأمر بالقراءة وبيان خلق الإنسان وعلم الله، وتختم بالأمر بالسجود والاقتراب.',
  110: 'تعلن اقتراب إتمام الرسالة ودخول الناس في دين الله أفواجًا، وتوجّه إلى التسبيح والاستغفار.',
  111: 'تتناول أبا لهب وزوجه بسبب عداوتهما للنبي ﷺ وإيذائهما للدعوة.',
  112: 'تقرر توحيد الله وتنزهه عن الولد والكفء، وهي سورة خالصة في تقرير التوحيد.',
  113: 'تعلم الاستعاذة بالله من الشرور الظاهرة، ومن شر ما خلق ومن الليل إذا أظلم ومن السحر والحسد.',
  114: 'تعلم الاستعاذة بالله من الشر الباطن والوسوسة، وتؤكد أن الله رب الناس وملكهم وإلههم.',
};

final Map<int, String> _surahSabab = {
  58: 'ورد سبب نزول أوائلها في قصة خولة بنت ثعلبة رضي الله عنها حين ظاهر منها زوجها، فاشتكت أمرها إلى النبي ﷺ، فنزل صدر السورة في بيان حكم الظهار.',
  80: 'وردت روايات صحيحة في سبب نزول أوائلها في شأن عبد الله بن أم مكتوم رضي الله عنه عندما جاء يسأل النبي ﷺ وهو يخاطب بعض زعماء قريش؛ وتختلف الروايات في بعض التفاصيل.',
  93: 'وردت روايات في سبب نزولها بعد انقطاع الوحي مدة، وفيها تثبيت للنبي ﷺ، مع اختلاف أهل التفسير في تفاصيل القصة.',
  111: 'نزلت في ذم أبي لهب وزوجه بسبب شدة عداوتهما للنبي ﷺ ومقاومتهما لدعوته.',
  110: 'ورد في سياقها أنها نزلت بعد فتح مكة، وفيها إشارة إلى تمام النصر وقرب انتهاء مهمة النبي ﷺ، وورد ذلك في أحاديث صحيحة.',
};

SurahInfo _surahInfoFor(int number) {
  final i = (number - 1).clamp(0, surahNames.length - 1);
  return SurahInfo(
    revelationPlace: _surahRevelationPlaces[i],
    ayahCount: _surahAyahCounts[i],
    context: _surahContext[number] ?? 'تتضمن السورة موضوعات إيمانية وتشريعية وتربوية مترابطة، ويُستحسن الرجوع إلى تفسير موثوق لفهم سياق آياتها على وجه التفصيل.',
    sabab: _surahSabab[number],
  );
}

class QuranReaderPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;
  final int? initialPage;
  final String? initialAyah;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.initialPage,
    this.initialAyah,
  });

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> with WidgetsBindingObserver {
  late int currentPage;
  late WebViewController controller;
List<TimingRead> timingReads = [];
  bool loadingReciters = false;
  final AudioPlayer _audioPlayer = AudioPlayer();
  List<AyahTiming> _ayahTimings = [];
  StreamSubscription<Duration>? _positionSubscription;
  String? _selectedAyah;
  TimingRead? _selectedRead;
  double _speed = 1.0;
  int _repeatCount = 1;
  int _completedRepeats = 0;
  bool _handlingCompletion = false;
  bool _isFullSurahPlayback = false;
  String? _lastHighlightedAyah;
  int? _lastHighlightedPage;
  String? _lastReadAyah;
  StreamSubscription<ProcessingState>? _processingSubscription;

  // إضافات واجهة القارئ الاحترافية
  bool _isNightMode = false;
  double _mushafTextScale = 1.0;
  int? _bookmarkPage;
  int? _lastReadPage;
  final Set<String> _savedAyahs = <String>{};
  final Set<int> _favoriteReciterIds = <int>{};
  int? _lastReciterId;
  bool _prefsLoaded = false;

  // آخر صفحة تم تحميلها فعلياً؛ نستخدمها حتى تبقى أدوات القارئ
  // متزامنة مع صفحة المصحف الظاهرة.
  int? _loadedPage;

  // يمنع الانتقال السريع المتكرر بين الصفحات عند السحب المتتابع.
  bool _isPageSwipeBusy = false;

  // نراقب اتجاه الجهاز حتى نعيد ضبط مساحة المصحف داخل WebView
  // عند الانتقال بين العمودي والأفقي بدون كسر بقية خصائص القارئ.
  bool? _lastLandscape;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    currentPage = (widget.initialPage != null && widget.initialPage! >= 1 && widget.initialPage! <= 604)
        ? widget.initialPage!
        : surahStartPages[widget.surahNumber - 1];
    _lastReadAyah = widget.initialAyah;
    _lastHighlightedAyah = widget.initialAyah;
    _bookmarkPage = currentPage;
    _loadReaderPreferences();

    _positionSubscription =
        _audioPlayer.positionStream.listen(_onAudioPosition);

    _processingSubscription = _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleAudioCompleted();
      }
    });

    controller = WebViewController();

    if (!kIsWeb) {
      controller
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(const Color(0xFFFFF7F1))
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (_) {
              _installMushafInteractions();
              Future<void>.delayed(const Duration(milliseconds: 150), _installMushafInteractions);
              Future<void>.delayed(const Duration(milliseconds: 500), _installMushafInteractions);
            },
          ),
        )
        ..addJavaScriptChannel(
          'AyahChannel',
          onMessageReceived: (message) {
            _rememberLastReadAyah(message.message);
            _showReciters(message.message);
          },
        )
        ..addJavaScriptChannel(
          'NavigationChannel',
          onMessageReceived: (message) async {
            if (_isPageSwipeBusy) return;

            final isNext = message.message == 'next';
            final isPrev = message.message == 'prev';
            if (!isNext && !isPrev) return;

            _isPageSwipeBusy = true;

            // تباطؤ بسيط حتى يكون الانتقال مريحاً ولا تقفز عدة صفحات.
            await Future<void>.delayed(
              const Duration(milliseconds: 180),
            );

            if (!mounted) {
              _isPageSwipeBusy = false;
              return;
            }

            // في وضع المصحف العربي: السحب لليمين = الصفحة التالية.
            final targetPage = isNext
                ? currentPage + 1
                : currentPage - 1;

            await _changePage(targetPage);

            if (mounted) {
              await Future<void>.delayed(
                const Duration(milliseconds: 120),
              );
            }

            _isPageSwipeBusy = false;
          },
        )
        ..addJavaScriptChannel(
          'PageChannel',
          onMessageReceived: (message) {
            final page = int.tryParse(message.message);
            if (page != null && mounted) {
              setState(() => currentPage = page);
              _lastReadPage = page;
              _saveReaderPreferences();
            }
          },
        );
    }

    _loadMushafPage(currentPage);
  }

  void _syncMushafOrientation(bool isLandscape) {
    if (_lastLandscape == isLandscape) return;
    _lastLandscape = isLandscape;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      try {
        await controller.runJavaScript(
          "if(window.setNoorOrientation){window.setNoorOrientation(${isLandscape ? 'true' : 'false'});}",
        );
      } catch (_) {}
    });
  }

Future<void> _loadReciters() async {
    setState(() {
      loadingReciters = true;
    });

    try {
      final response = await http
          .get(
            Uri.parse(
              'https://mp3quran.net/api/v3/ayat_timing/reads',
            ),
          )
          .timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      final List<dynamic> list = data is List ? data : [];

      if (!mounted) return;

      setState(() {
        timingReads = list
            .map(
              (item) => TimingRead.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .where(
              (read) =>
                  read.id > 0 && read.folderUrl.isNotEmpty,
            )
            .toList();
        loadingReciters = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loadingReciters = false;
      });
    }
  }

  Future<List<AyahTiming>> _loadAyahTimings(
    TimingRead read,
  ) async {
    final response = await http.get(
      Uri.parse(
        'https://mp3quran.net/api/v3/ayat_timing'
        '?surah=${widget.surahNumber}&read=${read.id}',
      ),
    );

    if (response.statusCode != 200) {
      throw Exception('تعذر تحميل توقيت الآيات');
    }

    final data = jsonDecode(response.body);
    final List<dynamic> list = data is List ? data : [];

    return list
        .map(
          (item) => AyahTiming.fromJson(
            Map<String, dynamic>.from(item),
          ),
        )
        .where(
          (item) =>
              item.ayah >= 1 &&
              item.endTime > item.startTime,
        )
        .toList();
  }

  String _surahAudioUrl(TimingRead read) {
    final surahId =
        widget.surahNumber.toString().padLeft(3, '0');
    return '${read.folderUrl}$surahId.mp3';
  }

  Future<File> _surahFile(TimingRead read) async {
    final dir = await getApplicationDocumentsDirectory();
    return File(
      '${dir.path}/noor_quran_${widget.surahNumber}_${read.id}.mp3',
    );
  }

  Future<bool> _hasOfflineSurah(TimingRead read) async {
    final file = await _surahFile(read);
    return file.exists();
  }

  Future<File> _downloadSurahForRead(
    TimingRead read, {
    bool showMessage = true,
  }) async {
    final file = await _surahFile(read);

    if (await file.exists()) {
      return file;
    }

    if (showMessage && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'جاري تنزيل الصوت للاستخدام بدون إنترنت...',
          ),
        ),
      );
    }

    final response = await http
        .get(Uri.parse(_surahAudioUrl(read)))
        .timeout(const Duration(seconds: 60));

    if (response.statusCode != 200) {
      throw Exception('فشل تنزيل الصوت');
    }

    await file.writeAsBytes(
      response.bodyBytes,
      flush: true,
    );

    return file;
  }

  Future<void> _prepareAndPlayAyah(
    String ayah,
    TimingRead read, {
    int? repeatCount,
    double? speed,
  }) async {
    final parts = ayah.split(':');
    if (parts.length != 2) return;

    final verse = int.tryParse(parts[1]);
    if (verse == null) return;

    try {
      if (_ayahTimings.isEmpty ||
          _selectedRead?.id != read.id) {
        _ayahTimings = await _loadAyahTimings(read);
      }

      AyahTiming? timing;
      for (final item in _ayahTimings) {
        if (item.ayah == verse) {
          timing = item;
          break;
        }
      }

      if (timing == null) {
        throw Exception('لا يوجد توقيت لهذه الآية');
      }

      _selectedAyah = ayah;
      _selectedRead = read;
      _isFullSurahPlayback = false;
      _speed = speed ?? _speed;
      _repeatCount = repeatCount ?? _repeatCount;
      _completedRepeats = 0;
      _handlingCompletion = false;
      if (mounted) setState(() {});

      await _audioPlayer.stop();

      final offlineFile = await _surahFile(read);

      if (await offlineFile.exists()) {
        await _audioPlayer.setFilePath(
          offlineFile.path,
        );
      } else {
        await _audioPlayer.setUrl(
          _surahAudioUrl(read),
        );
      }

      await _audioPlayer.setClip(
        start: Duration(
          milliseconds: timing.startTime,
        ),
        end: Duration(
          milliseconds: timing.endTime,
        ),
      );

      await _audioPlayer.setSpeed(_speed);

      _highlightTiming(timing);
      await _audioPlayer.play();
    } catch (e) {
      if (!mounted) return;

      _showMessage(
        'تعذر تشغيل الآية: '
        '${e.toString().replaceFirst('Exception: ', '')}',
      );
    }
  }

  void _onAudioPosition(Duration position) {
    if (!_isFullSurahPlayback || _ayahTimings.isEmpty) return;

    final ms = position.inMilliseconds;
    for (final item in _ayahTimings) {
      if (ms >= item.startTime && ms < item.endTime) {
        if (_lastHighlightedAyah != '${widget.surahNumber}:${item.ayah}') {
          _highlightTiming(item);
        }
        if (item.page != null && item.page != _lastHighlightedPage) {
          _lastHighlightedPage = item.page;
          _changePage(item.page!);
        }
        break;
      }
    }
  }

  void _highlightTiming(AyahTiming timing) {
    final ayahKey = '${widget.surahNumber}:${timing.ayah}';
    final changed = _lastHighlightedAyah != ayahKey;
    _lastHighlightedAyah = ayahKey;
    _lastReadAyah = ayahKey;
    _lastHighlightedPage = currentPage;
    if (changed) _rememberLastReadAyah(ayahKey);
    if (kIsWeb) return;

    final js = "if(window.setNoorAyahHighlight){window.setNoorAyahHighlight('${widget.surahNumber}','${timing.ayah}');}";
    // إعادة المحاولة بعد تحميل/إعادة رسم صفحة المصحف؛ هذا يمنع ضياع
    // التضليل عند انتقال القارئ بين الصفحات أو إعادة تحميل الـWebView.
    controller.runJavaScript(js);
    Future<void>.delayed(const Duration(milliseconds: 120), () {
      if (!mounted) return;
      controller.runJavaScript(js);
    });
    Future<void>.delayed(const Duration(milliseconds: 450), () {
      if (!mounted) return;
      controller.runJavaScript(js);
    });
  }

  void _clearAyahHighlight() {
    _lastHighlightedAyah = null;
    if (kIsWeb) return;
    controller.runJavaScript("""
      window.noorHighlightSurah = null;
      window.noorHighlightAyah = null;
      document.querySelectorAll('.ayahPolygon').forEach(function(el) {
        el.classList.remove('selected');
        if (el.dataset.noorOriginalFill) el.style.setProperty('fill', el.dataset.noorOriginalFill, 'important');
        else el.style.removeProperty('fill');
        if (el.dataset.noorOriginalStroke) el.style.setProperty('stroke', el.dataset.noorOriginalStroke, 'important');
        else el.style.removeProperty('stroke');
        if (el.dataset.noorOriginalStrokeWidth) el.style.setProperty('stroke-width', el.dataset.noorOriginalStrokeWidth, 'important');
        else el.style.removeProperty('stroke-width');
        if (el.dataset.noorOriginalFillOpacity) el.style.setProperty('fill-opacity', el.dataset.noorOriginalFillOpacity, 'important');
        else el.style.removeProperty('fill-opacity');
      });
    """);
  }

  Future<void> _playFullSurah(TimingRead read) async {
    try {
      _ayahTimings = await _loadAyahTimings(read);
      if (_ayahTimings.isEmpty) throw Exception('لا توجد توقيتات متاحة لهذه السورة');

      _selectedRead = read;
      _selectedAyah = null;
      _isFullSurahPlayback = true;
      _lastHighlightedPage = null;
      _completedRepeats = 0;
      _handlingCompletion = false;
      if (mounted) setState(() {});

      await _audioPlayer.stop();
      final offlineFile = await _surahFile(read);
      if (await offlineFile.exists()) {
        await _audioPlayer.setFilePath(offlineFile.path);
      } else {
        await _audioPlayer.setUrl(_surahAudioUrl(read));
      }
      await _audioPlayer.setClip(start: null, end: null);
      await _audioPlayer.setSpeed(_speed);
      await _audioPlayer.play();

      final first = _ayahTimings.first;
      if (first.page != null) {
        _lastHighlightedPage = first.page;
        await _changePage(first.page!);
      }
    } catch (e) {
      if (!mounted) return;
      _showMessage('تعذر تشغيل السورة: ${e.toString().replaceFirst('Exception: ', '')}');
    }
  }

  void _handleAudioCompleted() {
    if (_handlingCompletion || _selectedAyah == null || _isFullSurahPlayback) {
      return;
    }

    _handlingCompletion = true;

    if (_repeatCount == 0 ||
        _completedRepeats + 1 < _repeatCount) {
      _completedRepeats++;

      Future.microtask(() async {
        try {
          await _audioPlayer.seek(Duration.zero);
          await _audioPlayer.play();
        } finally {
          _handlingCompletion = false;
        }
      });
    } else {
      _completedRepeats = 0;
      _handlingCompletion = false;
    }
  }

  String get _currentSurahName {
    var index = 0;
    for (var i = 0; i < surahStartPages.length; i++) {
      if (surahStartPages[i] <= currentPage) {
        index = i;
      } else {
        break;
      }
    }
    return surahNames[index];
  }

  @override
  Widget build(BuildContext context) {
    final pageText = 'الصفحة $currentPage من 604';
    final juzText = 'الجزء ${_juz(currentPage)}';
    final currentSurahTitle = 'سورة $_currentSurahName';
    final isBookmarked = _bookmarkPage == currentPage;
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    final shellBackground = _isNightMode
        ? const Color(0xFF0D1513)
        : const Color(0xFFF1EBDD);
    final panel = _isNightMode
        ? const Color(0xFF16221F)
        : const Color(0xFFFFFCF4);
    final panel2 = _isNightMode
        ? const Color(0xFF1D2B27)
        : const Color(0xFFF8F2E5);
    final ink = _isNightMode
        ? const Color(0xFFF4E8C9)
        : const Color(0xFF173F38);
    final muted = _isNightMode
        ? const Color(0xFFAABBB4)
        : const Color(0xFF786F61);
    final gold = const Color(0xFFD5AA4A);
    final progress = currentPage / 604;

    _syncMushafOrientation(isLandscape);

    return Scaffold(
      backgroundColor: shellBackground,
      appBar: isLandscape
          ? null
          : PreferredSize(
              preferredSize: const Size.fromHeight(104),
              child: SafeArea(
                bottom: false,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: _isNightMode
                          ? const [Color(0xFF123D36), Color(0xFF102F2A)]
                          : const [Color(0xFF19554B), Color(0xFF123F38)],
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Color(0x33000000),
                        blurRadius: 18,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: 72,
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: 'رجوع',
                              onPressed: _closeReader,
                              icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
                            ),
                            Expanded(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.auto_stories_rounded, color: Color(0xFFF0CF7A), size: 17),
                                      const SizedBox(width: 7),
                                      Text(
                                        currentSurahTitle,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 19,
                                          fontWeight: FontWeight.w900,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '$juzText  •  $pageText',
                                    style: const TextStyle(
                                      color: Color(0xFFD9E6DF),
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'الوضع الليلي',
                              onPressed: _toggleNightMode,
                              icon: Icon(
                                _isNightMode ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                                color: const Color(0xFFF0CF7A),
                              ),
                            ),
                            IconButton(
                              tooltip: 'معلومات السورة',
                              onPressed: _showSurahInfo,
                              icon: const Icon(
                                Icons.info_outline_rounded,
                                color: Color(0xFFF0CF7A),
                              ),
                            ),
                            IconButton(
                              tooltip: 'دليل التجويد',
                              onPressed: _showTajweedGuide,
                              icon: const Icon(
                                Icons.palette_outlined,
                                color: Color(0xFFF0CF7A),
                              ),
                            ),
                            IconButton(
                              tooltip: 'التجويد الملون',
                              onPressed: _openTajweedColoredPage,
                              icon: const Icon(
                                Icons.format_color_text_rounded,
                                color: Color(0xFFF0CF7A),
                              ),
                            ),
                            IconButton(
                              tooltip: isBookmarked ? 'إزالة العلامة' : 'حفظ الصفحة',
                              onPressed: () {
                                setState(() => _bookmarkPage = isBookmarked ? null : currentPage);
                                _saveReaderPreferences();
                                _showMessage(isBookmarked ? 'تمت إزالة علامة القراءة' : 'تم حفظ الصفحة $currentPage');
                              },
                              icon: Icon(
                                isBookmarked ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                                color: const Color(0xFFF0CF7A),
                              ),
                            ),
                            PopupMenuButton<String>(
                              tooltip: 'أدوات المصحف',
                              icon: const Icon(Icons.tune_rounded, color: Colors.white),
                              onSelected: (value) {
                                if (value == 'jump') {
                                  _showGoToPageDialog();
                                } else if (value == 'bookmark') {
                                  if (_bookmarkPage != null) {
                                    _changePage(_bookmarkPage!);
                                  } else {
                                    _showMessage('لا توجد علامة محفوظة بعد');
                                  }
                                } else if (value == 'text_size') {
                                  _showMushafTextSizeDialog();
                                } else if (value == 'saved') {
                                  _showSavedAyahs();
                                } else if (value == 'surah_info') {
                                  _showSurahInfo();
                                } else if (value == 'tajweed') {
                                  _showTajweedGuide();
                                } else if (value == 'tajweed_colored') {
                                  _openTajweedColoredPage();
                                } else if (value == 'surahs') {
                                  _showReaderTools();
                                }
                              },
                              itemBuilder: (context) => [
                                const PopupMenuItem(
                                  value: 'jump',
                                  child: ListTile(leading: Icon(Icons.find_in_page_rounded), title: Text('الانتقال إلى صفحة')),
                                ),
                                const PopupMenuItem(
                                  value: 'bookmark',
                                  child: ListTile(leading: Icon(Icons.bookmark_rounded), title: Text('العودة إلى العلامة')),
                                ),
                                const PopupMenuItem(
                                  value: 'text_size',
                                  child: ListTile(leading: Icon(Icons.text_fields_rounded), title: Text('حجم عرض المصحف')),
                                ),
                                const PopupMenuItem(
                                  value: 'saved',
                                  child: ListTile(leading: Icon(Icons.bookmarks_rounded), title: Text('الآيات المحفوظة')),
                                ),
                                const PopupMenuItem(
                                  value: 'surah_info',
                                  child: ListTile(leading: Icon(Icons.info_outline_rounded), title: Text('معلومات السورة')),
                                ),
                                const PopupMenuItem(
                                  value: 'tajweed',
                                  child: ListTile(leading: Icon(Icons.palette_outlined), title: Text('دليل التجويد')),
                                ),
                                const PopupMenuItem(
                                  value: 'tajweed_colored',
                                  child: ListTile(leading: Icon(Icons.format_color_text_rounded), title: Text('التجويد الملون')),
                                ),
                                const PopupMenuItem(
                                  value: 'surahs',
                                  child: ListTile(leading: Icon(Icons.swap_horiz_rounded), title: Text('السورة السابقة / التالية')),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            minHeight: 4,
                            value: progress,
                            backgroundColor: const Color(0x335E8B7C),
                            valueColor: AlwaysStoppedAnimation<Color>(gold),
                          ),
                        ),
                      ),
                      const SizedBox(height: 9),
                    ],
                  ),
                ),
              ),
            ),
      body: SafeArea(
        top: isLandscape,
        bottom: false,
        child: Column(
          children: [
            if (!isLandscape)
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 9, 12, 6),
                child: Row(
                  children: [
                    _readerMiniChip(Icons.menu_book_rounded, 'مصحف المدينة', ink, panel2, muted),
                    const Spacer(),
                    _readerMiniChip(Icons.layers_rounded, juzText, ink, panel2, muted),
                    const SizedBox(width: 6),
                    _readerMiniChip(Icons.bookmark_rounded, isBookmarked ? 'محفوظ' : 'غير محفوظ', isBookmarked ? gold : ink, panel2, muted),
                  ],
                ),
              ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  isLandscape ? 0 : 10,
                  isLandscape ? 0 : 2,
                  isLandscape ? 0 : 10,
                  0,
                ),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: panel,
                    borderRadius: BorderRadius.circular(isLandscape ? 0 : 26),
                    border: isLandscape ? null : Border.all(color: _isNightMode ? const Color(0xFF30443D) : const Color(0xFFE1D5BE)),
                    boxShadow: isLandscape
                        ? const []
                        : const [BoxShadow(color: Color(0x18000000), blurRadius: 18, offset: Offset(0, 6))],
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(isLandscape ? 0 : 25),
                          child: Container(
                            color: _isNightMode ? const Color(0xFF111816) : const Color(0xFFFFFEFA),
                            child: kIsWeb && _isNightMode
                                ? ColorFiltered(
                                    colorFilter: const ColorFilter.matrix([
                                      -0.8, 0, 0, 0, 204,
                                      0, -0.8, 0, 0, 204,
                                      0, 0, -0.8, 0, 204,
                                      0, 0, 0, 1, 0,
                                    ]),
                                    child: WebViewWidget(
                                      key: ValueKey('mushaf-webview-${isLandscape ? "landscape" : "portrait"}'),
                                      controller: controller,
                                    ),
                                  )
                                : WebViewWidget(controller: controller),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (!isLandscape)
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 7, 10, 6),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_selectedRead != null) _buildAudioBar(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                      decoration: BoxDecoration(
                        color: panel,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: _isNightMode ? const Color(0xFF30443D) : const Color(0xFFE0D4BD)),
                        boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 12, offset: Offset(0, 3))],
                      ),
                      child: Row(
                        children: [
                          _readerNavButton(Icons.arrow_back_ios_new_rounded, 'السابق', currentPage > 1 ? () => _changePage(currentPage - 1) : null, ink, gold),
                          Expanded(
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
                              onTap: _showGoToPageDialog,
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 3),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(currentSurahTitle, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: ink)),
                                    const SizedBox(height: 2),
                                    Text('$pageText  •  اضغط للانتقال', style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w600, color: muted)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          _readerNavButton(Icons.arrow_forward_ios_rounded, 'التالي', currentPage < 604 ? () => _changePage(currentPage + 1) : null, ink, gold),
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

  Widget _readerMiniChip(IconData icon, String text, Color ink, Color bg, Color muted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _isNightMode ? const Color(0xFF30443D) : const Color(0xFFE0D4BD)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: _isNightMode ? const Color(0xFFE2C26A) : const Color(0xFF806525)),
          const SizedBox(width: 5),
          Text(text, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w800, color: muted)),
        ],
      ),
    );
  }

  Widget _readerNavButton(IconData icon, String label, VoidCallback? onPressed, Color ink, Color gold) {
    final enabled = onPressed != null;
    return SizedBox(
      width: 66,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(18),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 17, color: enabled ? ink : const Color(0xFFAAA69C)),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 8.5, fontWeight: FontWeight.w700, color: enabled ? ink : const Color(0xFFAAA69C))),
            ],
          ),
        ),
      ),
    );
  }



  void _openTajweedColoredPage() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => TajweedColoredPage(
          surahNumber: widget.surahNumber,
          surahName: widget.surahName,
        ),
      ),
    );
  }

  Future<void> _showSurahInfo() async {
    final info = _surahInfoFor(widget.surahNumber);
    final placeColor = info.revelationPlace == 'مكية'
        ? const Color(0xFF9A6B28)
        : const Color(0xFF1E6A5A);

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _isNightMode
          ? const Color(0xFF16221F)
          : const Color(0xFFFFFCF4),
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: _isNightMode ? const Color(0xFF24463D) : const Color(0xFFE9F0E8),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Icon(Icons.auto_stories_rounded, color: placeColor),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'سورة ${widget.surahName}',
                            style: TextStyle(
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                              color: _isNightMode ? Colors.white : const Color(0xFF173F38),
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'معلومات تساعد القارئ على معرفة السورة وسياقها',
                            style: TextStyle(fontSize: 11, color: _isNightMode ? const Color(0xFFB8C8C1) : const Color(0xFF756D61)),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(child: _infoStat('التصنيف', info.revelationPlace, Icons.location_on_outlined, placeColor)),
                    const SizedBox(width: 8),
                    Expanded(child: _infoStat('عدد الآيات', '${info.ayahCount}', Icons.format_list_numbered_rounded, const Color(0xFF8A6827))),
                    const SizedBox(width: 8),
                    Expanded(child: _infoStat('رقم السورة', '${widget.surahNumber}', Icons.tag_rounded, const Color(0xFF4A6D62))),
                  ],
                ),
                const SizedBox(height: 18),
                _infoSection(
                  title: 'عن السورة',
                  icon: Icons.menu_book_rounded,
                  text: info.context,
                ),
                const SizedBox(height: 12),
                _infoSection(
                  title: 'سبب النزول',
                  icon: Icons.history_edu_rounded,
                  text: info.sabab ?? 'لا يثبت سبب نزول خاص بالسورة كلها في المصادر المشهورة. قد تكون لبعض آياتها أسباب نزول منفردة، ولذلك لا ننسب للسورة سببًا واحدًا من غير دليل.',
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: _isNightMode ? const Color(0xFF202E2A) : const Color(0xFFF6F0E2),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: _isNightMode ? const Color(0xFF34483F) : const Color(0xFFE3D7C0)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.info_outline_rounded, size: 18, color: placeColor),
                      const SizedBox(width: 9),
                      Expanded(
                        child: Text(
                          'ملاحظة: التصنيف المكي والمدني في بعض السور محل خلاف بين أهل العلم؛ لذلك نعرض هنا التصنيف المشهور، وعند وجود اختلاف لا نعرضه على أنه حقيقة قطعية.',
                          style: TextStyle(
                            fontSize: 11.5,
                            height: 1.55,
                            color: _isNightMode ? const Color(0xFFC5D0CB) : const Color(0xFF665F55),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _infoStat(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: _isNightMode ? const Color(0xFF1D2B27) : const Color(0xFFF7F1E5),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _isNightMode ? const Color(0xFF34483F) : const Color(0xFFE2D6BE)),
      ),
      child: Column(
        children: [
          Icon(icon, size: 17, color: color),
          const SizedBox(height: 5),
          Text(title, style: TextStyle(fontSize: 9.5, color: _isNightMode ? const Color(0xFFB4C4BD) : const Color(0xFF7A7266))),
          const SizedBox(height: 2),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: _isNightMode ? Colors.white : const Color(0xFF173F38))),
        ],
      ),
    );
  }

  Widget _infoSection({required String title, required IconData icon, required String text}) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: _isNightMode ? const Color(0xFF1D2B27) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _isNightMode ? const Color(0xFF34483F) : const Color(0xFFE2D6BE)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: const Color(0xFF9A762C)),
              const SizedBox(width: 7),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: _isNightMode ? Colors.white : const Color(0xFF173F38))),
            ],
          ),
          const SizedBox(height: 9),
          Text(text, style: TextStyle(fontSize: 12.5, height: 1.7, color: _isNightMode ? const Color(0xFFD1DAD6) : const Color(0xFF595248))),
        ],
      ),
    );
  }

  Future<void> _showTajweedGuide() async {
    final rules = <Map<String, Object>>[
      {'name': 'المد', 'desc': 'إطالة الصوت بحرف من حروف المد بحسب الحكم.', 'color': const Color(0xFFD24B45)},
      {'name': 'الغنة', 'desc': 'صوت يخرج من الخيشوم ويظهر في أحكام محددة مثل النون والميم المشددتين.', 'color': const Color(0xFF2C8A66)},
      {'name': 'القلقلة', 'desc': 'اضطراب المخرج عند النطق بحروف قطب جد إذا تحققت شروطها.', 'color': const Color(0xFF4267B2)},
      {'name': 'الإخفاء', 'desc': 'النطق بالنون الساكنة أو التنوين بين الإظهار والإدغام مع بقاء الغنة.', 'color': const Color(0xFF8A4DA8)},
      {'name': 'الإدغام', 'desc': 'إدخال حرف في حرف مع أحكامه المعروفة، ومنه الإدغام بغنة وبغير غنة.', 'color': const Color(0xFF3E8F43)},
      {'name': 'الإقلاب', 'desc': 'قلب النون الساكنة أو التنوين ميمًا مخفاة عند الباء.', 'color': const Color(0xFFD77A27)},
      {'name': 'اللام الشمسية', 'desc': 'إدغام لام التعريف في الحروف الشمسية.', 'color': const Color(0xFF7D7D7D)},
    ];

    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _isNightMode ? const Color(0xFF16221F) : const Color(0xFFFFFCF4),
      builder: (sheetContext) => SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 2, 20, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('دليل التجويد', textAlign: TextAlign.center, style: TextStyle(fontSize: 21, fontWeight: FontWeight.w900, color: _isNightMode ? Colors.white : const Color(0xFF173F38))),
              const SizedBox(height: 5),
              Text('ألوان الدليل ستُستخدم لاحقًا لتلوين مواضع الأحكام داخل النص القرآني.', textAlign: TextAlign.center, style: TextStyle(fontSize: 11, color: _isNightMode ? const Color(0xFFB8C8C1) : const Color(0xFF756D61))),
              const SizedBox(height: 15),
              ...rules.map((rule) {
                final color = rule['color'] as Color;
                return Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _isNightMode ? const Color(0xFF1D2B27) : Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: _isNightMode ? const Color(0xFF34483F) : const Color(0xFFE2D6BE)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(width: 12, height: 12, margin: const EdgeInsets.only(top: 3), decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
                      const SizedBox(width: 10),
                      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(rule['name'] as String, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: _isNightMode ? Colors.white : const Color(0xFF173F38))),
                        const SizedBox(height: 3),
                        Text(rule['desc'] as String, style: TextStyle(fontSize: 11.5, height: 1.55, color: _isNightMode ? const Color(0xFFC8D3CE) : const Color(0xFF5F584F))),
                      ])),
                    ],
                  ),
                );
              }),
              const SizedBox(height: 4),
              Text('ملاحظة: تلوين التجويد في صفحة المصحف نفسها يحتاج إلى طبقة بيانات مرتبطة بنص حفص ومواضع الأحكام، لذلك لن نلوّن الحروف تخمينًا أو بطريقة قد تغيّر شكل المصحف.', textAlign: TextAlign.center, style: TextStyle(fontSize: 10.5, height: 1.55, color: _isNightMode ? const Color(0xFF9FB0A8) : const Color(0xFF776F64))),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showMushafTextSizeDialog() async {
    double draftScale = _mushafTextScale;

    await showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final percent = (draftScale * 100).round();

            return AlertDialog(
              title: const Row(
                children: [
                  Icon(Icons.text_fields_rounded),
                  SizedBox(width: 10),
                  Text('حجم خط المصحف'),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '$percent%',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  Slider(
                    min: 0.85,
                    max: 1.40,
                    divisions: 11,
                    value: draftScale,
                    label: '$percent%',
                    onChanged: (value) {
                      setDialogState(() => draftScale = value);
                    },
                  ),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('أصغر'),
                      Text('أكبر'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'اختر الحجم المناسب لك وسيتم حفظه تلقائياً.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                FilledButton(
                  onPressed: () async {
                    setState(() => _mushafTextScale = draftScale);
                    await _saveReaderPreferences();

                    try {
                      await controller.runJavaScript(
                        "if(window.setNoorTextScale){window.setNoorTextScale(${draftScale.toStringAsFixed(3)});}",
                      );
                    } catch (_) {}

                    if (mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: const Text('تطبيق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _toggleNightMode() async {
    final nextMode = !_isNightMode;
    if (!mounted) return;

    setState(() {
      _isNightMode = nextMode;
    });
    await _saveReaderPreferences();

    // ColorFiltered لا يؤثر على WebView كـ Platform View في Chrome،
    // لذلك نعيد تحميل صفحة الـ SVG مع CSS مختلف فعلياً.
    if (kIsWeb) {
      await _loadMushafPage(currentPage);
    }
  }

  Future<void> _showGoToPageDialog() async {
    final pageController = TextEditingController(
      text: currentPage.toString(),
    );

    final page = await showDialog<int>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'الانتقال إلى صفحة',
          textAlign: TextAlign.right,
        ),
        content: TextField(
          controller: pageController,
          autofocus: true,
          keyboardType: TextInputType.number,
          textAlign: TextAlign.center,
          inputFormatters: <TextInputFormatter>[
            FilteringTextInputFormatter.digitsOnly,
          ],
          decoration: InputDecoration(
            hintText: '1 - 604',
            suffixIcon: const Icon(Icons.menu_book_rounded),
            filled: true,
            fillColor: const Color(0xFFF5F1E8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              final value = int.tryParse(pageController.text.trim());
              if (value == null || value < 1 || value > 604) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('اكتبي رقم صفحة من 1 إلى 604'),
                  ),
                );
                return;
              }

              Navigator.of(dialogContext).pop(value);
            },
            child: const Text('انتقال'),
          ),
        ],
      ),
    );

    pageController.dispose();

    if (page != null && mounted) {
      // نغيّر الرقم أولاً ثم نطلب تحميل SVG الصفحة المطلوبة مباشرة.
      await _changePage(page, forceReload: true);
    }
  }

  void _showReaderTools() {
    final currentIndex = _currentSurahIndex;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      backgroundColor: _isNightMode
          ? const Color(0xFF1A2421)
          : const Color(0xFFFFFCF5),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'التنقل بين السور',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: FilledButton.tonalIcon(
                      onPressed: currentIndex > 0
                          ? () {
                              Navigator.pop(context);
                              _openSurah(currentIndex);
                            }
                          : null,
                      icon: const Icon(Icons.arrow_forward_rounded),
                      label: const Text('السورة السابقة'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: currentIndex < surahNames.length - 1
                          ? () {
                              Navigator.pop(context);
                              _openSurah(currentIndex + 2);
                            }
                          : null,
                      icon: const Icon(Icons.arrow_back_rounded),
                      label: const Text('السورة التالية'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                'أنت الآن في سورة $_currentSurahName',
                style: const TextStyle(
                  color: Color(0xFF766F63),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  int get _currentSurahIndex {
    var index = 0;
    for (var i = 0; i < surahStartPages.length; i++) {
      if (surahStartPages[i] <= currentPage) {
        index = i;
      } else {
        break;
      }
    }
    return index;
  }

  void _openSurah(int surahNumber) {
    if (surahNumber < 1 || surahNumber > surahNames.length) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => QuranReaderPage(
          surahNumber: surahNumber,
          surahName: surahNames[surahNumber - 1],
        ),
      ),
    );
  }

  Widget _buildAudioBar() {
    final read = _selectedRead;
    if (read == null) return const SizedBox.shrink();

    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playerState = snapshot.data;
        final isPlaying = playerState?.playing ?? false;

        return Container(
          margin: const EdgeInsets.fromLTRB(10, 6, 10, 4),
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
          decoration: BoxDecoration(
            color: const Color(0xFF8E63C7),
            borderRadius: BorderRadius.circular(28),
            boxShadow: const [
              BoxShadow(
                blurRadius: 8,
                offset: Offset(0, 3),
                color: Color(0x33000000),
              ),
            ],
          ),
          child: Row(
            children: [
              _audioBarButton(
                Icons.skip_previous_rounded,
                'الآية السابقة',
                () => _moveAudioAyah(-1),
              ),
              _audioBarButton(
                Icons.stop_rounded,
                'إيقاف',
                () async {
                  _isFullSurahPlayback = false;
                  _selectedAyah = null;
                  _selectedRead = null;
                  await _audioPlayer.stop();
                  _clearAyahHighlight();
                  if (mounted) setState(() {});
                },
              ),
              Expanded(
                child: IconButton(
                  onPressed: () async {
                    if (isPlaying) {
                      await _audioPlayer.pause();
                    } else {
                      await _audioPlayer.play();
                    }
                  },
                  iconSize: 42,
                  color: Colors.white,
                  tooltip: isPlaying ? 'إيقاف مؤقت' : 'تشغيل',
                  icon: Icon(
                    isPlaying
                        ? Icons.pause_circle_filled_rounded
                        : Icons.play_circle_fill_rounded,
                  ),
                ),
              ),
              _audioBarButton(
                Icons.skip_next_rounded,
                'الآية التالية',
                () => _moveAudioAyah(1),
              ),
              IconButton(
                onPressed: () => _showAudioControls(
                  _selectedAyah ?? '${widget.surahNumber}:1',
                  read,
                ),
                iconSize: 32,
                color: Colors.white,
                tooltip: 'إعدادات الصوت',
                icon: const Icon(Icons.settings_rounded),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _audioBarButton(
    IconData icon,
    String tooltip,
    VoidCallback onPressed,
  ) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      iconSize: 34,
      color: Colors.white,
      tooltip: tooltip,
    );
  }

  Future<void> _moveAudioAyah(int delta) async {
    if (_selectedRead == null || _ayahTimings.isEmpty) return;

    int currentAyah;
    if (_lastHighlightedAyah != null) {
      final parts = _lastHighlightedAyah!.split(':');
      currentAyah = int.tryParse(parts.length == 2 ? parts[1] : '') ?? 1;
    } else if (_selectedAyah != null) {
      final parts = _selectedAyah!.split(':');
      currentAyah = int.tryParse(parts.length == 2 ? parts[1] : '') ?? 1;
    } else {
      currentAyah = _ayahTimings.first.ayah;
    }

    final index = _ayahTimings.indexWhere((e) => e.ayah == currentAyah);
    if (index < 0) return;

    final nextIndex = index + delta;
    if (nextIndex < 0 || nextIndex >= _ayahTimings.length) return;

    final timing = _ayahTimings[nextIndex];

    if (_isFullSurahPlayback) {
      await _audioPlayer.seek(Duration(milliseconds: timing.startTime));
      _highlightTiming(timing);
      if (timing.page != null && timing.page != currentPage) {
        _lastHighlightedPage = timing.page;
        await _changePage(timing.page!);
      }
      if (!_audioPlayer.playing) {
        await _audioPlayer.play();
      }
      return;
    }

    await _prepareAndPlayAyah(
      '${widget.surahNumber}:${timing.ayah}',
      _selectedRead!,
      repeatCount: _repeatCount,
      speed: _speed,
    );
  }

  int _juz(int page) {
    const starts = [
      1, 22, 42, 62, 82, 102, 122, 142, 162, 182,
      202, 222, 242, 262, 282, 302, 322, 342, 362,
      382, 402, 422, 442, 462, 482, 502, 522, 542,
      562, 582,
    ];

    for (int i = starts.length - 1; i >= 0; i--) {
      if (page >= starts[i]) {
        return i + 1;
      }
    }

    return 1;
  }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _saveReaderPreferences();
    }
  }

  Future<void> _closeReader() async {
    await _saveReaderPreferences();
    if (mounted) Navigator.of(context).pop();
  }

  @override
  void dispose() {
    // نحفظ آخر صفحة/آية حتى لو خرج المستخدم قبل وصول PageChannel.
    WidgetsBinding.instance.removeObserver(this);
    _saveReaderPreferences();
    _positionSubscription?.cancel();
    _processingSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
    void _showAyahMenu(String ayah) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.copy),
                title: const Text('نسخ الآية'),
                onTap: () {
                  Navigator.pop(context);
                  _copyAyah(ayah);
                },
              ),
              ListTile(
                leading: const Icon(Icons.share),
                title: const Text('مشاركة الآية'),
                onTap: () {
                  Navigator.pop(context);
                  _shareAyah(ayah);
                },
              ),
              ListTile(
                leading: const Icon(Icons.volume_up),
                title: const Text('استماع'),
                onTap: () {
                  Navigator.pop(context);
                  _showReciters(ayah);
                },
              ),
              ListTile(
                leading: const Icon(Icons.menu_book),
                title: const Text('التفسير'),
                onTap: () {
                  Navigator.pop(context);
                  _showTafsir(ayah);
                },
              ),
              ListTile(
                leading: const Icon(Icons.bookmark_border),
                title: const Text('حفظ الآية'),
                onTap: () {
                  Navigator.pop(context);
                  _saveAyah(ayah);
                },
              ),
              ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('معلومات الآية'),
                onTap: () {
                  Navigator.pop(context);
                  _showInfo(ayah);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _copyAyah(String ayah) async {
    final text = await _getAyahText(ayah);

    if (!mounted) return;

    await Clipboard.setData(
      ClipboardData(text: text),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم نسخ الآية'),
      ),
    );
  }

  Future<void> _shareAyah(String ayah) async {
    final text = await _getAyahText(ayah);

    await Share.share(
      text,
      subject: 'آية من القرآن الكريم',
    );
  }

  Future<String> _getAyahText(String ayah) async {
    final response = await http.get(
      Uri.parse(
        'https://api.alquran.cloud/v1/ayah/$ayah/quran-uthmani',
      ),
    );

    if (response.statusCode != 200) {
      return 'تعذر تحميل الآية';
    }

    final data = jsonDecode(response.body);

    return data['data']['text']?.toString() ??
        'تعذر تحميل الآية';
  }
  Future<void> _saveAyah(String ayah) async {
    final wasSaved = _savedAyahs.contains(ayah);
    setState(() {
      if (wasSaved) {
        _savedAyahs.remove(ayah);
      } else {
        _savedAyahs.add(ayah);
      }
    });
    await _saveReaderPreferences();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSaved ? 'تمت إزالة الآية $ayah من المحفوظات' : 'تم حفظ الآية $ayah في المحفوظات',
        ),
        action: SnackBarAction(
          label: 'المحفوظات',
          onPressed: _showSavedAyahs,
        ),
      ),
    );
  }

  Future<void> _showSavedAyahs() async {
    final saved = _savedAyahs.toList()..sort();
    if (!mounted) return;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: _isNightMode ? const Color(0xFF1A2421) : const Color(0xFFFFFCF5),
      builder: (sheetContext) {
        if (saved.isEmpty) {
          return const SafeArea(
            child: SizedBox(
              height: 220,
              child: Center(child: Text('لا توجد آيات محفوظة بعد')),
            ),
          );
        }
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * .62,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(18, 4, 18, 10),
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Text('الآيات المحفوظة', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    itemCount: saved.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final ayah = saved[index];
                      final parts = ayah.split(':');
                      final surah = int.tryParse(parts.isNotEmpty ? parts[0] : '') ?? 1;
                      final number = int.tryParse(parts.length > 1 ? parts[1] : '') ?? 1;
                      return ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.bookmark_rounded)),
                        title: Text('سورة ${surah >= 1 && surah <= surahNames.length ? surahNames[surah - 1] : ''} — الآية $number', textDirection: TextDirection.rtl),
                        subtitle: Text(ayah, textDirection: TextDirection.rtl),
                        trailing: IconButton(
                          tooltip: 'حذف',
                          icon: const Icon(Icons.delete_outline_rounded),
                          onPressed: () async {
                            setState(() => _savedAyahs.remove(ayah));
                            await _saveReaderPreferences();
                            if (sheetContext.mounted) Navigator.pop(sheetContext);
                            if (mounted) _showSavedAyahs();
                          },
                        ),
                        onTap: () async {
                          Navigator.pop(sheetContext);
                          if (surah >= 1 && surah <= surahNames.length) {
                            _openSurah(surah);
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
  Future<void> _showReciters(String ayah) async {
    if (!mounted) return;

    String query = '';
    bool onlyFavorites = false;
    bool sheetLoading = timingReads.isEmpty;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor:
          _isNightMode ? const Color(0xFF18211E) : const Color(0xFFFFFCF5),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            if (sheetLoading) {
              Future.microtask(() async {
                try {
                  await _loadReciters().timeout(
                    const Duration(seconds: 12),
                  );
                } catch (_) {
                  // _loadReciters already updates its loading state.
                }
                if (sheetContext.mounted) {
                  setSheetState(() {
                    sheetLoading = false;
                  });
                }
              });
            }

            final filtered = timingReads.where((read) {
              final q = query.trim().toLowerCase();
              final matchesQuery = q.isEmpty ||
                  read.name.toLowerCase().contains(q) ||
                  read.rewaya.toLowerCase().contains(q);
              final matchesFavorite =
                  !onlyFavorites || _favoriteReciterIds.contains(read.id);
              return matchesQuery && matchesFavorite;
            }).toList()
              ..sort((a, b) {
                final af = _favoriteReciterIds.contains(a.id) ? 0 : 1;
                final bf = _favoriteReciterIds.contains(b.id) ? 0 : 1;
                if (af != bf) return af.compareTo(bf);
                return a.name.compareTo(b.name);
              });

            if (sheetLoading || loadingReciters) {
              return const SafeArea(
                child: SizedBox(
                  height: 320,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 14),
                        Text(
                          'جاري تحميل قائمة القرّاء...',
                          textDirection: TextDirection.rtl,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            if (timingReads.isEmpty) {
              return const SafeArea(
                child: SizedBox(
                  height: 280,
                  child: Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
                      child: Text(
                        'تعذر تحميل قائمة القرّاء.\nتأكدي من اتصال الإنترنت ثم حاولي مرة أخرى.',
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),
              );
            }

            return SafeArea(
              child: SizedBox(
                height: MediaQuery.of(context).size.height * .84,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                  child: Column(
                    children: [
                      Row(
                        textDirection: TextDirection.rtl,
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: _isNightMode
                                  ? const Color(0xFF29483D)
                                  : const Color(0xFFE2EFE9),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: const Icon(
                              Icons.graphic_eq_rounded,
                              color: Color(0xFF173F35),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'القرّاء',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 21,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'اختر قارئك المفضل للاستماع والتكرار',
                                  textDirection: TextDirection.rtl,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'ابحث باسم القارئ أو الرواية',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: query.isEmpty
                              ? null
                              : IconButton(
                                  onPressed: () =>
                                      setSheetState(() => query = ''),
                                  icon: const Icon(Icons.clear_rounded),
                                ),
                          filled: true,
                          fillColor: _isNightMode
                              ? const Color(0xFF22302B)
                              : const Color(0xFFF3F0E8),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        onChanged: (value) =>
                            setSheetState(() => query = value),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          FilterChip(
                            avatar: const Icon(
                              Icons.star_rounded,
                              size: 17,
                            ),
                            label: const Text('المفضلون'),
                            selected: onlyFavorites,
                            onSelected: (value) =>
                                setSheetState(() => onlyFavorites = value),
                          ),
                          const Spacer(),
                          Text(
                            '${filtered.length} قارئ',
                            textDirection: TextDirection.rtl,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Expanded(
                        child: filtered.isEmpty
                            ? const Center(
                                child: Text(
                                  'لا يوجد قارئ مطابق للبحث',
                                  textDirection: TextDirection.rtl,
                                ),
                              )
                            : ListView.separated(
                                itemCount: filtered.length,
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 5),
                                itemBuilder: (context, index) {
                                  final read = filtered[index];
                                  final favorite =
                                      _favoriteReciterIds.contains(read.id);
                                  final selected = _lastReciterId == read.id;
                                  return Material(
                                    color: Colors.transparent,
                                    child: InkWell(
                                      borderRadius: BorderRadius.circular(17),
                                      onTap: () {
                                        _lastReciterId = read.id;
                                        _saveReaderPreferences();

                                        // Close the reader list first, then open
                                        // the audio controls as a fresh sheet.
                                        Navigator.pop(sheetContext);
                                        Future.microtask(() {
                                          if (mounted) {
                                            _showAudioControls(ayah, read);
                                          }
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 12,
                                          vertical: 10,
                                        ),
                                        decoration: BoxDecoration(
                                          color: selected
                                              ? (_isNightMode
                                                  ? const Color(0xFF29483D)
                                                  : const Color(0xFFE8F1EC))
                                              : (_isNightMode
                                                  ? const Color(0xFF1F2A27)
                                                  : Colors.white),
                                          borderRadius:
                                              BorderRadius.circular(17),
                                          border: Border.all(
                                            color: selected
                                                ? const Color(0xFF6C9B8B)
                                                : (_isNightMode
                                                    ? const Color(0xFF31413B)
                                                    : const Color(0xFFE9E4D9)),
                                          ),
                                        ),
                                        child: Row(
                                          textDirection: TextDirection.rtl,
                                          children: [
                                            Container(
                                              width: 42,
                                              height: 42,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: favorite
                                                    ? const Color(0xFFF2D58A)
                                                    : const Color(0xFFE5EEE9),
                                              ),
                                              child: Icon(
                                                favorite
                                                    ? Icons.star_rounded
                                                    : Icons.person_rounded,
                                                color: const Color(0xFF173F35),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.end,
                                                children: [
                                                  Text(
                                                    read.name,
                                                    textDirection:
                                                        TextDirection.rtl,
                                                    maxLines: 1,
                                                    overflow:
                                                        TextOverflow.ellipsis,
                                                    style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.w800,
                                                      fontSize: 15,
                                                    ),
                                                  ),
                                                  if (read.rewaya.isNotEmpty)
                                                    Text(
                                                      read.rewaya,
                                                      textDirection:
                                                          TextDirection.rtl,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: const TextStyle(
                                                        fontSize: 12,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
                                            IconButton(
                                              tooltip: favorite
                                                  ? 'إزالة من المفضلة'
                                                  : 'إضافة للمفضلة',
                                              onPressed: () async {
                                                setState(() {
                                                  if (favorite) {
                                                    _favoriteReciterIds
                                                        .remove(read.id);
                                                  } else {
                                                    _favoriteReciterIds
                                                        .add(read.id);
                                                  }
                                                });
                                                await _saveReaderPreferences();
                                                setSheetState(() {});
                                              },
                                              icon: Icon(
                                                favorite
                                                    ? Icons.star_rounded
                                                    : Icons.star_border_rounded,
                                              ),
                                              color: favorite
                                                  ? const Color(0xFFC79622)
                                                  : Colors.grey,
                                            ),
                                            const Icon(
                                              Icons.play_circle_fill_rounded,
                                              color: Color(0xFF173F35),
                                              size: 31,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showAudioControls(
    String ayah,
    TimingRead read,
  ) {
    double speed = _speed;
    int repeat = _repeatCount;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  10,
                  20,
                  24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment:
                      CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'الآية $ayah',
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      read.name,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                    ),
                    if (read.rewaya.isNotEmpty)
                      Text(
                        read.rewaya,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center,
                      children: [
                        IconButton(
                          iconSize: 42,
                          tooltip: 'تشغيل',
                          onPressed: () {
                            Navigator.pop(sheetContext);
                            _prepareAndPlayAyah(
                              ayah,
                              read,
                              repeatCount: repeat,
                              speed: speed,
                            );
                          },
                          icon: const Icon(
                            Icons.play_circle_fill,
                          ),
                        ),
                        IconButton(
                          iconSize: 38,
                          tooltip: 'إيقاف مؤقت',
                          onPressed: () =>
                              _audioPlayer.pause(),
                          icon: const Icon(
                            Icons.pause_circle,
                          ),
                        ),
                        IconButton(
                          iconSize: 38,
                          tooltip: 'إيقاف',
                          onPressed: () async {
                            _isFullSurahPlayback = false;
                            _selectedAyah = null;
                            _selectedRead = null;
                            await _audioPlayer.stop();
                            _clearAyahHighlight();
                            if (mounted) setState(() {});
                          },
                          icon: const Icon(
                            Icons.stop_circle,
                          ),
                        ),
                        IconButton(
                          iconSize: 34,
                          tooltip: 'تنزيل',
                          onPressed: () async {
                            try {
                              await _downloadSurahForRead(
                                read,
                              );

                              if (!mounted) return;

                              _showMessage(
                                'تم تنزيل الصوت ويمكن تشغيل الآية بدون إنترنت',
                              );

                              setSheetState(() {});
                            } catch (_) {
                              if (mounted) {
                                _showMessage(
                                  'تعذر تنزيل الصوت',
                                );
                              }
                            }
                          },
                          icon: const Icon(
                            Icons.download,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () async {
                        Navigator.pop(sheetContext);
                        await _playFullSurah(read);
                      },
                      icon: const Icon(Icons.library_music),
                      label: const Text('تشغيل السورة كاملة مع التضليل'),
                    ),
                    const SizedBox(height: 12),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'عدد مرات تكرار الآية',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final value in [
                          1,
                          2,
                          3,
                          5,
                          10,
                          0,
                        ])
                          ChoiceChip(
                            label: Text(
                              value == 0
                                  ? '∞'
                                  : '$value',
                            ),
                            selected: repeat == value,
                            onSelected: (_) {
                              setSheetState(() {
                                repeat = value;
                              });
                              _repeatCount = value;
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'سرعة التلاوة',
                        textDirection: TextDirection.rtl,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      alignment: WrapAlignment.center,
                      children: [
                        for (final value in [
                          0.5,
                          0.75,
                          1.0,
                          1.25,
                          1.5,
                          2.0,
                        ])
                          ChoiceChip(
                            label: Text(
                              '${value}x',
                            ),
                            selected:
                                speed == value,
                            onSelected: (_) {
                              setSheetState(() {
                                speed = value;
                              });
                              _speed = value;
                              _audioPlayer.setSpeed(
                                value,
                              );
                            },
                          ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    FutureBuilder<bool>(
                      future:
                          _hasOfflineSurah(read),
                      builder:
                          (context, snapshot) {
                        if (snapshot.data ==
                            true) {
                          return const Text(
                            '✓ الصوت متوفر على الجهاز — يعمل بدون إنترنت',
                            textDirection:
                                TextDirection.rtl,
                            textAlign:
                                TextAlign.center,
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.w600,
                            ),
                          );
                        }

                        return const Text(
                          'يمكن تنزيل الصوت من زر ⬇️',
                          textDirection:
                              TextDirection.rtl,
                          textAlign:
                              TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
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
      },
    );
  }

    Future<void> _showTafsir(String ayah) async {
    final parts = ayah.split(':');

    if (parts.length != 2) {
      return;
    }

    final surah = parts[0];
    final verse = parts[1];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    try {
      final response = await http.get(
        Uri.parse(
          'https://quranenc.com/api/v1/translation/aya/'
          'arabic_moyassar/$surah/$verse',
        ),
      );

      if (!mounted) return;

      Navigator.pop(context);

      if (response.statusCode != 200) {
        _showMessage('تعذر تحميل التفسير');
        return;
      }

      final data = jsonDecode(response.body);

      final tafsir =
          data['result']?['translation']?.toString() ??
              'لا يوجد تفسير متاح';

      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('تفسير الآية'),
            content: SingleChildScrollView(
              child: Text(
                tafsir,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 17,
                  height: 1.8,
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('إغلاق'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      if (!mounted) return;

      Navigator.pop(context);

      _showMessage('حدث خطأ أثناء تحميل التفسير');
    }
  }

  void _showInfo(String ayah) {
    final parts = ayah.split(':');

    String surahNumber = '-';
    String ayahNumber = ayah;

    if (parts.length == 2) {
      surahNumber = parts[0];
      ayahNumber = parts[1];
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('معلومات الآية'),
          content: Directionality(
            textDirection: TextDirection.rtl,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _infoRow(
                  'السورة',
                  widget.surahName,
                ),
                _infoRow(
                  'رقم السورة',
                  surahNumber,
                ),
                _infoRow(
                  'رقم الآية',
                  ayahNumber,
                ),
                _infoRow(
                  'صفحة المصحف',
                  currentPage.toString(),
                ),
                _infoRow(
                  'الجزء',
                  _juz(currentPage).toString(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _infoRow(
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Text(
            '$title: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
  Future<void> _loadReaderPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedPage = prefs.getInt('noor_last_read_page_${widget.surahNumber}');
      final savedAyah = prefs.getString('noor_last_read_ayah_${widget.surahNumber}');
      final globalSurah = prefs.getInt('noor_last_read_surah');
      final globalAyah = prefs.getString('noor_last_read_ayah_global');
      final bookmark = prefs.getInt('noor_bookmark_page');
      final night = prefs.getBool('noor_night_mode') ?? false;
      final mushafScale = prefs.getDouble('noor_mushaf_text_scale') ?? 1.0;
      final saved = prefs.getStringList('noor_saved_ayahs') ?? <String>[];
      final favoriteReciters = prefs.getStringList('noor_favorite_reciters') ?? <String>[];
      final lastReciter = prefs.getInt('noor_last_reciter_id');
      final useInitial = widget.initialPage != null;
      final pageToOpen = useInitial ? widget.initialPage! : ((savedPage != null && savedPage >= 1 && savedPage <= 604) ? savedPage : currentPage);
      String? ayahToHighlight = useInitial ? widget.initialAyah : savedAyah;
      if (!useInitial && ayahToHighlight == null && globalSurah == widget.surahNumber) ayahToHighlight = globalAyah;
      if (!mounted) return;
      setState(() {
        _lastReadPage = pageToOpen;
        _lastReadAyah = ayahToHighlight;
        _lastHighlightedAyah = ayahToHighlight;
        _bookmarkPage = bookmark ?? currentPage;
        _isNightMode = night;
        _mushafTextScale = mushafScale.clamp(0.85, 1.40).toDouble();
        _savedAyahs..clear()..addAll(saved);
        _favoriteReciterIds..clear()..addAll(favoriteReciters.map((e) => int.tryParse(e)).whereType<int>());
        _lastReciterId = lastReciter;
        _prefsLoaded = true;
      });
      if (pageToOpen != currentPage) {
        await _changePage(pageToOpen, forceReload: true);
      } else {
        await _loadMushafPage(pageToOpen);
      }
    } catch (_) {
      _prefsLoaded = true;
    }
  }

  int _surahForPage(int page) {
    var index = 0;
    for (var i = 0; i < surahStartPages.length; i++) {
      if (surahStartPages[i] <= page) index = i; else break;
    }
    return index + 1;
  }

  Future<void> _rememberLastReadAyah(String ayahKey) async {
    final parts = ayahKey.split(':');
    if (parts.length != 2) return;
    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    if (surah == null || ayah == null || surah < 1 || surah > 114) return;
    _lastReadAyah = '$surah:$ayah';
    _lastHighlightedAyah = _lastReadAyah;
    _lastHighlightedPage = currentPage;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('noor_last_read_ayah_$surah', _lastReadAyah!);
      await prefs.setInt('noor_last_read_page_$surah', currentPage);
      await prefs.setInt('noor_last_read_updated_at_$surah', DateTime.now().millisecondsSinceEpoch);
      await prefs.setInt('noor_last_read_surah', surah);
      await prefs.setInt('noor_last_read_page_global', currentPage);
      await prefs.setString('noor_last_read_ayah_global', _lastReadAyah!);
      await prefs.setInt('noor_reading_position_version', 2);
    } catch (_) {}
  }

  Future<void> _saveReaderPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final actualSurah = _surahForPage(currentPage);
      await prefs.setInt('noor_last_read_surah', actualSurah);
      await prefs.setInt('noor_last_read_page_global', currentPage);
      await prefs.setInt('noor_reading_position_version', 2);
      await prefs.setInt('noor_last_read_page_$actualSurah', currentPage);
      await prefs.setInt('noor_last_read_updated_at_$actualSurah', DateTime.now().millisecondsSinceEpoch);
      if (_lastReadAyah != null && _lastReadAyah!.isNotEmpty) {
        final parts = _lastReadAyah!.split(':');
        if (parts.length == 2 && int.tryParse(parts[0]) == actualSurah) {
          await prefs.setString('noor_last_read_ayah_global', _lastReadAyah!);
          await prefs.setString('noor_last_read_ayah_$actualSurah', _lastReadAyah!);
        }
      }
      if (_bookmarkPage == null) await prefs.remove('noor_bookmark_page');
      else await prefs.setInt('noor_bookmark_page', _bookmarkPage!);
      await prefs.setBool('noor_night_mode', _isNightMode);
      await prefs.setDouble('noor_mushaf_text_scale', _mushafTextScale);
      await prefs.setStringList('noor_saved_ayahs', _savedAyahs.toList()..sort());
      await prefs.setStringList('noor_favorite_reciters', _favoriteReciterIds.map((e) => e.toString()).toList()..sort());
      if (_lastReciterId == null) await prefs.remove('noor_last_reciter_id');
      else await prefs.setInt('noor_last_reciter_id', _lastReciterId!);
    } catch (_) {}
  }

Future<void> _loadMushafPage(int page) async {
    final p = page.toString().padLeft(3, '0');
    final url = Uri.parse(
      'https://cdn.quran.ws/svg/pages/v1.1.1/hafs-kfqc/$p.svg',
    );

    try {
      final response = await http.get(url).timeout(
        const Duration(seconds: 20),
      );
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      var svg = response.body
          .replaceFirst(RegExp(r'<\?xml[^>]*>'), '')
          .replaceFirst(RegExp(r'<!DOCTYPE[^>]*>', caseSensitive: false), '');

      final html = '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta name="viewport" content="width=device-width, initial-scale=1.0, viewport-fit=cover">
<style>
html,body{margin:0;padding:0;width:100%;height:100%;background:${_isNightMode ? '#151B19' : '#f7f1df'};font-family:Arial,sans-serif;overflow:hidden;touch-action:none}
#page{width:100%;height:auto;min-height:100%;display:block;transition:opacity .15s ease;touch-action:none;user-select:none;-webkit-user-select:none;transform-origin:center top;will-change:transform}
svg{
width:100%;
height:auto;
display:block;
margin:0 auto;
max-width:none
}
.ayahPolygon{cursor:pointer;transition:fill .15s ease,fill-opacity .15s ease}
.noor-active{fill:#7652d6!important;fill-opacity:.38!important}
#readerSheet{position:fixed;inset:0;background:rgba(0,0,0,.38);display:none;align-items:flex-end;z-index:20}
#readerPanel{position:relative;background:${_isNightMode ? '#202522' : '#fff'};color:${_isNightMode ? '#f4f4f4' : '#222'};width:100%;max-height:78%;border-radius:22px 22px 0 0;padding:18px 16px 22px;box-sizing:border-box;box-shadow:0 -10px 30px rgba(0,0,0,.18)}
#readerTitle{font-size:18px;font-weight:700;text-align:center;margin-bottom:8px}
#readerAyah{font-size:13px;opacity:.7;text-align:center;margin-bottom:12px}
#readerSearch{width:100%;box-sizing:border-box;border:1px solid #ddd;border-radius:12px;padding:11px 13px;font-size:15px;background:transparent;color:inherit;outline:none;margin-bottom:10px}
#readerList{max-height:38vh;overflow:auto}
.readerRow{display:flex;align-items:center;gap:10px;padding:11px 8px;border-bottom:1px solid rgba(127,127,127,.16);cursor:pointer}
.readerRow:hover{background:rgba(118,82,214,.08)}
.readerAvatar{width:38px;height:38px;border-radius:50%;display:grid;place-items:center;background:rgba(118,82,214,.12);font-weight:700;color:#7652d6;flex:0 0 auto}
.readerName{font-weight:700;font-size:14px;flex:1}.readerRewaya{font-size:11px;opacity:.62;margin-top:2px}
#choiceSheet{position:fixed;inset:0;background:rgba(0,0,0,.38);display:none;align-items:flex-end;z-index:30}
#choicePanel{background:${_isNightMode ? '#202522' : '#fff'};color:${_isNightMode ? '#f4f4f4' : '#222'};width:100%;border-radius:22px 22px 0 0;padding:20px;box-sizing:border-box}
.choiceBtn{width:100%;border:0;border-radius:14px;padding:14px;margin-top:9px;font-size:15px;font-weight:700;cursor:pointer;background:rgba(118,82,214,.12);color:inherit}
.choiceBtn.primary{background:#7652d6;color:white}
#player{position:fixed;left:10px;right:10px;bottom:10px;display:none;z-index:15;background:${_isNightMode ? '#202522' : '#fff'};color:${_isNightMode ? '#fff' : '#222'};border-radius:18px;padding:10px 12px;box-shadow:0 8px 28px rgba(0,0,0,.2);direction:rtl}
#playerTop{display:flex;align-items:center;gap:10px}.playerInfo{flex:1}.playerName{font-weight:700;font-size:13px}.playerStatus{font-size:11px;opacity:.65;margin-top:2px}
.playerBtn{border:0;background:rgba(118,82,214,.12);border-radius:12px;width:42px;height:42px;cursor:pointer;font-size:18px}
#progress{width:100%;margin-top:8px;accent-color:#7652d6}
#closeReader{position:absolute;left:12px;top:10px;border:0;background:transparent;color:inherit;font-size:24px;cursor:pointer}
</style></head>
<body>
<div id="page">$svg</div>
<div id="readerSheet"><div id="readerPanel"><button id="closeReader">×</button><div id="readerTitle">اختر القارئ</div><div id="readerAyah"></div><input id="readerSearch" placeholder="ابحث عن اسم القارئ..."/><div id="readerList"></div></div></div>
<div id="choiceSheet"><div id="choicePanel"><div id="readerTitle">ماذا تريد أن تسمع؟</div><div id="readerAyah"></div><button class="choiceBtn primary" id="playAyah">▶ الاستماع إلى الآية</button><button class="choiceBtn" id="playSurah">▶ الاستماع إلى السورة كاملة</button><button class="choiceBtn" id="cancelChoice">إلغاء</button></div></div>
<div id="player"><div id="playerTop"><div class="playerInfo"><div class="playerName" id="playerName">نور القرآن</div><div class="playerStatus" id="playerStatus">جاهز</div></div><button class="playerBtn" id="stopBtn">■</button><button class="playerBtn" id="pauseBtn">Ⅱ</button></div><input id="progress" type="range" min="0" max="100" value="0" step="0.1"/></div>
<audio id="audio" preload="auto"></audio>
<script>
(function(){
 const SURAH=%SURAH%;
 const INITIAL_PAGE=%PAGE%;
 const pageEl=document.getElementById('page'), audio=document.getElementById('audio');
 const readerSheet=document.getElementById('readerSheet'), choiceSheet=document.getElementById('choiceSheet');
 const readerList=document.getElementById('readerList'), readerSearch=document.getElementById('readerSearch');
 const readerAyah=document.querySelector('#readerPanel #readerAyah'), choiceAyah=document.querySelector('#choicePanel #readerAyah');
 const player=document.getElementById('player'), playerName=document.getElementById('playerName'), playerStatus=document.getElementById('playerStatus'), progress=document.getElementById('progress');
 let readers=[], timings=[], selectedAyah=null, selectedReader=null, playMode='ayah', currentTiming=null, loadingPage=false;
 const api='https://mp3quran.net/api/v3';
 const qsvg='https://cdn.quran.ws/svg/pages/v1.1.1/hafs-kfqc/';
 function esc(v){return String(v||'').replace(/[&<>"]/g,s=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;'}[s]));}
 function setSheet(el,on){el.style.display=on?'flex':'none';}
 async function loadReaders(){
   if(readers.length) return readers;
   try{const r=await fetch(api+'/ayat_timing/reads'); if(!r.ok) throw 0; readers=await r.json(); readers=readers.filter(x=>x&&x.id&&x.folder_url); renderReaders(); return readers;}
   catch(e){readerList.innerHTML='<div style="padding:20px;text-align:center;opacity:.7">تعذر تحميل قائمة القراء. تحقق من الإنترنت.</div>'; return [];}
 }
 function renderReaders(){
   const q=(readerSearch.value||'').trim();
   const list=readers.filter(r=>!q || (r.name||'').includes(q) || (r.rewaya||'').includes(q)).slice(0,80);
   readerList.innerHTML=list.map(r=>`<div class="readerRow" data-id="\${r.id}"><div class="readerAvatar">\${esc((r.name||'ق').trim().charAt(0))}</div><div class="readerName">\${esc(r.name)}<div class="readerRewaya">\${esc(r.rewaya||'رواية غير محددة')}</div></div><div>›</div></div>`).join('') || '<div style="padding:20px;text-align:center;opacity:.7">لا توجد نتائج</div>';
   readerList.querySelectorAll('.readerRow').forEach(row=>row.onclick=()=>{selectedReader=readers.find(r=>String(r.id)===row.dataset.id);setSheet(readerSheet,false);setSheet(choiceSheet,true);choiceAyah.textContent='الآية '+selectedAyah;});
 }
 async function openAyah(ayah){
   selectedAyah=ayah;
   readerAyah.textContent='الآية '+ayah;
   setSheet(readerSheet,true); readerSearch.value='';
   await loadReaders(); renderReaders();
 }
 function clearHighlight(){
   document.querySelectorAll('.ayahPolygon').forEach(e=>e.classList.remove('noor-active'));
 }
 function highlight(surah,ayah){
   window.noorPendingHighlight=String(surah)+':'+String(ayah);
   clearHighlight();
   document.querySelectorAll('.ayahPolygon').forEach(e=>{
     if(e.getAttribute('surah')==String(surah)&&e.getAttribute('ayah')==String(ayah)) e.classList.add('noor-active');
   });
 }
 window.setNoorAyahHighlight=function(surah,ayah){
   highlight(surah,ayah);
 };
 window.clearNoorAyahHighlight=function(){
   window.noorPendingHighlight=null;
   clearHighlight();
 };
 async function loadTimings(read){
   const r=await fetch(api+'/ayat_timing?surah='+SURAH+'&read='+read.id); if(!r.ok) throw 0;
   timings=(await r.json()).filter(x=>x.ayah>=1&&x.end_time>x.start_time);
   return timings;
 }
 function audioUrl(read){return read.folder_url+String(SURAH).padStart(3,'0')+'.mp3';}
 function pageFromTiming(t){const m=String(t.page||'').match(/(\d{3})\.svg/); return m?parseInt(m[1],10):null;}
 async function loadPage(p){
   if(loadingPage) return; loadingPage=true;
   try{const u=qsvg+String(p).padStart(3,'0')+'.svg'; const r=await fetch(u); if(!r.ok) throw 0; const txt=await r.text(); pageEl.style.opacity='.2'; pageEl.innerHTML=txt.replace(/<\?xml[^>]*>/,'').replace(/<!DOCTYPE[^>]*>/i,''); pageEl.style.opacity='1'; bindPolygons();}
   finally{loadingPage=false;}
 }
 function bindPolygons(){
  document.querySelectorAll('.ayahPolygon').forEach(el=>{
   el.style.cursor='default';
   var pressTimer=null;
   var longPressed=false;
   var startX=0;
   var startY=0;

   var sendAyah=function(){
    const s=el.getAttribute('surah'),a=el.getAttribute('ayah');
    if(!s||!a)return;
    longPressed=true;
    if(window.AyahChannel){AyahChannel.postMessage(s+':'+a);}
    else{openAyah(s+':'+a);}
   };

   var cancelPress=function(){
    if(pressTimer!==null){
      clearTimeout(pressTimer);
      pressTimer=null;
    }
   };

   el.onclick=function(e){
    // A normal tap only selects the page; it does not open the reciter list.
    if(longPressed){
      e.preventDefault();
      e.stopPropagation();
      longPressed=false;
    }
   };

   el.addEventListener('touchstart',function(e){
    if(!e.touches||!e.touches.length)return;
    startX=e.touches[0].clientX;
    startY=e.touches[0].clientY;
    longPressed=false;
    cancelPress();
    pressTimer=setTimeout(function(){
      pressTimer=null;
      sendAyah();
    },650);
   },{passive:true});

   el.addEventListener('touchmove',function(e){
    if(!e.touches||!e.touches.length)return;
    var dx=e.touches[0].clientX-startX;
    var dy=e.touches[0].clientY-startY;
    if(Math.abs(dx)>12||Math.abs(dy)>12) cancelPress();
   },{passive:true});

   el.addEventListener('touchend',function(e){
    cancelPress();
    if(longPressed){
      e.preventDefault();
      e.stopPropagation();
      setTimeout(function(){longPressed=false;},0);
    }
   },{passive:false});

   el.addEventListener('touchcancel',cancelPress,{passive:true});
  });
  if(currentTiming)highlight(SURAH,currentTiming.ayah);
 }
 async function play(mode){
   if(!selectedReader||!selectedAyah) return;
   try{
     if(!timings.length) await loadTimings(selectedReader);
     if(!timings.length) throw 0;
     playMode=mode; const verse=parseInt(selectedAyah.split(':')[1],10); currentTiming=timings.find(x=>x.ayah===verse)||timings[0];
     audio.src=audioUrl(selectedReader); audio.playbackRate=1; await audio.play();
     if(mode==='ayah') audio.currentTime=currentTiming.start_time/1000;
     playerName.textContent=selectedReader.name+' • '+(selectedReader.rewaya||''); playerStatus.textContent=mode==='ayah'?'تشغيل الآية':'تشغيل السورة كاملة'; player.style.display='block'; setSheet(choiceSheet,false); highlight(SURAH,currentTiming.ayah);
   }catch(e){playerStatus.textContent='تعذر تشغيل الصوت؛ تحقق من الإنترنت';player.style.display='block';}
 }
 audio.ontimeupdate=async()=>{
   if(!currentTiming||!timings.length) return;
   const ms=audio.currentTime*1000;
   if(playMode==='ayah' && ms>=currentTiming.end_time){audio.pause();playerStatus.textContent='انتهت الآية';return;}
   if(playMode==='surah'){
     const t=timings.find(x=>ms>=x.start_time&&ms<x.end_time);
     if(t&&t.ayah!==currentTiming.ayah){currentTiming=t;highlight(SURAH,t.ayah);const pg=pageFromTiming(t);if(pg) await loadPage(pg);}
   }
   if(audio.duration) progress.value=(audio.currentTime/audio.duration)*100;
 };
 audio.onended=()=>{clearHighlight();playerStatus.textContent=playMode==='ayah'?'انتهت الآية':'انتهت السورة';};
 document.getElementById('playAyah').onclick=()=>play('ayah');
 document.getElementById('playSurah').onclick=()=>play('surah');
 document.getElementById('cancelChoice').onclick=()=>setSheet(choiceSheet,false);
 document.getElementById('closeReader').onclick=()=>setSheet(readerSheet,false);
 document.getElementById('pauseBtn').onclick=()=>{if(audio.paused){audio.play();}else{audio.pause();}};
 document.getElementById('stopBtn').onclick=()=>{audio.pause();audio.currentTime=0;clearHighlight();player.style.display='none';};
 progress.oninput=()=>{if(audio.duration) audio.currentTime=(Number(progress.value)/100)*audio.duration;};
 readerSearch.oninput=renderReaders;
 var swipeStartX=null,swipeStartY=null,swiped=false;
 var pinchStartDistance=null,pinchStartZoom=1,zoom=1,textScale=1;
 var panX=0,panY=0,panStartX=0,panStartY=0,panStartPanX=0,panStartPanY=0;
 function applyZoom(){pageEl.style.transform='translate3d('+panX+'px,'+panY+'px,0) scale('+(zoom*textScale)+')';}
 window.setNoorOrientation=function(landscape){
   panX=0; panY=0; zoom=1;
   document.documentElement.style.overflowY=landscape?'auto':'hidden';
   document.body.style.overflowY=landscape?'auto':'hidden';
   document.documentElement.style.touchAction=landscape?'pan-y':'none';
   document.body.style.touchAction=landscape?'pan-y':'none';
   pageEl.style.width='100%';
   pageEl.style.height='auto';
   pageEl.style.minHeight=landscape?'0':'100%';
   pageEl.style.touchAction=landscape?'pan-y':'none';
   pageEl.style.transformOrigin='center top';
   var svg=pageEl.querySelector('svg');
   if(svg){
     svg.style.width='100%';
     svg.style.height='auto';
     svg.style.display='block';
     svg.style.maxWidth='none';
   }
   applyZoom();
   window.scrollTo(0,0);
 };
 function dist(a,b){var dx=a.clientX-b.clientX,dy=a.clientY-b.clientY;return Math.sqrt(dx*dx+dy*dy);}
 document.addEventListener('touchstart',function(e){
  if(!e.touches||!e.touches.length)return;swiped=false;
  if(e.touches.length>=2){pinchStartDistance=dist(e.touches[0],e.touches[1]);pinchStartZoom=zoom;swipeStartX=null;return;}
  swipeStartX=e.touches[0].clientX;swipeStartY=e.touches[0].clientY;panStartX=swipeStartX;panStartY=swipeStartY;panStartPanX=panX;panStartPanY=panY;
 },{passive:true});
 document.addEventListener('touchmove',function(e){
  if(!e.touches||!e.touches.length)return;
  if(e.touches.length>=2){
   var d=dist(e.touches[0],e.touches[1]);
   if(pinchStartDistance===null){pinchStartDistance=d;pinchStartZoom=zoom;}
   zoom=Math.max(1,Math.min(3,pinchStartZoom*(d/pinchStartDistance)));swiped=zoom>1;applyZoom();return;
  }
  if(swipeStartX===null)return;
  var dx=e.touches[0].clientX-swipeStartX,dy=e.touches[0].clientY-swipeStartY;
  if(zoom>1.01){panX=panStartPanX+(e.touches[0].clientX-panStartX);panY=panStartPanY+(e.touches[0].clientY-panStartY);applyZoom();swiped=true;return;}
  if(Math.abs(dx)>35&&Math.abs(dx)>Math.abs(dy)*1.15)swiped=true;
 },{passive:true});
 document.addEventListener('touchend',function(e){
  if(e.touches&&e.touches.length>=2)return;
  if(pinchStartDistance!==null){pinchStartDistance=null;if(zoom<1.05){zoom=1;panX=0;panY=0;applyZoom();}swipeStartX=null;return;}
  if(swipeStartX===null)return;
  var dx=e.changedTouches[0].clientX-swipeStartX,dy=e.changedTouches[0].clientY-swipeStartY;swipeStartX=null;swipeStartY=null;
  if(zoom<=1.01&&Math.abs(dx)>105&&Math.abs(dx)>Math.abs(dy)*1.15){swiped=true;if(window.NavigationChannel)NavigationChannel.postMessage(dx>0?'next':'prev');setTimeout(function(){swiped=false;},100);}
 },{passive:true});
 document.addEventListener('dblclick',function(){zoom=1;panX=0;panY=0;applyZoom();});
 document.addEventListener('click',function(e){if(swiped){e.preventDefault();e.stopPropagation();swiped=false;}},true);
 bindPolygons();
})();
</script></body></html>
''';

      final webHtml = html
          .replaceFirst('%SURAH%', '${widget.surahNumber}')
          .replaceFirst('%PAGE%', '$page')
          .replaceFirst(
            '%IS_LANDSCAPE%',
            (mounted &&
                    MediaQuery.of(context).orientation == Orientation.landscape)
                ? 'true'
                : 'false',
          );

      await controller.loadHtmlString(webHtml);
      _loadedPage = page;
      _lastLandscape = null;
      if (mounted) {
        _syncMushafOrientation(
          MediaQuery.of(context).orientation == Orientation.landscape,
        );
      }
    } catch (e) {
      if (mounted) {
        _showMessage('تعذر تحميل صفحة المصحف. تحقق من الإنترنت.');
      }
    }
  }


  Future<void> _installMushafInteractions() async {
    try {
      await controller.runJavaScript('''
        (function() {
          document.documentElement.style.background = '#f7f1df';
          document.body.style.margin = '0';
          document.body.style.padding = '0';
          document.body.style.background = '#f7f1df';
          var svg = document.querySelector('svg');
          if (svg) {
            svg.style.height = 'auto';
            svg.style.display = 'block';
            svg.style.maxWidth = 'none';
          }

          // تطبيق حجم خط المصحف فعلياً بعد كل تحميل للصفحة.
          window.setNoorTextScale = function(scale) {
            var s = Number(scale);
            if (!isFinite(s)) s = 1;
            s = Math.max(0.85, Math.min(1.40, s));
            textScale = s;
            panX = 0;
            panY = 0;
            applyZoom();
          };

          window.setNoorAyahHighlight = function(surah, ayah) {
            window.noorPendingHighlight = String(surah) + ':' + String(ayah);
            document.querySelectorAll('.ayahPolygon').forEach(function(el) {
              var match = el.getAttribute('surah') === String(surah) &&
                          el.getAttribute('ayah') === String(ayah);
              if (match) {
                el.classList.add('noor-active');
                el.style.setProperty('fill', '#7652d6', 'important');
                el.style.setProperty('fill-opacity', '0.35', 'important');
              } else {
                el.classList.remove('noor-active');
                el.style.removeProperty('fill');
                el.style.removeProperty('fill-opacity');
              }
            });
          };

          document.querySelectorAll('.ayahPolygon').forEach(function(el) {
            el.style.cursor = 'pointer';
            el.onclick = function() {
              var surah = el.getAttribute('surah');
              var ayah = el.getAttribute('ayah');
              if (surah && ayah && window.AyahChannel) AyahChannel.postMessage(surah + ':' + ayah);
            };
          });

          var startX=null,startY=null,didSwipe=false;
          var pinchStartDistance=null,pinchStartZoom=1,zoom=1,textScale=1;
          var panX=0,panY=0,panStartX=0,panStartY=0,panStartPanX=0,panStartPanY=0;
          var pageEl=document.querySelector('#page')||document.body;
          pageEl.style.touchAction='none';pageEl.style.transformOrigin='center top';
          function applyZoom(){pageEl.style.transform='translate3d('+panX+'px,'+panY+'px,0) scale('+(zoom*textScale)+')';}
          window.setNoorOrientation = function(landscape) {
            panX = 0;
            panY = 0;
            zoom = 1;
            document.documentElement.style.overflowY = landscape ? 'auto' : 'hidden';
            document.body.style.overflowY = landscape ? 'auto' : 'hidden';
            document.documentElement.style.touchAction = landscape ? 'pan-y' : 'none';
            document.body.style.touchAction = landscape ? 'pan-y' : 'none';
            pageEl.style.width = '100%';
            pageEl.style.height = 'auto';
            pageEl.style.minHeight = landscape ? '0' : '100%';
            pageEl.style.touchAction = landscape ? 'pan-y' : 'none';
            pageEl.style.transformOrigin = 'center top';
            var svg = pageEl.querySelector('svg');
            if (svg) {
              svg.style.width = '100%';
              svg.style.height = 'auto';
              svg.style.display = 'block';
              svg.style.maxWidth = 'none';
            }
            applyZoom();
            window.scrollTo(0, 0);
          };
          function dist(a,b){var dx=a.clientX-b.clientX,dy=a.clientY-b.clientY;return Math.sqrt(dx*dx+dy*dy);}
          document.addEventListener('touchstart',function(e){
            if(!e.touches||!e.touches.length)return;didSwipe=false;
            if(e.touches.length>=2){pinchStartDistance=dist(e.touches[0],e.touches[1]);pinchStartZoom=zoom;startX=null;return;}
            startX=e.touches[0].clientX;startY=e.touches[0].clientY;panStartX=startX;panStartY=startY;panStartPanX=panX;panStartPanY=panY;
          },{passive:true});
          document.addEventListener('touchmove',function(e){
            if(!e.touches||!e.touches.length)return;
            if(e.touches.length>=2){var d=dist(e.touches[0],e.touches[1]);if(pinchStartDistance===null){pinchStartDistance=d;pinchStartZoom=zoom;}zoom=Math.max(1,Math.min(3,pinchStartZoom*(d/pinchStartDistance)));didSwipe=zoom>1;applyZoom();return;}
            if(startX===null)return;var dx=e.touches[0].clientX-startX,dy=e.touches[0].clientY-startY;
            if(zoom>1.01){panX=panStartPanX+(e.touches[0].clientX-panStartX);panY=panStartPanY+(e.touches[0].clientY-panStartY);applyZoom();didSwipe=true;return;}
            if(Math.abs(dx)>35&&Math.abs(dx)>Math.abs(dy)*1.15)didSwipe=true;
          },{passive:true});
          document.addEventListener('touchend',function(e){
            if(e.touches&&e.touches.length>=2)return;if(pinchStartDistance!==null){pinchStartDistance=null;if(zoom<1.05){zoom=1;panX=0;panY=0;applyZoom();}startX=null;return;}
            if(startX===null)return;var dx=e.changedTouches[0].clientX-startX,dy=e.changedTouches[0].clientY-startY;startX=null;startY=null;
            if(zoom<=1.01&&Math.abs(dx)>105&&Math.abs(dx)>Math.abs(dy)*1.15){didSwipe=true;if(window.NavigationChannel)NavigationChannel.postMessage(dx>0?'next':'prev');setTimeout(function(){didSwipe=false;},80);}
          },{passive:true});
          document.addEventListener('dblclick',function(){zoom=1;panX=0;panY=0;applyZoom();});
          document.addEventListener('click',function(e){if(didSwipe){e.preventDefault();e.stopPropagation();didSwipe=false;}},true);
          if (window.setNoorTextScale) {
            window.setNoorTextScale(%TEXT_SCALE%);
          }
          if (window.setNoorOrientation) {
            window.setNoorOrientation(%IS_LANDSCAPE%);
          }
          PageChannel.postMessage(String(%PAGE%));
        })();
      '''
          .replaceAll('%PAGE%', '$currentPage')
          .replaceAll('%TEXT_SCALE%', _mushafTextScale.toStringAsFixed(3)),
      );

      if (_lastHighlightedAyah != null) {
        final parts = _lastHighlightedAyah!.split(':');
        if (parts.length == 2) {
          await controller.runJavaScript(
            "setNoorAyahHighlight('${parts[0]}','${parts[1]}');",
          );
        }
      }
    } catch (_) {}
  }

  Future<void> _changePage(
    int newPage, {
    bool forceReload = false,
  }) async {
    if (newPage < 1 || newPage > 604) {
      return;
    }

    if (newPage == currentPage && !forceReload) {
      return;
    }

    if (mounted) {
      setState(() {
        currentPage = newPage;
      });
    }

    await _loadMushafPage(newPage);
    _lastReadPage = newPage;
    await _saveReaderPreferences();
  }

  Widget _pageButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(14),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 3,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 38,
                height: 34,
                decoration: BoxDecoration(
                  color: onPressed == null
                      ? const Color(0xFFECE8DE)
                      : const Color(0xFF174A43),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: onPressed == null
                      ? const Color(0xFFAAA396)
                      : Colors.white,
                  size: 25,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  color: onPressed == null
                      ? const Color(0xFFAAA396)
                      : const Color(0xFF174A43),
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
class AdhkarItem {
  final String title;
  final String text;
  final int count;
  const AdhkarItem(this.title, this.text, this.count);
}

class AdhkarPage extends StatefulWidget {
  const AdhkarPage({super.key});

  @override
  State<AdhkarPage> createState() => _AdhkarPageState();
}

class _AdhkarPageState extends State<AdhkarPage> {
  int category = 0;

  static const categories = <String>[
    'الصباح',
    'المساء',
    'بعد الصلاة',
    'النوم',
    'الاستيقاظ',
    'المنزل',
    'السفر',
    'الحج والعمرة',
    'الأدعية',
    'الكرب والهم',
    'الرزق والشكر',
    'الوالدان والأهل',
    'المسجد والوضوء',
    'المطر والعافية',
  ];

  static const data = <List<AdhkarItem>>[
    [
      AdhkarItem('سيد الاستغفار', 'اللهم أنت ربي لا إله إلا أنت، خلقتني وأنا عبدك، وأنا على عهدك ووعدك ما استطعت، أعوذ بك من شر ما صنعت، أبوء لك بنعمتك علي، وأبوء بذنبي، فاغفر لي فإنه لا يغفر الذنوب إلا أنت.', 1),
      AdhkarItem('التسبيح', 'سبحان الله وبحمده.', 100),
      AdhkarItem('التهليل', 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.', 10),
      AdhkarItem('الاستغفار', 'أستغفر الله وأتوب إليه.', 100),
      AdhkarItem('الصلاة على النبي', 'اللهم صل وسلم على نبينا محمد.', 10),
    ],
    [
      AdhkarItem('ذكر المساء', 'أمسينا وأمسى الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.', 1),
      AdhkarItem('التسبيح', 'سبحان الله وبحمده.', 100),
      AdhkarItem('الاستغفار', 'أستغفر الله وأتوب إليه.', 100),
      AdhkarItem('التهليل', 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.', 10),
      AdhkarItem('الصلاة على النبي', 'اللهم صل وسلم على نبينا محمد.', 10),
    ],
    [
      AdhkarItem('الاستغفار', 'أستغفر الله.', 3),
      AdhkarItem('التسبيح', 'سبحان الله.', 33),
      AdhkarItem('الحمد', 'الحمد لله.', 33),
      AdhkarItem('التكبير', 'الله أكبر.', 34),
      AdhkarItem('آية الكرسي', 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ...', 1),
    ],
    [
      AdhkarItem('دعاء النوم', 'باسمك اللهم أموت وأحيا.', 1),
      AdhkarItem('التسبيح', 'سبحان الله.', 33),
      AdhkarItem('الحمد', 'الحمد لله.', 33),
      AdhkarItem('التكبير', 'الله أكبر.', 34),
    ],
    [
      AdhkarItem('دعاء الاستيقاظ', 'الحمد لله الذي أحيانا بعدما أماتنا وإليه النشور.', 1),
      AdhkarItem('الشكر', 'الحمد لله رب العالمين.', 1),
    ],
    [
      AdhkarItem('عند دخول المنزل', 'بسم الله ولجنا، وبسم الله خرجنا، وعلى ربنا توكلنا.', 1),
      AdhkarItem('عند الخروج من المنزل', 'بسم الله، توكلت على الله، ولا حول ولا قوة إلا بالله.', 1),
    ],
    [
      AdhkarItem('دعاء السفر', 'سبحان الذي سخر لنا هذا وما كنا له مقرنين وإنا إلى ربنا لمنقلبون.', 1),
      AdhkarItem('التكبير في السفر', 'الله أكبر، الله أكبر، الله أكبر.', 3),
    ],
    [
      AdhkarItem('التلبية', 'لبيك اللهم لبيك، لبيك لا شريك لك لبيك، إن الحمد والنعمة لك والملك، لا شريك لك.', 1),
      AdhkarItem('الدعاء عند رؤية الكعبة', 'اللهم زد هذا البيت تشريفًا وتعظيمًا ومهابةً وأمنًا، وزد من حجه أو اعتمره تشريفًا وتعظيمًا.', 1),
      AdhkarItem('الدعاء أثناء الطواف', 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار.', 1),
      AdhkarItem('الدعاء عند الصفا والمروة', 'إن الصفا والمروة من شعائر الله، أبدأ بما بدأ الله به.', 1),
    ],
    [
      AdhkarItem('دعاء جامع', 'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار.', 1),
      AdhkarItem('دعاء الهداية', 'اهدني وسددني.', 1),
      AdhkarItem('دعاء الثبات', 'يا مقلب القلوب ثبت قلبي على دينك.', 1),
      AdhkarItem('دعاء المغفرة', 'رب اغفر لي وتب علي إنك أنت التواب الرحيم.', 1),
      AdhkarItem('دعاء حسن العبادة', 'اللهم أعني على ذكرك وشكرك وحسن عبادتك.', 1),
      AdhkarItem('دعاء الخير', 'اللهم إني أسألك من الخير كله عاجله وآجله ما علمت منه وما لم أعلم.', 1),
    ],
    [
      AdhkarItem('دعاء الكرب', 'لا إله إلا الله العظيم الحليم، لا إله إلا الله رب العرش العظيم، لا إله إلا الله رب السماوات ورب الأرض ورب العرش الكريم.', 1),
      AdhkarItem('دعاء الهم والحزن', 'اللهم إني أعوذ بك من الهم والحزن، وأعوذ بك من العجز والكسل، وأعوذ بك من الجبن والبخل، وأعوذ بك من غلبة الدين وقهر الرجال.', 1),
      AdhkarItem('حسبنا الله', 'حسبنا الله ونعم الوكيل.', 7),
      AdhkarItem('دعاء تفريج الكرب', 'لا إله إلا أنت سبحانك إني كنت من الظالمين.', 1),
    ],
    [
      AdhkarItem('دعاء الرزق', 'اللهم اكفني بحلالك عن حرامك وأغنني بفضلك عمن سواك.', 1),
      AdhkarItem('دعاء البركة', 'اللهم بارك لنا فيما رزقتنا وقنا عذاب النار.', 1),
      AdhkarItem('الحمد لله', 'الحمد لله رب العالمين.', 33),
      AdhkarItem('الشكر', 'رب أوزعني أن أشكر نعمتك التي أنعمت علي وعلى والدي وأن أعمل صالحًا ترضاه.', 1),
    ],
    [
      AdhkarItem('دعاء للوالدين', 'رب ارحمهما كما ربياني صغيرًا.', 1),
      AdhkarItem('دعاء للأهل', 'ربنا هب لنا من أزواجنا وذرياتنا قرة أعين واجعلنا للمتقين إمامًا.', 1),
      AdhkarItem('دعاء الصلاح', 'وأصلح لي في ذريتي إني تبت إليك وإني من المسلمين.', 1),
    ],
    [
      AdhkarItem('دعاء دخول المسجد', 'اللهم افتح لي أبواب رحمتك.', 1),
      AdhkarItem('دعاء الخروج من المسجد', 'اللهم إني أسألك من فضلك.', 1),
      AdhkarItem('دعاء الوضوء', 'أشهد أن لا إله إلا الله وحده لا شريك له، وأشهد أن محمدًا عبده ورسوله.', 1),
      AdhkarItem('بعد الأذان', 'اللهم رب هذه الدعوة التامة والصلاة القائمة، آت محمدًا الوسيلة والفضيلة، وابعثه مقامًا محمودًا الذي وعدته.', 1),
    ],
    [
      AdhkarItem('دعاء المطر', 'اللهم صيبًا نافعًا.', 1),
      AdhkarItem('دعاء العافية', 'اللهم إني أسألك العفو والعافية في الدنيا والآخرة.', 1),
      AdhkarItem('دعاء للمريض', 'أسأل الله العظيم رب العرش العظيم أن يشفيك.', 7),
      AdhkarItem('دعاء السلامة', 'اللهم إني أسألك السلامة من كل إثم والغنيمة من كل بر.', 1),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final items = data[category];
    final totalItems = data.fold<int>(0, (sum, list) => sum + list.length);
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      appBar: AppBar(
        title: const Text('الأذكار', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'مكتبة الأذكار',
            icon: const Icon(Icons.library_books_rounded),
            onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdhkarLibraryPage())),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 2),
            child: Card(
              elevation: 0,
              color: const Color(0xFFE8EFE8),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                child: Row(
                  textDirection: TextDirection.rtl,
                  children: [
                    const Icon(Icons.auto_awesome_rounded, color: Color(0xFF47734A)),
                    const SizedBox(width: 10),
                    Expanded(child: Text('محتوى الأذكار: $totalItems أذكار مختارة + مكتبة موسعة محلية', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.w800))),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 2, 12, 4),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const AdhkarLibraryPage())),
                    icon: const Icon(Icons.library_books_rounded),
                    label: const Text('مكتبة الأذكار'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const TasbeehCounterPage())),
                    icon: const Icon(Icons.touch_app_rounded),
                    label: const Text('عداد التسبيح'),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 58,
            child: ListView.separated(
              reverse: true,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 7),
              itemBuilder: (_, i) => ChoiceChip(label: Text(categories[i]), selected: category == i, onSelected: (_) => setState(() => category = i)),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 24),
              itemCount: items.length,
              itemBuilder: (_, i) => _DhikrCard(key: ValueKey('${category}_$i'), item: items[i]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrCard extends StatefulWidget {
  final AdhkarItem item;
  const _DhikrCard({super.key, required this.item});

  @override
  State<_DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<_DhikrCard> {
  late int completed;
  bool _loaded = false;

  String get _prefsKey => 'noor_dhikr_count_${base64Url.encode(utf8.encode('${widget.item.title}|${widget.item.text}'))}';

  @override
  void initState() {
    super.initState();
    completed = 0;
    _loadCount();
  }

  Future<void> _loadCount() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_prefsKey) ?? 0;
    if (!mounted) return;
    setState(() {
      completed = value.clamp(0, widget.item.count).toInt();
      _loaded = true;
    });
  }

  Future<void> _saveCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsKey, completed);
  }

  @override
  Widget build(BuildContext context) {
    final done = completed >= widget.item.count;
    final remaining = (widget.item.count - completed).clamp(0, widget.item.count);
    final progress = widget.item.count == 0 ? 1.0 : completed / widget.item.count;
    return Card(
      elevation: 1.5,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: done || !_loaded ? null : () {
          setState(() => completed++);
          _saveCount();
        },
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(textDirection: TextDirection.rtl, children: [
                Expanded(child: Text(widget.item.title, textDirection: TextDirection.rtl, style: const TextStyle(color: Color(0xFF174A43), fontSize: 15, fontWeight: FontWeight.w900))),
                Text('× ${widget.item.count}', style: const TextStyle(color: Color(0xFF174A43), fontWeight: FontWeight.w800)),
              ]),
              const SizedBox(height: 14),
              Text(widget.item.text, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.9)),
              const SizedBox(height: 14),
              ClipRRect(borderRadius: BorderRadius.circular(10), child: LinearProgressIndicator(value: progress, minHeight: 7)),
              const SizedBox(height: 10),
              Row(textDirection: TextDirection.rtl, children: [
                Expanded(child: Text(done ? 'تم الذكر ✓' : 'المتبقي: $remaining', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.w800))),
                TextButton.icon(onPressed: () { setState(() => completed = 0); _saveCount(); }, icon: const Icon(Icons.refresh_rounded, size: 19), label: const Text('تصفير')),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}


class TasbeehCounterPage extends StatefulWidget {
  const TasbeehCounterPage({super.key});

  @override
  State<TasbeehCounterPage> createState() => _TasbeehCounterPageState();
}

class _TasbeehCounterPageState extends State<TasbeehCounterPage> with WidgetsBindingObserver {
  static const _countKey = 'noor_tasbeeh_count_v3';
  static const _phraseKey = 'noor_tasbeeh_phrase_v3';
  static const _stateKey = 'noor_tasbeeh_state_v4';
  int count = 0;
  String phrase = 'سبحان الله';
  bool loading = true;

  static const phrases = ['سبحان الله', 'الحمد لله', 'الله أكبر', 'أستغفر الله'];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _load();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _persistNow();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _persistNow() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_countKey, count);
      await prefs.setString(_phraseKey, phrase);
      await prefs.setString(_stateKey, jsonEncode({'count': count, 'phrase': phrase}));
    } catch (_) {}
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    var savedCount = prefs.getInt(_countKey) ?? 0;
    var savedPhrase = prefs.getString(_phraseKey) ?? phrases.first;
    final rawState = prefs.getString(_stateKey);
    if (rawState != null) {
      try {
        final state = jsonDecode(rawState) as Map<String, dynamic>;
        savedCount = (state['count'] as num?)?.toInt() ?? savedCount;
        savedPhrase = state['phrase']?.toString() ?? savedPhrase;
      } catch (_) {}
    }
    if (!phrases.contains(savedPhrase)) savedPhrase = phrases.first;
    if (!mounted) return;
    setState(() {
      count = savedCount < 0 ? 0 : savedCount;
      phrase = savedPhrase;
      loading = false;
    });
  }

  Future<void> _increment() async {
    setState(() => count++);
    await _persistNow();
  }

  Future<void> _reset() async {
    setState(() => count = 0);
    await _persistNow();
  }

  Future<void> _setPhrase(String value) async {
    setState(() => phrase = value);
    await _persistNow();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      appBar: AppBar(
        title: const Text('عداد التسبيح', style: TextStyle(fontWeight: FontWeight.w900)),
        actions: [
          IconButton(
            tooltip: 'تصفير العداد',
            onPressed: loading ? null : _reset,
            icon: const Icon(Icons.restart_alt_rounded),
          ),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(18, 12, 18, 30),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(colors: [Color(0xFF1B5B50), Color(0xFF123F38)]),
                    borderRadius: BorderRadius.circular(28),
                    boxShadow: const [BoxShadow(color: Color(0x22000000), blurRadius: 18, offset: Offset(0, 8))],
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.auto_awesome_rounded, color: Color(0xFFF0CF7A), size: 28),
                      const SizedBox(height: 8),
                      const Text('عدادك محفوظ تلقائيًا', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                      const SizedBox(height: 5),
                      const Text('يمكنك الخروج من الصفحة والعودة لاحقًا وسيبقى العدد كما هو.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD7E4DF), height: 1.5, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Card(
                  elevation: 0,
                  color: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      children: [
                        const Align(alignment: Alignment.centerRight, child: Text('الذكر', style: TextStyle(fontWeight: FontWeight.w900, color: Color(0xFF173F38)))),
                        const SizedBox(height: 10),
                        Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 7,
                          runSpacing: 7,
                          children: phrases.map((item) => ChoiceChip(label: Text(item), selected: phrase == item, onSelected: (_) => _setPhrase(item))).toList(),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Center(
                  child: GestureDetector(
                    onTap: _increment,
                    child: Container(
                      width: 235,
                      height: 235,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFFE7EFE9),
                        border: Border.all(color: const Color(0xFFB8CDBF), width: 8),
                        boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 20, offset: Offset(0, 10))],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('$count', style: const TextStyle(fontSize: 58, fontWeight: FontWeight.w900, color: Color(0xFF173F38))),
                          const SizedBox(height: 4),
                          Text(phrase, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF47734A))),
                          const SizedBox(height: 10),
                          const Text('اضغط للعد', style: TextStyle(fontSize: 11, color: Color(0xFF7A827C))),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
                FilledButton.icon(
                  onPressed: _reset,
                  style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15), backgroundColor: const Color(0xFF7A3E3E)),
                  icon: const Icon(Icons.delete_sweep_rounded),
                  label: const Text('تصفير عدد التسبيحات', style: TextStyle(fontWeight: FontWeight.w900)),
                ),
                const SizedBox(height: 9),
                Text('العدد الحالي: $count', textAlign: TextAlign.center, style: const TextStyle(color: Color(0xFF6D756F), fontWeight: FontWeight.w700)),
              ],
            ),
    );
  }
}

class LibraryDhikrEntry {
  final int id;
  final String title;
  final List<String> texts;
  final List<String> footnotes;

  const LibraryDhikrEntry({
    required this.id,
    required this.title,
    required this.texts,
    required this.footnotes,
  });

  factory LibraryDhikrEntry.fromJson(Map<String, dynamic> json) {
    final rawText = json['text'];
    final rawFootnote = json['footnote'];
    final texts = rawText is List
        ? rawText.map((e) => '$e'.trim()).where((e) => e.isNotEmpty).toList()
        : (rawText == null ? <String>[] : ['$rawText']);
    final footnotes = rawFootnote is List
        ? rawFootnote.map((e) => '$e'.trim()).where((e) => e.isNotEmpty).toList()
        : (rawFootnote == null ? <String>[] : ['$rawFootnote']);

    return LibraryDhikrEntry(
      id: int.tryParse('${json['id']}') ?? 0,
      title: '${json['title'] ?? 'ذكر'}'.trim(),
      texts: List<String>.from(texts),
      footnotes: List<String>.from(footnotes),
    );
  }
}

class AdhkarLibraryPage extends StatefulWidget {
  const AdhkarLibraryPage({super.key});

  @override
  State<AdhkarLibraryPage> createState() => _AdhkarLibraryPageState();
}

class _AdhkarLibraryPageState extends State<AdhkarLibraryPage> {
  static const _sourceUrl =
      'https://raw.githubusercontent.com/asellam/HisnElMuslim/main/hisn.json';
  static const _cacheKey = 'noor_quran_adhkar_library_v1';

  final TextEditingController _searchController = TextEditingController();
  List<LibraryDhikrEntry> _entries = [];
  Set<int> _favorites = <int>{};
  String _filter = 'الكل';
  bool _loading = true;
  bool _refreshing = false;
  String? _error;

  static const _filters = <String>[
    'الكل',
    'الصباح والمساء',
    'الصلاة',
    'النوم والاستيقاظ',
    'المنزل',
    'السفر',
    'المرض والرقية',
    'الطعام والشراب',
    'الأسرة والمناسبات',
    'أخرى',
  ];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _loadLibrary();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final values = prefs.getStringList('noor_quran_adhkar_library_favorites') ?? [];
    if (!mounted) return;
    setState(() => _favorites = values.map(int.parse).toSet());
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'noor_quran_adhkar_library_favorites',
      _favorites.map((e) => '$e').toList(),
    );
  }

  Future<void> _loadLibrary({bool forceRefresh = false}) async {
    if (forceRefresh && mounted) {
      setState(() {
        _refreshing = true;
        _error = null;
      });
    }

    try {
      // المكتبة تعتمد الآن على بيانات الأذكار الموجودة داخل التطبيق نفسه.
      // لا تعتمد على حزمة خارجية أو GitHub أو الإنترنت، لذلك تعمل أوفلاين أيضاً.
      final entries = <LibraryDhikrEntry>[];

      for (var i = 0; i < _AdhkarPageState.data.length; i++) {
        final items = _AdhkarPageState.data[i];
        final texts = items
            .map((item) => item.text.trim())
            .where((text) => text.isNotEmpty)
            .toList();

        if (texts.isEmpty) continue;

        entries.add(
          LibraryDhikrEntry(
            id: i + 1,
            title: _AdhkarPageState.categories[i],
            texts: texts,
            footnotes: const <String>[],
          ),
        );
      }

      if (!mounted) return;
      setState(() {
        _entries = entries;
        _loading = false;
        _refreshing = false;
        _error = entries.isEmpty ? 'لم يتم العثور على بيانات الأذكار.' : null;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _refreshing = false;
        _error = 'تعذر فتح مكتبة الأذكار المحلية.';
      });
    }
  }

  String _bucket(LibraryDhikrEntry item) {
    final t = '${item.title} ${item.texts.join(' ')}';
    if (RegExp(r'الصباح|المساء|أمسينا|أصبحنا').hasMatch(t)) return 'الصباح والمساء';
    if (RegExp(r'الصلاة|الوضوء|الأذان|الركوع|السجود|التشهد|الوتر|الاستخارة|المسجد').hasMatch(t)) return 'الصلاة';
    if (RegExp(r'النوم|الاستيقاظ|الرؤيا|الحلم|الفزع').hasMatch(t)) return 'النوم والاستيقاظ';
    if (RegExp(r'المنزل|البيت|الخروج من المنزل|دخول المنزل').hasMatch(t)) return 'المنزل';
    if (RegExp(r'السفر|الركوب|المسافر|الطريق|البلدة').hasMatch(t)) return 'السفر';
    if (RegExp(r'مريض|المرض|يشفي|الشفاء|الرقية|العين|الحسد').hasMatch(t)) return 'المرض والرقية';
    if (RegExp(r'الطعام|الشراب|الأكل|المائدة').hasMatch(t)) return 'الطعام والشراب';
    if (RegExp(r'المولود|الزواج|التهنئة|العزاء|الميت|الجنازة|القبور').hasMatch(t)) return 'الأسرة والمناسبات';
    return 'أخرى';
  }

  List<LibraryDhikrEntry> get _filtered {
    final q = _searchController.text.trim().toLowerCase();
    return _entries.where((item) {
      final categoryOk = _filter == 'الكل' || _bucket(item) == _filter;
      if (!categoryOk) return false;
      if (q.isEmpty) return true;
      final haystack = '${item.title} ${item.texts.join(' ')} ${item.footnotes.join(' ')}'.toLowerCase();
      return haystack.contains(q);
    }).toList();
  }

  int get _textCount => _entries.fold(0, (sum, item) => sum + item.texts.length);

  Future<void> _copyEntry(LibraryDhikrEntry item) async {
    final text = '${item.title}\n\n${item.texts.join('\n\n')}'
        '${item.footnotes.isEmpty ? '' : '\n\nالمصادر:\n${item.footnotes.join('\n')}'}';
    await Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم نسخ الذكر')),
    );
  }

  Future<void> _shareEntry(LibraryDhikrEntry item) async {
    final text = '${item.title}\n\n${item.texts.join('\n\n')}';
    await Share.share(text);
  }

  Future<void> _toggleFavorite(LibraryDhikrEntry item) async {
    setState(() {
      if (_favorites.contains(item.id)) {
        _favorites.remove(item.id);
      } else {
        _favorites.add(item.id);
      }
    });
    await _saveFavorites();
  }

  Future<void> _randomEntry() async {
    if (_entries.isEmpty) return;
    final item = (_entries..shuffle()).first;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => _LibraryEntrySheet(
        item: item,
        favorite: _favorites.contains(item.id),
        onFavorite: () => _toggleFavorite(item),
        onCopy: () => _copyEntry(item),
        onShare: () => _shareEntry(item),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final items = _filtered;
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      appBar: AppBar(
        title: const Text('مكتبة الأذكار', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'ذكر عشوائي',
            icon: const Icon(Icons.auto_awesome_rounded),
            onPressed: _entries.isEmpty ? null : _randomEntry,
          ),
          IconButton(
            tooltip: 'تحديث المكتبة',
            icon: _refreshing
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.sync_rounded),
            onPressed: _refreshing ? null : () => _loadLibrary(forceRefresh: true),
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _entries.isEmpty
              ? _errorView()
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
                      child: Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F1EC),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            const Icon(Icons.menu_book_rounded, size: 32, color: Color(0xFF174A43)),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '${_entries.length} باباً • $_textCount نصاً\nبحث + تصنيف + مفضلة + نسخ ومشاركة',
                                textDirection: TextDirection.rtl,
                                style: const TextStyle(fontWeight: FontWeight.w800, height: 1.5),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      child: TextField(
                        controller: _searchController,
                        textDirection: TextDirection.rtl,
                        decoration: InputDecoration(
                          hintText: 'ابحث في عناوين ونصوص الأذكار...',
                          prefixIcon: const Icon(Icons.search_rounded),
                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  icon: const Icon(Icons.clear_rounded),
                                  onPressed: _searchController.clear,
                                ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 52,
                      child: ListView.separated(
                        reverse: true,
                        scrollDirection: Axis.horizontal,
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        itemCount: _filters.length,
                        separatorBuilder: (_, __) => const SizedBox(width: 7),
                        itemBuilder: (_, i) => ChoiceChip(
                          label: Text(_filters[i]),
                          selected: _filter == _filters[i],
                          onSelected: (_) => setState(() => _filter = _filters[i]),
                        ),
                      ),
                    ),
                    Expanded(
                      child: items.isEmpty
                          ? const Center(child: Text('لا توجد نتائج مطابقة', textDirection: TextDirection.rtl))
                          : ListView.builder(
                              padding: const EdgeInsets.fromLTRB(12, 6, 12, 24),
                              itemCount: items.length,
                              itemBuilder: (_, index) {
                                final item = items[index];
                                return _LibraryEntryCard(
                                  item: item,
                                  favorite: _favorites.contains(item.id),
                                  onFavorite: () => _toggleFavorite(item),
                                  onCopy: () => _copyEntry(item),
                                  onShare: () => _shareEntry(item),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }

  Widget _errorView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded, size: 54),
            const SizedBox(height: 12),
            Text(_error ?? 'تعذر تحميل المكتبة', textDirection: TextDirection.rtl, textAlign: TextAlign.center),
            const SizedBox(height: 14),
            FilledButton.icon(
              onPressed: () => _loadLibrary(forceRefresh: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
            ),
          ],
        ),
      ),
    );
  }
}

class _LibraryEntryCard extends StatelessWidget {
  final LibraryDhikrEntry item;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _LibraryEntryCard({
    required this.item,
    required this.favorite,
    required this.onFavorite,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1.2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE8F1EC),
          foregroundColor: const Color(0xFF174A43),
          child: Text('${item.id}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800)),
        ),
        title: Text(item.title, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.w800)),
        subtitle: Text('${item.texts.length} نص${item.texts.length == 1 ? '' : 'وص'} • ${item.footnotes.length} تخريج', textDirection: TextDirection.rtl),
        trailing: IconButton(
          tooltip: favorite ? 'إزالة من المفضلة' : 'إضافة للمفضلة',
          icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded),
          onPressed: onFavorite,
        ),
        children: [
          for (var i = 0; i < item.texts.length; i++) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                item.texts[i],
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, height: 1.95),
              ),
            ),
            if (i < item.texts.length - 1) const Divider(height: 26),
          ],
          if (item.footnotes.isNotEmpty) ...[
            const Divider(height: 28),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'المصادر والتخريج',
                textDirection: TextDirection.rtl,
                style: const TextStyle(fontWeight: FontWeight.w800, color: Color(0xFF174A43)),
              ),
            ),
            const SizedBox(height: 6),
            for (final note in item.footnotes)
              Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Text('• $note', textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 12, height: 1.6)),
              ),
          ],
          Row(
            textDirection: TextDirection.rtl,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(onPressed: onCopy, icon: const Icon(Icons.copy_rounded), label: const Text('نسخ')),
              TextButton.icon(onPressed: onShare, icon: const Icon(Icons.share_rounded), label: const Text('مشاركة')),
            ],
          ),
        ],
      ),
    );
  }
}

class _LibraryEntrySheet extends StatelessWidget {
  final LibraryDhikrEntry item;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const _LibraryEntrySheet({
    required this.item,
    required this.favorite,
    required this.onFavorite,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 4, 18, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(item.title, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 14),
            for (var i = 0; i < item.texts.length; i++) ...[
              Text(item.texts[i], textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.95)),
              if (i < item.texts.length - 1) const Divider(height: 26),
            ],
            const SizedBox(height: 12),
            Row(
              textDirection: TextDirection.rtl,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(onPressed: onFavorite, icon: Icon(favorite ? Icons.favorite_rounded : Icons.favorite_border_rounded)),
                IconButton(onPressed: onCopy, icon: const Icon(Icons.copy_rounded)),
                IconButton(onPressed: onShare, icon: const Icon(Icons.share_rounded)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class DuasPage extends StatelessWidget {
  const DuasPage({super.key});

  static const List<Map<String, String>> duas = [
    {'title': 'دعاء قبول العمل', 'text': 'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ', 'source': 'البقرة: 127'},
    {'title': 'دعاء إتمام الطاعة والتوبة', 'text': 'رَبَّنَا وَاجْعَلْنَا مُسْلِمَيْنِ لَكَ وَمِنْ ذُرِّيَّتِنَا أُمَّةً مُسْلِمَةً لَكَ وَأَرِنَا مَنَاسِكَنَا وَتُبْ عَلَيْنَا إِنَّكَ أَنْتَ التَّوَّابُ الرَّحِيمُ', 'source': 'البقرة: 128'},
    {'title': 'دعاء خير الدنيا والآخرة', 'text': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ', 'source': 'البقرة: 201'},
    {'title': 'دعاء الثبات', 'text': 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ', 'source': 'آل عمران: 8'},
    {'title': 'دعاء المغفرة والتقصير', 'text': 'رَبَّنَا اغْفِرْ لَنَا ذُنُوبَنَا وَإِسْرَافَنَا فِي أَمْرِنَا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ', 'source': 'آل عمران: 147'},
    {'title': 'دعاء تفريج الكرب', 'text': 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ', 'source': 'الأنبياء: 87'},
    {'title': 'دعاء الشكر والعمل الصالح', 'text': 'رَبِّ أَوْزِعْنِي أَنْ أَشْكُرَ نِعْمَتَكَ الَّتِي أَنْعَمْتَ عَلَيَّ وَعَلَى وَالِدَيَّ وَأَنْ أَعْمَلَ صَالِحًا تَرْضَاهُ وَأَصْلِحْ لِي فِي ذُرِّيَّتِي إِنِّي تُبْتُ إِلَيْكَ وَإِنِّي مِنَ الْمُسْلِمِينَ', 'source': 'الأحقاف: 15'},
    {'title': 'دعاء الوالدين', 'text': 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا', 'source': 'الإسراء: 24'},
    {'title': 'دعاء إقامة الصلاة', 'text': 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ. رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ', 'source': 'إبراهيم: 40-41'},
    {'title': 'دعاء العلم', 'text': 'رَبِّ زِدْنِي عِلْمًا', 'source': 'طه: 114'},
    {'title': 'دعاء التيسير', 'text': 'رَبِّ اشْرَحْ لِي صَدْرِي، وَيَسِّرْ لِي أَمْرِي، وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي، يَفْقَهُوا قَوْلِي', 'source': 'طه: 25-28'},
    {'title': 'دعاء الحاجة والفضل', 'text': 'رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ', 'source': 'القصص: 24'},
    {'title': 'دعاء النجاة والمغفرة', 'text': 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ', 'source': 'الأعراف: 23'},
    {'title': 'دعاء الصبر والثبات', 'text': 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَتَوَفَّنَا مُسْلِمِينَ', 'source': 'الأعراف: 126'},
    {'title': 'دعاء طلب الذرية الصالحة', 'text': 'رَبِّ هَبْ لِي مِنْ لَدُنْكَ ذُرِّيَّةً طَيِّبَةً إِنَّكَ سَمِيعُ الدُّعَاءِ', 'source': 'آل عمران: 38'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      appBar: AppBar(title: const Text('أدعية من القرآن الكريم', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF123D32), Color(0xFF0C2C24)]),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFD4B36A).withOpacity(.55)),
              ),
              child: const Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text('أدعية مأثورة من كتاب الله', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFFD4B36A), fontSize: 20, fontWeight: FontWeight.w900)),
                SizedBox(height: 7),
                Text('نصوص الدعاء هنا من القرآن الكريم، مع ذكر موضع الآية. يمكن نسخ الدعاء ومشاركته بسهولة.', textAlign: TextAlign.right, style: TextStyle(color: Color(0xFFE5ECE8), height: 1.7, fontSize: 12.5)),
              ]),
            ),
            const SizedBox(height: 12),
            for (final dua in duas)
              Card(
                margin: const EdgeInsets.only(bottom: 11),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(21), side: BorderSide(color: const Color(0xFFD4B36A).withOpacity(.30))),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 15, 16, 11),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      Expanded(child: Text(dua['title']!, style: const TextStyle(color: Color(0xFF173F35), fontWeight: FontWeight.w900, fontSize: 15))),
                      Container(padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5), decoration: BoxDecoration(color: const Color(0xFFEAF1EC), borderRadius: BorderRadius.circular(12)), child: Text(dua['source']!, style: const TextStyle(color: Color(0xFF4B675C), fontSize: 10, fontWeight: FontWeight.w800))),
                    ]),
                    const SizedBox(height: 12),
                    Text(dua['text']!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 19, height: 2.0, fontWeight: FontWeight.w700, color: Color(0xFF28352F))),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: IconButton(
                        tooltip: 'نسخ الدعاء',
                        icon: const Icon(Icons.copy_rounded),
                        onPressed: () async {
                          await Clipboard.setData(ClipboardData(text: '${dua['text']}\n(${dua['source']})'));
                          if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الدعاء')));
                        },
                      ),
                    ),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> with WidgetsBindingObserver {
  bool loading = false;
  bool locationReady = false;
  String? error;
  String locationText = 'لم يتم تحديد الموقع بعد';
  String dateText = '';
  double? latitude;
  double? longitude;
  Map<String, String> times = {};

  // طريقة الحساب الحالية: 8 = Gulf Region.
  // لاحقًا يمكن جعلها قابلة للتغيير من الإعدادات.
  static const int calculationMethod = 8;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      // إذا رجع المستخدم من إعدادات الموقع، أعد المحاولة تلقائياً.
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _loadSavedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLat = prefs.getDouble('noor_prayer_latitude');
    final savedLon = prefs.getDouble('noor_prayer_longitude');
    final savedLocation = prefs.getString('noor_prayer_location');

    if (savedLat != null && savedLon != null && mounted) {
      setState(() {
        latitude = savedLat;
        longitude = savedLon;
        locationText = savedLocation ?? 'آخر موقع محفوظ';
        locationReady = true;
      });
      await _loadPrayerTimes();
    } else {
      await _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      loading = true;
      error = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          loading = false;
          error = 'خدمة الموقع (GPS) غير مفعّلة. فعّلي الموقع من إعدادات الجهاز ثم حاولي مرة أخرى.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          loading = false;
          error = 'تم رفض إذن الموقع. نحتاج الموقع فقط لحساب مواقيت الصلاة حسب مكانك.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          loading = false;
          error = 'إذن الموقع مرفوض نهائيًا. افتحي إعدادات التطبيق وفعّلي صلاحية الموقع.';
        });
        return;
      }

      Position? position;

      // مواقيت الصلاة لا تحتاج دقة مترية؛ الدقة المتوسطة أسرع وأكثر
      // استقراراً على الأجهزة التي تتأخر في الحصول على GPS.
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 0,
          ),
        ).timeout(const Duration(seconds: 12));
      } catch (_) {
        // إذا لم يصل GPS بسرعة، استخدم آخر موقع معروف للجهاز مؤقتاً.
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        throw Exception('NO_LOCATION_FIX');
      }

      latitude = position.latitude;
      longitude = position.longitude;
      locationText =
          'الموقع الحالي • ${position.latitude.toStringAsFixed(4)}°، ${position.longitude.toStringAsFixed(4)}°';
      locationReady = true;

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('noor_prayer_latitude', position.latitude);
      await prefs.setDouble('noor_prayer_longitude', position.longitude);
      await prefs.setString('noor_prayer_location', locationText);

      if (mounted) {
        setState(() {});
      }

      await _loadPrayerTimes();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'لم نحصل على إحداثيات GPS بعد. فعّلي الموقع واسمحي للتطبيق بالموقع الدقيق، ثم اضغطي تحديث موقعي مرة أخرى.';
      });
    }
  }

  Future<void> _loadPrayerTimes() async {
    if (latitude == null || longitude == null) {
      await _getCurrentLocation();
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      final now = DateTime.now();
      final date =
          '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';

      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/$date'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&method=$calculationMethod',
      );

      final response = await http.get(url).timeout(
            const Duration(seconds: 15),
          );

      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = jsonDecode(response.body) as Map<String, dynamic>;
      final data = body['data'] as Map<String, dynamic>;
      final timings = Map<String, dynamic>.from(data['timings'] as Map);

      final metaDate = data['date'] as Map<String, dynamic>?;

      if (!mounted) return;

      setState(() {
        times = {
          'الفجر': timings['Fajr']?.toString() ?? '--:--',
          'الشروق': timings['Sunrise']?.toString() ?? '--:--',
          'الظهر': timings['Dhuhr']?.toString() ?? '--:--',
          'العصر': timings['Asr']?.toString() ?? '--:--',
          'المغرب': timings['Maghrib']?.toString() ?? '--:--',
          'العشاء': timings['Isha']?.toString() ?? '--:--',
        };

        dateText =
            '${metaDate?['gregorian']?['date'] ?? ''}  •  ${metaDate?['hijri']?['date'] ?? ''} هـ';
        loading = false;
        locationReady = true;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loading = false;
        error = 'تعذر تحميل مواقيت الصلاة. تحققي من اتصال الإنترنت وحاولي مرة أخرى.';
      });
    }
  }

  Future<void> _refreshLocationAndTimes() async {
    await _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    final isNight = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      appBar: AppBar(
        title: const Text(
          'مواقيت الصلاة',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تحديث الموقع',
            onPressed: loading ? null : _refreshLocationAndTimes,
            icon: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshLocationAndTimes,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Color(0xFF173F35),
                    Color(0xFF245B4D),
                  ],
                ),
                borderRadius: BorderRadius.circular(26),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF173F35).withOpacity(.15),
                    blurRadius: 22,
                    offset: const Offset(0, 9),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    textDirection: TextDirection.rtl,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(.12),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.location_on_rounded,
                          color: Color(0xFFE8D7A8),
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'مواقيتك حسب موقعك',
                          textDirection: TextDirection.rtl,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(
                    locationText,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      color: Color(0xFFD5E0D9),
                      fontSize: 12,
                      height: 1.6,
                    ),
                  ),
                  if (dateText.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(
                      dateText,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        color: Color(0xFFD5E0D9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: FilledButton.icon(
                      onPressed: loading ? null : _refreshLocationAndTimes,
                      icon: const Icon(Icons.gps_fixed_rounded),
                      label: const Text('تحديث موقعي ومواقيت الصلاة'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFFE8D7A8),
                        foregroundColor: const Color(0xFF173F35),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        textStyle: const TextStyle(
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(28),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            if (error != null)
              Container(
                margin: const EdgeInsets.only(bottom: 12),
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFF3F0),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFE6C9C1),
                  ),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.location_off_rounded,
                      size: 32,
                      color: Color(0xFF9A5A4A),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      error!,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF6E4035),
                        fontWeight: FontWeight.w600,
                        height: 1.6,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      alignment: WrapAlignment.center,
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        OutlinedButton.icon(
                          onPressed: loading ? null : _refreshLocationAndTimes,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('حاول مرة أخرى'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Geolocator.openLocationSettings(),
                          icon: const Icon(Icons.gps_fixed_rounded),
                          label: const Text('فتح إعدادات GPS'),
                        ),
                        OutlinedButton.icon(
                          onPressed: () => Geolocator.openAppSettings(),
                          icon: const Icon(Icons.settings_rounded),
                          label: const Text('إعدادات التطبيق'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            if (times.isNotEmpty)
              ...times.entries.map(
                (entry) => Container(
                  margin: const EdgeInsets.only(bottom: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: const Color(0xFFE6E1D6),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 4,
                    ),
                    leading: Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F0EB),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Icon(
                        _prayerIcon(entry.key),
                        color: const Color(0xFF174A43),
                      ),
                    ),
                    title: Text(
                      entry.key,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 15,
                      ),
                    ),
                    trailing: Text(
                      entry.value,
                      style: const TextStyle(
                        color: Color(0xFF173F35),
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
              ),
            if (!loading && times.isEmpty && error == null)
              Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'فعّلي الموقع حتى نحسب مواقيت الصلاة بدقة حسب إحداثياتك.',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    height: 1.6,
                  ),
                ),
              ),
            const SizedBox(height: 8),
            Text(
              'يُستخدم الموقع فقط لتحديد الإحداثيات اللازمة لحساب المواقيت، ولا نحتاج إلى تتبع موقعك في الخلفية.',
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                color: isNight ? Colors.white70 : const Color(0xFF7B817C),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _prayerIcon(String name) {
    switch (name) {
      case 'الفجر':
        return Icons.nightlight_round;
      case 'الشروق':
        return Icons.wb_sunny_outlined;
      case 'الظهر':
        return Icons.wb_sunny;
      case 'العصر':
        return Icons.sunny_snowing;
      case 'المغرب':
        return Icons.wb_twilight;
      default:
        return Icons.nights_stay;
    }
  }
}

class QiblaPage extends StatefulWidget {
  const QiblaPage({super.key});

  @override
  State<QiblaPage> createState() => _QiblaPageState();
}

class _QiblaPageState extends State<QiblaPage> with WidgetsBindingObserver {
  // الإحداثيات الدقيقة للكعبة المشرفة.
  static const double _kaabaLatitude = 21.422487;
  static const double _kaabaLongitude = 39.826206;

  StreamSubscription<CompassEvent>? _compassSubscription;

  double? latitude;
  double? longitude;
  double? locationAccuracy;
  double? _deviceHeading;
  double? _qiblaBearing;
  double? _compassAccuracy;
  bool _loading = true;
  bool _locationServiceDisabled = false;
  String? _error;

  double? get _relativeQibla {
    final qibla = _qiblaBearing;
    final heading = _deviceHeading;
    if (qibla == null || heading == null) return null;
    return _normalizeAngle(qibla - heading);
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startCompass();
    _loadCurrentLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mounted) {
      _loadCurrentLocation();
    }
  }

  void _startCompass() {
    if (kIsWeb) return;

    _compassSubscription = FlutterCompass.events?.listen(
      (event) {
        final heading = event.heading;
        if (heading == null || !heading.isFinite) return;

        // تنعيم بسيط يمنع اهتزاز السهم بسبب ضجيج حساس المغناطيسية.
        final old = _deviceHeading;
        double smoothed = heading;
        if (old != null) {
          var delta = _normalizeSignedAngle(heading - old);
          smoothed = _normalizeAngle(old + delta * 0.22);
        }

        if (!mounted) return;
        setState(() {
          _deviceHeading = smoothed;
          _compassAccuracy = event.accuracy;
        });
      },
      onError: (_) {},
    );
  }

  Future<void> _loadCurrentLocation() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _locationServiceDisabled = true;
          _error = 'خدمة الموقع GPS متوقفة. فعّلي الموقع حتى نحسب القبلة من إحداثياتك الحالية.';
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'نحتاج صلاحية الموقع حتى نحدد اتجاه القبلة بدقة.';
        });
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (!mounted) return;
        setState(() {
          _loading = false;
          _error = 'صلاحية الموقع مرفوضة نهائيًا. افتحي إعدادات التطبيق وفعّلي الموقع الدقيق.';
        });
        return;
      }

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 0,
          ),
        ).timeout(const Duration(seconds: 12));
      } catch (_) {
        position = await Geolocator.getLastKnownPosition();
      }

      if (position == null) {
        throw Exception('NO_LOCATION_FIX');
      }

      final currentPosition = position;
      final bearing = _calculateQiblaBearing(
        currentPosition.latitude,
        currentPosition.longitude,
      );

      if (!mounted) return;
      setState(() {
        latitude = currentPosition.latitude;
        longitude = currentPosition.longitude;
        locationAccuracy = currentPosition.accuracy;
        _qiblaBearing = bearing;
        _loading = false;
        _locationServiceDisabled = false;
        _error = null;
      });

      final prefs = await SharedPreferences.getInstance();
      await prefs.setDouble('noor_qibla_latitude', currentPosition.latitude);
      await prefs.setDouble('noor_qibla_longitude', currentPosition.longitude);
      await prefs.setDouble('noor_qibla_accuracy', currentPosition.accuracy);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'تعذر تحديد موقعك بدقة. تأكدي من تشغيل GPS والموقع الدقيق ثم حاولي مرة أخرى.';
      });
    }
  }

  static double _calculateQiblaBearing(double lat, double lon) {
    final phi1 = _degToRad(lat);
    final phi2 = _degToRad(_kaabaLatitude);
    final deltaLambda = _degToRad(_kaabaLongitude - lon);

    final y = math.sin(deltaLambda) * math.cos(phi2);
    final x = math.cos(phi1) * math.sin(phi2) -
        math.sin(phi1) * math.cos(phi2) * math.cos(deltaLambda);

    return _normalizeAngle(math.atan2(y, x) * 180 / math.pi);
  }

  static double _degToRad(double degrees) => degrees * math.pi / 180;

  static double _normalizeAngle(double angle) {
    var value = angle % 360;
    if (value < 0) value += 360;
    return value;
  }

  static double _normalizeSignedAngle(double angle) {
    var value = _normalizeAngle(angle);
    if (value > 180) value -= 360;
    return value;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _compassSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final relative = _relativeQibla;
    final qibla = _qiblaBearing;
    final accuracy = locationAccuracy;
    final compassReady = _deviceHeading != null && !kIsWeb;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      appBar: AppBar(
        title: const Text('القبلة', style: TextStyle(fontWeight: FontWeight.w800)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'تحديث الموقع',
            onPressed: _loading ? null : _loadCurrentLocation,
            icon: const Icon(Icons.my_location_rounded),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadCurrentLocation,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: const Color(0xFF174A43),
                borderRadius: BorderRadius.circular(28),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x22000000),
                    blurRadius: 18,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    'اتجاه القبلة من موقعك الحالي',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    qibla == null ? '--°' : '${qibla.toStringAsFixed(1)}°',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const Text(
                    'السمت الحقيقي للقبلة من الشمال',
                    textDirection: TextDirection.rtl,
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: const Color(0xFFE8D7A8),
                            border: Border.all(color: Colors.white24, width: 8),
                          ),
                        ),
                        const Positioned(
                          top: 13,
                          child: Text('N', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        const Positioned(
                          bottom: 13,
                          child: Text('S', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        const Positioned(
                          left: 18,
                          child: Text('W', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        const Positioned(
                          right: 18,
                          child: Text('E', style: TextStyle(fontWeight: FontWeight.w900)),
                        ),
                        if (relative != null)
                          Transform.rotate(
                            angle: _degToRad(relative),
                            child: const Icon(
                              Icons.navigation_rounded,
                              size: 92,
                              color: Color(0xFF8E4B38),
                            ),
                          )
                        else
                          const Icon(
                            Icons.explore_rounded,
                            size: 82,
                            color: Color(0xFF8E4B38),
                          ),
                        Container(
                          width: 18,
                          height: 18,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF174A43),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    relative == null
                        ? 'حرّكي الهاتف بعد تحديد الموقع ليظهر اتجاه السهم'
                        : 'السهم يتجه للقبلة مع دوران الهاتف',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            if (_error != null)
              Card(
                color: const Color(0xFFFFF3E6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        _locationServiceDisabled
                            ? Icons.location_off_rounded
                            : Icons.warning_amber_rounded,
                        color: const Color(0xFF9A5B2B),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _error!,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.center,
                        style: const TextStyle(height: 1.6),
                      ),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () async {
                          if (_locationServiceDisabled) {
                            await Geolocator.openLocationSettings();
                          } else {
                            await Geolocator.openAppSettings();
                          }
                        },
                        icon: const Icon(Icons.settings_rounded),
                        label: Text(
                          _locationServiceDisabled ? 'فتح إعدادات GPS' : 'فتح إعدادات الموقع',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 14),
            Card(
              elevation: 1,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _QiblaInfoRow(
                      icon: Icons.gps_fixed_rounded,
                      title: 'إحداثيات GPS',
                      value: latitude == null || longitude == null
                          ? 'جاري التحديد...'
                          : '${latitude!.toStringAsFixed(6)}°, ${longitude!.toStringAsFixed(6)}°',
                    ),
                    const Divider(height: 24),
                    _QiblaInfoRow(
                      icon: Icons.my_location_rounded,
                      title: 'دقة الموقع',
                      value: accuracy == null
                          ? '--'
                          : '±${accuracy.toStringAsFixed(1)} متر',
                    ),
                    const Divider(height: 24),
                    _QiblaInfoRow(
                      icon: Icons.explore_rounded,
                      title: 'حساس البوصلة',
                      value: compassReady
                          ? (_compassAccuracy == null
                              ? 'يعمل'
                              : 'يعمل • دقة ${_compassAccuracy!.toStringAsFixed(0)}°')
                          : 'غير متاح على هذا الجهاز',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFE8F1EC),
                borderRadius: BorderRadius.circular(18),
              ),
              child: const Text(
                'نستخدم GPS للحصول على موقعك الحالي بدقة، ثم نحسب السمت الجغرافي للكعبة، ويُستخدم حساس البوصلة لمعرفة اتجاه الهاتف لحظيًا. للحصول على أفضل قراءة، أبقي الموقع الدقيق مفعّلًا وحرّكي الهاتف حركة رقم 8 إذا كانت البوصلة غير مستقرة.',
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF315A4C), height: 1.7, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QiblaInfoRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _QiblaInfoRow({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      textDirection: TextDirection.rtl,
      children: [
        CircleAvatar(
          radius: 20,
          backgroundColor: const Color(0xFFE8F1EC),
          foregroundColor: const Color(0xFF174A43),
          child: Icon(icon, size: 21),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(title, textDirection: TextDirection.rtl, style: const TextStyle(fontSize: 12, color: Color(0xFF6F746F))),
              const SizedBox(height: 2),
              Text(value, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: const TextStyle(fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      ],
    );
  }
}

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> with WidgetsBindingObserver {
  static const _countKey = 'noor_tasbeeh_count_v3';
  static const _targetKey = 'noor_tasbeeh_target_v3';
  static const _stateKey = 'noor_tasbeeh_state_v4';
  static const _oldCountKey = 'noor_tasbeeh_count_v2';
  static const _oldTargetKey = 'noor_tasbeeh_target_v2';
  int count = 0;
  int target = 33;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadSavedTasbeeh();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused || state == AppLifecycleState.detached) {
      _persistTasbeeh();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _persistTasbeeh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_countKey, count);
      await prefs.setInt(_targetKey, target);
      await prefs.setString(_stateKey, jsonEncode({'count': count, 'target': target}));
    } catch (_) {}
  }

  Future<void> _loadSavedTasbeeh() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var savedCount = prefs.getInt(_countKey) ?? prefs.getInt(_oldCountKey) ?? prefs.getInt('noor_tasbeeh_count') ?? 0;
      var savedTarget = prefs.getInt(_targetKey) ?? prefs.getInt(_oldTargetKey) ?? prefs.getInt('noor_tasbeeh_target') ?? 33;
      final rawState = prefs.getString(_stateKey);
      if (rawState != null) {
        try {
          final state = jsonDecode(rawState) as Map<String, dynamic>;
          savedCount = (state['count'] as num?)?.toInt() ?? savedCount;
          savedTarget = (state['target'] as num?)?.toInt() ?? savedTarget;
        } catch (_) {}
      }
      if (!prefs.containsKey(_countKey) && savedCount > 0) await prefs.setInt(_countKey, savedCount);
      if (!prefs.containsKey(_targetKey)) await prefs.setInt(_targetKey, [33,100,1000].contains(savedTarget) ? savedTarget : 33);
      if (!mounted) return;
      setState(() {
        count = savedCount < 0 ? 0 : savedCount;
        target = [33, 100, 1000].contains(savedTarget) ? savedTarget : 33;
        loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _increment() async {
    if (loading) return;
    final next = count + 1;
    if (mounted) setState(() => count = next);
    await _persistTasbeeh();
  }

  Future<void> _reset() async {
    if (loading) return;
    if (mounted) setState(() => count = 0);
    await _persistTasbeeh();
  }

  Future<void> _setTarget(int value) async {
    if (loading) return;
    if (mounted) setState(() => target = value);
    await _persistTasbeeh();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      appBar: AppBar(
        title: const Text('التسبيح الإلكتروني', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [
          IconButton(onPressed: loading ? null : _reset, icon: const Icon(Icons.restart_alt_rounded), tooltip: 'تصفير العداد'),
        ],
      ),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : Directionality(
              textDirection: TextDirection.rtl,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(gradient: const LinearGradient(colors: [Color(0xFF1B5B50), Color(0xFF123F38)]), borderRadius: BorderRadius.circular(26)),
                    child: const Column(children: [
                      Icon(Icons.auto_awesome_rounded, color: Color(0xFFF0CF7A), size: 28),
                      SizedBox(height: 7),
                      Text('عدادك محفوظ تلقائيًا', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w900)),
                      SizedBox(height: 5),
                      Text('اخرج وارجع للتطبيق أو أغلقه وافتحه، وسيبقى العدد كما هو.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFFD7E4DF), height: 1.5, fontSize: 12)),
                    ]),
                  ),
                  const SizedBox(height: 26),
                  Center(child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTap: _increment,
                    child: Container(
                      width: 245, height: 245,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFFE7EFE9), border: Border.all(color: const Color(0xFFB8CDBF), width: 8), boxShadow: const [BoxShadow(color: Color(0x18000000), blurRadius: 20, offset: Offset(0, 10))]),
                      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('$count', style: const TextStyle(fontSize: 62, fontWeight: FontWeight.w900, color: Color(0xFF173F38))),
                        const SizedBox(height: 4),
                        const Text('سبحان الله', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Color(0xFF47734A))),
                        const SizedBox(height: 9),
                        Text('من $target', style: const TextStyle(fontSize: 12, color: Color(0xFF7A827C))),
                        const SizedBox(height: 4),
                        const Text('اضغط للعد', style: TextStyle(fontSize: 11, color: Color(0xFF7A827C))),
                      ]),
                    ),
                  )),
                  const SizedBox(height: 22),
                  Wrap(alignment: WrapAlignment.center, spacing: 8, children: [33, 100, 1000].map((v) => ChoiceChip(label: Text('$v'), selected: target == v, onSelected: (_) => _setTarget(v))).toList()),
                  const SizedBox(height: 18),
                  FilledButton.icon(onPressed: _reset, icon: const Icon(Icons.restart_alt_rounded), label: const Text('تصفير العداد يدويًا', style: TextStyle(fontWeight: FontWeight.w900))),
                ],
              ),
            ),
    );
  }
}

class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  bool loading = true;
  List<File> files = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    try {
      final dir = await getApplicationDocumentsDirectory();
      final list = dir
          .listSync()
          .whereType<File>()
          .where((f) => RegExp(r'^noor_quran_\d+_\d+\.mp3$').hasMatch(f.uri.pathSegments.last))
          .toList()
        ..sort((a, b) => a.uri.pathSegments.last.compareTo(b.uri.pathSegments.last));
      if (mounted) setState(() { files = list; loading = false; });
    } catch (_) {
      if (mounted) setState(() { files = []; loading = false; });
    }
  }

  Map<String, int>? _parse(File file) {
    final name = file.uri.pathSegments.last.replaceFirst('noor_quran_', '').replaceFirst('.mp3', '');
    final parts = name.split('_');
    if (parts.length != 2) return null;
    final surah = int.tryParse(parts[0]);
    final read = int.tryParse(parts[1]);
    if (surah == null || read == null) return null;
    return {'surah': surah, 'read': read};
  }

  Future<void> _delete(File file) async {
    await file.delete();
    await _load();
  }

  String _size(File file) {
    try {
      final mb = file.lengthSync() / (1024 * 1024);
      return '${mb.toStringAsFixed(mb < 10 ? 1 : 0)} MB';
    } catch (_) { return 'ملف صوتي'; }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      appBar: AppBar(
        title: const Text('التنزيلات', style: TextStyle(fontWeight: FontWeight.w900)),
        centerTitle: true,
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh_rounded), tooltip: 'تحديث')],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: loading
            ? const Center(child: CircularProgressIndicator())
            : files.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(28),
                      child: Column(mainAxisSize: MainAxisSize.min, children: [
                        Container(width: 82, height: 82, decoration: BoxDecoration(color: const Color(0xFFE7EEE9), borderRadius: BorderRadius.circular(26)), child: const Icon(Icons.download_for_offline_rounded, size: 43, color: Color(0xFF173F35))),
                        const SizedBox(height: 16),
                        const Text('لا توجد تنزيلات بعد', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: Color(0xFF173F35))),
                        const SizedBox(height: 7),
                        const Text('عند تنزيل صوت أي سورة من شاشة القراء، ستظهر هنا ويمكنك إدارتها بدون إنترنت.', textAlign: TextAlign.center, style: TextStyle(height: 1.7, color: Color(0xFF6C756F))),
                      ]),
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: _load,
                    child: ListView.builder(
                      padding: const EdgeInsets.fromLTRB(14, 12, 14, 28),
                      itemCount: files.length,
                      itemBuilder: (_, i) {
                        final file = files[i];
                        final parsed = _parse(file);
                        final surah = parsed?['surah'];
                        final read = parsed?['read'];
                        final title = surah != null && surah >= 1 && surah <= surahNames.length ? surahNames[surah - 1] : 'سورة غير معروفة';
                        return Card(
                          margin: const EdgeInsets.only(bottom: 10),
                          elevation: 0,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(19), side: BorderSide(color: const Color(0xFFD4B36A).withOpacity(.28))),
                          child: ListTile(
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
                            leading: Container(width: 46, height: 46, decoration: BoxDecoration(color: const Color(0xFF173F35), borderRadius: BorderRadius.circular(15)), child: const Icon(Icons.audiotrack_rounded, color: Color(0xFFD4B36A))),
                            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
                            subtitle: Text('القارئ رقم ${read ?? '-'} • ${_size(file)} • محفوظ بدون إنترنت'),
                            trailing: IconButton(
                              tooltip: 'حذف التنزيل',
                              icon: const Icon(Icons.delete_outline_rounded),
                              onPressed: () async {
                                final ok = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
                                  title: const Text('حذف التنزيل'),
                                  content: Text('هل تريد حذف صوت سورة $title من الجهاز؟'),
                                  actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('إلغاء')), FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('حذف'))],
                                ));
                                if (ok == true) await _delete(file);
                              },
                            ),
                          ),
                        );
                      },
                    ),
                  ),
      ),
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المكتبة'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(leading: const Icon(Icons.menu_book, size: 35), title: const Text('القرآن الكريم', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('قراءة واستماع وحفظ الآيات', textDirection: TextDirection.rtl), onTap: () => _open(context, const QuranPage()))),
          Card(child: ListTile(leading: const Icon(Icons.favorite, size: 35), title: const Text('الأذكار', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('الصباح والمساء والصلاة والنوم والسفر والمنزل', textDirection: TextDirection.rtl), onTap: () => _open(context, const AdhkarPage()))),
          Card(child: ListTile(leading: const Icon(Icons.auto_awesome, size: 35), title: const Text('الأدعية', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('أدعية مختارة', textDirection: TextDirection.rtl), onTap: () => _open(context, const DuasPage()))),
          Card(child: ListTile(leading: const Icon(Icons.access_time_filled, size: 35), title: const Text('مواقيت الصلاة', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('اختر مدينتك', textDirection: TextDirection.rtl), onTap: () => _open(context, const PrayerTimesPage()))),
          Card(child: ListTile(leading: const Icon(Icons.explore, size: 35), title: const Text('القبلة', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => _open(context, const QiblaPage()))),
          Card(child: ListTile(leading: const Icon(Icons.mosque_rounded, size: 35), title: const Text('مناسك الحج والعمرة', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('دليل واسع خطوة بخطوة', textDirection: TextDirection.rtl), onTap: () => _open(context, const HajjGuidePage()))),
          Card(child: ListTile(leading: const Icon(Icons.download_rounded, size: 35), title: const Text('التنزيلات', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('إدارة السور الصوتية المحفوظة بدون إنترنت', textDirection: TextDirection.rtl), onTap: () => _open(context, const DownloadsPage()))),
          Card(child: ListTile(leading: const Icon(Icons.touch_app, size: 35), title: const Text('التسبيح الإلكتروني', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => _open(context, const TasbihPage()))),
        ],
      ),
    );
  }
}


class HajjGuidePage extends StatefulWidget {
  const HajjGuidePage({super.key});

  @override
  State<HajjGuidePage> createState() => _HajjGuidePageState();
}

class _HajjGuidePageState extends State<HajjGuidePage> {
  bool isUmrah = false;
  int step = 0;
  int counter = 0;

  static const hajjSteps = <_HajjStep>[
    _HajjStep('الإحرام والنية', 'الإحرام ليس مجرد لباس؛ بل دخول في النسك بنيةٍ صحيحة والتزامٍ بأحكامه. يبدأ الحاج من الميقات الذي يمر به بحسب طريقه، فيغتسل ويتطيب قبل الإحرام إن تيسر، ثم يلبس ما يناسب أحكام إحرامه وينوي النسك ويلبي.', ['تحديد نوع النسك قبل الإحرام: تمتع أو قران أو إفراد بحسب ما يختاره الحاج وما يوافق الفتوى التي يتبعها.', 'الإحرام من الميقات المحدد للطريق، وعدم تجاوز الميقات بلا إحرام لمن أراد النسك.', 'الإكثار من التلبية والذكر، والابتعاد عن محظورات الإحرام.', 'المرأة تحرم في لباسها الساتر المعتاد، مع مراعاة أحكام النقاب والقفازين أثناء الإحرام وفق الفتوى المعتبرة.'], 'الإحرام', Icons.checkroom_rounded),
    _HajjStep('دخول مكة والطواف', 'بعد الوصول إلى المسجد الحرام يبدأ الحاج بما شرعه الله له من أعمال النسك. والطواف سبعة أشواط حول الكعبة، يبدأ كل شوط من جهة الحجر الأسود وينتهي إليها، مع المحافظة على الخشوع وعدم إيذاء الناس.', ['الطواف سبعة أشواط كاملة.', 'جعل الكعبة عن اليسار أثناء الطواف.', 'الدعاء والذكر بما تيسر دون التزام دعاء مخصوص لكل شوط.', 'المحافظة على الطهارة وستر العورة، ومراعاة الزحام وعدم التدافع.', 'يُسن عند محاذاة الحجر الأسود استلامه أو الإشارة إليه عند العجز عن الوصول إليه دون أذية.'], 'الطواف', Icons.sync_rounded),
    _HajjStep('الصلاة بعد الطواف والسعي', 'بعد الطواف يصلي الحاج ركعتين إن تيسر ذلك من غير أذية ولا مزاحمة، ثم يتجه إلى المسعى لأداء السعي في موضعه من النسك.', ['لا تجعل الصلاة خلف مقام إبراهيم سببًا في تعطيل حركة الناس؛ صلِّ حيث يتيسر في المسجد.', 'بعد الطواف اشرب من زمزم إن تيسر، ثم توجه إلى السعي.', 'يبدأ السعي من الصفا وينتهي بالمروة، وليس العكس.'], 'الطواف', Icons.mosque_rounded),
    _HajjStep('السعي بين الصفا والمروة', 'السعي سبعة أشواط: من الصفا إلى المروة شوط، ومن المروة إلى الصفا شوط آخر. يبدأ بالصفا وينتهي بالمروة. وفي المسار توجد العلامات التي تبين موضع الإسراع للرجال في الموضع المعروف.', ['عند الصفا يستقبل الحاج القبلة ويذكر الله ويدعو بما تيسر.', 'يمشي حتى المروة، وهذا هو الشوط الأول، ثم يعود إلى الصفا للشوط الثاني.', 'يكمل سبعة أشواط، وآخرها يكون عند المروة.', 'المرأة تمشي مشيًا معتادًا ولا تشرع لها هيئة الإسراع الخاصة بالرجال.', 'لا يوجد دعاء ملزم لكل شوط؛ الدعاء بما تيسر مشروع.'], 'السعي', Icons.swap_horiz_rounded),
    _HajjStep('يوم عرفة', 'الوقوف بعرفة هو أعظم أركان الحج. يكون الحاج في عرفة في الوقت المشروع، فيكثر من التوحيد والدعاء والذكر والتوبة، ويحافظ على وقته فيما ينفعه.', ['الوقوف بعرفة يكون في اليوم التاسع من ذي الحجة وفي الوقت المعتبر شرعًا.', 'الإكثار من الدعاء والاستغفار والتوحيد والصلاة على النبي ﷺ.', 'الحرص على الراحة وشرب الماء وتجنب التعرض المفرط للحرارة.', 'عدم الانشغال بالتصوير أو الجدال على حساب العبادة والسكينة.', 'من فاته الوقوف بعرفة فقد فاته الحج؛ لذلك يجب الالتزام بتعليمات الحملات والجهات المنظمة.'], 'عرفة', Icons.landscape_rounded),
    _HajjStep('المبيت بمزدلفة', 'بعد الإفاضة من عرفة يتوجه الحاج إلى مزدلفة، ويذكر الله ويبيت فيها بحسب ما تقتضيه أحكام النسك والرخص الشرعية. يجمع الحاج بين الذكر والراحة والاستعداد لأعمال يوم النحر.', ['الالتزام بتوجيهات التفويج والنقل وعدم تعريض النفس أو الآخرين للخطر.', 'جمع الحصى للرمي من المواضع المباحة، مع عدم التكلف في اختيار حجم معين ما دام ضمن القدر المشروع.', 'الإكثار من الذكر والاستغفار والدعاء.', 'الاستفادة من الرخص الشرعية لمن له عذر وفق فتوى موثوقة.'], 'مزدلفة', Icons.nightlight_round),
    _HajjStep('يوم النحر ورمي جمرة العقبة', 'يوم النحر يوم عظيم تتعدد فيه أعمال الحج. من أهمها رمي جمرة العقبة، ثم ما يتبع ذلك من أعمال الهدي والحلق أو التقصير وطواف الإفاضة بحسب ترتيب النسك وحال الحاج.', ['رمي جمرة العقبة بسبع حصيات، واحدة بعد أخرى.', 'التقيد بالوقت والتنظيم الرسمي للرمي وعدم التدافع.', 'لا يشرع إيذاء الجمرة أو ضربها؛ المقصود إسقاط الحصاة في الحوض بالطريقة المعتبرة.', 'بعد الرمي يكمل الحاج بقية أعمال يوم النحر وفق نوع نسكه.'], 'الجمرات', Icons.adjust_rounded),
    _HajjStep('الحلق أو التقصير', 'الحلق أو التقصير من أعمال التحلل. للرجل الحلق أو التقصير، والحلق أفضل عند كثير من أهل العلم، والمرأة تقصر من شعرها بالقدر المشروع ولا تحلقه.', ['الرجل يحلق أو يقصر شعر الرأس.', 'المرأة تقصر من أطراف شعرها ولا تحلق.', 'ترتيب الأعمال قد يختلف في بعض الصور، ولذلك ينبغي اتباع ترتيب النسك والفتوى المعتبرة.', 'بعد التحلل الأول تتغير بعض أحكام الإحرام، ويبقى ما يتعلق بالتحلل الكامل حتى استكمال الأعمال اللازمة.'], 'الحلق والتقصير', Icons.content_cut_rounded),
    _HajjStep('طواف الإفاضة', 'طواف الإفاضة من أركان الحج، ويؤدى بعد عرفة وما يتصل بها من أعمال يوم النحر في الوقت المشروع. لا ينبغي الاستعجال بطريقة تؤدي إلى أذية الناس أو ترك ركن.', ['الطواف سبعة أشواط.', 'يُراعى فيه ما يراعى في الطواف من ستر العورة والطهارة بحسب الحكم الشرعي المتبع.', 'بعد طواف الإفاضة يؤدي الحاج ما يلزمه من سعي إذا كان السعي باقيًا عليه بحسب نوع نسكه.', 'العودة إلى منى وأيام التشريق تكون وفق برنامج الحملة والتعليمات المنظمة.'], 'الإفاضة', Icons.circle_outlined),
    _HajjStep('أيام التشريق والرمي', 'يقضي الحاج أيام التشريق في منى لمن لزمه ذلك، ويرمي الجمرات في الأيام المقررة وفق النسك والوقت الشرعي. المقصود أداء العبادة بسكينة والتزام التنظيم.', ['رمي الجمرات الثلاث في الأيام التي يشرع فيها الرمي، بحسب أحكام النسك.', 'كل جمرة ترمى بسبع حصيات، واحدة بعد أخرى.', 'يستحب الدعاء بعد الجمرة الصغرى والوسطى في الموضع الذي يتيسر فيه دون أذية، ولا يطول بما يعرقل حركة الناس.', 'الجمرة الكبرى لا يقف عندها للدعاء على الصورة نفسها بعد الرمي.', 'الالتزام بتعليمات التفويج ومواعيد الحملة أمر مهم للسلامة.'], 'الجمرات', Icons.stacked_bar_chart_rounded),
    _HajjStep('طواف الوداع', 'عند إرادة مغادرة مكة بعد إتمام الحج، يطوف الحاج طواف الوداع لمن يلزمه، ثم يغادر، مع مراعاة أحكام الحيض والنفاس وسائر الأعذار التي لها أحكام خاصة.', ['الوداع يكون من آخر أعمال الحاج في مكة عند المغادرة.', 'إذا احتاج الحاج إلى أمر عارض بعد الطواف فلا يلزمه إعادة الطواف لمجرد كل حركة يسيرة، وتفاصيل ذلك تُرجع إلى المفتي عند الحاجة.', 'من كانت لها عذر شرعي خاص تسأل أهل العلم عن الحكم الخاص بها.', 'لا تجعل الوداع سباقًا أو موضع تدافع؛ المقصود العبادة والسكينة.'], 'الوداع', Icons.logout_rounded),
  ];

  static const umrahSteps = <_HajjStep>[
    _HajjStep('الإحرام من الميقات', 'يبدأ المعتمر الإحرام من الميقات المناسب لطريقه، ثم ينوي العمرة ويلبي، ويدخل في أحكام الإحرام حتى يتم نسكه.', ['الاغتسال والتنظف والتطيب قبل الإحرام إن تيسر.', 'لبس ما يوافق أحكام الإحرام ثم النية والتلبية.', 'تجنب محظورات الإحرام حتى نهاية النسك.', 'المرأة تحرم في لباسها الساتر المعتاد مع مراعاة الأحكام الشرعية الخاصة بالنقاب والقفازين.'], 'الإحرام', Icons.checkroom_rounded),
    _HajjStep('الطواف', 'يطوف المعتمر حول الكعبة سبعة أشواط، يبدأ من جهة الحجر الأسود وينتهي إليها، ويجعل الكعبة عن يساره.', ['سبعة أشواط كاملة.', 'الذكر والدعاء بما تيسر دون تخصيص دعاء ثابت لكل شوط.', 'تجنب التدافع ورفع الصوت وإيذاء الطائفين.', 'استلام الحجر أو الإشارة إليه عند القدرة دون مزاحمة أو أذية.'], 'الطواف', Icons.sync_rounded),
    _HajjStep('السعي', 'بعد الطواف يسعى المعتمر بين الصفا والمروة سبعة أشواط، يبدأ بالصفا وينتهي بالمروة.', ['الشوط من الصفا إلى المروة واحد، والعودة شوط ثانٍ.', 'الدعاء والذكر بما تيسر.', 'الرجال يسرعون في الموضع المعروف بين العلامتين، والنساء يمشين مشيًا معتادًا.', 'إكمال سبعة أشواط كاملة.'], 'السعي', Icons.swap_horiz_rounded),
    _HajjStep('الحلق أو التقصير', 'بعد السعي يتحلل المعتمر بالحلق أو التقصير للرجل، وبالتقصير للمرأة، وبذلك تتم العمرة.', ['الرجل يحلق أو يقصر، والحلق أفضل عند كثير من أهل العلم.', 'المرأة تقصر من شعرها ولا تحلق.', 'بعد إتمام التحلل تنتهي أحكام الإحرام الخاصة بالعمرة.'], 'الحلق والتقصير', Icons.content_cut_rounded),
  ];

  List<_HajjStep> get steps => isUmrah ? umrahSteps : hajjSteps;

  void _selectStep(int value) => setState(() { step = value; counter = 0; });
  void _next() { if (step < steps.length - 1) setState(() { step++; counter = 0; }); }
  void _previous() { if (step > 0) setState(() { step--; counter = 0; }); }

  @override
  Widget build(BuildContext context) {
    final current = steps[step];
    final isTawaf = current.visual == 'الطواف' || current.visual == 'الإفاضة' || current.visual == 'الوداع';
    final isSai = current.visual == 'السعي';
    final isJamarat = current.visual == 'الجمرات';
    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      appBar: AppBar(title: const Text('مناسك الحج والعمرة', style: TextStyle(fontWeight: FontWeight.w900)), centerTitle: true),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 30),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [Color(0xFF123D32), Color(0xFF0C2D25)]),
                borderRadius: BorderRadius.circular(25),
                border: Border.all(color: const Color(0xFFD4B36A).withOpacity(.55)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Row(children: [
                  Container(width: 50, height: 50, decoration: BoxDecoration(color: const Color(0xFFD4B36A), borderRadius: BorderRadius.circular(16)), child: const Icon(Icons.mosque_rounded, color: Color(0xFF123D32), size: 28)),
                  const SizedBox(width: 12),
                  const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('دليل المناسك خطوة بخطوة', style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w900)),
                    SizedBox(height: 4),
                    Text('شرح تعليمي موسع مع نقاط عملية وتذكيرات مهمة', style: TextStyle(color: Color(0xFFD9E6DF), fontSize: 11.5)),
                  ])),
                ]),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: ChoiceChip(label: const Text('الحج'), selected: !isUmrah, onSelected: (_) => setState(() { isUmrah = false; step = 0; counter = 0; }), selectedColor: const Color(0xFFD4B36A), labelStyle: TextStyle(color: !isUmrah ? const Color(0xFF123D32) : Colors.white, fontWeight: FontWeight.w900), backgroundColor: Colors.white.withOpacity(.10))),
                  const SizedBox(width: 10),
                  Expanded(child: ChoiceChip(label: const Text('العمرة'), selected: isUmrah, onSelected: (_) => setState(() { isUmrah = true; step = 0; counter = 0; }), selectedColor: const Color(0xFFD4B36A), labelStyle: TextStyle(color: isUmrah ? const Color(0xFF123D32) : Colors.white, fontWeight: FontWeight.w900), backgroundColor: Colors.white.withOpacity(.10))),
                ]),
              ]),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: const Color(0xFFFFFCF5), borderRadius: BorderRadius.circular(19), border: Border.all(color: const Color(0xFFE4DCCB))),
              child: const Text('تنبيه علمي: هذا الدليل تعليمي لتقريب ترتيب الأعمال وشرحها، وليس فتوى شخصية. بعض التفاصيل تختلف باختلاف نوع النسك والقدرة والعذر والمذهب أو الفتوى المعتمدة؛ لذلك تُرجع المسائل الخاصة إلى عالم موثوق أو الجهة الرسمية المنظمة للنسك.', style: TextStyle(height: 1.75, fontSize: 12.5, color: Color(0xFF5F665F))),
            ),
            const SizedBox(height: 14),
            SizedBox(
              height: 78,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: steps.length,
                separatorBuilder: (_, __) => const SizedBox(width: 8),
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => _selectStep(i),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 180),
                    width: 112,
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(color: i == step ? const Color(0xFF173F35) : Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: i == step ? const Color(0xFF173F35) : const Color(0xFFE3DDCF))),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Icon(steps[i].icon, size: 21, color: i == step ? const Color(0xFFD4B36A) : const Color(0xFF7A5A2D)),
                      const SizedBox(height: 5),
                      Text(steps[i].title, textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: i == step ? Colors.white : const Color(0xFF173F35))),
                    ]),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Card(
              clipBehavior: Clip.antiAlias,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
              child: Column(children: [
                SizedBox(height: 250, width: double.infinity, child: CustomPaint(painter: _HajjVisualPainter(type: current.visual, progress: counter))),
                Padding(
                  padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                    Row(children: [
                      Expanded(child: Text(current.title, style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w900, color: Color(0xFF173F35)))),
                      Text('${step + 1} / ${steps.length}', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF7A806E))),
                    ]),
                    const SizedBox(height: 10),
                    Text(current.description, style: const TextStyle(fontSize: 15.5, height: 1.85, color: Color(0xFF303934))),
                    const SizedBox(height: 18),
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: const Color(0xFFF4F0E6), borderRadius: BorderRadius.circular(18)),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        const Text('ما الذي تفعله في هذه المرحلة؟', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: Color(0xFF173F35))),
                        const SizedBox(height: 10),
                        for (final item in current.details)
                          Padding(padding: const EdgeInsets.only(bottom: 9), child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            const Padding(padding: EdgeInsets.only(top: 5), child: Icon(Icons.check_circle_rounded, size: 15, color: Color(0xFF5E7B69))),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item, style: const TextStyle(fontSize: 13, height: 1.7, color: Color(0xFF4A524D)))),
                          ])),
                      ]),
                    ),
                    if (isTawaf || isSai || isJamarat) ...[
                      const SizedBox(height: 16),
                      Row(children: [
                        Expanded(child: Text(isJamarat ? 'الرميات المسجلة: $counter / 7' : 'الأشواط: $counter / 7', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16))),
                        FilledButton.icon(
                          onPressed: () => setState(() { final max = isJamarat ? 7 : 7; if (counter < max) counter++; }),
                          icon: const Icon(Icons.add),
                          label: Text(isJamarat ? 'تسجيل رمية' : 'تسجيل شوط'),
                        ),
                      ]),
                      if (counter >= 7) const Padding(padding: EdgeInsets.only(top: 9), child: Text('اكتمل العداد التفاعلي ✓', style: TextStyle(color: Color(0xFF47734A), fontWeight: FontWeight.w900))),
                    ],
                  ]),
                ),
              ]),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: const Color(0xFFEAF1EC), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFB9CDBF))),
              child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.info_outline_rounded, color: Color(0xFF173F35)),
                SizedBox(width: 10),
                Expanded(child: Text('لا توجد أدعية ثابتة خاصة بكل شوط من الطواف أو السعي. ادعُ الله بما تيسر من خيري الدنيا والآخرة، ومن الأدعية القرآنية الموجودة في قسم الأدعية داخل التطبيق.', style: TextStyle(height: 1.7, fontSize: 12.5, color: Color(0xFF3F5048)))),
              ]),
            ),
            const SizedBox(height: 14),
            Row(children: [
              Expanded(child: OutlinedButton.icon(onPressed: step == 0 ? null : _previous, icon: const Icon(Icons.arrow_back), label: const Text('السابق'))),
              const SizedBox(width: 10),
              Expanded(child: FilledButton.icon(onPressed: step == steps.length - 1 ? null : _next, icon: const Icon(Icons.arrow_forward), label: const Text('التالي'))),
            ]),
          ],
        ),
      ),
    );
  }
}

class _HajjStep {
  final String title;
  final String description;
  final List<String> details;
  final String visual;
  final IconData icon;
  const _HajjStep(this.title, this.description, this.details, this.visual, this.icon);
}

class _HajjVisualPainter extends CustomPainter {
  final String type;
  final int progress;
  const _HajjVisualPainter({required this.type, required this.progress});

  static const _green = Color(0xFF173F35);
  static const _deep = Color(0xFF0E2B25);
  static const _gold = Color(0xFFD4B25F);
  static const _sand = Color(0xFFE9D9B8);
  static const _paper = Color(0xFFF7F4EC);
  static const _stone = Color(0xFFB7A98E);

  void _fill(Paint p, Color c) {
    p.style = PaintingStyle.fill;
    p.color = c;
  }

  void _stroke(Paint p, Color c, double width) {
    p.style = PaintingStyle.stroke;
    p.strokeWidth = width;
    p.strokeCap = StrokeCap.round;
    p.strokeJoin = StrokeJoin.round;
    p.color = c;
  }

  void _drawArch(Canvas canvas, Size size, {double left = .10, double right = .90}) {
    final p = Paint();
    _stroke(p, _gold.withOpacity(.55), 2.2);
    final path = Path()
      ..moveTo(size.width * left, size.height * .88)
      ..lineTo(size.width * left, size.height * .34)
      ..quadraticBezierTo(size.width * .50, size.height * .02, size.width * right, size.height * .34)
      ..lineTo(size.width * right, size.height * .88);
    canvas.drawPath(path, p);
  }

  void _drawGround(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFFE6DDCB);
    canvas.drawRect(Rect.fromLTWH(0, size.height * .82, size.width, size.height * .18), p);
    final line = Paint();
    _stroke(line, const Color(0xFFC8BCA5).withOpacity(.55), 1);
    for (var i = 0; i < 9; i++) {
      final x = size.width * i / 8;
      canvas.drawLine(Offset(x, size.height * .82), Offset(x + 28, size.height), line);
    }
  }

  void _drawKaaba(Canvas canvas, Size size, {double scale = 1}) {
    final cx = size.width / 2;
    final cy = size.height * .48;
    final w = 94 * scale;
    final h = 94 * scale;
    final p = Paint();
    _fill(p, const Color(0xFF202020));
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 18 * scale), width: w, height: h), p);

    final roof = Path()
      ..moveTo(cx - w / 2, cy - h / 2 + 18 * scale)
      ..lineTo(cx, cy - h / 2 - 4 * scale)
      ..lineTo(cx + w / 2, cy - h / 2 + 18 * scale)
      ..close();
    _fill(p, const Color(0xFF292929));
    canvas.drawPath(roof, p);

    _fill(p, _gold);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy - 2 * scale), width: w, height: 8 * scale), p);
    canvas.drawRect(Rect.fromCenter(center: Offset(cx, cy + 31 * scale), width: w, height: 4 * scale), p);

    _fill(p, const Color(0xFF121212));
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + 23 * scale, cy + 24 * scale), width: 16 * scale, height: 31 * scale), p);
    _fill(p, const Color(0xFF5B4632));
    canvas.drawRect(Rect.fromCenter(center: Offset(cx + 23 * scale, cy + 10 * scale), width: 19 * scale, height: 3 * scale), p);
  }

  void _drawTawaf(Canvas canvas, Size size) {
    _drawGround(canvas, size);
    _drawKaaba(canvas, size, scale: .92);
    final center = Offset(size.width / 2, size.height * .52);
    final ring = Paint();
    for (var i = 0; i < 3; i++) {
      _stroke(ring, const Color(0xFF8B7655).withOpacity(.24), 10);
      canvas.drawOval(Rect.fromCenter(center: center, width: 220 + i * 38, height: 128 + i * 24), ring);
    }
    final n = progress.clamp(0, 7);
    final dot = Paint();
    for (var i = 0; i < n; i++) {
      final a = -math.pi / 2 + i * (2 * math.pi / 7);
      final x = center.dx + 112 * math.cos(a);
      final y = center.dy + 65 * math.sin(a);
      _fill(dot, i == n - 1 ? _gold : _green);
      canvas.drawCircle(Offset(x, y), i == n - 1 ? 9 : 6, dot);
    }
  }

  void _drawSai(Canvas canvas, Size size) {
    _drawGround(canvas, size);
    final line = Paint();
    _stroke(line, const Color(0xFF9A845E).withOpacity(.45), 15);
    final path = Path()
      ..moveTo(size.width * .16, size.height * .62)
      ..quadraticBezierTo(size.width * .50, size.height * .18, size.width * .84, size.height * .62);
    canvas.drawPath(path, line);

    final p = Paint();
    _fill(p, _green);
    canvas.drawCircle(Offset(size.width * .14, size.height * .62), 23, p);
    canvas.drawCircle(Offset(size.width * .86, size.height * .62), 23, p);

    _drawArch(canvas, size, left: .30, right: .70);
    final tp = TextPainter(
      text: const TextSpan(text: 'الصفا                 المروة', style: TextStyle(color: _green, fontSize: 15, fontWeight: FontWeight.w900)),
      textDirection: TextDirection.rtl,
    )..layout(maxWidth: size.width);
    tp.paint(canvas, Offset((size.width - tp.width) / 2, size.height * .73));

    final n = progress.clamp(0, 7);
    final dot = Paint();
    for (var i = 0; i < n; i++) {
      _fill(dot, i == n - 1 ? _gold : _green);
      canvas.drawCircle(Offset(size.width * .35 + i * size.width * .05, size.height * .88), 5, dot);
    }
  }

  void _drawIhram(Canvas canvas, Size size) {
    _drawGround(canvas, size);
    final p = Paint();
    _fill(p, Colors.white);
    final body = Path()
      ..moveTo(size.width * .35, size.height * .78)
      ..lineTo(size.width * .40, size.height * .42)
      ..lineTo(size.width * .50, size.height * .30)
      ..lineTo(size.width * .60, size.height * .42)
      ..lineTo(size.width * .65, size.height * .78)
      ..close();
    canvas.drawPath(body, p);
    _fill(p, const Color(0xFFD5C7AB));
    canvas.drawCircle(Offset(size.width * .50, size.height * .23), 34, p);
    _stroke(p, _gold, 3);
    canvas.drawLine(Offset(size.width * .41, size.height * .43), Offset(size.width * .59, size.height * .43), p);
    _drawArch(canvas, size, left: .20, right: .80);
    _fill(p, _green);
    canvas.drawCircle(Offset(size.width * .50, size.height * .10), 5, p);
  }

  void _drawArafat(Canvas canvas, Size size) {
    final sky = Paint()..shader = const LinearGradient(colors: [Color(0xFFEDE5D4), Color(0xFFF8F4EA)]).createShader(Offset.zero & size);
    canvas.drawRect(Offset.zero & size, sky);
    _drawGround(canvas, size);
    final hill = Path()
      ..moveTo(size.width * .05, size.height * .78)
      ..quadraticBezierTo(size.width * .32, size.height * .35, size.width * .55, size.height * .76)
      ..quadraticBezierTo(size.width * .76, size.height * .45, size.width * .95, size.height * .78)
      ..close();
    final p = Paint()..color = _sand;
    canvas.drawPath(hill, p);
    _fill(p, _green);
    canvas.drawRect(Rect.fromLTWH(size.width * .35, size.height * .57, size.width * .30, size.height * .18), p);
    _fill(p, Colors.white);
    canvas.drawRect(Rect.fromLTWH(size.width * .37, size.height * .53, size.width * .26, size.height * .07), p);
    _drawArch(canvas, size, left: .08, right: .92);
  }

  void _drawMuzdalifah(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF253A36);
    canvas.drawRect(Offset.zero & size, p);
    _fill(p, const Color(0xFFF1E7D0));
    canvas.drawCircle(Offset(size.width * .78, size.height * .20), 27, p);
    final stars = Paint()..color = _gold.withOpacity(.75);
    for (var i = 0; i < 13; i++) {
      final x = size.width * (.08 + ((i * 37) % 83) / 100);
      final y = size.height * (.08 + ((i * 19) % 48) / 100);
      canvas.drawCircle(Offset(x, y), 1.7, stars);
    }
    _drawGround(canvas, size);
    for (var i = 0; i < 4; i++) {
      final x = size.width * (.18 + i * .21);
      _fill(p, Colors.white);
      canvas.drawPath(Path()
        ..moveTo(x - 32, size.height * .79)
        ..lineTo(x, size.height * .57)
        ..lineTo(x + 32, size.height * .79)
        ..close(), p);
      _fill(p, _green);
      canvas.drawRect(Rect.fromLTWH(x - 23, size.height * .70, 46, 28), p);
    }
  }

  void _drawJamarat(Canvas canvas, Size size) {
    _drawGround(canvas, size);
    final p = Paint();
    final xs = [size.width * .22, size.width * .50, size.width * .78];
    for (var i = 0; i < xs.length; i++) {
      _fill(p, i == 1 ? _green : const Color(0xFF6F6B61));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: Offset(xs[i], size.height * .52), width: 46, height: 125), const Radius.circular(22)), p);
      _fill(p, _gold);
      canvas.drawOval(Rect.fromCenter(center: Offset(xs[i], size.height * .40), width: 24, height: 42), p);
    }
    final n = progress.clamp(0, 21);
    for (var i = 0; i < n; i++) {
      final x = size.width * (.10 + ((i * 13) % 80) / 100);
      final y = size.height * (.25 + ((i * 17) % 52) / 100);
      _fill(p, const Color(0xFF8D806B));
      canvas.drawCircle(Offset(x, y), 3.5, p);
    }
  }

  void _drawHair(canvas, Size size) {
    _drawGround(canvas, size);
    final p = Paint();
    _fill(p, const Color(0xFFB98A5A));
    canvas.drawCircle(Offset(size.width * .50, size.height * .36), 58, p);
    _fill(p, const Color(0xFFF0C49C));
    canvas.drawCircle(Offset(size.width * .50, size.height * .39), 43, p);
    _fill(p, const Color(0xFF2E2119));
    canvas.drawArc(Rect.fromCenter(center: Offset(size.width * .50, size.height * .36), width: 91, height: 72), math.pi, math.pi, false, p);
    _stroke(p, _gold, 4);
    canvas.drawArc(Rect.fromCenter(center: Offset(size.width * .50, size.height * .40), width: 130, height: 110), math.pi * .15, math.pi * .70, false, p);
    _drawArch(canvas, size, left: .22, right: .78);
  }

  @override
  void paint(Canvas canvas, Size size) {
    // A refined, self-contained vector illustration: no network images and no asset paths.
    final bg = Paint()..color = _paper;
    canvas.drawRect(Offset.zero & size, bg);

    if (type == 'الطواف' || type == 'الإفاضة' || type == 'الوداع') {
      _drawTawaf(canvas, size);
    } else if (type == 'السعي') {
      _drawSai(canvas, size);
    } else if (type == 'الإحرام') {
      _drawIhram(canvas, size);
    } else if (type == 'عرفة') {
      _drawArafat(canvas, size);
    } else if (type == 'مزدلفة') {
      _drawMuzdalifah(canvas, size);
    } else if (type == 'الجمرات') {
      _drawJamarat(canvas, size);
    } else if (type == 'الحلق والتقصير') {
      _drawHair(canvas, size);
    } else {
      _drawIhram(canvas, size);
    }

    final badge = Paint()..color = _green.withOpacity(.92);
    canvas.drawRRect(
      RRect.fromRectAndRadius(Rect.fromLTWH(14, 14, 108, 30), const Radius.circular(15)),
      badge,
    );
    final label = TextPainter(
      text: TextSpan(text: 'دليل تعليمي', style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
      textDirection: TextDirection.rtl,
    )..layout();
    label.paint(canvas, Offset(68 - label.width / 2, 23));
  }

  @override
  bool shouldRepaint(covariant _HajjVisualPainter oldDelegate) =>
      oldDelegate.type != type || oldDelegate.progress != progress;
}


class TajweedColoredPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const TajweedColoredPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<TajweedColoredPage> createState() => _TajweedColoredPageState();
}

class _TajweedColoredPageState extends State<TajweedColoredPage> {
  static const _editionUrl = 'https://raw.githubusercontent.com/quran-ws/quran-tajweed/main/editions/uthmani-hafs.json';
  static const _annotationsUrl = 'https://raw.githubusercontent.com/quran-ws/quran-tajweed/main/packages/annotations/uthmani-hafs.json';

  Map<String, dynamic>? _edition;
  Map<String, dynamic>? _annotations;
  String? _error;

  static const _defaultColor = Color(0xFF26332F);
  static const _colors = <String, Color>{
    'madd': Color(0xFFC94B4B),
    'qalqalah': Color(0xFF4267B2),
    'noon': Color(0xFF8A4DA8),
    'tanween': Color(0xFF8A4DA8),
    'ghunnah': Color(0xFF2C8A66),
    'ikhfa': Color(0xFF8A4DA8),
    'idgham': Color(0xFF2C8A66),
    'iqlab': Color(0xFFD77A27),
    'meem': Color(0xFF2F7C8A),
    'tafkhim': Color(0xFF9A6B28),
    'tarqiq': Color(0xFF607D68),
    'raa': Color(0xFF9A6B28),
    'lam': Color(0xFF5D6470),
    'mutamathilain': Color(0xFF6D4AA8),
    'mutajanisain': Color(0xFF6D4AA8),
    'mutqaribain': Color(0xFF6D4AA8),
  };

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final responses = await Future.wait([
        http.get(Uri.parse(_editionUrl)),
        http.get(Uri.parse(_annotationsUrl)),
      ]);
      if (responses[0].statusCode != 200 || responses[1].statusCode != 200) {
        throw Exception('تعذر تحميل بيانات التجويد');
      }
      final edition = jsonDecode(responses[0].body) as Map<String, dynamic>;
      final annotations = jsonDecode(responses[1].body) as Map<String, dynamic>;
      if (!mounted) return;
      setState(() {
        _edition = edition;
        _annotations = annotations;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = 'تعذر تحميل التجويد الملون الآن. تحقق من الإنترنت ثم حاول مرة أخرى.');
    }
  }

  Color _ruleColor(String ruleId) {
    final id = ruleId.toLowerCase();
    for (final entry in _colors.entries) {
      if (id.contains(entry.key)) return entry.value;
    }
    return _defaultColor;
  }

  List<TextSpan> _buildAyahSpans(String ref, String text) {
    final raw = _annotations?['spans'];
    final ruleIds = (_annotations?['ruleIds'] as List?)?.map((e) => '$e').toList() ?? <String>[];
    final packed = raw is Map ? raw[ref] : null;
    final marks = List<int?>.filled(text.length, null);
    if (packed is List) {
      for (final item in packed) {
        if (item is! List || item.length < 3) continue;
        final start = int.tryParse('${item[0]}');
        final end = int.tryParse('${item[1]}');
        final ruleIndex = int.tryParse('${item[2]}');
        if (start == null || end == null || ruleIndex == null || ruleIndex < 0 || ruleIndex >= ruleIds.length) continue;
        for (var i = start; i < end && i < marks.length; i++) {
          if (i >= 0) marks[i] = ruleIndex;
        }
      }
    }

    final spans = <TextSpan>[];
    var buffer = StringBuffer();
    Color? currentColor;

    void flush() {
      if (buffer.isEmpty) return;
      spans.add(TextSpan(
        text: buffer.toString(),
        style: TextStyle(color: currentColor ?? _defaultColor),
      ));
      buffer = StringBuffer();
    }

    bool isCombining(String ch) {
      if (ch.isEmpty) return false;
      final code = ch.runes.first;
      return (code >= 0x064B && code <= 0x065F) ||
          (code >= 0x0670 && code <= 0x0670) ||
          code == 0x06D6 || code == 0x06D7 || code == 0x06D8 ||
          code == 0x06D9 || code == 0x06DA || code == 0x06DB ||
          code == 0x06DC || code == 0x06DF || code == 0x06E0 ||
          code == 0x06E1 || code == 0x06E2 || code == 0x06E3 ||
          code == 0x06E4 || code == 0x06E7 || code == 0x06E8 ||
          code == 0x06EA || code == 0x06EB || code == 0x06EC ||
          code == 0x06ED;
    }

    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      final ruleIndex = marks[i];
      final nextColor = ruleIndex == null ? null : _ruleColor(ruleIds[ruleIndex]);
      final effectiveColor = isCombining(ch) ? currentColor : nextColor;
      if (effectiveColor != currentColor) flush();
      currentColor = effectiveColor;
      buffer.write(ch);
    }
    flush();
    return spans;
  }

  @override
  Widget build(BuildContext context) {
    final ayahs = (_edition?['ayahs'] as Map?)?.entries
        .where((entry) => entry.key.toString().startsWith('${widget.surahNumber}:'))
        .toList()
      ?..sort((a, b) => int.parse(a.key.toString().split(':').last).compareTo(int.parse(b.key.toString().split(':').last)));

    return Scaffold(
      backgroundColor: const Color(0xFFF1EBDD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF173F38),
        foregroundColor: Colors.white,
        title: Text('التجويد الملون • ${widget.surahName}', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16)),
        actions: [
          IconButton(onPressed: _loadData, tooltip: 'تحديث', icon: const Icon(Icons.refresh_rounded)),
        ],
      ),
      body: _error != null
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.cloud_off_rounded, size: 46, color: Color(0xFF7A3E3E)), const SizedBox(height: 12), Text(_error!, textAlign: TextAlign.center), const SizedBox(height: 14), FilledButton.icon(onPressed: _loadData, icon: const Icon(Icons.refresh_rounded), label: const Text('إعادة المحاولة'))])))
          : _edition == null || _annotations == null
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.fromLTRB(12, 12, 12, 30),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(color: const Color(0xFFFFFCF4), borderRadius: BorderRadius.circular(22), border: Border.all(color: const Color(0xFFE0D4BD)), boxShadow: const [BoxShadow(color: Color(0x14000000), blurRadius: 14, offset: Offset(0, 6))]),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        const Text('التجويد الملون الحقيقي', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Color(0xFF173F38))),
                        const SizedBox(height: 5),
                        const Text('تلوين مبني على مواضع أحكام التجويد المعلَّمة في بيانات متخصصة، مع إبقاء نص الآية كما هو دون إعادة كتابة الأحرف.', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 11.5, height: 1.6, color: Color(0xFF6D665C))),
                        const SizedBox(height: 12),
                        Wrap(spacing: 8, runSpacing: 7, children: const [
                          _TajweedLegend(color: Color(0xFFC94B4B), label: 'المد'),
                          _TajweedLegend(color: Color(0xFF2C8A66), label: 'الإدغام'),
                          _TajweedLegend(color: Color(0xFF8A4DA8), label: 'النون والتنوين'),
                          _TajweedLegend(color: Color(0xFF4267B2), label: 'القلقلة'),
                          _TajweedLegend(color: Color(0xFF2F7C8A), label: 'الميم'),
                          _TajweedLegend(color: Color(0xFF9A6B28), label: 'التفخيم/الراء'),
                        ]),
                      ]),
                    ),
                    const SizedBox(height: 12),
                    if (ayahs != null)
                      ...ayahs.map((entry) {
                        final ref = entry.key.toString();
                        final text = entry.value.toString();
                        final ayah = ref.split(':').last;
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          padding: const EdgeInsets.fromLTRB(15, 14, 15, 12),
                          decoration: BoxDecoration(color: const Color(0xFFFFFCF4), borderRadius: BorderRadius.circular(18), border: Border.all(color: const Color(0xFFE2D6BE))),
                          child: Column(children: [
                            RichText(textDirection: TextDirection.rtl, textAlign: TextAlign.center, text: TextSpan(style: const TextStyle(fontFamily: 'Arial', fontSize: 25, height: 2.15, fontWeight: FontWeight.w600), children: _buildAyahSpans(ref, text))),
                            const SizedBox(height: 8),
                            Container(width: 32, height: 32, alignment: Alignment.center, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFE7EFE9)), child: Text(ayah, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: Color(0xFF315E53)))),
                          ]),
                        );
                      }),
                  ],
                ),
    );
  }
}

class _TajweedLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _TajweedLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
        decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Container(width: 9, height: 9, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.w800, color: color)),
        ]),
      );
}
