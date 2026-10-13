import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
          seedColor: const Color(0xFF126B50),
        ),
        scaffoldBackgroundColor: const Color(0xFFF7F8F4),
        fontFamily: 'Arial',
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int selectedIndex = 0;

  final List<String> titles = [
    'الرئيسية',
    'القرآن الكريم',
    'مواقيت الصلاة',
    'الأذكار والأدعية',
    'المكتبة الإسلامية',
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      const HomeContent(),
      const QuranPage(),
      const PrayerPage(),
      const AdhkarPage(),
      const LibraryPage(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: const Color(0xFF126B50),
          foregroundColor: Colors.white,
          title: Text(
            selectedIndex == 0
                ? 'نور القرآن الإسلامي'
                : titles[selectedIndex],
          ),
          centerTitle: true,
        ),
        body: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
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
              icon: Icon(Icons.menu_book),
              label: 'القرآن',
            ),
            NavigationDestination(
              icon: Icon(Icons.mosque_outlined),
              label: 'الصلاة',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline),
              label: 'الأذكار',
            ),
            NavigationDestination(
              icon: Icon(Icons.library_books_outlined),
              label: 'المكتبة',
            ),
          ],
        ),
      ),
    );
  }
}

class HomeContent extends StatelessWidget {
  const HomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(0xFF126B50),
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 14),
              Text(
                'نور القرآن ينير يومك',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'القرآن الكريم والأذكار ومواقيت الصلاة في مكان واحد',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'أقسام التطبيق',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        const FeatureCard(
          icon: Icons.menu_book,
          title: 'القرآن الكريم',
          subtitle: 'السور والآيات والقراءة',
        ),
        const FeatureCard(
          icon: Icons.headphones,
          title: 'القراءات الصوتية',
          subtitle: 'مكتبة القراء والتلاوات',
        ),
        const FeatureCard(
          icon: Icons.mosque,
          title: 'مواقيت الصلاة',
          subtitle: 'الفجر والظهر والعصر والمغرب والعشاء',
        ),
        const FeatureCard(
          icon: Icons.volunteer_activism,
          title: 'الأذكار والأدعية',
          subtitle: 'أذكار الصباح والمساء وأدعية متنوعة',
        ),
        const FeatureCard(
          icon: Icons.auto_stories,
          title: 'المكتبة الإسلامية',
          subtitle: 'التفسير والحديث والسيرة النبوية',
        ),
        const SizedBox(height: 20),
        const Center(
          child: Text(
            'اللهم اجعل القرآن ربيع قلوبنا',
            style: TextStyle(
              color: Color(0xFF126B50),
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFE0F0E7),
          child: Icon(
            icon,
            color: const Color(0xFF126B50),
          ),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(
          Icons.arrow_forward_ios,
          size: 16,
        ),
      ),
    );
  }
}
class QuranPage extends StatefulWidget {
  final int surahNumber;

  const QuranPage({
    super.key,
    this.surahNumber = 1,
  });

  @override
  State<QuranPage> createState() => _QuranPageState();
}

class _QuranPageState extends State<QuranPage> {
  final TextEditingController searchController = TextEditingController();

  static const List<String> surahs = [
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

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final searchText = searchController.text.trim();

    final filtered = surahs.asMap().entries.where((entry) {
      return entry.value.contains(searchText);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: searchController,
            decoration: InputDecoration(
              hintText: 'ابحث عن سورة...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: (_) {
              setState(() {});
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final entry = filtered[index];
              final number = entry.key + 1;
              final name = entry.value;

              return ListTile(
                leading: CircleAvatar(
                  child: Text('$number'),
                ),
                title: Text('سورة $name'),
                subtitle: const Text('القرآن الكريم'),
                trailing: const Icon(Icons.menu_book),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => QuranReaderPage(
                        surahNumber: number,
                        surahName: name,
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
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
  List<String> verses = [];
  bool loading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    loadVerses();
  }

  Future<void> loadVerses() async {
    try {
      final text = await rootBundle.loadString(
        'assets/quran/quran-uthmani.txt',
      );

      final result = <String>[];

      for (final line in text.split('\n')) {
        final parts = line.trim().split('|');

        if (parts.length < 3) {
          continue;
        }

        final surah = int.tryParse(parts[0]);

        if (surah != widget.surahNumber) {
          continue;
        }

        result.add(parts.sublist(2).join('|'));
      }

      if (result.isEmpty) {
        throw Exception('لم يتم العثور على آيات هذه السورة.');
      }

      if (!mounted) {
        return;
      }

      setState(() {
        verses = result;
        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        error = 'تعذرت قراءة الملف: $e';
        loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('سورة ${widget.surahName}'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      error!,
                      textAlign: TextAlign.center,
                    ),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: verses.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 18),
                      child: Text(
                        '${index + 1}. ${verses[index]}',
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontSize: 22,
                          height: 1.8,
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'أوقات الصلاة',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
class AdhkarPage extends StatelessWidget {
  const AdhkarPage({super.key});

  static const List<String> adhkar = [
    'سبحان الله',
    'الحمد لله',
    'الله أكبر',
    'لا إله إلا الله',
    'أستغفر الله',
    'اللهم صل وسلم على نبينا محمد',
    'سبحان الله وبحمده، سبحان الله العظيم',
    'لا حول ولا قوة إلا بالله',
    'حسبي الله لا إله إلا هو، عليه توكلت وهو رب العرش العظيم',
    'اللهم اغفر لي وارحمني واهدني وعافني وارزقني',
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: adhkar.length,
      itemBuilder: (context, index) {
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Text(
              adhkar[index],
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontSize: 20,
                height: 1.7,
              ),
            ),
          ),
        );
      },
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        Card(
          child: ListTile(
            leading: Icon(Icons.menu_book),
            title: Text('القرآن الكريم'),
            subtitle: Text('قراءة سور القرآن الكريم'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.favorite),
            title: Text('الأذكار'),
            subtitle: Text('مجموعة من الأذكار والأدعية'),
          ),
        ),
        Card(
          child: ListTile(
            leading: Icon(Icons.mosque),
            title: Text('أوقات الصلاة'),
            subtitle: Text('مواقيت الصلاة'),
          ),
        ),
      ],
    );
  }
}
