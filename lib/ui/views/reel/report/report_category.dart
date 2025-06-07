import 'package:equatable/equatable.dart'; // Add equatable if you want comparison

class ReportCategory extends Equatable {
  final String
  key; // Unique identifier for the reason (e.g., 'violence', 'abuse_under_18')
  final String title; // Display title
  final List<ReportCategory>? subcategories;
  final String? detailsText; // The descriptive text shown on the final screen

  const ReportCategory({
    required this.key,
    required this.title,
    this.subcategories,
    this.detailsText,
  });

  bool get hasSubcategories =>
      subcategories != null && subcategories!.isNotEmpty;

  bool get hasDetails => detailsText != null && detailsText!.isNotEmpty;

  @override
  List<Object?> get props => [key, title, subcategories, detailsText];
}

// *** Update the primaryReportCategories list to include keys ***
final List<ReportCategory> primaryReportCategories = [
  ReportCategory(
    key: 'violence_abuse_exploitation', // Example key
    title: 'Violence, abuse, and criminal exploitation',
    subcategories: [
      ReportCategory(
        key: 'exploitation_abuse_under_18', // Example key
        title: 'Exploitation and abuse of people under 18',
        detailsText: // Renamed from 'details'
            'We don\'t allow the following:\n\n• Showing or promoting sexual exploitation of people under 18, including child sexual abuse material (CSAM), grooming, solicitation, and pedophilia\n• Showing or promoting physical abuse, neglect, endangerment, and psychological abuse of people under 18\n• Showing or promoting trafficking of people under 18 and recruitment of child soldiers\n• Promoting or facilitating underage marriage',
      ),
      ReportCategory(
        key: 'physical_violence_threats',
        title: 'Physical violence and violent threats',
        detailsText:
            'We don\'t allow showing or promoting violence, violent threats, or any content that incites or promotes violence.',
      ),
      ReportCategory(
        key: 'sexual_exploitation_abuse',
        title: 'Sexual exploitation and abuse',
        detailsText:
            'We don\'t allow depicting, promoting, or enabling nonconsensual sexual acts.',
      ),
      ReportCategory(
        key: 'human_exploitation',
        title: 'Human exploitation',
        detailsText:
            'We don\'t allow content that depicts, promotes, or enables human trafficking or forced labor.',
      ),
      ReportCategory(
        key: 'animal_abuse',
        title: 'Animal abuse',
        detailsText:
            'We don\'t allow content that depicts or promotes animal cruelty or abuse.',
      ),
      ReportCategory(
        key: 'other_criminal_activities',
        title: 'Other criminal activities',
        detailsText:
            'We don\'t allow content that depicts, promotes, or enables other criminal activities not listed above.',
      ),
    ],
  ),
  ReportCategory(
    key: 'hate_harassment',
    title: 'Hate and harassment',
    detailsText:
        'We don\'t allow hate speech or content that harasses, bullies, or attacks individuals or groups.',
  ),
  ReportCategory(
    key: 'suicide_self_harm',
    title: 'Suicide and self-harm',
    detailsText:
        'We don\'t allow content that promotes, glorifies, or enables suicide or self-harm.',
  ),
  ReportCategory(
    key: 'disordered_eating_unhealthy_body',
    title: 'Disordered eating and unhealthy body image',
    detailsText:
        'We don\'t allow content that promotes or glorifies disordered eating, restrictive dieting, or unhealthy body image.',
  ),
  ReportCategory(
    key: 'dangerous_activities',
    title: 'Dangerous activities and challenges',
    detailsText:
        'We don\'t allow content that promotes or depicts dangerous activities or challenges that could lead to harm.',
  ),
  ReportCategory(
    key: 'nudity_sexual_content',
    title: 'Nudity and sexual content',
    detailsText:
        'We don\'t allow nudity or sexually explicit content, with some exceptions.',
  ),
  ReportCategory(
    key: 'shocking_graphic_content',
    title: 'Shocking and graphic content',
    detailsText:
        'We don\'t allow content that is excessively graphic, shocking, or disturbing.',
  ),
  ReportCategory(
    key: 'misinformation',
    title: 'Misinformation',
    detailsText: 'We don\'t allow misinformation that could cause harm.',
  ),
  ReportCategory(
    key: 'deceptive_behavior_spam',
    title: 'Deceptive behavior and spam',
    detailsText:
        'We don\'t allow content that is deceptive or engages in spamming behavior.',
  ),
  ReportCategory(
    key: 'regulated_goods_activities',
    title: 'Regulated goods and activities',
    detailsText:
        'We don\'t allow content that promotes or facilitates the trade of regulated goods or activities.',
  ),
  ReportCategory(
    key: 'frauds_scams',
    title: 'Frauds and scams',
    detailsText:
        'We don\'t allow content that promotes or facilitates fraudulent activities or scams.',
  ),
];
