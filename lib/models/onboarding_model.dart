class OnboardingPage {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;
  final String? buttonText;

  const OnboardingPage({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
    this.buttonText,
  });
}

class OnboardingData {
  static const List<OnboardingPage> pages = [
    OnboardingPage(
      title: 'Track Your Daily',
      subtitle: 'Expenses',
      description: 'Keep track of your spending habits with our simple and intuitive expense tracker',
      imagePath: 'assets/images/onboard1.png',
      buttonText: 'Next',
    ),
    OnboardingPage(
      title: 'Smart',
      subtitle: 'Analytics',
      description: 'Get insights into your spending patterns with beautiful charts and detailed reports',
      imagePath: 'assets/images/onboard2.png',
      buttonText: 'Next',
    ),
    OnboardingPage(
      title: 'Financial',
      subtitle: 'Freedom',
      description: 'Take control of your finances and achieve your savings goals with ease',
      imagePath: 'assets/images/onboard3.png',
      buttonText: 'Get Started',
    ),
  ];
}
