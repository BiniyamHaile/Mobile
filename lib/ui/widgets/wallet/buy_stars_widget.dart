import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For formatting currency
import 'package:mobile/services/Wallet_service/wallet_service.dart';
// Import the service
import 'package:provider/provider.dart'; // Import Provider
import 'package:reown_appkit/reown_appkit.dart';

class BuyStarsModal extends StatefulWidget {
  const BuyStarsModal({super.key});

  @override
  State<BuyStarsModal> createState() => _BuyStarsModalState();
}

class _BuyStarsModalState extends State<BuyStarsModal> {
  // Define the fixed package amounts in Stars (matching image)
  final List<int> _starPackages = [
    5,
    10,
    50,
    100,
    150,
    250,
    350,
    500,
    750,
    1000,
    1500,
    2500,
    5000,
    10000,
  ];

  int? _selectedStarsAmount; // Null means package not selected
  final TextEditingController _customAmountController =
      TextEditingController(); // For user input of native amount

  String _calculatedStarsDisplay =
      ''; // Display calculated stars for custom input
  String _buyStatus = 'Select a package or enter amount.'; // Status text

  // Store the native amount (as double) that will be sent with the transaction
  double? _purchaseAmountNative;

  // Access the WalletService instance using `late` because it's initialized in initState
  late WalletService _walletService;

  @override
  void initState() {
    super.initState();
    // Get the WalletService instance using listen: false.
    // We do this in initState to get the service *instance* and add listeners
    // or call methods that don't require the widget tree to be built yet.
    // We use listen: false because we don't want *this initState* method
    // to rerun every time the WalletService state changes.
    _walletService = Provider.of<WalletService>(context, listen: false);

    // Add listener to custom amount controller to update calculation/status
    _customAmountController.addListener(_updateCustomAmountCalculation);
    // Set initial status
    _updateBuyStatus();
  }

  @override
  void dispose() {
    _customAmountController.removeListener(_updateCustomAmountCalculation);
    _customAmountController.dispose();
    super.dispose();
  }

  // Helper to format a number with commas (Can stay here or move to service)
  String _formatNumber(int number) {
    // Only format if number is non-negative
    if (number < 0) return number.toString();
    final formatter = NumberFormat('#,###');
    return formatter.format(number);
  }

  // --- Manual Input Logic ---
  // (These methods use the _walletService instance obtained in initState)

  void _updateCustomAmountCalculation() {
    final text = _customAmountController.text.trim();
    if (text.isEmpty) {
      setState(() {
        _calculatedStarsDisplay = '';
        _purchaseAmountNative = null; // Clear purchase amount
        _updateBuyStatus(); // Update status based on no input/selection
      });
      return;
    }

    try {
      final amountNative = double.parse(text);
      if (amountNative <= 0) {
        setState(() {
          _calculatedStarsDisplay = 'Invalid amount';
          _purchaseAmountNative = null; // Clear purchase amount
          _updateBuyStatus();
        });
        return;
      }

      // Use the WalletService helper to get the stars amount
      final calculatedStars = _walletService.getStarsAmountForNative(
        amountNative,
      );

      setState(() {
        _selectedStarsAmount = null; // Clear package selection
        _calculatedStarsDisplay =
            '${_formatNumber(calculatedStars)} ${_walletService.starsTokenSymbol}'; // Use service symbol
        _purchaseAmountNative = amountNative; // Set purchase amount from input
        _updateBuyStatus(); // Update status
      });
    } catch (e) {
      // Handle non-numeric input
      setState(() {
        _calculatedStarsDisplay = 'Invalid number';
        _purchaseAmountNative = null; // Clear purchase amount
        _updateBuyStatus();
      });
    }
  }

  void _handlePackageSelected(int starsAmount) {
    // Clear custom input when a package is selected
    _customAmountController.clear();

    setState(() {
      _selectedStarsAmount = starsAmount; // Set selected package
      // Use the WalletService helper to get the native amount
      _purchaseAmountNative = _walletService.getNativeAmountForStars(
        starsAmount,
      );
      _updateBuyStatus(); // Update status
    });
  }

  void _updateBuyStatus() {
    // Determine current purchase amount and stars based on selection or input
    double? currentAmountNative;
    int? currentStarsAmount;

    if (_selectedStarsAmount != null) {
      currentStarsAmount = _selectedStarsAmount;
      // Use the WalletService helper
      currentAmountNative = _walletService.getNativeAmountForStars(
        currentStarsAmount!,
      );
    } else if (_purchaseAmountNative != null && _purchaseAmountNative! > 0) {
      currentAmountNative = _purchaseAmountNative;
      // Use the WalletService helper
      currentStarsAmount = _walletService.getStarsAmountForNative(
        currentAmountNative!,
      );
    }

    if (currentAmountNative == null || currentAmountNative <= 0) {
      setState(() {
        _buyStatus = 'Select a package or enter amount.';
      });
      return; // No valid amount selected or entered
    }

    // Use WalletService helpers and state to check balance
    final requiredNativeAmountWei = _walletService.nativeDoubleToWei(
      currentAmountNative,
    );
    final currentNativeBalanceWei =
        _walletService.currentNativeBalanceWei; // Access service state

    // Check if user has enough native currency
    if (currentNativeBalanceWei < requiredNativeAmountWei) {
      setState(() {
        _buyStatus =
            'Insufficient ${_walletService.connectedNetwork?.currency ?? "Native"} balance.'; // Use service state
      });
    } else {
      // Format the amount for display in the status
      final formattedNativeAmount = currentAmountNative
          .toStringAsFixed(4)
          .replaceAll(RegExp(r'0*$'), '')
          .replaceAll(RegExp(r'\.$'), '');

      setState(() {
        _buyStatus =
            'Ready to buy ${_formatNumber(currentStarsAmount ?? 0)} ${_walletService.starsTokenSymbol} for $formattedNativeAmount ${_walletService.connectedNetwork?.currency ?? "Native"}.'; // Use service state/symbol
      });
    }
  }

  void _confirmPurchase() {
    // Final check before popping the modal
    if (_purchaseAmountNative == null || _purchaseAmountNative! <= 0) {
      // Use service's AppKitModal instance to broadcast error
      _walletService.appKitModal.onModalError.broadcast(
        ModalError('Please select a package or enter a valid amount to buy.'),
      );
      return;
    }

    // Use WalletService helpers and state for final balance check
    final requiredNativeAmountWei = _walletService.nativeDoubleToWei(
      _purchaseAmountNative!,
    );
    final currentNativeBalanceWei =
        _walletService.currentNativeBalanceWei; // Access service state

    if (currentNativeBalanceWei < requiredNativeAmountWei) {
      // Use service's AppKitModal instance to broadcast error
      _walletService.appKitModal.onModalError.broadcast(
        ModalError(
          'Insufficient ${_walletService.connectedNetwork?.currency ?? "Native"} balance for this purchase.', // Use service state
        ),
      );
      // Update status on modal if balance check fails here
      setState(() {
        _buyStatus =
            'Insufficient ${_walletService.connectedNetwork?.currency ?? "Native"} balance.'; // Use service state
      });
      return;
    }

    // If checks pass, pop the modal and return the native amount (double) to the caller (MyHomePage).
    // The caller will then use the WalletService to initiate the transaction.
    Navigator.pop(context, _purchaseAmountNative!);
  }

  @override
  Widget build(BuildContext context) {
    // Watch the WalletService state to rebuild the UI when wallet data changes.
    // This is necessary to update balance displays, network currency symbols,
    // and button enable states within the modal.
    final walletService = context.watch<WalletService>();

    // Determine if interactions are generally enabled (connected to Sepolia, contracts loaded)
    final isSepoliaConnected =
        walletService.isConnected &&
        walletService.connectedNetwork?.chainId == walletService.sepoliaChainId;
    final enableInteractions =
        isSepoliaConnected && walletService.areContractsLoaded;

    // Calculate and format the user's Stars balance for display using service helpers
    final double currentStarsBalanceDouble = walletService.weiToStarsDouble(
      walletService.currentStarsBalanceWei, // Access service state
      walletService.starsTokenDecimals, // Access service state
    );
    String formattedStarsBalance = currentStarsBalanceDouble.toStringAsFixed(4);
    if (formattedStarsBalance.contains('.')) {
      formattedStarsBalance = formattedStarsBalance.replaceAll(
        RegExp(r'0*$'),
        '',
      );
      if (formattedStarsBalance.endsWith('.')) {
        formattedStarsBalance = formattedStarsBalance.substring(
          0,
          formattedStarsBalance.length - 1,
        );
      }
    }

    // Calculate and format the user's Native balance for display using service helpers
    final double currentNativeBalanceDouble = walletService.weiToNativeDouble(
      walletService.currentNativeBalanceWei, // Access service state
    );
    String formattedNativeBalance = currentNativeBalanceDouble.toStringAsFixed(
      4,
    );
    if (formattedNativeBalance.contains('.')) {
      formattedNativeBalance = formattedNativeBalance.replaceAll(
        RegExp(r'0*$'),
        '',
      );
      if (formattedNativeBalance.endsWith('.')) {
        formattedNativeBalance = formattedNativeBalance.substring(
          0,
          formattedNativeBalance.length - 1,
        );
      }
    }

    // Determine if the main Buy button should be enabled
    final bool enableConfirmButton =
        enableInteractions && // Must be connected & contracts loaded
        _purchaseAmountNative !=
            null && // Must have a calculated purchase amount
        _purchaseAmountNative! > 0 && // Amount must be positive
        walletService.currentNativeBalanceWei >= // Use service state
            walletService.nativeDoubleToWei(
              _purchaseAmountNative!,
            ); // Use service helper

    return Container(
      padding:
          EdgeInsets.all(16.0) +
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.0)),
        boxShadow: [
          BoxShadow(
            color: Color.fromRGBO(143, 148, 251, 0.1),
            blurRadius: 20,
            offset: Offset(0, -5),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: 20,),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Buy Stars',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color.fromRGBO(143, 148, 251, 1),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.close, color: Colors.grey[600]),
                  onPressed: () => Navigator.pop(context, null),
                ),
              ],
            ),
            SizedBox(height: 20),

            // Balance Card
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color.fromRGBO(143, 148, 251, 0.1), Colors.white],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Color.fromRGBO(143, 148, 251, 0.2)),
              ),
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Your Balances',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color.fromRGBO(143, 148, 251, 1),
                    ),
                  ),
                  SizedBox(height: 12),
                  _buildBalanceRow(
                    icon: Icons.star,
                    iconColor: Colors.amber[700]!,
                    amount:
                        '$formattedStarsBalance ${walletService.starsTokenSymbol}',
                  ),
                  SizedBox(height: 8),
                  _buildBalanceRow(
                    icon: Icons.account_balance_wallet_outlined,
                    iconColor: Color.fromRGBO(143, 148, 251, 1),
                    amount:
                        '${formattedNativeBalance} ${walletService.connectedNetwork?.currency ?? "Native"}',
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Info Section
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Color.fromRGBO(143, 148, 251, 0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  // Text(
                  //   '1 Star Needed',
                  //   style: TextStyle(
                  //     fontSize: 20,
                  //     fontWeight: FontWeight.bold,
                  //     color: Color.fromRGBO(143, 148, 251, 1),
                  //   ),
                  // ),
                  SizedBox(height: 8),
                  Text(
                    'Buy Stars to send paid reactions to channels.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),

            // Package Selection
            Text(
              'Choose package',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(143, 148, 251, 1),
              ),
            ),
            SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: _starPackages.length,
              separatorBuilder: (context, index) => SizedBox(height: 8),
              itemBuilder: (context, index) {
                final starsAmount = _starPackages[index];
                final requiredNativeAmount = walletService
                    .getNativeAmountForStars(starsAmount);
                final isSelected = _selectedStarsAmount == starsAmount;
                final requiredNativeAmountWei = walletService.nativeDoubleToWei(
                  requiredNativeAmount,
                );
                final bool canAffordThisPackage =
                    walletService.currentNativeBalanceWei >=
                    requiredNativeAmountWei;

                return Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Color.fromRGBO(143, 148, 251, 0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Color.fromRGBO(143, 148, 251, 1)
                          : Color.fromRGBO(143, 148, 251, 0.2),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(143, 148, 251, 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(Icons.star, color: Colors.amber[700]),
                    ),
                    title: Text(
                      '${_formatNumber(starsAmount)} ${walletService.starsTokenSymbol}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(143, 148, 251, 1),
                      ),
                    ),
                    trailing: Text(
                      '${requiredNativeAmount.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')} ${walletService.connectedNetwork?.currency ?? "Native"}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: enableInteractions
                            ? (canAffordThisPackage ? Colors.green : Colors.red)
                            : Colors.grey,
                      ),
                    ),
                    onTap: enableInteractions
                        ? () => _handlePackageSelected(starsAmount)
                        : null,
                  ),
                );
              },
            ),
            SizedBox(height: 24),

            // Custom Amount Section
            Text(
              'Or buy with native currency',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color.fromRGBO(143, 148, 251, 1),
              ),
            ),
            SizedBox(height: 12),
            TextField(
              controller: _customAmountController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              enabled: enableInteractions,
              decoration: InputDecoration(
                labelText:
                    'Amount (${walletService.connectedNetwork?.currency ?? "Native"})',
                hintText: 'e.g., 0.05',
                filled: true,
                fillColor: Colors.grey[50],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(143, 148, 251, 0.2),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(143, 148, 251, 0.2),
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(
                    color: Color.fromRGBO(143, 148, 251, 1),
                  ),
                ),
                contentPadding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                suffixText: _calculatedStarsDisplay,
                suffixStyle: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            SizedBox(height: 24),

            // Buy Button
            ElevatedButton(
              onPressed: enableConfirmButton ? _confirmPurchase : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color.fromRGBO(143, 148, 251, 1),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
              child: Text(
                _purchaseAmountNative == null || _purchaseAmountNative! <= 0
                    ? 'Select / Enter Amount'
                    : 'Confirm Purchase',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 12),

            // Status Text
            Center(
              child: Text(
                _buyStatus,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: _buyStatus.contains('Insufficient')
                      ? Colors.red
                      : Colors.grey[700],
                ),
              ),
            ),
            SizedBox(height: 16),

            // Conversion Rate
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Conversion Rate: 1 ${walletService.connectedNetwork?.currency ?? "Native"} = ${walletService.starsPerNativeToken.toStringAsFixed(0)} ${walletService.starsTokenSymbol}',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[700],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
            SizedBox(height: 12),

            // // Terms
            // Text(
            //   'By proceeding and purchasing Stars, you agree with the Terms and Conditions.',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 11, color: Colors.grey[600]),
            // ),
            // SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildBalanceRow({
    required IconData icon,
    required Color iconColor,
    required String amount,
  }) {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Color.fromRGBO(143, 148, 251, 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        SizedBox(width: 12),
        Text(
          amount,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }
}
