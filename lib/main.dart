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
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7),
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
            label: 'المكتبة',
          ),
        ],
      ),
    );
  }
}
class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  Widget _tile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget page,
  }) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 34),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => page),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('نور القرآن'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'الإعدادات',
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _tile(
            context,
            icon: Icons.menu_book,
            title: 'القرآن الكريم',
            subtitle: 'قراءة واستماع وتفسير وتلاوة متزامنة',
            page: const QuranPage(),
          ),
          _tile(
            context,
            icon: Icons.access_time,
            title: 'مواقيت الصلاة',
            subtitle: 'مواقيت اليوم حسب المدينة',
            page: const PrayerTimesPage(),
          ),
          _tile(
            context,
            icon: Icons.favorite,
            title: 'الأذكار والأدعية',
            subtitle: 'الصباح والمساء وأدعية مختارة',
            page: const AdhkarPage(),
          ),
          _tile(
            context,
            icon: Icons.download,
            title: 'التنزيلات',
            subtitle: 'أصوات القراء والتشغيل بدون إنترنت',
            page: const DownloadsPage(),
          ),
          _tile(
            context,
            icon: Icons.flag,
            title: 'ختم القرآن',
            subtitle: 'متابعة تقدم الختمة',
            page: const KhatmaPage(),
          ),
        ],
      ),
    );
  }
}

class QuranPage extends StatelessWidget {
  const QuranPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('القرآن الكريم'),
        centerTitle: true,
      ),
      body: ListView.builder(
        itemCount: surahNames.length,
        itemBuilder: (context, index) {
          final surahNumber = index + 1;

          return ListTile(
            leading: CircleAvatar(
              child: Text('$surahNumber'),
            ),
            title: Text(
              'سورة ${surahNames[index]}',
              textDirection: TextDirection.rtl,
            ),
            subtitle: Text(
              'صفحة ${surahStartPages[index]}',
              textDirection: TextDirection.rtl,
            ),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuranReaderPage(
                    surahNumber: surahNumber,
                    surahName: surahNames[index],
                  ),
                ),
              );
            },
          );
        },
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

  const AyahTiming({
    required this.ayah,
    required this.startTime,
    required this.endTime,
  });

  factory AyahTiming.fromJson(Map<String, dynamic> json) {
    return AyahTiming(
      ayah: int.tryParse(json['ayah']?.toString() ?? '') ?? -1,
      startTime: int.tryParse(json['start_time']?.toString() ?? '') ?? 0,
      endTime: int.tryParse(json['end_time']?.toString() ?? '') ?? 0,
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
  @override
  void initState() {
    super.initState();

    currentPage =
        surahStartPages[widget.surahNumber - 1];

    _positionSubscription =
        _audioPlayer.positionStream.listen(_onAudioPosition);

    _audioPlayer.processingStateStream.listen((state) {
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
      _speed = speed ?? _speed;
      _repeatCount = repeatCount ?? _repeatCount;
      _completedRepeats = 0;
      _handlingCompletion = false;

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

      _highlightAyah(ayah);
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
    if (_ayahTimings.isEmpty || _selectedRead == null) {
      return;
    }

    final ms = position.inMilliseconds;

    for (final item in _ayahTimings) {
      if (ms >= item.startTime &&
          ms < item.endTime) {
        _highlightAyah(
          '${widget.surahNumber}:${item.ayah}',
        );
        break;
      }
    }
  }

  void _highlightAyah(String ayah) {
    final parts = ayah.split(':');
    if (parts.length != 2) return;

    final surah = parts[0].replaceAll("'", "\\'");
    final verse = parts[1].replaceAll("'", "\\'");

    controller.runJavaScript("""
      document.querySelectorAll('.ayahPolygon').forEach(function(el) {
        el.classList.remove('selected');
        if (
          el.getAttribute('surah') === '$surah' &&
          el.getAttribute('ayah') === '$verse'
        ) {
          el.classList.add('selected');
        }
      });
    """);
  }

  void _handleAudioCompleted() {
    if (_handlingCompletion || _selectedAyah == null) {
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
  fill: rgba(103, 58, 183, 0.28) !important;
  stroke: #673AB7 !important;
  stroke-width: 2 !important;
}
</style>
</head>

<body>

<div id="mushaf"></div>

<script>

const pageNumber = $page;

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
        actions: [
          IconButton(
            tooltip: 'اختيار القارئ',
            icon: const Icon(Icons.headphones),
            onPressed: () => _showReciters(
              _selectedAyah ?? '${widget.surahNumber}:1',
            ),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'tafsir') {
                _showTafsir(
                  _selectedAyah ?? '${widget.surahNumber}:1',
                );
              } else if (value == 'info') {
                _showInfo(
                  _selectedAyah ?? '${widget.surahNumber}:1',
                );
              } else if (value == 'settings') {
                _showPlaybackSettings();
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                value: 'tafsir',
                child: Text('التفسير / الترجمة'),
              ),
              PopupMenuItem(
                value: 'info',
                child: Text('معلومات الآية'),
              ),
              PopupMenuItem(
                value: 'settings',
                child: Text('إعدادات التلاوة'),
              ),
            ],
          ),
        ],
      ),
      body: WebViewWidget(
        controller: controller,
      ),
      bottomNavigationBar: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (_selectedRead != null && _showPlayerBar)
              _buildPlayerBar(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('الصفحة $currentPage',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text('الجزء ${_juz(currentPage)}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  Widget _buildPlayerBar() {
    return StreamBuilder<PlayerState>(
      stream: _audioPlayer.playerStateStream,
      builder: (context, snapshot) {
        final playing = snapshot.data?.playing ?? _audioPlayer.playing;
        return Container(
          margin: const EdgeInsets.fromLTRB(10, 5, 10, 4),
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFF673AB7),
            borderRadius: BorderRadius.circular(28),
          ),
          child: Row(
            children: [
              IconButton(
                color: Colors.white,
                tooltip: 'السابق',
                onPressed: _playPreviousAyah,
                icon: const Icon(Icons.skip_previous_rounded),
              ),
              IconButton(
                color: Colors.white,
                tooltip: 'إيقاف',
                onPressed: () async {
                  await _audioPlayer.stop();
                  if (mounted) setState(() {});
                },
                icon: const Icon(Icons.stop_circle_outlined),
              ),
              Expanded(
                child: IconButton(
                  color: Colors.white,
                  iconSize: 34,
                  tooltip: playing ? 'إيقاف مؤقت' : 'تشغيل',
                  onPressed: () async {
                    if (playing) {
                      await _audioPlayer.pause();
                    } else {
                      await _audioPlayer.play();
                    }
                    if (mounted) setState(() {});
                  },
                  icon: Icon(
                    playing
                        ? Icons.pause_circle_filled
                        : Icons.play_circle_fill,
                  ),
                ),
              ),
              IconButton(
                color: Colors.white,
                tooltip: 'التالي',
                onPressed: _playNextAyah,
                icon: const Icon(Icons.skip_next_rounded),
              ),
              IconButton(
                color: Colors.white,
                tooltip: 'إعدادات التلاوة',
                onPressed: _showPlaybackSettings,
                icon: const Icon(Icons.settings_outlined),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _playPreviousAyah() async {
    if (_selectedRead == null) return;
    if (_ayahTimings.isEmpty) {
      _ayahTimings = await _loadAyahTimings(_selectedRead!);
    }
    int current = 1;
    if (_lastHighlightedAyah != null) {
      current = int.tryParse(_lastHighlightedAyah!.split(':').last) ?? 1;
    }
    final index = _ayahTimings.indexWhere((e) => e.ayah == current);
    final target = index > 0 ? _ayahTimings[index - 1] : _ayahTimings.first;

    if (_isFullSurahPlayback) {
      await _audioPlayer.seek(Duration(milliseconds: target.startTime));
      _highlightTiming(target);
      if (target.page != null && target.page != currentPage) {
        await _changePage(target.page!);
      }
    } else {
      await _prepareAndPlayAyah(
        '${widget.surahNumber}:${target.ayah}',
        _selectedRead!,
      );
    }
  }

  Future<void> _playNextAyah() async {
    if (_selectedRead == null) return;
    if (_ayahTimings.isEmpty) {
      _ayahTimings = await _loadAyahTimings(_selectedRead!);
    }
    int current = 0;
    if (_lastHighlightedAyah != null) {
      current = int.tryParse(_lastHighlightedAyah!.split(':').last) ?? 0;
    }
    final index = _ayahTimings.indexWhere((e) => e.ayah == current);
    final target = index >= 0 && index + 1 < _ayahTimings.length
        ? _ayahTimings[index + 1]
        : _ayahTimings.last;

    if (_isFullSurahPlayback) {
      await _audioPlayer.seek(Duration(milliseconds: target.startTime));
      _highlightTiming(target);
      if (target.page != null && target.page != currentPage) {
        await _changePage(target.page!);
      }
    } else {
      await _prepareAndPlayAyah(
        '${widget.surahNumber}:${target.ayah}',
        _selectedRead!,
      );
    }
  }

  void _showPlaybackSettings() {
    if (_selectedRead == null) return;
    double speed = _speed;
    int repeat = _repeatCount;
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'إعدادات التلاوة',
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                const Text('سرعة التلاوة', textDirection: TextDirection.rtl),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final v in [0.5, 0.75, 1.0, 1.25, 1.5, 2.0])
                      ChoiceChip(
                        label: Text('${v}x'),
                        selected: speed == v,
                        onSelected: (_) {
                          setSheetState(() => speed = v);
                          _speed = v;
                          _audioPlayer.setSpeed(v);
                        },
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                const Text('تكرار الآية', textDirection: TextDirection.rtl),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final v in [1, 2, 3, 5, 10, 0])
                      ChoiceChip(
                        label: Text(v == 0 ? '∞' : '$v'),
                        selected: repeat == v,
                        onSelected: (_) {
                          setSheetState(() => repeat = v);
                          _repeatCount = v;
                        },
                      ),
                  ],
                ),
                ListTile(
                  leading: const Icon(Icons.download),
                  title: const Text('تنزيل صوت السورة'),
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      await _downloadSurahForRead(_selectedRead!);
                      _showMessage('تم التنزيل ويمكن التشغيل بدون إنترنت');
                    } catch (_) {
                      _showMessage('تعذر تنزيل الصوت');
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.person),
                  title: const Text('تغيير القارئ'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showReciters(
                      _selectedAyah ?? '${widget.surahNumber}:1',
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
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
    _selectedRead = read;
    _selectedAyah = ayah;
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
                          onPressed: () =>
                              _audioPlayer.stop(),
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
  
class PrayerTimesPage extends StatefulWidget {
  const PrayerTimesPage({super.key});

  @override
  State<PrayerTimesPage> createState() => _PrayerTimesPageState();
}

class _PrayerTimesPageState extends State<PrayerTimesPage> {
  String city = 'Baghdad';
  String country = 'Iraq';
  Map<String, String> times = {};
  String? hijri;
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final now = DateTime.now();
    final date =
        '${now.day.toString().padLeft(2, '0')}-${now.month.toString().padLeft(2, '0')}-${now.year}';
    try {
      final uri = Uri.https(
        'api.aladhan.com',
        '/v1/timingsByCity/$date',
        {
          'city': city,
          'country': country,
          'method': '3',
          'school': '0',
        },
      );
      final response = await http.get(uri);
      if (response.statusCode != 200) throw Exception();
      final data = jsonDecode(response.body);
      final raw =
          Map<String, dynamic>.from(data['data']['timings'] ?? {});
      const wanted = [
        'Fajr',
        'Sunrise',
        'Dhuhr',
        'Asr',
        'Maghrib',
        'Isha',
      ];
      times = {
        for (final key in wanted)
          key: raw[key]?.toString().split(' ').first ?? '--:--',
      };
      hijri = data['data']?['date']?['hijri']?['date']?.toString();
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر جلب المواقيت. تحقق من المدينة والإنترنت.'),
          ),
        );
      }
    }
    if (mounted) setState(() => loading = false);
  }

  @override
  Widget build(BuildContext context) {
    const labels = {
      'Fajr': 'الفجر',
      'Sunrise': 'الشروق',
      'Dhuhr': 'الظهر',
      'Asr': 'العصر',
      'Maghrib': 'المغرب',
      'Isha': 'العشاء',
    };
    return Scaffold(
      appBar: AppBar(
        title: const Text('مواقيت الصلاة'),
        centerTitle: true,
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.location_city),
                title: Text('$city، $country'),
                subtitle: Text(hijri == null ? 'اليوم' : 'التاريخ الهجري: $hijri'),
                trailing: const Icon(Icons.edit),
                onTap: _editLocation,
              ),
            ),
            if (loading)
              const Padding(
                padding: EdgeInsets.all(20),
                child: Center(child: CircularProgressIndicator()),
              ),
            for (final entry in times.entries)
              Card(
                child: ListTile(
                  leading: Icon(_iconForPrayer(entry.key)),
                  title: Text(
                    labels[entry.key] ?? entry.key,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    entry.value,
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            const SizedBox(height: 8),
            const Text(
              'المواقيت محسوبة آلياً وقد تختلف قليلاً عن التوقيت الرسمي المحلي؛ يمكن تعديلها لاحقاً.',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForPrayer(String key) {
    switch (key) {
      case 'Fajr':
        return Icons.nightlight;
      case 'Sunrise':
        return Icons.wb_sunny_outlined;
      case 'Dhuhr':
        return Icons.light_mode;
      case 'Asr':
        return Icons.wb_sunny;
      case 'Maghrib':
        return Icons.brightness_4;
      default:
        return Icons.nights_stay;
    }
  }

  void _editLocation() {
    final cityController = TextEditingController(text: city);
    final countryController = TextEditingController(text: country);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('موقع المواقيت'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: cityController,
              decoration: const InputDecoration(labelText: 'المدينة'),
            ),
            TextField(
              controller: countryController,
              decoration: const InputDecoration(labelText: 'الدولة'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () {
              city = cityController.text.trim();
              country = countryController.text.trim();
              Navigator.pop(ctx);
              _load();
            },
            child: const Text('حفظ'),
          ),
        ],
      ),
    );
  }
}

class AdhkarPage extends StatefulWidget {
  const AdhkarPage({super.key});

  @override
  State<AdhkarPage> createState() => _AdhkarPageState();
}

class _AdhkarPageState extends State<AdhkarPage> {
  int tab = 0;
  final Map<String, int> counts = {};

  static const morning = [
    'أصبحنا وأصبح الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له.',
    'اللهم بك أصبحنا وبك أمسينا وبك نحيا وبك نموت وإليك النشور.',
    'رضيت بالله رباً وبالإسلام ديناً وبمحمد ﷺ نبياً.',
    'سبحان الله وبحمده.',
  ];

  static const evening = [
    'أمسينا وأمسى الملك لله والحمد لله، لا إله إلا الله وحده لا شريك له.',
    'اللهم إني أمسيت أشهدك وأشهد حملة عرشك وملائكتك وجميع خلقك.',
    'أعوذ بكلمات الله التامات من شر ما خلق.',
    'سبحان الله وبحمده.',
  ];

  static const duas = [
    'ربنا آتنا في الدنيا حسنة وفي الآخرة حسنة وقنا عذاب النار.',
    'رب ارحمهما كما ربياني صغيراً.',
    'رب اغفر لي وتب علي إنك أنت التواب الرحيم.',
    'لا إله إلا الله العظيم الحليم، لا إله إلا الله رب العرش العظيم.',
  ];

  List<String> get items {
    if (tab == 0) return morning;
    if (tab == 1) return evening;
    return duas;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار والأدعية'),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 0, label: Text('الصباح')),
                ButtonSegment(value: 1, label: Text('المساء')),
                ButtonSegment(value: 2, label: Text('الأدعية')),
              ],
              selected: {tab},
              onSelectionChanged: (v) => setState(() => tab = v.first),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (_, i) {
                final key = '$tab-$i';
                final count = counts[key] ?? 0;
                return Card(
                  child: InkWell(
                    onTap: () => setState(() => counts[key] = count + 1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              items[i],
                              textDirection: TextDirection.rtl,
                              style: const TextStyle(
                                fontSize: 18,
                                height: 1.8,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          CircleAvatar(child: Text('$count')),
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
    );
  }
}

class DownloadsPage extends StatelessWidget {
  const DownloadsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التنزيلات'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: const [
          Card(
            child: ListTile(
              leading: Icon(Icons.headphones),
              title: Text('أصوات القراء'),
              subtitle: Text(
                'تنزيل صوت السورة يتم من صفحة الاستماع داخل المصحف، وبعد التنزيل يعمل بدون إنترنت.',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.menu_book),
              title: Text('المصاحف'),
              subtitle: Text('قسم جاهز لإضافة تنزيل المصحف المفضل لاحقاً.'),
            ),
          ),
        ],
      ),
    );
  }
}

class KhatmaPage extends StatefulWidget {
  const KhatmaPage({super.key});

  @override
  State<KhatmaPage> createState() => _KhatmaPageState();
}

class _KhatmaPageState extends State<KhatmaPage> {
  int pages = 0;
  static const total = 604;

  @override
  Widget build(BuildContext context) {
    final value = (pages / total).clamp(0.0, 1.0);
    return Scaffold(
      appBar: AppBar(title: const Text('ختم القرآن'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.flag, size: 60),
            const SizedBox(height: 12),
            Text(
              '$pages من $total صفحة',
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(value: value, minHeight: 10),
            const SizedBox(height: 12),
            Text('${(value * 100).toStringAsFixed(1)}%'),
            Slider(
              value: pages.toDouble(),
              min: 0,
              max: total.toDouble(),
              divisions: total,
              onChanged: (v) => setState(() => pages = v.round()),
            ),
            FilledButton.icon(
              onPressed: () => setState(() => pages = 0),
              icon: const Icon(Icons.refresh),
              label: const Text('بدء ختمة جديدة'),
            ),
          ],
        ),
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool night = false;
  bool keepScreen = true;
  bool notifications = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات'), centerTitle: true),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('الوضع الليلي'),
            value: night,
            onChanged: (v) => setState(() => night = v),
          ),
          SwitchListTile(
            title: const Text('إبقاء الشاشة مضاءة'),
            value: keepScreen,
            onChanged: (v) => setState(() => keepScreen = v),
          ),
          SwitchListTile(
            title: const Text('تنبيهات الأذكار والمواقيت'),
            value: notifications,
            onChanged: (v) => setState(() => notifications = v),
          ),
          const ListTile(
            leading: Icon(Icons.display_settings),
            title: Text('خصائص العرض'),
            subtitle: Text('يمكن توسيعها لاحقاً لإضافة ألوان وخيارات المصحف.'),
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('اللغة'),
            subtitle: Text('العربية'),
          ),
          const ListTile(
            leading: Icon(Icons.info_outline),
            title: Text('عن نور القرآن'),
            subtitle: Text('تطبيق قرآن متعدد الميزات.'),
          ),
        ],
      ),
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('المكتبة'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book, size: 35),
              title: const Text('القرآن الكريم'),
              subtitle: const Text('قراءة واستماع وتفسير'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const QuranPage()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite, size: 35),
              title: const Text('الأذكار والأدعية'),
              subtitle: const Text('الصباح والمساء والأدعية'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AdhkarPage()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.access_time, size: 35),
              title: const Text('مواقيت الصلاة'),
              subtitle: const Text('مواقيت اليوم حسب المدينة'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PrayerTimesPage()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.download, size: 35),
              title: const Text('التنزيلات'),
              subtitle: const Text('الأصوات والمحتوى المتاح بدون إنترنت'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const DownloadsPage()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.flag, size: 35),
              title: const Text('ختم القرآن'),
              subtitle: const Text('متابعة التقدم'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KhatmaPage()),
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.settings, size: 35),
              title: const Text('الإعدادات'),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
