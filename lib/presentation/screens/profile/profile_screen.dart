import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/theme_provider.dart';
import '../../../core/theme/user_provider.dart';
import '../auth/login_screen.dart';
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
              icon: Icons.lock_outline,
              title: 'Şifre Değiştir',
              onTap: () => _showChangePasswordDialog(context),
            ),
            _ProfileMenuItem(
              icon: Icons.logout,
              title: 'Çıkış Yap',
              textColor: AppColors.error,
              onTap: () {
                AuthService.instance.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserProvider userProvider) {
    final nameController = TextEditingController();
    final emailController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    const hintStyle = TextStyle(
      color: Color(0xFFAAAAAA),
      fontStyle: FontStyle.italic,
      fontSize: 14,
    );

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
                style: const TextStyle(color: Color(0xFF212121)),
                decoration: const InputDecoration(
                  hintText: 'Ad Soyad',
                  hintStyle: hintStyle,
                  fillColor: Colors.white,
                  filled: true,
                ),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Gerekli' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: emailController,
                style: const TextStyle(color: Color(0xFF212121)),
                decoration: const InputDecoration(
                  hintText: 'E-posta',
                  hintStyle: hintStyle,
                  fillColor: Colors.white,
                  filled: true,
                ),
                keyboardType: TextInputType.emailAddress,
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Gerekli' : null,
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

  void _showChangePasswordDialog(BuildContext context) {
    final oldController = TextEditingController();
    final newController = TextEditingController();
    final confirmController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool oldObscure = true;
    bool newObscure = true;

    const hintStyle = TextStyle(
      color: Color(0xFFAAAAAA),
      fontStyle: FontStyle.italic,
      fontSize: 14,
    );
    const inputStyle = TextStyle(color: Color(0xFF212121));
    const whiteFill = InputDecoration(
      filled: true,
      fillColor: Colors.white,
    );

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          title: const Text('Şifre Değiştir'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: oldController,
                  style: inputStyle,
                  obscureText: oldObscure,
                  decoration: whiteFill.copyWith(
                    hintText: 'Mevcut şifre',
                    hintStyle: hintStyle,
                    suffixIcon: IconButton(
                      icon: Icon(oldObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setDialogState(() => oldObscure = !oldObscure),
                    ),
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Gerekli' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: newController,
                  style: inputStyle,
                  obscureText: newObscure,
                  decoration: whiteFill.copyWith(
                    hintText: 'Yeni şifre',
                    hintStyle: hintStyle,
                    suffixIcon: IconButton(
                      icon: Icon(newObscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setDialogState(() => newObscure = !newObscure),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Gerekli';
                    if (v.length < 3) return 'En az 3 karakter';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: confirmController,
                  style: inputStyle,
                  obscureText: true,
                  decoration: whiteFill.copyWith(
                    hintText: 'Yeni şifreyi tekrarla',
                    hintStyle: hintStyle,
                  ),
                  validator: (v) => v != newController.text
                      ? 'Şifreler eşleşmiyor'
                      : null,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('İptal'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;
                final success = await AuthService.instance.changePassword(
                  oldController.text,
                  newController.text,
                );
                if (!ctx.mounted) return;
                if (success) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Şifre başarıyla değiştirildi')),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Mevcut şifre hatalı'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                }
              },
              child: const Text('Kaydet'),
            ),
          ],
        ),
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
