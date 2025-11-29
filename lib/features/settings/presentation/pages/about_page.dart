import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:go_router/go_router.dart';
import '../../../../l10n/generated/app_localizations.dart';

class AboutPage extends StatefulWidget {
  const AboutPage({super.key});

  @override
  State<AboutPage> createState() => _AboutPageState();
}

class _AboutPageState extends State<AboutPage> {
  String _version = '';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
  }

  Future<void> _loadPackageInfo() async {
    final info = await PackageInfo.fromPlatform();
    setState(() {
      _version = info.version;
      _buildNumber = info.buildNumber;
    });
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    // In a real app, these would be localized or fetched from remote config
    const contactEmail = 'support@gazacars.com';
    const contactPhone = '+972599000000'; // Example WhatsApp
    const websiteUrl = 'https://gazacars.com';

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.aboutApp),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // App Logo
            Center(
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: Theme.of(context).primaryColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.directions_car,
                  size: 60,
                  color: Theme.of(context).primaryColor,
                ),
              ),
            ),
            const SizedBox(height: 16),
            // App Name
            Text(
              l10n.appTitle,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            // Version
            Text(
              '${l10n.version} $_version ($_buildNumber)',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
            
            // Description
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Text(
                'The premier marketplace for buying and selling cars in Gaza. Connect with sellers, find your dream car, and trade with confidence.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
            ),
            const SizedBox(height: 32),

            const Divider(),
            
            // Contact Section
            _buildSectionHeader(context, l10n.contactUs),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: Text(l10n.emailSupport),
              subtitle: const Text(contactEmail),
              onTap: () => _launchUrl('mailto:$contactEmail'),
            ),
            ListTile(
              leading: const Icon(Icons.chat_outlined),
              title: Text(l10n.whatsappSupport),
              subtitle: const Text(contactPhone),
              onTap: () => _launchUrl('https://wa.me/${contactPhone.replaceAll('+', '')}'),
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(l10n.visitWebsite),
              subtitle: const Text(websiteUrl),
              onTap: () => _launchUrl(websiteUrl),
            ),

            const Divider(),

            // Legal Section
            _buildSectionHeader(context, l10n.legal),
            ListTile(
              leading: const Icon(Icons.privacy_tip_outlined),
              title: Text(l10n.privacyPolicy),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // Use GoRouter to navigate
                GoRouter.of(context).push('/privacy-policy');
              },
            ),
            ListTile(
              leading: const Icon(Icons.description_outlined),
              title: Text(l10n.termsOfService),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                // For now, we can reuse the privacy policy page or show a placeholder
                // Ideally, we should have a separate route.
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(l10n.termsOfServiceComingSoon)),
                );
              },
            ),

            const SizedBox(height: 32),
            
            // Copyright
            Text(
              l10n.copyright,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
        ),
      ),
    );
  }
}
