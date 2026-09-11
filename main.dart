import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  if (FirebaseAuth.instance.currentUser == null) {
    await FirebaseAuth.instance.signInAnonymously();
  }

  runApp(const MozMarketApp());
}

const green = Color(0xFF0B7A45);
const dark = Color(0xFF101512);
const bg = Color(0xFFF7F8F5);

class Ad {
  String id;
  String title;
  String price;
  String location;
  String category;
  String condition;
  String description;
  String whatsapp;
  String sellerId;
  List<XFile> photos;
  bool favourite;

  Ad({
    required this.id,
    required this.title,
    required this.price,
    required this.location,
    required this.category,
    required this.condition,
    required this.description,
    required this.whatsapp,
    required this.sellerId,
    required this.photos,
    this.favourite = false,
  });
}

class ChatMessage {
  final String id;
  final String text;
  final String senderId;
  final Timestamp? timestamp;

  ChatMessage({
    required this.id,
    required this.text,
    required this.senderId,
    this.timestamp,
  });
}

class MozMarketApp extends StatelessWidget {
  const MozMarketApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
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
            borderRadius: BorderRadius.all(
              Radius.circular(14),
            ),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      home: const MainScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int tab = 0;
  String query = '';

  final List<Ad> ads = [
    Ad(
      id: 'iphone_demo',
      title: 'iPhone 14 Pro Max',
      price: '25,000 MZN',
      location: 'Maputo',
      category: 'Phones',
      condition: 'Used - Like New',
      description: 'Excellent condition. Ready to use.',
      whatsapp: '258820000000',
      sellerId: 'demo_seller_1',
      photos: [],
    ),
    Ad(
      id: 'shirt_demo',
      title: 'Men T-Shirt',
      price: '500 MZN',
      location: 'Matola',
      category: 'Clothes',
      condition: 'New',
      description: 'Good quality.',
      whatsapp: '258820000000',
      sellerId: 'demo_seller_1',
      photos: [],
    ),
    Ad(
      id: 'dell_demo',
      title: 'Dell Laptop',
      price: '30,000 MZN',
      location: 'Maputo',
      category: 'Laptops / Computers',
      condition: 'Used - Good',
      description: 'Works perfectly.',
      whatsapp: '258820000000',
      sellerId: 'demo_seller_1',
      photos: [],
    ),
  ];

  final List<List<String>> categories = const [
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
    ['Other', '📦'],
  ];

  String get myUserId {
    return FirebaseAuth.instance.currentUser?.uid ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      _home(),
      _myAds(),
      _chatList(),
      _profile(),
    ];

    return Scaffold(
      body: SafeArea(
        child: pages[tab],
      ),
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
        onDestinationSelected: (i) {
          setState(() {
            tab = i;
          });
        },
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

  Widget _header() {
    return Row(
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
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No new notifications.'),
              ),
            );
          },
          icon: const Icon(
            Icons.notifications_none_rounded,
          ),
        ),
      ],
    );
  }

  Widget _home() {
    final filtered = ads.where((ad) {
      if (query.isEmpty) return true;

      final text =
          '${ad.title} ${ad.category} ${ad.location}'
              .toLowerCase();

      return text.contains(
        query.toLowerCase(),
      );
    }).toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        18,
        10,
        18,
        100,
      ),
      children: [
        _header(),
        const SizedBox(height: 16),
        TextField(
          onChanged: (value) {
            setState(() {
              query = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Search / Procurar...',
            prefixIcon: Icon(Icons.search),
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
            crossAxisAlignment:
                CrossAxisAlignment.start,
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
            separatorBuilder: (_, __) =>
                const SizedBox(width: 10),
            itemBuilder: (_, i) {
              return _categoryTile(
                categories[i][0],
                categories[i][1],
              );
            },
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'Featured Ads',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 12),
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

  Widget _categoryTile(
    String name,
    String emoji,
  ) {
    return GestureDetector(
      onTap: () {
        setState(() {
          query = name;
        });
      },
      child: Container(
        width: 92,
        padding: const EdgeInsets.all(9),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.black12,
          ),
        ),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            Text(
              emoji,
              style: const TextStyle(
                fontSize: 27,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              name,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(Ad ad) {
    return Card(
      margin: const EdgeInsets.only(
        bottom: 12,
      ),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: const BorderSide(
          color: Colors.black12,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _details(ad),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _thumb(ad),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      ad.title,
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w800,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      ad.price,
                      style: const TextStyle(
                        fontWeight:
                            FontWeight.w900,
                        color: green,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${ad.location} • ${ad.category}',
                      maxLines: 1,
                      overflow:
                          TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black54,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    ad.favourite =
                        !ad.favourite;
                  });
                },
                icon: Icon(
                  ad.favourite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: ad.favourite
                      ? Colors.red
                      : Colors.black45,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _thumb(Ad ad) {
    return ClipRRect(
      borderRadius:
          BorderRadius.circular(14),
      child: ad.photos.isNotEmpty
          ? Image.file(
              File(ad.photos.first.path),
              width: 78,
              height: 78,
              fit: BoxFit.cover,
            )
          : Container(
              width: 78,
              height: 78,
              color:
                  const Color(0xFFE9ECE7),
              child: const Icon(
                Icons.image_outlined,
                size: 30,
              ),
            ),
    );
  }

  Widget _myAds() {
    final myAds = ads
        .where(
          (ad) => ad.sellerId == myUserId,
        )
        .toList();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        18,
        18,
        18,
        30,
      ),
      children: [
        const Text(
          'My Ads',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Os seus anúncios publicados',
        ),
        const SizedBox(height: 18),
        if (myAds.isNotEmpty)
          ...myAds.map(_card),
        if (myAds.isEmpty)
          Center(
            child: Padding(
              padding:
                  const EdgeInsets.only(
                top: 80,
              ),
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
                  FilledButton.icon(
                    onPressed: _postAd,
                    icon: const Icon(
                      Icons.add,
                    ),
                    label: const Text(
                      'Post your first ad',
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _chatList() {
    final uid = myUserId;

    return StreamBuilder<
        QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('chats')
          .where(
            'members',
            arrayContains: uid,
          )
          .orderBy(
            'lastMessageTime',
            descending: true,
          )
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _chatError();
        }

        if (snapshot.connectionState ==
            ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        return ListView(
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
            if (docs.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.only(top: 100),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.chat_bubble_outline,
                        size: 60,
                        color: Colors.black38,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'No chats yet.',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w700,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Open an ad and tap Chat.',
                        textAlign:
                            TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ...docs.map(
              (doc) => _chatTile(
                doc.id,
                doc.data(),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _chatError() {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: const [
        Text(
          'Chat',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.w900,
          ),
        ),
        SizedBox(height: 30),
        Icon(
          Icons.cloud_off,
          size: 55,
          color: Colors.black38,
        ),
        SizedBox(height: 12),
        Center(
          child: Text(
            'Chat database setup is required.',
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  Widget _chatTile(
    String chatId,
    Map<String, dynamic> data,
  ) {
    final otherName =
        data['otherName']?.toString() ??
            'MOZ MARKET User';

    final adTitle =
        data['adTitle']?.toString() ?? '';

    final lastMessage =
        data['lastMessage']?.toString() ??
            'Start chatting';

    return Card(
      elevation: 0,
      child: ListTile(
        leading: const CircleAvatar(
          backgroundColor: green,
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
        ),
        title: Text(
          otherName,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        subtitle: Text(
          adTitle.isEmpty
              ? lastMessage
              : '$adTitle • $lastMessage',
          maxLines: 1,
          overflow:
              TextOverflow.ellipsis,
        ),
        trailing: const Icon(
          Icons.chevron_right,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ChatScreen(
                chatId: chatId,
                seller: otherName,
                adTitle: adTitle,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _profile() {
    final uid = myUserId;

    return ListView(
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
        const SizedBox(height: 8),
        Center(
          child: Text(
            uid.isEmpty
                ? 'Connecting...'
                : 'User ID: ${uid.substring(0, 8)}...',
            style: const TextStyle(
              color: Colors.black45,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _profileRow(
          Icons.edit_outlined,
          'Edit profile',
        ),
        _profileRow(
          Icons.favorite_border,
          'Favourites',
        ),
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
  }

  Widget _profileRow(
    IconData icon,
    String text,
  ) {
    return ListTile(
      leading: Icon(
        icon,
        color: green,
      ),
      title: Text(text),
      trailing: const Icon(
        Icons.chevron_right,
      ),
      onTap: () {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(text),
          ),
        );
      },
    );
  }

  void _showCategories() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) {
        return ListView(
          padding:
              const EdgeInsets.all(18),
          children: categories.map((c) {
            return ListTile(
              leading: Text(
                c[1],
                style: const TextStyle(
                  fontSize: 25,
                ),
              ),
              title: Text(c[0]),
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  query = c[0];
                });
              },
            );
          }).toList(),
        );
      },
    );
  }

  Future<void> _postAd() async {
    final title =
        TextEditingController();
    final price =
        TextEditingController();
    final desc =
        TextEditingController();
    final phone =
        TextEditingController();

    String category = 'Clothes';
    String condition = 'Used - Good';
    String location = 'Maputo';

    List<XFile> photos = [];

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setM) {
            Future<void> gallery() async {
              final picked =
                  await ImagePicker()
                      .pickMultiImage(
                imageQuality: 82,
              );

              if (picked.isNotEmpty) {
                setM(() {
                  photos = [
                    ...photos,
                    ...picked,
                  ].take(10).toList();
                });
              }
            }

            Future<void> camera() async {
              final picked =
                  await ImagePicker()
                      .pickImage(
                source:
                    ImageSource.camera,
                imageQuality: 82,
              );

              if (picked != null) {
                setM(() {
                  photos = [
                    ...photos,
                    picked,
                  ].take(10).toList();
                });
              }
            }

            return Padding(
              padding: EdgeInsets.fromLTRB(
                18,
                5,
                18,
                MediaQuery.of(ctx)
                        .viewInsets
                        .bottom +
                    16,
              ),
              child:
                  SingleChildScrollView(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Post New Ad',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight:
                            FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Publicar anúncio • até 10 fotos',
                    ),
                    const SizedBox(
                      height: 16,
                    ),

                    if (photos.isNotEmpty)
                      SizedBox(
                        height: 92,
                        child:
                            ListView.separated(
                          scrollDirection:
                              Axis.horizontal,
                          itemCount:
                              photos.length,
                          separatorBuilder:
                              (_, __) =>
                                  const SizedBox(
                                width: 8,
                              ),
                          itemBuilder:
                              (_, i) {
                            return Stack(
                              children: [
                                ClipRRect(
                                  borderRadius:
                                      BorderRadius
                                          .circular(
                                    12,
                                  ),
                                  child:
                                      Image.file(
                                    File(
                                      photos[i]
                                          .path,
                                    ),
                                    width: 92,
                                    height: 92,
                                    fit: BoxFit
                                        .cover,
                                  ),
                                ),
                                Positioned(
                                  right: 2,
                                  top: 2,
                                  child:
                                      CircleAvatar(
                                    radius: 12,
                                    backgroundColor:
                                        Colors
                                            .black54,
                                    child:
                                        IconButton(
                                      padding:
                                          EdgeInsets
                                              .zero,
                                      onPressed:
                                          () {
                                        setM(
                                          () {
                                            photos
                                                .removeAt(
                                                    i);
                                          },
                                        );
                                      },
                                      icon:
                                          const Icon(
                                        Icons
                                            .close,
                                        size: 15,
                                        color: Colors
                                            .white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    const SizedBox(
                      height: 10,
                    ),

                    Row(
                      children: [
                        Expanded(
                          child:
                              OutlinedButton
                                  .icon(
                            onPressed:
                                gallery,
                            icon: const Icon(
                              Icons
                                  .photo_library_outlined,
                            ),
                            label:
                                const Text(
                              'Gallery',
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        Expanded(
                          child:
                              OutlinedButton
                                  .icon(
                            onPressed:
                                camera,
                            icon: const Icon(
                              Icons
                                  .camera_alt_outlined,
                            ),
                            label:
                                const Text(
                              'Camera',
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 12,
                    ),

                    TextField(
                      controller: title,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Product title / Título',
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextField(
                      controller: price,
                      keyboardType:
                          TextInputType.number,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Price (MZN) / Preço',
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value: category,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Category / Categoria',
                      ),
                      items:
                          categories.map(
                        (c) {
                          return DropdownMenuItem(
                            value: c[0],
                            child:
                                Text(c[0]),
                          );
                        },
                      ).toList(),
                      onChanged: (v) {
                        setM(() {
                          category =
                              v ?? category;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value: condition,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Condition / Estado',
                      ),
                      items: const [
                        'New',
                        'Used - Like New',
                        'Used - Good',
                        'Used - Fair',
                      ].map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child:
                              Text(c),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setM(() {
                          condition =
                              v ?? condition;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    DropdownButtonFormField<
                        String>(
                      value: location,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Location / Localização',
                      ),
                      items: const [
                        'Maputo',
                        'Matola',
                        'Beira',
                        'Nampula',
                        'Chimoio',
                        'Other',
                      ].map((c) {
                        return DropdownMenuItem(
                          value: c,
                          child:
                              Text(c),
                        );
                      }).toList(),
                      onChanged: (v) {
                        setM(() {
                          location =
                              v ?? location;
                        });
                      },
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextField(
                      controller: desc,
                      maxLines: 3,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'Description / Descrição',
                      ),
                    ),

                    const SizedBox(
                      height: 10,
                    ),

                    TextField(
                      controller: phone,
                      keyboardType:
                          TextInputType.phone,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'WhatsApp number',
                      ),
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    SizedBox(
                      width: double.infinity,
                      child:
                          FilledButton.icon(
                        onPressed: () {
                          _publish(
                            ctx,
                            title,
                            price,
                            desc,
                            phone,
                            category,
                            condition,
                            location,
                            photos,
                          );
                        },
                        icon: const Icon(
                          Icons.publish,
                        ),
                        label: const Text(
                          'Publish Ad / Publicar',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );

    title.dispose();
    price.dispose();
    desc.dispose();
    phone.dispose();
  }

  void _publish(
    BuildContext ctx,
    TextEditingController title,
    TextEditingController price,
    TextEditingController desc,
    TextEditingController phone,
    String category,
    String condition,
    String location,
    List<XFile> photos,
  ) {
    if (title.text.trim().isEmpty ||
        price.text.trim().isEmpty) {
      ScaffoldMessenger.of(ctx)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter title and price.',
          ),
        ),
      );
      return;
    }

    setState(() {
      ads.insert(
        0,
        Ad(
          id: DateTime.now()
              .millisecondsSinceEpoch
              .toString(),
          title: title.text.trim(),
          price:
              '${price.text.trim()} MZN',
          location: location,
          category: category,
          condition: condition,
          description:
              desc.text.trim(),
          whatsapp:
              phone.text.trim(),
          sellerId: myUserId,
          photos:
              List<XFile>.from(photos),
        ),
      );

      tab = 1;
    });

    Navigator.pop(ctx);
  }

  void _details(Ad ad) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) {
        return Padding(
          padding:
              const EdgeInsets.fromLTRB(
            18,
            8,
            18,
            22,
          ),
          child: Column(
            mainAxisSize:
                MainAxisSize.min,
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              if (ad.photos.isNotEmpty)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(
                    18,
                  ),
                  child: Image.file(
                    File(
                      ad.photos.first.path,
                    ),
                    height: 210,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  height: 150,
                  width: double.infinity,
                  decoration:
                      BoxDecoration(
                    color:
                        const Color(
                      0xFFE9ECE7,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 55,
                  ),
                ),

              const SizedBox(
                height: 14,
              ),

              Text(
                ad.title,
                style:
                    const TextStyle(
                  fontSize: 23,
                  fontWeight:
                      FontWeight.w900,
                ),
              ),

              const SizedBox(
                height: 4,
              ),

              Text(
                ad.price,
                style:
                    const TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.w900,
                  color: green,
                ),
              ),

              const SizedBox(
                height: 8,
              ),

              Text(
                '${ad.location} • ${ad.category} • ${ad.condition}',
                style:
                    const TextStyle(
                  color: Colors.black54,
                ),
              ),

              if (ad.description
                  .isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.only(
                    top: 12,
                  ),
                  child: Text(
                    ad.description,
                  ),
                ),

              const SizedBox(
                height: 18,
              ),

              Row(
                children: [
                  Expanded(
                    child:
                        FilledButton.icon(
                      onPressed: () =>
                          _whatsapp(ad),
                      icon: const Icon(
                        Icons.chat,
                      ),
                      label: const Text(
                        'WhatsApp',
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child:
                        OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(
                          context,
                        );

                        _openChatWithAd(
                          ad,
                        );
                      },
                      icon: const Icon(
                        Icons
                            .chat_bubble_outline,
                      ),
                      label: const Text(
                        'Chat',
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  String _chatIdForAd(Ad ad) {
    final current =
        myUserId.isEmpty
            ? 'unknown'
            : myUserId;

    final users = [
      current,
      ad.sellerId,
    ]..sort();

    return '${users[0]}_${users[1]}_${ad.id}';
  }

  Future<void> _openChatWithAd(
    Ad ad,
  ) async {
    if (ad.sellerId == myUserId) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'This is your own ad.',
          ),
        ),
      );
      return;
    }

    final chatId =
        _chatIdForAd(ad);

    final chatRef = FirebaseFirestore
        .instance
        .collection('chats')
        .doc(chatId);

    final existing =
        await chatRef.get();

    if (!existing.exists) {
      await chatRef.set({
        'members': [
          myUserId,
          ad.sellerId,
        ],
        'adId': ad.id,
        'adTitle': ad.title,
        'sellerId': ad.sellerId,
        'buyerId': myUserId,
        'otherName': 'Seller',
        'lastMessage': '',
        'lastMessageTime':
            FieldValue.serverTimestamp(),
        'createdAt':
            FieldValue.serverTimestamp(),
      });
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatScreen(
          chatId: chatId,
          seller: 'Seller',
          adTitle: ad.title,
        ),
      ),
    );
  }

  Future<void> _whatsapp(
    Ad ad,
  ) async {
    final number =
        ad.whatsapp.replaceAll(
      RegExp(r'[^0-9]'),
      '',
    );

    if (number.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'Seller has not added WhatsApp yet.',
          ),
        ),
      );
      return;
    }

    final uri = Uri.parse(
      'https://wa.me/$number?text=${Uri.encodeComponent(
        'Olá, vi o seu anúncio no MOZ MARKET: ${ad.title}',
      )}',
    );

    final opened =
        await launchUrl(
      uri,
      mode:
          LaunchMode.externalApplication,
    );

    if (!opened && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'WhatsApp could not be opened.',
          ),
        ),
      );
    }
  }
}

class ChatScreen extends StatefulWidget {
  final String chatId;
  final String seller;
  final String adTitle;

  const ChatScreen({
    super.key,
    required this.chatId,
    required this.seller,
    required this.adTitle,
  });

  @override
  State<ChatScreen> createState() =>
      _ChatScreenState();
}

class _ChatScreenState
    extends State<ChatScreen> {
  final TextEditingController
      controller =
      TextEditingController();

  final ScrollController
      scrollController =
      ScrollController();

  String get myUserId {
    return FirebaseAuth
            .instance.currentUser
            ?.uid ??
        '';
  }

  CollectionReference<
      Map<String, dynamic>>
  get messageCollection {
    return FirebaseFirestore
        .instance
        .collection('chats')
        .doc(widget.chatId)
        .collection('messages');
  }

  @override
  void dispose() {
    controller.dispose();
    scrollController.dispose();
    super.dispose();
  }

  Future<void> send() async {
    final text =
        controller.text.trim();

    if (text.isEmpty) return;

    controller.clear();

    try {
      await messageCollection.add({
        'text': text,
        'senderId': myUserId,
        'timestamp':
            FieldValue.serverTimestamp(),
      });

      await FirebaseFirestore
          .instance
          .collection('chats')
          .doc(widget.chatId)
          .set(
        {
          'lastMessage': text,
          'lastMessageTime':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            'Message failed: $e',
          ),
        ),
      );
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance
        .addPostFrameCallback(
      (_) {
        if (!scrollController
            .hasClients) {
          return;
        }

        scrollController.animateTo(
          scrollController
              .position
              .maxScrollExtent,
          duration:
              const Duration(
            milliseconds: 250,
          ),
          curve: Curves.easeOut,
        );
      },
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const CircleAvatar(
              radius: 17,
              backgroundColor: green,
              child: Icon(
                Icons.person,
                size: 19,
                color: Colors.white,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment
                        .start,
                children: [
                  Text(
                    widget.seller,
                    style:
                        const TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                  if (widget.adTitle
                      .isNotEmpty)
                    Text(
                      widget.adTitle,
                      maxLines: 1,
                      overflow:
                          TextOverflow
                              .ellipsis,
                      style:
                          const TextStyle(
                        fontSize: 11,
                        color:
                            Colors.black54,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<
                QuerySnapshot<
                    Map<String,
                        dynamic>>>(
              stream: messageCollection
                  .orderBy(
                    'timestamp',
                    descending: false,
                  )
                  .snapshots(),
              builder:
                  (context, snapshot) {
                if (snapshot
                    .hasError) {
                  return const Center(
                    child: Text(
                      'Unable to load messages.',
                    ),
                  );
                }

                if (snapshot
                        .connectionState ==
                    ConnectionState
                        .waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                final docs =
                    snapshot.data?.docs ??
                        [];

                if (docs.isEmpty) {
                  return const Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons
                              .chat_bubble_outline,
                          size: 55,
                          color:
                              Colors.black26,
                        ),
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Start the conversation',
                          style:
                              TextStyle(
                            fontSize: 17,
                            fontWeight:
                                FontWeight
                                    .w700,
                          ),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'Send a message to the seller.',
                        ),
                      ],
                    ),
                  );
                }

                _scrollToBottom();

                return ListView.builder(
                  controller:
                      scrollController,
                  padding:
                      const EdgeInsets.all(
                    16,
                  ),
                  itemCount:
                      docs.length,
                  itemBuilder:
                      (context, i) {
                    final data =
                        docs[i].data();

                    final text =
                        data['text']
                                ?.toString() ??
                            '';

                    final senderId =
                        data['senderId']
                                ?.toString() ??
                            '';

                    final mine =
                        senderId ==
                            myUserId;

                    return Align(
                      alignment: mine
                          ? Alignment
                              .centerRight
                          : Alignment
                              .centerLeft,
                      child: Container(
                        constraints:
                            const BoxConstraints(
                          maxWidth: 300,
                        ),
                        margin:
                            const EdgeInsets
                                .only(
                          bottom: 10,
                        ),
                        padding:
                            const EdgeInsets
                                .symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration:
                            BoxDecoration(
                          color: mine
                              ? green
                              : Colors
                                  .white,
                          borderRadius:
                              BorderRadius
                                  .circular(
                            16,
                          ),
                          border: mine
                              ? null
                              : Border.all(
                                  color: Colors
                                      .black12,
                                ),
                        ),
                        child: Text(
                          text,
                          style:
                              TextStyle(
                            color: mine
                                ? Colors
                                    .white
                                : dark,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),

          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets
                      .fromLTRB(
                10,
                6,
                10,
                10,
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller:
                          controller,
                      textInputAction:
                          TextInputAction
                              .send,
                      onSubmitted:
                          (_) => send(),
                      decoration:
                          const InputDecoration(
                        hintText:
                            'Type a message / Escreva uma mensagem...',
                        prefixIcon:
                            Icon(
                          Icons
                              .chat_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  FloatingActionButton
                      .small(
                    backgroundColor:
                        green,
                    foregroundColor:
                        Colors.white,
                    onPressed: send,
                    child: const Icon(
                      Icons.send,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
