import 'package:flutter/material.dart';
import 'package:mobile/ui/views/reel/report/report_category.dart';
import 'package:mobile/ui/views/reel/report/report_sheet_wrapper.dart';

class ReportReasonListScreen extends StatelessWidget {
  final String title; 
  final List<ReportCategory> categories;
  final Function(ReportCategory) onCategorySelected;
  final VoidCallback? onBack;
  final VoidCallback onClose;

  const ReportReasonListScreen({
    Key? key,
    required this.title, 
    required this.categories,
    required this.onCategorySelected,
    this.onBack,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReportSheetWrapper(
      title: title, 
      onBack: onBack,
      onClose: onClose,
      content: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: categories.length,
        separatorBuilder:
            (context, index) =>
                const Divider(height: 0.5, indent: 0, endIndent: 0),
        itemBuilder: (context, index) {
          final category = categories[index];
          return InkWell(
            onTap: () {
              onCategorySelected(category);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      category.title,
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                  if (category.hasSubcategories)
                    const Icon(Icons.chevron_right, color: Colors.black54),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}