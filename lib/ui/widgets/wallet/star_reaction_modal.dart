import 'dart:async'; // For Timer

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For input formatters
import 'package:intl/intl.dart'; // For number formatting
import 'package:mobile/services/Wallet_service/wallet_service.dart';
// Import the service
import 'package:provider/provider.dart'; // Import Provider
import 'package:reown_appkit/modal/models/public/appkit_modal_events.dart';
import 'package:url_launcher/url_launcher.dart'; // For opening ToS link
import 'package:web3dart/web3dart.dart'; // Needed for EthereumAddress in validation

// Custom Modal Widget
class StarReactionModal extends StatefulWidget {
  final String recipientName;
  // The recipient's blockchain address. This is UI-specific data for this gift action,
  // not general wallet state, so it stays as a required parameter.
  final String recipientAddress;

  // Remove wallet-related parameters - these are now accessed via WalletService
  // final BigInt currentStarsBalanceWei;
  // final int starsTokenDecimals;
  // final String starsTokenSymbol;
  // Removed onSendStars and onClose callbacks. The modal now returns the amount via pop.

  const StarReactionModal({
    Key? key,
    required this.recipientName,
    required this.recipientAddress,
    // No required wallet parameters needed now
  }) : super(key: key);

  @override
  _StarReactionModalState createState() => _StarReactionModalState();
}

class _StarReactionModalState extends State<StarReactionModal> {
  int _selectedStarsAmount = 1; // Default selected amount in whole stars
  bool _showInTopSenders = true; // Default checkbox state

  late int _maxStarsAmount; // Maximum amount the user can send (in whole stars)

  // State for manual input
  bool _isEditingAmount = false;
  late TextEditingController _amountTextController;
  late FocusNode _amountFocusNode;

  // Timer to handle delayed exit from editing mode on focus loss
  Timer? _focusLostTimer;

  // Access the WalletService instance using `late`
  late WalletService _walletService;

  @override
  void initState() {
    super.initState();

    // Get the WalletService instance using listen: false.
    // We do this in initState to get the service *instance*
    // and use its initial state to set up local state like _maxStarsAmount.
    // We use listen: false because we don't want *this initState* method
    // to rerun every time the WalletService state changes.
    _walletService = Provider.of<WalletService>(context, listen: false);

    // Convert BigInt balance in Wei to human-readable whole stars (integer part)
    // Use WalletService's state and helper method
    _maxStarsAmount = _walletService.weiToStarsInt(
      _walletService.currentStarsBalanceWei,
      _walletService.starsTokenDecimals,
    );

    // Set initial selected amount
    if (_maxStarsAmount < 1) {
      _selectedStarsAmount =
          0; // Cannot send if balance is less than 1 whole star
    } else {
      // Initialize to a reasonable default, like 10, or _maxStarsAmount if smaller
      _selectedStarsAmount = _maxStarsAmount >= 10 ? 10 : _maxStarsAmount;
      // Ensure it's clamped to at least 1 if max is >= 1
      if (_selectedStarsAmount < 1) {
        _selectedStarsAmount = 1;
      }
    }

    // Initialize controllers and focus node
    _amountTextController = TextEditingController(
      text: _selectedStarsAmount.toString(),
    );
    _amountFocusNode = FocusNode();

    // Add listener to focus node to exit editing mode when focus is lost
    // Use a timer to avoid immediate exit if focus briefly shifts (e.g., tapping on a button)
    _amountFocusNode.addListener(() {
      if (!_amountFocusNode.hasFocus) {
        // Start a timer. If focus returns before the timer fires, cancel it.
        _focusLostTimer = Timer(const Duration(milliseconds: 200), () {
          if (mounted && !_amountFocusNode.hasFocus) {
            // Double check focus state
            _exitEditingMode();
          }
        });
      } else {
        // If focus is gained, cancel any pending exit timer
        _focusLostTimer?.cancel();
      }
    });
  }

  @override
  void didUpdateWidget(covariant StarReactionModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Although we are using Provider, if any *widget parameters* were still being passed
    // that affected _maxStarsAmount (like recipient address might if logic changed),
    // this method would be the place to recalculate _maxStarsAmount based on new widget values.
    // In this refactor, _maxStarsAmount depends solely on wallet state,
    // so this block isn't strictly necessary for *this* specific state variable,
    // but it's a standard pattern if widget parameters influenced local state.
    // The current approach where _maxStarsAmount is recalculated in build based on watched service state is simpler.
  }

  @override
  void dispose() {
    _focusLostTimer?.cancel(); // Cancel timer on dispose
    _amountTextController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  // Remove this helper function, use the one in WalletService instead
  // int _weiToStarsInt(BigInt weiAmount, int decimals) { ... }

  // Helper to format a number with commas (Can stay here)
  String _formatNumber(int number) {
    // Only format if number is non-negative
    if (number < 0) return number.toString();
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // --- Manual Input Logic ---
  // (These methods use the _walletService instance obtained in initState or the watched instance in build)

  void _enterEditingMode() {
    // Access the WalletService instance (could use context.read here too)
    final walletService = Provider.of<WalletService>(context, listen: false);

    // Only allow editing if interactions are enabled and maxStarsAmount is at least 1
    final bool enableInteractions = walletService.isConnected &&
        walletService.connectedNetwork?.chainId ==
            walletService.sepoliaChainId &&
        walletService.areContractsLoaded;

    if (!enableInteractions || _maxStarsAmount < 1) return;

    // Cancel any pending exit timer
    _focusLostTimer?.cancel();

    setState(() {
      _isEditingAmount = true;
      // Ensure controller text matches the current selected amount before editing
      _amountTextController.text = _selectedStarsAmount.toString();
      // Select the text for easy replacement by the user
      _amountTextController.selection = TextSelection(
        baseOffset: 0,
        extentOffset: _amountTextController.text.length,
      );
    });
    // Request focus after the UI has rebuilt and the TextField is visible
    // Use a small delay to ensure the TextField is ready
    Future.delayed(const Duration(milliseconds: 50), () {
      if (mounted) {
        // Check if widget is still mounted
        _amountFocusNode.requestFocus();
      }
    });
  }

  void _exitEditingMode() {
    // Cancel any pending exit timer just in case
    _focusLostTimer?.cancel();

    // If not currently editing, do nothing
    if (!_isEditingAmount) return;

    // Parse the text field content
    final String text = _amountTextController.text.trim();
    final int? parsedAmount = int.tryParse(text);

    setState(() {
      if (parsedAmount != null) {
        // Clamp the parsed amount to the valid range [1, _maxStarsAmount] if _maxStarsAmount >= 1
        // If _maxStarsAmount is 0, the allowed range is [0, 0].
        _selectedStarsAmount = (_maxStarsAmount >= 1)
            ? parsedAmount.clamp(1, _maxStarsAmount)
            : parsedAmount.clamp(0, 0); // If max is 0, clamp to 0
      } else {
        // If parsing failed, revert to the minimum allowed if balance > 0, otherwise 0
        _selectedStarsAmount = (_maxStarsAmount >= 1) ? 1 : 0;
      }
      _isEditingAmount = false;
      // Ensure controller text reflects the final selected amount
      _amountTextController.text = _selectedStarsAmount.toString();
    });
    // Hide the keyboard
    _amountFocusNode.unfocus();
  }

  void _handleAmountTextChange(String text) {
    // Attempt to parse the text as an integer
    final int? parsedAmount = int.tryParse(text);

    setState(() {
      if (parsedAmount != null) {
        // Update selected amount, clamping to valid range [0, _maxStarsAmount]
        // We allow 0 temporarily during input (e.g., when deleting numbers),
        // but the Send button will be disabled if it's 0 or less than 1.
        _selectedStarsAmount = parsedAmount.clamp(0, _maxStarsAmount);
      } else {
        // If text is empty or invalid during typing, default selected amount to 0
        // This will disable the Send button until a valid number >= 1 is entered.
        _selectedStarsAmount = 0;
      }
      // Note: _amountTextController.text is already updated by the TextField itself
      // We only update _selectedStarsAmount which drives the Slider and the button text.
    });
  }

  // --- Send Button Logic ---
  // Modified to pop the modal with the selected amount
  void _handleSendStars() {
    // Access the WalletService instance
    final walletService = Provider.of<WalletService>(context, listen: false);

    // Perform final validation based on the *final* _selectedStarsAmount
    if (_selectedStarsAmount < 1 || _selectedStarsAmount > _maxStarsAmount) {
      // This should be prevented by button state/UI validation, but a final check is safe
      print(
        "Validation failed before sending: Amount $_selectedStarsAmount is invalid. Max available is $_maxStarsAmount.",
      );
      // Use service's AppKitModal to broadcast error
      walletService.appKitModal.onModalError.broadcast(
        ModalError("Invalid amount selected for gift."),
      );
      return;
    }

    // Basic check for valid recipient address string before popping
    try {
      // EthereumAddress is needed here for validation, import web3dart if necessary
      EthereumAddress.fromHex(widget.recipientAddress, enforceEip55: true);
    } catch (e) {
      print("Invalid recipient address string: ${widget.recipientAddress}");
      // Use service's AppKitModal to broadcast error
      walletService.appKitModal.onModalError.broadcast(
        ModalError("Invalid recipient address provided."),
      );
      return;
    }

    if (mounted) {
      // Pop the modal and return the selected amount (integer) to the caller.
      // The caller (MyHomePage) will then get the recipientAddress from the widget
      // and call walletService.sendGiftStars.
      Navigator.pop(context, _selectedStarsAmount);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Watch the WalletService state to rebuild the UI when wallet data changes.
    // This is necessary to update the max available balance, token symbol,
    // and button/slider enable states.
    final walletService = context.watch<WalletService>();

    // Update maxStarsAmount whenever the user's balance changes in the service
    _maxStarsAmount = walletService.weiToStarsInt(
      walletService.currentStarsBalanceWei,
      walletService.starsTokenDecimals,
    );

    // Determine if interactions are generally enabled (connected to Sepolia, contracts loaded)
    final bool enableInteractions = walletService.isConnected &&
        walletService.connectedNetwork?.chainId ==
            walletService.sepoliaChainId &&
        walletService.areContractsLoaded;

    // Determine slider properties based on _maxStarsAmount
    final int sliderMin = (_maxStarsAmount >= 1) ? 1 : 0;
    final int sliderMax = _maxStarsAmount;
    // Divisions = number of steps. If max=5, min=1, divisions=4. If max=0, min=0, divisions=1 (0 to 0)
    final int sliderDivisions =
        sliderMax > sliderMin ? sliderMax - sliderMin : 1;

    // Ensure selected amount is within the valid range for the slider value
    double sliderValue = _selectedStarsAmount.toDouble();
    if (_maxStarsAmount >= 1) {
      // Clamp slider value between 1.0 and max if max is >= 1
      sliderValue = sliderValue.clamp(1.0, _maxStarsAmount.toDouble());
    } else {
      // If max is 0, slider is disabled and value should be 0
      sliderValue = 0.0;
    }

    // Determine if the Send button should be enabled
    // Enabled if interactions are enabled, selected amount is >= 1 and <= max available, AND not currently editing
    final bool isSendButtonEnabled =
        enableInteractions && // Must be connected & contracts loaded
            _selectedStarsAmount >= 1 && // Amount must be at least 1
            _selectedStarsAmount <=
                _maxStarsAmount && // Amount must be <= max available
            !_isEditingAmount; // Disable button while actively editing

    // Get current view padding (especially bottom for keyboard)
    final mediaQuery = MediaQuery.of(context);
    final keyboardPadding = mediaQuery.viewInsets.bottom;

    return Padding(
      // Add bottom padding equal to keyboard height when keyboard is visible
      padding: EdgeInsets.only(bottom: keyboardPadding),
      // Wrap the entire content in a GestureDetector to dismiss keyboard/editing on tap outside
      child: GestureDetector(
        // Use HitTestBehavior.opaque to make the entire area detectable for taps
        // onTapDown is used to ensure the gesture is handled before potential button taps
        onTapDown: (details) {
          // Only exit editing if we are currently editing
          if (_isEditingAmount) {
            _exitEditingMode();
          }
        },
        // Set behavior to opaque so taps outside children hit this detector
        behavior: HitTestBehavior.opaque,
        child: Container(
          // Use padding for overall layout
          padding: const EdgeInsets.all(24.0),
          decoration: const BoxDecoration(
            color: Color(0xFF1E293B), // Dark background color
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
          ),
          child: SingleChildScrollView(
            // Wrap content in SingleChildScrollView
            // Use NeverScrollableScrollPhysics unless keyboard is up or content overflows
            physics: (_maxStarsAmount > 0 ||
                    keyboardPadding > 0 ||
                    _isEditingAmount) // Allow scroll if balance > 0, keyboard is up, or editing
                ? AlwaysScrollableScrollPhysics()
                : NeverScrollableScrollPhysics(),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Wrap content vertically
              crossAxisAlignment:
                  CrossAxisAlignment.stretch, // Stretch elements horizontally
              children: [
                // Header Row (Title and Close button)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Icon and Title
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Placeholder for the Eagle Icon (replace with actual asset if needed)
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.white, // Example background
                          child: Icon(
                            Icons.star,
                            color: Colors.amber,
                          ), // Placeholder icon
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Star Reaction',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    // Close Button
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.white),
                      onPressed: () => Navigator.pop(
                        context,
                        null,
                      ), // Pop and return null on close
                    ),
                  ],
                ),
                SizedBox(height: 30), // Spacer
                // Amount Indicator Bubble (Switch between Display and TextField)
                Center(
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.amber[600], // Yellow/Orange color
                      borderRadius: BorderRadius.circular(
                        20,
                      ), // Rounded corners
                    ),
                    child: _isEditingAmount
                        ? IntrinsicWidth(
                            // Make TextField only as wide as its content
                            child: TextField(
                              controller: _amountTextController,
                              focusNode: _amountFocusNode,
                              keyboardType: TextInputType.numberWithOptions(
                                decimal: false,
                              ), // Only integer input
                              inputFormatters: [
                                FilteringTextInputFormatter
                                    .digitsOnly, // Only allow digits
                              ],
                              textAlign: TextAlign.center, // Center the text
                              style: TextStyle(
                                // Style to match the Text widget
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                decoration: TextDecoration
                                    .none, // Remove default underline
                              ),
                              decoration: InputDecoration(
                                // Remove default TextField decoration
                                isDense: true, // Compact padding
                                contentPadding:
                                    EdgeInsets.zero, // Remove internal padding
                                border: InputBorder.none, // Remove border
                                focusedBorder: InputBorder
                                    .none, // Remove border when focused
                                enabledBorder: InputBorder
                                    .none, // Remove border when enabled
                                errorBorder: InputBorder.none,
                                disabledBorder: InputBorder.none,
                                focusedErrorBorder: InputBorder.none,
                              ),
                              onChanged:
                                  _handleAmountTextChange, // Handle input change
                              onSubmitted: (_) =>
                                  _exitEditingMode(), // Exit editing on submit
                            ),
                          )
                        : GestureDetector(
                            // Only allow tap to enter editing if interactions are enabled and balance >= 1
                            onTap: (enableInteractions && _maxStarsAmount >= 1)
                                ? _enterEditingMode
                                : null, // Disable tap if not enabled or insufficient balance
                            child: Row(
                              mainAxisSize:
                                  MainAxisSize.min, // Wrap content horizontally
                              children: [
                                Icon(
                                  Icons.star,
                                  color: Colors.white,
                                  size: 18,
                                ), // Star icon
                                SizedBox(width: 6),
                                Text(
                                  _formatNumber(
                                    _selectedStarsAmount,
                                  ), // Formatted amount
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 20), // Spacer
                // Slider
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        activeTrackColor:
                            Colors.amber[600], // Active track color
                        inactiveTrackColor: Colors.white.withOpacity(
                          0.3,
                        ), // Inactive track color
                        thumbColor: Colors.white, // Thumb color
                        overlayColor: Colors.amber[600]?.withOpacity(
                          0.2,
                        ), // Overlay color on hover/press
                        thumbShape: RoundSliderThumbShape(
                          enabledThumbRadius: 12.0,
                        ), // Thumb size
                        trackHeight: 8.0, // Make track thicker to match image
                        // You can customize overlay shape, tick marks, etc. here
                      ),
                      child: Slider(
                        value: sliderValue, // Use the clamped sliderValue
                        min: sliderMin
                            .toDouble(), // Use double for slider min/max
                        max: sliderMax.toDouble(),
                        divisions:
                            sliderDivisions, // Use divisions for integer steps
                        // Disable slider if interactions are not enabled or maxStars < 1
                        onChanged: (enableInteractions && _maxStarsAmount >= 1)
                            ? (double newValue) {
                                setState(() {
                                  // Update selected amount based on slider, clamping to valid range [1, maxStars]
                                  // Note: sliderMin is 1 if maxStars >= 1, so clamp(sliderMin, ...) ensures min of 1
                                  _selectedStarsAmount = newValue.round().clamp(
                                        sliderMin,
                                        _maxStarsAmount,
                                      );
                                  // Also update the text controller when slider changes
                                  _amountTextController.text =
                                      _selectedStarsAmount.toString();
                                  // Ensure focus is not on the text field when using slider
                                  if (_amountFocusNode.hasFocus) {
                                    _amountFocusNode.unfocus();
                                  }
                                  // Exit editing mode if using slider
                                  _isEditingAmount = false;
                                });
                              }
                            : null, // Disable slider
                      ),
                    ),
                    // Display max available balance
                    if (_maxStarsAmount > 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          'Available: ${_formatNumber(_maxStarsAmount)} ${walletService.starsTokenSymbol}', // Use service symbol
                          textAlign: TextAlign.right,
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ),
                    if (_maxStarsAmount == 0)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          enableInteractions
                              ? 'Insufficient balance to send ${walletService.starsTokenSymbol}' // Use service symbol
                              : 'Connect to Sepolia to see balance', // Show if not connected/loaded
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: enableInteractions
                                ? Colors.redAccent
                                : Colors.orange,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),

                SizedBox(height: 20),
                // Description Text
                Text(
                  'Choose how many ${walletService.starsTokenSymbol} you want to send\nto ${widget.recipientName} to support this post.', // Use service symbol
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
                SizedBox(height: 20),
                // Checkbox
                CheckboxListTile(
                  title: Text(
                    'Show me in Top Senders',
                    style: TextStyle(color: Colors.white),
                  ),
                  value: _showInTopSenders,
                  // Disable checkbox if interactions are not enabled
                  onChanged: enableInteractions
                      ? (bool? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _showInTopSenders = newValue;
                            });
                          }
                        }
                      : null, // Disable checkbox
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  checkColor: Colors.amber,
                  activeColor: Colors.white,
                ),
                SizedBox(height: 30),
                // Send Button
                ElevatedButton(
                  // Button enabled if interactions are enabled AND amount is valid AND not editing
                  onPressed: isSendButtonEnabled ? _handleSendStars : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF61A4F1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    disabledBackgroundColor: const Color(
                      0xFF61A4F1,
                    ).withOpacity(0.5),
                    disabledForegroundColor: Colors.white.withOpacity(0.5),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.star, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        // Button text changes based on enabled state
                        isSendButtonEnabled
                            ? 'Send ${_formatNumber(_selectedStarsAmount)} ${walletService.starsTokenSymbol}' // Use service symbol
                            : (!enableInteractions
                                ? 'Connect to Send' // Show if not connected/loaded
                                : (_maxStarsAmount == 0
                                    ? 'Insufficient Balance'
                                    : 'Enter Amount') // Show if connected but invalid state
                            ),
                        style: TextStyle(fontSize: 18),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                // Terms of Service Link
                Center(
                  child: GestureDetector(
                    onTap: () async {
                      final url = Uri.parse('https://reown.com/terms');
                      if (await canLaunchUrl(url)) {
                        await launchUrl(
                          url,
                          mode: LaunchMode.externalApplication,
                        );
                      } else {
                        print('Could not launch $url');
                        // Use service's AppKitModal to broadcast error
                        walletService.appKitModal.onModalError.broadcast(
                          ModalError('Could not open Terms link.'),
                        );
                      }
                    },
                    child: Text(
                      'By sending ${walletService.starsTokenSymbol} you agree to the Terms of Service.', // Use service symbol
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF61A4F1),
                        decoration: TextDecoration.underline,
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
