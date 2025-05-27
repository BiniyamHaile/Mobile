import 'package:flutter/material.dart';
import 'package:mobile/ui/views/reel/report/report_category.dart';
import 'package:mobile/ui/views/reel/report/report_sheet_wrapper.dart';


class ReportDetailsScreen extends StatelessWidget {
  final String title; 
  final String details;
  final VoidCallback onBack;
  final VoidCallback onClose;

  final ReportCategory finalCategory; 
  final ReportCategory? parentCategory; 
  final String reportedEntityId; 
  final void Function(ReportCategory finalCat, ReportCategory? parentCat)
      onSubmit; 

  const ReportDetailsScreen({
    Key? key,
    required this.title,
    required this.details,
    required this.onBack,
    required this.onClose,
    required this.finalCategory,
    this.parentCategory, 
    required this.reportedEntityId,
    required this.onSubmit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ReportSheetWrapper(
      title: title, 
      onBack: onBack,
      onClose: onClose,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            details, 
            style: const TextStyle(fontSize: 15, color: Colors.black87),
          ),
          // const SizedBox(height: 16),
          // TextField(
          //   decoration: InputDecoration(
          //     labelText: 'Add more details (optional)',
          //     border: OutlineInputBorder(),
          //   ),
          //   maxLines: 3,
          // ),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () {
                print('Report Submitted for: ${finalCategory.title}');
                onSubmit(finalCategory, parentCategory);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.pinkAccent,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
              child: const Text(
                'Submit Report', 
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }
}