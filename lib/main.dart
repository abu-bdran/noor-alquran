import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
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
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF673AB7),
        ),
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// أسماء السور
// ============================================================

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

// ============================================================
// بداية كل سورة في مصحف المدينة
// ============================================================

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
  603, 604, 604, 604, 604,
];

// ============================================================
// الرئيسية
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final pages = const [
    HomeContent(),
    QuranPage(),
    AdhkarPage(),
    LibraryPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: pages[selectedIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: selectedIndex,
        onDestinationSelected: (index) {
          setState(() {
            selectedIndex = index;
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

// ============================================================
// الرئيسية
// ============================================================

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const Icon(
                Icons.menu_book,
                size: 80,
                color: Color(0xFF673AB7),
              ),
              const SizedBox(height: 15),
              const Text(
                'نور القرآن',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF673AB7),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'القرآن الكريم والأذكار والمكتبة الإسلامية',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              FilledButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const QuranPage(),
                    ),
                  );
                },
                icon: const Icon(Icons.menu_book),
                label: const Text('فتح القرآن الكريم'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// قائمة السور
// ============================================================

class QuranPage extends StatefulWidget {
  const QuranPage({super.key});

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  String search = '';

  @override
  Widget build(BuildContext context) {
    final indexes = List.generate(
      surahNames.length,
      (i) => i,
    ).where(
      (i) => surahNames[i].contains(search.trim()),
    ).toList();

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(18),
            child: Text(
              'القرآن الكريم',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF673AB7),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحثي عن سورة',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) {
                setState(() {
                  search = value;
                });
              },
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: ListView.builder(
              itemCount: indexes.length,
              itemBuilder: (context, index) {
                final surahIndex = indexes[index];
                final surahNumber = surahIndex + 1;

                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE9E0FF),
                      child: Text('$surahNumber'),
                    ),
                    title: Text(
                      'سورة ${surahNames[surahIndex]}',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    subtitle: Text(
                      'صفحة ${surahStartPages[surahIndex]}',
                      textDirection: TextDirection.rtl,
                    ),
                    trailing: const Icon(Icons.chevron_left),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuranReaderPage(
                            surahNumber: surahNumber,
                            surahName: surahNames[surahIndex],
                          ),
                        ),
                      );
                    },
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
// ============================================================
// صفحة قراءة القرآن
// ============================================================

class QuranReaderPage extends StatefulWidget {
  final int surahNumber;
  final String surahName;

  const QuranReaderPage({
    super.key,
    required this.surahNumber,
    required this.surahName,
  });

  @override
  State<QuranReaderPage> createState() =>
      _QuranReaderPageState();
}

class _QuranReaderPageState
    extends State<QuranReaderPage> {
  late WebViewController controller;

  late int currentPage;

  int? selectedSurah;
  int? selectedAyah;

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
        const Color(0xFFF7F4E9),
      )
      ..addJavaScriptChannel(
        'AyahChannel',
        onMessageReceived: (message) {
          final parts =
              message.message.split(':');

          if (parts.length == 2) {
            final surah =
                int.tryParse(parts[0]);
            final ayah =
                int.tryParse(parts[1]);

            if (surah != null && ayah != null) {
              setState(() {
                selectedSurah = surah;
                selectedAyah = ayah;
              });

              _showAyahMenu(
                surah,
                ayah,
              );
            }
          }
        },
      )
      ..addJavaScriptChannel(
        'PageChannel',
        onMessageReceived: (message) {
          final page =
              int.tryParse(message.message);

          if (page != null &&
              page >= 1 &&
              page <= 604) {
            setState(() {
              currentPage = page;
            });
          }
        },
      )
      ..loadHtmlString(
        _html(currentPage),
      );
  }

  String _html(int page) {
    final p =
        page.toString().padLeft(3, '0');

    final svgUrl =
        'https://cdn.quran.ws/svg/pages/v1.1.1/hafs-kfqc/$p.svg';

    return '''
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
<meta name="viewport"
      content="width=device-width,
      initial-scale=1.0,
      maximum-scale=1.0,
      user-scalable=yes">

<style>
html, body {
  margin: 0;
  padding: 0;
  background: #F7F4E9;
  width: 100%;
  height: 100%;
}

body {
  display: flex;
  justify-content: center;
  align-items: flex-start;
  overflow: auto;
}

#mushaf {
  width: 100%;
  max-width: 900px;
  margin: 0 auto;
  position: relative;
}

#mushaf svg {
  width: 100%;
  height: auto;
  display: block;
}

.ayahPolygon {
  fill: transparent;
  stroke: transparent;
}

.ayahPolygon.selected {
  fill: rgba(103, 58, 183, 0.15);
  stroke: rgba(103, 58, 183, 0.45);
  stroke-width: 2;
}
</style>
</head>

<body>

<div id="mushaf"></div>

<script>

let currentAudio = null;

fetch('$svgUrl')
  .then(response => response.text())
  .then(svg => {

    document.getElementById('mushaf')
      .innerHTML = svg;

    const polygons =
      document.querySelectorAll(
        '.ayahPolygon'
      );

    polygons.forEach(function(poly) {

      poly.addEventListener(
        'click',
        function() {

          polygons.forEach(function(p) {
            p.classList.remove(
              'selected'
            );
          });

          poly.classList.add(
            'selected'
          );

          const surah =
            poly.getAttribute('surah');

          const ayah =
            poly.getAttribute('ayah');

          if (surah && ayah) {
            AyahChannel.postMessage(
              surah + ':' + ayah
            );
          }
        }
      );

    });

  })
  .catch(function(error) {
    document.getElementById('mushaf')
      .innerHTML =
      '<div style="padding:30px;text-align:center;">' +
      'تعذر تحميل السورة' +
      '</div>';
  });

function playAyah(
  surah,
  ayah,
  speed
) {

  if (currentAudio) {
    currentAudio.pause();
    currentAudio = null;
  }

  const url =
    'https://cdn.islamic.network/quran/audio/128/ar.alafasy/' +
    surah + '/' +
    ayah +
    '.mp3';

  currentAudio =
    new Audio(url);

  currentAudio.playbackRate =
    speed || 1.0;

  currentAudio.play();
}

function setSpeed(speed) {
  if (currentAudio) {
    currentAudio.playbackRate =
      speed;
  }
}

function pauseAyah() {
  if (currentAudio) {
    currentAudio.pause();
  }
}

function stopAyah() {
  if (currentAudio) {
    currentAudio.pause();
    currentAudio.currentTime = 0;
  }
}

</script>

</body>
</html>
''';
  }
    Future<String> _getAyahText(
    int surah,
    int ayah,
  ) async {
    final url = Uri.parse(
      'https://api.alquran.cloud/v1/ayah/'
      '$surah:$ayah/quran-uthmani',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load ayah');
    }

    final data =
        jsonDecode(response.body);

    return data['data']['text'];
  }

  Future<String> _getTafsir(
    int surah,
    int ayah,
  ) async {
    final url = Uri.parse(
      'https://quranenc.com/api/v1/translation/'
      'aya/arabic_moyassar/'
      '$surah/$ayah',
    );

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Failed to load tafsir');
    }

    final data =
        jsonDecode(response.body);

    return data['result']['translation'];
  }

  void _showAyahMenu(
    int surah,
    int ayah,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: FutureBuilder<String>(
              future: _getAyahText(
                surah,
                ayah,
              ),
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const SizedBox(
                    height: 220,
                    child: Center(
                      child: Text(
                        'تعذر تحميل الآية',
                        style: TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    ),
                  );
                }

                final text =
                    snapshot.data ?? '';

                return SingleChildScrollView(
                  child: Column(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      Container(
                        width: 45,
                        height: 5,
                        decoration:
                            BoxDecoration(
                          color:
                              Colors.grey.shade300,
                          borderRadius:
                              BorderRadius.circular(
                            10,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      Text(
                        'الآية $ayah',
                        style:
                            const TextStyle(
                          fontSize: 20,
                          fontWeight:
                              FontWeight.bold,
                          color:
                              Color(0xFF673AB7),
                        ),
                      ),

                      const SizedBox(height: 15),

                      Text(
                        text,
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          fontSize: 22,
                          height: 2,
                        ),
                      ),

                      const SizedBox(height: 25),

                      Wrap(
                        alignment:
                            WrapAlignment.center,
                        spacing: 10,
                        runSpacing: 10,
                        children: [
                          _actionButton(
                            icon: Icons.copy,
                            title: 'نسخ',
                            onTap: () async {
                              await Clipboard
                                  .setData(
                                ClipboardData(
                                  text: text,
                                ),
                              );

                              if (context.mounted) {
                                Navigator.pop(
                                  context,
                                );

                                ScaffoldMessenger
                                    .of(this.context)
                                    .showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'تم نسخ الآية',
                                    ),
                                  ),
                                );
                              }
                            },
                          ),

                          _actionButton(
                            icon:
                                Icons.share,
                            title: 'مشاركة',
                            onTap: () async {
                              await Share.share(
                                text,
                              );
                            },
                          ),

                          _actionButton(
                            icon:
                                Icons.headphones,
                            title: 'استماع',
                            onTap: () {
                              Navigator.pop(
                                context,
                              );

                              _showAudioControls(
                                surah,
                                ayah,
                              );
                            },
                          ),

                          _actionButton(
                            icon:
                                Icons.menu_book,
                            title: 'تفسير',
                            onTap: () {
                              Navigator.pop(
                                context,
                              );

                              _showTafsir(
                                surah,
                                ayah,
                              );
                            },
                          ),

                          _actionButton(
                            icon:
                                Icons.bookmark_border,
                            title: 'حفظ',
                            onTap: () {
                              Navigator.pop(
                                context,
                              );

                              ScaffoldMessenger
                                  .of(this.context)
                                  .showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'تم حفظ الآية',
                                  ),
                                ),
                              );
                            },
                          ),

                          _actionButton(
                            icon:
                                Icons.info_outline,
                            title: 'معلومات',
                            onTap: () {
                              Navigator.pop(
                                context,
                              );

                              _showInfo(
                                surah,
                                ayah,
                              );
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return SizedBox(
      width: 90,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Container(
          padding:
              const EdgeInsets.symmetric(
            vertical: 12,
          ),
          decoration: BoxDecoration(
            color:
                const Color(0xFFF5F1FF),
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color:
                    const Color(0xFF673AB7),
                size: 28,
              ),
              const SizedBox(height: 5),
              Text(title),
            ],
          ),
        ),
      ),
    );
  }
    void _showAudioControls(
    int surah,
    int ayah,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape:
          const RoundedRectangleBorder(
        borderRadius:
            BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        double speed = 1.0;

        return StatefulBuilder(
          builder:
              (context, setModalState) {
            return Directionality(
              textDirection:
                  TextDirection.rtl,
              child: Padding(
                padding:
                    const EdgeInsets.all(22),
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.headphones,
                      size: 48,
                      color:
                          Color(0xFF673AB7),
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'استماع — الآية $ayah',
                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    const Text(
                      'سرعة القارئ',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Wrap(
                      spacing: 8,
                      children: [
                        for (final value
                            in [
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
                              setModalState(() {
                                speed = value;
                              });

                              controller
                                  .runJavaScript(
                                'setSpeed($value);',
                              );
                            },
                          ),
                      ],
                    ),

                    const SizedBox(height: 18),

                    Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        IconButton.filled(
                          onPressed: () {
                            controller
                                .runJavaScript(
                              'playAyah('
                              '$surah,'
                              '$ayah,'
                              '$speed'
                              ');',
                            );
                          },
                          icon: const Icon(
                            Icons.play_arrow,
                          ),
                        ),

                        const SizedBox(
                          width: 15,
                        ),

                        IconButton.filled(
                          onPressed: () {
                            controller
                                .runJavaScript(
                              'pauseAyah();',
                            );
                          },
                          icon: const Icon(
                            Icons.pause,
                          ),
                        ),

                        const SizedBox(
                          width: 15,
                        ),

                        IconButton.filled(
                          onPressed: () {
                            controller
                                .runJavaScript(
                              'stopAyah();',
                            );
                          },
                          icon: const Icon(
                            Icons.stop,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showTafsir(
    int surah,
    int ayah,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection:
              TextDirection.rtl,
          child: AlertDialog(
            title: Text(
              'تفسير الآية $ayah',
            ),
            content:
                FutureBuilder<String>(
              future: _getTafsir(
                surah,
                ayah,
              ),
              builder:
                  (context, snapshot) {
                if (snapshot
                        .connectionState ==
                    ConnectionState.waiting) {
                  return const SizedBox(
                    height: 100,
                    child: Center(
                      child:
                          CircularProgressIndicator(),
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return const Text(
                    'تعذر تحميل التفسير.\n'
                    'تأكدي من اتصال الإنترنت.',
                  );
                }

                return SingleChildScrollView(
                  child: Text(
                    snapshot.data ?? '',
                    style:
                        const TextStyle(
                      fontSize: 17,
                      height: 1.8,
                    ),
                  ),
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(
                    context,
                  );
                },
                child:
                    const Text('إغلاق'),
              ),
            ],
          ),
        );
      },
    );
  }
    void _showInfo(
    int surah,
    int ayah,
  ) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'معلومات الآية',
          ),
          content: Text(
            'سورة ${surahNames[surah - 1]}\n'
            'رقم السورة: $surah\n'
            'رقم الآية: $ayah\n'
            'الصفحة: $currentPage\n'
            'الجزء: ${_juz(currentPage)}',
            textDirection:
                TextDirection.rtl,
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

  int _juz(int page) {
    const starts = [
      1,
      22,
      42,
      62,
      82,
      102,
      122,
      142,
      162,
      182,
      202,
      222,
      242,
      262,
      282,
      302,
      322,
      342,
      362,
      382,
      402,
      422,
      442,
      462,
      482,
      502,
      522,
      542,
      562,
      582,
    ];

    int juz = 1;

    for (int i = 0;
        i < starts.length;
        i++) {
      if (page >= starts[i]) {
        juz = i + 1;
      }
    }

    return juz;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF7F4E9),

      appBar: AppBar(
        backgroundColor:
            const Color(0xFF673AB7),
        foregroundColor:
            Colors.white,
        centerTitle: true,
        title: Text(
          'سورة ${widget.surahName}',
        ),
      ),

      body: Column(
        children: [
          Expanded(
            child: WebViewWidget(
              controller: controller,
            ),
          ),

          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 10,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment
                      .spaceBetween,
              children: [
                Text(
                  '${_juz(currentPage)} جزء',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                    color:
                        Color(0xFF673AB7),
                  ),
                ),

                Text(
                  '$currentPage',
                  style:
                      const TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Text(
                  '604',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
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
// ============================================================
// الأذكار
// ============================================================

class AdhkarPage extends StatelessWidget {
  const AdhkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final list = [
      'سبحان الله وبحمده',
      'أستغفر الله وأتوب إليه',
      'لا إله إلا الله وحده لا شريك له',
      'اللهم صل وسلم على نبينا محمد',
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'الأذكار',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF673AB7),
            ),
          ),
          const SizedBox(height: 20),
          ...list.map(
            (item) => Card(
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Text(
                  item,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 19,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// المكتبة
// ============================================================

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: const [
          Text(
            'المكتبة الإسلامية',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Color(0xFF673AB7),
            ),
          ),
          SizedBox(height: 20),
          Card(
            child: ListTile(
              leading: Icon(Icons.menu_book),
              title: Text('القرآن الكريم'),
              subtitle: Text(
                'مصحف المدينة المنورة',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.favorite),
              title: Text('الأذكار'),
              subtitle: Text(
                'أذكار المسلم',
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.auto_stories),
              title: Text('كتب إسلامية'),
              subtitle: Text('قريباً'),
            ),
          ),
        ],
      ),
    );
  }
}
