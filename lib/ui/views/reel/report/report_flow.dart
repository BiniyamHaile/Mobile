import 'package:flutter/material.dart';
import 'package:mobile/bloc/reel/reel_bloc.dart';
import 'package:mobile/bloc/reel/reel_event.dart';
import 'package:mobile/models/reel/report/report_reason_details_dto.dart';
import 'package:mobile/ui/views/reel/report/report_category.dart';
import 'package:mobile/ui/views/reel/report/report_details_screen.dart';
import 'package:mobile/ui/views/reel/report/report_reason_list_screen.dart';

class ReportFlowModal extends StatefulWidget {
  final String reelId;
  final ReelFeedAndActionBloc bloc;

  const ReportFlowModal({Key? key, required this.reelId, required this.bloc})
      : super(key: key);

  @override
  _ReportFlowModalState createState() => _ReportFlowModalState();
}

class _ReportFlowModalState extends State<ReportFlowModal> {
  List<ReportCategory> _currentCategories = primaryReportCategories;
  ReportCategory? _selectedPrimaryCategory;
  ReportCategory? _selectedSubCategory;
  ReportCategory? _finalCategoryForDetails;

  String get _currentTitle {
    if (_finalCategoryForDetails != null) {
      return _finalCategoryForDetails!.title;
    } else if (_selectedPrimaryCategory != null) {
      return _selectedPrimaryCategory!.title;
    }
    return 'Select a reason';
  }

  void _onCategorySelected(ReportCategory category) {
    print('Selected category: ${category.title}');
    if (category.hasSubcategories) {
      setState(() {
        _selectedPrimaryCategory = category;
        _currentCategories = category.subcategories!;
        _selectedSubCategory = null;
        _finalCategoryForDetails = null;
      });
    } else if (category.hasDetails) {
      setState(() {
        _selectedPrimaryCategory ??= category;
        _selectedSubCategory = category;
        _finalCategoryForDetails = category;
      });
    }
  }

  void _onBack() {
    if (_finalCategoryForDetails != null) {
      setState(() {
        _finalCategoryForDetails = null;
        _selectedSubCategory = null;

        if (_selectedPrimaryCategory != null &&
            _selectedPrimaryCategory!.hasSubcategories) {
          _currentCategories = _selectedPrimaryCategory!.subcategories!;
        } else {
          _currentCategories = primaryReportCategories;
          _selectedPrimaryCategory = null;
        }
      });
    } else if (_selectedPrimaryCategory != null) {
      setState(() {
        _currentCategories = primaryReportCategories;
        _selectedPrimaryCategory = null;
      });
    } else {
      _onClose();
    }
  }

  void _onClose() {
    print('Close pressed.');
    Navigator.pop(context);
  }

  void _onSubmitReport(ReportCategory finalCat, ReportCategory? parentCat) {
    print('Submit Report called in Modal.');
    final reasonDetails = ReportReasonDetailsDto(
      mainReason: parentCat?.key ?? finalCat.key,
      subReason: parentCat != null ? finalCat.key : null,
      details: finalCat.detailsText ?? '',
    );

    print('Dispatching ReportReel event for ${widget.reelId}');
    print(
      'Reason details: Main: ${reasonDetails.mainReason}, Sub: ${reasonDetails.subReason}, Details: ${reasonDetails.details}',
    );

    widget.bloc.add(
      ReportReel(reelId: widget.reelId, reasonDetails: reasonDetails),
    );

    _onClose();
  }

  @override
  Widget build(BuildContext context) {
    final bool showBackButton =
        _selectedPrimaryCategory != null || _finalCategoryForDetails != null;

    if (_finalCategoryForDetails != null) {
      return ReportDetailsScreen(
        title: _currentTitle,
        details: _finalCategoryForDetails!.detailsText!,
        onBack: _onBack,
        onClose: _onClose,
        finalCategory: _finalCategoryForDetails!,
        parentCategory: _selectedPrimaryCategory?.hasSubcategories == true
            ? _selectedPrimaryCategory
            : null,
        reportedEntityId: widget.reelId,
        onSubmit: _onSubmitReport,
      );
    } else {
      return ReportReasonListScreen(
        title: _currentTitle,
        categories: _currentCategories,
        onCategorySelected: _onCategorySelected,
        onBack: showBackButton ? _onBack : null,
        onClose: _onClose,
      );
    }
  }
}

void showReportFlow({
  required BuildContext context,
  required String reelId,
  required ReelFeedAndActionBloc bloc,
}) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      print('Showing ReportFlowModal for Reel ID: $reelId');
      return ReportFlowModal(reelId: reelId, bloc: bloc);
    },
  );
}
