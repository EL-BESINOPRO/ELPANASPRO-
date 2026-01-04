import 'dart:io';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/app_model.dart';

class AppCard extends StatelessWidget {
  final AppModel app;
  const AppCard({required this.app});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(12),
        child: Column(
          children: [
            // icon + info
            Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(app.icon, width: 64, height: 64, fit: BoxFit.cover, errorBuilder: (_, __, ___) {
                    return Container(width: 64, height: 64, color: Colors.grey, child: Icon(Icons.apps));
                  }),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(app.name, style: Theme.of(context).textTheme.subtitle1),
                      SizedBox(height: 6),
                      Text(app.humanSize, style: Theme.of(context).textTheme.caption),
                    ],
                  ),
                )
              ],
            ),
            SizedBox(height: 12),
            Expanded(child: Text(app.description, maxLines: 3, overflow: TextOverflow.ellipsis)),
            SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: Icon(Icons.download),
                    label: Text('Install'),
                    onPressed: () => _onInstall(context),
                    style: ElevatedButton.styleFrom(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.play_arrow),
                  onPressed: () => _onLaunch(context),
                )
              ],
            )
          ],
        ),
      ),
    );
  }

  void _onInstall(BuildContext context) async {
    // Basic cross-platform strategy:
    // - Android: open playstore url or apk link
    // - iOS: open app store url
    // - Windows: download installer URL or open installer
    final platforms = app.platforms ?? {};
    if (Platform.isAndroid) {
      final url = platforms['android']?['playstore_url'] ?? platforms['android']?['installer_url'] ?? platforms['web']?['url'];
      if (url != null) launchUrl(Uri.parse(url));
      else _showMessage(context, 'No Android installer provided.');
    } else if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final url = platforms['windows']?['installer_url'] ?? platforms['web']?['url'];
      if (url != null) launchUrl(Uri.parse(url));
      else _showMessage(context, 'No installer available for this desktop platform.');
    } else if (Platform.isIOS) {
      final url = platforms['ios']?['app_store_url'] ?? platforms['web']?['url'];
      if (url != null) launchUrl(Uri.parse(url));
      else _showMessage(context, 'No App Store entry available.');
    } else {
      final url = platforms['web']?['url'];
      if (url != null) launchUrl(Uri.parse(url));
      else _showMessage(context, 'No installer available.');
    }
  }

  void _onLaunch(BuildContext context) async {
    // Attempt to launch via deep link or open store/web fallback
    final platforms = app.platforms ?? {};
    final deep = platforms['deep_link'] ?? platforms['android']?['deep_link'] ?? platforms['ios']?['deep_link'];
    final web = platforms['web']?['url'];
    final store = platforms['android']?['playstore_url'] ?? platforms['ios']?['app_store_url'];

    if (deep != null) {
      if (await canLaunchUrl(Uri.parse(deep))) {
        launchUrl(Uri.parse(deep));
        return;
      }
    }
    if (web != null) {
      launchUrl(Uri.parse(web));
      return;
    }
    if (store != null) {
      launchUrl(Uri.parse(store));
      return;
    }
    _showMessage(context, 'No launch method available.');
  }

  void _showMessage(BuildContext context, String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }
}