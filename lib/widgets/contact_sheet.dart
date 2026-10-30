import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../services/launcher_service.dart';
import '../theme/app_theme.dart';

Future<void> showContactSheet(
  BuildContext context, {
  String highlight = 'call',
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => _ContactSheet(highlight: highlight),
  );
}

class _ContactSheet extends StatelessWidget {
  const _ContactSheet({required this.highlight});

  final String highlight;

  Future<void> _run(
    BuildContext context,
    Future<bool> Function() action,
    String success,
    String failure,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    final ok = await action();
    if (context.mounted) Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(ok ? success : failure)));
  }

  Future<void> _copy(BuildContext context) async {
    final messenger = ScaffoldMessenger.of(context);
    await LauncherService.copyPhone(AppConfig.storePhone);
    if (context.mounted) Navigator.of(context).pop();
    messenger.showSnackBar(
      SnackBar(content: Text('Nomor ${AppConfig.storePhone} disalin.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final callTile = _ActionTile(
      icon: Icons.call,
      title: 'Telepon Sekarang',
      subtitle: AppConfig.storePhone,
      highlighted: highlight == 'call',
      onTap: () => _run(
        context,
        () => LauncherService.makePhoneCall(AppConfig.storePhone),
        'Membuka aplikasi telepon...',
        'Perangkat ini tidak mendukung panggilan langsung. Gunakan WhatsApp.',
      ),
    );
    final smsTile = _ActionTile(
      icon: Icons.sms,
      title: 'Kirim SMS',
      subtitle: 'Pesan otomatis ke admin toko',
      highlighted: highlight == 'sms',
      onTap: () => _run(
        context,
        () =>
            LauncherService.sendSms(AppConfig.storePhone, AppConfig.smsMessage),
        'Membuka aplikasi SMS...',
        'Aplikasi SMS tidak tersedia. Gunakan WhatsApp.',
      ),
    );
    final waTile = _ActionTile(
      icon: Icons.chat,
      title: 'Chat WhatsApp',
      subtitle: 'Respon cepat dari admin',
      onTap: () => _run(
        context,
        () => LauncherService.openWhatsApp(
          AppConfig.storePhone,
          AppConfig.smsMessage,
        ),
        'Membuka WhatsApp...',
        'Tidak dapat membuka WhatsApp.',
      ),
    );
    final copyTile = _ActionTile(
      icon: Icons.copy,
      title: 'Salin Nomor',
      subtitle: 'Simpan nomor untuk dihubungi nanti',
      onTap: () => _copy(context),
    );

    final tiles = highlight == 'sms'
        ? [smsTile, waTile, callTile, copyTile]
        : [callTile, waTile, smsTile, copyTile];

    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 22),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.line,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: AppGradients.primary,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.18),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.support_agent,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Hubungi Kami',
                          style: TextStyle(
                            fontFamily: AppTheme.heading,
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          AppConfig.storeName,
                          style: TextStyle(
                            fontFamily: AppTheme.body,
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            ...tiles,
            const SizedBox(height: 10),
            const Text(
              'Di browser desktop, panggilan/SMS langsung bisa saja tidak '
              'tersedia. Gunakan WhatsApp atau salin nomor.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.body,
                fontSize: 11,
                height: 1.4,
                color: AppColors.muted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.highlighted = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: highlighted
            ? AppColors.sageGreen.withValues(alpha: 0.16)
            : AppColors.cream,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(
            color: highlighted ? AppColors.sageGreen : AppColors.line,
          ),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: highlighted ? AppColors.darkGreen : AppColors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: highlighted ? Colors.white : AppColors.darkGreen,
              size: 20,
            ),
          ),
          title: Text(
            title,
            style: const TextStyle(
              fontFamily: AppTheme.heading,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.charcoal,
            ),
          ),
          subtitle: Text(
            subtitle,
            style: const TextStyle(
              fontFamily: AppTheme.body,
              fontSize: 12,
              color: AppColors.muted,
            ),
          ),
          trailing: const Icon(Icons.chevron_right, size: 18),
        ),
      ),
    );
  }
}
