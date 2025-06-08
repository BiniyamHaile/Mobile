import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:mobile/models/token.dart';
import 'package:mobile/services/Wallet_service/wallet_service.dart';
import 'package:mobile/ui/styles/app_colors.dart';
import 'package:mobile/ui/widgets/wallet/buy_stars_widget.dart';
import 'package:mobile/ui/widgets/wallet/star_reaction_modal.dart';
import 'package:provider/provider.dart';
import 'package:reown_appkit/modal/i_appkit_modal_impl.dart';
import 'package:reown_appkit/reown_appkit.dart';
import 'package:url_launcher/url_launcher.dart';

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
        ModalError('Please connect to Sepolia network to buy stars.'),
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
        ModalError('Please connect to Sepolia network to gift stars.'),
      );
      return;
    }

    final recipientAddressString = _giftRecipientAddressController.text.trim();
    if (recipientAddressString.isEmpty) {
      walletService.appKitModal.onModalError.broadcast(
        ModalError('Default recipient address not set.'),
      );
      return;
    }
    try {
      if (!recipientAddressString.startsWith('0x') ||
          recipientAddressString.length != 42) {
        throw const FormatException("Invalid address format");
      }
    } catch (e) {
      walletService.appKitModal.onModalError.broadcast(
        ModalError('Invalid default recipient address format.'),
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
        );
      },
    ).then((amountInStars) {
      if (amountInStars != null && amountInStars > 0) {
        print('Modal returned amount: $amountInStars. Initiating gift...');
        walletService.sendGiftStars(recipientAddressString, amountInStars);
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

    print('--- Debug Transaction Item ---');
    print('Tx Hash: ${tx.hash}');
    print('Tx Value (BigInt): ${tx.value}');
    print('Tx Decimal (int): ${tx.tokenDecimal}');
    print('Calculated Amount (double): $amount');
    print('Amount Runtime Type: ${amount.runtimeType}');

    String formattedAmount;
    if (amount is num) {
      formattedAmount = NumberFormat('#,##0.####').format(amount);
    } else {
      print(
        "!!! ALERT: amount is NOT a number. It is ${amount.runtimeType} !!!",
      );
      formattedAmount = 'Invalid Amount';
    }
    print('Formatted Amount: $formattedAmount');
    print('--- End Debug Transaction Item ---');

    final bool isExpanded = _expandedTxHash == tx.hash;

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
      elevation: 0.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: InkWell(
        onTap: () {
          setState(() {
            if (isExpanded) {
              _expandedTxHash = null;
            } else {
              _expandedTxHash = tx.hash;
            }
          });
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        isOutgoing ? Icons.north_east : Icons.south_west,
                        color: isOutgoing ? Colors.red[700] : Colors.green[700],
                        size: 18,
                      ),
                      SizedBox(width: 8),
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
                    ],
                  ),
                ],
              ),
              Visibility(
                visible: isExpanded,
                child: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 4),
                      Text(
                        'Token ID: ${tx.tokenSymbol}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        isOutgoing ? 'To: ${tx.to}' : 'From: ${tx.from}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'When: ${_formatTimestamp(tx.timeStamp)}',
                        style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                      SizedBox(height: 4),
                      if (tx.hash.isNotEmpty)
                        GestureDetector(
                          onTap: () async {
                            final url = Uri.parse(
                              'https://sepolia.etherscan.io/tx/${tx.hash}',
                            );
                            if (await canLaunchUrl(url)) {
                              await launchUrl(
                                url,
                                mode: LaunchMode.externalApplication,
                              );
                            } else {
                              print('Could not launch $url');
                              walletService.appKitModal.onModalError.broadcast(
                                ModalError('Could not open transaction link.'),
                              );
                            }
                          },
                          child: Text(
                            'Tx Hash: ${tx.hash}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.indigoAccent,
        elevation: 0,
        leading: isConnected
            ? Builder(
                builder: (context) => IconButton(
                  icon: const Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
              )
            : null,
      ),
      drawer: isConnected
          ? Drawer(
              backgroundColor: AppColors().purpleEventColor,
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 0, vertical: 30),
                children: [
                  // ListTile(
                  //   leading: Icon(Icons.refresh),
                  //   title: Text('Refresh STARS Balance'),
                  //   onTap: enableTxActions
                  //       ? walletService.getStarsBalance
                  //       : null,
                  //   enabled:
                  //       enableTxActions,
                  // ),
                  ListTile(
                    leading: Icon(Icons.token),
                    title: Text('Add STARS Token to Wallet'),
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

                      color: Theme.of(context).canvasColor,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16.0,
                        ),
                        leading: Icon(
                          Icons.logout,

                          color: isConnected
                              ? Colors.red[700]
                              : Colors.grey[500],
                        ),
                        title: Text(
                          'Disconnect',
                          style: TextStyle(
                            color: isConnected
                                ? Colors.red[700]
                                : Colors.grey[500],
                            fontWeight: FontWeight.bold,
                          ),
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
                    'Welcome to the Secure Wallet',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),
                  Text(
                    'Connect your wallet to get started.',
                    style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 30),
                  // AppKitModalConnectButton handles the connection logic
                  // AppKitModalConnectButton(
                  //   appKit: walletService.appKitModal,
                  //   context: context,
                  // ),
                  ElevatedButton(
                    onPressed: () => _connectWallet(context),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      child: Text(
                        'Connect Wallet',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  if (walletService.status == ReownAppKitModalStatus.error)
                    Text(
                      'Connection failed.',
                      style: TextStyle(
                        fontStyle: FontStyle.italic,
                        color: Colors.red,
                      ),
                    ),
                  SizedBox(height: 20),
                  if (walletService.status ==
                      ReownAppKitModalStatus.initializing)
                    Text(
                      'Initializing wallet service...',
                      style: TextStyle(fontStyle: FontStyle.italic),
                    ),
                  if (walletService.status == ReownAppKitModalStatus.error)
                    Text(
                      'Initialization failed.',
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
                                backgroundColor: Colors.deepPurple.shade100,
                                radius: 18,
                                child: Text(
                                  walletService.starsTokenSymbol[0],
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.deepPurple,
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
                                          '$formattedStarsBalance ${walletService.starsTokenSymbol}', // Use service symbol
                                          style: TextStyle(fontSize: 16),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 4),
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.account_balance_wallet_outlined,
                                          color: Colors.blueGrey,
                                          size: 20,
                                        ),
                                        SizedBox(width: 8),
                                        Text(
                                          '${formattedNativeBalance} ${walletService.connectedNetwork?.currency ?? "Native"}', // Use service state for currency symbol
                                          style: TextStyle(fontSize: 16),
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
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildActionButton(
                        icon: Icons.shopping_cart,
                        label: 'Buy',
                        onPressed: enableBuyButton ? _showBuyStarsModal : null,
                      ),
                      SizedBox(width: 8),
                      _buildActionButton(
                        icon: Icons.card_giftcard,
                        label: 'Gift',
                        onPressed: enableGiftButton
                            ? _showStarReactionModal
                            : null,
                      ),
                      SizedBox(width: 8), 
                    ],
                  ),
                  SizedBox(height: 30), 
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10.0),
                    child: Text(
                      'Recent STARS Transactions (Sepolia):',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center, 
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
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
                        if (currentAddress == null)
                          return SizedBox.shrink(); 
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
