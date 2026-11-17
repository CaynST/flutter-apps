import 'dart:typed_data';

import 'package:flutter/material.dart';

class ProfileMenu extends StatefulWidget {
  const ProfileMenu({
    super.key,
    required this.displayName,
    required this.email,
    required this.avatar,
    required this.onPickAvatar,
    required this.onRemoveAvatar,
    required this.onCompleteAll,
    required this.onSignOut,
  });

  final String displayName;
  final String email;
  final Uint8List? avatar;
  final VoidCallback onPickAvatar;
  final VoidCallback onRemoveAvatar;
  final VoidCallback onCompleteAll;
  final VoidCallback onSignOut;

  @override
  State<ProfileMenu> createState() => _ProfileMenuState();
}

class _ProfileMenuState extends State<ProfileMenu> {
  bool _imageError = false;

  @override
  void didUpdateWidget(ProfileMenu oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.avatar != widget.avatar) _imageError = false;
  }

  String get _initials {
    final List<String> parts = widget.displayName
        .trim()
        .split(RegExp(r'\s+'))
        .where((String part) => part.isNotEmpty)
        .toList(growable: false);
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts[0].substring(0, 1) + parts[1].substring(0, 1))
        .toUpperCase();
  }

  bool get _showImage => widget.avatar != null && !_imageError;

  @override
  Widget build(BuildContext context) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<String>(
      tooltip: 'Perfil',
      offset: const Offset(0, 48),
      onSelected: (String value) {
        switch (value) {
          case 'avatar':
            widget.onPickAvatar();
          case 'remove':
            widget.onRemoveAvatar();
          case 'complete':
            widget.onCompleteAll();
          case 'signout':
            widget.onSignOut();
        }
      },
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        PopupMenuItem<String>(
          enabled: false,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: CircleAvatar(
              backgroundColor: scheme.primaryContainer,
              backgroundImage:
                  _showImage ? MemoryImage(widget.avatar!) : null,
              child: _showImage
                  ? null
                  : Text(
                      _initials,
                      style: TextStyle(color: scheme.onPrimaryContainer),
                    ),
            ),
            title: Text(widget.displayName),
            subtitle: Text(widget.email),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'avatar',
          child: ListTile(
            leading: Icon(Icons.photo_camera_outlined),
            title: Text('Cambiar foto'),
          ),
        ),
        if (widget.avatar != null)
          const PopupMenuItem<String>(
            value: 'remove',
            child: ListTile(
              leading: Icon(Icons.hide_image_outlined),
              title: Text('Quitar foto'),
            ),
          ),
        const PopupMenuItem<String>(
          value: 'complete',
          child: ListTile(
            leading: Icon(Icons.done_all),
            title: Text('Completar todas'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'signout',
          child: ListTile(
            leading: Icon(Icons.logout),
            title: Text('Cerrar sesión'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: scheme.primaryContainer,
          backgroundImage: _showImage ? MemoryImage(widget.avatar!) : null,
          onBackgroundImageError: _showImage
              ? (_, _) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted) setState(() => _imageError = true);
                  });
                }
              : null,
          child: _showImage
              ? null
              : Text(
                  _initials,
                  style: TextStyle(
                    color: scheme.onPrimaryContainer,
                    fontSize: 12,
                  ),
                ),
        ),
      ),
    );
  }
}
