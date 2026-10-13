import 'package:flutter/material.dart';

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
          seedColor: const Color(0xFF176B5B),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F3EA),
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// الصفحة الرئيسية
// ============================================================

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
        backgroundColor: Colors.white,
        indicatorColor: const Color(0xFFDCEFE9),
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
// محتوى الرئيسية
// ============================================================

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 15),

            const Text(
              'نور القرآن',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
                color: Color(0xFF176B5B),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'رفيقك في تلاوة القرآن والذكر',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 30),

            Card(
              elevation: 2,
              color: const Color(0xFFEAF5F1),
              child: Padding(
                padding: const EdgeInsets.all(22),
                child: Column(
                  children: [
                    const Icon(
                      Icons.menu_book,
                      size: 55,
                      color: Color(0xFF176B5B),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'اقرأ القرآن الكريم',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'مصحف المدينة المنورة الملون بأحكام التجويد',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                      ),
                    ),
                    const SizedBox(height: 18),
                    FilledButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const QuranPage(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('فتح القرآن'),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF5F1),
                  child: Icon(
                    Icons.favorite,
                    color: Color(0xFF176B5B),
                  ),
                ),
                title: const Text(
                  'الأذكار اليومية',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'أذكار الصباح والمساء وأذكار المسلم',
                ),
                trailing: const Icon(Icons.chevron_left),
              ),
            ),

            const SizedBox(height: 10),

            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFEAF5F1),
                  child: Icon(
                    Icons.auto_stories,
                    color: Color(0xFF176B5B),
                  ),
                ),
                title: const Text(
                  'المكتبة الإسلامية',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: const Text(
                  'كتب ومحتوى إسلامي',
                ),
                trailing: const Icon(Icons.chevron_left),
              ),
            ),
          ],
        ),
      ),
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
// صفحات بداية السور في مصحف المدينة 604 صفحة
// ============================================================

const List<int> surahStartPages = [
  1,
  2,
  50,
  77,
  106,
  128,
  151,
  177,
  187,
  208,
  221,
  235,
  249,
  255,
  262,
  267,
  282,
  293,
  305,
  312,
  322,
  332,
  342,
  350,
  359,
  367,
  377,
  385,
  396,
  404,
  411,
  415,
  418,
  428,
  434,
  440,
  446,
  453,
  458,
  467,
  477,
  483,
  489,
  496,
  499,
  502,
  507,
  511,
  515,
  518,
  520,
  523,
  526,
  528,
  531,
  534,
  537,
  542,
  545,
  549,
  551,
  553,
  554,
  556,
  558,
  560,
  562,
  564,
  566,
  568,
  570,
  572,
  574,
  575,
  577,
  578,
  580,
  582,
  583,
  585,
  586,
  587,
  587,
  589,
  590,
  591,
  591,
  592,
  593,
  594,
  595,
  595,
  596,
  596,
  597,
  597,
  598,
  598,
  599,
  599,
  600,
  600,
  601,
  601,
  601,
  602,
  602,
  602,
  603,
  603,
  603,
  604,
  604,
  604,
];

// ============================================================
// صفحة القرآن
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
    final filtered = List.generate(
      surahNames.length,
      (index) => index,
    ).where((index) {
      final name = surahNames[index];
      return name.contains(search.trim());
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 20, 18, 10),
            child: Row(
              children: [
                const Expanded(
                  child: Text(
                    'القرآن الكريم',
                    style: TextStyle(
                      fontSize: 27,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF176B5B),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (_) => const AboutDialog(
                        applicationName: 'نور القرآن',
                        applicationVersion: '1.0.0',
                        applicationLegalese:
                            'تطبيق نور القرآن الإسلامي',
                      ),
                    );
                  },
                  icon: const Icon(Icons.info_outline),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: TextField(
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                hintText: 'ابحثي عن سورة...',
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
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 5,
              ),
              itemCount: filtered.length,
              itemBuilder: (context, index) {
                final surahIndex = filtered[index];
                final surahNumber = surahIndex + 1;

                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFFE1F0EB),
                      child: Text(
                        '$surahNumber',
                        style: const TextStyle(
                          color: Color(0xFF176B5B),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      'سورة ${surahNames[surahIndex]}',
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      'الصفحة ${surahStartPages[surahIndex]}',
                      textDirection: TextDirection.rtl,
                    ),
                    trailing: const Icon(
                      Icons.chevron_left,
                    ),
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
// قارئ المصحف الحقيقي - صفحات ملونة
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
  State<QuranReaderPage> createState() => _QuranReaderPageState();
}

class _QuranReaderPageState extends State<QuranReaderPage> {
  late PageController pageController;
  late int currentPage;

  @override
  void initState() {
    super.initState();

    currentPage = surahStartPages[widget.surahNumber - 1];

    pageController = PageController(
      initialPage: currentPage - 1,
    );
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  String getPageUrl(int page) {
    return 'https://quran.ksu.edu.sa/tajweed_png/$page.png';
  }

  int getJuzForPage(int page) {
    const juzPages = [
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

    for (int i = 0; i < juzPages.length; i++) {
      if (page >= juzPages[i]) {
        juz = i + 1;
      } else {
        break;
      }
    }

    return juz;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFEFE9DD),
      appBar: AppBar(
        backgroundColor: const Color(0xFF176B5B),
        foregroundColor: Colors.white,
        centerTitle: true,
        title: Text(
          'سورة ${widget.surahName}',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                reverse: false,
                itemCount: 604,
                onPageChanged: (index) {
                  setState(() {
                    currentPage = index + 1;
                  });
                },
                itemBuilder: (context, index) {
                  final page = index + 1;

                  return Center(
                    child: InteractiveViewer(
                      minScale: 1.0,
                      maxScale: 4.0,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        child: Image.network(
                          getPageUrl(page),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          loadingBuilder:
                              (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }

                            return const Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CircularProgressIndicator(
                                    color: Color(0xFF176B5B),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'جاري تحميل صفحة المصحف...',
                                  ),
                                ],
                              ),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.cloud_off,
                                    size: 55,
                                    color: Colors.grey,
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'تعذر تحميل الصفحة',
                                    style: TextStyle(
                                      fontSize: 17,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      setState(() {});
                                    },
                                    icon: const Icon(Icons.refresh),
                                    label: const Text('إعادة المحاولة'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),

            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 18,
                vertical: 10,
              ),
              decoration: const BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black12,
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${currentPage} صفحة',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF176B5B),
                    ),
                  ),
                  Text(
                    '${getJuzForPage(currentPage)} جزء',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF176B5B),
                    ),
                  ),
                  Text(
                    '604 / $currentPage',
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
}

// ============================================================
// الأذكار
// ============================================================

class AdhkarPage extends StatelessWidget {
  const AdhkarPage({super.key});

  @override
  Widget build(BuildContext context) {
    final adhkar = [
      {
        'title': 'أذكار الصباح',
        'text': 'أصبحنا وأصبح الملك لله والحمد لله...',
      },
      {
        'title': 'أذكار المساء',
        'text': 'أمسينا وأمسى الملك لله والحمد لله...',
      },
      {
        'title': 'ذكر الله',
        'text': 'سبحان الله والحمد لله ولا إله إلا الله والله أكبر.',
      },
      {
        'title': 'الاستغفار',
        'text': 'أستغفر الله العظيم وأتوب إليه.',
      },
    ];

    return SafeArea(
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'الأذكار',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF176B5B),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: adhkar.length,
              itemBuilder: (context, index) {
                return AdhkarCard(
                  title: adhkar[index]['title']!,
                  text: adhkar[index]['text']!,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AdhkarCard extends StatelessWidget {
  final String title;
  final String text;

  const AdhkarCard({
    super.key,
    required this.title,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              title,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: Color(0xFF176B5B),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              text,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 17,
                height: 1.8,
              ),
            ),
          ],
        ),
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
      child: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'المكتبة الإسلامية',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
                color: Color(0xFF176B5B),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: const [
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.menu_book,
                      color: Color(0xFF176B5B),
                    ),
                    title: Text('القرآن الكريم'),
                    subtitle: Text('مصحف المدينة المنورة'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.favorite,
                      color: Color(0xFF176B5B),
                    ),
                    title: Text('الأذكار'),
                    subtitle: Text('أذكار المسلم اليومية'),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: Icon(
                      Icons.auto_stories,
                      color: Color(0xFF176B5B),
                    ),
                    title: Text('كتب إسلامية'),
                    subtitle: Text('سيتم إضافة الكتب قريباً'),
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
