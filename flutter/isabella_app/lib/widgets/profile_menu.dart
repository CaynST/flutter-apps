import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../core/theme.dart';
import 'seal.dart';

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
    return PopupMenuButton<String>(
      tooltip: 'Perfil',
      offset: const Offset(0, 44),
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
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 6),
            child: Row(
              children: <Widget>[
                _AvatarCircle(
                  initials: _initials,
                  avatar: _showImage ? widget.avatar : null,
                  size: 34,
                  onError: () {},
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(widget.displayName, style: karla(weight: 700)),
                      Text(
                        widget.email,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: karla(size: 12, color: pencil),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'avatar',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.photo_camera_outlined, size: 20),
            title: Text('Cambiar foto'),
          ),
        ),
        if (widget.avatar != null)
          const PopupMenuItem<String>(
            value: 'remove',
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.hide_image_outlined, size: 20),
              title: Text('Quitar foto'),
            ),
          ),
        const PopupMenuItem<String>(
          value: 'complete',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.done_all, size: 20),
            title: Text('Marcar todas'),
          ),
        ),
        const PopupMenuDivider(),
        const PopupMenuItem<String>(
          value: 'signout',
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout, size: 20),
            title: Text('Cerrar sesión'),
          ),
        ),
      ],
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: _AvatarCircle(
          initials: _initials,
          avatar: _showImage ? widget.avatar : null,
          size: 34,
          onError: () {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) setState(() => _imageError = true);
            });
          },
        ),
      ),
    );
  }
}

class _AvatarCircle extends StatelessWidget {
  const _AvatarCircle({
    required this.initials,
    required this.avatar,
    required this.size,
    required this.onError,
  });

  final String initials;
  final Uint8List? avatar;
  final double size;
  final VoidCallback onError;

  @override
  Widget build(BuildContext context) {
    if (avatar == null) {
      return Seal(label: initials, size: size, color: moss);
    }
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: moss, width: 1.4),
        image: DecorationImage(
          image: MemoryImage(avatar!),
          fit: BoxFit.cover,
          onError: (_, _) => onError(),
        ),
      ),
    );
  }
}
