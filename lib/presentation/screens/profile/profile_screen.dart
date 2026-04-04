import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/user_provider.dart';
import 'user_expenses_screen.dart';
import 'user_groups_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () => _showSettingsDialog(context),
            tooltip: 'Ayarlar',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),
            // Profile Header
            Center(
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.person,
                      size: 60,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    userProvider.userName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Text(
                    userProvider.userEmail,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                        ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () => _showEditProfileDialog(context, userProvider),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Profili Düzenle'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Profile Info List
            const Divider(),
            _ProfileMenuItem(
              icon: Icons.account_balance_wallet_outlined,
              title: 'Harcamalarım',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserExpensesScreen()),
                );
              },
            ),
            _ProfileMenuItem(
              icon: Icons.group_outlined,
              title: 'Gruplarım',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const UserGroupsScreen()),
                );
              },
            ),
            const Divider(),
            _ProfileMenuItem(
              icon: Icons.logout,
              title: 'Çıkış Yap',
              textColor: AppColors.error,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
    final nameController = TextEditingController(text: userProvider.userName);
    final emailController = TextEditingController(text: userProvider.userEmail);
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Profili Düzenle'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Ad Soyad'),
                validator: (v) => v!.isEmpty ? 'Gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'E-posta'),
                validator: (v) => v!.isEmpty ? 'Gerekli' : null,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                userProvider.updateUserData(
                  nameController.text.trim(),
                  emailController.text.trim(),
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    );
  }

  void _showSettingsDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Ayarlar',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Consumer<ThemeProvider>(
                  builder: (_, themeProvider, __) => SwitchListTile(
                    secondary: Icon(
                      themeProvider.isDark ? Icons.dark_mode : Icons.light_mode,
                      color: AppColors.primary,
                    ),
                    title: const Text('Karanlık Mod'),
                    subtitle: Text(
                      themeProvider.isDark ? 'Açık moda geç' : 'Karanlık moda geç',
                    ),
                    value: themeProvider.isDark,
                    onChanged: (value) {
                      themeProvider.toggleTheme();
                    },
                    activeThumbColor: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final Color? textColor;

  const _ProfileMenuItem({
    required this.icon,
    required this.title,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.primary),
      title: Text(
        title,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, size: 20),
      onTap: onTap,
    );
  }
}
