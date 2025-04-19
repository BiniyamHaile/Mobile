
import 'package:flutter/material.dart';
import 'package:mobile/ui/widgets/shared/buttons/main_app_button.dart';
import 'package:mobile/ui/widgets/shared/helpers/custom_spacer.dart';

class FormWrapper extends StatefulWidget {
  final List<Widget> inputFields;
  final void Function() onSubmit;
  final String submitTitle;
  final double bottomGap;
  final bool loading;
  final GlobalKey<FormState>? formKey;
  final void Function()? onPrevalidation;

  const FormWrapper({
    super.key,
    required this.inputFields,
    required this.onSubmit,
    required this.submitTitle,
    this.bottomGap = 0,
    this.loading = false,
    this.formKey,
    this.onPrevalidation,
  });

  @override
  State<FormWrapper> createState() => _FormWrapperState();
}

class _FormWrapperState extends State<FormWrapper> {
  late GlobalKey<FormState> _formKey;

  @override
  void initState() {
    _formKey = widget.formKey ?? GlobalKey<FormState>();
    super.initState();
  }

  void _submit() {
    final onPrevalidation = widget.onPrevalidation;
    if (onPrevalidation != null) {
      onPrevalidation();
    }
    if (_formKey.currentState?.validate() == true) {
      widget.onSubmit();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.disabled,
      child: Column(
        children: [
          ...widget.inputFields,
          CustomSpacer(height: widget.bottomGap),
          MainAppButton(
              text: widget.submitTitle,
              onPressed: _submit,
              loading: widget.loading),
        ],
      ),
    );
  }
}
