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
          Card(
            child: ListTile(
              leading: const Icon(Icons.menu_book, size: 36),
              title: const Text(
                'القرآن الكريم',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('اقرأ القرآن الكريم'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const QuranPage(),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          Card(
            child: ListTile(
              leading: const Icon(Icons.favorite, size: 36),
              title: const Text(
                'الأذكار',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: const Text('أذكار الصباح والمساء وغيرها'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const AdhkarPage(),
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
      ),
      body: WebViewWidget(
        controller: controller,
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 10,
          ),
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
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
  class AdhkarPage extends StatelessWidget {
  const AdhkarPage({super.key});

  static const List<String> adhkar = [
    'سبحان الله وبحمده',
    'أستغفر الله وأتوب إليه',
    'لا إله إلا الله وحده لا شريك له',
    'اللهم صل وسلم على نبينا محمد',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('الأذكار'),
        centerTitle: true,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: adhkar.length,
        itemBuilder: (context, index) {
          return Card(
            margin: const EdgeInsets.symmetric(
              vertical: 6,
            ),
            child: ListTile(
              leading: CircleAvatar(
                child: Text('${index + 1}'),
              ),
              title: Text(
                adhkar[index],
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              trailing: const Icon(
                Icons.favorite_border,
              ),
            ),
          );
        },
      ),
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('المكتبة'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.menu_book,
                size: 35,
              ),
              title: const Text(
                'القرآن الكريم',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'قراءة القرآن الكريم',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.favorite,
                size: 35,
              ),
              title: const Text(
                'الأذكار',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'الأذكار والأدعية',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(
                Icons.library_books,
                size: 35,
              ),
              title: const Text(
                'كتب إسلامية',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'قريباً',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
