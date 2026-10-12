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
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
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
  final TextEditingController searchController = TextEditingController();

  final List<String> surahs = const [
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
    final filtered = surahs
        .asMap()
        .entries
        .where((entry) =>
            entry.value.contains(searchController.text.trim()))
        .toList();

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
            onChanged: (_) => setState(() {}),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final entry = filtered[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: const Color(0xFFE0F0E7),
                  child: Text('${entry.key + 1}'),
                ),
                title: Text('سورة ${entry.value}'),
                subtitle: const Text('القرآن الكريم'),
                trailing: const Icon(Icons.menu_book),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'اخترت سورة ${entry.value}. ستتم إضافة القراءة والتلاوة في المرحلة التالية.',
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

class PrayerPage extends StatelessWidget {
  const PrayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    const prayers = [
      'الفجر',
      'الظهر',
      'العصر',
      'المغرب',
      'العشاء',
    ];

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Icon(
          Icons.mosque,
          size: 70,
          color: Color(0xFF126B50),
        ),
        const SizedBox(height: 12),
        const Center(
          child: Text(
            'مواقيت الصلاة',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'ستظهر المواقيت الصحيحة بعد ربط التطبيق بالمدينة وطريقة حساب الصلاة.',
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 20),
        ...prayers.map(
          (prayer) => Card(
            child: ListTile(
              leading: const Icon(
                Icons.access_time,
                color: Color(0xFF126B50),
              ),
              title: Text(prayer),
              trailing: const Text('لم يُحدد الوقت'),
            ),
          ),
        ),
      ],
    );
  }
}

class AdhkarPage extends StatelessWidget {
  const AdhkarPage({super.key});

  final List<Map<String, String>> categories = const [
    {
      'title': 'أذكار الصباح',
      'subtitle': 'أذكار بداية اليوم',
    },
    {
      'title': 'أذكار المساء',
      'subtitle': 'أذكار نهاية اليوم',
    },
    {
      'title': 'أذكار بعد الصلاة',
      'subtitle': 'الأذكار الواردة بعد الصلوات',
    },
    {
      'title': 'أذكار النوم',
      'subtitle': 'أذكار النوم والاستيقاظ',
    },
    {
      'title': 'أدعية القرآن',
      'subtitle': 'الأدعية الواردة في القرآن الكريم',
    },
    {
      'title': 'أدعية الأنبياء',
      'subtitle': 'الأدعية الواردة عن الأنبياء في القرآن',
    },
    {
      'title': 'أدعية السفر',
      'subtitle': 'أذكار السفر والركوب',
    },
    {
      'title': 'الاستغفار والتوبة',
      'subtitle': 'أذكار الاستغفار والتوبة',
    },
    {
      'title': 'الرقية الشرعية',
      'subtitle': 'آيات وأدعية الرقية من مصادر موثوقة',
    },
    {
      'title': 'التسبيح',
      'subtitle': 'عداد إلكتروني للتسبيح',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'الأذكار والأدعية',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...categories.map(
          (category) => Card(
            child: ListTile(
              leading: const Icon(
                Icons.favorite,
                color: Color(0xFF126B50),
              ),
              title: Text(category['title']!),
              subtitle: Text(category['subtitle']!),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'قسم ${category['title']} سيُجهز بمحتواه الموثق في المرحلة التالية.',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  final List<Map<String, String>> sections = const [
    {
      'title': 'التفسير',
      'subtitle': 'تفسير الآيات من مصادر معتمدة',
    },
    {
      'title': 'الحديث النبوي',
      'subtitle': 'الأحاديث مع المصادر ودرجات الصحة',
    },
    {
      'title': 'السيرة النبوية',
      'subtitle': 'سيرة النبي محمد صلى الله عليه وسلم',
    },
    {
      'title': 'أسماء الله الحسنى',
      'subtitle': 'الأسماء ومعانيها',
    },
    {
      'title': 'القراء والتلاوات',
      'subtitle': 'مكتبة القراء والتسجيلات الصوتية',
    },
    {
      'title': 'الإعدادات',
      'subtitle': 'إعدادات التطبيق والتفضيلات',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'المكتبة الإسلامية',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...sections.map(
          (section) => Card(
            child: ListTile(
              leading: const Icon(
                Icons.auto_stories,
                color: Color(0xFF126B50),
              ),
              title: Text(section['title']!),
              subtitle: Text(section['subtitle']!),
              trailing: const Icon(Icons.chevron_left),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'سيتم تجهيز قسم ${section['title']} لاحقاً.',
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
