import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/auth/preference/preference_bloc.dart';
import 'package:mobile/ui/routes/route_names.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/localizations_service.dart';
import 'package:provider/provider.dart';

class PreferencesPage extends StatelessWidget {
  const PreferencesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final languageService = Provider.of<LanguageService>(context);

    return BlocProvider(
      create: (context) => PreferenceBloc()..add(LoadPreferences()),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromRGBO(143, 148, 251, 1),
          title: Text(
            languageService.translate(AppStrings.contentPreferences),
            style: const TextStyle(color: Colors.black),
          ),
          centerTitle: true,
          elevation: 0,
          foregroundColor: Colors.black,
           leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            context.go(RouteNames.profileSetting);
          },
        ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: BlocConsumer<PreferenceBloc, PreferenceState>(
              listener: (context, state) {
                if (state is PreferencesError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.error ,  style: TextStyle(color: Colors.white)),
                      backgroundColor: Colors.red,
                    ),
                  );
                } else if (state is PreferencesSubmitted) {
                  // Show success message
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Profile updated successfully!',
                        style: TextStyle(color: Colors.white),
                      ),
                      backgroundColor: Colors.green,
                    ),
                  );

                  // Navigate to home page after successful submission
                  context.go(RouteNames.feed);
                }
              },
              builder: (context, state) {
                if (state is PreferencesLoading || state is PreferenceInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is PreferencesError &&
                    state.categories == null) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text('Failed to load preferences'),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<PreferenceBloc>().add(
                            LoadPreferences(),
                          ),
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is PreferencesLoaded ||
                    state is PreferencesSubmitting ||
                    state is PreferencesError && state.categories != null) {
                  final categories = (state is PreferencesLoaded)
                      ? state.categories
                      : (state is PreferencesSubmitting)
                      ? state.categories
                      : (state as PreferencesError).categories!;

                  final isSubmitting = state is PreferencesSubmitting;

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        languageService.translate(AppStrings.selectPreferences),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageService.translate(AppStrings.selectTopics),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        languageService.translate(AppStrings.personalizeExperience),
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...categories
                          .map(
                            (category) =>
                                _buildCategorySection(context, category),
                          )
                          .toList(),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: isSubmitting
                              ? null
                              : () => context.read<PreferenceBloc>().add(
                                  SubmitPreferences(),
                                ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: isSubmitting
                              ? const CircularProgressIndicator(
                                  color: Colors.white,
                                )
                              : Text(
                                  languageService.translate(AppStrings.continueText),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  );
                } else {
                  return const Center(child: Text('Unknown state'));
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategorySection(
    BuildContext context,
    PreferenceCategory category,
  ) {
    final languageService = Provider.of<LanguageService>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          category.name,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: category.options.map((option) {
            return FilterChip(
              selected: option.selected,
              onSelected: (selected) {
                context.read<PreferenceBloc>().add(
                  TogglePreference(
                    categoryId: category.id,
                    optionId: option.id,
                  ),
                );
              },
              label: Text(option.name),
              selectedColor: Colors.deepPurple.withOpacity(0.2),
              checkmarkColor: Colors.deepPurple,
              labelStyle: TextStyle(
                color: option.selected ? Colors.deepPurple : Colors.black,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
                side: BorderSide(
                  color: option.selected
                      ? Colors.deepPurple
                      : Colors.grey.shade300,
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
