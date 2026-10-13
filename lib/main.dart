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
class Moshaf {
  final String name;
  final String server;
  final List<String> surahList;

  Moshaf({
    required this.name,
    required this.server,
    required this.surahList,
  });

  factory Moshaf.fromJson(Map<String, dynamic> json) {
    return Moshaf(
      name: json['name']?.toString() ?? '',
      server: json['server']?.toString() ?? '',
      surahList: (json['surah_list']?.toString() ?? '')
          .split(',')
          .where((e) => e.isNotEmpty)
          .toList(),
    );
  }
}

class Reciter {
  final int id;
  final String name;
  final List<Moshaf> moshaf;

  Reciter({
    required this.id,
    required this.name,
    required this.moshaf,
  });

  factory Reciter.fromJson(Map<String, dynamic> json) {
    return Reciter(
      id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
      name: json['name']?.toString() ?? '',
      moshaf: (json['moshaf'] as List? ?? [])
          .map(
            (item) => Moshaf.fromJson(
              Map<String, dynamic>.from(item),
            ),
          )
          .toList(),
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
List<Reciter> reciters = [];
bool loadingReciters = false;
  @override
  void initState() {
    super.initState();

    currentPage =
        surahStartPages[widget.surahNumber - 1];

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
        'https://mp3quran.net/api/v3/reciters?language=ar',
      ),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);

      final List<dynamic> list = data['reciters'] ?? [];

      setState(() {
        reciters = list
            .map(
              (item) => Reciter.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();

        loadingReciters = false;
      });
    } else {
      setState(() {
        loadingReciters = false;
      });
    }
  } catch (e) {
    setState(() {
      loadingReciters = false;
    });
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
</style>
</head>

<body>

<div id="mushaf"></div>

<script>

let audio = null;
let currentSpeed = 1.0;

function playAyah(ayah) {

  if (audio) {
    audio.pause();
  }

  const parts = ayah.split(':');

  if (parts.length !== 2) {
    return;
  }

  const surah = parts[0];
  const verse = parts[1];

  fetch(
    'https://api.alquran.cloud/v1/ayah/' +
    surah +
    ':' +
    verse +
    '/ar.alafasy'
  )
  .then(response => response.json())
  .then(data => {

    const url = data.data.audio;

    audio = new Audio(url);

    audio.playbackRate = currentSpeed;

    audio.play();
  });
}

function pauseAyah() {

  if (audio) {
    audio.pause();
  }
}

function stopAyah() {

  if (audio) {
    audio.pause();
    audio.currentTime = 0;
  }
}

function setSpeed(speed) {

  currentSpeed = speed;

  if (audio) {
    audio.playbackRate = speed;
  }
}

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
                  _showReciters();
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
  void _showMoshafList(Reciter reciter) {
  if (reciter.moshaf.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('لا توجد رواية متاحة لهذا القارئ'),
      ),
    );
    return;
  }

  showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                reciter.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textDirection: TextDirection.rtl,
              ),
            ),
            const Divider(),
            ...reciter.moshaf.map(
              (moshaf) {
                return ListTile(
                  leading: const Icon(Icons.menu_book),
                  title: Text(
                    moshaf.name,
                    textDirection: TextDirection.rtl,
                  ),
                  trailing: const Icon(
                    Icons.arrow_back_ios,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.pop(context);
                    _downloadSurah(moshaf);
                  },
                );
              },
            ),
          ],
        ),
      );
    },
  );
  }
Future<void> _showReciters() async {
  if (reciters.isEmpty) {
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

      if (reciters.isEmpty) {
        return const SizedBox(
          height: 250,
          child: Center(
            child: Text('تعذر تحميل قائمة القرّاء'),
          ),
        );
      }

      return SafeArea(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.75,
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
                  itemCount: reciters.length,
                  itemBuilder: (context, index) {
                    final reciter = reciters[index];

                    return ListTile(
                      leading: const CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      title: Text(
                        reciter.name,
                        textDirection: TextDirection.rtl,
                      ),
                      trailing: const Icon(
                        Icons.arrow_back_ios,
                        size: 16,
                      ),
                      onTap: () {
                        Navigator.pop(context);
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
  void _showAudioControls(String ayah) {
    double speed = 1.0;

    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    'الاستماع إلى الآية',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        iconSize: 36,
                        onPressed: () {
                          controller.runJavaScript(
                            'playAyah("$ayah");',
                          );
                        },
                        icon: const Icon(
                          Icons.play_circle_fill,
                        ),
                      ),
                      IconButton(
                        iconSize: 36,
                        onPressed: () {
                          controller.runJavaScript(
                            'pauseAyah();',
                          );
                        },
                        icon: const Icon(
                          Icons.pause_circle,
                        ),
                      ),
                      IconButton(
                        iconSize: 36,
                        onPressed: () {
                          controller.runJavaScript(
                            'stopAyah();',
                          );
                        },
                        icon: const Icon(
                          Icons.stop_circle,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 15),

                  const Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      'سرعة التلاوة',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Wrap(
                    spacing: 8,
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
                          label: Text('${value}x'),
                          selected: speed == value,
                          onSelected: (_) {
                            setSheetState(() {
                              speed = value;
                            });

                            controller.runJavaScript(
                              'setSpeed($value);',
                            );
                          },
                        ),
                    ],
                  ),

                  const SizedBox(height: 20),
                ],
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
