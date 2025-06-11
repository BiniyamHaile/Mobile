import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile/bloc/social/postReport/post_report_bloc.dart';
import 'package:mobile/bloc/social/postReport/post_report_event.dart';
import 'package:mobile/bloc/social/postReport/post_report_state.dart';
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
  String? selectedCategory;
  String? selectedSubReason;
  final TextEditingController _customReasonController = TextEditingController();

  final Map<String, List<String>> reportReasons = {
    'Violence or Physical Harm': ['Assault', 'Threats', 'Animal cruelty'],
    'Hate Speech or Symbols': [
      'Racist',
      'Sexist',
      'Religious',
      'LGBTQ+ targeted',
    ],
    'Harassment or Bullying': ['Repeated insults', 'Name calling', 'Stalking'],
    'Nudity or Sexual Content': ['Explicit photos', 'Sexual language'],
    'False Information': ['Medical', 'Political', 'Other'],
    'Spam or Misleading Content': ['Clickbait', 'Scam links'],
    'Other': ['Please specify'],
  };

  bool get _isFormValid {
    if (selectedCategory == null) return false;
    if (selectedSubReason == 'Please specify') {
      return _customReasonController.text.trim().isNotEmpty;
    }
    return selectedSubReason != null;
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
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return BlocProvider.value(
      value: _postReportBloc,
      child: BlocListener<PostReportBloc, PostReportState>(
        listener: (context, state) {
          if (state is PostReportSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Report submitted successfully',
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.green,
              ),
            );
            context.push(RouteNames.feed);
          } else if (state is PostReportFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  state.message,
                  style: TextStyle(color: Colors.white),
                ),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Scaffold(
          backgroundColor: isDark ? Colors.black : Colors.grey[100],
          appBar: AppBar(
            title: const Text(
              'Report Post',
              style: TextStyle(color: Colors.white),
            ),
            centerTitle: true,
            backgroundColor: const Color.fromRGBO(
              143,
              148,
              251,
              1,
            ), // Add this lin
            foregroundColor: isDark ? Colors.white : Colors.black,
            elevation: 1,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Why are you reporting this post?',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),
                ...reportReasons.entries.map((entry) {
                  final isExpanded = selectedCategory == entry.key;
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 8),
                    elevation: 3,
                    color: isDark ? Colors.grey[900] : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ExpansionTile(
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
                          selectedCategory = expanded ? entry.key : null;
                          selectedSubReason = null;
                          _customReasonController.clear();
                        });
                      },
                      children: entry.value.map((sub) {
                        final isSelected = selectedSubReason == sub;
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
                              selectedSubReason = sub;
                            });
                          },
                          trailing: Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.green : Colors.grey,
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
                if (selectedSubReason == 'Please specify')
                  Padding(
                    padding: const EdgeInsets.only(top: 12.0),
                    child: TextField(
                      controller: _customReasonController,
                      decoration: InputDecoration(
                        labelText: 'Custom Reason',
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
                    ),
                  ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isFormValid
                        ? () {
                            final main = selectedCategory!;
                            final sub = selectedSubReason == 'Please specify'
                                ? _customReasonController.text.trim()
                                : selectedSubReason;

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

                            print("report: $report.toJson()");
                            _postReportBloc.add(CreatePostReport(report));
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: _isFormValid
                          ? theme.primaryColor
                          : Colors.grey[400],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Submit Report',
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
