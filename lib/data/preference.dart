import 'package:mobile/bloc/auth/preference/preference_bloc.dart';

final List<PreferenceCategory> mockPreferenceCategories = [
  PreferenceCategory(
    id: 'entertainment',
    name: 'Entertainment',

    options: [
      PreferenceOption(
        id: 'entertainment_funny_comedy',
        name: 'Funny/Comedy',
        selected: false,
      ),
      PreferenceOption(
        id: 'entertainment_music',
        name: 'Music',
        selected: false,
      ),
      PreferenceOption(
        id: 'entertainment_dance',
        name: 'Dance',
        selected: false,
      ),
      PreferenceOption(
        id: 'entertainment_gaming',
        name: 'Gaming',
        selected: false,
      ),
      PreferenceOption(
        id: 'entertainment_animation',
        name: 'Animation',
        selected: false,
      ),
      PreferenceOption(
        id: 'entertainment_drama',
        name: 'Drama',
        selected: false,
      ),
      PreferenceOption(
        id: 'entertainment_aesthetic',
        name: 'Aesthetic',
        selected: false,
      ), 
      PreferenceOption(
        id: 'entertainment_diy_life_hacks',
        name: 'DIY/Life Hacks',
        selected: false,
      ),
      PreferenceOption(
        id: 'entertainment_fashion',
        name: 'Fashion',
        selected: false,
      ),
      PreferenceOption(
        id: 'entertainment_beauty',
        name: 'Beauty',
        selected: false,
      ), 
      PreferenceOption(
        id: 'entertainment_pranks',
        name: 'Pranks',
        selected: false,
      ), 
      PreferenceOption(
        id: 'entertainment_challenges',
        name: 'Challenges',
        selected: false,
      ),
    ],
  ),

  PreferenceCategory(
    id: 'informational_educational',
    name: 'Informational/Educational',
    options: [
      PreferenceOption(
        id: 'info_edu_educational',
        name: 'Educational',
        selected: false,
      ), 
      PreferenceOption(
        id: 'info_edu_documentary',
        name: 'Documentary',
        selected: false,
      ),
      PreferenceOption(
        id: 'info_edu_news',
        name: 'News',
        selected: false,
      ), 
      PreferenceOption(
        id: 'info_edu_science_tech',
        name: 'Science/Tech',
        selected: false,
      ),
      PreferenceOption(
        id: 'info_edu_health_wellness',
        name: 'Health/Wellness',
        selected: false,
      ),
      PreferenceOption(
        id: 'info_edu_travel',
        name: 'Travel',
        selected: false,
      ), 
      PreferenceOption(
        id: 'info_edu_cooking_food',
        name: 'Cooking/Food',
        selected: false,
      ),
      PreferenceOption(
        id: 'info_edu_business_finance',
        name: 'Business/Finance',
        selected: false,
      ), 
      PreferenceOption(
        id: 'info_edu_history',
        name: 'History',
        selected: false,
      ),
      PreferenceOption(
        id: 'info_edu_language_learning',
        name: 'Language Learning',
        selected: false,
      ), 
    ],
  ),

  PreferenceCategory(
    id: 'social_cultural_political',
    name: 'Social/Cultural/Political',
    options: [
      PreferenceOption(
        id: 'soc_cul_pol_political',
        name: 'Political',
        selected: false,
      ),
      PreferenceOption(
        id: 'soc_cul_pol_social_issues',
        name: 'Social Issues',
        selected: false,
      ),
      PreferenceOption(
        id: 'soc_cul_pol_ethnic_cultural',
        name: 'Ethnic/Cultural',
        selected: false,
      ),
      PreferenceOption(
        id: 'soc_cul_pol_religious_spiritual',
        name: 'Religious/Spiritual',
        selected: false,
      ),
      PreferenceOption(
        id: 'soc_cul_pol_personal_stories',
        name: 'Personal Stories',
        selected: false,
      ),
      PreferenceOption(
        id: 'soc_cul_pol_activism',
        name: 'Activism',
        selected: false,
      ),
    ],
  ),

  PreferenceCategory(
    id: 'commercial',
    name: 'Commercial',
    options: [
      PreferenceOption(
        id: 'commercial_advertisement',
        name: 'Advertisement',
        selected: false,
      ),
      PreferenceOption(
        id: 'commercial_product_reviews',
        name: 'Product Reviews',
        selected: false,
      ), 
      PreferenceOption(
        id: 'commercial_influencer_marketing',
        name: 'Influencer Marketing',
        selected: false,
      ),
    ],
  ),

  PreferenceCategory(
    id: 'other',
    name: 'Other',
    options: [
      PreferenceOption(
        id: 'other_animals_pets',
        name: 'Animals/Pets',
        selected: false,
      ), 
      PreferenceOption(id: 'other_sports', name: 'Sports', selected: false),
      PreferenceOption(
        id: 'other_asmr',
        name: 'ASMR',
        selected: false,
      ), 
      PreferenceOption(
        id: 'other_art',
        name: 'Art',
        selected: false,
      ), 
      PreferenceOption(id: 'other_family', name: 'Family', selected: false),
      PreferenceOption(
        id: 'other_motors',
        name: 'Motors',
        selected: false,
      ),
      PreferenceOption(
        id: 'other_misc',
        name: 'Other (Misc)',
        selected: false,
      ),
    ],
  ),
];
