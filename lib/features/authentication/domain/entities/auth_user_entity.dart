import 'package:equatable/equatable.dart';

class AuthUserEntity extends Equatable {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const AuthUserEntity({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  String get initials {
    final trimmedName = name.trim();

    if (trimmedName.isEmpty) {
      return email.isEmpty ? 'U' : email[0].toUpperCase();
    }

    final words =
        trimmedName
            .split(RegExp(r'\s+'))
            .where((word) => word.isNotEmpty)
            .toList();

    if (words.length == 1) {
      return words.first[0].toUpperCase();
    }

    return '${words.first[0]}${words.last[0]}'.toUpperCase();
  }

  @override
  List<Object?> get props => [id, name, email, photoUrl];
}
