import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

void main() => runApp(const MozMarketApp());

const green = Color(0xFF0B7A45);
const dark = Color(0xFF101512);
const bg = Color(0xFFF7F8F5);

class Ad {
  String title, price, location, category, condition, description, whatsapp;
  List<XFile> photos;
  bool favourite;

  Ad({
    required this.title,
    required this.price,
    required this.location,
    required this.category,
    required this.condition,
    required this.description,
    required this.whatsapp,
    required this.photos,
    this.favourite = false,
  });
}

class ChatMessage {
  final String text;
  final bool mine;

  ChatMessage(this.text, this.mine);
}

class MozMarketApp extends StatelessWidget {
  const MozMarketApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MOZ MARKET',
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: bg,
          colorScheme: ColorScheme.fromSeed(seedColor: green),
          appBarTheme: const AppBarTheme(
            backgroundColor: bg,
            surfaceTintColor: Colors.transparent,
          ),
          inputDecorationTheme: const InputDecorationTheme(
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(14)),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        home: const MainScreen(),
      );
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int tab = 0;
  String query = '';

  final ads = <Ad>[
    Ad(
      title: 'iPhone 14 Pro Max',
      price: '25,000 MZN',
      location: 'Maputo',
      category: 'Phones',
      condition: 'Used - Like New',
      description: 'Excellent condition. Ready to use.',
      whatsapp: '258820000000',
      photos: [],
    ),
    Ad(
      title: 'Men T-Shirt',
      price: '500 MZN',
      location: 'Matola',
      category: 'Clothes',
      condition: 'New',
      description: 'Good quality.',
      whatsapp: '258820000000',
      photos: [],
    ),
    Ad(
      title: 'Dell Laptop',
      price: '30,000 MZN',
      location: 'Maputo',
      category: 'Laptops / Computers',
      condition: 'Used - Good',
      description: 'Works perfectly.',
      whatsapp: '258820000000',
      photos: [],
    ),
  ];

  final categories = const [
    ['Clothes', '👕'],
    ['Shoes & Bags', '👟'],
    ['Phones', '📱'],
    ['Electronics', '🎧'],
    ['Laptops / Computers', '💻'],
    ['TV / Appliances', '📺'],
    ['Gaming', '🎮'],
    ['Cars / Bikes', '🚗'],
    ['Furniture', '🛋️'],
    ['Kids / Baby', '🧸'],
    ['Jobs', '💼'],
    ['Services', '🛠️'],
    ['Other', '📦']
  ];

  final List<ChatMessage> messages = [
    ChatMessage('Olá! Tenho interesse neste produto.', false),
    ChatMessage('Olá! Sim, ainda está disponível.', true),
  ];

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      _myAds(),
      _chatList(),
      _profile(),
    ];

    return Scaffold(
      body: SafeArea(child: pages[tab]),
      floatingActionButton: tab == 0
          ? FloatingActionButton.extended(
              backgroundColor: green,
              foregroundColor: Colors.white,
              onPressed: _postAd,
              icon: const Icon(Icons.add),
              label: const Text('Post Ad'),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        selectedIndex: tab,
        onDestinationSelected: (i) => setState(() => tab = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2),
            label: 'My Ads',
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Chat',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _header() => Row(
        children: [
          const Expanded(
            child: Text(
              'MOZ MARKET 🇲🇿',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w900,
                color: dark,
              ),
            ),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.notifications_none_rounded),
          ),
        ],
      );

  Widget _home() {
    final filtered = ads
        .where(
          (a) =>
              query.isEmpty ||
              '${a.title} ${a.category} ${a.location}'
                  .toLowerCase()
                  .contains(query.toLowerCase()),
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 100),
      children: [
        _header(),
        const SizedBox(height: 16),
        TextField(
          onChanged: (v) => setState(() => query = v),
          decoration: const InputDecoration(
            hintText: 'Search / Procurar...',
            prefixIcon: Icon(Icons.search),
            suffixIcon: Icon(Icons.tune_rounded),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            color: green,
            borderRadius: BorderRadius.circular(24),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Buy & Sell Anything',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              SizedBox(height: 7),
              Text(
                'Compre e venda facilmente em Moçambique 🇲🇿',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Categories',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: _showCategories,
              child: const Text('See all'),
            ),
          ],
        ),
        SizedBox(
          height: 105,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) =>
                _categoryTile(categories[i][0], categories[i][1]),
          ),
        ),
        const SizedBox(height: 22),
        Row(
          children: [
            const Expanded(
              child: Text(
                'Featured Ads',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text('See all'),
            ),
          ],
        ),
        ...filtered.map(_card),
        if (filtered.isEmpty)
          const Padding(
            padding: EdgeInsets.all(30),
            child: Center(
              child: Text(
                'No ads found / Nenhum anúncio encontrado',
              ),
            ),
          ),
      ],
    );
  }

  Widget _categoryTile(String name, String emoji) => GestureDetector(
        onTap: () => setState(() => query = name),
        child: Container(
          width: 92,
          padding: const EdgeInsets.all(9),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.black12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 27),
              ),
              const SizedBox(height: 5),
              Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      );

  Widget _card(Ad ad) => Card(
        margin: const EdgeInsets.only(bottom: 12),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: Colors.black12),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _details(ad),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _thumb(ad, 78, 78),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ad.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        ad.price,
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          color: green,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${ad.location} • ${ad.category}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      setState(() => ad.favourite = !ad.favourite),
                  icon: Icon(
                    ad.favourite
                        ? Icons.favorite
                        : Icons.favorite_border,
                    color:
                        ad.favourite ? Colors.red : Colors.black45,
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  Widget _thumb(Ad ad, double w, double h) => ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: ad.photos.isNotEmpty
            ? Image.file(
                File(ad.photos.first.path),
                width: w,
                height: h,
                fit: BoxFit.cover,
              )
            : Container(
                width: w,
                height: h,
                color: const Color(0xFFE9ECE7),
                child: const Icon(
                  Icons.image_outlined,
                  size: 30,
                ),
              ),
      );

  Widget _myAds() => ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 30),
        children: [
          const Text(
            'My Ads',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 8),
          const Text('Os seus anúncios publicados'),
          const SizedBox(height: 18),
          if (ads.length > 3) ...ads.sublist(3).map(_card),
          if (ads.length <= 3)
            Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    const Icon(
                      Icons.inventory_2_outlined,
                      size: 58,
                      color: Colors.black38,
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Your ads will appear here.',
                    ),
                    const SizedBox(height: 12),
                    FilledButton(
                      onPressed: _postAd,
                      child: const Text(
                        'Post your first ad',
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      );

  Widget _chatList() => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Chat',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: green,
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                ),
              ),
              title: const Text('Seller chat'),
              subtitle: const Text(
                'Olá! Sim, ainda está disponível.',
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => _openChat('Seller chat'),
            ),
          ),
        ],
      );

  Widget _profile() => ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Profile',
            style: TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 42,
            backgroundColor: green,
            child: Icon(
              Icons.person,
              size: 45,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          const Center(
            child: Text(
              'MOZ MARKET User',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(height: 24),
          _profileRow(Icons.edit_outlined, 'Edit profile'),
          _profileRow(Icons.favorite_border, 'Favourites'),
          _profileRow(
            Icons.language,
            'Language • Português / English',
          ),
          _profileRow(
            Icons.help_outline,
            'Help & Support',
          ),
          _profileRow(
            Icons.report_outlined,
            'Report a problem',
          ),
        ],
      );

  Widget _profileRow(IconData icon, String text) => ListTile(
        leading: Icon(icon, color: green),
        title: Text(text),
        trailing: const Icon(Icons.chevron_right),
        onTap: () {},
      );

  void _showCategories() => showModalBottomSheet(
        context: context,
        showDragHandle: true,
        builder: (_) => ListView(
          padding: const EdgeInsets.all(18),
          children: categories
              .map(
                (c) => ListTile(
                  leading: Text(
                    c[1],
                    style: const TextStyle(fontSize: 25),
                  ),
                  title: Text(c[0]),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() => query = c[0]);
                  },
                ),
              )
              .toList(),
        ),
      );

  Future<void> _postAd() async {
    final title = TextEditingController();
    final price = TextEditingController();
    final desc = TextEditingController();
    final phone = TextEditingController();

    String category = 'Clothes';
    String condition = 'Used - Good';
    String location = 'Maputo';
    List<XFile> photos = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setM) {
          Future<void> gallery() async {
            final p = await ImagePicker().pickMultiImage(
              imageQuality: 82,
            );

            if (p.isNotEmpty) {
              setM(
                () => photos = [
                  ...photos,
                  ...p
                ].take(10).toList(),
              );
            }
          }

          Future<void> camera() async {
            final p = await ImagePicker().pickImage(
              source: ImageSource.camera,
              imageQuality: 82,
            );

            if (p != null) {
              setM(
                () => photos = [
                  ...photos,
                  p
                ].take(10).toList(),
              );
            }
          }

          return Padding(
            padding: EdgeInsets.fromLTRB(
              18,
              5,
              18,
              MediaQuery.of(ctx).viewInsets.bottom + 16,
            ),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Post New Ad',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '
