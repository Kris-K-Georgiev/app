import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart' show XFile;
import '../icons/app_icons.dart';
import 'profile_edit_screen.dart';
import 'settings_screen.dart';

class ProfileScreen extends StatefulWidget { const ProfileScreen({super.key}); @override State<ProfileScreen> createState()=> _ProfileScreenState(); }

class _ProfileScreenState extends State<ProfileScreen>{
  XFile? _avatar;

  @override
  Widget build(BuildContext context){
  final isDark = Theme.of(context).brightness == Brightness.dark;
  final iconColor = isDark ? Colors.white : null;
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        Map user = {};
        String name = '—';
        try {
          user = auth.user ?? {};
          name = user['name']?.toString() ?? '—';
        } catch (err) {
          return const _EmptyTab(label: 'Няма любими');
        }
    // Minimal profile info only
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.only(top: 24, left: 32, right: 32, bottom: 0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Профил',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 28,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.edit, color: iconColor),
                    tooltip: 'Редактирай профил',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileEditScreen()));
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.settings, color: iconColor),
                    tooltip: 'Настройки',
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (_) => SettingsScreen()));
                    },
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double maxW = constraints.maxWidth < 600 ? constraints.maxWidth * 0.95 : constraints.maxWidth < 900 ? 480 : 600;
                return Center(
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: constraints.maxWidth < 600 ? 8 : 32),
                    constraints: BoxConstraints(maxWidth: maxW),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(.07), blurRadius: 14, offset: const Offset(0,6))],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: CircleAvatar(
                            radius: 54,
                            backgroundImage: user['avatar_path'] != null && user['avatar_path'].toString().isNotEmpty
                                ? NetworkImage(user['avatar_path'].toString())
                                : null,
                            child: (user['avatar_path'] == null || user['avatar_path'].toString().isEmpty)
                                ? Text(name.isNotEmpty ? name[0] : '?', style: Theme.of(context).textTheme.headlineSmall)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                        const SizedBox(height: 8),
                        _RolePill(role: user['role']),
                        if(user['city']!=null) ...[
                          const SizedBox(height: 8),
                          _InlineInfo(icon: AppIcons.location(size:16, color: iconColor), text: user['city'].toString()),
                        ],
                        if(user['email']!=null) ...[
                          const SizedBox(height: 8),
                          _InlineInfo(icon: AppIcons.audience(size:16, color: iconColor), text: user['email'].toString()),
                        ],
                        if(user['phone']!=null && user['phone'].toString().isNotEmpty) ...[
                          const SizedBox(height: 8),
                          _InlineInfo(icon: AppIcons.people(size:16, color: iconColor), text: user['phone'].toString()),
                        ],
                        const SizedBox(height: 18),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surfaceContainerHighest,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(.18)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Биография', style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700)),
                              const SizedBox(height: 8),
                              Text((user['bio'] ?? 'Няма био').toString(), style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
      },
    );
  }
}

class _EmptyTab extends StatelessWidget {
  final String label; const _EmptyTab({required this.label});
  @override Widget build(BuildContext context){
    return Center(child: Text(label, style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.onSurface.withOpacity(.55))));
  }
}

class _InlineInfo extends StatelessWidget {
  final Widget icon; final String text; const _InlineInfo({required this.icon, required this.text});
  @override Widget build(BuildContext context){
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: scheme.outline.withOpacity(.25)),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children:[
        IconTheme(data: const IconThemeData(size:16), child: icon),
        const SizedBox(width:6),
        Text(text, style: Theme.of(context).textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w500)),
      ]),
    );
  }
}

class _RolePill extends StatelessWidget {
  final dynamic role; const _RolePill({this.role});
  @override Widget build(BuildContext context){
    final map = {
      'admin':'Администратор',
      'director':'Директор',
      'teacher':'Учител',
    };
    final label = map[role] ?? 'Потребител';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal:14, vertical:6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Theme.of(context).colorScheme.outline.withOpacity(.25)),
        color: Theme.of(context).colorScheme.surface,
      ),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
    );
  }
}

