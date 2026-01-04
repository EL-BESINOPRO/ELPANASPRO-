import 'dart:convert';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'models/app_model.dart';
import 'widgets/app_card.dart';

void main() {
  runApp(ElPanasLauncher());
}

class ElPanasLauncher extends StatefulWidget {
  @override
  _ElPanasLauncherState createState() => _ElPanasLauncherState();
}

class _ElPanasLauncherState extends State<ElPanasLauncher> {
  ThemeMode _themeMode = ThemeMode.system;
  List<AppModel> apps = [];
  String query = '';

  @override
  void initState() {
    super.initState();
    loadApps();
  }

  Future<void> loadApps() async {
    final jsonStr = await rootBundle.loadString('assets/apps.json');
    final List parsed = json.decode(jsonStr);
    setState(() {
      apps = parsed.map((e) => AppModel.fromJson(e)).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ElPanas Launcher',
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: ThemeData.light().copyWith(
        scaffoldBackgroundColor: Colors.grey[100],
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
        ),
      ),
      darkTheme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        cardTheme: CardTheme(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 6,
        ),
      ),
      home: Scaffold(
        body: SafeArea(
          child: Row(
            children: [
              // Sidebar (desktop) - responsive
              LayoutBuilder(builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 800;
                return isNarrow
                    ? SizedBox.shrink()
                    : Container(
                        width: 250,
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('ElPanas', style: Theme.of(context).textTheme.headline6),
                            SizedBox(height: 12),
                            Expanded(
                              child: ListView(
                                children: [
                                  _sidebarItem(Icons.games, 'Games'),
                                  _sidebarItem(Icons.build, 'Tools'),
                                  _sidebarItem(Icons.edit, 'Editors'),
                                  _sidebarItem(Icons.settings, 'Settings'),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Theme'),
                                Switch(
                                  value: _themeMode == ThemeMode.dark,
                                  onChanged: (v) {
                                    setState(() {
                                      _themeMode = v ? ThemeMode.dark : ThemeMode.light;
                                    });
                                  },
                                )
                              ],
                            )
                          ],
                        ),
                      );
              }),
              // Main content
              Expanded(
                child: Column(
                  children: [
                    // Top bar with acrylic blur
                    Padding(
                      padding: EdgeInsets.all(12),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: Theme.of(context).brightness == Brightness.dark
                                ? Colors.white.withOpacity(0.03)
                                : Colors.white.withOpacity(0.6),
                            child: Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    decoration: InputDecoration(
                                      hintText: 'Search apps, games...',
                                      prefixIcon: Icon(Icons.search),
                                      border: InputBorder.none,
                                    ),
                                    onChanged: (v) => setState(() => query = v),
                                  ),
                                ),
                                SizedBox(width: 12),
                                IconButton(
                                  icon: Icon(Icons.refresh),
                                  onPressed: () => loadApps(),
                                )
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Content grid
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 12),
                        child: LayoutBuilder(builder: (context, constraints) {
                          final width = constraints.maxWidth;
                          int crossAxisCount = 2;
                          if (width > 1200) crossAxisCount = 5;
                          else if (width > 900) crossAxisCount = 4;
                          else if (width > 600) crossAxisCount = 3;

                          final filtered = apps.where((a) {
                            final q = query.toLowerCase();
                            return q.isEmpty ||
                                a.name.toLowerCase().contains(q) ||
                                (a.description ?? '').toLowerCase().contains(q);
                          }).toList();

                          return GridView.builder(
                            padding: EdgeInsets.only(bottom: 24),
                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: crossAxisCount,
                              childAspectRatio: 0.85,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                            itemCount: filtered.length,
                            itemBuilder: (context, idx) {
                              return AppCard(app: filtered[idx]);
                            },
                          );
                        }),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _sidebarItem(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {},
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}