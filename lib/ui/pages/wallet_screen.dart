import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/token.dart';
import 'package:mobile/services/Wallet_service/wallet_service.dart';
import 'package:mobile/services/localization/app_string.dart';
import 'package:mobile/services/localization/string_extension.dart';
import 'package:mobile/ui/theme/app_theme.dart';
import 'package:mobile/ui/widgets/wallet/buy_stars_widget.dart';
import 'package:mobile/ui/widgets/wallet/star_reaction_modal.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/modal/i_appkit_modal_impl.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:url_launcher/url_launcher.dart';

// Define the custom clipper for the concave bottom shape
class ConcaveBottomClipper extends CustomClipper<Path> {
  final double curveHeight; // How deep the concave curve is

  ConcaveBottomClipper({this.curveHeight = 30.0}); // Default curve height

  @override
  Path getClip(Size size) {
    final path = Path();
    // Start from the top-left corner (0,0)
    path.lineTo(0, size.height); // Go down to the bottom-left
    // Add a quadratic bezier curve from bottom-left to bottom-right
    // The control point is in the middle horizontally, and moves *up* to create the concave shape
    path.quadraticBezierTo(
      size.width / 2, // Control point x (middle horizontal)
      size.height - curveHeight, // Control point y (above the bottom)
      size.width, // End point x (bottom-right)
      size.height, // End point y (bottom)
    );
    // Go up to the top-right corner
    path.lineTo(size.width, 0);
    // Close the path (draws a line from top-right back to top-left)
    path.close();

    return path;
  }

  @override
  bool shouldReclip(ConcaveBottomClipper oldClipper) {
    // Only reclip if the curveHeight changes
    return oldClipper.curveHeight != curveHeight;
  }
}

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  State<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen> {
  final TextEditingController _giftRecipientAddressController =
      TextEditingController();

  final String _defaultRecipientAddress =
      '0x6ed5aD6f949b27EDA88C47d1e3b9Eb3DE9140cfE';

  String? _expandedTxHash;

  @override
  void initState() {
    super.initState();
    _giftRecipientAddressController.text = _defaultRecipientAddress;

    final walletService = Provider.of<WalletService>(context, listen: false);
    walletService.init(context);
  }

  @override
  void dispose() {
    _giftRecipientAddressController.dispose();
    super.dispose();
  }

  void _connectWallet(BuildContext context) {
    final walletService = Provider.of<WalletService>(context, listen: false);
    walletService.connectWallet(context);
  }

  void _disconnectWallet(BuildContext context) {
    final walletService = Provider.of<WalletService>(context, listen: false);
    walletService.disconnect();
  }

  void _showBuyStarsModal() {
    final walletService = Provider.of<WalletService>(context, listen: false);

    if (!walletService.isConnected ||
        walletService.currentSession == null ||
        !walletService.areContractsLoaded ||
        walletService.connectedAddress == null ||
        walletService.connectedNetwork?.chainId !=
            walletService.sepoliaChainId) {
      walletService.appKitModal.onModalError.broadcast(
        ModalError(AppStrings.connectSepoliaNetwork.tr(context)),
      );
      return;
    }

    showModalBottomSheet<double?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return BuyStarsModal();
      },
    ).then((amountNative) {
      if (amountNative != null && amountNative > 0) {
        print('Modal returned amount: $amountNative. Initiating buy...');
        walletService.buyStars(amountNative);
      } else {
        print('Buy Stars Modal closed or no amount selected.');
      }
    });
  }

  void _showStarReactionModal() {
    final walletService = Provider.of<WalletService>(context, listen: false);

    if (!walletService.isConnected ||
        walletService.currentSession == null ||
        !walletService.areContractsLoaded ||
        walletService.connectedAddress == null ||
        walletService.connectedNetwork?.chainId !=
            walletService.sepoliaChainId) {
      walletService.appKitModal.onModalError.broadcast(
        ModalError(AppStrings.connectSepoliaNetworkGift.tr(context)),
      );
      return;
    }

    final recipientAddressString = _giftRecipientAddressController.text.trim();
    if (recipientAddressString.isEmpty) {
      walletService.appKitModal.onModalError.broadcast(
        ModalError(AppStrings.defaultRecipientNotSet.tr(context)),
      );
      return;
    }
    try {
      if (!recipientAddressString.startsWith('0x') ||
          recipientAddressString.length != 42) {
        throw const FormatException(AppStrings.invalidAddress);
      }
    } catch (e) {
      walletService.appKitModal.onModalError.broadcast(
        ModalError(AppStrings.invalidRecipientFormat.tr(context)),
      );
      print('Recipient address parsing error before modal: $e');
      return;
    }

    showModalBottomSheet<int?>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return StarReactionModal(
          recipientName: "Default Recipient",
          recipientAddress: recipientAddressString,
          recipientId: '', // Assuming recipientId is not needed here
        );
      },
    ).then((amountInStars) {
      if (amountInStars != null && amountInStars > 0) {
        print('Modal returned amount: $amountInStars. Initiating gift...');
        walletService.sendGiftStars(recipientAddressString, amountInStars, '');
      } else {
        print('Modal closed or no amount selected.');
      }
    });
  }

  String _formatTimestamp(int timestamp) {
    try {
      final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.toLocal());
    } catch (e) {
      print("Error formatting timestamp $timestamp: $e");
      return "Invalid Date";
    }
  }

  Widget _buildTransactionItem(
    TokenTransaction tx,
    String currentAddress,
    WalletService walletService,
  ) {
    final bool isOutgoing =
        tx.from.toLowerCase() == currentAddress.toLowerCase();
    final double amount = walletService.weiToStarsDouble(
      tx.value,
      tx.tokenDecimal,
    );
    String formattedAmount = NumberFormat('#,##0.####').format(amount);
    final bool isExpanded = _expandedTxHash == tx.hash;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 0),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
        side: BorderSide(color: Color.fromRGBO(143, 148, 251, 0.2), width: 1),
      ),
      child: InkWell(
        onTap: () {
          setState(() {
            _expandedTxHash = isExpanded ? null : tx.hash;
          });
        },
        borderRadius: BorderRadius.circular(16.0),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color.fromRGBO(143, 148, 251, 0.05)],
            ),
            borderRadius: BorderRadius.circular(16.0),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isOutgoing
                              ? Colors.red.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          isOutgoing
                              ? Icons.arrow_upward_rounded
                              : Icons.arrow_downward_rounded,
                          color: isOutgoing
                              ? Colors.red[700]
                              : Colors.green[700],
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${isOutgoing ? '-' : '+'}${formattedAmount} ${tx.tokenSymbol}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: isOutgoing
                                  ? Colors.red[700]
                                  : Colors.green[700],
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            _formatTimestamp(tx.timeStamp),
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Color.fromRGBO(143, 148, 251, 1),
                  ),
                ],
              ),
              if (isExpanded) ...[
                const Divider(height: 24),
                _buildDetailRow(
                  icon: Icons.token,
                  label: 'Token',
                  value: tx.tokenSymbol,
                ),
                const SizedBox(height: 12),
                _buildDetailRow(
                  icon: isOutgoing ? Icons.send : Icons.call_received,
                  label: isOutgoing ? 'To' : 'From',
                  value: isOutgoing ? tx.to : tx.from,
                ),
                // const SizedBox(height: 12),
                // if (tx.hash.isNotEmpty)
                //   GestureDetector(
                //     onTap: () async {
                //       final url = Uri.parse(
                //         'https://sepolia.etherscan.io/tx/${tx.hash}',
                //       );
                //       if (await canLaunchUrl(url)) {
                //         await launchUrl(
                //           url,
                //           mode: LaunchMode.externalApplication,
                //         );
                //       } else {
                //         walletService.appKitModal.onModalError.broadcast(
                //           ModalError('Could not open transaction link.'),
                //         );
                //       }
                //     },
                //     child: Container(
                //       padding: const EdgeInsets.symmetric(
                //         vertical: 8,
                //         horizontal: 12,
                //       ),
                //       decoration: BoxDecoration(
                //         color: Color.fromRGBO(143, 148, 251, 0.1),
                //         borderRadius: BorderRadius.circular(8),
                //       ),
                //       child: Row(
                //         mainAxisSize: MainAxisSize.min,
                //         children: [
                //           Icon(
                //             Icons.link,
                //             size: 16,
                //             color: Color.fromRGBO(143, 148, 251, 1),
                //           ),
                //           const SizedBox(width: 8),
                //           Text(
                //             'View on Etherscan',
                //             style: TextStyle(
                //               fontSize: 12,
                //               color: Color.fromRGBO(143, 148, 251, 1),
                //               fontWeight: FontWeight.w500,
                //             ),
                //           ),
                //         ],
                //       ),
                //     ),
                // ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Color.fromRGBO(143, 148, 251, 1)),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[700],
            fontWeight: FontWeight.w500,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(fontSize: 12, color: Colors.grey[900]),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(30),
            child: CircleAvatar(
              radius: 30,
              backgroundColor: onPressed != null
                  ? Colors.deepPurple.shade50
                  : Colors.grey.shade300,
              child: Icon(
                icon,
                color: onPressed != null
                    ? Colors.deepPurple
                    : Colors.grey.shade500,
                size: 24,
              ),
            ),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: onPressed != null ? Colors.black87 : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final walletService = context.watch<WalletService>();

    final isSepoliaConnected =
        walletService.isConnected &&
        walletService.connectedNetwork?.chainId == walletService.sepoliaChainId;
    final isConnected = walletService.isConnected;
    final contractsLoaded = walletService.areContractsLoaded;

    final enableTxActions = isSepoliaConnected && contractsLoaded;

    final bool enableRefreshTransactionsButton =
        isSepoliaConnected &&
        !walletService.isLoadingTransactions &&
        !walletService.transactionListStatus.contains('API key is missing');

    final bool enableGiftButton = enableTxActions;

    final bool enableBuyButton = enableTxActions;

    final double currentStarsBalanceDouble = walletService.weiToStarsDouble(
      walletService.currentStarsBalanceWei,
      walletService.starsTokenDecimals,
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

    final double currentNativeBalanceDouble = walletService.weiToNativeDouble(
      walletService.currentNativeBalanceWei,
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
    final theme = AppTheme.getTheme(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.onPrimary,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.onPrimary,
        elevation: 0,
        leading: isConnected
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  color: theme.colorScheme.primary,
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
      ),
      drawer: isConnected
          ? Drawer(
              backgroundColor: theme.colorScheme.onPrimary,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 30),
                children: [
                  ClipPath(
                    clipper: ConcaveBottomClipper(curveHeight: 20.0),
                    child: SizedBox(
                      height: 80,
                      child: Container(
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          border: Border(
                            top: BorderSide(
                              color: theme
                                  .colorScheme
                                  .onPrimary, // Top border color
                              width: 2.0, // Top border width
                            ),
                            bottom: BorderSide(
                              color: theme
                                  .colorScheme
                                  .onPrimary, // Bottom border color
                              width: 2.0, // Bottom border width
                            ),
                            left: BorderSide(
                              color: theme
                                  .colorScheme
                                  .onPrimary, // Left border color
                              width: 2.0, // Left border width
                            ),
                            right: BorderSide(
                              color: theme
                                  .colorScheme
                                  .onPrimary, // Right border color
                              width: 2.0, // Right border width
                            ),
                          ),
                          // Set the background color to green
                          // Remove the borderRadius property
                        ),
                        alignment: Alignment.center,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            AppStrings.walletSettings.tr(context),
                            style: TextStyle(
                              color: theme
                                  .colorScheme
                                  .onPrimary, // Make text white for visibility on green
                              fontSize: 20, // Adjust font size
                              fontWeight: FontWeight.bold, // Make text bold
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  ListTile(
                    leading: Icon(Icons.shopping_cart),
                    title: Text(AppStrings.buyStars.tr(context)),
                    onTap: enableBuyButton
                        ? () {
                            Navigator.pop(context);
                            _showBuyStarsModal();
                          }
                        : null,
                    enabled: enableBuyButton,
                  ),
                  ListTile(
                    leading: Icon(Icons.token),
                    title: Text(AppStrings.addStarsToken.tr(context)),
                    onTap: enableTxActions
                        ? walletService.addStarsTokenToWallet
                        : null,
                    enabled: enableTxActions,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Material(
                      elevation: isConnected ? 4.0 : 0.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      ),

                      color: theme.colorScheme.onPrimary,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),

                        title: Text(
                          AppStrings.disconnect.tr(context),

                          style: TextStyle(
                            color: 
                                theme.colorScheme.onPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: Icon(
                          Icons.logout,

                          color: isConnected ? Colors.white : Colors.grey[500],
                        ),
                        onTap: isConnected
                            ? () {
                                walletService.disconnect();
                                Navigator.pop(context);
                              }
                            : null,
                        enabled: isConnected,
                      ),
                    ),
                  ),
                ],
              ),
            )
          : null,
      body: !isConnected
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.welcomeWallet.tr(context),
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    AppStrings.connectWalletMessage.tr(context),
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  ElevatedButton(
                    onPressed: () => _connectWallet(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.colorScheme.onPrimary,
                      foregroundColor: theme.colorScheme.primary,
                      elevation: 4,
                      shadowColor: theme.colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24.0,
                        vertical: 16.0,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.account_balance_wallet_rounded,
                          size: 24,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          AppStrings.connectWallet.tr(context),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (walletService.status == ReownAppKitModalStatus.error)
                    Text(
                      AppStrings.connectionFailed.tr(context),
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                      ),
                    ),
                  SizedBox(height: 20),
                  if (walletService.status ==
                      ReownAppKitModalStatus.initializing)
                    Text(
                      AppStrings.initializingWallet.tr(context),
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  if (walletService.status == ReownAppKitModalStatus.error)
                    Text(
                      AppStrings.initializationFailed.tr(context),
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                      ),
                    ),
                ],
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(height: 8),
                  Card(
                    margin: EdgeInsets.zero,
                    elevation: 1.0,
                    color: theme.colorScheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              CircleAvatar(
                                backgroundColor: theme.colorScheme.onPrimary,
                                radius: 18,
                                child: Text(
                                  walletService.starsTokenSymbol[0],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.primary,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.star,
                                          color: Colors.amber[700],
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '$formattedStarsBalance ${walletService.starsTokenSymbol}',
                                          style: TextStyle(
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          color: Colors.white,
                                          size: 16,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '$formattedNativeBalance ${walletService.connectedNetwork?.currency ?? "Native"}',
                                          style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Row(
                  //   mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //   children: [
                  //     _buildActionButton(
                  //       icon: Icons.shopping_cart,
                  //       label: 'Buy',
                  //       onPressed: enableBuyButton ? _showBuyStarsModal : null,
                  //     ),
                  //     SizedBox(width: 8),
                  //     // _buildActionButton(
                  //     //   icon: Icons.card_giftcard,
                  //     //   label: 'Gift',
                  //     //   onPressed: enableGiftButton
                  //     //       ? _showStarReactionModal
                  //     //       : null,
                  //     // ),
                  //     SizedBox(width: 8),
                  //   ],
                  // ),
                  // SizedBox(height: 30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 16.0),
                        child: Text(
                          'Recent STARS Transactions:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.refresh,
                          color: enableRefreshTransactionsButton
                              ? Colors.blue
                              : Colors.grey,
                        ),
                        tooltip: 'Refresh Transactions',
                        onPressed: enableRefreshTransactionsButton
                            ? walletService.fetchTokenTransactions
                            : null,
                      ),
                    ],
                  ),
                  SizedBox(height: 8),

                  if (walletService.transactionListStatus.isNotEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          walletService.transactionListStatus,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                                walletService.transactionListStatus.contains(
                                  'Error',
                                )
                                ? Colors.red
                                : (walletService.transactionListStatus.contains(
                                        'Loading',
                                      )
                                      ? Colors.orange
                                      : Colors.grey[700]),
                            fontStyle:
                                walletService.transactionListStatus.contains(
                                  'Loading',
                                )
                                ? FontStyle.italic
                                : null,
                          ),
                        ),
                      ),
                    )
                  else if (walletService.transactions.isEmpty &&
                      !walletService.isLoadingTransactions)
                    const Center(child: Text('No recent transactions found.'))
                  else if (walletService.transactions.isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: walletService.transactions.map((tx) {
                        final currentAddress = walletService.connectedAddress;
                        if (currentAddress == null) return SizedBox.shrink();
                        return _buildTransactionItem(
                          tx,
                          currentAddress,
                          walletService,
                        );
                      }).toList(),
                    ),
                  SizedBox(height: 40),
                ],
              ),
            ),
    );
  }
}
