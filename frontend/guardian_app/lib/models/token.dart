// frontend/guardian_app/lib/models/token.dart

class Token {
  final String accessToken;
  final String tokenType;

  Token({required this.accessToken, required this.tokenType});

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      accessToken: json['access_token'],
      tokenType: json['token_type'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'token_type': tokenType,
    };
  }
}
