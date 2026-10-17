import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
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
  520, 523, 526, 528, 531, 534, 537, 539, 542, 544,
  546, 549, 551, 553, 554, 556, 558, 560, 562, 564,
  566, 568, 570, 572, 574, 575, 577, 578, 580, 582,
  583, 585, 586, 587, 589, 590, 591, 593, 594, 595,
  596, 597, 598, 599, 600, 601, 602, 603
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
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F4EC),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 760;
            final horizontal = wide ? 48.0 : 20.0;

            return Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1050),
                child: CustomScrollView(
                  slivers: [
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 8),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFF173F35),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.menu_book_rounded,
                                color: Color(0xFFE8D7A8),
                                size: 26,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    'نور القرآن',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      color: Color(0xFF173F35),
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  SizedBox(height: 2),
                                  Text(
                                    'رفيقك في تلاوة القرآن والذكر',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(
                                      color: Color(0xFF6F746D),
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              tooltip: 'الإعدادات',
                              onPressed: () => _open(context, const LibraryPage()),
                              icon: const Icon(Icons.settings_outlined),
                              color: const Color(0xFF173F35),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 0),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              begin: Alignment.topRight,
                              end: Alignment.bottomLeft,
                              colors: [Color(0xFF173F35), Color(0xFF245B4D)],
                            ),
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF173F35).withOpacity(.16),
                                blurRadius: 22,
                                offset: const Offset(0, 10),
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
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(.12),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: const Text(
                                      'وردك اليومي',
                                      textDirection: TextDirection.rtl,
                                      style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.auto_awesome_rounded, color: Color(0xFFE8D7A8), size: 24),
                                ],
                              ),
                              const SizedBox(height: 22),
                              const Text(
                                'وَرَتِّلِ الْقُرْآنَ تَرْتِيلًا',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 25,
                                  height: 1.7,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'سورة المزمل • 4',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(color: Color(0xFFD5E0D9), fontSize: 12),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                height: 48,
                                child: FilledButton.icon(
                                  onPressed: () => _open(context, const QuranPage()),
                                  icon: const Icon(Icons.arrow_back_rounded),
                                  label: const Text('ابدأ التلاوة'),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: const Color(0xFFE8D7A8),
                                    foregroundColor: const Color(0xFF173F35),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                    textStyle: const TextStyle(fontWeight: FontWeight.w800),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 0),
                      sliver: SliverToBoxAdapter(
                        child: Row(
                          textDirection: TextDirection.rtl,
                          children: [
                            Text(
                              'الوصول السريع',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: scheme.onSurface),
                            ),
                            const Spacer(),
                            Text(
                              'كل ما تحتاجه',
                              textDirection: TextDirection.rtl,
                              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontal, 12, horizontal, 0),
                      sliver: SliverGrid(
                        delegate: SliverChildListDelegate([
                          _ModernFeatureCard(
                            icon: Icons.menu_book_rounded,
                            title: 'القرآن الكريم',
                            subtitle: 'تلاوة وتصفح المصحف',
                            color: const Color(0xFFE4EFE9),
                            iconColor: const Color(0xFF1E5A4A),
                            onTap: () => _open(context, const QuranPage()),
                          ),
                          _ModernFeatureCard(
                            icon: Icons.wb_sunny_rounded,
                            title: 'الأذكار',
                            subtitle: 'صباحًا ومساءً',
                            color: const Color(0xFFF2E9D5),
                            iconColor: const Color(0xFF8B6B2F),
                            onTap: () => _open(context, const AdhkarPage()),
                          ),
                          _ModernFeatureCard(
                            icon: Icons.auto_awesome_rounded,
                            title: 'الأدعية',
                            subtitle: 'أدعية مختارة',
                            color: const Color(0xFFE9E5F2),
                            iconColor: const Color(0xFF66558A),
                            onTap: () => _open(context, const DuasPage()),
                          ),
                          _ModernFeatureCard(
                            icon: Icons.access_time_filled_rounded,
                            title: 'مواقيت الصلاة',
                            subtitle: 'مواقيتك اليومية',
                            color: const Color(0xFFE6EDF2),
                            iconColor: const Color(0xFF41677C),
                            onTap: () => _open(context, const PrayerTimesPage()),
                          ),
                          _ModernFeatureCard(
                            icon: Icons.explore_rounded,
                            title: 'القبلة',
                            subtitle: 'اتجاه القبلة',
                            color: const Color(0xFFE8EFE8),
                            iconColor: const Color(0xFF47734A),
                            onTap: () => _open(context, const QiblaPage()),
                          ),
                          _ModernFeatureCard(
                            icon: Icons.touch_app_rounded,
                            title: 'التسبيح',
                            subtitle: 'عداد التسبيح',
                            color: const Color(0xFFF1E6E1),
                            iconColor: const Color(0xFF8A5A49),
                            onTap: () => _open(context, const TasbihPage()),
                          ),
                        ]),
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: wide ? 3 : 2,
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: wide ? 1.75 : 1.35,
                        ),
                      ),
                    ),
                    SliverPadding(
                      padding: EdgeInsets.fromLTRB(horizontal, 24, horizontal, 30),
                      sliver: SliverToBoxAdapter(
                        child: Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(22),
                            border: Border.all(color: const Color(0xFFE6E1D5)),
                          ),
                          child: const Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                textDirection: TextDirection.rtl,
                                children: [
                                  Icon(Icons.format_quote_rounded, color: Color(0xFFB49455), size: 25),
                                  SizedBox(width: 8),
                                  Text(
                                    'آية اليوم',
                                    textDirection: TextDirection.rtl,
                                    style: TextStyle(color: Color(0xFF173F35), fontWeight: FontWeight.w800, fontSize: 16),
                                  ),
                                ],
                              ),
                              SizedBox(height: 12),
                              Text(
                                'إِنَّ مَعَ الْعُسْرِ يُسْرًا',
                                textDirection: TextDirection.rtl,
                                textAlign: TextAlign.right,
                                style: TextStyle(color: Color(0xFF2C332F), fontSize: 22, height: 1.8, fontWeight: FontWeight.w700),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'سورة الشرح • 6',
                                textDirection: TextDirection.rtl,
                                style: TextStyle(color: Color(0xFF777C76), fontSize: 12),
                              ),
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

class QuranReaderPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
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

  @override
  void initState() {
    super.initState();

    currentPage =
        surahStartPages[widget.surahNumber - 1];
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
              Future<void>.delayed(const Duration(milliseconds: 250), _installMushafInteractions);
            },
          ),
        )
        ..addJavaScriptChannel(
          'AyahChannel',
          onMessageReceived: (message) {
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
            }
          },
        );
    }

    _loadMushafPage(currentPage);
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
    _lastHighlightedAyah = '${widget.surahNumber}:${timing.ayah}';
    if (kIsWeb) return;
    controller.runJavaScript(
      "setNoorAyahHighlight('${widget.surahNumber}', '${timing.ayah}');",
    );
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

  bool? _lastLandscape;

  void _syncMushafOrientation(bool isLandscape) {
    if (_lastLandscape == isLandscape) return;
    _lastLandscape = isLandscape;

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted || kIsWeb) return;
      try {
        await controller.runJavaScript(
          "if(window.setNoorOrientation){window.setNoorOrientation(${isLandscape ? 'true' : 'false'});}",
        );
      } catch (_) {}
    });
  }

  @override
  Widget build(BuildContext context) {
    final pageText = 'الصفحة $currentPage من 604';
    final juzText = 'الجزء ${_juz(currentPage)}';
    final currentSurahTitle = 'سورة $_currentSurahName';
    final isBookmarked = _bookmarkPage == currentPage;

    final shellBackground =
        _isNightMode ? const Color(0xFF121917) : const Color(0xFFF4F0E6);
    final cardBackground =
        _isNightMode ? const Color(0xFF1A2421) : const Color(0xFFFFFCF5);
    final borderColor =
        _isNightMode ? const Color(0xFF31413B) : const Color(0xFFE1D8C7);
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    _syncMushafOrientation(isLandscape);

    return Scaffold(
      backgroundColor: shellBackground,
      // الوضع الأفقي للمصحف = قراءة ملء الشاشة بدون أشرطة إضافية.
      appBar: isLandscape
          ? null
          : PreferredSize(
        preferredSize: Size.fromHeight(isLandscape ? 62 : 82),
        child: Container(
          decoration: const BoxDecoration(
            color: Color(0xFF174A43),
            boxShadow: [
              BoxShadow(
                color: Color(0x33000000),
                blurRadius: 16,
                offset: Offset(0, 5),
              ),
            ],
          ),
          child: SafeArea(
            bottom: false,
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        IconButton(
                          tooltip: 'رجوع',
                          onPressed: () => Navigator.of(context).maybePop(),
                          icon: const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                          ),
                        ),
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                currentSurahTitle,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: isLandscape ? 17 : 20,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$pageText  •  $juzText',
                                style: const TextStyle(
                                  color: Color(0xFFD8E7DF),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: isBookmarked
                              ? 'إزالة العلامة'
                              : 'حفظ موضع القراءة',
                          onPressed: () {
                            setState(() {
                              _bookmarkPage =
                                  isBookmarked ? null : currentPage;
                            });
                            _saveReaderPreferences();
                            _showMessage(
                              isBookmarked
                                  ? 'تمت إزالة علامة القراءة'
                                  : 'تم حفظ الصفحة $currentPage كعلامة قراءة',
                            );
                          },
                          icon: Icon(
                            isBookmarked
                                ? Icons.bookmark_rounded
                                : Icons.bookmark_border_rounded,
                            color: const Color(0xFFF2D58A),
                          ),
                        ),
                        PopupMenuButton<String>(
                          tooltip: 'خيارات القارئ',
                          icon: const Icon(
                            Icons.more_vert_rounded,
                            color: Colors.white,
                          ),
                          onSelected: (value) {
                            if (value == 'jump') {
                              _showGoToPageDialog();
                            } else if (value == 'bookmark') {
                              if (_bookmarkPage != null) {
                                _changePage(_bookmarkPage!);
                              } else {
                                _showMessage('لا توجد علامة محفوظة بعد');
                              }
                            } else if (value == 'night') {
                              _toggleNightMode();
                            } else if (value == 'text_size') {
                              _showMushafTextSizeDialog();
                            } else if (value == 'saved') {
                              _showSavedAyahs();
                            } else if (value == 'surahs') {
                              _showReaderTools();
                            }
                          },
                          itemBuilder: (context) => [
                            const PopupMenuItem(
                              value: 'jump',
                              child: Row(
                                children: [
                                  Icon(Icons.find_in_page_rounded),
                                  SizedBox(width: 12),
                                  Text('الانتقال إلى صفحة'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'bookmark',
                              child: Row(
                                children: [
                                  Icon(Icons.bookmark_rounded),
                                  SizedBox(width: 12),
                                  Text('العودة إلى العلامة'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'night',
                              child: Row(
                                children: [
                                  Icon(Icons.dark_mode_rounded),
                                  SizedBox(width: 12),
                                  Expanded(child: Text('الوضع الليلي')),
                                  Switch(
                                    value: _isNightMode,
                                    onChanged: null,
                                  ),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'text_size',
                              child: Row(
                                children: [
                                  Icon(Icons.text_fields_rounded),
                                  SizedBox(width: 12),
                                  Text('حجم خط المصحف'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'saved',
                              child: Row(
                                children: [
                                  Icon(Icons.bookmarks_rounded),
                                  SizedBox(width: 12),
                                  Text('الآيات المحفوظة'),
                                ],
                              ),
                            ),
                            const PopupMenuItem(
                              value: 'surahs',
                              child: Row(
                                children: [
                                  Icon(Icons.swap_horiz_rounded),
                                  SizedBox(width: 12),
                                  Text('السورة السابقة / التالية'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                LinearProgressIndicator(
                  minHeight: 3,
                  value: currentPage / 604,
                  backgroundColor: const Color(0x335E8B7C),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    Color(0xFFF2D58A),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Container(
        color: shellBackground,
        child: Padding(
          padding: EdgeInsets.zero,
          child: Container(
            decoration: BoxDecoration(
              color: cardBackground,
              borderRadius: BorderRadius.circular(isLandscape ? 0 : 24),
              border: Border.all(
                color: borderColor,
                width: 1.2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _isNightMode
                      ? const Color(0x55000000)
                      : const Color(0x1A000000),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: isLandscape ? 0 : 7),
                    child: Container(
                      decoration: BoxDecoration(
                        color: _isNightMode
                            ? const Color(0xFF151B19)
                            : const Color(0xFFFFFEFA),
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(
                          color: _isNightMode
                              ? const Color(0xFF34453E)
                              : const Color(0xFFE4DCCB),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: _isNightMode
                                ? const Color(0x33000000)
                                : const Color(0x10000000),
                            blurRadius: 12,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(isLandscape ? 0 : 17),
                        child: kIsWeb && _isNightMode
                            ? ColorFiltered(
                                colorFilter: const ColorFilter.matrix([
                                  -0.8, 0, 0, 0, 204,
                                  0, -0.8, 0, 0, 204,
                                  0, 0, -0.8, 0, 204,
                                  0, 0, 0, 1, 0,
                                ]),
                                child: WebViewWidget(
                                   key: ValueKey('mushaf-webview-\${isLandscape ? "landscape" : "portrait"}'),
                                   controller: controller,
                                 ),
                              )
                            : WebViewWidget(controller: controller),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: isLandscape
          ? null
          : SafeArea(
        top: false,
        child: Container(
          padding: EdgeInsets.fromLTRB(
            isLandscape ? 4 : 8,
            3,
            isLandscape ? 4 : 8,
            isLandscape ? 4 : 7,
          ),
          color: shellBackground,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (_selectedRead != null) _buildAudioBar(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 7,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: cardBackground,
                  borderRadius: BorderRadius.circular(21),
                  border: Border.all(color: borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: _isNightMode
                          ? const Color(0x33000000)
                          : const Color(0x14000000),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(15),
                        onTap: _showGoToPageDialog,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 3),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.menu_book_rounded,
                                    size: 15,
                                    color: _isNightMode
                                        ? const Color(0xFFF2D58A)
                                        : const Color(0xFF174A43),
                                  ),
                                  const SizedBox(width: 5),
                                  Text(
                                    'مصحف المدينة • اسحب للتصفح',
                                    style: TextStyle(
                                      color: _isNightMode
                                          ? Colors.white
                                          : const Color(0xFF174A43),
                                      fontSize: 12,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                '$pageText  •  $juzText',
                                style: TextStyle(
                                  color: _isNightMode
                                      ? const Color(0xFFB9C7C1)
                                      : const Color(0xFF766F63),
                                  fontSize: 10,
                                ),
                              ),
                              if (isBookmarked)
                                const Padding(
                                  padding: EdgeInsets.only(top: 2),
                                  child: Text(
                                    '★ علامة القراءة محفوظة',
                                    style: TextStyle(
                                      color: Color(0xFFB58A2A),
                                      fontSize: 9,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
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
void dispose() {
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
      final savedPage =
          prefs.getInt('noor_last_read_page_${widget.surahNumber}');
      final bookmark = prefs.getInt('noor_bookmark_page');
      final night = prefs.getBool('noor_night_mode') ?? false;
      final mushafScale =
          prefs.getDouble('noor_mushaf_text_scale') ?? 1.0;
      final saved = prefs.getStringList('noor_saved_ayahs') ?? <String>[];
      final favoriteReciters = prefs.getStringList('noor_favorite_reciters') ?? <String>[];
      final lastReciter = prefs.getInt('noor_last_reciter_id');

      if (!mounted) return;
      setState(() {
        _lastReadPage = savedPage;
        _bookmarkPage = bookmark ?? currentPage;
        _isNightMode = night;
        _mushafTextScale = mushafScale.clamp(0.85, 1.40).toDouble();
        _savedAyahs
          ..clear()
          ..addAll(saved);
        _favoriteReciterIds
          ..clear()
          ..addAll(favoriteReciters.map((e) => int.tryParse(e)).whereType<int>());
        _lastReciterId = lastReciter;
        _prefsLoaded = true;
      });

      if (savedPage != null && savedPage >= 1 && savedPage <= 604 && savedPage != currentPage) {
        await _changePage(savedPage, forceReload: true);
      } else if (kIsWeb && night) {
        await _loadMushafPage(currentPage);
      }
    } catch (_) {
      _prefsLoaded = true;
    }
  }

  Future<void> _saveReaderPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(
        'noor_last_read_page_${widget.surahNumber}',
        currentPage,
      );
      if (_bookmarkPage == null) {
        await prefs.remove('noor_bookmark_page');
      } else {
        await prefs.setInt('noor_bookmark_page', _bookmarkPage!);
      }
      await prefs.setBool('noor_night_mode', _isNightMode);
      await prefs.setDouble('noor_mushaf_text_scale', _mushafTextScale);
      await prefs.setStringList('noor_saved_ayahs', _savedAyahs.toList()..sort());
      await prefs.setStringList('noor_favorite_reciters', _favoriteReciterIds.map((e) => e.toString()).toList()..sort());
      if (_lastReciterId == null) {
        await prefs.remove('noor_last_reciter_id');
      } else {
        await prefs.setInt('noor_last_reciter_id', _lastReciterId!);
      }
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
<meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no, viewport-fit=cover">
<style>
html,body{margin:0;padding:0;width:100%;height:100%;background:${_isNightMode ? '#151B19' : '#f7f1df'};font-family:Arial,sans-serif;overflow:hidden;touch-action:pan-y}
#page{width:100%;min-height:100%;display:block;transition:opacity .15s ease;touch-action:none;user-select:none;-webkit-user-select:none;transform-origin:center top;will-change:transform}
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
 function clearHighlight(){document.querySelectorAll('.ayahPolygon').forEach(e=>e.classList.remove('noor-active'));}
 function highlight(surah,ayah){clearHighlight(); document.querySelectorAll('.ayahPolygon').forEach(e=>{if(e.getAttribute('surah')==String(surah)&&e.getAttribute('ayah')==String(ayah)) e.classList.add('noor-active');});}
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
           window.setNoorOrientation=function(isLandscape){
             document.documentElement.style.width='100%';
             document.body.style.width='100%';
             pageEl.style.width='100%';
             pageEl.style.margin='0';
             pageEl.style.maxWidth='none';
             var svgNow=pageEl.querySelector('svg');
             if(svgNow){
               svgNow.style.width='100%';
               svgNow.style.height='auto';
               svgNow.style.maxWidth='none';
               svgNow.style.display='block';
             }
             document.body.style.overflow='hidden';
             panX=0; panY=0; applyZoom();
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
          .replaceFirst('%PAGE%', '$page');

      await controller.loadHtmlString(webHtml);
      _loadedPage = page;
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
            document.querySelectorAll('.ayahPolygon').forEach(function(el) {
              var match = el.getAttribute('surah') === String(surah) &&
                          el.getAttribute('ayah') === String(ayah);
              if (match) {
                el.style.setProperty('fill', '#7652d6', 'important');
                el.style.setProperty('fill-opacity', '0.35', 'important');
              } else {
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
           window.setNoorOrientation=function(isLandscape){
             document.documentElement.style.width='100%';
             document.body.style.width='100%';
             pageEl.style.width='100%';
             pageEl.style.margin='0';
             pageEl.style.maxWidth='none';
             var svgNow=pageEl.querySelector('svg');
             if(svgNow){
               svgNow.style.width='100%';
               svgNow.style.height='auto';
               svgNow.style.maxWidth='none';
               svgNow.style.display='block';
             }
             document.body.style.overflow='hidden';
             panX=0; panY=0; applyZoom();
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
          .replaceAll('%TEXT_SCALE%', _mushafTextScale.toStringAsFixed(3))
          .replaceAll(
            '%IS_LANDSCAPE%',
            MediaQuery.of(context).orientation == Orientation.landscape ? 'true' : 'false',
          ),
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
  final categories = const ['الصباح', 'المساء', 'بعد الصلاة', 'النوم'];

  final List<List<AdhkarItem>> data = const [
    [
      AdhkarItem('ذكر', 'أصبحنا وأصبح الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.', 1),
      AdhkarItem('التسبيح', 'سبحان الله وبحمده.', 100),
      AdhkarItem('الاستغفار', 'أستغفر الله وأتوب إليه.', 100),
      AdhkarItem('التوحيد', 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.', 10),
      AdhkarItem('الصلاة على النبي', 'اللهم صل وسلم وبارك على نبينا محمد.', 10),
    ],
    [
      AdhkarItem('ذكر', 'أمسينا وأمسى الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له.', 1),
      AdhkarItem('التسبيح', 'سبحان الله وبحمده.', 100),
      AdhkarItem('الاستغفار', 'أستغفر الله وأتوب إليه.', 100),
      AdhkarItem('التوحيد', 'لا إله إلا الله وحده لا شريك له، له الملك وله الحمد وهو على كل شيء قدير.', 10),
    ],
    [
      AdhkarItem('الاستغفار', 'أستغفر الله.', 3),
      AdhkarItem('التسبيح', 'سبحان الله.', 33),
      AdhkarItem('الحمد', 'الحمد لله.', 33),
      AdhkarItem('التكبير', 'الله أكبر.', 34),
    ],
    [
      AdhkarItem('دعاء النوم', 'باسمك اللهم أموت وأحيا.', 1),
      AdhkarItem('التسبيح', 'سبحان الله.', 33),
      AdhkarItem('الحمد', 'الحمد لله.', 33),
      AdhkarItem('التكبير', 'الله أكبر.', 34),
    ],
  ];

  @override
  Widget build(BuildContext context) {
    final items = data[category];
    return Scaffold(
      appBar: AppBar(title: const Text('الأذكار'), centerTitle: true),
      body: Column(
        children: [
          SizedBox(
            height: 58,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              itemCount: categories.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: ChoiceChip(
                  label: Text(categories[index]),
                  selected: category == index,
                  onSelected: (_) => setState(() => category = index),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (_, index) => _DhikrCard(item: items[index]),
            ),
          ),
        ],
      ),
    );
  }
}

class _DhikrCard extends StatefulWidget {
  final AdhkarItem item;
  const _DhikrCard({required this.item});

  @override
  State<_DhikrCard> createState() => _DhikrCardState();
}

class _DhikrCardState extends State<_DhikrCard> {
  late int remaining;

  @override
  void initState() {
    super.initState();
    remaining = widget.item.count;
  }

  @override
  Widget build(BuildContext context) {
    final done = remaining == 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: done ? null : () => setState(() => remaining--),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(widget.item.title, textDirection: TextDirection.rtl, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(widget.item.text, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.8)),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(done ? 'تم ✓' : 'المتبقي: $remaining', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    onPressed: () => setState(() => remaining = widget.item.count),
                    icon: const Icon(Icons.refresh),
                    label: const Text('إعادة'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class DuasPage extends StatelessWidget {
  const DuasPage({super.key});

  static const List<Map<String, String>> duas = [
    {'title': 'دعاء ربنا آتنا', 'text': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.'},
    {'title': 'دعاء الهداية', 'text': 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ.'},
    {'title': 'دعاء العلم', 'text': 'رَبِّ زِدْنِي عِلْمًا.'},
    {'title': 'دعاء الوالدين', 'text': 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا.'},
    {'title': 'دعاء التيسير', 'text': 'رَبِّ اشْرَحْ لِي صَدْرِي، وَيَسِّرْ لِي أَمْرِي.'},
    {'title': 'دعاء المغفرة', 'text': 'رَبَّنَا اغْفِرْ لَنَا وَلِإِخْوَانِنَا الَّذِينَ سَبَقُونَا بِالْإِيمَانِ.'},
    {'title': 'دعاء الثبات', 'text': 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الأدعية'), centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: duas.length,
        itemBuilder: (_, index) {
          final dua = duas[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 10),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(dua['title']!, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 10),
                  Text(dua['text']!, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.9)),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      tooltip: 'نسخ الدعاء',
                      icon: const Icon(Icons.copy),
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: dua['text']!));
                        if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الدعاء')));
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
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
    _loadSavedLocation();
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

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

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
        error = 'تعذر تحديد الموقع. تأكدي من تشغيل GPS والإنترنت ثم حاولي مرة أخرى.';
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
                    OutlinedButton.icon(
                      onPressed: loading ? null : _refreshLocationAndTimes,
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('حاول مرة أخرى'),
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

class QiblaPage extends StatelessWidget {
  const QiblaPage({super.key});

  static const cityBearing = <String, double>{
    'سامراء': 196.0,
    'بغداد': 196.5,
    'الموصل': 179.0,
    'كركوك': 191.0,
    'أربيل': 192.0,
    'السليمانية': 202.0,
    'دهوك': 169.0,
    'النجف': 207.0,
    'كربلاء': 203.0,
    'البصرة': 225.0,
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('القبلة'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Icon(Icons.explore, size: 110),
          const SizedBox(height: 20),
          const Text('اتجاه القبلة التقريبي حسب المدينة', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 18),
          ...cityBearing.entries.map((e) => Card(child: ListTile(title: Text(e.key, textDirection: TextDirection.rtl), trailing: Text('${e.value.toStringAsFixed(1)}°')))),
          const SizedBox(height: 12),
          const Text('هذه نسخة بدون حساس البوصلة. لاحقًا يمكن إضافة بوصلة حية عند إضافة حزمة المستشعرات.', textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class TasbihPage extends StatefulWidget {
  const TasbihPage({super.key});

  @override
  State<TasbihPage> createState() => _TasbihPageState();
}

class _TasbihPageState extends State<TasbihPage> {
  int count = 0;
  int target = 33;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التسبيح'), centerTitle: true, actions: [IconButton(onPressed: () => setState(() => count = 0), icon: const Icon(Icons.refresh))]),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('سبحان الله', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold)),
            const SizedBox(height: 18),
            Text('$count', style: const TextStyle(fontSize: 64, fontWeight: FontWeight.bold)),
            Text('من $target', textDirection: TextDirection.rtl),
            const SizedBox(height: 30),
            GestureDetector(
              onTap: () => setState(() => count = (count + 1) % (target + 1)),
              child: Container(
                width: 190,
                height: 190,
                decoration: BoxDecoration(shape: BoxShape.circle, color: Theme.of(context).colorScheme.primaryContainer),
                child: const Center(child: Icon(Icons.touch_app, size: 70)),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              children: [33, 100, 1000].map((v) => ChoiceChip(label: Text('$v'), selected: target == v, onSelected: (_) => setState(() { target = v; count = 0; }))).toList(),
            ),
          ],
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
          Card(child: ListTile(leading: const Icon(Icons.favorite, size: 35), title: const Text('الأذكار', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('الصباح والمساء وبعد الصلاة والنوم', textDirection: TextDirection.rtl), onTap: () => _open(context, const AdhkarPage()))),
          Card(child: ListTile(leading: const Icon(Icons.auto_awesome, size: 35), title: const Text('الأدعية', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('أدعية مختارة', textDirection: TextDirection.rtl), onTap: () => _open(context, const DuasPage()))),
          Card(child: ListTile(leading: const Icon(Icons.access_time_filled, size: 35), title: const Text('مواقيت الصلاة', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), subtitle: const Text('اختر مدينتك', textDirection: TextDirection.rtl), onTap: () => _open(context, const PrayerTimesPage()))),
          Card(child: ListTile(leading: const Icon(Icons.explore, size: 35), title: const Text('القبلة', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => _open(context, const QiblaPage()))),
          Card(child: ListTile(leading: const Icon(Icons.touch_app, size: 35), title: const Text('التسبيح الإلكتروني', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)), onTap: () => _open(context, const TasbihPage()))),
        ],
      ),
    );
  }
}
