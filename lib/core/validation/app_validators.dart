class AppValidators {
  AppValidators._();

  static String? requiredField(
    String? value, {
    String fieldName = 'This field',
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required.';
    }

    return null;
  }

  static String? name(String? value) {
    final requiredError = requiredField(value, fieldName: 'Name');

    if (requiredError != null) {
      return requiredError;
    }

    final normalizedName = value!.trim();

    if (normalizedName.length < 2) {
      return 'Name must contain at least 2 characters.';
    }

    if (normalizedName.length > 50) {
      return 'Name must not exceed 50 characters.';
    }

    return null;
  }

  static String? email(String? value) {
    final requiredError = requiredField(value, fieldName: 'Email');

    if (requiredError != null) {
      return requiredError;
    }

    final normalizedEmail = value!.trim();

    final emailPattern = RegExp(
      r'^[A-Za-z0-9.!#$%&'
      '*+/=?^_`{|}~-]+'
      r'@[A-Za-z0-9-]+'
      r'(?:\.[A-Za-z0-9-]+)+$',
    );

    if (!emailPattern.hasMatch(normalizedEmail)) {
      return 'Please enter a valid email address.';
    }

    return null;
  }

  static String? password(String? value) {
    final requiredError = requiredField(value, fieldName: 'Password');

    if (requiredError != null) {
      return requiredError;
    }

    if (value!.length < 6) {
      return 'Password must contain at least 6 characters.';
    }

    if (value.length > 128) {
      return 'Password must not exceed 128 characters.';
    }

    return null;
  }

  static String? strongPassword(String? value) {
    final passwordError = password(value);

    if (passwordError != null) {
      return passwordError;
    }

    final hasUppercase = RegExp(r'[A-Z]').hasMatch(value!);
    final hasLowercase = RegExp(r'[a-z]').hasMatch(value);
    final hasNumber = RegExp(r'[0-9]').hasMatch(value);

    if (!hasUppercase || !hasLowercase || !hasNumber) {
      return 'Use uppercase, lowercase, and at least one number.';
    }

    return null;
  }

  static String? confirmPassword({
    required String? value,
    required String password,
  }) {
    final requiredError = requiredField(value, fieldName: 'Confirm password');

    if (requiredError != null) {
      return requiredError;
    }

    if (value != password) {
      return 'Passwords do not match.';
    }

    return null;
  }
}
