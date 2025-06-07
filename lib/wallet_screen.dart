// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:my_secure_wallet_app/buy_stars_widget.dart';
// import 'package:my_secure_wallet_app/star_reaction_modal.dart';
// import 'package:my_secure_wallet_app/token.dart';
// import 'package:my_secure_wallet_app/wallet_service.dart';
// import 'package:provider/provider.dart';
// import 'package:reown_appkit/modal/i_appkit_modal_impl.dart';
// import 'package:reown_appkit/reown_appkit.dart';
// import 'package:url_launcher/url_launcher.dart';

// class WalletScreen extends StatefulWidget {
//   const WalletScreen({super.key});

//   @override
//   State<WalletScreen> createState() => _WalletScreenState();
// }

// class _WalletScreenState extends State<WalletScreen> {
//   final TextEditingController _giftRecipientAddressController =
//       TextEditingController();

//   final String _defaultRecipientAddress =
//       '0x6ed5aD6f949b27EDA88C47d1e3b9Eb3DE9140cfE';

//   String? _expandedTxHash;

//   @override
//   void initState() {
//     super.initState();
//     _giftRecipientAddressController.text = _defaultRecipientAddress;

//     final walletService = Provider.of<WalletService>(context, listen: false);
//     walletService.init(context);
//   }

//   @override
//   void dispose() {
//     _giftRecipientAddressController.dispose();
//     super.dispose();
//   }

//   void _connectWallet(BuildContext context) {
//     final walletService = Provider.of<WalletService>(context, listen: false);
//     // The service itself handles creating/recreating the modal instance if needed
//     walletService.connectWallet(context);
//   }

//   void _disconnectWallet(BuildContext context) {
//     final walletService = Provider.of<WalletService>(context, listen: false);
//     walletService.disconnect();
//   }

//   void _showBuyStarsModal() {
//     final walletService = Provider.of<WalletService>(context, listen: false);

//     if (!walletService.isConnected ||
//         walletService.currentSession == null ||
//         !walletService.areContractsLoaded ||
//         walletService.connectedAddress == null ||
//         walletService.connectedNetwork?.chainId !=
//             walletService.sepoliaChainId) {
//       walletService.appKitModal.onModalError.broadcast(
//         ModalError('Please connect to Sepolia network to buy stars.'),
//       );
//       return;
//     }

//     showModalBottomSheet<double?>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return BuyStarsModal();
//       },
//     ).then((amountNative) {
//       if (amountNative != null && amountNative > 0) {
//         print('Modal returned amount: $amountNative. Initiating buy...');
//         walletService.buyStars(amountNative);
//       } else {
//         print('Buy Stars Modal closed or no amount selected.');
//       }
//     });
//   }

//   void _showStarReactionModal() {
//     final walletService = Provider.of<WalletService>(context, listen: false);

//     if (!walletService.isConnected ||
//         walletService.currentSession == null ||
//         !walletService.areContractsLoaded ||
//         walletService.connectedAddress == null ||
//         walletService.connectedNetwork?.chainId !=
//             walletService.sepoliaChainId) {
//       walletService.appKitModal.onModalError.broadcast(
//         ModalError('Please connect to Sepolia network to gift stars.'),
//       );
//       return;
//     }

//     final recipientAddressString = _giftRecipientAddressController.text.trim();
//     if (recipientAddressString.isEmpty) {
//       walletService.appKitModal.onModalError.broadcast(
//         ModalError('Default recipient address not set.'),
//       );
//       return;
//     }
//     try {
//       if (!recipientAddressString.startsWith('0x') ||
//           recipientAddressString.length != 42) {
//         throw const FormatException("Invalid address format");
//       }
//     } catch (e) {
//       walletService.appKitModal.onModalError.broadcast(
//         ModalError('Invalid default recipient address format.'),
//       );
//       print('Recipient address parsing error before modal: $e');
//       return;
//     }

//     showModalBottomSheet<int?>(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.transparent,
//       builder: (BuildContext context) {
//         return StarReactionModal(
//           recipientName: "Default Recipient",
//           recipientAddress: recipientAddressString,
//         );
//       },
//     ).then((amountInStars) {
//       if (amountInStars != null && amountInStars > 0) {
//         print('Modal returned amount: $amountInStars. Initiating gift...');
//         walletService.sendGiftStars(recipientAddressString, amountInStars);
//       } else {
//         print('Modal closed or no amount selected.');
//       }
//     });
//   }

//   String _formatTimestamp(int timestamp) {
//     try {
//       final dateTime = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
//       return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime.toLocal());
//     } catch (e) {
//       print("Error formatting timestamp $timestamp: $e");
//       return "Invalid Date";
//     }
//   }

//   Widget _buildTransactionItem(
//     TokenTransaction tx,
//     String currentAddress,
//     WalletService walletService,
//   ) {
//     final bool isOutgoing =
//         tx.from.toLowerCase() == currentAddress.toLowerCase();

//     // Calculate the amount
//     final double amount = walletService.weiToStarsDouble(
//       tx.value,
//       tx.tokenDecimal,
//     );

//     // --- Add Debugging and Safety Check Here ---
//     print('--- Debug Transaction Item ---');
//     print('Tx Hash: ${tx.hash}');
//     print('Tx Value (BigInt): ${tx.value}');
//     print('Tx Decimal (int): ${tx.tokenDecimal}');
//     print('Calculated Amount (double): $amount');
//     print('Amount Runtime Type: ${amount.runtimeType}');

//     String formattedAmount;
//     // Check if the calculated amount is actually a number before formatting
//     if (amount is num) {
//       // Check if it's any number type (int or double)
//       formattedAmount = NumberFormat('#,##0.####').format(amount);
//     } else {
//       // If it's not a number, handle the unexpected type
//       print(
//         "!!! ALERT: amount is NOT a number. It is ${amount.runtimeType} !!!",
//       );
//       formattedAmount = 'Invalid Amount'; // Display an error placeholder
//       // You might also want to broadcast an error or handle this malformed item explicitly
//     }
//     print('Formatted Amount: $formattedAmount');
//     print('--- End Debug Transaction Item ---');
//     // --- End Debugging ---

//     final bool isExpanded = _expandedTxHash == tx.hash;

//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 0),
//       elevation: 0.5,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//       child: InkWell(
//         onTap: () {
//           setState(() {
//             if (isExpanded) {
//               _expandedTxHash = null;
//             } else {
//               _expandedTxHash = tx.hash;
//             }
//           });
//         },
//         child: Padding(
//           padding: const EdgeInsets.all(12.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Amount and Symbol (Always visible)
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Row(
//                     // Icon and Amount/Direction
//                     children: [
//                       Icon(
//                         isOutgoing ? Icons.north_east : Icons.south_west,
//                         color: isOutgoing ? Colors.red[700] : Colors.green[700],
//                         size: 18,
//                       ),
//                       SizedBox(width: 8),
//                       Text(
//                         '${isOutgoing ? '-' : '+'}${formattedAmount} ${tx.tokenSymbol}', // Use the potentially 'Invalid Amount' string
//                         style: TextStyle(
//                           fontWeight: FontWeight.bold,
//                           color: isOutgoing
//                               ? Colors.red[700]
//                               : Colors.green[700],
//                           fontSize: 16,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//               Visibility(
//                 visible: isExpanded,
//                 child: Padding(
//                   padding: const EdgeInsets.only(
//                     top: 8.0,
//                   ), // Add padding if expanded
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(height: 4),
//                       Text(
//                         'Token ID: ${tx.tokenSymbol}',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         isOutgoing ? 'To: ${tx.to}' : 'From: ${tx.from}',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                       ),
//                       SizedBox(height: 4),
//                       Text(
//                         'When: ${_formatTimestamp(tx.timeStamp)}',
//                         style: TextStyle(fontSize: 12, color: Colors.grey[700]),
//                       ),
//                       SizedBox(height: 4),
//                       // Check if the transaction hash is valid before creating a link
//                       if (tx.hash.isNotEmpty)
//                         GestureDetector(
//                           onTap: () async {
//                             final url = Uri.parse(
//                               'https://sepolia.etherscan.io/tx/${tx.hash}',
//                             );
//                             if (await canLaunchUrl(url)) {
//                               await launchUrl(
//                                 url,
//                                 mode: LaunchMode.externalApplication,
//                               );
//                             } else {
//                               print('Could not launch $url');
//                               walletService.appKitModal.onModalError.broadcast(
//                                 ModalError('Could not open transaction link.'),
//                               );
//                             }
//                           },
//                           child: Text(
//                             'Tx Hash: ${tx.hash}', // Show full hash when expanded
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Colors.blue,
//                               decoration: TextDecoration.underline,
//                             ),
//                           ),
//                         ),
//                     ],
//                   ),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   // Helper function to build the action button widgets
//   Widget _buildActionButton({
//     required IconData icon,
//     required String label,
//     required VoidCallback? onPressed,
//   }) {
//     return Expanded(
//       // Use Expanded to distribute space
//       child: Column(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           InkWell(
//             // Use InkWell for tap effect and custom shape
//             onTap: onPressed,
//             borderRadius: BorderRadius.circular(30), // Make it circular
//             child: CircleAvatar(
//               radius: 30,
//               backgroundColor: onPressed != null
//                   ? Colors.deepPurple.shade50
//                   : Colors.grey.shade300, // Different color when disabled
//               child: Icon(
//                 icon,
//                 color: onPressed != null
//                     ? Colors.deepPurple
//                     : Colors.grey.shade500, // Different color when disabled
//                 size: 24,
//               ),
//             ),
//           ),
//           SizedBox(height: 8),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 12,
//               color: onPressed != null ? Colors.black87 : Colors.grey,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     final walletService = context.watch<WalletService>();

//     final isSepoliaConnected =
//         walletService.isConnected &&
//         walletService.connectedNetwork?.chainId == walletService.sepoliaChainId;
//     final isConnected = walletService.isConnected;
//     final contractsLoaded = walletService.areContractsLoaded;

//     final enableTxActions = isSepoliaConnected && contractsLoaded;

//     final bool enableRefreshTransactionsButton =
//         isSepoliaConnected &&
//         !walletService.isLoadingTransactions &&
//         !walletService.transactionListStatus.contains('API key is missing');

//     final bool enableGiftButton = enableTxActions;

//     final bool enableBuyButton = enableTxActions;

//     // Calculate and format the user's Stars balance for display using service helpers
//     final double currentStarsBalanceDouble = walletService.weiToStarsDouble(
//       walletService.currentStarsBalanceWei, // Access service state
//       walletService.starsTokenDecimals, // Access service state
//     );
//     String formattedStarsBalance = currentStarsBalanceDouble.toStringAsFixed(4);
//     if (formattedStarsBalance.contains('.')) {
//       formattedStarsBalance = formattedStarsBalance.replaceAll(
//         RegExp(r'0*$'),
//         '',
//       );
//       if (formattedStarsBalance.endsWith('.')) {
//         formattedStarsBalance = formattedStarsBalance.substring(
//           0,
//           formattedStarsBalance.length - 1,
//         );
//       }
//     }

//     final double currentNativeBalanceDouble = walletService.weiToNativeDouble(
//       walletService.currentNativeBalanceWei, // Access service state
//     );
//     String formattedNativeBalance = currentNativeBalanceDouble.toStringAsFixed(
//       4,
//     );
//     if (formattedNativeBalance.contains('.')) {
//       formattedNativeBalance = formattedNativeBalance.replaceAll(
//         RegExp(r'0*$'),
//         '',
//       );
//       if (formattedNativeBalance.endsWith('.')) {
//         formattedNativeBalance = formattedNativeBalance.substring(
//           0,
//           formattedNativeBalance.length - 1,
//         );
//       }
//     }

//     return Scaffold(
//       backgroundColor: Theme.of(
//         context,
//       ).colorScheme.background, // Apply light background
//       // AppBar style similar to image - simple with icons
//       appBar: AppBar(
//         backgroundColor: Theme.of(
//           context,
//         ).colorScheme.background, // Match background
//         elevation: 0, // No shadow
//         // AppBar title removed to match image layout
//         leading: isConnected
//             ? Builder(
//                 // Show drawer icon only when connected
//                 builder: (context) => IconButton(
//                   icon: const Icon(Icons.menu), // Standard menu icon for drawer
//                   onPressed: () => Scaffold.of(context).openDrawer(),
//                 ),
//               )
//             : null, // No leading icon when not connected
//       ),
//       drawer: isConnected
//           ? Drawer(
//               // Add Drawer when connected
//               child: ListView(
//                 padding: EdgeInsets.zero,
//                 children: [
//                   DrawerHeader(
//                     decoration: BoxDecoration(
//                       color: Theme.of(context).colorScheme.inversePrimary,
//                     ),
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Wallet Settings',
//                           style: TextStyle(
//                             fontSize: 20,
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.onInverseSurface,
//                           ),
//                         ),
//                         SizedBox(height: 8),
//                         Text(
//                           'Status: ${walletService.status.name}',
//                           style: TextStyle(
//                             fontSize: 14,
//                             color: Theme.of(
//                               context,
//                             ).colorScheme.onInverseSurface,
//                           ),
//                         ),
//                         if (walletService.connectedAddress != null)
//                           Text(
//                             'Address: ${walletService.connectedAddress!.substring(0, 6)}...',
//                             style: TextStyle(
//                               fontSize: 12,
//                               color: Theme.of(
//                                 context,
//                               ).colorScheme.onInverseSurface,
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.refresh),
//                     title: Text('Refresh STARS Balance'),
//                     onTap: enableTxActions
//                         ? walletService.getStarsBalance
//                         : null,
//                     enabled:
//                         enableTxActions, // Enable only when connected to Sepolia
//                   ),
//                   ListTile(
//                     leading: Icon(Icons.token), // Or a custom STARS icon
//                     title: Text('Add STARS Token to Wallet'),
//                     onTap: enableTxActions
//                         ? walletService.addStarsTokenToWallet
//                         : null,
//                     enabled:
//                         enableTxActions, // Enable only when connected to Sepolia
//                   ),
//                   // Note: Approve is a specific action, maybe less common for a general setting?
//                   // Leaving it off the main drawer for simplicity based on image,
//                   // but could add it back if needed.
//                   ListTile(
//                     leading: Icon(
//                       Icons.logout,
//                     ), // Standard logout/disconnect icon
//                     title: Text('Disconnect'),
//                     // Call disconnect method in the service
//                     onTap:
//                         isConnected // Enable only when AppKit reports connected
//                         ? () {
//                             _disconnectWallet(context); // Call service method
//                             Navigator.pop(context); // Close drawer
//                           }
//                         : null,
//                     enabled: isConnected, // Enable only when connected
//                   ),
//                 ],
//               ),
//             )
//           : null, // No drawer when not connected
//       body: !isConnected
//           ? Center(
//               // Show welcome message and connect button when not connected
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Text(
//                     'Welcome to the Secure Wallet',
//                     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 20),
//                   Text(
//                     'Connect your wallet to get started.',
//                     style: TextStyle(fontSize: 16, color: Colors.grey[700]),
//                     textAlign: TextAlign.center,
//                   ),
//                   SizedBox(height: 30),
//                   // AppKitModalConnectButton handles the connection logic
//                   // AppKitModalConnectButton(
//                   //   appKit: walletService.appKitModal,
//                   //   context: context,
//                   // ),
//                   ElevatedButton(
//                     onPressed: () => _connectWallet(context),
//                     child: Padding(
//                       padding: const EdgeInsets.symmetric(
//                         horizontal: 16.0,
//                         vertical: 12.0,
//                       ),
//                       child: Text(
//                         'Connect Wallet',
//                         style: TextStyle(fontSize: 18),
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 20),
//                   // Show initialization/connection status if needed
//                   if (walletService.status == ReownAppKitModalStatus.error)
//                     Text(
//                       'Connection failed.',
//                       style: TextStyle(
//                         fontStyle: FontStyle.italic,
//                         color: Colors.red,
//                       ),
//                     ),
//                   SizedBox(height: 20),
//                   // Show initialization status if needed
//                   if (walletService.status ==
//                       ReownAppKitModalStatus.initializing)
//                     Text(
//                       'Initializing wallet service...',
//                       style: TextStyle(fontStyle: FontStyle.italic),
//                     ),
//                   if (walletService.status == ReownAppKitModalStatus.error)
//                     Text(
//                       'Initialization failed.',
//                       style: TextStyle(
//                         fontStyle: FontStyle.italic,
//                         color: Colors.red,
//                       ),
//                     ),
//                 ],
//               ),
//             )
//           : SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 16.0,
//                 vertical: 8.0,
//               ), // Adjust padding
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 crossAxisAlignment: CrossAxisAlignment.stretch,
//                 children: [
//                   SizedBox(height: 8),

//                   Card(
//                     margin:
//                         EdgeInsets.zero, // No margin if using outside padding
//                     elevation: 1.0, // Subtle elevation
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(12.0),
//                     ), // Rounded corners
//                     child: Padding(
//                       padding: const EdgeInsets.all(16.0),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // Row for STARS token balance
//                           Row(
//                             children: [
//                               // Placeholder icon for STARS (replace with actual asset if available)
//                               CircleAvatar(
//                                 backgroundColor: Colors.deepPurple.shade100,
//                                 radius: 18,
//                                 child: Text(
//                                   walletService.starsTokenSymbol[0],
//                                   style: TextStyle(
//                                     fontWeight: FontWeight.bold,
//                                     color: Colors.deepPurple,
//                                   ),
//                                 ),
//                                 // Or use a custom image asset:
//                                 // backgroundImage: AssetImage('assets/stars_icon.png'),
//                               ),
//                               SizedBox(width: 12),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Row(
//                                       children: [
//                                         Icon(
//                                           Icons.star,
//                                           color: Colors.amber[700],
//                                           size: 20,
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text(
//                                           '$formattedStarsBalance ${walletService.starsTokenSymbol}', // Use service symbol
//                                           style: TextStyle(fontSize: 16),
//                                         ),
//                                       ],
//                                     ),
//                                     SizedBox(height: 4),
//                                     Row(
//                                       children: [
//                                         Icon(
//                                           Icons.account_balance_wallet_outlined,
//                                           color: Colors.blueGrey,
//                                           size: 20,
//                                         ),
//                                         SizedBox(width: 8),
//                                         Text(
//                                           '${formattedNativeBalance} ${walletService.connectedNetwork?.currency ?? "Native"}', // Use service state for currency symbol
//                                           style: TextStyle(fontSize: 16),
//                                         ),
//                                       ],
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ),
//                   SizedBox(height: 30), // Space before transactions
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceAround,
//                     children: [
//                       _buildActionButton(
//                         icon: Icons.shopping_cart,
//                         label: 'Buy',
//                         onPressed: enableBuyButton ? _showBuyStarsModal : null,
//                       ),
//                       SizedBox(width: 8), // Space between buttons
//                       _buildActionButton(
//                         icon: Icons.card_giftcard,
//                         label: 'Gift',
//                         onPressed: enableGiftButton
//                             ? _showStarReactionModal
//                             : null,
//                       ),
//                       SizedBox(width: 8), // Space between buttons
//                     ],
//                   ),
//                   SizedBox(height: 30), // More space after buttons
//                   const Padding(
//                     padding: EdgeInsets.only(bottom: 10.0),
//                     child: Text(
//                       'Recent STARS Transactions (Sepolia):',
//                       style: TextStyle(
//                         fontWeight: FontWeight.bold,
//                         fontSize: 16,
//                       ),
//                       textAlign: TextAlign.center, // Center the header
//                     ),
//                   ),

//                   Align(
//                     alignment: Alignment.centerRight,
//                     child: IconButton(
//                       icon: Icon(
//                         Icons.refresh,
//                         color: enableRefreshTransactionsButton
//                             ? Colors.blue
//                             : Colors.grey,
//                       ),
//                       tooltip: 'Refresh Transactions',
//                       onPressed: enableRefreshTransactionsButton
//                           ? walletService.fetchTokenTransactions
//                           : null,
//                     ),
//                   ),
//                   SizedBox(height: 8),

//                   // Display status or list
//                   if (walletService.transactionListStatus.isNotEmpty)
//                     Center(
//                       child: Padding(
//                         padding: const EdgeInsets.symmetric(vertical: 8.0),
//                         child: Text(
//                           walletService.transactionListStatus,
//                           textAlign: TextAlign.center,
//                           style: TextStyle(
//                             color:
//                                 walletService.transactionListStatus.contains(
//                                   'Error',
//                                 )
//                                 ? Colors.red
//                                 : (walletService.transactionListStatus.contains(
//                                         'Loading',
//                                       )
//                                       ? Colors.orange
//                                       : Colors.grey[700]),
//                             fontStyle:
//                                 walletService.transactionListStatus.contains(
//                                   'Loading',
//                                 )
//                                 ? FontStyle.italic
//                                 : null,
//                           ),
//                         ),
//                       ),
//                     )
//                   else if (walletService.transactions.isEmpty &&
//                       !walletService.isLoadingTransactions)
//                     // Show 'No transactions' only if not loading and list is empty
//                     const Center(child: Text('No recent transactions found.'))
//                   else if (walletService.transactions.isNotEmpty)
//                     // Use a Column to list transaction items
//                     Column(
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: walletService.transactions.map((tx) {
//                         // Ensure connectedAddress is not null before building item
//                         final currentAddress = walletService.connectedAddress;
//                         if (currentAddress == null)
//                           return SizedBox.shrink(); // Should not happen here if isConnected is true
//                         return _buildTransactionItem(
//                           tx,
//                           currentAddress,
//                           walletService,
//                         );
//                       }).toList(),
//                     ),
//                   SizedBox(height: 40), // Final spacing
//                 ],
//               ),
//             ),
//     );
//   }
// }
