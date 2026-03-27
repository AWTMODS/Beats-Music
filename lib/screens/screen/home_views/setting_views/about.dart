import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:beats_music/core/theme/app_theme.dart';

class About extends StatelessWidget {
  const About({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'About',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // App Logo with green glow
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF1a1a1a),
                    boxShadow: [
                      BoxShadow(
                        color: Default_Theme.successAccent.withValues(alpha: 0.6),
                        blurRadius: 30,
                        spreadRadius: 4,
                      ),
                    ],
                    border: Border.all(
                      color: Default_Theme.successAccent.withValues(alpha: 0.5),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    MingCute.music_2_fill,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // App name
              const Text(
                'Beats',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.5,
                ),
              ),

              const SizedBox(height: 6),

              // Version
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  final ver = snapshot.hasData
                      ? 'v${snapshot.data!.version}'
                      : 'v1.0.0';
                  return Text(
                    ver,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  );
                },
              ),

              const SizedBox(height: 6),

              // Subtitle
              Text(
                'Your personal music companion',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.45),
                  fontSize: 14,
                ),
              ),

              const SizedBox(height: 32),

              // Developer Card
              _SectionCard(
                child: Column(
                  children: [
                    Text(
                      'Developed by',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Aadith C V',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      alignment: WrapAlignment.center,
                      children: [
                        _LinkButton(
                          icon: MingCute.github_fill,
                          label: 'GitHub',
                          url: 'https://github.com/awtmods',
                        ),
                        _LinkButton(
                          icon: FontAwesome.instagram_brand,
                          label: 'Instagram',
                          url: 'https://instagram.com/aadith.cv',
                        ),
                        _LinkButton(
                          icon: FontAwesome.telegram_brand,
                          label: 'Telegram',
                          url: 'https://t.me/artwebtech',
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Support Development Card
              _SectionCard(
                child: Column(
                  children: [
                    const Text(
                      'Support Development',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Help keep Beats ad-free and support future updates!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 20),
                    
                    // UPI & PayPal
                    Row(
                      children: [
                        Expanded(
                          child: _DonateItem(
                            icon: Icons.account_balance_wallet_rounded,
                            label: 'UPI ID',
                            value: 'aadithaadith14-2@okaxis',
                            onTap: () {
                              Clipboard.setData(const ClipboardData(text: 'aadithaadith14-2@okaxis'));
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('UPI ID copied to clipboard')),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _DonateItem(
                            icon: FontAwesome.paypal_brand,
                            label: 'PayPal',
                            value: 'DevAadith',
                            onTap: () => launchUrl(
                              Uri.parse('https://paypal.me/DevAadith'),
                              mode: LaunchMode.externalApplication,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    
                    // Crypto Wallets
                    _DonateItem(
                      icon: FontAwesome.bitcoin_brand,
                      label: 'BTC Address',
                      value: '15w6uDZ7aMAo9CqMBBNX8YkNH3qGEJzuDX',
                      isCrypto: true,
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: '15w6uDZ7aMAo9CqMBBNX8YkNH3qGEJzuDX'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('BTC Address copied to clipboard')),
                        );
                      },
                    ),
                    const SizedBox(height: 12),
                    _DonateItem(
                      icon: FontAwesome.ethereum_brand,
                      label: 'ETH / USDT (TRC20)',
                      value: 'TBgX4jo8byy2pjfUvWTiEbcUVbybBm7Q85',
                      isCrypto: true,
                      onTap: () {
                        Clipboard.setData(const ClipboardData(text: 'TBgX4jo8byy2pjfUvWTiEbcUVbybBm7Q85'));
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Wallet Address copied to clipboard')),
                        );
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Special Thanks Card
              _SectionCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(
                      child: Text(
                        'Special Thanks',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _ThanksItem(
                      icon: MingCute.leaf_3_fill,
                      iconColor: Default_Theme.successAccent,
                      name: 'Bloomee',
                      description: 'Inspiration & Open Source',
                      url: 'https://github.com/AWTMODS/Beats-Music',
                    ),
                    const SizedBox(height: 12),
                    _ThanksItem(
                      icon: MingCute.code_fill,
                      iconColor: const Color(0xFF54C5F8),
                      name: 'Flutter',
                      description: 'UI Framework',
                      url: 'https://flutter.dev',
                    ),
                    const SizedBox(height: 12),
                    _ThanksItem(
                      icon: MingCute.music_2_fill,
                      iconColor: Colors.orangeAccent,
                      name: 'iTunes API',
                      description: 'Music Data Provider',
                      url: 'https://developer.apple.com/library/archive/documentation/AudioVideo/Conceptual/iTuneSearchAPI',
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Open Source Card
              _SectionCard(
                child: Column(
                  children: [
                    const Text(
                      'Open Source',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Beats is open source and built with love.\nContributions are always welcome!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.55),
                        fontSize: 13,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _LinkButton(
                      icon: MingCute.github_fill,
                      label: 'View on GitHub',
                      url: 'https://github.com/AWTMODS/Beats-Music',
                      fullWidth: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Footer
              Text(
                'Made with ❤️ for music lovers',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.3),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final Widget child;
  const _SectionCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.07),
          width: 1,
        ),
      ),
      child: child,
    );
  }
}

class _LinkButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final String url;
  final bool fullWidth;

  const _LinkButton({
    required this.icon,
    required this.label,
    required this.url,
    this.fullWidth = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        width: fullWidth ? double.infinity : null,
        alignment: fullWidth ? Alignment.center : null,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.min : MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ThanksItem extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String name;
  final String description;
  final String url;

  const _ThanksItem({
    required this.icon,
    required this.iconColor,
    required this.name,
    required this.description,
    required this.url,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: iconColor.withValues(alpha: 0.3),
              ),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios_rounded,
            color: Colors.white.withValues(alpha: 0.25),
            size: 14,
          ),
        ],
      ),
    );
  }
}

class _DonateItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;
  final bool isCrypto;

  const _DonateItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.onTap,
    this.isCrypto = false,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.08),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Colors.white.withValues(alpha: 0.7), size: 16),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 13,
                fontWeight: FontWeight.w700,
                fontFamily: isCrypto ? 'monospace' : null,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
