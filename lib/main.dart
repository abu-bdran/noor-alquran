import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const NoorAlQuranApp());
}

class NoorAlQuranApp extends StatelessWidget {
  const NoorAlQuranApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'نور القرآن',
      locale: const Locale('ar'),
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0F766E),
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
            icon: Icon(Icons.library_books_outlined),
            selectedIcon: Icon(Icons.library_books),
            label: 'المزيد',
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('نور القرآن'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF673AB7), Color(0xFF8E63C7)],
              ),
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'بِسْمِ اللهِ الرَّحْمٰنِ الرَّحِيمِ',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'نور القرآن — قرآن، أذكار، أدعية ومواقيت الصلاة',
                  textDirection: TextDirection.rtl,
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _HomeFeatureCard(
            icon: Icons.menu_book,
            title: 'القرآن الكريم',
            subtitle: 'قراءة، استماع، تضليل الآية، تفسير وتنزيل',
            onTap: () => _open(context, const QuranPage()),
          ),
          _HomeFeatureCard(
            icon: Icons.wb_sunny,
            title: 'أذكار الصباح والمساء',
            subtitle: 'أذكار مع عدّاد للتكرار',
            onTap: () => _open(context, const AdhkarPage()),
          ),
          _HomeFeatureCard(
            icon: Icons.auto_awesome,
            title: 'الأدعية',
            subtitle: 'أدعية القرآن والأنبياء والأدعية اليومية',
            onTap: () => _open(context, const DuasPage()),
          ),
          _HomeFeatureCard(
            icon: Icons.mosque,
            title: 'الحج والعمرة',
            subtitle: 'دليل المناسك خطوة بخطوة مع الأذكار والأدعية',
            onTap: () => _open(context, const HajjUmrahPage()),
          ),
          _HomeFeatureCard(
            icon: Icons.access_time_filled,
            title: 'مواقيت الصلاة',
            subtitle: 'الفجر والشروق والظهر والعصر والمغرب والعشاء',
            onTap: () => _open(context, const PrayerTimesPage()),
          ),
          Row(
            children: [
              Expanded(
                child: _SmallFeatureCard(
                  icon: Icons.explore,
                  title: 'القبلة',
                  onTap: () => _open(context, const QiblaPage()),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallFeatureCard(
                  icon: Icons.touch_app,
                  title: 'التسبيح',
                  onTap: () => _open(context, const TasbihPage()),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _HomeFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeFeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        leading: CircleAvatar(
          backgroundColor: Theme.of(context).colorScheme.primaryContainer,
          child: Icon(icon),
        ),
        title: Text(title, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, textDirection: TextDirection.rtl),
        trailing: const Icon(Icons.arrow_forward_ios, size: 17),
        onTap: onTap,
      ),
    );
  }
}

class _SmallFeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SmallFeatureCard({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18),
          child: Column(
            children: [
              Icon(icon, size: 32),
              const SizedBox(height: 7),
              Text(title, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
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
  final TextEditingController _search = TextEditingController();
  String mode = 'السور';
  int selectedJuz = 1;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openSurah(BuildContext context, int number) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => QuranReaderPage(
          surahNumber: number,
          surahName: surahNames[number - 1],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final query = _search.text.trim();
    final indices = List<int>.generate(114, (i) => i).where((i) {
      if (query.isEmpty) return true;
      return surahNames[i].contains(query) || '${i + 1}'.contains(query);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'صفحة المصحف',
            icon: const Icon(Icons.menu_book_outlined),
            onPressed: () async {
              final controller = TextEditingController(text: '1');
              final page = await showDialog<int>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('الانتقال إلى صفحة', textDirection: TextDirection.rtl),
                  content: TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    decoration: const InputDecoration(hintText: '1 - 604'),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('إلغاء')),
                    FilledButton(
                      onPressed: () {
                        final n = int.tryParse(controller.text);
                        if (n != null && n >= 1 && n <= 604) Navigator.pop(context, n);
                      },
                      child: const Text('فتح'),
                    ),
                  ],
                ),
              );
              controller.dispose();
              if (page == null || !context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuranReaderPage(surahNumber: 1, surahName: 'المصحف', initialPage: page),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 24),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF0F766E), Color(0xFF164E63)],
              ),
              boxShadow: const [BoxShadow(blurRadius: 18, offset: Offset(0, 8), color: Color(0x22000000))],
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text('القرآن الكريم', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
                SizedBox(height: 6),
                Text('قراءة المصحف • استماع • تلاوة متزامنة • تكرار • تحميل', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white70, fontSize: 13)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _search,
            textDirection: TextDirection.rtl,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'ابحث باسم السورة أو رقمها...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _search.text.isEmpty ? null : IconButton(onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.clear)),
              filled: true,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none),
            ),
          ),
          const SizedBox(height: 10),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'السور', label: Text('السور'), icon: Icon(Icons.view_list)),
              ButtonSegment(value: 'الأجزاء', label: Text('الأجزاء'), icon: Icon(Icons.grid_view)),
            ],
            selected: {mode},
            onSelectionChanged: (v) => setState(() => mode = v.first),
          ),
          const SizedBox(height: 12),
          if (mode == 'السور') ...[
            Text('${indices.length} سورة', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...indices.map((i) {
              final n = i + 1;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                elevation: 0,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
                  leading: CircleAvatar(child: Text('$n')),
                  title: Text('سورة ${surahNames[i]}', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('صفحة ${surahStartPages[i]}  •  الجزء ${((surahStartPages[i] - 1) ~/ 20) + 1}', textDirection: TextDirection.rtl),
                  trailing: const Icon(Icons.chevron_left),
                  onTap: () => _openSurah(context, n),
                ),
              );
            }),
          ] else ...[
            const Text('اختر الجزء', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 30,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, childAspectRatio: 1.45, crossAxisSpacing: 8, mainAxisSpacing: 8),
              itemBuilder: (_, i) => Card(
                elevation: 0,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => setState(() => selectedJuz = i + 1),
                  child: Center(child: Text('الجزء ${i + 1}', textDirection: TextDirection.rtl, style: TextStyle(fontWeight: FontWeight.bold, color: selectedJuz == i + 1 ? Theme.of(context).colorScheme.primary : null))),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Card(
              child: ListTile(
                title: Text('الجزء $selectedJuz', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: const Text('يمكنك متابعة القراءة من صفحات المصحف والتنقل بالسحب', textDirection: TextDirection.rtl),
                trailing: const Icon(Icons.arrow_back_ios_new, size: 17),
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => QuranReaderPage(surahNumber: 1, surahName: 'الجزء $selectedJuz', initialPage: (((selectedJuz - 1) * 20) + 1).clamp(1, 604)))),
              ),
            ),
          ],
        ],
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
  final int? initialPage;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
    this.initialPage,
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

  @override
  void initState() {
    super.initState();

    currentPage = widget.initialPage ?? surahStartPages[widget.surahNumber - 1];

    _positionSubscription =
        _audioPlayer.positionStream.listen(_onAudioPosition);

    _processingSubscription = _audioPlayer.processingStateStream.listen((state) {
      if (state == ProcessingState.completed) {
        _handleAudioCompleted();
      }
    });

    controller = WebViewController()
      ..setJavaScriptMode(
        JavaScriptMode.unrestricted,
      )
      ..setBackgroundColor(
        const Color(0xFFF7F1DF),
      )  
..addJavaScriptChannel(
  'AyahChannel',
  onMessageReceived: (message) {
    _showAyahMenu(message.message);
  },
)
..addJavaScriptChannel(
  'NavigationChannel',
  onMessageReceived: (message) {
    final direction = message.message;

    if (direction == 'next') {
      _changePage(currentPage + 1);
    } else if (direction == 'prev') {
      _changePage(currentPage - 1);
    }
  },
)
      ..addJavaScriptChannel(
      'PageChannel',
        onMessageReceived: (message) {
          final page = int.tryParse(message.message);

          if (page != null) {
            setState(() {
              currentPage = page;
            });

            if (_isFullSurahPlayback && _lastHighlightedAyah != null) {
              final parts = _lastHighlightedAyah!.split(':');
              if (parts.length == 2) {
                Future.delayed(const Duration(milliseconds: 100), () {
                  if (!mounted) return;
                  controller.runJavaScript(
                    "setNoorAyahHighlight('${parts[0]}', '${parts[1]}');",
                  );
                });
              }
            }
          }
        },
      )
      ..loadHtmlString(
        _mushafPage(currentPage),
      );
  }
Future<void> _loadReciters() async {
    setState(() {
      loadingReciters = true;
    });

    try {
      final response = await http.get(
        Uri.parse(
          'https://mp3quran.net/api/v3/ayat_timing/reads',
        ),
      );

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

    final response = await http.get(
      Uri.parse(_surahAudioUrl(read)),
    );

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
    controller.runJavaScript(
      "setNoorAyahHighlight('${widget.surahNumber}', '${timing.ayah}');",
    );
  }

  void _clearAyahHighlight() {
    _lastHighlightedAyah = null;
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

  String _mushafPage(int page) {
    final p = page.toString().padLeft(3, '0');

    final svgUrl =
        'https://cdn.quran.ws/svg/pages/v1.1.1/hafs-kfqc/$p.svg';

    return '''
<!DOCTYPE html>
<html dir="rtl">
<head>
<meta name="viewport"
      content="width=device-width,
      initial-scale=1.0,
      maximum-scale=1.0">

<style>
html, body {
  margin: 0;
  padding: 0;
  background: #f7f1df;
}

body {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  min-height: 100vh;
}

#mushaf {
  width: 100%;
  max-width: 900px;
  padding: 10px;
  box-sizing: border-box;
}

#mushaf svg {
  width: 100%;
  height: auto;
  display: block;
}

.ayahPolygon {
  cursor: pointer;
}

.ayahPolygon.selected {
  fill: rgba(103, 58, 183, 0.30) !important;
  stroke: none !important;
  stroke-width: 0 !important;
}
</style>
</head>

<body>

<div id="mushaf"></div>

<script>

const pageNumber = $page;

function setNoorAyahHighlight(surah, ayah) {
  window.noorHighlightSurah = String(surah);
  window.noorHighlightAyah = String(ayah);
  document.querySelectorAll('.ayahPolygon').forEach(function(el) {
    if (!el.dataset.noorOriginalFill) {
      el.dataset.noorOriginalFill = el.getAttribute('fill') || '';
      el.dataset.noorOriginalStroke = el.getAttribute('stroke') || '';
      el.dataset.noorOriginalStrokeWidth = el.getAttribute('stroke-width') || '';
      el.dataset.noorOriginalFillOpacity = el.getAttribute('fill-opacity') || '';
    }
    const match = el.getAttribute('surah') === String(surah) &&
                  el.getAttribute('ayah') === String(ayah);
    if (match) {
      el.classList.add('selected');
      el.style.setProperty('fill', 'rgba(103,58,183,0.30)', 'important');
      el.style.setProperty('fill-opacity', '1', 'important');
      el.style.setProperty('stroke', 'none', 'important');
      el.style.setProperty('stroke-width', '0', 'important');
    } else {
      el.classList.remove('selected');
      if (el.dataset.noorOriginalFill) el.style.setProperty('fill', el.dataset.noorOriginalFill, 'important');
      else el.style.removeProperty('fill');
      if (el.dataset.noorOriginalStroke) el.style.setProperty('stroke', el.dataset.noorOriginalStroke, 'important');
      else el.style.removeProperty('stroke');
      if (el.dataset.noorOriginalStrokeWidth) el.style.setProperty('stroke-width', el.dataset.noorOriginalStrokeWidth, 'important');
      else el.style.removeProperty('stroke-width');
      if (el.dataset.noorOriginalFillOpacity) el.style.setProperty('fill-opacity', el.dataset.noorOriginalFillOpacity, 'important');
      else el.style.removeProperty('fill-opacity');
    }
  });
}
window.setNoorAyahHighlight = setNoorAyahHighlight;

fetch('$svgUrl')
  .then(response => response.text())
  .then(svg => {

    document.getElementById('mushaf').innerHTML = svg;

    document.querySelectorAll(
  '.ayahPolygon'
).forEach(function(element) {

  element.addEventListener(
    'click',
    function() {

      const surah =
        element.getAttribute('surah');

      const ayah =
        element.getAttribute('ayah');

      if (surah && ayah) {

        AyahChannel.postMessage(
          surah + ':' + ayah
        );

      }
    }
  );

});
let startX = 0;

document.addEventListener('touchstart', function(event) {
  startX = event.touches[0].clientX;
});

document.addEventListener('touchend', function(event) {
  const endX = event.changedTouches[0].clientX;
  const difference = endX - startX;

  if (Math.abs(difference) < 80) {
    return;
  }

  if (difference < 0) {
    NavigationChannel.postMessage('next');
  } else {
    NavigationChannel.postMessage('prev');
  }
});
    PageChannel.postMessage(
      pageNumber.toString()
    );
    if (window.noorHighlightSurah && window.noorHighlightAyah) {
      setTimeout(function() {
        setNoorAyahHighlight(window.noorHighlightSurah, window.noorHighlightAyah);
      }, 80);
    }
  })
  .catch(function(error) {

    document.getElementById('mushaf').innerHTML =
      '<div style="padding:40px;text-align:center;font-family:sans-serif;">' +
      'تعذر تحميل صفحة المصحف' +
      '</div>';
  });
</script>

</body>
</html>
''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'سورة ${widget.surahName}',
        ),
        centerTitle: true,
      ),
      body: WebViewWidget(
        controller: controller,
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedRead != null) _buildAudioBar(),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'الصفحة $currentPage',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'الجزء ${_juz(currentPage)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
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
    void _saveAyah(String ayah) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'تم حفظ الآية $ayah',
        ),
      ),
    );
  }
  Future<void> _showReciters(String ayah) async {
    if (timingReads.isEmpty) {
      await _loadReciters();
    }

    if (!mounted) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) {
        if (loadingReciters) {
          return const SizedBox(
            height: 250,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (timingReads.isEmpty) {
          return const SizedBox(
            height: 250,
            child: Center(
              child: Text('تعذر تحميل قائمة القرّاء'),
            ),
          );
        }

        return SafeArea(
          child: SizedBox(
            height:
                MediaQuery.of(context).size.height * 0.78,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'اختر القارئ',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView.builder(
                    itemCount: timingReads.length,
                    itemBuilder: (context, index) {
                      final read = timingReads[index];

                      return ListTile(
                        leading: const CircleAvatar(
                          child: Icon(Icons.person),
                        ),
                        title: Text(
                          read.name,
                          textDirection: TextDirection.rtl,
                        ),
                        subtitle: read.rewaya.isEmpty
                            ? null
                            : Text(
                                read.rewaya,
                                textDirection:
                                    TextDirection.rtl,
                              ),
                        trailing: const Icon(
                          Icons.arrow_back_ios,
                          size: 16,
                        ),
                        onTap: () {
                          Navigator.pop(context);
                          _showAudioControls(
                            ayah,
                            read,
                          );
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
    Future<void> _changePage(int newPage) async {
    if (newPage < 1 || newPage > 604) {
      return;
    }

    setState(() {
      currentPage = newPage;
    });

    await controller.loadHtmlString(
      _mushafPage(newPage),
    );
  }

  Widget _pageButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
      tooltip: 'تغيير الصفحة',
    );
  }
}
  class AdhkarItem {
  final String title;
  final String text;
  final int count;
  final String source;
  final String category;
  const AdhkarItem(this.title, this.text, this.count, this.source, this.category);
}

const List<AdhkarItem> allAdhkar = [
  AdhkarItem('آية الكرسي', 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ.', 1, 'القرآن الكريم — البقرة: 255', 'الصباح والمساء'),
  AdhkarItem('سورة الإخلاص', 'قُلْ هُوَ اللَّهُ أَحَدٌ  اللَّهُ الصَّمَدُ  لَمْ يَلِدْ وَلَمْ يُولَدْ  وَلَمْ يَكُنْ لَهُ كُفُوًا أَحَدٌ.', 3, 'من أذكار الكتاب والسنة', 'الصباح والمساء'),
  AdhkarItem('سورة الفلق', 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ  مِنْ شَرِّ مَا خَلَقَ  وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ  وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ  وَمِنْ شَرِّ حَاسِدٍ إِذَا حَسَدَ.', 3, 'من أذكار الكتاب والسنة', 'الصباح والمساء'),
  AdhkarItem('سورة الناس', 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ  مَلِكِ النَّاسِ  إِلَٰهِ النَّاسِ  مِنْ شَرِّ الْوَسْوَاسِ الْخَنَّاسِ  الَّذِي يُوَسْوِسُ فِي صُدُورِ النَّاسِ  مِنَ الْجِنَّةِ وَالنَّاسِ.', 3, 'من أذكار الكتاب والسنة', 'الصباح والمساء'),
  AdhkarItem('ذكر الصباح', 'أَصْبَحْنَا وَأَصْبَحَ الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.', 1, 'حصن المسلم — أذكار الصباح والمساء', 'الصباح والمساء'),
  AdhkarItem('ذكر المساء', 'أَمْسَيْنَا وَأَمْسَى الْمُلْكُ لِلَّهِ، وَالْحَمْدُ لِلَّهِ، لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.', 1, 'حصن المسلم — أذكار الصباح والمساء', 'الصباح والمساء'),
  AdhkarItem('العفو والعافية', 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْعَفْوَ وَالْعَافِيَةَ فِي الدُّنْيَا وَالْآخِرَةِ.', 1, 'حصن المسلم', 'الصباح والمساء'),
  AdhkarItem('رضيت بالله ربًا', 'رَضِيتُ بِاللَّهِ رَبًّا، وَبِالْإِسْلَامِ دِينًا، وَبِمُحَمَّدٍ صَلَّى اللَّهُ عَلَيْهِ وَسَلَّمَ نَبِيًّا.', 3, 'حصن المسلم', 'الصباح والمساء'),
  AdhkarItem('حسبي الله', 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ، وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ.', 7, 'حصن المسلم', 'الصباح والمساء'),
  AdhkarItem('سبحان الله وبحمده', 'سُبْحَانَ اللَّهِ وَبِحَمْدِهِ.', 100, 'حصن المسلم', 'الصباح والمساء'),
  AdhkarItem('لا إله إلا الله وحده', 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.', 10, 'حصن المسلم', 'الصباح والمساء'),
  AdhkarItem('الاستغفار', 'أَسْتَغْفِرُ اللَّهَ وَأَتُوبُ إِلَيْهِ.', 100, 'حصن المسلم', 'الصباح والمساء'),
  AdhkarItem('سيد الاستغفار', 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي، فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.', 1, 'حصن المسلم', 'الصباح والمساء'),
  AdhkarItem('بعد الصلاة: الاستغفار', 'أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ، أَسْتَغْفِرُ اللَّهَ.', 3, 'صحيح مسلم', 'بعد الصلاة'),
  AdhkarItem('بعد الصلاة: السلام', 'اللَّهُمَّ أَنْتَ السَّلَامُ، وَمِنْكَ السَّلَامُ، تَبَارَكْتَ يَا ذَا الْجَلَالِ وَالْإِكْرَامِ.', 1, 'صحيح مسلم', 'بعد الصلاة'),
  AdhkarItem('بعد الصلاة: التسبيح', 'سُبْحَانَ اللَّهِ.', 33, 'صحيح مسلم', 'بعد الصلاة'),
  AdhkarItem('بعد الصلاة: الحمد', 'الْحَمْدُ لِلَّهِ.', 33, 'صحيح مسلم', 'بعد الصلاة'),
  AdhkarItem('بعد الصلاة: التكبير', 'اللَّهُ أَكْبَرُ.', 33, 'صحيح مسلم', 'بعد الصلاة'),
  AdhkarItem('ختام التسبيح بعد الصلاة', 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.', 1, 'صحيح مسلم', 'بعد الصلاة'),
  AdhkarItem('دعاء النوم', 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا.', 1, 'صحيح البخاري', 'النوم'),
  AdhkarItem('قبل النوم: آية الكرسي', 'اللَّهُ لَا إِلَٰهَ إِلَّا هُوَ الْحَيُّ الْقَيُّومُ ۚ لَا تَأْخُذُهُ سِنَةٌ وَلَا نَوْمٌ ۚ لَهُ مَا فِي السَّمَاوَاتِ وَمَا فِي الْأَرْضِ ۗ مَنْ ذَا الَّذِي يَشْفَعُ عِنْدَهُ إِلَّا بِإِذْنِهِ ۚ يَعْلَمُ مَا بَيْنَ أَيْدِيهِمْ وَمَا خَلْفَهُمْ ۖ وَلَا يُحِيطُونَ بِشَيْءٍ مِنْ عِلْمِهِ إِلَّا بِمَا شَاءَ ۚ وَسِعَ كُرْسِيُّهُ السَّمَاوَاتِ وَالْأَرْضَ ۖ وَلَا يَئُودُهُ حِفْظُهُمَا ۚ وَهُوَ الْعَلِيُّ الْعَظِيمُ.', 1, 'صحيح البخاري — مع قراءة آية الكرسي كاملة', 'النوم'),
  AdhkarItem('قبل النوم: التسبيح والتحميد والتكبير', 'سُبْحَانَ اللَّهِ 33، وَالْحَمْدُ لِلَّهِ 33، وَاللَّهُ أَكْبَرُ 34.', 1, 'صحيح البخاري وصحيح مسلم', 'النوم'),
  AdhkarItem('الاستيقاظ من النوم', 'الْحَمْدُ لِلَّهِ الَّذِي أَحْيَانَا بَعْدَ مَا أَمَاتَنَا وَإِلَيْهِ النُّشُورُ.', 1, 'صحيح البخاري', 'الاستيقاظ'),
  AdhkarItem('دخول الخلاء', 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْخُبُثِ وَالْخَبَائِثِ.', 1, 'صحيح البخاري وصحيح مسلم', 'اليوم والليلة'),
  AdhkarItem('الخروج من الخلاء', 'غُفْرَانَكَ.', 1, 'سنن أبي داود والترمذي', 'اليوم والليلة'),
  AdhkarItem('قبل الوضوء', 'بِسْمِ اللَّهِ.', 1, 'من الأذكار المشروعة', 'الوضوء'),
  AdhkarItem('بعد الوضوء', 'أَشْهَدُ أَنْ لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، وَأَشْهَدُ أَنَّ مُحَمَّدًا عَبْدُهُ وَرَسُولُهُ.', 1, 'صحيح مسلم', 'الوضوء'),
  AdhkarItem('دخول المنزل', 'بِسْمِ اللَّهِ وَلَجْنَا، وَبِسْمِ اللَّهِ خَرَجْنَا، وَعَلَى رَبِّنَا تَوَكَّلْنَا.', 1, 'سنن أبي داود', 'اليوم والليلة'),
  AdhkarItem('الخروج من المنزل', 'بِسْمِ اللَّهِ، تَوَكَّلْتُ عَلَى اللَّهِ، وَلَا حَوْلَ وَلَا قُوَّةَ إِلَّا بِاللَّهِ.', 1, 'سنن أبي داود والترمذي', 'اليوم والليلة'),
  AdhkarItem('دخول المسجد', 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ.', 1, 'صحيح مسلم', 'المسجد'),
  AdhkarItem('الخروج من المسجد', 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ.', 1, 'صحيح مسلم', 'المسجد'),
  AdhkarItem('بعد الأذان', 'اللَّهُمَّ رَبَّ هَذِهِ الدَّعْوَةِ التَّامَّةِ، وَالصَّلَاةِ الْقَائِمَةِ، آتِ مُحَمَّدًا الْوَسِيلَةَ وَالْفَضِيلَةَ، وَابْعَثْهُ مَقَامًا مَحْمُودًا الَّذِي وَعَدْتَهُ.', 1, 'صحيح البخاري', 'المسجد'),
  AdhkarItem('عند الكرب', 'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ.', 1, 'صحيح البخاري وصحيح مسلم', 'الكرب والهم'),
  AdhkarItem('عند الهم والحزن', 'اللَّهُمَّ إِنِّي عَبْدُكَ، ابْنُ عَبْدِكَ، ابْنُ أَمَتِكَ، نَاصِيَتِي بِيَدِكَ، مَاضٍ فِيَّ حُكْمُكَ، عَدْلٌ فِيَّ قَضَاؤُكَ، أَسْأَلُكَ بِكُلِّ اسْمٍ هُوَ لَكَ، سَمَّيْتَ بِهِ نَفْسَكَ، أَوْ أَنْزَلْتَهُ فِي كِتَابِكَ، أَوْ عَلَّمْتَهُ أَحَدًا مِنْ خَلْقِكَ، أَوِ اسْتَأْثَرْتَ بِهِ فِي عِلْمِ الْغَيْبِ عِنْدَكَ، أَنْ تَجْعَلَ الْقُرْآنَ رَبِيعَ قَلْبِي، وَنُورَ صَدْرِي، وَجَلَاءَ حُزْنِي، وَذَهَابَ هَمِّي.', 1, 'مسند أحمد — دعاء الهم والحزن', 'الكرب والهم'),
  AdhkarItem('عند المرض', 'أَسْأَلُ اللَّهَ الْعَظِيمَ رَبَّ الْعَرْشِ الْعَظِيمِ أَنْ يَشْفِيَكَ.', 7, 'سنن أبي داود والترمذي', 'المرض'),
  AdhkarItem('للمريض', 'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا.', 1, 'صحيح البخاري وصحيح مسلم', 'المرض'),
  AdhkarItem('عند المصيبة', 'إِنَّا لِلَّهِ وَإِنَّا إِلَيْهِ رَاجِعُونَ، اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي، وَأَخْلِفْ لِي خَيْرًا مِنْهَا.', 1, 'صحيح مسلم', 'المصائب'),
  AdhkarItem('عند الغضب', 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ.', 1, 'صحيح البخاري وصحيح مسلم', 'الكرب والهم'),
  AdhkarItem('عند نزول المطر', 'اللَّهُمَّ صَيِّبًا نَافِعًا.', 1, 'صحيح البخاري', 'المطر'),
  AdhkarItem('بعد نزول المطر', 'مُطِرْنَا بِفَضْلِ اللَّهِ وَرَحْمَتِهِ.', 1, 'صحيح البخاري وصحيح مسلم', 'المطر'),
  AdhkarItem('دعاء السفر', 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ.', 1, 'صحيح مسلم', 'السفر'),
  AdhkarItem('دعاء السفر المختصر', 'اللَّهُمَّ هَوِّنْ عَلَيْنَا سَفَرَنَا هَذَا وَاطْوِ عَنَّا بُعْدَهُ، اللَّهُمَّ أَنْتَ الصَّاحِبُ فِي السَّفَرِ وَالْخَلِيفَةُ فِي الْأَهْلِ.', 1, 'صحيح مسلم', 'السفر'),
  AdhkarItem('عند رؤية ما يعجب', 'اللَّهُمَّ بَارِكْ لَهُ.', 1, 'من الدعاء المشروع عند الإعجاب', 'اليوم والليلة'),
  AdhkarItem('لبس الثوب', 'الْحَمْدُ لِلَّهِ الَّذِي كَسَانِي هَذَا الثَّوْبَ وَرَزَقَنِيهِ مِنْ غَيْرِ حَوْلٍ مِنِّي وَلَا قُوَّةٍ.', 1, 'سنن أبي داود والترمذي', 'اليوم والليلة'),
  AdhkarItem('لبس الثوب الجديد', 'اللَّهُمَّ لَكَ الْحَمْدُ أَنْتَ كَسَوْتَنِيهِ، أَسْأَلُكَ خَيْرَهُ وَخَيْرَ مَا صُنِعَ لَهُ، وَأَعُوذُ بِكَ مِنْ شَرِّهِ وَشَرِّ مَا صُنِعَ لَهُ.', 1, 'سنن أبي داود والترمذي', 'اليوم والليلة'),
  AdhkarItem('لمن لبس ثوبًا جديدًا', 'تُبْلِي وَيُخْلِفُ اللَّهُ تَعَالَى.', 1, 'سنن أبي داود', 'اليوم والليلة'),
  AdhkarItem('دعاء الذهاب إلى المسجد', 'اللَّهُمَّ اجْعَلْ فِي قَلْبِي نُورًا، وَفِي بَصَرِي نُورًا، وَفِي سَمْعِي نُورًا، وَعَنْ يَمِينِي نُورًا، وَعَنْ شِمَالِي نُورًا، وَفَوْقِي نُورًا، وَتَحْتِي نُورًا، وَأَمَامِي نُورًا، وَخَلْفِي نُورًا، وَأَعْظِمْ لِي نُورًا.', 1, 'صحيح البخاري وصحيح مسلم', 'المسجد'),
  AdhkarItem('دعاء الاستفتاح', 'اللَّهُمَّ بَاعِدْ بَيْنِي وَبَيْنَ خَطَايَايَ كَمَا بَاعَدْتَ بَيْنَ الْمَشْرِقِ وَالْمَغْرِبِ، اللَّهُمَّ نَقِّنِي مِنْ خَطَايَايَ كَمَا نُقِّيَ الثَّوْبُ الْأَبْيَضُ مِنَ الدَّنَسِ، اللَّهُمَّ اغْسِلْنِي مِنْ خَطَايَايَ بِالثَّلْجِ وَالْمَاءِ وَالْبَرَدِ.', 1, 'صحيح البخاري وصحيح مسلم', 'الصلاة'),
  AdhkarItem('دعاء الركوع', 'سُبْحَانَ رَبِّيَ الْعَظِيمِ.', 3, 'صحيح مسلم', 'الصلاة'),
  AdhkarItem('دعاء السجود', 'سُبْحَانَ رَبِّيَ الْأَعْلَى.', 3, 'صحيح مسلم', 'الصلاة'),
  AdhkarItem('دعاء بين السجدتين', 'رَبِّ اغْفِرْ لِي، رَبِّ اغْفِرْ لِي.', 1, 'سنن أبي داود', 'الصلاة'),
  AdhkarItem('دعاء بعد الرفع من الركوع', 'رَبَّنَا وَلَكَ الْحَمْدُ حَمْدًا كَثِيرًا طَيِّبًا مُبَارَكًا فِيهِ.', 1, 'صحيح البخاري', 'الصلاة'),
  AdhkarItem('الصلاة على النبي', 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ وَعَلَى آلِ مُحَمَّدٍ، كَمَا صَلَّيْتَ عَلَى إِبْرَاهِيمَ وَعَلَى آلِ إِبْرَاهِيمَ، إِنَّكَ حَمِيدٌ مَجِيدٌ.', 1, 'صحيح البخاري وصحيح مسلم', 'الصلاة'),
  AdhkarItem('دعاء سيد الاستغفار', 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي، فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.', 1, 'صحيح البخاري', 'الاستغفار'),
  AdhkarItem('دعاء قنوت الوتر', 'اللَّهُمَّ اهْدِنِي فِيمَنْ هَدَيْتَ، وَعَافِنِي فِيمَنْ عَافَيْتَ، وَتَوَلَّنِي فِيمَنْ تَوَلَّيْتَ، وَبَارِكْ لِي فِيمَا أَعْطَيْتَ، وَقِنِي شَرَّ مَا قَضَيْتَ، فَإِنَّكَ تَقْضِي وَلَا يُقْضَى عَلَيْكَ، إِنَّهُ لَا يَذِلُّ مَنْ وَالَيْتَ، وَلَا يَعِزُّ مَنْ عَادَيْتَ، تَبَارَكْتَ رَبَّنَا وَتَعَالَيْتَ.', 1, 'سنن أبي داود والترمذي والنسائي', 'الصلاة'),
  AdhkarItem('دعاء الاستخارة', 'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ، فَإِنَّكَ تَقْدِرُ وَلَا أَقْدِرُ، وَتَعْلَمُ وَلَا أَعْلَمُ، وَأَنْتَ عَلَّامُ الْغُيُوبِ.', 1, 'صحيح البخاري', 'الاستخارة'),
  AdhkarItem('عند استصعاب أمر', 'اللَّهُمَّ لَا سَهْلَ إِلَّا مَا جَعَلْتَهُ سَهْلًا، وَأَنْتَ تَجْعَلُ الْحَزْنَ إِذَا شِئْتَ سَهْلًا.', 1, 'صحيح ابن حبان', 'الحاجة والكرب'),
  AdhkarItem('قضاء الدين', 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ.', 1, 'صحيح البخاري', 'الرزق والدين'),
  AdhkarItem('دعاء الدين', 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ.', 1, 'سنن الترمذي', 'الرزق والدين'),
  AdhkarItem('عند الوسوسة', 'آمَنْتُ بِاللَّهِ وَرُسُلِهِ.', 1, 'صحيح مسلم', 'الوسوسة'),
  AdhkarItem('طرد الشيطان', 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ.', 1, 'من الأذكار المشروعة', 'الوسوسة'),
  AdhkarItem('عند سماع نباح الكلاب', 'أَعُوذُ بِاللَّهِ مِنَ الشَّيْطَانِ الرَّجِيمِ.', 1, 'صحيح أبي داود', 'اليوم والليلة'),
  AdhkarItem('عند صياح الديك', 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ.', 1, 'صحيح البخاري وصحيح مسلم', 'اليوم والليلة'),
  AdhkarItem('عند هبوب الريح', 'اللَّهُمَّ إِنِّي أَسْأَلُكَ خَيْرَهَا، وَخَيْرَ مَا فِيهَا، وَخَيْرَ مَا أُرْسِلَتْ بِهِ، وَأَعُوذُ بِكَ مِنْ شَرِّهَا، وَشَرِّ مَا فِيهَا، وَشَرِّ مَا أُرْسِلَتْ بِهِ.', 1, 'صحيح مسلم', 'المطر والريح'),
  AdhkarItem('رؤية الهلال', 'اللَّهُمَّ أَهِلَّهُ عَلَيْنَا بِالْأَمْنِ وَالْإِيمَانِ، وَالسَّلَامَةِ وَالْإِسْلَامِ، رَبِّي وَرَبُّكَ اللَّهُ.', 1, 'سنن الترمذي', 'اليوم والليلة'),
  AdhkarItem('عند الإفطار', 'ذَهَبَ الظَّمَأُ، وَابْتَلَّتِ الْعُرُوقُ، وَثَبَتَ الْأَجْرُ إِنْ شَاءَ اللَّهُ.', 1, 'سنن أبي داود', 'الصيام'),
  AdhkarItem('ليلة القدر', 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي.', 1, 'سنن الترمذي', 'رمضان'),
  AdhkarItem('تهنئة المولود', 'بَارَكَ اللَّهُ لَكَ فِي الْمَوْهُوبِ لَكَ، وَشَكَرْتَ الْوَاهِبَ، وَبَلَغَ أَشُدَّهُ، وَرُزِقْتَ بِرَّهُ.', 1, 'ورد عن السلف', 'الأسرة'),
  AdhkarItem('تعزية المصاب', 'إِنَّ لِلَّهِ مَا أَخَذَ، وَلَهُ مَا أَعْطَى، وَكُلُّ شَيْءٍ عِنْدَهُ بِأَجَلٍ مُسَمًّى، فَلْتَصْبِرْ وَلْتَحْتَسِبْ.', 1, 'صحيح البخاري وصحيح مسلم', 'المصائب'),
  AdhkarItem('للمحبة في الله', 'أَحَبَّكَ الَّذِي أَحْبَبْتَنِي لَهُ.', 1, 'سنن أبي داود', 'الآداب'),
  AdhkarItem('لمن صنع إليك معروفًا', 'جَزَاكَ اللَّهُ خَيْرًا.', 1, 'سنن الترمذي', 'الآداب'),
  AdhkarItem('عطاس المسلم', 'يَرْحَمُكَ اللَّهُ.', 1, 'صحيح البخاري وصحيح مسلم', 'الآداب'),
  AdhkarItem('رد العاطس', 'يَهْدِيكُمُ اللَّهُ وَيُصْلِحُ بَالَكُمْ.', 1, 'صحيح البخاري', 'الآداب'),
  AdhkarItem('عند رؤية مبتلى', 'الْحَمْدُ لِلَّهِ الَّذِي عَافَانِي مِمَّا ابْتَلَاكَ بِهِ، وَفَضَّلَنِي عَلَى كَثِيرٍ مِمَّنْ خَلَقَ تَفْضِيلًا.', 1, 'سنن الترمذي', 'اليوم والليلة'),
  AdhkarItem('دعاء الريح النافعة', 'اللَّهُمَّ اجْعَلْهَا رِيَاحًا وَلَا تَجْعَلْهَا رِيحًا.', 1, 'ورد في الدعاء عند الريح', 'المطر والريح'),
  AdhkarItem('ذكر عند رؤية النعمة', 'مَا شَاءَ اللَّهُ، لَا قُوَّةَ إِلَّا بِاللَّهِ.', 1, 'القرآن الكريم — الكهف: 39', 'النعمة'),
  AdhkarItem('عند الخوف من قوم', 'اللَّهُمَّ إِنَّا نَجْعَلُكَ فِي نُحُورِهِمْ، وَنَعُوذُ بِكَ مِنْ شُرُورِهِمْ.', 1, 'سنن أبي داود', 'الخوف'),
  AdhkarItem('دعاء الثبات', 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ.', 1, 'القرآن الكريم — آل عمران: 8', 'الهداية'),
  AdhkarItem('دعاء حسن العبادة', 'اللَّهُمَّ أَعِنِّي عَلَى ذِكْرِكَ وَشُكْرِكَ وَحُسْنِ عِبَادَتِكَ.', 1, 'سنن أبي داود والنسائي', 'العبادة'),
  AdhkarItem('دعاء صلاح القلب', 'يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ.', 1, 'سنن الترمذي', 'الهداية'),
  AdhkarItem('دعاء العلم النافع', 'اللَّهُمَّ انْفَعْنِي بِمَا عَلَّمْتَنِي، وَعَلِّمْنِي مَا يَنْفَعُنِي، وَزِدْنِي عِلْمًا.', 1, 'سنن الترمذي وما ورد في الدعاء بالعلم النافع', 'العلم'),
  AdhkarItem('طلب الهداية', 'اللَّهُمَّ إِنِّي أَسْأَلُكَ الْهُدَى وَالتُّقَى وَالْعَفَافَ وَالْغِنَى.', 1, 'صحيح مسلم', 'الهداية'),
  AdhkarItem('دعاء العفو', 'اللَّهُمَّ إِنَّكَ عَفُوٌّ تُحِبُّ الْعَفْوَ فَاعْفُ عَنِّي.', 1, 'سنن الترمذي', 'المغفرة'),
  AdhkarItem('دعاء جامع من خير الدنيا والآخرة', 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً، وَفِي الْآخِرَةِ حَسَنَةً، وَقِنَا عَذَابَ النَّارِ.', 1, 'القرآن الكريم — البقرة: 201', 'أدعية جامعة'),

];

class AdhkarPage extends StatefulWidget {
  const AdhkarPage({super.key});

  @override
  State<AdhkarPage> createState() => _AdhkarPageState();
}

class _AdhkarPageState extends State<AdhkarPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'الكل';
  final Set<int> favorites = <int>{};

  List<String> get categories => ['الكل', ...allAdhkar.map((e) => e.category).toSet()];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _share(AdhkarItem item) => Share.share('${item.title}\n\n${item.text}\n\nالمصدر: ${item.source}', subject: item.title);

  @override
  Widget build(BuildContext context) {
    final q = _searchController.text.trim();
    final items = allAdhkar.asMap().entries.where((entry) {
      final item = entry.value;
      final categoryOk = selectedCategory == 'الكل' || item.category == selectedCategory;
      final searchOk = q.isEmpty || item.title.contains(q) || item.text.contains(q) || item.category.contains(q);
      return categoryOk && searchOk;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: () { setState(() { selectedCategory = 'الكل'; _searchController.clear(); }); }, icon: const Icon(Icons.filter_alt_off)),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
            child: TextField(
              controller: _searchController,
              textDirection: TextDirection.rtl,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'ابحث في الأذكار...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isEmpty ? null : IconButton(onPressed: () { _searchController.clear(); setState(() {}); }, icon: const Icon(Icons.clear)),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)),
              ),
            ),
          ),
          SizedBox(
            height: 52,
            child: ListView.separated(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              scrollDirection: Axis.horizontal,
              itemCount: categories.length,
              separatorBuilder: (_, __) => const SizedBox(width: 6),
              itemBuilder: (_, i) => ChoiceChip(label: Text(categories[i]), selected: selectedCategory == categories[i], onSelected: (_) => setState(() => selectedCategory = categories[i])),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('${items.length} ذكر', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
              Text('${favorites.length} مفضل', textDirection: TextDirection.rtl, style: TextStyle(color: Theme.of(context).colorScheme.primary)),
            ]),
          ),
          Expanded(
            child: items.isEmpty
                ? const Center(child: Text('لا توجد أذكار مطابقة للبحث', textDirection: TextDirection.rtl))
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: items.length,
                    itemBuilder: (_, i) {
                      final originalIndex = items[i].key;
                      final item = items[i].value;
                      return _DhikrCard(
                        key: ValueKey(originalIndex),
                        item: item,
                        favorite: favorites.contains(originalIndex),
                        onFavorite: () => setState(() { favorites.contains(originalIndex) ? favorites.remove(originalIndex) : favorites.add(originalIndex); }),
                        onShare: () => _share(item),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _DhikrCard extends StatefulWidget {
  final AdhkarItem item;
  final bool favorite;
  final VoidCallback onFavorite;
  final VoidCallback onShare;
  const _DhikrCard({super.key, required this.item, required this.favorite, required this.onFavorite, required this.onShare});

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
    final progress = widget.item.count <= 1 ? (done ? 1.0 : 0.0) : (widget.item.count - remaining) / widget.item.count;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: done ? null : () => setState(() => remaining--),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              IconButton(tooltip: 'مشاركة', onPressed: widget.onShare, icon: const Icon(Icons.share_outlined)),
              IconButton(tooltip: 'مفضلة', onPressed: widget.onFavorite, icon: Icon(widget.favorite ? Icons.favorite : Icons.favorite_border)),
              Expanded(child: Text(widget.item.title, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 17))),
            ]),
            Text(widget.item.text, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.9)),
            const SizedBox(height: 10),
            LinearProgressIndicator(value: progress, minHeight: 5, borderRadius: BorderRadius.circular(5)),
            const SizedBox(height: 8),
            Row(children: [
              Text(done ? 'تم ✓' : 'المتبقي: $remaining', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
              const Spacer(),
              TextButton.icon(onPressed: () => setState(() => remaining = widget.item.count), icon: const Icon(Icons.refresh, size: 18), label: const Text('إعادة')),
            ]),
            Text(widget.item.source, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ]),
        ),
      ),
    );
  }
}

class DuaItem {
  final String title;
  final String text;
  final String source;
  final String category;
  const DuaItem(this.title, this.text, this.source, this.category);
}

const List<DuaItem> allDuas = [
  DuaItem('ربنا آتنا في الدنيا حسنة', 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الْآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ.', 'القرآن الكريم — البقرة: 201', 'أدعية القرآن'),
  DuaItem('ربنا لا تزغ قلوبنا', 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ.', 'القرآن الكريم — آل عمران: 8', 'أدعية القرآن'),
  DuaItem('رب هب لي من لدنك ذرية طيبة', 'رَبِّ هَبْ لِي مِنْ لَدُنْكَ ذُرِّيَّةً طَيِّبَةً إِنَّكَ سَمِيعُ الدُّعَاءِ.', 'القرآن الكريم — آل عمران: 38', 'الذرية والأسرة'),
  DuaItem('ربنا ظلمنا أنفسنا', 'رَبَّنَا ظَلَمْنَا أَنْفُسَنَا وَإِنْ لَمْ تَغْفِرْ لَنَا وَتَرْحَمْنَا لَنَكُونَنَّ مِنَ الْخَاسِرِينَ.', 'القرآن الكريم — الأعراف: 23', 'التوبة والمغفرة'),
  DuaItem('ربنا أفرغ علينا صبرًا', 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَتَوَفَّنَا مُسْلِمِينَ.', 'القرآن الكريم — الأعراف: 126', 'الكرب والثبات'),
  DuaItem('رب اجعلني مقيم الصلاة', 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ  رَبَّنَا اغْفِرْ لِي وَلِوَالِدَيَّ وَلِلْمُؤْمِنِينَ يَوْمَ يَقُومُ الْحِسَابُ.', 'القرآن الكريم — إبراهيم: 40-41', 'الصلاة والذرية'),
  DuaItem('رب اشرح لي صدري', 'رَبِّ اشْرَحْ لِي صَدْرِي  وَيَسِّرْ لِي أَمْرِي  وَاحْلُلْ عُقْدَةً مِنْ لِسَانِي  يَفْقَهُوا قَوْلِي.', 'القرآن الكريم — طه: 25-28', 'العلم والتيسير'),
  DuaItem('رب زدني علمًا', 'رَبِّ زِدْنِي عِلْمًا.', 'القرآن الكريم — طه: 114', 'العلم'),
  DuaItem('دعاء ذي النون', 'لَا إِلَهَ إِلَّا أَنْتَ سُبْحَانَكَ إِنِّي كُنْتُ مِنَ الظَّالِمِينَ.', 'القرآن الكريم — الأنبياء: 87', 'الكرب والتوبة'),
  DuaItem('رب إني لما أنزلت إلي من خير فقير', 'رَبِّ إِنِّي لِمَا أَنْزَلْتَ إِلَيَّ مِنْ خَيْرٍ فَقِيرٌ.', 'القرآن الكريم — القصص: 24', 'الرزق'),
  DuaItem('ربنا هب لنا من أزواجنا وذرياتنا قرة أعين', 'رَبَّنَا هَبْ لَنَا مِنْ أَزْوَاجِنَا وَذُرِّيَّاتِنَا قُرَّةَ أَعْيُنٍ وَاجْعَلْنَا لِلْمُتَّقِينَ إِمَامًا.', 'القرآن الكريم — الفرقان: 74', 'الأسرة والذرية'),
  DuaItem('ربنا تقبل منا', 'رَبَّنَا تَقَبَّلْ مِنَّا إِنَّكَ أَنْتَ السَّمِيعُ الْعَلِيمُ.', 'القرآن الكريم — البقرة: 127', 'العبادة'),
  DuaItem('ربنا أتمم لنا نورنا', 'رَبَّنَا أَتْمِمْ لَنَا نُورَنَا وَاغْفِرْ لَنَا إِنَّكَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.', 'القرآن الكريم — التحريم: 8', 'المغفرة'),
  DuaItem('رب اغفر لي ولوالدي', 'رَبِّ اغْفِرْ لِي وَلِوَالِدَيَّ وَلِمَنْ دَخَلَ بَيْتِيَ مُؤْمِنًا وَلِلْمُؤْمِنِينَ وَالْمُؤْمِنَاتِ.', 'القرآن الكريم — نوح: 28', 'الوالدان والمغفرة'),
  DuaItem('ربنا لا تؤاخذنا', 'رَبَّنَا لَا تُؤَاخِذْنَا إِنْ نَسِينَا أَوْ أَخْطَأْنَا.', 'القرآن الكريم — البقرة: 286', 'المغفرة'),
  DuaItem('ربنا ولا تحمل علينا إصرًا', 'رَبَّنَا وَلَا تَحْمِلْ عَلَيْنَا إِصْرًا كَمَا حَمَلْتَهُ عَلَى الَّذِينَ مِنْ قَبْلِنَا.', 'القرآن الكريم — البقرة: 286', 'الكرب'),
  DuaItem('ربنا ولا تحملنا ما لا طاقة لنا به', 'رَبَّنَا وَلَا تُحَمِّلْنَا مَا لَا طَاقَةَ لَنَا بِهِ وَاعْفُ عَنَّا وَاغْفِرْ لَنَا وَارْحَمْنَا أَنْتَ مَوْلَانَا فَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ.', 'القرآن الكريم — البقرة: 286', 'الكرب والمغفرة'),
  DuaItem('دعاء الثبات', 'رَبَّنَا أَفْرِغْ عَلَيْنَا صَبْرًا وَثَبِّتْ أَقْدَامَنَا وَانْصُرْنَا عَلَى الْقَوْمِ الْكَافِرِينَ.', 'القرآن الكريم — البقرة: 250', 'الثبات'),
  DuaItem('دعاء الهداية', 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ.', 'القرآن الكريم — الفاتحة: 6', 'الهداية'),
  DuaItem('دعاء الاستعاذة من الهم والحزن', 'اللَّهُمَّ إِنِّي أَعُوذُ بِكَ مِنَ الْهَمِّ وَالْحَزَنِ، وَأَعُوذُ بِكَ مِنَ الْعَجْزِ وَالْكَسَلِ، وَأَعُوذُ بِكَ مِنَ الْجُبْنِ وَالْبُخْلِ، وَأَعُوذُ بِكَ مِنْ غَلَبَةِ الدَّيْنِ وَقَهْرِ الرِّجَالِ.', 'صحيح البخاري', 'الهم والكرب'),
  DuaItem('دعاء الشفاء', 'اللَّهُمَّ رَبَّ النَّاسِ، أَذْهِبِ الْبَأْسَ، اشْفِ أَنْتَ الشَّافِي، لَا شِفَاءَ إِلَّا شِفَاؤُكَ، شِفَاءً لَا يُغَادِرُ سَقَمًا.', 'صحيح البخاري وصحيح مسلم', 'الشفاء'),
  DuaItem('دعاء قضاء الدين', 'اللَّهُمَّ اكْفِنِي بِحَلَالِكَ عَنْ حَرَامِكَ، وَأَغْنِنِي بِفَضْلِكَ عَمَّنْ سِوَاكَ.', 'سنن الترمذي', 'الرزق والدين'),
  DuaItem('دعاء الاستخارة', 'اللَّهُمَّ إِنِّي أَسْتَخِيرُكَ بِعِلْمِكَ، وَأَسْتَقْدِرُكَ بِقُدْرَتِكَ، وَأَسْأَلُكَ مِنْ فَضْلِكَ الْعَظِيمِ، فَإِنَّكَ تَقْدِرُ وَلَا أَقْدِرُ، وَتَعْلَمُ وَلَا أَعْلَمُ، وَأَنْتَ عَلَّامُ الْغُيُوبِ. اللَّهُمَّ إِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الْأَمْرَ خَيْرٌ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي، فَاقْدُرْهُ لِي وَيَسِّرْهُ لِي، ثُمَّ بَارِكْ لِي فِيهِ، وَإِنْ كُنْتَ تَعْلَمُ أَنَّ هَذَا الْأَمْرَ شَرٌّ لِي فِي دِينِي وَمَعَاشِي وَعَاقِبَةِ أَمْرِي، فَاصْرِفْهُ عَنِّي وَاصْرِفْنِي عَنْهُ، وَاقْدُرْ لِيَ الْخَيْرَ حَيْثُ كَانَ، ثُمَّ أَرْضِنِي بِهِ.', 'صحيح البخاري — دعاء الاستخارة', 'الاستخارة'),
  DuaItem('دعاء سيد الاستغفار', 'اللَّهُمَّ أَنْتَ رَبِّي لَا إِلَهَ إِلَّا أَنْتَ، خَلَقْتَنِي وَأَنَا عَبْدُكَ، وَأَنَا عَلَى عَهْدِكَ وَوَعْدِكَ مَا اسْتَطَعْتُ، أَعُوذُ بِكَ مِنْ شَرِّ مَا صَنَعْتُ، أَبُوءُ لَكَ بِنِعْمَتِكَ عَلَيَّ، وَأَبُوءُ لَكَ بِذَنْبِي، فَاغْفِرْ لِي، فَإِنَّهُ لَا يَغْفِرُ الذُّنُوبَ إِلَّا أَنْتَ.', 'صحيح البخاري', 'التوبة والمغفرة'),
  DuaItem('دعاء التوكل', 'حَسْبِيَ اللَّهُ لَا إِلَهَ إِلَّا هُوَ، عَلَيْهِ تَوَكَّلْتُ، وَهُوَ رَبُّ الْعَرْشِ الْعَظِيمِ.', 'القرآن الكريم — التوبة: 129', 'التوكل'),
  DuaItem('دعاء تفريج الكرب', 'لَا إِلَهَ إِلَّا اللَّهُ الْعَظِيمُ الْحَلِيمُ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ الْعَرْشِ الْعَظِيمِ، لَا إِلَهَ إِلَّا اللَّهُ رَبُّ السَّمَاوَاتِ وَرَبُّ الْأَرْضِ وَرَبُّ الْعَرْشِ الْكَرِيمِ.', 'صحيح البخاري وصحيح مسلم', 'الكرب'),
  DuaItem('دعاء عند المصيبة', 'اللَّهُمَّ أْجُرْنِي فِي مُصِيبَتِي، وَأَخْلِفْ لِي خَيْرًا مِنْهَا.', 'صحيح مسلم', 'المصائب'),
  DuaItem('دعاء الوالدين', 'رَبِّ ارْحَمْهُمَا كَمَا رَبَّيَانِي صَغِيرًا.', 'القرآن الكريم — الإسراء: 24', 'الوالدان'),
  DuaItem('دعاء للأهل والذرية', 'رَبِّ اجْعَلْنِي مُقِيمَ الصَّلَاةِ وَمِنْ ذُرِّيَّتِي رَبَّنَا وَتَقَبَّلْ دُعَاءِ.', 'القرآن الكريم — إبراهيم: 40', 'الأسرة والذرية'),
  DuaItem('دعاء حسن الخاتمة', 'رَبَّنَا لَا تُزِغْ قُلُوبَنَا بَعْدَ إِذْ هَدَيْتَنَا وَهَبْ لَنَا مِنْ لَدُنْكَ رَحْمَةً إِنَّكَ أَنْتَ الْوَهَّابُ.', 'القرآن الكريم — آل عمران: 8', 'الثبات وحسن الخاتمة'),
  DuaItem('دعاء يوم عرفة', 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.', 'حديث: خير الدعاء دعاء يوم عرفة — الترمذي', 'يوم عرفة'),
  DuaItem('دعاء جامع', 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنَ الْخَيْرِ كُلِّهِ، عَاجِلِهِ وَآجِلِهِ، مَا عَلِمْتُ مِنْهُ وَمَا لَمْ أَعْلَمْ، وَأَعُوذُ بِكَ مِنَ الشَّرِّ كُلِّهِ، عَاجِلِهِ وَآجِلِهِ، مَا عَلِمْتُ مِنْهُ وَمَا لَمْ أَعْلَمْ.', 'من الأدعية الجامعة الواردة في السنة', 'أدعية جامعة'),
  DuaItem('دعاء السفر', 'سُبْحَانَ الَّذِي سَخَّرَ لَنَا هَذَا وَمَا كُنَّا لَهُ مُقْرِنِينَ، وَإِنَّا إِلَى رَبِّنَا لَمُنْقَلِبُونَ.', 'صحيح مسلم', 'السفر'),
  DuaItem('دعاء دخول المسجد', 'اللَّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ.', 'صحيح مسلم', 'المسجد'),
  DuaItem('دعاء الخروج من المسجد', 'اللَّهُمَّ إِنِّي أَسْأَلُكَ مِنْ فَضْلِكَ.', 'صحيح مسلم', 'المسجد'),
  DuaItem('دعاء عند المطر', 'اللَّهُمَّ صَيِّبًا نَافِعًا.', 'صحيح البخاري', 'المطر'),
  DuaItem('دعاء عند الخوف', 'حَسْبُنَا اللَّهُ وَنِعْمَ الْوَكِيلُ.', 'القرآن الكريم — آل عمران: 173', 'الخوف والتوكل'),
];

class DuasPage extends StatefulWidget {
  const DuasPage({super.key});

  @override
  State<DuasPage> createState() => _DuasPageState();
}

class _DuasPageState extends State<DuasPage> {
  final TextEditingController _searchController = TextEditingController();
  String selectedCategory = 'الكل';
  final Set<int> favorites = <int>{};

  List<String> get categories => ['الكل', ...allDuas.map((e) => e.category).toSet()];

  @override
  void dispose() { _searchController.dispose(); super.dispose(); }

  void _share(DuaItem item) => Share.share('${item.title}\n\n${item.text}\n\nالمصدر: ${item.source}', subject: item.title);

  @override
  Widget build(BuildContext context) {
    final q = _searchController.text.trim();
    final items = allDuas.asMap().entries.where((entry) {
      final item = entry.value;
      return (selectedCategory == 'الكل' || item.category == selectedCategory) &&
          (q.isEmpty || item.title.contains(q) || item.text.contains(q) || item.category.contains(q));
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text('الأدعية'), centerTitle: true, actions: [
        IconButton(onPressed: () { setState(() { selectedCategory = 'الكل'; _searchController.clear(); }); }, icon: const Icon(Icons.filter_alt_off)),
      ]),
      body: Column(children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
          child: TextField(controller: _searchController, textDirection: TextDirection.rtl, onChanged: (_) => setState(() {}), decoration: InputDecoration(hintText: 'ابحث في الأدعية...', prefixIcon: const Icon(Icons.search), suffixIcon: _searchController.text.isEmpty ? null : IconButton(onPressed: () { _searchController.clear(); setState(() {}); }, icon: const Icon(Icons.clear)), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18)))),
        ),
        SizedBox(height: 52, child: ListView.separated(reverse: true, padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), scrollDirection: Axis.horizontal, itemCount: categories.length, separatorBuilder: (_, __) => const SizedBox(width: 6), itemBuilder: (_, i) => ChoiceChip(label: Text(categories[i]), selected: selectedCategory == categories[i], onSelected: (_) => setState(() => selectedCategory = categories[i])))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('${items.length} دعاء', textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)), Text('${favorites.length} مفضل', textDirection: TextDirection.rtl, style: TextStyle(color: Theme.of(context).colorScheme.primary))])),
        Expanded(child: items.isEmpty ? const Center(child: Text('لا توجد أدعية مطابقة للبحث', textDirection: TextDirection.rtl)) : ListView.builder(padding: const EdgeInsets.all(12), itemCount: items.length, itemBuilder: (_, i) {
          final originalIndex = items[i].key;
          final item = items[i].value;
          return Card(margin: const EdgeInsets.only(bottom: 12), child: Padding(padding: const EdgeInsets.fromLTRB(14, 12, 14, 10), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [IconButton(tooltip: 'مشاركة', onPressed: () => _share(item), icon: const Icon(Icons.share_outlined)), IconButton(tooltip: 'مفضلة', onPressed: () => setState(() { favorites.contains(originalIndex) ? favorites.remove(originalIndex) : favorites.add(originalIndex); }), icon: Icon(favorites.contains(originalIndex) ? Icons.favorite : Icons.favorite_border)), Expanded(child: Text(item.title, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold, fontSize: 17)))]),
            Text(item.text, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.9)),
            const SizedBox(height: 8),
            Row(children: [TextButton.icon(onPressed: () async { await Clipboard.setData(ClipboardData(text: item.text)); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم نسخ الدعاء'))); }, icon: const Icon(Icons.copy, size: 18), label: const Text('نسخ')), const Spacer(), Expanded(child: Text(item.source, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)))])
          ])));
        }))
      ]),
    );
  }
}

class HajjUmrahPage extends StatefulWidget {
  const HajjUmrahPage({super.key});

  @override
  State<HajjUmrahPage> createState() => _HajjUmrahPageState();
}

class _HajjUmrahPageState extends State<HajjUmrahPage> {
  final List<Map<String, String>> steps = const [
    {'title': 'الإحرام والنية', 'text': 'الاغتسال والتجرد ولبس الإحرام والنية من الميقات، ثم التلبية.'},
    {'title': 'التلبية', 'text': 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ.'},
    {'title': 'الطواف', 'text': 'الطواف حول الكعبة سبعة أشواط، ويشرع الذكر والدعاء بما تيسر دون تخصيص دعاء لكل شوط.'},
    {'title': 'السعي', 'text': 'السعي بين الصفا والمروة سبعة أشواط، يبدأ بالصفا وينتهي بالمروة.'},
    {'title': 'الحلق أو التقصير', 'text': 'بعد السعي يحلق الرجل أو يقصر، والمرأة تقصر من أطراف شعرها، وبذلك تتم العمرة.'},
    {'title': 'الحج: يوم التروية', 'text': 'يوم الثامن من ذي الحجة، ثم التوجه إلى منى والصلاة فيها بحسب أحكام النسك.'},
    {'title': 'الحج: يوم عرفة', 'text': 'الوقوف بعرفة ركن الحج، ويكثر الحاج من الذكر والدعاء والتلبية حتى الغروب.'},
    {'title': 'مزدلفة', 'text': 'الإفاضة من عرفة بعد الغروب إلى مزدلفة، والصلاة والذكر والمبيت بحسب أحكام الحج.'},
    {'title': 'منى ورمي الجمار', 'text': 'رمي جمرة العقبة يوم النحر، ثم بقية الجمار في أيام التشريق وفق ترتيب وأوقات الرمي.'},
    {'title': 'طواف الإفاضة والوداع', 'text': 'طواف الإفاضة من أعمال الحج، وطواف الوداع عند مغادرة مكة لمن وجب عليه.'},
  ];

  final List<Map<String, String>> duas = const [
    {'title': 'دعاء التلبية', 'text': 'لَبَّيْكَ اللَّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ.'},
    {'title': 'عند الحجر الأسود', 'text': 'اللَّهُ أَكْبَرُ.'},
    {'title': 'بين الركن اليماني والحجر الأسود', 'text': 'رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً، وَفِي الْآخِرَةِ حَسَنَةً، وَقِنَا عَذَابَ النَّارِ.'},
    {'title': 'على الصفا والمروة', 'text': 'إِنَّ الصَّفَا وَالْمَرْوَةَ مِنْ شَعَائِرِ اللَّهِ، أَبْدَأُ بِمَا بَدَأَ اللَّهُ بِهِ.'},
    {'title': 'دعاء يوم عرفة', 'text': 'لَا إِلَهَ إِلَّا اللَّهُ وَحْدَهُ لَا شَرِيكَ لَهُ، لَهُ الْمُلْكُ وَلَهُ الْحَمْدُ، وَهُوَ عَلَى كُلِّ شَيْءٍ قَدِيرٌ.'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الحج والعمرة'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(14),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              gradient: const LinearGradient(colors: [Color(0xFF14532D), Color(0xFF0F766E)]),
            ),
            child: const Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Icon(Icons.mosque, color: Colors.white, size: 42),
              SizedBox(height: 8),
              Text('دليل المناسك', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.w800)),
              SizedBox(height: 5),
              Text('الحج والعمرة • الأذكار • الأدعية • خطوات عملية', textDirection: TextDirection.rtl, style: TextStyle(color: Colors.white70)),
            ]),
          ),
          const SizedBox(height: 16),
          const Text('مراحل الحج والعمرة', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...steps.asMap().entries.map((e) => Card(
            elevation: 0,
            child: ExpansionTile(
              leading: CircleAvatar(child: Text('${e.key + 1}')),
              title: Text(e.value['title']!, textDirection: TextDirection.rtl, style: const TextStyle(fontWeight: FontWeight.bold)),
              children: [Padding(padding: const EdgeInsets.fromLTRB(18, 0, 18, 18), child: Text(e.value['text']!, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: const TextStyle(fontSize: 17, height: 1.8)))],
            ),
          )),
          const SizedBox(height: 16),
          const Text('أدعية وأذكار مختارة', textDirection: TextDirection.rtl, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          ...duas.map((d) => Card(
            child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              Text(d['title']!, textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(d['text']!, textDirection: TextDirection.rtl, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, height: 1.9)),
              Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () async { await Clipboard.setData(ClipboardData(text: d['text']!)); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('تم النسخ'))); }, icon: const Icon(Icons.copy_outlined))),
            ])),
          )),
          const SizedBox(height: 12),
          const Text('ملاحظة: الأدعية في الطواف والسعي ليست مقسمة شرعًا على سبعة أشواط بدعاء مخصوص لكل شوط؛ يشرع الدعاء والذكر بما تيسر من الخير.', textDirection: TextDirection.rtl, textAlign: TextAlign.right, style: TextStyle(fontSize: 13, height: 1.7)),
        ],
      ),
    );
  }
}

class IraqPlace {
  final String id;
  final int level;
  final String name;
  final String englishName;
  final String? parentId;
  final double lat;
  final double lon;

  const IraqPlace({
    required this.id,
    required this.level,
    required this.name,
    required this.englishName,
    required this.parentId,
    required this.lat,
    required this.lon,
  });

  factory IraqPlace.fromJson(Map<String, dynamic> json) {
    final name = Map<String, dynamic>.from(
      json['name'] is Map ? json['name'] : const <String, dynamic>{},
    );
    final geo = Map<String, dynamic>.from(
      json['geo'] is Map ? json['geo'] : const <String, dynamic>{},
    );
    final parent = json['parent'] is Map
        ? Map<String, dynamic>.from(json['parent'])
        : null;

    return IraqPlace(
      id: json['id']?.toString() ?? '',
      level: int.tryParse(json['level']?.toString() ?? '') ?? 0,
      name: name['local']?.toString() ?? name['ar']?.toString() ?? '',
      englishName: name['en']?.toString() ?? '',
      parentId: json['parent_id']?.toString() ?? parent?['id']?.toString(),
      lat: double.tryParse(geo['lat']?.toString() ?? '') ?? 0,
      lon: double.tryParse(geo['lon']?.toString() ?? '') ?? 0,
    );
  }
}

class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  static const String _govUrl =
      'https://raw.githubusercontent.com/open-admin-data/'
      'iraq-administrative-divisions/master/data/all-governorate.json';
  static const String _districtUrl =
      'https://raw.githubusercontent.com/open-admin-data/'
      'iraq-administrative-divisions/master/data/all-district.json';
  static const String _subdistrictUrl =
      'https://raw.githubusercontent.com/open-admin-data/'
      'iraq-administrative-divisions/master/data/all-subdistrict.json';

  bool loadingPlaces = true;
  bool loadingTimes = false;
  String? error;
  Map<String, String> times = {};
  String dateText = '';

  List<IraqPlace> governorates = [];
  List<IraqPlace> districts = [];
  List<IraqPlace> subdistricts = [];

  IraqPlace? selectedGovernorate;
  IraqPlace? selectedDistrict;
  IraqPlace? selectedSubdistrict;

  @override
  void initState() {
    super.initState();
    _loadIraqPlaces();
  }

  Future<List<IraqPlace>> _fetchPlaces(String url) async {
    final response = await http.get(Uri.parse(url));
    if (response.statusCode != 200) {
      throw Exception('HTTP ${response.statusCode}');
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw Exception('بيانات المواقع غير صحيحة');
    }

    return decoded
        .map((item) => IraqPlace.fromJson(
              Map<String, dynamic>.from(item as Map),
            ))
        .where((place) => place.id.isNotEmpty)
        .toList();
  }

  Future<void> _loadIraqPlaces() async {
    setState(() {
      loadingPlaces = true;
      error = null;
    });

    try {
      final results = await Future.wait<List<IraqPlace>>([
        _fetchPlaces(_govUrl),
        _fetchPlaces(_districtUrl),
        _fetchPlaces(_subdistrictUrl),
      ]);

      final loadedGovernors = results[0];
      final loadedDistricts = results[1];
      final loadedSubdistricts = results[2];

      // حلبجة: نضيفها صراحةً حتى تشمل النسخة الحالية 19 محافظة.
      // المصدر المرجعي المفتوح أعلاه يحتوي 18 محافظة و101 قضاء و294 ناحية.
      // حلبجة أضيفت هنا مع التقسيم المتاح في المرجع العراقي المفتوح.
      loadedGovernors.add(
        const IraqPlace(
          id: 'IQ-HL',
          level: 1,
          name: 'حلبجة',
          englishName: 'Halabja',
          parentId: null,
          lat: 35.1787,
          lon: 45.9864,
        ),
      );

      const halabjaDistrictId = 'IQ-HL-Q01';
      loadedDistricts.add(
        const IraqPlace(
          id: halabjaDistrictId,
          level: 2,
          name: 'حلبجة',
          englishName: 'Halabja',
          parentId: 'IQ-HL',
          lat: 35.1787,
          lon: 45.9864,
        ),
      );

      const halabjaSubdistricts = [
        IraqPlace(
          id: 'IQ-HL-Q01-N01',
          level: 3,
          name: 'حلبجة',
          englishName: 'Halabja',
          parentId: halabjaDistrictId,
          lat: 35.1787,
          lon: 45.9864,
        ),
        IraqPlace(
          id: 'IQ-HL-Q01-N02',
          level: 3,
          name: 'سيروان',
          englishName: 'Sirwan',
          parentId: halabjaDistrictId,
          lat: 35.2548,
          lon: 45.9401,
        ),
        IraqPlace(
          id: 'IQ-HL-Q01-N03',
          level: 3,
          name: 'خورمال',
          englishName: 'Khurmal',
          parentId: halabjaDistrictId,
          lat: 35.2975,
          lon: 46.0349,
        ),
        IraqPlace(
          id: 'IQ-HL-Q01-N04',
          level: 3,
          name: 'بيارة',
          englishName: 'Byara',
          parentId: halabjaDistrictId,
          lat: 35.2308,
          lon: 46.1206,
        ),
        IraqPlace(
          id: 'IQ-HL-Q01-N05',
          level: 3,
          name: 'بامو',
          englishName: 'Bamo',
          parentId: halabjaDistrictId,
          lat: 35.1904,
          lon: 45.9712,
        ),
      ];

      loadedSubdistricts.addAll(halabjaSubdistricts);

      loadedGovernors.sort((a, b) => a.name.compareTo(b.name));
      loadedDistricts.sort((a, b) => a.name.compareTo(b.name));
      loadedSubdistricts.sort((a, b) => a.name.compareTo(b.name));

      if (!mounted) return;

      final defaultGovernorate = loadedGovernors.firstWhere(
        (item) => item.name == 'صلاح الدين',
        orElse: () => loadedGovernors.first,
      );

      setState(() {
        governorates = loadedGovernors;
        districts = loadedDistricts;
        subdistricts = loadedSubdistricts;
        selectedGovernorate = defaultGovernorate;
        selectedDistrict = _districtsFor(defaultGovernorate).isEmpty
            ? null
            : _districtsFor(defaultGovernorate).first;
        selectedSubdistrict = selectedDistrict == null
            ? null
            : (_subdistrictsFor(selectedDistrict!).isEmpty
                ? null
                : _subdistrictsFor(selectedDistrict!).first);
        loadingPlaces = false;
      });

      await _loadPrayerTimes();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        loadingPlaces = false;
        error = 'تعذر تحميل قائمة المحافظات والأقضية والنواحي. تحقق من الإنترنت.';
      });
    }
  }

  List<IraqPlace> _districtsFor(IraqPlace governorate) {
    return districts
        .where((item) => item.parentId == governorate.id)
        .toList();
  }

  List<IraqPlace> _subdistrictsFor(IraqPlace district) {
    return subdistricts
        .where((item) => item.parentId == district.id)
        .toList();
  }

  IraqPlace? get _activePlace =>
      selectedSubdistrict ?? selectedDistrict ?? selectedGovernorate;

  Future<void> _loadPrayerTimes() async {
    final place = _activePlace;
    if (place == null || place.lat == 0 || place.lon == 0) return;

    setState(() {
      loadingTimes = true;
      error = null;
    });

    try {
      final now = DateTime.now();
      final date =
          '${now.day.toString().padLeft(2, '0')}-'
          '${now.month.toString().padLeft(2, '0')}-${now.year}';

      final url = Uri.parse(
        'https://api.aladhan.com/v1/timings/$date'
        '?latitude=${place.lat}&longitude=${place.lon}'
        '&method=8&school=0&timezonestring=Asia%2FBaghdad',
      );

      final response = await http.get(url);
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final body = jsonDecode(response.body);
      final timings = Map<String, dynamic>.from(body['data']['timings']);
      final metaDate = body['data']['date'];

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
            '${metaDate?['gregorian']?['date'] ?? ''}  •  '
            '${metaDate?['hijri']?['date'] ?? ''} هـ';
        loadingTimes = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        loadingTimes = false;
        error = 'تعذر تحميل المواقيت. تحقق من الإنترنت.';
      });
    }
  }

  Future<void> _showPlacePicker({
    required String title,
    required List<IraqPlace> items,
    required IraqPlace? selected,
    required ValueChanged<IraqPlace> onSelected,
  }) async {
    if (items.isEmpty) return;

    final result = await showModalBottomSheet<IraqPlace>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: SizedBox(
            height: MediaQuery.of(sheetContext).size.height * 0.78,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    title,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: ListView.builder(
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return ListTile(
                        title: Text(
                          item.name,
                          textDirection: TextDirection.rtl,
                        ),
                        subtitle: Text(
                          item.englishName,
                          textDirection: TextDirection.ltr,
                        ),
                        trailing: item.id == selected?.id
                            ? const Icon(Icons.check_circle)
                            : const Icon(Icons.chevron_left),
                        onTap: () => Navigator.pop(sheetContext, item),
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

    if (result != null) {
      onSelected(result);
    }
  }

  Widget _placeSelector({
    required String label,
    required String? value,
    required VoidCallback? onTap,
    required IconData icon,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          label,
          textDirection: TextDirection.rtl,
          style: const TextStyle(fontSize: 12),
        ),
        subtitle: Text(
          value ?? 'اختر',
          textDirection: TextDirection.rtl,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: const Icon(Icons.keyboard_arrow_down_rounded),
        onTap: onTap,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final governorate = selectedGovernorate;
    final governorateDistricts =
        governorate == null ? <IraqPlace>[] : _districtsFor(governorate);
    final district = selectedDistrict;
    final districtSubdistricts =
        district == null ? <IraqPlace>[] : _subdistrictsFor(district);
    final activePlace = _activePlace;

    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: loadingPlaces || loadingTimes
                ? null
                : _loadPrayerTimes,
            icon: const Icon(Icons.refresh),
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: loadingPlaces
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadPrayerTimes,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  Card(
                    color: Theme.of(context)
                        .colorScheme
                        .primaryContainer,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.end,
                        children: [
                          const Text(
                            'موقع مواقيت الصلاة',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'المحافظة ← القضاء ← الناحية',
                            textDirection: TextDirection.rtl,
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  _placeSelector(
                    label: 'المحافظة',
                    value: governorate?.name,
                    icon: Icons.map_outlined,
                    onTap: () => _showPlacePicker(
                      title: 'اختر المحافظة',
                      items: governorates,
                      selected: selectedGovernorate,
                      onSelected: (value) {
                        final nextDistricts = _districtsFor(value);
                        final nextDistrict =
                            nextDistricts.isEmpty
                                ? null
                                : nextDistricts.first;
                        final nextSubs = nextDistrict == null
                            ? <IraqPlace>[]
                            : _subdistrictsFor(nextDistrict);

                        setState(() {
                          selectedGovernorate = value;
                          selectedDistrict = nextDistrict;
                          selectedSubdistrict =
                              nextSubs.isEmpty ? null : nextSubs.first;
                          times = {};
                          dateText = '';
                        });
                        _loadPrayerTimes();
                      },
                    ),
                  ),
                  _placeSelector(
                    label: 'القضاء',
                    value: district?.name,
                    icon: Icons.location_city_outlined,
                    onTap: governorateDistricts.isEmpty
                        ? null
                        : () => _showPlacePicker(
                              title: 'اختر القضاء',
                              items: governorateDistricts,
                              selected: selectedDistrict,
                              onSelected: (value) {
                                final nextSubs =
                                    _subdistrictsFor(value);
                                setState(() {
                                  selectedDistrict = value;
                                  selectedSubdistrict =
                                      nextSubs.isEmpty
                                          ? null
                                          : nextSubs.first;
                                  times = {};
                                  dateText = '';
                                });
                                _loadPrayerTimes();
                              },
                            ),
                  ),
                  _placeSelector(
                    label: 'الناحية',
                    value: districtSubdistricts.isEmpty
                        ? 'لا توجد نواحٍ مسجلة — يستخدم مركز القضاء'
                        : selectedSubdistrict?.name,
                    icon: Icons.place_outlined,
                    onTap: districtSubdistricts.isEmpty
                        ? null
                        : () => _showPlacePicker(
                              title: 'اختر الناحية',
                              items: districtSubdistricts,
                              selected: selectedSubdistrict,
                              onSelected: (value) {
                                setState(() {
                                  selectedSubdistrict = value;
                                  times = {};
                                  dateText = '';
                                });
                                _loadPrayerTimes();
                              },
                            ),
                  ),
                  if (activePlace != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          'الإحداثيات: ${activePlace.lat.toStringAsFixed(4)}, '
                          '${activePlace.lon.toStringAsFixed(4)}',
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (dateText.isNotEmpty)
                    Center(
                      child: Text(
                        dateText,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  if (loadingTimes)
                    const Padding(
                      padding: EdgeInsets.all(30),
                      child: Center(
                        child: CircularProgressIndicator(),
                      ),
                    ),
                  if (error != null)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Text(
                          error!,
                          textDirection: TextDirection.rtl,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ...times.entries.map(
                    (entry) => Card(
                      child: ListTile(
                        leading: Icon(
                          _prayerIcon(entry.key),
                          size: 30,
                        ),
                        title: Text(
                          entry.key,
                          textDirection: TextDirection.rtl,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        trailing: Text(
                          entry.value,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'المواقيت تُحسب حسب إحداثيات الموقع المختار. '
                    'قد تختلف دقائق بسيطة عن توقيت المسجد أو الجهة الرسمية المحلية.',
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 12),
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
