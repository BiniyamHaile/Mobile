import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/social/postReport/post_report_bloc.dart';
import 'package:mobile/bloc/social/postReport/post_report_event.dart';
import 'package:mobile/bloc/social/postReport/post_report_state.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/localizations_service.dart';
import 'package:mobile/services/localization/string_extension.dart';
import 'package:mobile/models/report_post.dart';
import 'package:mobile/repository/social/post_report_repository.dart';
import 'package:mobile/ui/routes/route_names.dart';

class ReportPage extends StatefulWidget {
  final String postId;

  const ReportPage({super.key, required this.postId});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late final PostReportBloc _postReportBloc;
  String? selectedCategoryKey;
  String? selectedSubReasonKey;
  final TextEditingController _customReasonController = TextEditingController();

  Map<String, List<String>> _getTranslatedReasons(BuildContext context) {
    return {
      AppStrings.reportCatViolence.tr(context): [
        AppStrings.subAssault.tr(context),
        AppStrings.subThreats.tr(context),
        AppStrings.subAnimalCruelty.tr(context),
      ],
      AppStrings.reportCatHateSpeech.tr(context): [
        AppStrings.subRacist.tr(context),
        AppStrings.subSexist.tr(context),
        AppStrings.subReligious.tr(context),
        AppStrings.subLgbtqTargeted.tr(context),
      ],
      AppStrings.reportCatHarassment.tr(context): [
        AppStrings.subRepeatedInsults.tr(context),
        AppStrings.subNameCalling.tr(context),
        AppStrings.subStalking.tr(context),
      ],
      AppStrings.reportCatNudity.tr(context): [
        AppStrings.subExplicitPhotos.tr(context),
        AppStrings.subSexualLanguage.tr(context),
      ],
      AppStrings.reportCatFalseInfo.tr(context): [
        AppStrings.subMedical.tr(context),
        AppStrings.subPolitical.tr(context),
        AppStrings.subOtherInfo.tr(context),
      ],
      AppStrings.reportCatSpam.tr(context): [
        AppStrings.subClickbait.tr(context),
        AppStrings.subScamLinks.tr(context),
      ],
      AppStrings.reportCatOther.tr(context): [
        AppStrings.specifyReason.tr(context),
      ],
    };
  }

  bool get _isFormValid {
    if (selectedCategoryKey == null) return false;
    if (selectedSubReasonKey == AppStrings.specifyReason.tr(context)) {
      return _customReasonController.text.trim().isNotEmpty;
    }
    return selectedSubReasonKey != null;
  }

  @override
  void initState() {
    super.initState();
    _postReportBloc = PostReportBloc(repository: PostReportRepository());
  }

  @override
  void dispose() {
    _postReportBloc.close();
    _customReasonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    context.watch<LanguageService>();
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reportReasons = _getTranslatedReasons(context);

    return BlocProvider.value(
      value: _postReportBloc,
      child: BlocListener<PostReportBloc, PostReportState>(
        listener: (context, state) {
          if (state is PostReportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  AppStrings.reportSubmittedSuccess.tr(context),
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.go(RouteNames.feed);
          } else if (state is PostReportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message, // Assuming state.message is already localized or an error code
                  style: const TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.grey[100],
          appBar: AppBar(
            title: Text(
              AppStrings.reportPostTitle.tr(context),
              style: const TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(143, 148, 251, 1),
            iconTheme: const IconThemeData(color: Colors.white),
            elevation: 1,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.reportReasonQuestion.tr(context),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ...reportReasons.entries.map((entry) {
                  final isExpanded = selectedCategoryKey == entry.key;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    color: isDark ? Colors.grey[900] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      key: ValueKey(entry.key), // Important for state management
                      tilePadding: const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                      collapsedIconColor: theme.primaryColor,
                      iconColor: theme.primaryColor,
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          selectedCategoryKey = expanded ? entry.key : null;
                          selectedSubReasonKey = null;
                          _customReasonController.clear();
                        });
                      },
                      children: entry.value.map((sub) {
                        final isSelected = selectedSubReasonKey == sub;
                        return ListTile(
                          title: Text(
                            sub,
                            style: TextStyle(
                              color: isSelected
                                  ? theme.primaryColor
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                          selected: isSelected,
                          onTap: () {
                            setState(() {
                              selectedSubReasonKey = sub;
                            });
                          },
                          trailing: Icon(
                            isSelected ? Icons.check_circle : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.green : Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
                if (selectedSubReasonKey == AppStrings.specifyReason.tr(context))
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: TextField(
                      controller: _customReasonController,
                      decoration: InputDecoration(
                        labelText: AppStrings.customReason.tr(context),
                        labelStyle: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        filled: true,
                        fillColor: isDark ? Colors.grey[850] : Colors.white,
                      ),
                      style: TextStyle(
                        color: isDark ? Colors.white : Colors.black87,
                      ),
                      maxLines: 3,
                      onChanged: (text) => setState(() {}),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            final main = selectedCategoryKey!;
                            final sub = selectedSubReasonKey == AppStrings.specifyReason.tr(context)
                                ? _customReasonController.text.trim()
                                : selectedSubReasonKey;

                            final report = PostReport(
                              id: '',
                              content_id: widget.postId,
                              reporterId: null, // Should be populated from auth state
                              mainReason: main,
                              subreason: sub,
                              status: 'pending',
                              resolvedBy: null,
                              reportType: 'post',
                              resolvedAt: null,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );
                            _postReportBloc.add(CreatePostReport(report));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _isFormValid ? theme.primaryColor : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppStrings.submitReport.tr(context),
                      style: TextStyle(
                        fontSize: 16,
                        color: _isFormValid ? Colors.white : Colors.grey[700],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
