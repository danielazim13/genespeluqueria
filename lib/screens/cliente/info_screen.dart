import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Información'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileHeader(),
            SizedBox(height: 16.0),
            _buildInfoTile(
              icon: FontAwesomeIcons.mapMarkerAlt,
              title: 'Location',
              content: 'Güemes 4507\nPalermo',
              onTap: () => _launchUrl(
                  'https://www.google.com/maps/search/?api=1&query=G%C3%BCemes+4507+Palermo'),
            ),
            SizedBox(height: 16.0),
            _buildInfoTile(
              icon: FontAwesomeIcons.instagram,
              title: 'Instagram',
              content: 'genespeluqueria',
              onTap: () =>
                  _launchUrl('https://www.instagram.com/genespeluqueria/'),
            ),
            SizedBox(height: 16.0),
            _buildInfoTile(
              icon: FontAwesomeIcons.whatsapp,
              title: 'WhatsApp',
              content: '541166417552',
              onTap: () => _launchUrl('https://wa.me/541166417552'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        CircleAvatar(
          backgroundImage: Image.asset('lib/assets/logo.jpg').image,
          radius: 32.0,
        ),
        SizedBox(width: 16.0),
        Expanded (child:         Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Genes peluqueria',
              style: TextStyle(
                fontSize: 18.0,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              '✨Salón de Belleza 💇‍♀️💅',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '⚡️𝐄𝐱𝐩𝐞𝐫𝐭𝐚 𝐞𝐧 𝐞𝐥 𝐜𝐮𝐢𝐝𝐚𝐝𝐨 𝐝𝐞 𝐭𝐮 𝐜𝐚𝐛𝐞𝐥𝐥𝐨💯',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 4.0),
            Text(
              '⌚️ Martes a sábados 10hs-19hs',
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey[600],
              ),
            ),

          ],
        ),),
      ],
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    required String content,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 32.0),
          SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16.0,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  content,
                  style: TextStyle(
                    fontSize: 14.0,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _launchUrl(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
