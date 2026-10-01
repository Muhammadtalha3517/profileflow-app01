class HeuristicRules {
  /// Cleans and normalizes text for robust matching
  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  /// Calculates Jaccard / token similarity between two strings
  static double calculateSimilarity(String s1, String s2) {
    final norm1 = normalize(s1);
    final norm2 = normalize(s2);

    if (norm1 == norm2) return 1.0;
    if (norm1.isEmpty || norm2.isEmpty) return 0.0;

    final tokens1 = norm1.split(' ').toSet();
    final tokens2 = norm2.split(' ').toSet();

    final intersection = tokens1.intersection(tokens2).length;
    final union = tokens1.union(tokens2).length;

    if (union == 0) return 0.0;
    return intersection / union;
  }

  /// Checks if input indicates a security barrier or CAPTCHA
  static bool isSecurityBarrier(String text) {
    final norm = normalize(text);
    const securityTerms = [
      'captcha',
      'recaptcha',
      'hcaptcha',
      'verify you are human',
      'bot detection',
      'two factor',
      '2fa',
      'security code',
      'authenticator',
      'otp',
      'one time password',
    ];

    for (final term in securityTerms) {
      if (norm.contains(term)) return true;
    }
    return false;
  }

  /// Checks if an element is a submit or forbidden automated button
  static bool isProhibitedAutomationAction(String tag, String type, String text) {
    final tType = type.toLowerCase();
    final tTag = tag.toUpperCase();
    final tText = normalize(text);

    if (tType == 'submit') return true;
    if (tTag == 'BUTTON' || tType == 'button') {
      const prohibitedKeywords = [
        'submit',
        'apply',
        'send',
        'continue',
        'next',
        'confirm',
        'purchase',
        'pay',
        'payment',
        'verify',
        'place order',
        'checkout',
      ];
      for (final kw in prohibitedKeywords) {
        if (tText == kw || tText.contains(kw)) return true;
      }
    }
    return false;
  }
}
