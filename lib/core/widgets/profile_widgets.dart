import 'package:cached_network_image/cached_network_image.dart';
import 'package:core_project/core/sessions/auth_session.dart';
import 'package:flutter/material.dart';

class UserProfileAvatar extends StatelessWidget {
  const UserProfileAvatar({super.key});

  Color _getAvatarColor(String? name) {
    if (name == null || name.isEmpty) return Colors.blue;
    final int hash = name.codeUnits.fold(0, (prev, element) => prev + element);
    final List<Color> colors = [
      Colors.blue,
      Colors.indigo,
      Colors.teal,
      Colors.green,
      Colors.orange,
      Colors.deepOrange,
      Colors.purple,
      Colors.pink,
      Colors.brown,
      Colors.blueGrey,
    ];
    return colors[hash % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<List<String?>>(
        future: Future.wait([
          AuthSession.getPhotoUrl(),
          AuthSession.getName(),
        ]),
        builder: (context, snapshot) {
          final data = snapshot.data;
          final photoUrl = data != null && data.isNotEmpty ? data[0] : null;
          final name = data != null && data.length > 1 ? data[1] : null;
          final initial = (name != null && name.isNotEmpty)
              ? name[0].toUpperCase()
              : 'U';

          return CircleAvatar(
            radius: 50,
            backgroundColor: _getAvatarColor(name),
            backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                ? CachedNetworkImageProvider(photoUrl)
                : null,
            child: photoUrl == null || photoUrl.isEmpty
                ? Text(
                    initial,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }
}

class UserNameWidget extends StatelessWidget {
  const UserNameWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<String?>(
        future: AuthSession.getName(),
        builder: (context, snapshot) {
          return Text(
            snapshot.data ?? 'John Doe',
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          );
        },
      ),
    );
  }
}

class UserEmailWidget extends StatelessWidget {
  const UserEmailWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: FutureBuilder<String?>(
        future: AuthSession.getEmail(),
        builder: (context, snapshot) {
          return Text(
            snapshot.data ?? 'john@example.com',
            style: const TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          );
        },
      ),
    );
  }
}
