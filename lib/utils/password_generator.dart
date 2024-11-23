import 'dart:math';

class PasswordGenerator {
  static String generatePassword(String name, String email) {
    // Get first 3 characters of name (or less if name is shorter)
    String namePrefix = name.replaceAll(' ', '').toLowerCase();
    namePrefix = namePrefix.length > 3 ? namePrefix.substring(0, 3) : namePrefix;
    
    // Get first 2 characters of email domain
    String emailDomain = email.split('@')[1];
    String domainPrefix = emailDomain.length > 2 ? emailDomain.substring(0, 2) : emailDomain;
    
    // Generate 3 random numbers
    String numbers = (Random().nextInt(900) + 100).toString();
    
    // Generate 2 random special characters
    const specialChars = '!@#\$%^&*';
    final random = Random();
    String special = specialChars[random.nextInt(specialChars.length)];
    
    // Combine all parts
    return '$namePrefix$numbers$domainPrefix$special';
  }
}
