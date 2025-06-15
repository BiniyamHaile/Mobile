import 'dart:io';

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
import 'package:mobile/ui/theme/app_theme.dart';

class ReportPage extends StatefulWidget {
  final String postId;

  const ReportPage({Key? key, required this.postId}) : super(key: key);

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  late final PostReportBloc _postReportBloc;
  String? selectedCategoryKey;
  String? selectedSubReasonKey;
  final TextEditingController _customReasonController =
      TextEditingController();

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

  Map<String, List<String>> _getTranslatedReasons(BuildContext ctx) {
    return {
      AppStrings.reportCatViolence.tr(ctx): [
        AppStrings.subAssault.tr(ctx),
        AppStrings.subThreats.tr(ctx),
        AppStrings.subAnimalCruelty.tr(ctx),
      ],
      AppStrings.reportCatHateSpeech.tr(ctx): [
        AppStrings.subRacist.tr(ctx),
        AppStrings.subSexist.tr(ctx),
        AppStrings.subReligious.tr(ctx),
        AppStrings.subLgbtqTargeted.tr(ctx),
      ],
      AppStrings.reportCatHarassment.tr(ctx): [
        AppStrings.subRepeatedInsults.tr(ctx),
        AppStrings.subNameCalling.tr(ctx),
        AppStrings.subStalking.tr(ctx),
      ],
      AppStrings.reportCatNudity.tr(ctx): [
        AppStrings.subExplicitPhotos.tr(ctx),
        AppStrings.subSexualLanguage.tr(ctx),
      ],
      AppStrings.reportCatFalseInfo.tr(ctx): [
        AppStrings.subMedical.tr(ctx),
        AppStrings.subPolitical.tr(ctx),
        AppStrings.subOtherInfo.tr(ctx),
      ],
      AppStrings.reportCatSpam.tr(ctx): [
        AppStrings.subClickbait.tr(ctx),
        AppStrings.subScamLinks.tr(ctx),
      ],
      AppStrings.reportCatOther.tr(ctx): [
        AppStrings.specifyReason.tr(ctx),
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
  Widget build(BuildContext context) {
    // watch for locale changes
    context.watch<LanguageService>();
    final theme = AppTheme.getTheme(context);
    final isDark = theme.brightness == Brightness.dark;
    final reportReasons = _getTranslatedReasons(context);

    return BlocProvider.value(
      value: _postReportBloc,
      child: BlocListener<PostReportBloc, PostReportState>(
        listener: (ctx, state) {
          if (state is PostReportSuccess) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                backgroundColor: Colors.green,
                content: Text(
                  AppStrings.reportSubmittedSuccess.tr(ctx),
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
            );
            ctx.push(RouteNames.feed);
          } else if (state is PostReportFailure) {
            ScaffoldMessenger.of(ctx).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text(
                  state.message,
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: Colors.white),
                ),
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor:
              isDark ? theme.colorScheme.background : theme.colorScheme.surface,
          appBar: AppBar(
            backgroundColor: theme.colorScheme.primary,
            foregroundColor: theme.colorScheme.onPrimary,
            elevation: 1,
            centerTitle: true,
            title: Text(
              AppStrings.reportPostTitle.tr(context),
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.onPrimary),
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.reportReasonQuestion.tr(context),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: theme.colorScheme.onBackground,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                ...reportReasons.entries.map((entry) {
                  final isExpanded = selectedCategoryKey == entry.key;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    color: isDark
                        ? theme.colorScheme.surfaceVariant
                        : theme.colorScheme.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
                      key: ValueKey(entry.key),
                      tilePadding:
                          const EdgeInsets.symmetric(horizontal: 16),
                      title: Text(
                        entry.key,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onBackground,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      collapsedIconColor: theme.colorScheme.primary,
                      iconColor: theme.colorScheme.primary,
                      initiallyExpanded: isExpanded,
                      onExpansionChanged: (expanded) {
                        setState(() {
                          selectedCategoryKey =
                              expanded ? entry.key : null;
                          selectedSubReasonKey = null;
                          _customReasonController.clear();
                        });
                      },
                      children: entry.value.map((sub) {
                        final isSelected = selectedSubReasonKey == sub;
                        return ListTile(
                          title: Text(
                            sub,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isSelected
                                  ? theme.colorScheme.primary
                                  : theme.colorScheme.onBackground,
                            ),
                          ),
                          selected: isSelected,
                          onTap: () =>
                              setState(() => selectedSubReasonKey = sub),
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onBackground
                                    .withOpacity(0.6),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
                if (selectedSubReasonKey ==
                    AppStrings.specifyReason.tr(context))
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: TextField(
                      controller: _customReasonController,
                      decoration: InputDecoration(
                        labelText: AppStrings.customReason.tr(context),
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onBackground,
                        ),
                        filled: true,
                        fillColor: theme.colorScheme.surfaceVariant,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onBackground,
                      ),
                      maxLines: 3,
                      onChanged: (_) => setState(() {}),
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            final main = selectedCategoryKey!;
                            final sub = selectedSubReasonKey ==
                                    AppStrings.specifyReason.tr(context)
                                ? _customReasonController.text.trim()
                                : selectedSubReasonKey!;

                            final report = PostReport(
                              id: '',
                              content_id: widget.postId,
                              reporterId: null,
                              mainReason: main,
                              subreason: sub,
                              status: 'pending',
                              resolvedBy: null,
                              reportType: 'post',
                              resolvedAt: null,
                              createdAt: DateTime.now(),
                              updatedAt: DateTime.now(),
                            );

                            _postReportBloc
                                .add(CreatePostReport(report));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFormValid
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      AppStrings.submitReport.tr(context),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: _isFormValid
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onBackground
                                .withOpacity(0.6),
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
