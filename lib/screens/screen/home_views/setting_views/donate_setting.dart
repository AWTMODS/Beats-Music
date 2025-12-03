import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:icons_plus/icons_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:beats_music/theme_data/default.dart';
import 'package:beats_music/screens/widgets/snackbar.dart';

class DonateSettings extends StatelessWidget {
  const DonateSettings({super.key});

  // UPI ID
  static const String upiId = "aadithaadith14-2@okaxis";
  
  // PayPal username
  static const String paypalUsername = "DevAadith";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Default_Theme.themeColor,
      appBar: AppBar(
        backgroundColor: Default_Theme.themeColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Default_Theme.primaryColor1),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Support Development',
          style: TextStyle(
            color: Default_Theme.primaryColor1,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Support Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Default_Theme.cardColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6B2C91),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    child: const Icon(
                      Icons.favorite,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Support the Developer',
                    style: TextStyle(
                      color: Default_Theme.primaryColor1,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Help keep this app free and support future development by making a donation. Every contribution helps!',
                    style: TextStyle(
                      color: Default_Theme.primaryColor2.withOpacity(0.8),
                      fontSize: 14,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // UPI Donation Section
            const Text(
              'UPI Donation (Easy)',
              style: TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Default_Theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildUpiAppTile(
                    context,
                    appName: "Google Pay",
                    icon: FontAwesome.google_pay_brand,
                    packageName: "com.google.android.apps.nbu.paisa.user",
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _buildUpiAppTile(
                    context,
                    appName: "PhonePe",
                    icon: Icons.account_balance_wallet,
                    packageName: "com.phonepe.app",
                  ),
                  const Divider(color: Colors.white10, height: 1),
                  _buildUpiAppTile(
                    context,
                    appName: "Paytm",
                    icon: Icons.wallet,
                    packageName: "net.one97.paytm",
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // PayPal Donation Section
            const Text(
              'PayPal Donation',
              style: TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              decoration: BoxDecoration(
                color: Default_Theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildPayPalTile(context),
            ),
            const SizedBox(height: 32),

            // Cryptocurrency Donations Section
            const Text(
              'Cryptocurrency Donations',
              style: TextStyle(
                color: Default_Theme.primaryColor1,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Click on any address to copy it to your clipboard',
              style: TextStyle(
                color: Default_Theme.primaryColor2.withOpacity(0.7),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            
            // Tether Card
            Container(
              decoration: BoxDecoration(
                color: Default_Theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildCryptoTile(
                context,
                name: "Tether",
                symbol: "USDT",
                icon: Icons.currency_bitcoin,
                address: "TBgX4jo8byy2pjfUvWTiEbcUVbybBm7Q85",
                color: const Color(0xFF26A17B),
              ),
            ),
            const SizedBox(height: 12),
            
            // Bitcoin Card
            Container(
              decoration: BoxDecoration(
                color: Default_Theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildCryptoTile(
                context,
                name: "Bitcoin",
                symbol: "BTC",
                icon: FontAwesome.bitcoin_brand,
                address: "15w6uDZ7aMAo9CqMBBNX8YkNH3qGEJzuDX",
                color: const Color(0xFFF7931A),
              ),
            ),
            const SizedBox(height: 12),
            
            // Ethereum Card
            Container(
              decoration: BoxDecoration(
                color: Default_Theme.cardColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: _buildCryptoTile(
                context,
                name: "Ethereum",
                symbol: "ETH",
                icon: FontAwesome.ethereum_brand,
                address: "TBgX4jo8byy2pjfUvWTiEbcUVbybBm7Q85",
                color: const Color(0xFF627EEA),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildUpiAppTile(
    BuildContext context, {
    required String appName,
    required IconData icon,
    required String packageName,
  }) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: Default_Theme.spotifyGreen.withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: 24,
          color: Default_Theme.spotifyGreen,
        ),
      ),
      title: Text(
        appName,
        style: const TextStyle(
          color: Default_Theme.primaryColor1,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        'Pay via $appName',
        style: TextStyle(
          color: Default_Theme.primaryColor2.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Default_Theme.primaryColor2,
        size: 18,
      ),
      onTap: () async {
        final Uri uri = Uri.parse('upi://pay?pa=$upiId&pn=Beats%20Donation&cu=INR');
        try {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } else {
            SnackbarService.showMessage(
              "Could not launch $appName. Please make sure it's installed.",
            );
          }
        } catch (e) {
          SnackbarService.showMessage(
            "Could not launch $appName: $e",
          );
        }
      },
    );
  }

  Widget _buildPayPalTile(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF0070BA).withOpacity(0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(
          FontAwesome.paypal_brand,
          size: 24,
          color: Color(0xFF0070BA),
        ),
      ),
      title: const Text(
        'PayPal',
        style: TextStyle(
          color: Default_Theme.primaryColor1,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '@$paypalUsername',
        style: TextStyle(
          color: Default_Theme.primaryColor2.withOpacity(0.7),
          fontSize: 12,
        ),
      ),
      trailing: const Icon(
        Icons.arrow_forward_ios,
        color: Default_Theme.primaryColor2,
        size: 18,
      ),
      onTap: () async {
        final Uri uri = Uri.parse('https://paypal.me/$paypalUsername');
        try {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } catch (e) {
          SnackbarService.showMessage(
            "Could not open PayPal: $e",
          );
        }
      },
    );
  }

  Widget _buildCryptoTile(
    BuildContext context, {
    required String name,
    required String symbol,
    required IconData icon,
    required String address,
    required Color color,
  }) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: address));
        SnackbarService.showMessage(
          "$name address copied to clipboard",
        );
      },
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    size: 24,
                    color: color,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: const TextStyle(
                          color: Default_Theme.primaryColor1,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        symbol,
                        style: TextStyle(
                          color: color,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.copy,
                  color: Default_Theme.primaryColor2,
                  size: 20,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Default_Theme.cardColorLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(
                        color: Default_Theme.primaryColor2.withOpacity(0.9),
                        fontSize: 12,
                        fontFamily: 'monospace',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                'Tap to copy address',
                style: TextStyle(
                  color: Default_Theme.primaryColor2.withOpacity(0.6),
                  fontSize: 11,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
