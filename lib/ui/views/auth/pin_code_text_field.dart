import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mobile/ui/theme/pin_theme.dart';
import 'package:mobile/ui/utils/cursor_painter.dart';
import 'package:mobile/ui/utils/screen_size_utils.dart';
import 'package:mobile/ui/widgets/inputs/auth/custom_input_field.dart';
import 'package:mobile/ui/widgets/shared/buttons/custom_outlined_button.dart';

class PinCodeTextField extends StatefulWidget {
  final int length;
  final TextInputType keyboardType;
  final TextEditingController controller;

  const PinCodeTextField({
    super.key,
    required this.length,
    required this.controller,
    this.keyboardType = TextInputType.number,
  });

  @override
  PinCodeTextFieldState createState() => PinCodeTextFieldState();
}

class PinCodeTextFieldState extends State<PinCodeTextField>
    with TickerProviderStateMixin {
  TextEditingController? _textEditingController;
  FocusNode? _focusNode;
  late List<String> _inputList;
  int _selectedIndex = 0;
  late AnimationController _cursorController;
  late Animation<double> _cursorAnimation;
  PinTheme get _pinTheme => PinTheme.fromAppTheme(context);
  Timer? _blinkDebounce;
  final _animationDuration = const Duration(milliseconds: 150);
  final _animationCurve = Curves.easeInOut;
  late ValueNotifier<bool> _valueListenable;

  TextStyle? get _textStyle {
    final appTheme = Theme.of(context);

    return appTheme.textTheme.bodyMedium?.copyWith(
      color: appTheme.scaffoldBackgroundColor,
      fontWeight: FontWeight.bold,
    );
  }

  @override
  void initState() {
    _initialize();
    super.initState();
  }

  void _initialize() {
    _valueListenable = ValueNotifier(false);
    _assignController();
    _focusNode = FocusNode();
    _focusNode?.addListener(() {
      _setState(() {});
    });
    _inputList = List<String>.filled(widget.length, "");

    _cursorController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _cursorAnimation = Tween<double>(
      begin: 1,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _cursorController,
      curve: Curves.easeIn,
    ));

    _cursorController.repeat();
  }

  void _assignController() {
    _textEditingController = widget.controller;
    _textEditingController?.addListener(_textEditingControllerListener);
  }

  void _textEditingControllerListener() {
    _debounceBlink();

    var currentText = _textEditingController?.text;
    if (currentText == null) return;

    if (_inputList.join("") != currentText) {
      if (currentText.length >= widget.length) {
        _focusNode?.unfocus();
      }
      _setTextToInput(data: currentText);
    }
  }

  void _debounceBlink() {
    final text = _textEditingController?.text;
    if (text == null) return;

    if (text.length > _inputList.where((x) => x.isNotEmpty).length) {
      if (_blinkDebounce?.isActive ?? false) {
        _blinkDebounce?.cancel();
      }
    }
  }

  @override
  void dispose() {
    _textEditingController?.removeListener(_textEditingControllerListener);
    _textEditingController?.dispose();
    _focusNode?.dispose();
    _cursorController.dispose();
    _valueListenable.dispose();
    super.dispose();
  }

  Color _getColorFromIndex({required int index}) {
    if (((_selectedIndex == index) ||
            (_selectedIndex == index + 1 && index + 1 == widget.length)) &&
        _focusNode?.hasFocus == true) {
      return _pinTheme.selectedColor;
    } else if (_selectedIndex > index) {
      Color relevantActiveColor = _pinTheme.activeColor;
      return relevantActiveColor;
    }

    Color relevantInactiveColor = _pinTheme.inactiveColor;
    return relevantInactiveColor;
  }

  double _getBorderWidthForIndex({required int index}) {
    final isSelectedIndex = (_selectedIndex == index) ||
        (_selectedIndex == index + 1 && index + 1 == widget.length);

    if (isSelectedIndex && _focusNode?.hasFocus == null) {
      return _pinTheme.selectedBorderWidth;
    } else if (_selectedIndex > index) {
      double relevantActiveBorderWidth = _pinTheme.activeBorderWidth;
      return relevantActiveBorderWidth;
    }

    double relevantActiveBorderWidth = _pinTheme.inactiveBorderWidth;
    return relevantActiveBorderWidth;
  }

  List<BoxShadow>? _getBoxShadowFromIndex({required int index}) {
    if (_selectedIndex == index) {
      return _pinTheme.activeBoxShadows;
    } else if (_selectedIndex > index) {
      return _pinTheme.inactiveBoxShadows;
    }

    return null;
  }

  Widget _renderPinField({required int index}) {
    final text = _inputList[index];
    return Text(text, key: ValueKey(_inputList[index]), style: _textStyle);
  }

  Color _getFillColorFromIndex({required int index}) {
    final isSelectedIndex = (_selectedIndex == index) ||
        (_selectedIndex == index + 1 && index + 1 == widget.length);

    if (isSelectedIndex && _focusNode?.hasFocus == true) {
      return _pinTheme.selectedFillColor;
    }
    if (_selectedIndex > index) {
      return _pinTheme.activeFillColor;
    }
    return _pinTheme.inactiveFillColor;
  }

  Widget buildChild(int index) {
    final appTheme = Theme.of(context);
    final isSelectedIndex = (_selectedIndex == index) ||
        (_selectedIndex == index + 1 && index + 1 == widget.length);

    if (isSelectedIndex && _focusNode?.hasFocus == true) {
      final cursorColor = appTheme.scaffoldBackgroundColor;
      final cursorHeight = (_textStyle?.fontSize ?? 0) + 8;
      final leftPadding =
          EdgeInsets.only(left: (_textStyle?.fontSize ?? 0) / 1.5);
      final screen = ScreenSizeUtils(context);

      if (_selectedIndex == index + 1 && index + 1 == widget.length) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Center(
              child: Padding(
                padding: leftPadding,
                child: FadeTransition(
                  opacity: _cursorAnimation,
                  child: CustomPaint(
                    size: Size(0, cursorHeight),
                    painter: CursorPainter(
                      cursorColor: cursorColor,
                      cursorWidth: screen.scaledShortestScreenSide(0.005),
                    ),
                  ),
                ),
              ),
            ),
            _renderPinField(
              index: index,
            ),
          ],
        );
      } else {
        return Center(
          child: FadeTransition(
            opacity: _cursorAnimation,
            child: CustomPaint(
              size: Size(0, cursorHeight),
              painter: CursorPainter(
                cursorColor: cursorColor,
                cursorWidth: screen.scaledShortestScreenSide(0.005),
              ),
            ),
          ),
        );
      }
    }

    return _renderPinField(index: index);
  }

  @override
  Widget build(BuildContext context) {
    final appTheme = Theme.of(context);
    final screen = ScreenSizeUtils(context);

    final textField = CustomTextField(
      controller: _textEditingController,
      keyboardType: widget.keyboardType,
      focusNode: _focusNode,
      autofillHints: const <String>[AutofillHints.oneTimeCode],
      autocorrect: false,
      inputFormatters: [
        LengthLimitingTextInputFormatter(widget.length),
        FilteringTextInputFormatter.digitsOnly,
      ],
      enableInteractiveSelection: false,
      showCursor: false,
      cursorWidth: 0.01,
      decoration: const InputDecoration(
        contentPadding: EdgeInsets.all(0),
        border: InputBorder.none,
        fillColor: Colors.transparent,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        errorBorder: InputBorder.none,
        focusedErrorBorder: InputBorder.none,
      ),
      style: appTheme.textTheme.bodySmall
          ?.copyWith(color: Colors.transparent, height: .01, fontSize: 0.01),
      onChanged: (value) {
        _valueListenable.value = false;
        return null;
      },
    );

    return Column(
      children: [
        ValueListenableBuilder(
          valueListenable: _valueListenable,
          builder: (context, value, child) => SizedBox(
            height: screen.scaledShortestScreenSide(0.1),
            child: value
                ? CustomOutlinedButton(
                    onPressed: () {
                      _valueListenable.value = false;
                      Clipboard.getData('text/plain').then((value) {
                        final text = value?.text;
                        if (text != null) {
                          _textEditingController?.text = text;
                        }
                      });
                    },
                    label: 'Paste',
                  )
                : const SizedBox(),
          ),
        ),
        Stack(
          alignment: Alignment.bottomCenter,
          children: <Widget>[
            AbsorbPointer(
              absorbing: true,
              child: textField,
            ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      _onFocus();
                      _valueListenable.value = false;
                    },
                    onLongPress: () {
                      _valueListenable.value = true;
                      HapticFeedback.vibrate();
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _generateFields(context: context),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  List<Widget> _generateFields({required BuildContext context}) {
    var result = <Widget>[];
    final screen = ScreenSizeUtils(context);

    for (int i = 0; i < widget.length; i++) {
      result.add(
        Container(
          padding: _pinTheme.fieldOuterPadding,
          child: AnimatedContainer(
            curve: _animationCurve,
            duration: _animationDuration,
            width: _pinTheme.fieldWidth,
            height: _pinTheme.fieldHeight,
            decoration: BoxDecoration(
              color: _getFillColorFromIndex(index: i),
              boxShadow: _getBoxShadowFromIndex(index: i),
              shape: BoxShape.rectangle,
              borderRadius:
                  BorderRadius.circular(screen.scaledShortestScreenSide(0.01)),
              border: Border.all(
                color: _getColorFromIndex(index: i),
                width: _getBorderWidthForIndex(index: i),
              ),
            ),
            child: Center(
              child: AnimatedSwitcher(
                switchInCurve: _animationCurve,
                switchOutCurve: _animationCurve,
                duration: _animationDuration,
                transitionBuilder: (child, animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0, .5),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
                child: buildChild(i),
              ),
            ),
          ),
        ),
      );
    }

    return result;
  }

  void _onFocus() {
    if (!_focusNode!.hasFocus || MediaQuery.of(context).viewInsets.bottom > 0) {
      _focusNode?.requestFocus();
    } else {
      _focusNode?.unfocus();
      Future.delayed(
          const Duration(microseconds: 1), () => _focusNode?.requestFocus());
    }
  }

  void _setTextToInput({required String data}) async {
    var replaceInputList = List<String>.filled(widget.length, "");

    for (int i = 0; i < widget.length; i++) {
      replaceInputList[i] = data.length > i ? data[i] : "";
    }

    _setState(() {
      _selectedIndex = data.length;
      _inputList = replaceInputList;
    });
  }

  void _setState(void Function() function) {
    if (mounted) {
      setState(function);
    }
  }
}
