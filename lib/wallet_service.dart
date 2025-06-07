// // import 'dart:convert';

// // import 'package:decimal/decimal.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart' show rootBundle;
// // import 'package:http/http.dart';
// // import 'package:my_secure_wallet_app/token.dart';
// // import 'package:reown_appkit/modal/i_appkit_modal_impl.dart';
// // import 'package:reown_appkit/reown_appkit.dart';

// // const String _etherscanApiKey =
// //     'DUGGC885HI87T28EAFB4WECBS57X1JGQKN'; // !! Replace with your actual key or use a secure method !!

// // // Ensure you have a valid Etherscan API key. If not, transactions will fail.
// // // const String _etherscanApiKey = 'YOUR_ETHERSCAN_API_KEY';

// // const double _STARS_PER_NATIVE_TOKEN = 100.0;
// // const double _NATIVE_PER_STAR = 1.0 / _STARS_PER_NATIVE_TOKEN;

// // class WalletService extends ChangeNotifier {
// //   // --- AppKitModal Instance ---
// //   late ReownAppKitModal? _appKitModal;
// //   bool _isInitialized = false; // Flag to prevent double initialization

// //   // --- State Variables (Keep private and expose via getters) ---
// //   ReownAppKitModalStatus _status = ReownAppKitModalStatus.idle;
// //   ReownAppKitModalNetworkInfo? _connectedNetwork;
// //   ReownAppKitModalSession? _currentSession;
// //   String? _connectedAddress;
// //   String? _connectedWalletName;
// //   BigInt _currentNativeBalanceWei = BigInt.zero; // Fetched via RPC
// //   BigInt _currentStarsBalanceWei = BigInt.zero; // Fetched via Contract Read
// //   String _starsBalanceDisplay =
// //       'Connect to see balance'; // Formatted display string

// //   // Contract Details (Move from UI)
// //   final String _sepoliaChainId = 'eip155:11155111';
// //   final String _starsTokenAddress =
// //       '0x185239e90BBb3810c27671aaCFA7d9b3c26Da22C'; // Example Sepolia Token Address
// //   final String _starsPlatformAddress =
// //       '0xA14536b87f485F266560b218f6f19D0eCAB070d1'; // Example Sepolia Platform Address
// //   final int _starsTokenDecimals = 18;
// //   final String _starsTokenSymbol = 'STR';

// //   // Deployed Contracts
// //   DeployedContract? _starsTokenContract;
// //   DeployedContract? _starsPlatformContract;
// //   bool _areContractsLoaded = false; // Flag for ABI loading status

// //   // Transaction/Action Status
// //   String _transactionStatus = 'Ready.'; // General status for user actions

// //   // Transaction List State
// //   List<TokenTransaction> _transactions = [];
// //   bool _isLoadingTransactions = false;
// //   String _transactionListStatus =
// //       'Connect to see transactions'; // Status for the list area

// //   // Flag to track if initial data fetch has been attempted for the current Sepolia connection
// //   bool _hasFetchedInitialData = false;

// //   // --- Getters to Expose State to UI ---
// //   ReownAppKitModal get appKitModal => _appKitModal!; // Expose the modal instance
// //   ReownAppKitModalStatus get status => _status;
// //   bool get isConnected =>
// //       _status == ReownAppKitModalStatus.initialized && _currentSession != null;
// //   ReownAppKitModalNetworkInfo? get connectedNetwork => _connectedNetwork;
// //   ReownAppKitModalSession? get currentSession => _currentSession;
// //   String? get connectedAddress => _connectedAddress;
// //   String? get connectedWalletName => _connectedWalletName;
// //   BigInt get currentNativeBalanceWei => _currentNativeBalanceWei;
// //   BigInt get currentStarsBalanceWei => _currentStarsBalanceWei;
// //   String get starsBalanceDisplay => _starsBalanceDisplay;

// //   String get sepoliaChainId => _sepoliaChainId;
// //   String get starsTokenAddress => _starsTokenAddress;
// //   String get starsPlatformAddress => _starsPlatformAddress;
// //   int get starsTokenDecimals => _starsTokenDecimals;
// //   String get starsTokenSymbol => _starsTokenSymbol;

// //   bool get areContractsLoaded => _areContractsLoaded;

// //   String get transactionStatus => _transactionStatus;
// //   // Setter for transactionStatus if other parts of the service need to update it
// //   set transactionStatus(String status) {
// //     if (_transactionStatus != status) {
// //       _transactionStatus = status;
// //       notifyListeners();
// //     }
// //   }

// //   List<TokenTransaction> get transactions => _transactions;
// //   bool get isLoadingTransactions => _isLoadingTransactions;
// //   String get transactionListStatus => _transactionListStatus;

// //   // Conversion Rates (expose as getters)
// //   double get starsPerNativeToken => _STARS_PER_NATIVE_TOKEN;
// //   double get nativePerStar => _NATIVE_PER_STAR;

// //   // Helper getter to check if we are connected to Sepolia and have loaded contracts
// //   bool get _isSepoliaAndReady {
// //     return isConnected &&
// //         _connectedNetwork?.chainId == _sepoliaChainId &&
// //         _connectedAddress != null &&
// //         _currentSession != null &&
// //         _areContractsLoaded;
// //   }

// //   // --- Initialization ---
// //   Future<void> init(BuildContext context) async {
// //     print('WalletService: Starting initialization...');
// //     if (_isInitialized) {
// //       print('WalletService: Already initialized, skipping.');
// //       return;
// //     }

// //     print('WalletService: Creating AppKitModal instance...');
// //     _appKitModal = ReownAppKitModal(
// //       context: context,
// //       projectId:
// //           'ccf4925f727ee0d480bb502cce820edf', // Replace with your Project ID
// //       metadata: const PairingMetadata(
// //         name: 'Secure Wallet App', // App Name
// //         description: 'A secure wallet application', // App Description
// //         url: 'https://reown.com/', // Your Website URL
// //         icons: ['https://reown.com/logo.png'], // Your App Icon URL
// //         redirect: Redirect(
// //           native: 'mysecurewalletapp://', // Your app's deep link scheme
// //           universal:
// //               'https://reown.com/mysecurewalletapp', // Your universal link
// //         ),
// //       ),
// //       requiredNamespaces: {
// //         'eip155': RequiredNamespace(
// //           chains: [_sepoliaChainId], // Specify required chains
// //           methods: [
// //             'eth_sendTransaction',
// //             'eth_signTypedData_v4',
// //             'personal_sign',
// //             'eth_call', // Required for read calls
// //             'wallet_switchEthChain',
// //             'wallet_addEthChain',
// //             'wallet_watchAsset', // Required for add token
// //           ],
// //           events: ['chainChanged', 'accountsChanged'],
// //         ),
// //       },
// //       logLevel: LogLevel.debug,
// //     );

// //     print('WalletService: Adding listeners...');
// //     // Add _updateState listener first, it reacts to core AppKitModal state changes
// //     _appKitModal!.addListener(_updateState);
// //     // Add _updateNativeBalance listener for native balance changes
// //     _appKitModal!.balanceNotifier.addListener(_updateNativeBalance);
// //     // Add error listener
// //     _appKitModal!.onModalError.subscribe(_handleModalError);

// //     try {
// //       print('WalletService: Initializing AppKitModal...');
// //       await _appKitModal!.init();
// //       _isInitialized = true;
// //       print('WalletService: AppKitModal initialized successfully.');

// //       // Start loading contracts asynchronously, but don't block init()
// //       // _updateState will handle the state transition when contracts are loaded
// //       await _loadContractAbis();

// //       // Do NOT call _updateState() explicitly here.
// //       // AppKitModal.init() will trigger its listeners internally when ready.
// //     } catch (e, s) {
// //       print('WalletService: Error during AppKitModal initialization: $e\n$s');
// //       _status = ReownAppKitModalStatus.error;
// //       _transactionListStatus = 'Initialization failed.';
// //       _transactionStatus = 'Initialization failed.';
// //       _starsBalanceDisplay = 'Initialization failed.';
// //       _areContractsLoaded = false;
// //       notifyListeners();
// //       // Broadcast a modal error for UI feedback
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError(
// //           "Failed to initialize wallet service. Check console for details.",
// //         ),
// //       );
// //     }
// //   }

// //   // This listener reacts to *any* state change in AppKitModal
// //   void _updateState() {
// //     print(
// //       'WalletService: _updateState called. AppKitModal Status: ${_appKitModal!.status}, isConnected: ${_appKitModal!.isConnected}',
// //     );
// //     print('WalletService: Current Sepolia target chainId: $_sepoliaChainId');

// //     // Capture the new state from AppKitModal properties
// //     final newStatus = _appKitModal!.status;
// //     final bool newIsConnected = _appKitModal!.isConnected;
// //     final ReownAppKitModalSession? newSession = _appKitModal!.session;
// //     final ReownAppKitModalNetworkInfo? newConnectedNetwork =
// //         _appKitModal!.selectedChain;

// //     String? newConnectedAddress =
// //         _connectedAddress; // Keep current unless updated
// //     String? newConnectedWalletName =
// //         _connectedWalletName; // Keep current unless updated

// //     // Determine if the *relevant* connected state has changed
// //     final bool wasConnectedAndReady =
// //         _isSepoliaAndReady; // State before this update
// //     bool isConnectedNow = false;

// //     if (newIsConnected && newSession != null && newConnectedNetwork != null) {
// //       isConnectedNow = true; // Wallet is connected to *some* network

// //       final namespace = NamespaceUtils.getNamespaceFromChain(
// //         newConnectedNetwork.chainId,
// //       );

// //       try {
// //         newConnectedAddress = newSession.getAddress(namespace);
// //       } catch (e) {
// //         print(
// //           "WalletService: Could not get address for namespace $namespace: $e",
// //         );
// //         newConnectedAddress = null; // Reset address if it fails
// //       }

// //       newConnectedWalletName =
// //           newSession.peer?.metadata.name ??
// //           newSession.sessionEmail ??
// //           newSession.sessionUsername ??
// //           'Unknown Wallet';

// //       print(
// //         'WalletService: Wallet connected. Chain: ${newConnectedNetwork.chainId}, Address: $newConnectedAddress, Wallet: $newConnectedWalletName',
// //       );

// //       // Update internal state variables
// //       _currentSession = newSession;
// //       _connectedNetwork = newConnectedNetwork;
// //       _connectedAddress = newConnectedAddress;
// //       _connectedWalletName = newConnectedWalletName;
// //     } else {
// //       // Wallet is now disconnected
// //       print("WalletService: Wallet is NOT connected.");
// //       isConnectedNow = false; // Explicitly set to false

// //       // Clear all session/connection specific state
// //       _currentSession = null;
// //       _connectedNetwork = null;
// //       _connectedAddress = null;
// //       _connectedWalletName = null;

// //       // Reset Sepolia-specific UI and data state
// //       _starsBalanceDisplay = 'Connect to see balance';
// //       _transactionStatus = 'Connect to transact';
// //       _transactions = []; // Clear transactions
// //       _transactionListStatus = 'Connect to see transactions';
// //       _currentNativeBalanceWei = BigInt.zero; // Reset balance
// //       _currentStarsBalanceWei = BigInt.zero; // Reset balance
// //       _hasFetchedInitialData = false; // Reset fetch flag on disconnect
// //       // Keep contracts loaded state unless disposing (_areContractsLoaded)
// //       // But actions depending on Sepolia + Contracts will be disabled by _isSepoliaAndReady check
// //     }

// //     // Update the status last
// //     _status = newStatus;

// //     // Determine if we are now in the "Sepolia and Ready" state
// //     final bool isNowConnectedAndReady =
// //         _isSepoliaAndReady; // State after this update

// //     // --- Handle State Transitions and Data Fetching ---

// //     // Case 1: Transitioning *into* the Sepolia+Ready state for the first time in this session
// //     if (isNowConnectedAndReady &&
// //         !wasConnectedAndReady &&
// //         !_hasFetchedInitialData) {
// //       print(
// //         "WalletService: Transitioned to Sepolia+Ready state. Triggering initial data fetch.",
// //       );
// //       // Use Future.delayed(Duration.zero) to ensure this runs after all listeners
// //       // have processed the current state update, preventing potential re-entrancy issues.
// //       Future.delayed(Duration.zero, () {
// //         // Double-check state before fetching in case it changed again very quickly
// //         if (_isSepoliaAndReady && !_hasFetchedInitialData) {
// //           _fetchInitialData();
// //         } else {
// //           print(
// //             "WalletService: State changed again before initial fetch could run.",
// //           );
// //         }
// //       });
// //       // Set loading status immediately while waiting for the scheduled fetch
// //       _starsBalanceDisplay = 'Loading...';
// //       _transactionListStatus = 'Loading...';
// //       _transactionStatus = 'Connected to Sepolia. Loading data...';
// //     } else if (isNowConnectedAndReady && _hasFetchedInitialData) {
// //       // Case 2: Already in the Sepolia+Ready state and data was fetched.
// //       // Status messages should reflect operational state (e.g., 'Ready')
// //       // unless individual fetch calls update them to 'Loading...' or 'Error'.
// //       if (_transactionStatus.contains('Loading') ||
// //           _transactionStatus.contains('Error')) {
// //         // Don't overwrite specific loading/error messages from fetches
// //       } else {
// //         _transactionStatus = 'Ready to transact on Sepolia.';
// //       }
// //       if (_transactionListStatus.contains('Loading') ||
// //           _transactionListStatus.contains('Error')) {
// //         // Don't overwrite specific loading/error messages from fetches
// //       } else if (_transactions.isEmpty) {
// //         _transactionListStatus = 'No recent STARS transactions found.';
// //       } else {
// //         _transactionListStatus = ''; // Clear status if list is populated
// //       }
// //       // starsBalanceDisplay is managed by getStarsBalance()
// //     } else if (isConnectedNow &&
// //         newConnectedNetwork?.chainId != _sepoliaChainId) {
// //       // Case 3: Connected to a network, but NOT Sepolia
// //       print(
// //         "WalletService: Connected to a network other than Sepolia (Chain: ${newConnectedNetwork?.chainId}).",
// //       );
// //       _starsBalanceDisplay = 'Switch wallet to Sepolia to see balance';
// //       _transactionStatus = 'Switch wallet to Sepolia to transact';
// //       _transactions = []; // Clear Sepolia transactions
// //       _transactionListStatus = 'Switch wallet to Sepolia to see transactions';
// //       _currentNativeBalanceWei = BigInt.zero; // Reset Sepolia-specific balance
// //       _currentStarsBalanceWei = BigInt.zero; // Reset Sepolia-specific balance
// //       _hasFetchedInitialData = false; // Reset fetch flag
// //       // _areContractsLoaded remains true if ABIs were loaded, but contract *actions* are disabled by chainId check
// //     } else if (!isConnectedNow) {
// //       // Case 4: Not connected at all (handled in the initial disconnection logic)
// //       // Statuses are already set to 'Connect...' messages above.
// //     }

// //     print('WalletService: Notifying listeners of state change');
// //     notifyListeners();
// //   }

// //   // Method called by UI to disconnect
// //   Future<void> disconnect() async {
// //     print('WalletService: Requesting disconnect...');
// //     if (_appKitModal == null) {
// //       print(
// //         'WalletService: AppKitModal instance is null, nothing to disconnect.',
// //       );
// //       // Already disconnected state, just ensure UI reflects idle
// //       if (_status != ReownAppKitModalStatus.idle) {
// //         _status = ReownAppKitModalStatus.idle;
// //         notifyListeners();
// //       }
// //       return;
// //     }

// //     if (!_appKitModal!.isConnected) {
// //       print('WalletService: App is not connected, performing cleanup.');
// //       await _performLocalCleanup(); // Clean up even if not formally 'connected'
// //       return;
// //     }

// //     _status = ReownAppKitModalStatus.idle;
// //     _transactionStatus = 'Disconnecting...';
// //     notifyListeners(); // Update UI status

// //     try {
// //       print('WalletService: Calling appKitModal.disconnect()...');
// //       await _appKitModal!.disconnect();
// //       print('WalletService: appKitModal.disconnect() returned.');
// //       // _updateState listener will now handle the state change to disconnected
// //       // and trigger _performLocalCleanup.
// //     } catch (e, s) {
// //       print('WalletService: Error during disconnect request: $e\n$s');
// //       _transactionStatus = 'Error during disconnect.';
// //       // Proceed with local cleanup even if remote disconnect failed
// //       await _performLocalCleanup();
// //       // Decide if you want to broadcast a modal error for disconnect issues
// //       _appKitModal?.onModalError.broadcast(
// //         ModalError('Failed to disconnect properly.'),
// //       );
// //     } finally {
// //       // notifyListeners() will be called by _performLocalCleanup
// //     }
// //   }

// //   // Perform local cleanup - dispose modal, reset state
// //   Future<void> _performLocalCleanup() async {
// //     print('WalletService: Performing local cleanup...');

// //     // Remove listeners first
// //     print('WalletService: Removing listeners...');
// //     _appKitModal!.removeListener(_updateState);
// //     _appKitModal!.balanceNotifier.removeListener(_updateNativeBalance);
// //     _appKitModal!.onModalError.unsubscribe(_handleModalError);

// //     // Dispose the modal instance
// //     print('WalletService: Disposing AppKitModal instance...');
// //     _appKitModal!.dispose();
// //     _appKitModal = null; // Set to null

// //     // Reset all service state variables related to connection/session
// //     print('WalletService: Resetting service state...');
// //     _status = ReownAppKitModalStatus.idle; // Set final status
// //     _connectedNetwork = null;
// //     _currentSession = null;
// //     _connectedAddress = null;
// //     _connectedWalletName = null;
// //     _currentNativeBalanceWei = BigInt.zero;
// //     _currentStarsBalanceWei = BigInt.zero;
// //     _starsBalanceDisplay = 'Connect to see balance';
// //     _transactionStatus = 'Ready.'; // Or 'Connect to transact'
// //     _transactions = []; // Clear transactions
// //     _transactionListStatus = 'Connect to see transactions';
// //     _hasFetchedInitialData = false; // Reset fetch flag

// //     print('WalletService: Local cleanup complete.');
// //     notifyListeners(); // Notify UI after cleanup
// //   }

// //   // Helper to trigger initial data fetches when state is ready
// //   void _fetchInitialData() {
// //     if (_hasFetchedInitialData) {
// //       print(
// //         "WalletService: _fetchInitialData called but flag already true. Skipping.",
// //       );
// //       return; // Prevent re-triggering within the same session
// //     }
// //     print(
// //       "WalletService: Calling _fetchInitialData(). Setting flag and status.",
// //     );
// //     _hasFetchedInitialData = true;

// //     // Set loading statuses immediately
// //     _starsBalanceDisplay = 'Fetching balance...';
// //     _transactionListStatus = 'Fetching transactions...';
// //     _transactionStatus = 'Fetching data...';
// //     notifyListeners(); // Notify UI to show these initial loading states

// //     _updateNativeBalance();
// //     // Fetch the data asynchronously
// //     getStarsBalance(); // This will update _starsBalanceDisplay and call notifyListeners()
// //     fetchTokenTransactions(); // This will update _transactionListStatus and call notifyListeners()

// //     // Note: _updateNativeBalance is triggered by the balanceNotifier listener,
// //     // which should fire automatically upon session connection and changes.
// //   }

// //   void _updateNativeBalance() async {
// //     print("WalletService: _updateNativeBalance triggered by balanceNotifier.");

// //     if (!isConnected ||
// //         _connectedNetwork?.chainId != _sepoliaChainId ||
// //         _connectedAddress == null ||
// //         _currentSession == null) {
// //       print(
// //         "WalletService: _updateNativeBalance skipped - not connected to Sepolia or missing data.",
// //       );
// //       // If we are not connected to Sepolia, native balance isn't relevant for Sepolia context
// //       // The core state update in _updateState handles resetting the balance display
// //       // However, if this listener fires *after* disconnect but before _updateState resets,
// //       // ensure we don't try to set a non-zero Sepolia balance.
// //       if (_currentNativeBalanceWei != BigInt.zero) {
// //         _currentNativeBalanceWei = BigInt.zero;
// //         notifyListeners(); // Notify if balance reset
// //       }
// //       return; // Exit early
// //     }

// //     // No need to explicitly call eth_getBalance via request here,
// //     // as _appKitModal.balanceNotifier should provide the updated balance.
// //     // We just need to update our internal state and potentially display it.
// //     // The AppKitModal's listener on `balanceNotifier` already updates
// //     // its internal native balance state. We are *this* listener,
// //     // reacting to AppKitModal telling us *its* balance changed.

// //     // Assuming AppKitModal updates its internal state and then notifies *us*.
// //     // We might need a way to *get* the latest native balance from AppKitModal here.
// //     // If AppKitModal doesn't expose the raw balance, the current logic of fetching
// //     // it manually via RPC request in _updateNativeBalance (as you had it) is needed.
// //     // Reverting the manual fetch logic inside _updateNativeBalance:

// //     print(
// //       "WalletService: _updateNativeBalance fetching raw balance via RPC...",
// //     );

// //     try {
// //       final address = EthereumAddress.fromHex(_connectedAddress!);
// //       final topic = _currentSession?.topic;

// //       if (topic == null) {
// //         print(
// //           "WalletService: _updateNativeBalance skipped - session topic is null.",
// //         );
// //         if (_currentNativeBalanceWei != BigInt.zero) {
// //           _currentNativeBalanceWei = BigInt.zero;
// //           notifyListeners(); // Notify if balance reset
// //         }
// //         return; // Exit if topic is null
// //       }

// //       // Explicitly request the balance
// //       final dynamic result = await _appKitModal!.request(
// //         topic: topic,
// //         chainId: _sepoliaChainId,
// //         request: SessionRequestParams(
// //           method: 'eth_getBalance',
// //           params: [address.hex, 'latest'],
// //         ),
// //       );

// //       if (result is String && result.startsWith('0x')) {
// //         final balance = BigInt.parse(result.substring(2), radix: 16);
// //         if (_currentNativeBalanceWei != balance) {
// //           _currentNativeBalanceWei = balance;
// //           print(
// //             "WalletService: Native balance updated via RPC: $_currentNativeBalanceWei wei",
// //           );
// //           // No need to notify here, the finally block handles it
// //         } else {
// //           print("WalletService: Native balance fetched but unchanged.");
// //         }
// //       } else {
// //         print(
// //           "WalletService: Unexpected result format from eth_getBalance: $result",
// //         );
// //         if (_currentNativeBalanceWei != BigInt.zero) {
// //           _currentNativeBalanceWei = BigInt.zero;
// //           // No need to notify here, the finally block handles it
// //         } else {
// //           print(
// //             "WalletService: Native balance result unexpected but was already zero.",
// //           );
// //         }
// //       }
// //     } catch (e, s) {
// //       print("WalletService: Error updating native balance via RPC: $e\n$s");
// //       if (_currentNativeBalanceWei != BigInt.zero) {
// //         _currentNativeBalanceWei = BigInt.zero;
// //         // No need to notify here, the finally block handles it
// //       }
// //       // Don't necessarily broadcast a modal error for background balance updates
// //     } finally {
// //       // Always notify listeners at the end of the async operation
// //       notifyListeners();
// //     }
// //   }

// //   // Handle errors from AppKitModal
// //   void _handleModalError(ModalError? event) {
// //     print('WalletService: AppKit Modal Error: ${event?.message}');
// //     // Decide if you want to show a Snackbar or other UI element here based on the error
// //     // Example:
// //     // if (event?.message != null && event?.message.isNotEmpty == true) {
// //     //   // Show a snackbar or update a state variable to display the error in the UI
// //     // }
// //     notifyListeners(); // Ensure UI can react to error status changes
// //   }

// //   // Helper to check if an error is likely a user rejecting the request
// //   bool _isUserRejectedError(dynamic e) {
// //     // Check standard RPC error codes for user rejection (e.g., 4001)
// //     // and common error message patterns.
// //     final regexp = RegExp(
// //       r'\b(rejected|cancelled|disapproved|denied|User canceled|User denied)\b',
// //       caseSensitive: false,
// //     );

// //     if (e is JsonRpcError) {
// //       // Standard EIP-1193 user rejected request code
// //       if (e.code == 4001) return true;
// //       // WalletConnect specific rejection codes (often in 5000-5999 range)
// //       if (e.code != null && e.code! >= 5000 && e.code! < 6000) {
// //         return true; // WalletConnect errors are often user-initiated or network issues
// //       }
// //       // Check message for patterns even if code isn't standard
// //       if (e.message != null && regexp.hasMatch(e.message!)) {
// //         return true;
// //       }
// //     }
// //     // AppKit-specific error types (if any)
// //     if (e is UserRejectedRequest) return true;

// //     // Check the error string representation as a fallback
// //     return regexp.hasMatch(e.toString());
// //   }

// //   // --- Contract Loading ---
// //   Future<void> _loadContractAbis() async {
// //     print('WalletService: Starting to load ABIs...');
// //     _areContractsLoaded = false; // Set loading state for contracts
// //     // Status messages are already handled by _updateState's initial checks

// //     try {
// //       // Load and parse ABIs
// //       print('WalletService: Loading StarsToken.json...');
// //       final starsTokenAbiString = await rootBundle.loadString(
// //         'assets/abis/StarsToken.json',
// //       );
// //       print('WalletService: Loading StarsPlatform.json...');
// //       final starsPlatformAbiString = await rootBundle.loadString(
// //         'assets/abis/StarsPlatform.json',
// //       );

// //       final starsTokenAbiJson = jsonDecode(starsTokenAbiString);
// //       final starsPlatformAbiJson = jsonDecode(starsPlatformAbiString);

// //       final starsTokenAbiArray = starsTokenAbiJson['abi'];
// //       final starsPlatformAbiArray = starsPlatformAbiJson['abi'];

// //       if (starsTokenAbiArray == null ||
// //           starsPlatformAbiArray == null ||
// //           starsTokenAbiArray is! List ||
// //           starsPlatformAbiArray is! List) {
// //         print('WalletService: ABI validation failed: JSON structure invalid.');
// //         throw Exception(
// //           "ABI JSON is not structured as expected (missing 'abi' key or not an array)",
// //         );
// //       }

// //       final starsTokenAbi = ContractAbi.fromJson(
// //         jsonEncode(starsTokenAbiArray),
// //         'StarsToken',
// //       );
// //       final starsPlatformAbi = ContractAbi.fromJson(
// //         jsonEncode(starsPlatformAbiArray),
// //         'StarsPlatform',
// //       );

// //       _starsTokenContract = DeployedContract(
// //         starsTokenAbi,
// //         EthereumAddress.fromHex(_starsTokenAddress),
// //       );
// //       _starsPlatformContract = DeployedContract(
// //         starsPlatformAbi,
// //         EthereumAddress.fromHex(_starsPlatformAddress),
// //       );

// //       _areContractsLoaded = true; // Contracts successfully loaded
// //       print('WalletService: Contract ABIs loaded successfully.');

// //       // IMPORTANT: If we successfully loaded contracts *after* the wallet was already connected
// //       // to Sepolia, trigger the initial data fetch now.
// //       if (_isSepoliaAndReady && !_hasFetchedInitialData) {
// //         print(
// //           "WalletService: Contracts loaded AFTER Wallet was ready. Triggering initial data fetch.",
// //         );
// //         // Use Future.delayed(Duration.zero) to yield back before calling fetch
// //         Future.delayed(Duration.zero, () {
// //           // Double-check state before fetching
// //           if (_isSepoliaAndReady && !_hasFetchedInitialData) {
// //             _fetchInitialData();
// //           } else {
// //             print(
// //               "WalletService: State changed again before initial fetch (post-ABI load) could run.",
// //             );
// //           }
// //         });
// //         // Set loading status immediately
// //         _starsBalanceDisplay = 'Loading...';
// //         _transactionListStatus = 'Loading...';
// //         _transactionStatus = 'Contracts loaded. Fetching data...';
// //       } else {
// //         print(
// //           "WalletService: Contracts loaded. Sepolia ready state: $_isSepoliaAndReady, Initial fetch done: $_hasFetchedInitialData.",
// //         );
// //         // State will be updated by _updateState based on connection status
// //         // No need to set specific statuses here unless there was an error
// //       }
// //     } catch (e, s) {
// //       print('WalletService: FATAL ERROR loading or parsing ABIs: $e\n$s');
// //       _areContractsLoaded = false; // Ensure this is false on error
// //       _starsTokenContract = null;
// //       _starsPlatformContract = null;
// //       // Update status messages to reflect the error
// //       _starsBalanceDisplay = 'Error loading contracts';
// //       _transactionStatus = 'Error loading contracts';
// //       _transactionListStatus = 'Error loading contracts';
// //       _currentNativeBalanceWei = BigInt.zero;
// //       _currentStarsBalanceWei = BigInt.zero;
// //       _hasFetchedInitialData = false; // Reset flag

// //       _appKitModal!.onModalError.broadcast(
// //         ModalError('Error loading contract data. Check console for details.'),
// //       );
// //     } finally {
// //       // Always notify listeners after ABI loading attempt (success or failure)
// //       notifyListeners();
// //     }
// //   }

// //   // Helper to convert double Stars amount to BigInt Wei
// //   BigInt starsToWei(double starsAmount) {
// //     if (starsAmount < 0) return BigInt.zero;
// //     final bigDecimal = BigInt.from(10).pow(_starsTokenDecimals);
// //     try {
// //       final starsDecimal = Decimal.parse(starsAmount.toString());
// //       final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
// //       final weiAmountDecimal = starsDecimal * bigDecimalDecimal;
// //       // Rounding is important for accurate BigInt conversion
// //       // Use round(MidpointRounding.toNearestEven) or check requirements
// //       // For simplicity, we'll use standard round(), but be aware of precision.
// //       return BigInt.parse(weiAmountDecimal.round().toString());
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error converting stars $starsAmount to wei: $e\n$s',
// //       );
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError("Conversion Error: Invalid star amount."),
// //       );
// //       return BigInt.zero; // Return zero on conversion error
// //     }
// //   }

// //   // Helper to convert integer Stars amount to BigInt Wei (for gifting)
// //   BigInt starsIntToWei(int starsAmount) {
// //     if (starsAmount < 0) return BigInt.zero;
// //     final bigDecimal = BigInt.from(10).pow(_starsTokenDecimals);
// //     // Directly multiply BigInt for integer amounts
// //     return BigInt.from(starsAmount) * bigDecimal;
// //   }

// //   // Helper to convert BigInt Wei to double Stars (for display)
// //   double weiToStarsDouble(BigInt weiAmount, int decimals) {
// //     if (decimals < 0) decimals = 0; // Handle invalid decimals
// //     final bigDecimal = BigInt.from(10).pow(decimals);
// //     if (bigDecimal == BigInt.zero)
// //       return weiAmount
// //           .toDouble(); // Avoid division by zero if decimals somehow 0

// //     try {
// //       final weiDecimal = Decimal.parse(weiAmount.toString());
// //       final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
// //       // Perform division using Decimal and convert to double
// //       return (weiDecimal / bigDecimalDecimal).toDouble();
// //     } catch (e, s) {
// //       print(
// //         "WalletService: Error converting wei $weiAmount to stars double: $e\n$s",
// //       );
// //       // Don't broadcast error for conversion *for display*, just return 0.0
// //       return 0.0;
// //     }
// //   }

// //   // Helper to convert BigInt Wei to integer Stars (rounding down, for gifting amount input)
// //   int weiToStarsInt(BigInt weiAmount, int decimals) {
// //     if (decimals < 0) decimals = 0;
// //     final bigDecimal = BigInt.from(10).pow(decimals);
// //     if (bigDecimal == BigInt.zero) return 0;
// //     try {
// //       // Integer division
// //       return (weiAmount ~/ bigDecimal).toInt();
// //     } catch (e, s) {
// //       print(
// //         "WalletService: Error converting wei $weiAmount to stars int: $e\n$s",
// //       );
// //       return 0; // Return 0 on error
// //     }
// //   }

// //   // Helper to convert double native amount to BigInt Wei
// //   BigInt nativeDoubleToWei(double amount) {
// //     // Assuming native currency (ETH, MATIC) has 18 decimals - common standard
// //     try {
// //       if (amount < 0) amount = 0;
// //       final decimalAmount = Decimal.parse(amount.toString());
// //       // Standard ETH/native token decimals is 18
// //       final weiFactor = Decimal.parse(BigInt.from(10).pow(18).toString());
// //       final weiAmountDecimal = decimalAmount * weiFactor;
// //       return BigInt.parse(
// //         weiAmountDecimal.round().toString(),
// //       ); // Round and parse as BigInt
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error in nativeDoubleToWei for amount $amount: $e\n$s',
// //       );
// //       // This conversion happens before sending a tx, so error should be user-facing
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError("Conversion Error: Invalid native amount entered."),
// //       );
// //       return BigInt.zero;
// //     }
// //   }

// //   // Helper to convert BigInt Wei to double native currency (for display)
// //   double weiToNativeDouble(BigInt weiAmount) {
// //     // Assuming native currency has 18 decimals - common standard (18 decimals)
// //     final bigDecimal = BigInt.from(10).pow(18);
// //     if (bigDecimal == BigInt.zero)
// //       return weiAmount.toDouble(); // Avoid division by zero

// //     try {
// //       final weiDecimal = Decimal.parse(weiAmount.toString());
// //       final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
// //       // Perform division using Decimal and convert to double
// //       return (weiDecimal / bigDecimalDecimal).toDouble();
// //     } catch (e, s) {
// //       print(
// //         "WalletService: Error converting wei $weiAmount to native double: $e\n$s",
// //       );
// //       // Don't broadcast error for conversion *for display*, just return 0.0
// //       return 0.0;
// //     }
// //   }

// //   // Helper to calculate native token amount needed for a given stars amount
// //   double getNativeAmountForStars(int starsAmount) {
// //     if (starsAmount < 0) return 0.0;
// //     try {
// //       final starsDecimal = Decimal.parse(starsAmount.toString());
// //       final rateDecimal = Decimal.parse(_NATIVE_PER_STAR.toString());
// //       final nativeAmountDecimal = starsDecimal * rateDecimal;
// //       return nativeAmountDecimal.toDouble();
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error calculating native amount for stars $starsAmount: $e\n$s',
// //       );
// //       // Conversion error before a tx, potentially user-facing
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError("Conversion Error: Cannot calculate native cost."),
// //       );
// //       return 0.0;
// //     }
// //   }

// //   // Helper to calculate stars amount for a given native amount
// //   int getStarsAmountForNative(double nativeAmount) {
// //     if (nativeAmount < 0) return 0;
// //     try {
// //       final nativeDecimal = Decimal.parse(nativeAmount.toString());
// //       final rateDecimal = Decimal.parse(_STARS_PER_NATIVE_TOKEN.toString());
// //       final starsAmountDecimal = nativeDecimal * rateDecimal;
// //       // Use floor() as you can only buy whole stars (based on typical tokenomics)
// //       return starsAmountDecimal.floor().toBigInt().toInt();
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error calculating stars for native amount $nativeAmount: $e\n$s',
// //       );
// //       // Conversion error before a tx, potentially user-facing
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError("Conversion Error: Cannot calculate stars amount."),
// //       );
// //       return 0;
// //     }
// //   }

// //   // Fetch STARS Balance (Made Public)
// //   Future<void> getStarsBalance() async {
// //     print("WalletService: Attempting to get STARS balance.");
// //     if (!_isSepoliaAndReady) {
// //       print(
// //         "WalletService: Not ready to get STARS balance. State not Sepolia+Ready.",
// //       );
// //       // Status message should be handled by _updateState or previous fetch attempts
// //       if (!(_starsBalanceDisplay.contains('Loading') ||
// //           _starsBalanceDisplay.contains('Error'))) {
// //         // Only update if it's not already a loading or error state
// //         _starsBalanceDisplay = 'Not connected to Sepolia'; // Or relevant state
// //       }
// //       notifyListeners(); // Ensure state change is reflected
// //       return;
// //     }

// //     // Only show 'Getting balance...' if we ARE connected to Sepolia and attempting to fetch
// //     _starsBalanceDisplay = 'Getting balance...';
// //     notifyListeners(); // Update UI to show loading state

// //     try {
// //       final address = EthereumAddress.fromHex(_connectedAddress!);
// //       final topic = _currentSession?.topic; // Get topic for WC

// //       // Use requestReadContract which is designed for view/pure functions
// //       final result = await _appKitModal!.requestReadContract(
// //         topic: topic,
// //         chainId: _sepoliaChainId,
// //         deployedContract: _starsTokenContract!, // Use the StarsToken contract
// //         functionName: 'balanceOf', // The standard ERC20 balance function
// //         parameters: [address], // The address to check the balance for
// //       );

// //       if (result.isNotEmpty && result[0] is BigInt) {
// //         _currentStarsBalanceWei = result[0] as BigInt;
// //         final balanceDouble = weiToStarsDouble(
// //           _currentStarsBalanceWei,
// //           _starsTokenDecimals,
// //         );
// //         // Display with a reasonable number of decimal places
// //         String formattedBalance = balanceDouble.toStringAsFixed(4);
// //         // Remove trailing zeros and decimal point if only zeros remain
// //         if (formattedBalance.contains('.')) {
// //           formattedBalance = formattedBalance.replaceAll(RegExp(r'0*$'), '');
// //           if (formattedBalance.endsWith('.')) {
// //             formattedBalance = formattedBalance.substring(
// //               0,
// //               formattedBalance.length - 1,
// //             );
// //           }
// //         }

// //         _starsBalanceDisplay = '$formattedBalance $_starsTokenSymbol';
// //         print("WalletService: Fetched STARS balance: $_starsBalanceDisplay");
// //       } else {
// //         _currentStarsBalanceWei = BigInt.zero;
// //         _starsBalanceDisplay = 'Could not parse balance';
// //         print("WalletService: Failed to parse STARS balance result: $result");
// //       }
// //     } catch (e, s) {
// //       print('WalletService: Error getting STARS balance: $e\n$s');
// //       _currentStarsBalanceWei = BigInt.zero;
// //       _starsBalanceDisplay = 'Error fetching balance';
// //       // Read calls usually don't trigger user rejection directly, but RPC errors can happen
// //       // Decide if you want a modal error for a background fetch failure
// //       if (e is JsonRpcError) {
// //         print('WalletService: RPC Error fetching balance: ${e.message}');
// //         // _appKitModal.onModalError.broadcast(ModalError('RPC Error fetching balance: ${e.message ?? "Unknown error"}'));
// //       } else {
// //         print('WalletService: Unknown Error fetching balance: $e');
// //         // _appKitModal.onModalError.broadcast(ModalError('Failed to get balance.'));
// //       }
// //     } finally {
// //       notifyListeners(); // Notify UI after fetch (success or failure)
// //     }
// //   }

// //   // Fetch Token Transactions from Etherscan (Made Public)
// //   Future<void> fetchTokenTransactions() async {
// //     print('WalletService: Starting fetchTokenTransactions...');

// //     if (_etherscanApiKey == 'YOUR_ETHERSCAN_API_KEY' ||
// //         _etherscanApiKey.isEmpty) {
// //       print(
// //         "WalletService: WARNING: Etherscan API key is not set. Cannot fetch transactions.",
// //       );
// //       _transactionListStatus =
// //           'Error: Etherscan API key is missing.'; // Clearer message
// //       _transactions = []; // Clear any old data
// //       _isLoadingTransactions = false; // Stop loading state
// //       notifyListeners(); // Update UI
// //       return; // Stop execution if key is missing
// //     }

// //     if (!_isSepoliaAndReady) {
// //       print(
// //         "WalletService: Not ready to fetch transactions. State not Sepolia+Ready.",
// //       );
// //       // This case is handled by _updateState clearing the list and setting status
// //       if (_transactionListStatus != 'Error: Etherscan API key is missing.' &&
// //           !(_transactionListStatus.contains('Loading') ||
// //               _transactionListStatus.contains('Error'))) {
// //         _transactionListStatus = 'Connect to Sepolia to see transactions.';
// //       }
// //       _transactions = []; // Clear any old data if state is not ready
// //       _isLoadingTransactions = false; // Ensure loading is false
// //       notifyListeners(); // Update UI
// //       return;
// //     }

// //     if (_isLoadingTransactions) {
// //       print("WalletService: Transaction fetch already in progress.");
// //       return; // Prevent multiple concurrent calls
// //     }

// //     _isLoadingTransactions = true;
// //     _transactionListStatus =
// //         'Loading transactions...'; // Indicate loading started
// //     // _transactions = []; // Don't clear immediately, show old data while loading if desired, or clear based on UI preference. Keeping old data might make the UI less jumpy. If clearing is preferred, uncomment this.
// //     notifyListeners(); // Update UI to show loading state

// //     final String apiKey = _etherscanApiKey;
// //     final String address = _connectedAddress!;
// //     final String tokenAddress = _starsTokenAddress;
// //     // Use Sepolia-specific API endpoint
// //     final String baseUrl = 'https://api-sepolia.etherscan.io/api';

// //     try {
// //       final url = Uri.parse(
// //         '$baseUrl?module=account&action=tokentx&contractaddress=$tokenAddress&address=$address&page=1&offset=50&sort=desc&apikey=$apiKey',
// //       );

// //       print('WalletService: Fetching transactions from Etherscan: $url');

// //       final response = await get(url);
// //       print(
// //         'WalletService: Received Etherscan response status code: ${response.statusCode}',
// //       );

// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         print(
// //           'WalletService: Etherscan API response status: ${data['status']}, message: ${data['message']}',
// //         );

// //         if (data['status'] == '1' && data['result'] is List) {
// //           final List resultList = data['result'];
// //           print('WalletService: Processing ${resultList.length} transactions');

// //           // Filter out potential null entries and handle parsing errors gracefully
// //           final List<TokenTransaction> fetchedTransactions = resultList
// //               .where((json) => json != null)
// //               .map((json) {
// //                 try {
// //                   // Provide contract decimals and symbol during parsing
// //                   return TokenTransaction.fromJson(json);
// //                 } catch (e, s) {
// //                   print(
// //                     'WalletService: Error parsing transaction JSON item: $json\nError: $e\nStack: $s',
// //                   );
// //                   return null; // Return null if parsing fails
// //                 }
// //               })
// //               .where((tx) => tx != null) // Filter out nulls
// //               .cast<
// //                 TokenTransaction
// //               >() // Ensure remaining items are TokenTransaction
// //               .toList();

// //           print(
// //             'WalletService: Successfully fetched and parsed ${fetchedTransactions.length} transactions.',
// //           );

// //           _transactions = fetchedTransactions;
// //           if (_transactions.isEmpty) {
// //             _transactionListStatus =
// //                 'No recent STARS transactions found for this address.';
// //           } else {
// //             _transactionListStatus = ''; // Clear status on success with data
// //           }
// //         } else if (data['status'] == '0' &&
// //             data['message'] == 'No transactions found') {
// //           print('WalletService: Etherscan API: No transactions found.');
// //           _transactionListStatus =
// //               'No recent STARS transactions found for this address.';
// //           _transactions = []; // Ensure list is empty
// //         } else {
// //           // Handle other Etherscan API error status ('0') or unexpected format
// //           final errorMessage = data['message'] ?? 'Unknown error';
// //           print(
// //             'WalletService: Etherscan API error/unexpected format (status ${data['status']}): $errorMessage',
// //           );
// //           _transactionListStatus = 'Etherscan API error: $errorMessage';
// //           _transactions = []; // Clear list on API error
// //         }
// //       } else {
// //         // Handle HTTP error status (e.g., 404, 500)
// //         print(
// //           'WalletService: HTTP Error fetching transactions: ${response.statusCode} - ${response.reasonPhrase}',
// //         );
// //         _transactionListStatus =
// //             'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}';
// //         _transactions = []; // Clear list on HTTP error
// //       }
// //     } catch (e, s) {
// //       // Catch any other exceptions (network, json decoding, parsing errors)
// //       print('WalletService: Error fetching or processing transactions: $e\n$s');
// //       _transactionListStatus =
// //           'Failed to fetch transactions: ${e.runtimeType} - ${e.toString()}';
// //       _transactions = []; // Clear list on general error
// //     } finally {
// //       _isLoadingTransactions = false; // Stop loading animation/indicator
// //       notifyListeners(); // Notify UI after fetch attempt (success or failure)
// //     }
// //   }

// //   // Add STARS Token to Wallet
// //   Future<void> addStarsTokenToWallet() async {
// //     print("WalletService: Attempting to add STARS token to wallet.");
// //     if (!_isSepoliaAndReady) {
// //       print("WalletService: Not ready to add STARS token.");
// //       _transactionStatus =
// //           'Error: Wallet not connected to Sepolia or contracts not loaded.';
// //       notifyListeners();
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError('Please connect to Sepolia to add the token.'),
// //       );
// //       return;
// //     }

// //     _transactionStatus = 'Requesting wallet to add STARS token...';
// //     notifyListeners(); // Update UI status

// //     try {
// //       final watchAssetParams = {
// //         'type': 'ERC20',
// //         'options': {
// //           'address': _starsTokenAddress,
// //           'symbol': _starsTokenSymbol,
// //           'decimals': _starsTokenDecimals,
// //           // 'image': 'URL_TO_YOUR_TOKEN_LOGO', // Optional: Add your token logo URL
// //         },
// //       };

// //       // Use AppKitModal's request method which is designed to handle wallet_watchAsset
// //       // for different underlying wallet types (WC, Magic, etc.)
// //       await _appKitModal!.request(
// //         topic: _currentSession!.topic, // Use the session topic
// //         chainId: _sepoliaChainId, // Specify the chain ID
// //         request: SessionRequestParams(
// //           method: 'wallet_watchAsset', // The method for adding a custom token
// //           params: watchAssetParams,
// //         ),
// //       );

// //       _transactionStatus = 'Wallet prompted to add STARS token.';
// //       print('WalletService: Sent wallet_watchAsset request for STARS token.');
// //       // Refresh balance after adding token (if wallet supports it - not guaranteed to trigger a balance update)
// //       Future.delayed(Duration(seconds: 2), () {
// //         getStarsBalance(); // Call service's method
// //       });
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error requesting wallet to add STARS token: $e\n$s',
// //       );
// //       _transactionStatus = 'Failed to prompt wallet to add token.';

// //       if (_isUserRejectedError(e)) {
// //         _appKitModal!.onModalError.broadcast(
// //           UserRejectedRequest(),
// //         ); // Use AppKit's specific error
// //       } else if (e is JsonRpcError) {
// //         _appKitModal!.onModalError.broadcast(
// //           ModalError('RPC Error adding token: ${e.message ?? "Unknown error"}'),
// //         );
// //       } else {
// //         _appKitModal!.onModalError.broadcast(
// //           ModalError('Failed to send add token request.'),
// //         );
// //       }
// //     } finally {
// //       notifyListeners(); // Update UI status
// //     }
// //   }

// //   // Approve Platform to Spend STARS (Example - depends on your contract logic)
// //   // This might be needed if your giftStars function uses transferFrom internally.
// //   // For simplicity in this example, let's assume giftStars uses transfer, not transferFrom,
// //   // or handles allowance internally. If your platform needs allowance, you'd expose this
// //   // or call it before gifting/buying if required by contract logic.
// //   // Removed for simplicity based on the provided example code structure which calls giftStars/buyStars directly.
// //   // If your contract requires allowance, you would add this back and potentially check allowance before gifting.

// //   // Send Gift Stars (Uses the StarsPlatform contract)
// //   Future<void> sendGiftStars(
// //     String recipientAddressString,
// //     int amountInStars, // Integer amount for gifting
// //   ) async {
// //     print(
// //       "WalletService: Attempting to send gift of $amountInStars STARS to $recipientAddressString",
// //     );

// //     if (amountInStars < 1) {
// //       print("WalletService: Cannot send less than 1 star.");
// //       _transactionStatus = 'Cannot send less than 1 star.';
// //       notifyListeners();
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError('Cannot send less than 1 star.'),
// //       );
// //       return;
// //     }

// //     // Convert integer amount back to Wei BigInt for the contract call
// //     final amountWei = starsIntToWei(amountInStars);

// //     if (!_isSepoliaAndReady) {
// //       print("WalletService: Not ready to send gift.");
// //       _transactionStatus =
// //           'Error: Wallet not connected to Sepolia or contracts not loaded.';
// //       notifyListeners();
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError(
// //           'Please connect wallet and ensure contracts are loaded on Sepolia.',
// //         ),
// //       );
// //       return;
// //     }

// //     if (recipientAddressString.isEmpty) {
// //       print("WalletService: Recipient address is empty.");
// //       _transactionStatus = 'Error: Recipient address is empty.';
// //       notifyListeners();
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError('Please enter a recipient address.'),
// //       );
// //       return;
// //     }

// //     EthereumAddress recipientAddress;
// //     try {
// //       // Use EthereumAddress.fromHex with enforceEip55 for better validation
// //       recipientAddress = EthereumAddress.fromHex(
// //         recipientAddressString,
// //         enforceEip55: true,
// //       );
// //       if (recipientAddress.hex.toLowerCase() ==
// //           _connectedAddress!.toLowerCase()) {
// //         print("WalletService: Cannot gift to self.");
// //         _transactionStatus = 'Error: Cannot send gift to yourself.';
// //         notifyListeners();
// //         _appKitModal!.onModalError.broadcast(
// //           ModalError('Cannot send gift to yourself.'),
// //         );
// //         return;
// //       }
// //     } catch (e) {
// //       print(
// //         "WalletService: Invalid recipient address format or checksum: $recipientAddressString, Error: $e",
// //       );
// //       _transactionStatus = 'Error: Invalid recipient address.';
// //       notifyListeners();
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError('Invalid recipient address format or checksum.'),
// //       );
// //       return;
// //     }

// //     // Basic balance check
// //     if (_currentStarsBalanceWei < amountWei) {
// //       print(
// //         "WalletService: Insufficient STARS balance for gift (Need $amountWei, have $_currentStarsBalanceWei).",
// //       );
// //       _transactionStatus = 'Error: Insufficient STARS balance.';
// //       notifyListeners();
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError('Insufficient STARS balance.'),
// //       );
// //       return;
// //     }

// //     // Update status immediately
// //     _transactionStatus =
// //         'Sending $amountInStars $_starsTokenSymbol to ${recipientAddressString.substring(0, 6)}...${recipientAddressString.substring(recipientAddressString.length - 4)}...';
// //     notifyListeners();

// //     try {
// //       final fromAddress = EthereumAddress.fromHex(_connectedAddress!);

// //       print("WalletService: Calling giftStars on platform contract...");
// //       final txHash = await _appKitModal!.requestWriteContract(
// //         topic: _currentSession!.topic,
// //         chainId: _sepoliaChainId,
// //         deployedContract:
// //             _starsPlatformContract!, // Call giftStars on StarsPlatform!
// //         functionName: 'giftStars', // Assuming the function name is 'giftStars'
// //         transaction: Transaction(from: fromAddress), // Specify the sender
// //         parameters: [
// //           recipientAddress, // Recipient address argument
// //           amountWei, // Amount in wei argument (BigInt)
// //         ],
// //       );

// //       _transactionStatus = 'Gift Transaction sent! Hash: $txHash';
// //       print('WalletService: Gift Stars Tx Hash: $txHash');

// //       // Refresh balance and transactions after a short delay for confirmation
// //       // Use a reasonable delay (e.g., 10-20 seconds) for transaction to be mined and indexed
// //       Future.delayed(Duration(seconds: 15), () {
// //         print("WalletService: Delayed fetch after gift transaction.");
// //         getStarsBalance(); // Refresh balance
// //         fetchTokenTransactions(); // Fetch transactions
// //         _transactionStatus = 'Gift sent. Ready.'; // Update final status
// //         notifyListeners(); // Notify UI for final status update
// //       });
// //     } catch (e, s) {
// //       print('WalletService: Error sending gift stars: $e\n$s');
// //       _transactionStatus = 'Gift transaction failed or rejected.';

// //       if (_isUserRejectedError(e)) {
// //         _appKitModal!.onModalError.broadcast(UserRejectedRequest());
// //       } else if (e is JsonRpcError) {
// //         _appKitModal!.onModalError.broadcast(
// //           ModalError('RPC Error gifting: ${e.message ?? "Unknown error"}'),
// //         );
// //       } else {
// //         _appKitModal!.onModalError.broadcast(ModalError('Failed to send gift.'));
// //       }
// //     } finally {
// //       notifyListeners(); // Update UI status (initial failure)
// //     }
// //   }

// //   // Buy STARS tokens (Uses the StarsPlatform contract)
// //   Future<void> buyStars(double amountNative) async {
// //     print(
// //       "WalletService: Attempting to buy STARS with $amountNative native tokens.",
// //     );

// //     if (amountNative <= 0) {
// //       print("WalletService: Buy amount is zero or negative.");
// //       _transactionStatus = 'Error: Invalid buy amount.';
// //       notifyListeners();
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError('Invalid amount entered. Please enter a positive number.'),
// //       );
// //       return;
// //     }

// //     if (!_isSepoliaAndReady) {
// //       print("WalletService: Not ready to buy stars.");
// //       _transactionStatus =
// //           'Error: Wallet not connected to Sepolia or contracts not loaded.';
// //       notifyListeners();
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError(
// //           'Please connect wallet and ensure contracts are loaded on Sepolia.',
// //         ),
// //       );
// //       return;
// //     }

// //     BigInt amountWei;
// //     try {
// //       // Convert the double native amount to native token Wei (assuming 18 decimals)
// //       amountWei = nativeDoubleToWei(amountNative);
// //       if (amountWei <= BigInt.zero) {
// //         print(
// //           "WalletService: Calculated native amount in wei is zero or negative.",
// //         );
// //         _transactionStatus = 'Error: Amount conversion resulted in zero.';
// //         notifyListeners();
// //         _appKitModal!.onModalError.broadcast(
// //           ModalError('Calculated native amount is too small.'),
// //         );

// //         return;
// //       }
// //     } catch (e) {
// //       // Error handled inside nativeDoubleToWei and broadcasted
// //       print(
// //         "WalletService: Error converting native amount $amountNative to wei.",
// //       );
// //       _transactionStatus = 'Error: Amount conversion failed.';
// //       notifyListeners();
// //       return;
// //     }

// //     // Check native balance
// //     if (_currentNativeBalanceWei < amountWei) {
// //       print(
// //         "WalletService: Insufficient native balance for buy (Need $amountWei, have $_currentNativeBalanceWei).",
// //       );
// //       _transactionStatus = 'Error: Insufficient native balance.';
// //       notifyListeners();
// //       _appKitModal!.onModalError.broadcast(
// //         ModalError('Insufficient native balance to complete purchase.'),
// //       );
// //       return;
// //     }

// //     _transactionStatus =
// //         'Buying STARS with ${amountNative.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')} ${_connectedNetwork?.currency ?? "Native"}...';
// //     notifyListeners();

// //     try {
// //       final fromAddress = EthereumAddress.fromHex(_connectedAddress!);

// //       print(
// //         "WalletService: Calling buyStars on platform contract with value $amountWei...",
// //       );
// //       final txHash = await _appKitModal!.requestWriteContract(
// //         topic: _currentSession!.topic,
// //         chainId: _sepoliaChainId,
// //         deployedContract:
// //             _starsPlatformContract!, // Call buyStars on StarsPlatform!
// //         functionName: 'buyStars', // Assuming the function name is 'buyStars'
// //         transaction: Transaction(
// //           from: fromAddress,
// //           value: EtherAmount.inWei(
// //             amountWei,
// //           ), // Send the native currency as value
// //         ),
// //         parameters:
// //             [], // buyStars function takes no explicit parameters (value is sent separately)
// //       );

// //       _transactionStatus = 'Buy Transaction sent! Hash: $txHash';
// //       print('WalletService: Buy Stars Tx Hash: $txHash');

// //       // Refresh balance and transactions after a short delay
// //       // Use a reasonable delay (e.g., 10-20 seconds) for transaction to be mined and indexed
// //       Future.delayed(Duration(seconds: 15), () {
// //         print("WalletService: Delayed fetch after buy transaction.");
// //         getStarsBalance(); // Refresh STARS balance
// //         // _updateNativeBalance(); // This is triggered by balanceNotifier listener which fires when native balance changes
// //         fetchTokenTransactions(); // Fetch transactions
// //         _transactionStatus = 'Buy successful. Ready.'; // Update final status
// //         notifyListeners(); // Notify UI for final status update
// //       });
// //     } catch (e, s) {
// //       print('WalletService: Error sending buy stars transaction: $e\n$s');
// //       _transactionStatus = 'Buy transaction failed or rejected.';

// //       if (_isUserRejectedError(e)) {
// //         _appKitModal!.onModalError.broadcast(UserRejectedRequest());
// //       } else if (e is JsonRpcError) {
// //         _appKitModal!.onModalError.broadcast(
// //           ModalError('RPC Error buying: ${e.message ?? "Unknown error"}'),
// //         );
// //       } else {
// //         _appKitModal!.onModalError.broadcast(
// //           ModalError('Failed to send buy transaction.'),
// //         );
// //       }
// //     } finally {
// //       notifyListeners(); // Update UI status (initial failure)
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     // Important: Remove listeners before disposing the modal
// //     _appKitModal!.removeListener(_updateState);
// //     _appKitModal!.balanceNotifier.removeListener(_updateNativeBalance);
// //     _appKitModal!.onModalError.unsubscribe(_handleModalError);

// //     _appKitModal!.dispose(); // Dispose the AppKitModal instance
// //     print("WalletService: Disposed.");
// //     super.dispose();
// //   }
// // }

// // import 'dart:convert';

// // import 'package:decimal/decimal.dart';
// // import 'package:flutter/material.dart';
// // import 'package:flutter/services.dart' show rootBundle;
// // import 'package:http/http.dart'; // For fetching Etherscan data
// // import 'package:my_secure_wallet_app/token.dart'; // Assuming you have this model
// // import 'package:reown_appkit/modal/i_appkit_modal_impl.dart';
// // import 'package:reown_appkit/reown_appkit.dart';

// // const String _etherscanApiKey =
// //     'DUGGC885HI87T28EAFB4WECBS57X1JGQKN'; // !! Replace with your actual key or use a secure method !!

// // // Ensure you have a valid Etherscan API key. If not, transactions will fail.
// // // const String _etherscanApiKey = 'YOUR_ETHERSCAN_API_KEY';

// // const double _STARS_PER_NATIVE_TOKEN = 100.0;
// // const double _NATIVE_PER_STAR = 1.0 / _STARS_PER_NATIVE_TOKEN;

// // class WalletService extends ChangeNotifier {
// //   // --- AppKitModal Instance ---
// //   ReownAppKitModal? _appKitModal; // Made nullable
// //   // Removed _isInitialized flag - presence of _appKitModal will indicate if modal was created

// //   // --- State Variables (Keep private and expose via getters) ---
// //   ReownAppKitModalStatus _status = ReownAppKitModalStatus.idle;
// //   ReownAppKitModalNetworkInfo? _connectedNetwork;
// //   ReownAppKitModalSession? _currentSession;
// //   String? _connectedAddress;
// //   String? _connectedWalletName;
// //   BigInt _currentNativeBalanceWei = BigInt.zero; // Fetched via RPC
// //   BigInt _currentStarsBalanceWei = BigInt.zero; // Fetched via Contract Read
// //   String _starsBalanceDisplay =
// //       'Connect to see balance'; // Formatted display string

// //   // Contract Details (Move from UI)
// //   final String _sepoliaChainId = 'eip155:11155111';
// //   final String _starsTokenAddress =
// //       '0x185239e90BBb3810c27671aaCFA7d9b3c26Da22C'; // Example Sepolia Token Address
// //   final String _starsPlatformAddress =
// //       '0xA14536b87f485F266560b218f6f19D0eCAB070d1'; // Example Sepolia Platform Address
// //   final int _starsTokenDecimals = 18;
// //   final String _starsTokenSymbol = 'STR';

// //   // Deployed Contracts
// //   DeployedContract? _starsTokenContract;
// //   DeployedContract? _starsPlatformContract;
// //   bool _areContractsLoaded = false; // Flag for ABI loading status

// //   // Transaction/Action Status
// //   String _transactionStatus = 'Ready.'; // General status for user actions

// //   // Transaction List State
// //   List<TokenTransaction> _transactions = [];
// //   bool _isLoadingTransactions = false;
// //   String _transactionListStatus =
// //       'Connect to see transactions'; // Status for the list area

// //   // Flag to track if initial data fetch has been attempted for the current Sepolia connection
// //   bool _hasFetchedInitialData = false;

// //   // Store the BuildContext needed for modal creation
// //   BuildContext? _context; // Will be set by init

// //   // --- Getters to Expose State to UI ---
// //   // We can't expose _appKitModal directly anymore because it might be null.
// //   // Actions requiring the modal will need to be methods on WalletService.
// //   ReownAppKitModal get appKitModal => _appKitModal!; // Removed this getter

// //   ReownAppKitModalStatus get status => _status;
// //   bool get isConnected =>
// //       _status == ReownAppKitModalStatus.initialized && _currentSession != null;
// //   ReownAppKitModalNetworkInfo? get connectedNetwork => _connectedNetwork;
// //   ReownAppKitModalSession? get currentSession => _currentSession;
// //   String? get connectedAddress => _connectedAddress;
// //   String? get connectedWalletName => _connectedWalletName;
// //   BigInt get currentNativeBalanceWei => _currentNativeBalanceWei;
// //   BigInt get currentStarsBalanceWei => _currentStarsBalanceWei;
// //   String get starsBalanceDisplay => _starsBalanceDisplay;

// //   String get sepoliaChainId => _sepoliaChainId;
// //   String get starsTokenAddress => _starsTokenAddress;
// //   String get starsPlatformAddress => _starsPlatformAddress;
// //   int get starsTokenDecimals => _starsTokenDecimals;
// //   String get starsTokenSymbol => _starsTokenSymbol;

// //   bool get areContractsLoaded => _areContractsLoaded;

// //   String get transactionStatus => _transactionStatus;
// //   // Setter for transactionStatus if other parts of the service need to update it
// //   set transactionStatus(String status) {
// //     if (_transactionStatus != status) {
// //       _transactionStatus = status;
// //       notifyListeners();
// //     }
// //   }

// //   List<TokenTransaction> get transactions => _transactions;
// //   bool get isLoadingTransactions => _isLoadingTransactions;
// //   String get transactionListStatus => _transactionListStatus;

// //   // Conversion Rates (expose as getters)
// //   double get starsPerNativeToken => _STARS_PER_NATIVE_TOKEN;
// //   double get nativePerStar => _NATIVE_PER_STAR;

// //   // Helper getter to check if we are connected to Sepolia and have loaded contracts
// //   bool get _isSepoliaAndReady {
// //     return isConnected &&
// //         _connectedNetwork?.chainId == _sepoliaChainId &&
// //         _connectedAddress != null &&
// //         _currentSession != null &&
// //         _areContractsLoaded;
// //   }

// //   // --- Initialization ---
// //   // Initial service setup, primarily loads ABIs
// //   Future<void> init(BuildContext context) async {
// //     print('WalletService: Starting service initialization...');
// //     _context = context; // Store context for later modal creation

// //     // Start loading contracts asynchronously, but don't block init()
// //     await _loadContractAbis();

// //     print('WalletService: Service initialization complete.');
// //     // No need to call notifyListeners() here unless statuses change immediately
// //     // _updateState listener will handle state changes once modal is created/connected.
// //   }

// //   // --- Connect Wallet Method (Called by UI Button) ---
// //   Future<void> connectWallet(BuildContext context) async {
// //     print('WalletService: Connect Wallet requested.');

// //     if (_appKitModal != null &&
// //         _appKitModal!.status != ReownAppKitModalStatus.idle) {
// //       // If modal exists and is not idle, it's likely already connecting or connected
// //       print(
// //         'WalletService: AppKitModal instance exists and is not idle (${_appKitModal!.status}), skipping creation.',
// //       );
// //       // Just call connect on the existing instance (it might resume a session)
// //       try {
// //         _status =
// //             ReownAppKitModalStatus.initializing; // Indicate connecting state
// //         notifyListeners();
// //         await _appKitModal!.openModalView();
// //         print('WalletService: Called connect() on existing modal instance.');
// //       } catch (e, s) {
// //         print(
// //           'WalletService: Error calling connect() on existing modal: $e\n$s',
// //         );
// //         _status = ReownAppKitModalStatus.error; // Update status on error
// //         _transactionStatus = 'Connection failed.';
// //         notifyListeners();
// //         _appKitModal!.onModalError.broadcast(
// //           ModalError('Failed to reconnect wallet. Check console for details.'),
// //         );
// //       }
// //       return;
// //     }

// //     print('WalletService: Creating a new AppKitModal instance...');
// //     _status = ReownAppKitModalStatus.initializing; // Set status before creation
// //     _transactionStatus = 'Initializing wallet connection...';
// //     notifyListeners(); // Update UI immediately

// //     try {
// //       _appKitModal = ReownAppKitModal(
// //         context: context, // Use the provided context
// //         projectId:
// //             'ccf4925f727ee0d480bb502cce820edf', // Replace with your Project ID
// //         metadata: const PairingMetadata(
// //           name: 'Secure Wallet App', // App Name
// //           description: 'A secure wallet application', // App Description
// //           url: 'https://reown.com/', // Your Website URL
// //           icons: ['https://reown.com/logo.png'], // Your App Icon URL
// //           redirect: Redirect(
// //             native: 'mysecurewalletapp://', // Your app's deep link scheme
// //             universal:
// //                 'https://reown.com/mysecurewalletapp', // Your universal link
// //           ),
// //         ),
// //         requiredNamespaces: {
// //           'eip155': RequiredNamespace(
// //             chains: [_sepoliaChainId], // Specify required chains
// //             methods: [
// //               'eth_sendTransaction',
// //               'eth_signTypedData_v4',
// //               'personal_sign',
// //               'eth_call', // Required for read calls
// //               'wallet_switchEthChain',
// //               'wallet_addEthChain',
// //               'wallet_watchAsset', // Required for add token
// //             ],
// //             events: ['chainChanged', 'accountsChanged'],
// //           ),
// //         },
// //         logLevel: LogLevel.debug,
// //       );

// //       print('WalletService: Adding listeners to new modal instance...');
// //       // Add listeners to the *new* instance
// //       _appKitModal!.addListener(_updateState);
// //       _appKitModal!.balanceNotifier.addListener(_updateNativeBalance);
// //       _appKitModal!.onModalError.subscribe(_handleModalError);

// //       print('WalletService: Initializing new AppKitModal instance...');
// //       await _appKitModal!.init(); // Initialize the new instance

// //       print('WalletService: Calling connect() on new modal instance...');
// //       await _appKitModal!.openModalView();

// //       // _updateState listener will handle state transitions after connect()
// //       // is called and modal state updates.
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error during new AppKitModal creation/connection: $e\n$s',
// //       );
// //       // Ensure _appKitModal is null and clean up if creation failed midway
// //       if (_appKitModal != null) {
// //         try {
// //           // Remove listeners from the instance that failed to init/connect
// //           _appKitModal!.removeListener(_updateState);
// //           _appKitModal!.balanceNotifier.removeListener(_updateNativeBalance);
// //           _appKitModal!.onModalError.unsubscribe(_handleModalError);
// //           _appKitModal!.dispose();
// //           print('WalletService: Disposed failed modal instance.');
// //         } catch (disposeError) {
// //           print(
// //             'WalletService: Error disposing failed modal instance: $disposeError',
// //           );
// //         }
// //       }
// //       _appKitModal = null; // Ensure it's null
// //       _status = ReownAppKitModalStatus.error;
// //       _transactionListStatus = 'Connection failed.';
// //       _transactionStatus = 'Connection failed.';
// //       _starsBalanceDisplay = 'Connection failed.';
// //       _currentSession = null; // Reset session state
// //       _connectedAddress = null; // Reset address state
// //       _connectedWalletName = null; // Reset name state
// //       _currentNativeBalanceWei = BigInt.zero; // Reset balances
// //       _currentStarsBalanceWei = BigInt.zero;
// //       _hasFetchedInitialData = false; // Reset fetch flag

// //       notifyListeners();
// //       _handleModalError(
// //         ModalError("Failed to connect wallet. Check console for details."),
// //       );
// //     }
// //   }

// //   // This listener reacts to *any* state change in AppKitModal
// //   void _updateState() {
// //     print(
// //       'WalletService: _updateState called. AppKitModal Status: ${_appKitModal?.status}, isConnected: ${_appKitModal?.isConnected}',
// //     );
// //     print('WalletService: Current Sepolia target chainId: $_sepoliaChainId');

// //     // Check if _appKitModal is still valid (not null or disposed)
// //     if (_appKitModal == null) {
// //       print(
// //         'WalletService: _updateState called but _appKitModal is null or disposed. Skipping.',
// //       );
// //       // We might be here because _performLocalCleanup set it to null.
// //       // Ensure service state reflects disconnected.
// //       if (_status != ReownAppKitModalStatus.idle) {
// //         _performLocalCleanup(); // Re-run cleanup if state is off
// //       }
// //       return;
// //     }

// //     // Capture the new state from AppKitModal properties
// //     final newStatus = _appKitModal!.status;
// //     final bool newIsConnected = _appKitModal!.isConnected;
// //     final ReownAppKitModalSession? newSession = _appKitModal!.session;
// //     final ReownAppKitModalNetworkInfo? newConnectedNetwork =
// //         _appKitModal!.selectedChain;

// //     String? newConnectedAddress =
// //         _connectedAddress; // Keep current unless updated
// //     String? newConnectedWalletName =
// //         _connectedWalletName; // Keep current unless updated

// //     // Determine if the *relevant* connected state has changed
// //     final bool wasConnectedAndReady =
// //         _isSepoliaAndReady; // State before this update
// //     bool isConnectedNow = false;

// //     if (newIsConnected && newSession != null && newConnectedNetwork != null) {
// //       isConnectedNow = true; // Wallet is connected to *some* network

// //       final namespace = NamespaceUtils.getNamespaceFromChain(
// //         newConnectedNetwork.chainId,
// //       );

// //       try {
// //         // This can sometimes throw if the session structure is unexpected for the chain
// //         newConnectedAddress = newSession.getAddress(namespace);
// //       } catch (e) {
// //         print(
// //           "WalletService: Could not get address for namespace $namespace: $e",
// //         );
// //         newConnectedAddress = null; // Reset address if it fails
// //       }

// //       newConnectedWalletName =
// //           newSession.peer?.metadata.name ??
// //           newSession.sessionEmail ??
// //           newSession.sessionUsername ??
// //           'Unknown Wallet';

// //       print(
// //         'WalletService: Wallet connected. Chain: ${newConnectedNetwork.chainId}, Address: $newConnectedAddress, Wallet: $newConnectedWalletName',
// //       );

// //       // Update internal state variables (only if different to avoid unnecessary notifies)
// //       if (_currentSession != newSession) _currentSession = newSession;
// //       if (_connectedNetwork != newConnectedNetwork)
// //         _connectedNetwork = newConnectedNetwork;
// //       if (_connectedAddress != newConnectedAddress)
// //         _connectedAddress = newConnectedAddress;
// //       if (_connectedWalletName != newConnectedWalletName)
// //         _connectedWalletName = newConnectedWalletName;

// //       // If connected, but not to Sepolia, reset Sepolia-specific states
// //       if (newConnectedNetwork.chainId != _sepoliaChainId) {
// //         print(
// //           'WalletService: Connected to non-Sepolia chain. Resetting Sepolia states.',
// //         );
// //         _starsBalanceDisplay = 'Switch wallet to Sepolia to see balance';
// //         _transactionStatus = 'Switch wallet to Sepolia to transact';
// //         _transactions = []; // Clear Sepolia transactions
// //         _transactionListStatus = 'Switch wallet to Sepolia to see transactions';
// //         // Don't reset native balance immediately, it might still show the non-Sepolia balance
// //         // _currentNativeBalanceWei is handled by _updateNativeBalance reacting to chain changes
// //         _currentStarsBalanceWei = BigInt.zero; // Reset Sepolia-specific balance
// //         _hasFetchedInitialData = false; // Reset fetch flag
// //       }
// //     } else {
// //       // Wallet is now disconnected or failed connection
// //       print("WalletService: Wallet is NOT connected.");
// //       isConnectedNow = false; // Explicitly set to false

// //       // Clear all session/connection specific state
// //       // Only reset if state was previously connected or connecting
// //       if (_currentSession != null || _status != ReownAppKitModalStatus.idle) {
// //         print(
// //           'WalletService: Disconnection detected. Performing local cleanup.',
// //         );
// //         // This disconnection triggers the disposal of the modal instance
// //         _performLocalCleanup();
// //         // _performLocalCleanup will handle setting all state variables and notifyListeners
// //         return; // Exit _updateState here as cleanup handles the notification
// //       }
// //       // If already idle and not connected, do nothing further here.
// //     }

// //     // Update the status last (unless cleanup already did)
// //     if (_status != newStatus) {
// //       _status = newStatus;
// //       print('WalletService: Status updated to: $_status');
// //     }

// //     // Determine if we are now in the "Sepolia and Ready" state
// //     final bool isNowConnectedAndReady =
// //         _isSepoliaAndReady; // State after this update

// //     // --- Handle State Transitions and Data Fetching ---

// //     // Case 1: Transitioning *into* the Sepolia+Ready state for the first time in this session
// //     if (isNowConnectedAndReady &&
// //         !wasConnectedAndReady &&
// //         !_hasFetchedInitialData) {
// //       print(
// //         "WalletService: Transitioned to Sepolia+Ready state. Triggering initial data fetch.",
// //       );
// //       // Use Future.delayed(Duration.zero) to ensure this runs after all listeners
// //       // have processed the current state update, preventing potential re-entrancy issues.
// //       Future.delayed(Duration.zero, () {
// //         // Double-check state before fetching in case it changed again very quickly
// //         if (_isSepoliaAndReady && !_hasFetchedInitialData) {
// //           _fetchInitialData();
// //         } else {
// //           print(
// //             "WalletService: State changed again before initial fetch could run.",
// //           );
// //         }
// //       });
// //       // Set loading status immediately while waiting for the scheduled fetch
// //       _starsBalanceDisplay = 'Loading...';
// //       _transactionListStatus = 'Loading...';
// //       _transactionStatus = 'Connected to Sepolia. Loading data...';
// //     } else if (isNowConnectedAndReady && _hasFetchedInitialData) {
// //       // Case 2: Already in the Sepolia+Ready state and data was fetched.
// //       // Status messages should reflect operational state (e.g., 'Ready')
// //       // unless individual fetch calls update them to 'Loading...' or 'Error'.
// //       if (!_transactionStatus.contains('Loading') &&
// //           !_transactionStatus.contains('Error') &&
// //           !_transactionStatus.contains('Failed')) {
// //         _transactionStatus = 'Ready to transact on Sepolia.';
// //       }
// //       if (_transactionListStatus != 'Error: Etherscan API key is missing.' &&
// //           !_transactionListStatus.contains('Loading') &&
// //           !_transactionListStatus.contains('Error') &&
// //           !_transactionListStatus.contains('Failed')) {
// //         if (_transactions.isEmpty) {
// //           _transactionListStatus = 'No recent STARS transactions found.';
// //         } else {
// //           _transactionListStatus = ''; // Clear status if list is populated
// //         }
// //       }
// //       // starsBalanceDisplay is managed by getStarsBalance()
// //     } else if (isConnectedNow &&
// //         newConnectedNetwork?.chainId != _sepoliaChainId) {
// //       // Case 3: Connected to a network, but NOT Sepolia (Handled within the connected block above)
// //       // This block is now less critical as the check is inside the `if (newIsConnected)` block.
// //       print(
// //         "WalletService: Connected to a network other than Sepolia (Chain: ${newConnectedNetwork?.chainId}). Statuses updated in connected block.",
// //       );
// //     } else if (!isConnectedNow && _appKitModal != null) {
// //       // Case 4: Modal exists but is not connected. This might be during connecting phase.
// //       // Statuses should already reflect connecting or initialization.
// //       print(
// //         "WalletService: Modal exists but is not connected. Status: $_status",
// //       );
// //       // No specific status changes needed here, statuses are set by connectWallet or init/dispose.
// //     }
// //     // If !isConnectedNow and _appKitModal is null, it means cleanup happened, handled by _performLocalCleanup

// //     // Only notify if state variables potentially changed and cleanup wasn't performed
// //     if (_appKitModal != null || _status != ReownAppKitModalStatus.idle) {
// //       print('WalletService: Notifying listeners of state change');
// //       notifyListeners();
// //     }
// //   }

// //   // Method called by UI to disconnect
// //   Future<void> disconnect() async {
// //     print('WalletService: Requesting disconnect...');
// //     if (_appKitModal == null || !_appKitModal!.isConnected) {
// //       print(
// //         'WalletService: AppKitModal instance is null or not connected, performing local cleanup.',
// //       );
// //       // Already in a disconnected state, ensure local cleanup is done
// //       if (_appKitModal != null) {
// //         // Only perform cleanup if there was an instance
// //         await _performLocalCleanup();
// //       } else {
// //         // If already null, just ensure service state is reset
// //         _status = ReownAppKitModalStatus.idle;
// //         _transactionStatus = 'Ready.';
// //         _transactionListStatus = 'Connect to see transactions';
// //         _starsBalanceDisplay = 'Connect to see balance';
// //         _currentNativeBalanceWei = BigInt.zero;
// //         _currentStarsBalanceWei = BigInt.zero;
// //         _hasFetchedInitialData = false;
// //         _transactions = [];
// //         notifyListeners();
// //       }
// //       return;
// //     }

// //     _status = ReownAppKitModalStatus.initializing;
// //     _transactionStatus = 'Disconnecting...';
// //     notifyListeners(); // Update UI status

// //     try {
// //       print('WalletService: Calling appKitModal.disconnect()...');
// //       // This triggers the state change that _updateState listens for
// //       await _appKitModal!.disconnect();
// //       print('WalletService: appKitModal.disconnect() returned.');
// //       // _updateState listener will now handle the state change to disconnected
// //       // and trigger _performLocalCleanup.
// //     } catch (e, s) {
// //       print('WalletService: Error during disconnect request: $e\n$s');
// //       _transactionStatus = 'Error requesting disconnect.';
// //       // Still attempt local cleanup if the request failed
// //       await _performLocalCleanup(); // Force cleanup on error
// //       // Decide if you want to broadcast a modal error for disconnect issues
// //       _handleModalError(ModalError('Failed to disconnect properly.'));
// //     } finally {
// //       // notifyListeners() was already called above and by _performLocalCleanup
// //     }
// //   }

// //   // Perform local cleanup - dispose modal, reset state
// //   Future<void> _performLocalCleanup() async {
// //     // This method should only be called when the modal is detected as disconnected
// //     // or if an error prevents connection/disconnection.
// //     if (_appKitModal == null) {
// //       print(
// //         'WalletService: _performLocalCleanup called but _appKitModal is null. Skipping modal specific cleanup.',
// //       );
// //       // Still reset service state if needed
// //       if (_status != ReownAppKitModalStatus.idle) {
// //         _status = ReownAppKitModalStatus.idle;
// //         _connectedNetwork = null;
// //         _currentSession = null;
// //         _connectedAddress = null;
// //         _connectedWalletName = null;
// //         _currentNativeBalanceWei = BigInt.zero;
// //         _currentStarsBalanceWei = BigInt.zero;
// //         _starsBalanceDisplay = 'Connect to see balance';
// //         _transactionStatus = 'Ready.';
// //         _transactions = [];
// //         _transactionListStatus = 'Connect to see transactions';
// //         _hasFetchedInitialData = false;
// //         notifyListeners();
// //       }
// //       return;
// //     }
// //     print('WalletService: Performing local cleanup...');

// //     // Remove listeners from the SPECIFIC instance before disposing it
// //     try {
// //       print('WalletService: Removing listeners...');
// //       _appKitModal!.removeListener(_updateState);
// //       _appKitModal!.balanceNotifier.removeListener(_updateNativeBalance);
// //       _appKitModal!.onModalError.unsubscribe(_handleModalError);
// //     } catch (e) {
// //       print('WalletService: Error removing listeners: $e');
// //       // Continue cleanup even if listener removal fails
// //     }

// //     // Dispose the modal instance
// //     try {
// //       print('WalletService: Disposing AppKitModal instance...');
// //       await _appKitModal!.dispose(); // Use await as dispose might be async
// //       print('WalletService: AppKitModal instance disposed.');
// //     } catch (e) {
// //       print('WalletService: Error disposing AppKitModal instance: $e');
// //       // Continue cleanup even if dispose fails
// //     } finally {
// //       _appKitModal = null; // Set to null regardless of dispose success
// //     }

// //     // Reset all service state variables related to connection/session
// //     print('WalletService: Resetting service state...');
// //     _status = ReownAppKitModalStatus.idle; // Set final status
// //     _connectedNetwork = null;
// //     _currentSession = null;
// //     _connectedAddress = null;
// //     _connectedWalletName = null;
// //     _currentNativeBalanceWei = BigInt.zero;
// //     _currentStarsBalanceWei = BigInt.zero;
// //     _starsBalanceDisplay = 'Connect to see balance';
// //     _transactionStatus = 'Ready.'; // Or 'Connect to transact'
// //     _transactions = []; // Clear transactions
// //     _transactionListStatus = 'Connect to see transactions';
// //     _hasFetchedInitialData = false; // Reset fetch flag

// //     print('WalletService: Local cleanup complete.');
// //     notifyListeners(); // Notify UI after cleanup
// //   }

// //   // Helper to trigger initial data fetches when state is ready
// //   void _fetchInitialData() {
// //     if (_hasFetchedInitialData) {
// //       print(
// //         "WalletService: _fetchInitialData called but flag already true. Skipping.",
// //       );
// //       return; // Prevent re-triggering within the same session
// //     }
// //     print(
// //       "WalletService: Calling _fetchInitialData(). Setting flag and status.",
// //     );
// //     _hasFetchedInitialData = true;

// //     // Set loading statuses immediately
// //     _starsBalanceDisplay = 'Fetching balance...';
// //     _transactionListStatus = 'Fetching transactions...';
// //     _transactionStatus = 'Fetching data...';
// //     notifyListeners(); // Notify UI to show these initial loading states

// //     _updateNativeBalance(); // Get native balance via RPC request
// //     // Fetch the data asynchronously
// //     getStarsBalance(); // This will update _starsBalanceDisplay and call notifyListeners()
// //     fetchTokenTransactions(); // This will update _transactionListStatus and call notifyListeners()

// //     // Note: _updateNativeBalance is triggered by the balanceNotifier listener,
// //     // which *should* fire automatically upon session connection and chain changes.
// //     // We call it explicitly here too for certainty on initial load.
// //   }

// //   // This is called by the balanceNotifier listener OR explicitly in _fetchInitialData
// //   void _updateNativeBalance() async {
// //     print("WalletService: _updateNativeBalance triggered.");

// //     // Ensure we have a valid modal, session, address, and are on Sepolia
// //     if (_appKitModal == null ||
// //         !isConnected ||
// //         _connectedNetwork?.chainId != _sepoliaChainId ||
// //         _connectedAddress == null ||
// //         _currentSession == null) {
// //       print(
// //         "WalletService: _updateNativeBalance skipped - not connected to Sepolia or missing data.",
// //       );
// //       // If we are not connected to Sepolia, native balance isn't relevant for Sepolia context
// //       // The core state update in _updateState handles resetting the balance display
// //       // However, if this listener fires *after* disconnect but before _updateState resets,
// //       // ensure we don't try to set a non-zero Sepolia balance.
// //       if (_currentNativeBalanceWei != BigInt.zero) {
// //         _currentNativeBalanceWei = BigInt.zero;
// //         notifyListeners(); // Notify if balance reset
// //       }
// //       return; // Exit early
// //     }

// //     // Fetch the balance using the currently active modal instance
// //     print(
// //       "WalletService: _updateNativeBalance fetching raw balance via RPC for address $_connectedAddress...",
// //     );

// //     try {
// //       final address = EthereumAddress.fromHex(_connectedAddress!);
// //       final topic = _currentSession?.topic; // Get topic for WC

// //       if (topic == null) {
// //         print(
// //           "WalletService: _updateNativeBalance skipped - session topic is null.",
// //         );
// //         if (_currentNativeBalanceWei != BigInt.zero) {
// //           _currentNativeBalanceWei = BigInt.zero;
// //           notifyListeners(); // Notify if balance reset
// //         }
// //         return; // Exit if topic is null
// //       }

// //       // Explicitly request the balance using the modal's request method
// //       final dynamic result = await _appKitModal!.request(
// //         topic: topic,
// //         chainId: _sepoliaChainId, // Request balance for the Sepolia chain
// //         request: SessionRequestParams(
// //           method: 'eth_getBalance',
// //           params: [address.hex, 'latest'],
// //         ),
// //       );

// //       if (result is String && result.startsWith('0x')) {
// //         final balance = BigInt.parse(result.substring(2), radix: 16);
// //         if (_currentNativeBalanceWei != balance) {
// //           _currentNativeBalanceWei = balance;
// //           print(
// //             "WalletService: Native balance updated via RPC: $_currentNativeBalanceWei wei",
// //           );
// //           // No need to notify here, the finally block handles it
// //         } else {
// //           print("WalletService: Native balance fetched but unchanged.");
// //         }
// //       } else {
// //         print(
// //           "WalletService: Unexpected result format from eth_getBalance: $result",
// //         );
// //         if (_currentNativeBalanceWei != BigInt.zero) {
// //           _currentNativeBalanceWei = BigInt.zero;
// //           // No need to notify here, the finally block handles it
// //         } else {
// //           print(
// //             "WalletService: Native balance result unexpected but was already zero.",
// //           );
// //         }
// //       }
// //     } catch (e, s) {
// //       print("WalletService: Error updating native balance via RPC: $e\n$s");
// //       if (_currentNativeBalanceWei != BigInt.zero) {
// //         _currentNativeBalanceWei = BigInt.zero;
// //         // No need to notify here, the finally block handles it
// //       }
// //       // Don't necessarily broadcast a modal error for background balance updates
// //     } finally {
// //       // Always notify listeners at the end of the async operation
// //       notifyListeners();
// //     }
// //   }

// //   // Handle errors from AppKitModal
// //   void _handleModalError(ModalError? event) {
// //     print('WalletService: AppKit Modal Error: ${event?.message}');
// //     if (event?.message != null && event!.message.isNotEmpty) {
// //       // You might want to expose this error to the UI differently,
// //       // maybe store the last error message and display it somewhere.
// //       // For now, we just print and notify.
// //       // You could also trigger a Snackbar here using the stored context if available.
// //       if (_context != null && _context!.mounted) {
// //         ScaffoldMessenger.of(_context!).showSnackBar(
// //           SnackBar(content: Text('Wallet Error: ${event.message}')),
// //         );
// //       }
// //     }
// //     notifyListeners(); // Ensure UI can react to error status changes
// //   }

// //   // Helper to check if an error is likely a user rejecting the request
// //   bool _isUserRejectedError(dynamic e) {
// //     // Check standard RPC error codes for user rejection (e.g., 4001)
// //     // and common error message patterns.
// //     final regexp = RegExp(
// //       r'\b(rejected|cancelled|disapproved|denied|User canceled|User denied)\b',
// //       caseSensitive: false,
// //     );

// //     if (e is JsonRpcError) {
// //       // Standard EIP-1193 user rejected request code
// //       if (e.code == 4001) return true;
// //       // WalletConnect specific rejection codes (often in 5000-5999 range)
// //       // These are less standard but common for network/request issues including user rejection
// //       if (e.code != null && e.code! >= 5000 && e.code! < 6000) {
// //         // Needs refinement - not all codes are user rejection, but many are.
// //         // A robust check might inspect the message for these codes too.
// //         // print('WalletService: Potential WC error code: ${e.code}'); // Debugging WC errors
// //         return true;
// //       }
// //       // Check message for patterns even if code isn't standard
// //       if (e.message != null && regexp.hasMatch(e.message!)) {
// //         return true;
// //       }
// //     }
// //     // AppKit-specific error types (if any)
// //     if (e is UserRejectedRequest) return true;

// //     // Check the error string representation as a fallback
// //     return regexp.hasMatch(e.toString());
// //   }

// //   // --- Contract Loading ---
// //   // This is called once during service init
// //   Future<void> _loadContractAbis() async {
// //     print('WalletService: Starting to load ABIs...');
// //     _areContractsLoaded = false; // Set loading state for contracts
// //     // Status messages are already handled by _updateState's initial checks

// //     try {
// //       // Load and parse ABIs
// //       print('WalletService: Loading StarsToken.json...');
// //       final starsTokenAbiString = await rootBundle.loadString(
// //         'assets/abis/StarsToken.json',
// //       );
// //       print('WalletService: Loading StarsPlatform.json...');
// //       final starsPlatformAbiString = await rootBundle.loadString(
// //         'assets/abis/StarsPlatform.json',
// //       );

// //       final starsTokenAbiJson = jsonDecode(starsTokenAbiString);
// //       final starsPlatformAbiJson = jsonDecode(starsPlatformAbiString);

// //       final starsTokenAbiArray = starsTokenAbiJson['abi'];
// //       final starsPlatformAbiArray = starsPlatformAbiJson['abi'];

// //       if (starsTokenAbiArray == null ||
// //           starsPlatformAbiArray == null ||
// //           starsTokenAbiArray is! List ||
// //           starsPlatformAbiArray is! List) {
// //         print('WalletService: ABI validation failed: JSON structure invalid.');
// //         throw Exception(
// //           "ABI JSON is not structured as expected (missing 'abi' key or not an array)",
// //         );
// //       }

// //       final starsTokenAbi = ContractAbi.fromJson(
// //         jsonEncode(starsTokenAbiArray),
// //         'StarsToken',
// //       );
// //       final starsPlatformAbi = ContractAbi.fromJson(
// //         jsonEncode(starsPlatformAbiArray),
// //         'StarsPlatform',
// //       );

// //       _starsTokenContract = DeployedContract(
// //         starsTokenAbi,
// //         EthereumAddress.fromHex(_starsTokenAddress),
// //       );
// //       _starsPlatformContract = DeployedContract(
// //         starsPlatformAbi,
// //         EthereumAddress.fromHex(_starsPlatformAddress),
// //       );

// //       _areContractsLoaded = true; // Contracts successfully loaded
// //       print('WalletService: Contract ABIs loaded successfully.');

// //       // IMPORTANT: If we successfully loaded contracts *after* the wallet was already connected
// //       // to Sepolia, trigger the initial data fetch now.
// //       if (_isSepoliaAndReady && !_hasFetchedInitialData) {
// //         print(
// //           "WalletService: Contracts loaded AFTER Wallet was ready. Triggering initial data fetch.",
// //         );
// //         // Use Future.delayed(Duration.zero) to yield back before calling fetch
// //         Future.delayed(Duration.zero, () {
// //           // Double-check state before fetching
// //           if (_isSepoliaAndReady && !_hasFetchedInitialData) {
// //             _fetchInitialData();
// //           } else {
// //             print(
// //               "WalletService: State changed again before initial fetch (post-ABI load) could run.",
// //             );
// //           }
// //         });
// //         // Set loading status immediately
// //         _starsBalanceDisplay = 'Loading...';
// //         _transactionListStatus = 'Loading...';
// //         _transactionStatus = 'Contracts loaded. Fetching data...';
// //       } else {
// //         print(
// //           "WalletService: Contracts loaded. Sepolia ready state: $_isSepoliaAndReady, Initial fetch done: $_hasFetchedInitialData.",
// //         );
// //         // State will be updated by _updateState based on connection status
// //         // No need to set specific statuses here unless there was an error
// //       }
// //     } catch (e, s) {
// //       print('WalletService: FATAL ERROR loading or parsing ABIs: $e\n$s');
// //       _areContractsLoaded = false; // Ensure this is false on error
// //       _starsTokenContract = null;
// //       _starsPlatformContract = null;
// //       // Update status messages to reflect the error
// //       _starsBalanceDisplay = 'Error loading contracts';
// //       _transactionStatus = 'Error loading contracts';
// //       _transactionListStatus = 'Error loading contracts';
// //       _currentNativeBalanceWei = BigInt.zero;
// //       _currentStarsBalanceWei = BigInt.zero;
// //       _hasFetchedInitialData = false; // Reset flag

// //       _handleModalError(
// //         ModalError('Error loading contract data. Check console for details.'),
// //       );
// //     } finally {
// //       // Always notify listeners after ABI loading attempt (success or failure)
// //       notifyListeners();
// //     }
// //   }

// //   // Helper to convert double Stars amount to BigInt Wei
// //   BigInt starsToWei(double starsAmount) {
// //     if (starsAmount < 0) return BigInt.zero;
// //     final bigDecimal = BigInt.from(10).pow(_starsTokenDecimals);
// //     try {
// //       final starsDecimal = Decimal.parse(starsAmount.toString());
// //       final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
// //       final weiAmountDecimal = starsDecimal * bigDecimalDecimal;
// //       // Rounding is important for accurate BigInt conversion
// //       // Use round(MidpointRounding.toNearestEven) or check requirements
// //       // For simplicity, we'll use standard round(), but be aware of precision.
// //       return BigInt.parse(weiAmountDecimal.round().toString());
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error converting stars $starsAmount to wei: $e\n$s',
// //       );
// //       _handleModalError(ModalError("Conversion Error: Invalid star amount."));
// //       return BigInt.zero; // Return zero on conversion error
// //     }
// //   }

// //   // Helper to convert integer Stars amount to BigInt Wei (for gifting)
// //   BigInt starsIntToWei(int starsAmount) {
// //     if (starsAmount < 0) return BigInt.zero;
// //     final bigDecimal = BigInt.from(10).pow(_starsTokenDecimals);
// //     // Directly multiply BigInt for integer amounts
// //     return BigInt.from(starsAmount) * bigDecimal;
// //   }

// //   // Helper to convert BigInt Wei to double Stars (for display)
// //   double weiToStarsDouble(BigInt weiAmount, int decimals) {
// //     if (decimals < 0) decimals = 0; // Handle invalid decimals
// //     final bigDecimal = BigInt.from(10).pow(decimals);
// //     if (bigDecimal == BigInt.zero)
// //       return weiAmount
// //           .toDouble(); // Avoid division by zero if decimals somehow 0

// //     try {
// //       final weiDecimal = Decimal.parse(weiAmount.toString());
// //       final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
// //       // Perform division using Decimal and convert to double
// //       return (weiDecimal / bigDecimalDecimal).toDouble();
// //     } catch (e, s) {
// //       print(
// //         "WalletService: Error converting wei $weiAmount to stars double: $e\n$s",
// //       );
// //       // Don't broadcast error for conversion *for display*, just return 0.0
// //       return 0.0;
// //     }
// //   }

// //   // Helper to convert integer Stars amount to BigInt Wei (rounding down, for gifting amount input)
// //   int weiToStarsInt(BigInt weiAmount, int decimals) {
// //     if (decimals < 0) decimals = 0;
// //     final bigDecimal = BigInt.from(10).pow(decimals);
// //     if (bigDecimal == BigInt.zero) return 0;
// //     try {
// //       // Integer division
// //       return (weiAmount ~/ bigDecimal).toInt();
// //     } catch (e, s) {
// //       print(
// //         "WalletService: Error converting wei $weiAmount to stars int: $e\n$s",
// //       );
// //       return 0; // Return 0 on error
// //     }
// //   }

// //   // Helper to convert double native amount to BigInt Wei
// //   BigInt nativeDoubleToWei(double amount) {
// //     // Assuming native currency (ETH, MATIC) has 18 decimals - common standard
// //     try {
// //       if (amount < 0) amount = 0;
// //       final decimalAmount = Decimal.parse(amount.toString());
// //       // Standard ETH/native token decimals is 18
// //       final weiFactor = Decimal.parse(BigInt.from(10).pow(18).toString());
// //       final weiAmountDecimal = decimalAmount * weiFactor;
// //       return BigInt.parse(
// //         weiAmountDecimal.round().toString(),
// //       ); // Round and parse as BigInt
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error in nativeDoubleToWei for amount $amount: $e\n$s',
// //       );
// //       // This conversion happens before sending a tx, so error should be user-facing
// //       _handleModalError(
// //         ModalError("Conversion Error: Invalid native amount entered."),
// //       );
// //       return BigInt.zero;
// //     }
// //   }

// //   // Helper to convert BigInt Wei to double native currency (for display)
// //   double weiToNativeDouble(BigInt weiAmount) {
// //     // Assuming native currency has 18 decimals - common standard (18 decimals)
// //     final bigDecimal = BigInt.from(10).pow(18);
// //     if (bigDecimal == BigInt.zero)
// //       return weiAmount.toDouble(); // Avoid division by zero

// //     try {
// //       final weiDecimal = Decimal.parse(weiAmount.toString());
// //       final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
// //       // Perform division using Decimal and convert to double
// //       return (weiDecimal / bigDecimalDecimal).toDouble();
// //     } catch (e, s) {
// //       print(
// //         "WalletService: Error converting wei $weiAmount to native double: $e\n$s",
// //       );
// //       // Don't broadcast error for conversion *for display*, just return 0.0
// //       return 0.0;
// //     }
// //   }

// //   // Helper to calculate native token amount needed for a given stars amount
// //   double getNativeAmountForStars(int starsAmount) {
// //     if (starsAmount < 0) return 0.0;
// //     try {
// //       final starsDecimal = Decimal.parse(starsAmount.toString());
// //       final rateDecimal = Decimal.parse(_NATIVE_PER_STAR.toString());
// //       final nativeAmountDecimal = starsDecimal * rateDecimal;
// //       return nativeAmountDecimal.toDouble();
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error calculating native amount for stars $starsAmount: $e\n$s',
// //       );
// //       // Conversion error before a tx, potentially user-facing
// //       _handleModalError(
// //         ModalError("Conversion Error: Cannot calculate native cost."),
// //       );
// //       return 0.0;
// //     }
// //   }

// //   // Helper to calculate stars amount for a given native amount
// //   int getStarsAmountForNative(double nativeAmount) {
// //     if (nativeAmount < 0) return 0;
// //     try {
// //       final nativeDecimal = Decimal.parse(nativeAmount.toString());
// //       final rateDecimal = Decimal.parse(_STARS_PER_NATIVE_TOKEN.toString());
// //       final starsAmountDecimal = nativeDecimal * rateDecimal;
// //       // Use floor() as you can only buy whole stars (based on typical tokenomics)
// //       return starsAmountDecimal.floor().toBigInt().toInt();
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error calculating stars for native amount $nativeAmount: $e\n$s',
// //       );
// //       // Conversion error before a tx, potentially user-facing
// //       _handleModalError(
// //         ModalError("Conversion Error: Cannot calculate stars amount."),
// //       );
// //       return 0;
// //     }
// //   }

// //   // Fetch STARS Balance (Made Public)
// //   Future<void> getStarsBalance() async {
// //     print("WalletService: Attempting to get STARS balance.");
// //     // Check _isSepoliaAndReady which includes modal != null check
// //     if (!_isSepoliaAndReady) {
// //       print(
// //         "WalletService: Not ready to get STARS balance. State not Sepolia+Ready.",
// //       );
// //       // Status message should be handled by _updateState or previous fetch attempts
// //       if (!(_starsBalanceDisplay.contains('Loading') ||
// //           _starsBalanceDisplay.contains('Error') ||
// //           _starsBalanceDisplay.contains('Failed'))) {
// //         // Only update if it's not already a loading or error state
// //         _starsBalanceDisplay = 'Not connected to Sepolia'; // Or relevant state
// //       }
// //       notifyListeners(); // Ensure state change is reflected
// //       return;
// //     }

// //     // Only show 'Getting balance...' if we ARE connected to Sepolia and attempting to fetch
// //     if (!_starsBalanceDisplay.contains('Loading')) {
// //       // Prevent overwriting 'Loading...'
// //       _starsBalanceDisplay = 'Getting balance...';
// //       notifyListeners(); // Update UI to show loading state
// //     }

// //     try {
// //       final address = EthereumAddress.fromHex(_connectedAddress!);
// //       final topic = _currentSession?.topic; // Get topic for WC

// //       if (topic == null) {
// //         throw Exception("Session topic is null");
// //       }

// //       // Use requestReadContract which is designed for view/pure functions
// //       final result = await _appKitModal!.requestReadContract(
// //         topic: topic,
// //         chainId: _sepoliaChainId,
// //         deployedContract: _starsTokenContract!, // Use the StarsToken contract
// //         functionName: 'balanceOf', // The standard ERC20 balance function
// //         parameters: [address], // The address to check the balance for
// //       );

// //       if (result.isNotEmpty && result[0] is BigInt) {
// //         _currentStarsBalanceWei = result[0] as BigInt;
// //         final balanceDouble = weiToStarsDouble(
// //           _currentStarsBalanceWei,
// //           _starsTokenDecimals,
// //         );
// //         // Display with a reasonable number of decimal places
// //         String formattedBalance = balanceDouble.toStringAsFixed(4);
// //         // Remove trailing zeros and decimal point if only zeros remain
// //         if (formattedBalance.contains('.')) {
// //           formattedBalance = formattedBalance.replaceAll(RegExp(r'0*$'), '');
// //           if (formattedBalance.endsWith('.')) {
// //             formattedBalance = formattedBalance.substring(
// //               0,
// //               formattedBalance.length - 1,
// //             );
// //           }
// //         }

// //         _starsBalanceDisplay = '$formattedBalance $_starsTokenSymbol';
// //         print("WalletService: Fetched STARS balance: $_starsBalanceDisplay");
// //       } else {
// //         _currentStarsBalanceWei = BigInt.zero;
// //         _starsBalanceDisplay = 'Could not parse balance';
// //         print("WalletService: Failed to parse STARS balance result: $result");
// //         _handleModalError(ModalError('Failed to parse STARS balance.'));
// //       }
// //     } catch (e, s) {
// //       print('WalletService: Error getting STARS balance: $e\n$s');
// //       _currentStarsBalanceWei = BigInt.zero;
// //       _starsBalanceDisplay = 'Error fetching balance';
// //       // Read calls usually don't trigger user rejection directly, but RPC errors can happen
// //       if (e is JsonRpcError) {
// //         print('WalletService: RPC Error fetching balance: ${e.message}');
// //         _handleModalError(
// //           ModalError(
// //             'RPC Error fetching balance: ${e.message ?? "Unknown error"}',
// //           ),
// //         );
// //       } else {
// //         print('WalletService: Unknown Error fetching balance: $e');
// //         _handleModalError(ModalError('Failed to get balance.'));
// //       }
// //     } finally {
// //       notifyListeners(); // Notify UI after fetch (success or failure)
// //     }
// //   }

// //   // Fetch Token Transactions from Etherscan (Made Public)
// //   Future<void> fetchTokenTransactions() async {
// //     print('WalletService: Starting fetchTokenTransactions...');

// //     if (_etherscanApiKey == 'YOUR_ETHERSCAN_API_KEY' ||
// //         _etherscanApiKey.isEmpty) {
// //       print(
// //         "WalletService: WARNING: Etherscan API key is not set. Cannot fetch transactions.",
// //       );
// //       _transactionListStatus =
// //           'Error: Etherscan API key is missing.'; // Clearer message
// //       _transactions = []; // Clear any old data
// //       _isLoadingTransactions = false; // Stop loading state
// //       notifyListeners(); // Update UI
// //       return; // Stop execution if key is missing
// //     }

// //     // Check _isSepoliaAndReady which includes modal != null check
// //     if (!_isSepoliaAndReady) {
// //       print(
// //         "WalletService: Not ready to fetch transactions. State not Sepolia+Ready.",
// //       );
// //       // This case is handled by _updateState clearing the list and setting status
// //       if (_transactionListStatus != 'Error: Etherscan API key is missing.' &&
// //           !(_transactionListStatus.contains('Loading') ||
// //               _transactionListStatus.contains('Error') ||
// //               _transactionListStatus.contains('Failed'))) {
// //         _transactionListStatus = 'Connect to Sepolia to see transactions.';
// //       }
// //       _transactions = []; // Clear any old data if state is not ready
// //       _isLoadingTransactions = false; // Ensure loading is false
// //       notifyListeners(); // Update UI
// //       return;
// //     }

// //     if (_isLoadingTransactions) {
// //       print("WalletService: Transaction fetch already in progress.");
// //       return; // Prevent multiple concurrent calls
// //     }

// //     _isLoadingTransactions = true;
// //     _transactionListStatus =
// //         'Loading transactions...'; // Indicate loading started
// //     // _transactions = []; // Don't clear immediately, show old data while loading if desired, or clear based on UI preference. Keeping old data might make the UI less jumpy. If clearing is preferred, uncomment this.
// //     notifyListeners(); // Update UI to show loading state

// //     final String apiKey = _etherscanApiKey;
// //     final String address = _connectedAddress!;
// //     final String tokenAddress = _starsTokenAddress;
// //     // Use Sepolia-specific API endpoint
// //     final String baseUrl = 'https://api-sepolia.etherscan.io/api';

// //     try {
// //       final url = Uri.parse(
// //         '$baseUrl?module=account&action=tokentx&contractaddress=$tokenAddress&address=$address&page=1&offset=50&sort=desc&apikey=$apiKey',
// //       );

// //       print('WalletService: Fetching transactions from Etherscan: $url');

// //       final response = await get(url);
// //       print(
// //         'WalletService: Received Etherscan response status code: ${response.statusCode}',
// //       );

// //       if (response.statusCode == 200) {
// //         final data = jsonDecode(response.body);
// //         print(
// //           'WalletService: Etherscan API response status: ${data['status']}, message: ${data['message']}',
// //         );

// //         if (data['status'] == '1' && data['result'] is List) {
// //           final List resultList = data['result'];
// //           print('WalletService: Processing ${resultList.length} transactions');

// //           // Filter out potential null entries and handle parsing errors gracefully
// //           final List<TokenTransaction> fetchedTransactions = resultList
// //               .where((json) => json != null)
// //               .map((json) {
// //                 try {
// //                   // Provide contract decimals and symbol during parsing
// //                   return TokenTransaction.fromJson(json);
// //                 } catch (e, s) {
// //                   print(
// //                     'WalletService: Error parsing transaction JSON item: $json\nError: $e\nStack: $s',
// //                   );
// //                   return null; // Return null if parsing fails
// //                 }
// //               })
// //               .where((tx) => tx != null) // Filter out nulls
// //               .cast<
// //                 TokenTransaction
// //               >() // Ensure remaining items are TokenTransaction
// //               .toList();

// //           print(
// //             'WalletService: Successfully fetched and parsed ${fetchedTransactions.length} transactions.',
// //           );

// //           _transactions = fetchedTransactions;
// //           if (_transactions.isEmpty) {
// //             _transactionListStatus =
// //                 'No recent STARS transactions found for this address.';
// //           } else {
// //             _transactionListStatus = ''; // Clear status on success with data
// //           }
// //         } else if (data['status'] == '0' &&
// //             data['message'] == 'No transactions found') {
// //           print('WalletService: Etherscan API: No transactions found.');
// //           _transactionListStatus =
// //               'No recent STARS transactions found for this address.';
// //           _transactions = []; // Ensure list is empty
// //         } else {
// //           // Handle other Etherscan API error status ('0') or unexpected format
// //           final errorMessage = data['message'] ?? 'Unknown error';
// //           print(
// //             'WalletService: Etherscan API error/unexpected format (status ${data['status']}): $errorMessage',
// //           );
// //           _transactionListStatus = 'Etherscan API error: $errorMessage';
// //           _transactions = []; // Clear list on API error
// //         }
// //       } else {
// //         // Handle HTTP error status (e.g., 404, 500)
// //         print(
// //           'WalletService: HTTP Error fetching transactions: ${response.statusCode} - ${response.reasonPhrase}',
// //         );
// //         _transactionListStatus =
// //             'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}';
// //         _transactions = []; // Clear list on HTTP error
// //       }
// //     } catch (e, s) {
// //       // Catch any other exceptions (network, json decoding, parsing errors)
// //       print('WalletService: Error fetching or processing transactions: $e\n$s');
// //       _transactionListStatus =
// //           'Failed to fetch transactions: ${e.runtimeType} - ${e.toString()}';
// //       _transactions = []; // Clear list on general error
// //     } finally {
// //       _isLoadingTransactions = false; // Stop loading animation/indicator
// //       notifyListeners(); // Notify UI after fetch attempt (success or failure)
// //     }
// //   }

// //   // Add STARS Token to Wallet
// //   Future<void> addStarsTokenToWallet() async {
// //     print("WalletService: Attempting to add STARS token to wallet.");
// //     // Check _isSepoliaAndReady which includes modal != null check
// //     if (!_isSepoliaAndReady) {
// //       print("WalletService: Not ready to add STARS token.");
// //       _transactionStatus =
// //           'Error: Wallet not connected to Sepolia or contracts not loaded.';
// //       notifyListeners();
// //       _handleModalError(
// //         ModalError('Please connect to Sepolia to add the token.'),
// //       );
// //       return;
// //     }

// //     _transactionStatus = 'Requesting wallet to add STARS token...';
// //     notifyListeners(); // Update UI status

// //     try {
// //       final watchAssetParams = {
// //         'type': 'ERC20',
// //         'options': {
// //           'address': _starsTokenAddress,
// //           'symbol': _starsTokenSymbol,
// //           'decimals': _starsTokenDecimals,
// //           // 'image': 'URL_TO_YOUR_TOKEN_LOGO', // Optional: Add your token logo URL
// //         },
// //       };

// //       final topic = _currentSession?.topic;
// //       if (topic == null) {
// //         throw Exception("Session topic is null, cannot request add token.");
// //       }

// //       // Use AppKitModal's request method which is designed to handle wallet_watchAsset
// //       // for different underlying wallet types (WC, Magic, etc.)
// //       await _appKitModal!.request(
// //         // Use the active modal instance
// //         topic: topic, // Use the session topic
// //         chainId: _sepoliaChainId, // Specify the chain ID
// //         request: SessionRequestParams(
// //           method: 'wallet_watchAsset', // The method for adding a custom token
// //           params: watchAssetParams,
// //         ),
// //       );

// //       _transactionStatus = 'Wallet prompted to add STARS token.';
// //       print('WalletService: Sent wallet_watchAsset request for STARS token.');
// //       // Refresh balance after adding token (if wallet supports it - not guaranteed to trigger a balance update)
// //       Future.delayed(Duration(seconds: 2), () {
// //         getStarsBalance(); // Call service's method
// //       });
// //     } catch (e, s) {
// //       print(
// //         'WalletService: Error requesting wallet to add STARS token: $e\n$s',
// //       );
// //       _transactionStatus = 'Failed to prompt wallet to add token.';

// //       if (_isUserRejectedError(e)) {
// //         _handleModalError(UserRejectedRequest()); // Use AppKit's specific error
// //       } else if (e is JsonRpcError) {
// //         _handleModalError(
// //           ModalError('RPC Error adding token: ${e.message ?? "Unknown error"}'),
// //         );
// //       } else {
// //         _handleModalError(ModalError('Failed to send add token request.'));
// //       }
// //     } finally {
// //       notifyListeners(); // Update UI status
// //     }
// //   }

// //   // Send Gift Stars (Uses the StarsPlatform contract)
// //   Future<void> sendGiftStars(
// //     String recipientAddressString,
// //     int amountInStars, // Integer amount for gifting
// //   ) async {
// //     print(
// //       "WalletService: Attempting to send gift of $amountInStars STARS to $recipientAddressString",
// //     );

// //     if (amountInStars < 1) {
// //       print("WalletService: Cannot send less than 1 star.");
// //       _transactionStatus = 'Cannot send less than 1 star.';
// //       notifyListeners();
// //       _handleModalError(ModalError('Cannot send less than 1 star.'));
// //       return;
// //     }

// //     // Convert integer amount back to Wei BigInt for the contract call
// //     final amountWei = starsIntToWei(amountInStars);

// //     // Check _isSepoliaAndReady which includes modal != null check
// //     if (!_isSepoliaAndReady) {
// //       print("WalletService: Not ready to send gift.");
// //       _transactionStatus =
// //           'Error: Wallet not connected to Sepolia or contracts not loaded.';
// //       notifyListeners();
// //       _handleModalError(
// //         ModalError(
// //           'Please connect wallet and ensure contracts are loaded on Sepolia.',
// //         ),
// //       );
// //       return;
// //     }

// //     if (recipientAddressString.isEmpty) {
// //       print("WalletService: Recipient address is empty.");
// //       _transactionStatus = 'Error: Recipient address is empty.';
// //       notifyListeners();
// //       _handleModalError(ModalError('Please enter a recipient address.'));
// //       return;
// //     }

// //     EthereumAddress recipientAddress;
// //     try {
// //       // Use EthereumAddress.fromHex with enforceEip55 for better validation
// //       recipientAddress = EthereumAddress.fromHex(
// //         recipientAddressString,
// //         enforceEip55: true,
// //       );
// //       if (recipientAddress.hex.toLowerCase() ==
// //           _connectedAddress!.toLowerCase()) {
// //         print("WalletService: Cannot gift to self.");
// //         _transactionStatus = 'Error: Cannot send gift to yourself.';
// //         notifyListeners();
// //         _handleModalError(ModalError('Cannot send gift to yourself.'));
// //         return;
// //       }
// //     } catch (e) {
// //       print(
// //         "WalletService: Invalid recipient address format or checksum: $recipientAddressString, Error: $e",
// //       );
// //       _transactionStatus = 'Error: Invalid recipient address.';
// //       notifyListeners();
// //       _handleModalError(
// //         ModalError('Invalid recipient address format or checksum.'),
// //       );
// //       return;
// //     }

// //     // Basic balance check
// //     if (_currentStarsBalanceWei < amountWei) {
// //       print(
// //         "WalletService: Insufficient STARS balance for gift (Need $amountWei, have $_currentStarsBalanceWei).",
// //       );
// //       _transactionStatus = 'Error: Insufficient STARS balance.';
// //       notifyListeners();
// //       _handleModalError(ModalError('Insufficient STARS balance.'));
// //       return;
// //     }

// //     // Update status immediately
// //     _transactionStatus =
// //         'Sending $amountInStars $_starsTokenSymbol to ${recipientAddressString.substring(0, 6)}...${recipientAddressString.substring(recipientAddressString.length - 4)}...';
// //     notifyListeners();

// //     try {
// //       final fromAddress = EthereumAddress.fromHex(_connectedAddress!);
// //       final topic = _currentSession?.topic; // Get topic for WC

// //       if (topic == null) {
// //         throw Exception("Session topic is null, cannot send gift.");
// //       }
// //       if (_starsPlatformContract == null) {
// //         throw Exception("StarsPlatform contract not loaded.");
// //       }

// //       print("WalletService: Calling giftStars on platform contract...");
// //       final txHash = await _appKitModal!.requestWriteContract(
// //         // Use the active modal instance
// //         topic: topic,
// //         chainId: _sepoliaChainId,
// //         deployedContract:
// //             _starsPlatformContract!, // Call giftStars on StarsPlatform!
// //         functionName: 'giftStars', // Assuming the function name is 'giftStars'
// //         transaction: Transaction(from: fromAddress), // Specify the sender
// //         parameters: [
// //           recipientAddress, // Recipient address argument
// //           amountWei, // Amount in wei argument (BigInt)
// //         ],
// //       );

// //       _transactionStatus = 'Gift Transaction sent! Hash: $txHash';
// //       print('WalletService: Gift Stars Tx Hash: $txHash');

// //       // Refresh balance and transactions after a short delay for confirmation
// //       // Use a reasonable delay (e.g., 10-20 seconds) for transaction to be mined and indexed
// //       Future.delayed(Duration(seconds: 15), () {
// //         print("WalletService: Delayed fetch after gift transaction.");
// //         getStarsBalance(); // Refresh balance
// //         fetchTokenTransactions(); // Fetch transactions
// //         _transactionStatus = 'Gift sent. Ready.'; // Update final status
// //         notifyListeners(); // Notify UI for final status update
// //       });
// //     } catch (e, s) {
// //       print('WalletService: Error sending gift stars: $e\n$s');
// //       _transactionStatus = 'Gift transaction failed or rejected.';

// //       if (_isUserRejectedError(e)) {
// //         _handleModalError(UserRejectedRequest());
// //       } else if (e is JsonRpcError) {
// //         _handleModalError(
// //           ModalError('RPC Error gifting: ${e.message ?? "Unknown error"}'),
// //         );
// //       } else {
// //         _handleModalError(ModalError('Failed to send gift.'));
// //       }
// //     } finally {
// //       notifyListeners(); // Update UI status (initial failure)
// //     }
// //   }

// //   // Buy STARS tokens (Uses the StarsPlatform contract)
// //   Future<void> buyStars(double amountNative) async {
// //     print(
// //       "WalletService: Attempting to buy STARS with $amountNative native tokens.",
// //     );

// //     if (amountNative <= 0) {
// //       print("WalletService: Buy amount is zero or negative.");
// //       _transactionStatus = 'Error: Invalid buy amount.';
// //       notifyListeners();
// //       _handleModalError(
// //         ModalError('Invalid amount entered. Please enter a positive number.'),
// //       );
// //       return;
// //     }

// //     // Check _isSepoliaAndReady which includes modal != null check
// //     if (!_isSepoliaAndReady) {
// //       print("WalletService: Not ready to buy stars.");
// //       _transactionStatus =
// //           'Error: Wallet not connected to Sepolia or contracts not loaded.';
// //       notifyListeners();
// //       _handleModalError(
// //         ModalError(
// //           'Please connect wallet and ensure contracts are loaded on Sepolia.',
// //         ),
// //       );
// //       return;
// //     }

// //     BigInt amountWei;
// //     try {
// //       // Convert the double native amount to native token Wei (assuming 18 decimals)
// //       amountWei = nativeDoubleToWei(amountNative);
// //       if (amountWei <= BigInt.zero) {
// //         print(
// //           "WalletService: Calculated native amount in wei is zero or negative.",
// //         );
// //         _transactionStatus = 'Error: Amount conversion resulted in zero.';
// //         notifyListeners();
// //         _handleModalError(ModalError('Calculated native amount is too small.'));
// //         return;
// //       }
// //     } catch (e) {
// //       // Error handled inside nativeDoubleToWei and broadcasted
// //       print(
// //         "WalletService: Error converting native amount $amountNative to wei.",
// //       );
// //       _transactionStatus = 'Error: Amount conversion failed.';
// //       notifyListeners();
// //       return;
// //     }

// //     // Check native balance
// //     if (_currentNativeBalanceWei < amountWei) {
// //       print(
// //         "WalletService: Insufficient native balance for buy (Need $amountWei, have $_currentNativeBalanceWei).",
// //       );
// //       _transactionStatus = 'Error: Insufficient native balance.';
// //       notifyListeners();
// //       _handleModalError(
// //         ModalError('Insufficient native balance to complete purchase.'),
// //       );
// //       return;
// //     }

// //     _transactionStatus =
// //         'Buying STARS with ${amountNative.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')} ${_connectedNetwork?.currency ?? "Native"}...';
// //     notifyListeners();

// //     try {
// //       final fromAddress = EthereumAddress.fromHex(_connectedAddress!);
// //       final topic = _currentSession?.topic; // Get topic for WC

// //       if (topic == null) {
// //         throw Exception("Session topic is null, cannot send buy transaction.");
// //       }
// //       if (_starsPlatformContract == null) {
// //         throw Exception("StarsPlatform contract not loaded.");
// //       }

// //       print(
// //         "WalletService: Calling buyStars on platform contract with value $amountWei...",
// //       );
// //       final txHash = await _appKitModal!.requestWriteContract(
// //         // Use the active modal instance
// //         topic: topic,
// //         chainId: _sepoliaChainId,
// //         deployedContract:
// //             _starsPlatformContract!, // Call buyStars on StarsPlatform!
// //         functionName: 'buyStars', // Assuming the function name is 'buyStars'
// //         transaction: Transaction(
// //           from: fromAddress,
// //           value: EtherAmount.inWei(
// //             amountWei,
// //           ), // Send the native currency as value
// //         ),
// //         parameters:
// //             [], // buyStars function takes no explicit parameters (value is sent separately)
// //       );

// //       _transactionStatus = 'Buy Transaction sent! Hash: $txHash';
// //       print('WalletService: Buy Stars Tx Hash: $txHash');

// //       // Refresh balance and transactions after a short delay
// //       // Use a reasonable delay (e.g., 10-20 seconds) for transaction to be mined and indexed
// //       Future.delayed(Duration(seconds: 15), () {
// //         print("WalletService: Delayed fetch after buy transaction.");
// //         getStarsBalance(); // Refresh STARS balance
// //         // _updateNativeBalance is triggered by balanceNotifier listener which fires when native balance changes
// //         fetchTokenTransactions(); // Fetch transactions
// //         _transactionStatus = 'Buy successful. Ready.'; // Update final status
// //         notifyListeners(); // Notify UI for final status update
// //       });
// //     } catch (e, s) {
// //       print('WalletService: Error sending buy stars transaction: $e\n$s');
// //       _transactionStatus = 'Buy transaction failed or rejected.';

// //       if (_isUserRejectedError(e)) {
// //         _handleModalError(UserRejectedRequest());
// //       } else if (e is JsonRpcError) {
// //         _handleModalError(
// //           ModalError('RPC Error buying: ${e.message ?? "Unknown error"}'),
// //         );
// //       } else {
// //         _handleModalError(ModalError('Failed to send buy transaction.'));
// //       }
// //     } finally {
// //       notifyListeners(); // Update UI status (initial failure)
// //     }
// //   }

// //   @override
// //   void dispose() {
// //     print("WalletService: Disposing WalletService...");
// //     // Dispose the modal if it still exists
// //     if (_appKitModal != null) {
// //       print(
// //         "WalletService: Disposing existing _appKitModal instance during service dispose.",
// //       );
// //       try {
// //         // Remove listeners first
// //         _appKitModal!.removeListener(_updateState);
// //         _appKitModal!.balanceNotifier.removeListener(_updateNativeBalance);
// //         _appKitModal!.onModalError.unsubscribe(_handleModalError);
// //         // Dispose the instance
// //         _appKitModal!.dispose();
// //         print("WalletService: _appKitModal disposed.");
// //       } catch (e) {
// //         print("WalletService: Error during final _appKitModal dispose: $e");
// //       } finally {
// //         _appKitModal = null;
// //       }
// //     }
// //     print("WalletService: WalletService disposed.");
// //     super.dispose();
// //   }
// // }

// import 'dart:convert';

// import 'package:decimal/decimal.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:http/http.dart'; // For fetching Etherscan data
// import 'package:my_secure_wallet_app/token.dart'; // Assuming you have this model
// import 'package:reown_appkit/modal/i_appkit_modal_impl.dart';
// import 'package:reown_appkit/modal/services/coinbase_service/i_coinbase_service.dart';
// import 'package:reown_appkit/modal/services/third_party_wallet_service.dart'; // For ThirdPartyWalletException
// import 'package:reown_appkit/reown_appkit.dart';

// const String _etherscanApiKey =
//     'DUGGC885HI87T28EAFB4WECBS57X1JGQKN'; // !! Replace with your actual key or use a secure method !!

// // Ensure you have a valid Etherscan API key. If not, transactions will fail.
// // const String _etherscanApiKey = 'YOUR_ETHERSCAN_API_KEY';

// const double _STARS_PER_NATIVE_TOKEN = 100.0;
// const double _NATIVE_PER_STAR = 1.0 / _STARS_PER_NATIVE_TOKEN;

// class WalletService extends ChangeNotifier {
//   // --- AppKitModal Instance ---
//   ReownAppKitModal? _appKitModal; // Made nullable
//   // Removed _isInitialized flag - presence of _appKitModal will indicate if modal was created

//   // --- State Variables (Keep private and expose via getters) ---
//   ReownAppKitModalStatus _status = ReownAppKitModalStatus.idle;
//   @override // Added override for status getter
//   ReownAppKitModalStatus get status => _status;

//   ReownAppKitModalNetworkInfo? _connectedNetwork;
//   @override // Added override
//   ReownAppKitModalNetworkInfo? get connectedNetwork => _connectedNetwork;

//   ReownAppKitModalSession? _currentSession;
//   @override // Added override
//   ReownAppKitModalSession? get currentSession => _currentSession;

//   String? _connectedAddress;
//   String? _connectedWalletName;
//   BigInt _currentNativeBalanceWei = BigInt.zero; // Fetched via RPC
//   BigInt _currentStarsBalanceWei = BigInt.zero; // Fetched via Contract Read
//   String _starsBalanceDisplay =
//       'Connect to see balance'; // Formatted display string

//   // Contract Details (Move from UI)
//   final String _sepoliaChainId = 'eip155:11155111';
//   final String _starsTokenAddress =
//       '0x185239e90BBb3810c27671aaCFA7d9b3c26Da22C'; // Example Sepolia Token Address
//   final String _starsPlatformAddress =
//       '0xA14536b87f485F266560b218f6f19D0eCAB070d1'; // Example Sepolia Platform Address
//   final int _starsTokenDecimals = 18;
//   final String _starsTokenSymbol = 'STR';

//   // Deployed Contracts
//   DeployedContract? _starsTokenContract;
//   DeployedContract? _starsPlatformContract;
//   bool _areContractsLoaded = false; // Flag for ABI loading status

//   // Transaction/Action Status
//   String _transactionStatus = 'Ready.'; // General status for user actions

//   // Transaction List State
//   List<TokenTransaction> _transactions = [];
//   bool _isLoadingTransactions = false;
//   String _transactionListStatus =
//       'Connect to see transactions'; // Status for the list area

//   // Flag to track if initial data fetch has been attempted for the current Sepolia connection
//   bool _hasFetchedInitialData = false;

//   // Store the BuildContext needed for modal creation
//   BuildContext? _context; // Will be set by init

//   // Add isDisposed getter as required by ChangeNotifier
//   @override
//   // bool get isDisposed {
//   //   // Use the super.isDisposed from ChangeNotifier
//   //   return super.isDisposed;
//   // }
//   // --- Getters to Expose State to UI ---
//   // Removed the appKitModal getter as it might be null
//   ReownAppKitModal get appKitModal => _appKitModal!; // Expose the modal instance

//   bool get isConnected =>
//       _status == ReownAppKitModalStatus.initialized && _currentSession != null;

//   String? get connectedAddress => _connectedAddress;
//   String? get connectedWalletName => _connectedWalletName;
//   BigInt get currentNativeBalanceWei => _currentNativeBalanceWei;
//   BigInt get currentStarsBalanceWei => _currentStarsBalanceWei;
//   String get starsBalanceDisplay => _starsBalanceDisplay;

//   String get sepoliaChainId => _sepoliaChainId;
//   String get starsTokenAddress => _starsTokenAddress;
//   String get starsPlatformAddress => _starsPlatformAddress;
//   int get starsTokenDecimals => _starsTokenDecimals;
//   String get starsTokenSymbol => _starsTokenSymbol;

//   bool get areContractsLoaded => _areContractsLoaded;

//   String get transactionStatus => _transactionStatus;
//   // Setter for transactionStatus if other parts of the service need to update it
//   set transactionStatus(String status) {
//     if (_transactionStatus != status) {
//       _transactionStatus = status;
//       notifyListeners();
//     }
//   }

//   List<TokenTransaction> get transactions => _transactions;
//   bool get isLoadingTransactions => _isLoadingTransactions;
//   String get transactionListStatus => _transactionListStatus;

//   // Conversion Rates (expose as getters)
//   double get starsPerNativeToken => _STARS_PER_NATIVE_TOKEN;
//   double get nativePerStar => _NATIVE_PER_STAR;

//   // Helper getter to check if we are connected to Sepolia and have loaded contracts
//   bool get _isSepoliaAndReady {
//     // Also check if modal instance is valid
//     return _appKitModal != null &&
//         isConnected &&
//         _connectedNetwork?.chainId == _sepoliaChainId &&
//         _connectedAddress != null &&
//         _currentSession != null &&
//         _areContractsLoaded;
//   }

//   // --- Initialization ---
//   // Initial service setup, primarily loads ABIs
//   Future<void> init(BuildContext context) async {
//     print('WalletService: Starting service initialization...');
//     _context = context; // Store context for later modal creation

//     // Start loading contracts asynchronously, but don't block init()
//     await _loadContractAbis();

//     print('WalletService: Service initialization complete.');
//     // No need to call notifyListeners() here unless statuses change immediately
//     // _updateState listener will handle state changes once modal is created/connected.
//   }

//   void _resetState() {
//     _status = ReownAppKitModalStatus.idle;
//     _connectedNetwork = null;
//     _currentSession = null;
//     _connectedAddress = null;
//     _connectedWalletName = null;
//     _currentNativeBalanceWei = BigInt.zero;
//     _currentStarsBalanceWei = BigInt.zero;
//     _starsBalanceDisplay = 'Connect to see balance';
//     _transactionStatus = 'Ready.';
//     _transactions = [];
//     _transactionListStatus = 'Connect to see transactions';
//     _hasFetchedInitialData = false;
//     notifyListeners();
//   }

//   // --- Connect Wallet Method (Called by UI Button) ---
//   Future<void> connectWallet(BuildContext context) async {
//     print('WalletService: Connect Wallet requested.');

//     // If modal exists, clean it up first to ensure a fresh state
//     if (_appKitModal != null) {
//       print(
//         'WalletService: Existing AppKitModal instance found. Cleaning up before new connection.',
//       );
//       await _performLocalCleanup();
//     }
//     // Check if a modal instance already exists and is potentially active
//     if (_appKitModal != null) {
//       print(
//         'WalletService: AppKitModal instance already exists. Calling openModalView() on existing instance.',
//       );
//       try {
//         // Status should already reflect initialized or connecting if instance exists
//         if (_status == ReownAppKitModalStatus.idle) {
//           _status = ReownAppKitModalStatus
//               .initializing; // Indicate connecting state if modal was idle
//           _transactionStatus = 'Opening wallet connection modal...';
//           notifyListeners();
//         } else {
//           print(
//             'WalletService: AppKitModal status is already $_status, not changing status immediately.',
//           );
//         }
//         // Open the modal UI on the existing instance
//         await _appKitModal!.openModalView(); // <-- This is correct
//         print(
//           'WalletService: Called openModalView() on existing modal instance.',
//         );
//         // _updateState listener will handle subsequent status changes
//       } catch (e, s) {
//         print(
//           'WalletService: Error calling openModalView() on existing modal: $e\n$s',
//         );
//         // Handle errors if opening the modal fails
//         _status = ReownAppKitModalStatus.error; // Update status on error
//         _transactionStatus = 'Failed to open wallet modal.';
//         notifyListeners();
//         _handleModalError(
//           ModalError('Failed to open wallet modal. Check console for details.'),
//         );
//       }
//       return; // Exit if we used an existing instance
//     }

//     print('WalletService: Creating a new AppKitModal instance...');
//     _status = ReownAppKitModalStatus.initializing; // Set status before creation
//     _transactionStatus = 'Initializing wallet connection...';
//     notifyListeners(); // Update UI immediately

//     try {
//       // Create a NEW instance
//       _appKitModal = ReownAppKitModal(
//         context: context, // Use the provided context
//         projectId:
//             'ccf4925f727ee0d480bb502cce820edf', // Replace with your Project ID
//         metadata: const PairingMetadata(
//           name: 'Secure Wallet App', // App Name
//           description: 'A secure wallet application', // App Description
//           url: 'https://reown.com/', // Your Website URL
//           icons: ['https://reown.com/logo.png'], // Your App Icon URL
//           redirect: Redirect(
//             native: 'mysecurewalletapp://', // Your app's deep link scheme
//             universal:
//                 'https://reown.com/mysecurewalletapp', // Your universal link
//           ),
//         ),
//         requiredNamespaces: {
//           'eip155': RequiredNamespace(
//             chains: [_sepoliaChainId], // Specify required chains
//             methods: [
//               'eth_sendTransaction',
//               'eth_signTypedData_v4',
//               'personal_sign',
//               'eth_call', // Required for read calls
//               'wallet_switchEthChain',
//               'wallet_addEthChain',
//               'wallet_watchAsset', // Required for add token
//             ],
//             events: ['chainChanged', 'accountsChanged'],
//           ),
//         },
//         logLevel: LogLevel.debug,
//       );

//       print('WalletService: Adding listeners to new modal instance...');
//       // Add listeners to the *new* instance
//       // It's safe to add listeners *before* init, they will queue events
//       _appKitModal!.addListener(_updateState);
//       _appKitModal!.balanceNotifier.addListener(_updateNativeBalance);
//       _appKitModal!.onModalError.subscribe(_handleModalError);

//       print('WalletService: Initializing new AppKitModal instance...');
//       await _appKitModal!.init(); // Initialize the new instance

//       // After successful init, status is likely initialized (if no session) or connecting/initialized (if resuming session)
//       // _updateState will be triggered by init setting the status.
//       // We now proceed to open the modal UI.

//       print('WalletService: Calling openModalView() on new modal instance...');
//       // Call openModalView to show the wallet selection UI
//       // Ensure modal is still valid before calling
//       if (_appKitModal != null) {
//         await _appKitModal!.openModalView(); // This should now be safe
//         print('WalletService: Called openModalView() on new modal instance.');
//       } else {
//         // This case implies _updateState triggered cleanup unexpectedly after init
//         print(
//           'WalletService: AppKitModal instance became null/disposed immediately after init. Cannot call openModalView.',
//         );
//         // The error handling block below will catch this implicit failure
//         throw Exception(
//           "Wallet connection modal became unavailable after initialization.",
//         );
//       }

//       // _updateState listener will handle state transitions after openModalView()
//       // is called and modal state updates based on user interaction.
//     } catch (e, s) {
//       print(
//         'WalletService: Error during new AppKitModal creation/opening: $e\n$s',
//       );
//       // Ensure _appKitModal is null and clean up if creation failed midway
//       // The _performLocalCleanup method handles setting _appKitModal = null internally
//       if (_appKitModal != null) {
//         print('WalletService: Attempting cleanup of failed modal instance.');
//         await _performLocalCleanup(); // Force cleanup on creation/opening error
//       } else {
//         print(
//           'WalletService: No valid modal instance to clean up during error.',
//         );
//         // If modal was already null/disposed, just reset service state
//         _status = ReownAppKitModalStatus.error;
//         _connectedNetwork = null;
//         _currentSession = null;
//         _connectedAddress = null;
//         _connectedWalletName = null;
//         _currentNativeBalanceWei = BigInt.zero;
//         _currentStarsBalanceWei = BigInt.zero;
//         _starsBalanceDisplay = 'Connection failed.';
//         _transactionStatus = 'Connection failed.';
//         _transactions = [];
//         _transactionListStatus = 'Connection failed.';
//         _hasFetchedInitialData = false;
//         notifyListeners();
//       }

//       _handleModalError(
//         ModalError("Failed to connect wallet. Check console for details."),
//       );
//     }
//   }

//   // This listener reacts to *any* state change in AppKitModal
//   void _updateState() {
//     print(
//       'WalletService: _updateState called. AppKitModal Status: ${_appKitModal?.status}, isConnected: ${_appKitModal?.isConnected}',
//     );
//     print('WalletService: Current Sepolia target chainId: $_sepoliaChainId');

//     // Check if _appKitModal is still valid (not null or disposed)
//     if (_appKitModal == null) {
//       print(
//         'WalletService: _updateState called but _appKitModal is null or disposed. Skipping state update.',
//       );
//       // If modal is gone, state *should* already be idle and session data cleared by _performLocalCleanup
//       // If state isn't idle, something went wrong in cleanup, but we can't rely on modal anymore.
//       return;
//     }

//     // Capture the new state from AppKitModal properties using the current _appKitModal! instance
//     final newStatus = _appKitModal!.status;
//     final bool newIsConnected = _appKitModal!.isConnected;
//     final ReownAppKitModalSession? newSession = _appKitModal!.session;
//     final ReownAppKitModalNetworkInfo? newConnectedNetwork =
//         _appKitModal!.selectedChain;

//     // Determine if the *relevant* connected state has changed
//     final bool wasConnectedAndReady =
//         _isSepoliaAndReady; // State before this update
//     final bool isNowConnectedAndReady =
//         newIsConnected && // Use new values
//         newConnectedNetwork?.chainId == _sepoliaChainId &&
//         newSession != null &&
//         _areContractsLoaded; // Use service flag for contracts

//     // --- Update Service State based on New Modal State ---
//     bool stateChanged = false;

//     // Update core connection state variables
//     if (_status != newStatus) {
//       _status = newStatus;
//       stateChanged = true;
//       print('Status changed to $_status');
//     }
//     if (_currentSession != newSession) {
//       _currentSession = newSession;
//       stateChanged = true;
//       print('Session changed');
//     }
//     if (_connectedNetwork != newConnectedNetwork) {
//       _connectedNetwork = newConnectedNetwork;
//       stateChanged = true;
//       print('Network changed to ${newConnectedNetwork?.chainId}');
//     }

//     // Update derived connection state variables (address, wallet name)
//     String? derivedAddress = null;
//     String? derivedWalletName = null;

//     if (newIsConnected && newSession != null && newConnectedNetwork != null) {
//       final namespace = NamespaceUtils.getNamespaceFromChain(
//         newConnectedNetwork.chainId,
//       );
//       try {
//         derivedAddress = newSession.getAddress(namespace);
//       } catch (e) {
//         print(
//           "WalletService: Could not get address for namespace $namespace on update: $e",
//         );
//       }
//       derivedWalletName =
//           newSession.peer?.metadata.name ??
//           newSession.sessionEmail ??
//           newSession.sessionUsername ??
//           'Unknown Wallet';
//     }

//     if (_connectedAddress != derivedAddress) {
//       _connectedAddress = derivedAddress;
//       stateChanged = true;
//       print('Address changed');
//     }
//     if (_connectedWalletName != derivedWalletName) {
//       _connectedWalletName = derivedWalletName;
//       stateChanged = true;
//       print('Wallet name changed');
//     }

//     // --- Handle Data Fetching / Status Messages based on Sepolia+Ready Transition ---

//     // Case 1: Transitioning *into* the Sepolia+Ready state for the first time in this session
//     if (isNowConnectedAndReady &&
//         !wasConnectedAndReady &&
//         !_hasFetchedInitialData) {
//       print(
//         "WalletService: Transitioned to Sepolia+Ready state. Triggering initial data fetch.",
//       );
//       // Use Future.microtask to ensure this runs after all listeners
//       // have processed the current state update, preventing potential re-entrancy issues.
//       Future.microtask(() {
//         // Double-check state before fetching in case it changed again very quickly
//         if (_isSepoliaAndReady && !_hasFetchedInitialData) {
//           _fetchInitialData(); // _fetchInitialData sets _hasFetchedInitialData = true
//         } else {
//           print(
//             "WalletService: State changed again before initial fetch could run.",
//           );
//         }
//       });
//       // Set loading status immediately while waiting for the scheduled fetch
//       _starsBalanceDisplay = 'Loading...';
//       _transactionListStatus = 'Loading...';
//       _transactionStatus = 'Connected to Sepolia. Loading data...';
//       stateChanged = true; // Statuses changed, need to notify
//     }
//     // Case 2: Already in the Sepolia+Ready state and data was fetched.
//     else if (isNowConnectedAndReady && _hasFetchedInitialData) {
//       // Status messages should reflect operational state ('Ready') unless overrides exist
//       if (!_transactionStatus.contains('Loading') &&
//           !_transactionStatus.contains('Error') &&
//           !_transactionStatus.contains('Failed') &&
//           _transactionStatus !=
//               'Ready to transact on Sepolia.') // Check if it's already the desired state
//       {
//         _transactionStatus = 'Ready to transact on Sepolia.';
//         stateChanged = true;
//       }
//       if (_transactionListStatus != 'Error: Etherscan API key is missing.' &&
//           !_transactionListStatus.contains('Loading') &&
//           !_transactionListStatus.contains('Error') &&
//           !_transactionListStatus.contains('Failed')) {
//         if (_transactions.isEmpty &&
//             _transactionListStatus !=
//                 'No recent STARS transactions found for this address.') {
//           _transactionListStatus =
//               'No recent STARS transactions found for this address.';
//           stateChanged = true;
//         } else if (_transactions.isNotEmpty && _transactionListStatus != '') {
//           _transactionListStatus = ''; // Clear status if list is populated
//           stateChanged = true;
//         }
//       }
//       // starsBalanceDisplay is managed by getStarsBalance() - check stateChanged after fetch completes
//     }
//     // Case 3: Connected to a network, but NOT Sepolia
//     else if (newIsConnected &&
//         newConnectedNetwork?.chainId != _sepoliaChainId) {
//       print(
//         'WalletService: Connected to non-Sepolia chain (${newConnectedNetwork?.chainId}). Resetting Sepolia states.',
//       );
//       // Only reset if we were previously Sepolia+Ready or had Sepolia data displayed
//       if (wasConnectedAndReady ||
//           _hasFetchedInitialData ||
//           _starsBalanceDisplay != 'Connect to see balance' ||
//           _transactionListStatus != 'Connect to see transactions') {
//         _starsBalanceDisplay = 'Switch wallet to Sepolia to see balance';
//         _transactionStatus = 'Switch wallet to Sepolia to transact';
//         _transactions = []; // Clear Sepolia transactions
//         _transactionListStatus = 'Switch wallet to Sepolia to see transactions';
//         // Don't reset native balance immediately, it might still show the non-Sepolia balance from balanceNotifier
//         _currentStarsBalanceWei = BigInt.zero; // Reset Sepolia-specific balance
//         _currentStarsBalanceWei = BigInt.zero; // Ensure STARS is zero
//         _hasFetchedInitialData = false; // Reset fetch flag
//         stateChanged = true;
//         print(
//           'WalletService: Sepolia specific states reset due to non-Sepolia connection.',
//         );
//       } else {
//         print(
//           'WalletService: Sepolia specific states already reflect non-Sepolia connection.',
//         );
//       }
//     }
//     // Case 4: Not connected (and modal instance is still valid)
//     else if (!newIsConnected) {
//       print(
//         'WalletService: Not connected (modal still valid). Status reflects state.',
//       );
//       // This might be during connecting, or if a wallet disconnects but AppKitModal hasn't disposed yet.
//       // The _performLocalCleanup should be triggered by onSessionDelete or explicit disconnect.
//       // Ensure display reflects 'Connect' state if not already loading/error/disconnecting
//       if (!newStatus.toString().contains('connecting') &&
//           !newStatus.toString().contains('initializing') &&
//           !newStatus.toString().contains('disconnecting') &&
//           _starsBalanceDisplay != 'Connect to see balance') {
//         // Reset display states if modal is not in a transition state
//         _connectedAddress = null;
//         _connectedWalletName = null;
//         _currentSession = null;
//         _connectedNetwork = null; // Clear network info
//         _currentNativeBalanceWei = BigInt.zero;
//         _currentStarsBalanceWei = BigInt.zero;
//         _starsBalanceDisplay = 'Connect to see balance';
//         _transactionStatus = 'Ready.'; // Reset to initial state
//         _transactions = [];
//         _transactionListStatus = 'Connect to see transactions';
//         _hasFetchedInitialData = false; // Reset fetch flag
//         stateChanged = true;
//         print(
//           'WalletService: Display states reset due to not connected status.',
//         );
//       }
//     }
//     // If _appKitModal is null/disposed, the initial check at the top handles it.

//     // Only notify if state variables potentially changed and cleanup wasn't performed
//     // We explicitly check for _appKitModal != null && !_appKitModal!.isDisposed here
//     // because if cleanup happened, notifyListeners is called there, and we shouldn't
//     // notify again using potentially outdated state captured *before* cleanup.
//     if (stateChanged && _appKitModal != null) {
//       print('WalletService: Notifying listeners of state change');
//       notifyListeners();
//     } else if (stateChanged) {
//       print(
//         'WalletService: State changed but modal is null/disposed. Assuming cleanup already notified.',
//       );
//     } else {
//       print(
//         'WalletService: _updateState finished, no state changes detected requiring notification.',
//       );
//     }
//   }

//   // This method is called by the library's _onSessionDelete handler
//   // It is the intended way to clean up after a session ends.
//   Future<void> _cleanSession({dynamic args, bool event = true}) async {
//     print('WalletService: _cleanSession called by AppKitModal event.');
//     // This method directly triggers the cleanup and state reset
//     await _performLocalCleanup(); // _performLocalCleanup will set _appKitModal = null and notifyListeners
//     // No need to notify here, _performLocalCleanup does it
//   }

//   // Method called by UI to disconnect
//   Future<void> disconnect() async {
//     print('WalletService: Requesting disconnect...');

//     if (_appKitModal == null || !_appKitModal!.isConnected) {
//       _resetState();
//       return;
//     }
//     // Check if there's a modal instance that is currently connected
//     if (_appKitModal == null || !_appKitModal!.isConnected) {
//       print(
//         'WalletService: AppKitModal instance is null, disposed, or not connected. Performing local cleanup directly.',
//       );
//       // Already in a disconnected state, ensure local cleanup is done
//       if (_appKitModal != null) {
//         // Only perform cleanup if there was a valid instance
//         await _performLocalCleanup(); // This will set _appKitModal = null and notify
//       } else {
//         print(
//           'WalletService: No valid modal instance found, ensuring service state is reset.',
//         );
//         // If already null/disposed, just ensure service state is reset
//         _status = ReownAppKitModalStatus.idle;
//         _connectedNetwork = null;
//         _currentSession = null;
//         _connectedAddress = null;
//         _connectedWalletName = null;
//         _currentNativeBalanceWei = BigInt.zero;
//         _currentStarsBalanceWei = BigInt.zero;
//         _starsBalanceDisplay = 'Connect to see balance';
//         _transactionStatus = 'Ready.';
//         _transactions = [];
//         _transactionListStatus = 'Connect to see transactions';
//         _hasFetchedInitialData = false;
//         notifyListeners(); // Notify after state reset
//       }
//       return;
//     }

//     _status = ReownAppKitModalStatus.initializing;
//     _transactionStatus = 'Disconnecting...';
//     notifyListeners(); // Update UI status

//     try {
//       print('WalletService: Calling appKitModal.disconnect()...');
//       // Calling this should trigger the onSessionDelete event internally in AppKitModal,
//       // which in turn calls our _cleanSession handler, which calls _performLocalCleanup.
//       await _appKitModal!.disconnect();
//       print(
//         'WalletService: appKitModal.disconnect() returned. Expecting _cleanSession via event.',
//       );
//       // Explicitly call cleanup after disconnect, even if onSessionDelete event is expected
//       await _performLocalCleanup();
//       print('WalletService: Cleanup completed after disconnect.');
//     } catch (e, s) {
//       print('WalletService: Error during disconnect request: $e\n$s');
//       _transactionStatus = 'Error requesting disconnect.';
//       // If the disconnect *request* itself failed, the session might still be active or in a bad state.
//       // In this error case, we force local cleanup to reset our service state.
//       await _performLocalCleanup(); // Force cleanup on error
//       // Decide if you want to broadcast a modal error for disconnect issues
//       _handleModalError(
//         ModalError('Failed to disconnect properly. Please check wallet app.'),
//       );
//     } finally {
//       // notifyListeners() was already called above and will be called by _performLocalCleanup
//     }
//   }

//   // Perform local cleanup - dispose modal, reset state
//   Future<void> _performLocalCleanup() async {
//     // This method is the SOLE place responsible for setting _appKitModal = null
//     // It is called by:
//     // 1. The _cleanSession handler (which reacts to onSessionDelete from AppKitModal)
//     // 2. The error handling path in connectWallet (if creation/opening fails)
//     // 3. The error handling path in disconnect (if the disconnect request fails)
//     // 4. The dispose() method (as a final failsafe)

//     if (_appKitModal == null) {
//       print(
//         'WalletService: _performLocalCleanup called but _appKitModal is null or disposed. Skipping modal specific cleanup.',
//       );
//       // Still reset service state if it somehow wasn't reset
//       if (_status != ReownAppKitModalStatus.idle) {
//         _status = ReownAppKitModalStatus.idle;
//         _connectedNetwork = null;
//         _currentSession = null;
//         _connectedAddress = null;
//         _connectedWalletName = null;
//         _currentNativeBalanceWei = BigInt.zero;
//         _currentStarsBalanceWei = BigInt.zero;
//         _starsBalanceDisplay = 'Connect to see balance';
//         _transactionStatus = 'Ready.'; // Or 'Connect to transact'
//         _transactions = [];
//         _transactionListStatus = 'Connect to see transactions';
//         _hasFetchedInitialData = false;
//         notifyListeners();
//       }
//       return;
//     }
//     print('WalletService: Performing local cleanup for modal instance...');

//     // Remove listeners from the SPECIFIC instance before disposing it
//     try {
//       print('WalletService: Removing listeners...');
//       // Check if listeners were actually added (e.g., if init/connect succeeded enough to add them)
//       // removeListener and unsubscribe are generally safe even if listener wasn't added.
//       _appKitModal!.removeListener(_updateState);
//       _appKitModal!.balanceNotifier.removeListener(_updateNativeBalance);
//       _appKitModal!.onModalError.unsubscribe(_handleModalError);
//       print('WalletService: Listeners removed.');
//     } catch (e) {
//       print(
//         'WalletService: Error removing listeners (may indicate listeners weren\'t fully added or instance is unstable): $e',
//       );
//       // Continue cleanup even if listener removal fails
//     }

//     // Dispose the modal instance
//     try {
//       print('WalletService: Disposing AppKitModal instance...');
//       await _appKitModal!.dispose(); // Use await as dispose might be async
//       print('WalletService: AppKitModal instance disposed.');
//     } catch (e) {
//       print('WalletService: Error disposing AppKitModal instance: $e');
//       // Continue cleanup even if dispose fails
//     } finally {
//       _appKitModal = null; // Set to null regardless of dispose success
//     }

//     // Reset all service state variables related to connection/session
//     print('WalletService: Resetting service state...');
//     _status = ReownAppKitModalStatus.idle; // Set final status
//     _connectedNetwork = null;
//     _currentSession = null;
//     _connectedAddress = null;
//     _connectedWalletName = null;
//     _currentNativeBalanceWei = BigInt.zero;
//     _currentStarsBalanceWei = BigInt.zero;
//     _starsBalanceDisplay = 'Connect to see balance';
//     _transactionStatus = 'Ready.'; // Or 'Connect to transact'
//     _transactions = []; // Clear transactions
//     _transactionListStatus = 'Connect to see transactions';
//     _hasFetchedInitialData = false; // Reset fetch flag

//     print('WalletService: Local cleanup complete.');
//     notifyListeners(); // Notify UI after cleanup
//   }

//   // Helper to trigger initial data fetches when state is ready
//   void _fetchInitialData() {
//     // This method is called when transitioning TO Sepolia+Ready state for the first time.
//     if (_hasFetchedInitialData) {
//       print(
//         "WalletService: _fetchInitialData called but flag already true. Skipping.",
//       );
//       return; // Prevent re-triggering within the same session
//     }
//     // Ensure modal is valid before fetching anything
//     if (_appKitModal == null) {
//       print(
//         "WalletService: Cannot fetch initial data, modal is null or disposed.",
//       );
//       // Reset state related to fetching if it's stuck
//       _starsBalanceDisplay = 'Error fetching balance';
//       _transactionListStatus = 'Error fetching transactions';
//       _transactionStatus = 'Error fetching data';
//       // state should already reflect not connected/error, notify might be needed
//       notifyListeners();
//       return;
//     }

//     print(
//       "WalletService: Calling _fetchInitialData(). Setting flag and status.",
//     );
//     _hasFetchedInitialData = true; // Set the flag

//     // Set loading statuses immediately
//     // These will be overwritten by the fetch results or errors
//     _starsBalanceDisplay = 'Fetching balance...';
//     _transactionListStatus = 'Fetching transactions...';
//     _transactionStatus = 'Fetching data...';
//     notifyListeners(); // Notify UI to show these initial loading states

//     _updateNativeBalance(); // Get native balance via RPC request (handles null/disposed check internally)
//     getStarsBalance(); // Fetch STARS balance (handles null/disposed check internally)
//     fetchTokenTransactions(); // Fetch transactions (handles null/disposed check internally)

//     // The fetch methods themselves will call notifyListeners() again when complete.
//   }

//   // This is called by the balanceNotifier listener OR explicitly in _fetchInitialData
//   void _updateNativeBalance() async {
//     print("WalletService: _updateNativeBalance triggered.");

//     // Ensure we have a valid modal, session, address, and are on Sepolia
//     if (_appKitModal == null ||
//         !isConnected ||
//         _connectedNetwork?.chainId != _sepoliaChainId ||
//         _connectedAddress == null ||
//         _currentSession == null) {
//       print(
//         "WalletService: _updateNativeBalance skipped - not connected to Sepolia or missing data.",
//       );
//       // If we are not connected to Sepolia, native balance isn't relevant for Sepolia context
//       // The core state update in _updateState handles resetting the balance display
//       // However, if this listener fires *after* disconnect but before _updateState resets,
//       // ensure we don't try to set a non-zero Sepolia balance.
//       if (_currentNativeBalanceWei != BigInt.zero) {
//         _currentNativeBalanceWei = BigInt.zero;
//         notifyListeners(); // Notify if balance reset
//       }
//       return; // Exit early
//     }

//     // Fetch the balance using the currently active modal instance
//     print(
//       "WalletService: _updateNativeBalance fetching raw balance via RPC for address $_connectedAddress...",
//     );

//     try {
//       final address = EthereumAddress.fromHex(_connectedAddress!);
//       final topic = _currentSession?.topic; // Get topic for WC

//       if (topic == null) {
//         print(
//           "WalletService: _updateNativeBalance skipped - session topic is null.",
//         );
//         if (_currentNativeBalanceWei != BigInt.zero) {
//           _currentNativeBalanceWei = BigInt.zero;
//           notifyListeners(); // Notify if balance reset
//         }
//         return; // Exit if topic is null
//       }

//       // Explicitly request the balance using the modal's request method
//       final dynamic result = await _appKitModal!.request(
//         topic: topic,
//         chainId: _sepoliaChainId, // Request balance for the Sepolia chain
//         request: SessionRequestParams(
//           method: 'eth_getBalance',
//           params: [address.hex, 'latest'],
//         ),
//       );

//       if (result is String && result.startsWith('0x')) {
//         final balance = BigInt.parse(result.substring(2), radix: 16);
//         if (_currentNativeBalanceWei != balance) {
//           _currentNativeBalanceWei = balance;
//           print(
//             "WalletService: Native balance updated via RPC: $_currentNativeBalanceWei wei",
//           );
//           // No need to notify here, the finally block handles it
//         } else {
//           print("WalletService: Native balance fetched but unchanged.");
//         }
//       } else {
//         print(
//           "WalletService: Unexpected result format from eth_getBalance: $result",
//         );
//         if (_currentNativeBalanceWei != BigInt.zero) {
//           _currentNativeBalanceWei = BigInt.zero;
//           // No need to notify here, the finally block handles it
//         } else {
//           print(
//             "WalletService: Native balance result unexpected but was already zero.",
//           );
//         }
//       }
//     } catch (e, s) {
//       print("WalletService: Error updating native balance via RPC: $e\n$s");
//       if (_currentNativeBalanceWei != BigInt.zero) {
//         _currentNativeBalanceWei = BigInt.zero;
//         // No need to notify here, the finally block handles it
//       }
//       // Don't necessarily broadcast a modal error for background balance updates
//     } finally {
//       // Always notify listeners at the end of the async operation
//       notifyListeners();
//     }
//   }

//   // Handle errors from AppKitModal
//   void _handleModalError(ModalError? event) {
//     print('WalletService: AppKit Modal Error: ${event?.message}');
//     if (event?.message != null && event!.message.isNotEmpty) {
//       // You might want to expose this error to the UI differently,
//       // maybe store the last error message and display it somewhere.
//       // For now, we just print and notify.
//       // You could also trigger a Snackbar here using the stored context if available.
//       // Use the stored context safely
//       if (_context != null && _context!.mounted) {
//         // Use a small delay to ensure context is still valid, especially after modal close
//         Future.delayed(Duration(milliseconds: 100), () {
//           if (_context!.mounted) {
//             // Double check context mounted state
//             ScaffoldMessenger.of(_context!).showSnackBar(
//               SnackBar(content: Text('Wallet Error: ${event.message}')),
//             );
//           }
//         });
//       }
//     }
//     // notifyListeners(); // Notification happens when status changes in _updateState
//   }

//   // Helper to check if an error is likely a user rejecting the request
//   bool _isUserRejectedError(dynamic e) {
//     // Check standard RPC error codes for user rejection (e.g., 4001)
//     // and common error message patterns.
//     final regexp = RegExp(
//       r'\b(rejected|cancelled|disapproved|denied|User canceled|User denied)\b',
//       caseSensitive: false,
//     );

//     // Use instanceof checks for specific AppKit/Core error types if available
//     if (e is UserRejectedRequest) return true; // AppKit specific

//     if (e is JsonRpcError) {
//       // Standard EIP-1193 user rejected request code
//       if (e.code == 4001) return true;
//       // Check message for patterns even if code isn't standard
//       if (e.message != null && regexp.hasMatch(e.message!)) {
//         return true;
//       }
//       // WalletConnect specific rejection codes (often in 5000-5999 range)
//       // These are less standard but common for network/request issues including user rejection
//       if (e.code != null && e.code! >= 5000 && e.code! < 6000) {
//         // Needs refinement - not all codes are user rejection, but many are.
//         // A robust check might inspect the message for these codes too.
//         // print('WalletService: Potential WC error code: ${e.code}'); // Debugging WC errors
//         // Heuristic: if it's a WC error code and the message doesn't indicate something else clearly, assume user rejection or a non-critical request failure.
//         if (regexp.hasMatch(e.message ?? ''))
//           return true; // Check message pattern for safety
//         // Potentially return true for 5000-5999 range if message check isn't enough,
//         // but be aware this might catch non-user rejection errors. Let's rely on message for now.
//         // return true; // Consider uncommenting if message check isn't reliable for WC errors
//       }
//     }
//     if (e is CoinbaseServiceException) {
//       if (regexp.hasMatch(e.error.toString()) ||
//           regexp.hasMatch(e.message.toString())) {
//         return true;
//       }
//     }
//     if (e is ThirdPartyWalletException) {
//       if (regexp.hasMatch(e.message ?? '')) {
//         return true;
//       }
//     }

//     // Check the error string representation as a fallback (less reliable)
//     return regexp.hasMatch(e.toString());
//   }

//   // --- Contract Loading ---
//   // This is called once during service init
//   Future<void> _loadContractAbis() async {
//     print('WalletService: Starting to load ABIs...');
//     _areContractsLoaded = false; // Set loading state for contracts
//     // Status messages are already handled by _updateState's initial checks

//     try {
//       // Load and parse ABIs
//       print('WalletService: Loading StarsToken.json...');
//       final starsTokenAbiString = await rootBundle.loadString(
//         'assets/abis/StarsToken.json',
//       );
//       print('WalletService: Loading StarsPlatform.json...');
//       final starsPlatformAbiString = await rootBundle.loadString(
//         'assets/abis/StarsPlatform.json',
//       );

//       final starsTokenAbiJson = jsonDecode(starsTokenAbiString);
//       final starsPlatformAbiJson = jsonDecode(starsPlatformAbiString);

//       final starsTokenAbiArray = starsTokenAbiJson['abi'];
//       final starsPlatformAbiArray = starsPlatformAbiJson['abi'];

//       if (starsTokenAbiArray == null ||
//           starsPlatformAbiArray == null ||
//           starsTokenAbiArray is! List ||
//           starsPlatformAbiArray is! List) {
//         print('WalletService: ABI validation failed: JSON structure invalid.');
//         throw Exception(
//           "ABI JSON is not structured as expected (missing 'abi' key or not an array)",
//         );
//       }

//       final starsTokenAbi = ContractAbi.fromJson(
//         jsonEncode(starsTokenAbiArray),
//         'StarsToken',
//       );
//       final starsPlatformAbi = ContractAbi.fromJson(
//         jsonEncode(starsPlatformAbiArray),
//         'StarsPlatform',
//       );

//       _starsTokenContract = DeployedContract(
//         starsTokenAbi,
//         EthereumAddress.fromHex(_starsTokenAddress),
//       );
//       _starsPlatformContract = DeployedContract(
//         starsPlatformAbi,
//         EthereumAddress.fromHex(_starsPlatformAddress),
//       );

//       _areContractsLoaded = true; // Contracts successfully loaded
//       print('WalletService: Contract ABIs loaded successfully.');

//       // IMPORTANT: If we successfully loaded contracts *after* the wallet was already connected
//       // to Sepolia, trigger the initial data fetch now.
//       // Check _isSepoliaAndReady which includes modal != null check
//       if (_isSepoliaAndReady && !_hasFetchedInitialData) {
//         print(
//           "WalletService: Contracts loaded AFTER Wallet was Sepolia+Ready. Triggering initial data fetch.",
//         );
//         // Use Future.microtask to yield back before calling fetch
//         Future.microtask(() {
//           // Double-check state before fetching
//           if (_isSepoliaAndReady && !_hasFetchedInitialData) {
//             _fetchInitialData();
//           } else {
//             print(
//               "WalletService: State changed again before initial fetch (post-ABI load) could run.",
//             );
//           }
//         });
//         // Set loading status immediately
//         _starsBalanceDisplay = 'Loading...';
//         _transactionListStatus = 'Loading...';
//         _transactionStatus = 'Contracts loaded. Fetching data...';
//         notifyListeners(); // Notify UI so it shows loading state immediately
//       } else {
//         print(
//           "WalletService: Contracts loaded. Sepolia ready state: $_isSepoliaAndReady, Initial fetch done: $_hasFetchedInitialData.",
//         );
//         // State will be updated by _updateState based on connection status
//         // No need to set specific statuses here unless there was an error
//       }
//     } catch (e, s) {
//       print('WalletService: FATAL ERROR loading or parsing ABIs: $e\n$s');
//       _areContractsLoaded = false; // Ensure this is false on error
//       _starsTokenContract = null;
//       _starsPlatformContract = null;
//       // Update status messages to reflect the error
//       _starsBalanceDisplay = 'Error loading contracts';
//       _transactionStatus = 'Error loading contracts';
//       _transactionListStatus = 'Error loading contracts';
//       _currentNativeBalanceWei = BigInt.zero;
//       _currentStarsBalanceWei = BigInt.zero;
//       _hasFetchedInitialData = false; // Reset flag

//       _handleModalError(
//         ModalError('Error loading contract data. Check console for details.'),
//       );
//     } finally {
//       // Always notify listeners after ABI loading attempt (success or failure)
//       // Only notify here if ContractsLoaded state actually changed or if there was an error
//       notifyListeners();
//     }
//   }

//   // Helper to convert double Stars amount to BigInt Wei
//   BigInt starsToWei(double starsAmount) {
//     if (starsAmount < 0) return BigInt.zero;
//     final bigDecimal = BigInt.from(10).pow(_starsTokenDecimals);
//     try {
//       final starsDecimal = Decimal.parse(starsAmount.toString());
//       final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
//       final weiAmountDecimal = starsDecimal * bigDecimalDecimal;
//       // Rounding is important for accurate BigInt conversion
//       // Use round(MidpointRounding.toNearestEven) or check requirements
//       // For simplicity, we'll use standard round(), but be aware of precision.
//       return BigInt.parse(weiAmountDecimal.round().toString());
//     } catch (e, s) {
//       print(
//         'WalletService: Error converting stars $starsAmount to wei: $e\n$s',
//       );
//       _handleModalError(ModalError("Conversion Error: Invalid star amount."));
//       return BigInt.zero; // Return zero on conversion error
//     }
//   }

//   // Helper to convert integer Stars amount to BigInt Wei (for gifting)
//   BigInt starsIntToWei(int starsAmount) {
//     if (starsAmount < 0) return BigInt.zero;
//     final bigDecimal = BigInt.from(10).pow(_starsTokenDecimals);
//     // Directly multiply BigInt for integer amounts
//     return BigInt.from(starsAmount) * bigDecimal;
//   }

//   // Helper to convert BigInt Wei to double Stars (for display)
//   double weiToStarsDouble(BigInt weiAmount, int decimals) {
//     if (decimals < 0) decimals = 0; // Handle invalid decimals
//     final bigDecimal = BigInt.from(10).pow(decimals);
//     if (bigDecimal == BigInt.zero)
//       return weiAmount
//           .toDouble(); // Avoid division by zero if decimals somehow 0

//     try {
//       final weiDecimal = Decimal.parse(weiAmount.toString());
//       final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
//       // Perform division using Decimal and convert to double
//       return (weiDecimal / bigDecimalDecimal).toDouble();
//     } catch (e, s) {
//       print(
//         "WalletService: Error converting wei $weiAmount to stars double: $e\n$s",
//       );
//       // Don't broadcast error for conversion *for display*, just return 0.0
//       return 0.0;
//     }
//   }

//   // Helper to convert integer Stars amount to BigInt Wei (rounding down, for gifting amount input)
//   int weiToStarsInt(BigInt weiAmount, int decimals) {
//     if (decimals < 0) decimals = 0;
//     final bigDecimal = BigInt.from(10).pow(decimals);
//     if (bigDecimal == BigInt.zero) return 0;
//     try {
//       // Integer division
//       return (weiAmount ~/ bigDecimal).toInt();
//     } catch (e, s) {
//       print(
//         "WalletService: Error converting wei $weiAmount to stars int: $e\n$s",
//       );
//       return 0; // Return 0 on error
//     }
//   }

//   // Helper to convert double native amount to BigInt Wei
//   BigInt nativeDoubleToWei(double amount) {
//     // Assuming native currency (ETH, MATIC) has 18 decimals - common standard
//     try {
//       if (amount < 0) amount = 0;
//       final decimalAmount = Decimal.parse(amount.toString());
//       // Standard ETH/native token decimals is 18
//       final weiFactor = Decimal.parse(BigInt.from(10).pow(18).toString());
//       final weiAmountDecimal = decimalAmount * weiFactor;
//       return BigInt.parse(
//         weiAmountDecimal.round().toString(),
//       ); // Round and parse as BigInt
//     } catch (e, s) {
//       print(
//         'WalletService: Error in nativeDoubleToWei for amount $amount: $e\n$s',
//       );
//       // This conversion happens before sending a tx, so error should be user-facing
//       _handleModalError(
//         ModalError("Conversion Error: Invalid native amount entered."),
//       );
//       return BigInt.zero;
//     }
//   }

//   // Helper to convert BigInt Wei to double native currency (for display)
//   double weiToNativeDouble(BigInt weiAmount) {
//     // Assuming native currency has 18 decimals - common standard (18 decimals)
//     final bigDecimal = BigInt.from(10).pow(18);
//     if (bigDecimal == BigInt.zero)
//       return weiAmount.toDouble(); // Avoid division by zero

//     try {
//       final weiDecimal = Decimal.parse(weiAmount.toString());
//       final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
//       // Perform division using Decimal and convert to double
//       return (weiDecimal / bigDecimalDecimal).toDouble();
//     } catch (e, s) {
//       print(
//         "WalletService: Error converting wei $weiAmount to native double: $e\n$s",
//       );
//       // Don't broadcast error for conversion *for display*, just return 0.0
//       return 0.0;
//     }
//   }

//   // Helper to calculate native token amount needed for a given stars amount
//   double getNativeAmountForStars(int starsAmount) {
//     if (starsAmount < 0) return 0.0;
//     try {
//       final starsDecimal = Decimal.parse(starsAmount.toString());
//       final rateDecimal = Decimal.parse(_NATIVE_PER_STAR.toString());
//       final nativeAmountDecimal = starsDecimal * rateDecimal;
//       return nativeAmountDecimal.toDouble();
//     } catch (e, s) {
//       print(
//         'WalletService: Error calculating native amount for stars $starsAmount: $e\n$s',
//       );
//       // Conversion error before a tx, potentially user-facing
//       _handleModalError(
//         ModalError("Conversion Error: Cannot calculate native cost."),
//       );
//       return 0.0;
//     }
//   }

//   // Helper to calculate stars amount for a given native amount
//   int getStarsAmountForNative(double nativeAmount) {
//     if (nativeAmount < 0) return 0;
//     try {
//       final nativeDecimal = Decimal.parse(nativeAmount.toString());
//       final rateDecimal = Decimal.parse(_STARS_PER_NATIVE_TOKEN.toString());
//       final starsAmountDecimal = nativeDecimal * rateDecimal;
//       // Use floor() as you can only buy whole stars (based on typical tokenomics)
//       return starsAmountDecimal.floor().toBigInt().toInt();
//     } catch (e, s) {
//       print(
//         'WalletService: Error calculating stars for native amount $nativeAmount: $e\n$s',
//       );
//       // Conversion error before a tx, potentially user-facing
//       _handleModalError(
//         ModalError("Conversion Error: Cannot calculate stars amount."),
//       );
//       return 0;
//     }
//   }

//   // Fetch STARS Balance (Made Public)
//   Future<void> getStarsBalance() async {
//     print("WalletService: Attempting to get STARS balance.");
//     // Check _isSepoliaAndReady which includes modal != null check
//     if (!_isSepoliaAndReady) {
//       print(
//         "WalletService: Not ready to get STARS balance. State not Sepolia+Ready.",
//       );
//       // Status message should be handled by _updateState or previous fetch attempts
//       if (!(_starsBalanceDisplay.contains('Loading') ||
//           _starsBalanceDisplay.contains('Error') ||
//           _starsBalanceDisplay.contains('Failed'))) {
//         // Only update if it's not already a loading or error state
//         _starsBalanceDisplay = 'Not connected to Sepolia'; // Or relevant state
//       }
//       notifyListeners(); // Ensure state change is reflected
//       return;
//     }

//     // Only show 'Getting balance...' if we ARE connected to Sepolia and attempting to fetch
//     if (!_starsBalanceDisplay.contains('Loading')) {
//       // Prevent overwriting 'Loading...'
//       _starsBalanceDisplay = 'Getting balance...';
//       notifyListeners(); // Update UI to show loading state
//     }

//     try {
//       final address = EthereumAddress.fromHex(_connectedAddress!);
//       final topic = _currentSession?.topic; // Get topic for WC

//       if (topic == null) {
//         throw Exception("Session topic is null");
//       }
//       // Ensure the modal instance is valid before using it
//       if (_appKitModal == null) {
//         print(
//           "WalletService: AppKitModal instance is null or disposed during getStarsBalance.",
//         );
//         throw Exception(
//           "Wallet service is not in a valid state to fetch balance.",
//         );
//       }

//       // Use requestReadContract which is designed for view/pure functions
//       final result = await _appKitModal!.requestReadContract(
//         topic: topic,
//         chainId: _sepoliaChainId,
//         deployedContract: _starsTokenContract!, // Use the StarsToken contract
//         functionName: 'balanceOf', // The standard ERC20 balance function
//         parameters: [address], // The address to check the balance for
//       );

//       if (result.isNotEmpty && result[0] is BigInt) {
//         _currentStarsBalanceWei = result[0] as BigInt;
//         final balanceDouble = weiToStarsDouble(
//           _currentStarsBalanceWei,
//           _starsTokenDecimals,
//         );
//         // Display with a reasonable number of decimal places
//         String formattedBalance = balanceDouble.toStringAsFixed(4);
//         // Remove trailing zeros and decimal point if only zeros remain
//         if (formattedBalance.contains('.')) {
//           formattedBalance = formattedBalance.replaceAll(RegExp(r'0*$'), '');
//           if (formattedBalance.endsWith('.')) {
//             formattedBalance = formattedBalance.substring(
//               0,
//               formattedBalance.length - 1,
//             );
//           }
//         }

//         _starsBalanceDisplay = '$formattedBalance $_starsTokenSymbol';
//         print("WalletService: Fetched STARS balance: $_starsBalanceDisplay");
//       } else {
//         _currentStarsBalanceWei = BigInt.zero;
//         _starsBalanceDisplay = 'Could not parse balance';
//         print("WalletService: Failed to parse STARS balance result: $result");
//         _handleModalError(ModalError('Failed to parse STARS balance.'));
//       }
//     } catch (e, s) {
//       print('WalletService: Error getting STARS balance: $e\n$s');
//       _currentStarsBalanceWei = BigInt.zero;
//       _starsBalanceDisplay = 'Error fetching balance';
//       // Read calls usually don't trigger user rejection directly, but RPC errors can happen
//       if (e is JsonRpcError) {
//         print('WalletService: RPC Error fetching balance: ${e.message}');
//         _handleModalError(
//           ModalError(
//             'RPC Error fetching balance: ${e.message ?? "Unknown error"}',
//           ),
//         );
//       } else {
//         print('WalletService: Unknown Error fetching balance: $e');
//         _handleModalError(ModalError('Failed to get balance.'));
//       }
//     } finally {
//       notifyListeners(); // Notify UI after fetch (success or failure)
//     }
//   }

//   // Fetch Token Transactions from Etherscan (Made Public)
//   Future<void> fetchTokenTransactions() async {
//     print('WalletService: Starting fetchTokenTransactions...');

//     if (_etherscanApiKey == 'YOUR_ETHERSCAN_API_KEY' ||
//         _etherscanApiKey.isEmpty) {
//       print(
//         "WalletService: WARNING: Etherscan API key is not set. Cannot fetch transactions.",
//       );
//       _transactionListStatus =
//           'Error: Etherscan API key is missing.'; // Clearer message
//       _transactions = []; // Clear any old data
//       _isLoadingTransactions = false; // Stop loading state
//       notifyListeners(); // Update UI
//       return; // Stop execution if key is missing
//     }

//     // Check _isSepoliaAndReady which includes modal != null check
//     if (!_isSepoliaAndReady) {
//       print(
//         "WalletService: Not ready to fetch transactions. State not Sepolia+Ready.",
//       );
//       // This case is handled by _updateState clearing the list and setting status
//       if (_transactionListStatus != 'Error: Etherscan API key is missing.' &&
//           !(_transactionListStatus.contains('Loading') ||
//               _transactionListStatus.contains('Error') ||
//               _transactionListStatus.contains('Failed'))) {
//         _transactionListStatus = 'Connect to Sepolia to see transactions.';
//       }
//       _transactions = []; // Clear any old data if state is not ready
//       _isLoadingTransactions = false; // Ensure loading is false
//       notifyListeners(); // Update UI
//       return;
//     }

//     if (_isLoadingTransactions) {
//       print("WalletService: Transaction fetch already in progress.");
//       return; // Prevent multiple concurrent calls
//     }

//     _isLoadingTransactions = true;
//     _transactionListStatus =
//         'Loading transactions...'; // Indicate loading started
//     // _transactions = []; // Don't clear immediately, show old data while loading if desired, or clear based on UI preference. Keeping old data might make the UI less jumpy. If clearing is preferred, uncomment this.
//     notifyListeners(); // Update UI to show loading state

//     final String apiKey = _etherscanApiKey;
//     final String address = _connectedAddress!;
//     final String tokenAddress = _starsTokenAddress;
//     // Use Sepolia-specific API endpoint
//     final String baseUrl = 'https://api-sepolia.etherscan.io/api';

//     try {
//       final url = Uri.parse(
//         '$baseUrl?module=account&action=tokentx&contractaddress=$tokenAddress&address=$address&page=1&offset=50&sort=desc&apikey=$apiKey',
//       );

//       print('WalletService: Fetching transactions from Etherscan: $url');

//       final response = await get(url);
//       print(
//         'WalletService: Received Etherscan response status code: ${response.statusCode}',
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         print(
//           'WalletService: Etherscan API response status: ${data['status']}, message: ${data['message']}',
//         );

//         if (data['status'] == '1' && data['result'] is List) {
//           final List resultList = data['result'];
//           print('WalletService: Processing ${resultList.length} transactions');

//           // Filter out potential null entries and handle parsing errors gracefully
//           final List<TokenTransaction> fetchedTransactions = resultList
//               .where((json) => json != null)
//               .map((json) {
//                 try {
//                   // Provide contract decimals and symbol during parsing
//                   return TokenTransaction.fromJson(json);
//                 } catch (e, s) {
//                   print(
//                     'WalletService: Error parsing transaction JSON item: $json\nError: $e\nStack: $s',
//                   );
//                   return null; // Return null if parsing fails
//                 }
//               })
//               .where((tx) => tx != null) // Filter out nulls
//               .cast<
//                 TokenTransaction
//               >() // Ensure remaining items are TokenTransaction
//               .toList();

//           print(
//             'WalletService: Successfully fetched and parsed ${fetchedTransactions.length} transactions.',
//           );

//           _transactions = fetchedTransactions;
//           if (_transactions.isEmpty) {
//             _transactionListStatus =
//                 'No recent STARS transactions found for this address.';
//           } else {
//             _transactionListStatus = ''; // Clear status on success with data
//           }
//         } else if (data['status'] == '0' &&
//             data['message'] == 'No transactions found') {
//           print('WalletService: Etherscan API: No transactions found.');
//           _transactionListStatus =
//               'No recent STARS transactions found for this address.';
//           _transactions = []; // Ensure list is empty
//         } else {
//           // Handle other Etherscan API error status ('0') or unexpected format
//           final errorMessage = data['message'] ?? 'Unknown error';
//           print(
//             'WalletService: Etherscan API error/unexpected format (status ${data['status']}): $errorMessage',
//           );
//           _transactionListStatus = 'Etherscan API error: $errorMessage';
//           _transactions = []; // Clear list on API error
//         }
//       } else {
//         // Handle HTTP error status (e.g., 404, 500)
//         print(
//           'WalletService: HTTP Error fetching transactions: ${response.statusCode} - ${response.reasonPhrase}',
//         );
//         _transactionListStatus =
//             'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}';
//         _transactions = []; // Clear list on HTTP error
//       }
//     } catch (e, s) {
//       // Catch any other exceptions (network, json decoding, parsing errors)
//       print('WalletService: Error fetching or processing transactions: $e\n$s');
//       _transactionListStatus =
//           'Failed to fetch transactions: ${e.runtimeType} - ${e.toString()}';
//       _transactions = []; // Clear list on general error
//     } finally {
//       _isLoadingTransactions = false; // Stop loading animation/indicator
//       notifyListeners(); // Notify UI after fetch attempt (success or failure)
//     }
//   }

//   // Add STARS Token to Wallet
//   Future<void> addStarsTokenToWallet() async {
//     print("WalletService: Attempting to add STARS token to wallet.");
//     // Check _isSepoliaAndReady which includes modal != null check
//     if (!_isSepoliaAndReady) {
//       print("WalletService: Not ready to add STARS token.");
//       _transactionStatus =
//           'Error: Wallet not connected to Sepolia or contracts not loaded.';
//       notifyListeners();
//       _handleModalError(
//         ModalError('Please connect to Sepolia to add the token.'),
//       );
//       return;
//     }

//     _transactionStatus = 'Requesting wallet to add STARS token...';
//     notifyListeners(); // Update UI status

//     try {
//       final watchAssetParams = {
//         'type': 'ERC20',
//         'options': {
//           'address': _starsTokenAddress,
//           'symbol': _starsTokenSymbol,
//           'decimals': _starsTokenDecimals,
//           // 'image': 'URL_TO_YOUR_TOKEN_LOGO', // Optional: Add your token logo URL
//         },
//       };

//       final topic = _currentSession?.topic;
//       if (topic == null) {
//         throw Exception("Session topic is null, cannot request add token.");
//       }
//       // Ensure modal is valid
//       if (_appKitModal == null) {
//         throw Exception("Wallet service is not in a valid state to add token.");
//       }

//       // Use AppKitModal's request method which is designed to handle wallet_watchAsset
//       // for different underlying wallet types (WC, Magic, etc.)
//       await _appKitModal!.request(
//         // Use the active modal instance
//         topic: topic, // Use the session topic
//         chainId: _sepoliaChainId, // Specify the chain ID
//         request: SessionRequestParams(
//           method: 'wallet_watchAsset', // The method for adding a custom token
//           params: watchAssetParams,
//         ),
//       );

//       _transactionStatus = 'Wallet prompted to add STARS token.';
//       print('WalletService: Sent wallet_watchAsset request for STARS token.');
//       // Refresh balance after adding token (if wallet supports it - not guaranteed to trigger a balance update)
//       Future.delayed(Duration(seconds: 2), () {
//         getStarsBalance(); // Call service's method
//       });
//     } catch (e, s) {
//       print(
//         'WalletService: Error requesting wallet to add STARS token: $e\n$s',
//       );
//       _transactionStatus = 'Failed to prompt wallet to add token.';

//       if (_isUserRejectedError(e)) {
//         _handleModalError(UserRejectedRequest()); // Use AppKit's specific error
//       } else if (e is JsonRpcError) {
//         _handleModalError(
//           ModalError('RPC Error adding token: ${e.message ?? "Unknown error"}'),
//         );
//       } else {
//         _handleModalError(ModalError('Failed to send add token request.'));
//       }
//     } finally {
//       notifyListeners(); // Update UI status
//     }
//   }

//   // Send Gift Stars (Uses the StarsPlatform contract)
//   Future<void> sendGiftStars(
//     String recipientAddressString,
//     int amountInStars, // Integer amount for gifting
//   ) async {
//     print(
//       "WalletService: Attempting to send gift of $amountInStars STARS to $recipientAddressString",
//     );

//     if (amountInStars < 1) {
//       print("WalletService: Cannot send less than 1 star.");
//       _transactionStatus = 'Cannot send less than 1 star.';
//       notifyListeners();
//       _handleModalError(ModalError('Cannot send less than 1 star.'));
//       return;
//     }

//     // Convert integer amount back to Wei BigInt for the contract call
//     final amountWei = starsIntToWei(amountInStars);

//     // Check _isSepoliaAndReady which includes modal != null check
//     if (!_isSepoliaAndReady) {
//       print("WalletService: Not ready to send gift.");
//       _transactionStatus =
//           'Error: Wallet not connected to Sepolia or contracts not loaded.';
//       notifyListeners();
//       _handleModalError(
//         ModalError(
//           'Please connect wallet and ensure contracts are loaded on Sepolia.',
//         ),
//       );
//       return;
//     }

//     if (recipientAddressString.isEmpty) {
//       print("WalletService: Recipient address is empty.");
//       _transactionStatus = 'Error: Recipient address is empty.';
//       notifyListeners();
//       _handleModalError(ModalError('Please enter a recipient address.'));
//       return;
//     }

//     EthereumAddress recipientAddress;
//     try {
//       // Use EthereumAddress.fromHex with enforceEip55 for better validation
//       recipientAddress = EthereumAddress.fromHex(
//         recipientAddressString,
//         enforceEip55: true,
//       );
//       if (recipientAddress.hex.toLowerCase() ==
//           _connectedAddress!.toLowerCase()) {
//         print("WalletService: Cannot gift to self.");
//         _transactionStatus = 'Error: Cannot send gift to yourself.';
//         notifyListeners();
//         _handleModalError(ModalError('Cannot send gift to yourself.'));
//         return;
//       }
//     } catch (e) {
//       print(
//         "WalletService: Invalid recipient address format or checksum: $recipientAddressString, Error: $e",
//       );
//       _transactionStatus = 'Error: Invalid recipient address.';
//       notifyListeners();
//       _handleModalError(
//         ModalError('Invalid recipient address format or checksum.'),
//       );
//       return;
//     }

//     // Basic balance check
//     if (_currentStarsBalanceWei < amountWei) {
//       print(
//         "WalletService: Insufficient STARS balance for gift (Need $amountWei, have $_currentStarsBalanceWei).",
//       );
//       _transactionStatus = 'Error: Insufficient STARS balance.';
//       notifyListeners();
//       _handleModalError(ModalError('Insufficient STARS balance.'));
//       return;
//     }

//     // Update status immediately
//     _transactionStatus =
//         'Sending $amountInStars $_starsTokenSymbol to ${recipientAddressString.substring(0, 6)}...${recipientAddressString.substring(recipientAddressString.length - 4)}...';
//     notifyListeners();

//     try {
//       final fromAddress = EthereumAddress.fromHex(_connectedAddress!);
//       final topic = _currentSession?.topic; // Get topic for WC

//       if (topic == null) {
//         throw Exception("Session topic is null, cannot send gift.");
//       }
//       if (_starsPlatformContract == null) {
//         throw Exception("StarsPlatform contract not loaded.");
//       }
//       // Ensure modal is valid
//       if (_appKitModal == null) {
//         throw Exception("Wallet service is not in a valid state to send gift.");
//       }

//       print("WalletService: Calling giftStars on platform contract...");
//       final txHash = await _appKitModal!.requestWriteContract(
//         // Use the active modal instance
//         topic: topic,
//         chainId: _sepoliaChainId,
//         deployedContract:
//             _starsPlatformContract!, // Call giftStars on StarsPlatform!
//         functionName: 'giftStars', // Assuming the function name is 'giftStars'
//         transaction: Transaction(from: fromAddress), // Specify the sender
//         parameters: [
//           recipientAddress, // Recipient address argument
//           amountWei, // Amount in wei argument (BigInt)
//         ],
//       );

//       _transactionStatus = 'Gift Transaction sent! Hash: $txHash';
//       print('WalletService: Gift Stars Tx Hash: $txHash');

//       // Refresh balance and transactions after a short delay for confirmation
//       // Use a reasonable delay (e.g., 10-20 seconds) for transaction to be mined and indexed
//       Future.delayed(Duration(seconds: 15), () {
//         print("WalletService: Delayed fetch after gift transaction.");
//         getStarsBalance(); // Refresh balance
//         fetchTokenTransactions(); // Fetch transactions
//         _transactionStatus = 'Gift sent. Ready.'; // Update final status
//         notifyListeners(); // Notify UI for final status update
//       });
//     } catch (e, s) {
//       print('WalletService: Error sending gift stars: $e\n$s');
//       _transactionStatus = 'Gift transaction failed or rejected.';

//       if (_isUserRejectedError(e)) {
//         _handleModalError(UserRejectedRequest());
//       } else if (e is JsonRpcError) {
//         _handleModalError(
//           ModalError('RPC Error gifting: ${e.message ?? "Unknown error"}'),
//         );
//       } else {
//         _handleModalError(ModalError('Failed to send gift.'));
//       }
//     } finally {
//       notifyListeners(); // Update UI status (initial failure)
//     }
//   }

//   // Buy STARS tokens (Uses the StarsPlatform contract)
//   Future<void> buyStars(double amountNative) async {
//     print(
//       "WalletService: Attempting to buy STARS with $amountNative native tokens.",
//     );

//     if (amountNative <= 0) {
//       print("WalletService: Buy amount is zero or negative.");
//       _transactionStatus = 'Error: Invalid buy amount.';
//       notifyListeners();
//       _handleModalError(
//         ModalError('Invalid amount entered. Please enter a positive number.'),
//       );
//       return;
//     }

//     // Check _isSepoliaAndReady which includes modal != null check
//     if (!_isSepoliaAndReady) {
//       print("WalletService: Not ready to buy stars.");
//       _transactionStatus =
//           'Error: Wallet not connected to Sepolia or contracts not loaded.';
//       notifyListeners();
//       _handleModalError(
//         ModalError(
//           'Please connect wallet and ensure contracts are loaded on Sepolia.',
//         ),
//       );
//       return;
//     }

//     BigInt amountWei;
//     try {
//       // Convert the double native amount to native token Wei (assuming 18 decimals)
//       amountWei = nativeDoubleToWei(amountNative);
//       if (amountWei <= BigInt.zero) {
//         print(
//           "WalletService: Calculated native amount in wei is zero or negative.",
//         );
//         _transactionStatus = 'Error: Amount conversion resulted in zero.';
//         notifyListeners();
//         _handleModalError(ModalError('Calculated native amount is too small.'));
//         return;
//       }
//     } catch (e) {
//       // Error handled inside nativeDoubleToWei and broadcasted
//       print(
//         "WalletService: Error converting native amount $amountNative to wei.",
//       );
//       _transactionStatus = 'Error: Amount conversion failed.';
//       notifyListeners();
//       return;
//     }

//     // Check native balance
//     if (_currentNativeBalanceWei < amountWei) {
//       print(
//         "WalletService: Insufficient native balance for buy (Need $amountWei, have $_currentNativeBalanceWei).",
//       );
//       _transactionStatus = 'Error: Insufficient native balance.';
//       notifyListeners();
//       _handleModalError(
//         ModalError('Insufficient native balance to complete purchase.'),
//       );
//       return;
//     }

//     _transactionStatus =
//         'Buying STARS with ${amountNative.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')} ${_connectedNetwork?.currency ?? "Native"}...';
//     notifyListeners();

//     try {
//       final fromAddress = EthereumAddress.fromHex(_connectedAddress!);
//       final topic = _currentSession?.topic; // Get topic for WC

//       if (topic == null) {
//         throw Exception("Session topic is null, cannot send buy transaction.");
//       }
//       if (_starsPlatformContract == null) {
//         throw Exception("StarsPlatform contract not loaded.");
//       }
//       // Ensure modal is valid
//       if (_appKitModal == null) {
//         throw Exception(
//           "Wallet service is not in a valid state to send buy transaction.",
//         );
//       }

//       print(
//         "WalletService: Calling buyStars on platform contract with value $amountWei...",
//       );
//       final txHash = await _appKitModal!.requestWriteContract(
//         // Use the active modal instance
//         topic: topic,
//         chainId: _sepoliaChainId,
//         deployedContract:
//             _starsPlatformContract!, // Call buyStars on StarsPlatform!
//         functionName: 'buyStars', // Assuming the function name is 'buyStars'
//         transaction: Transaction(
//           from: fromAddress,
//           value: EtherAmount.inWei(
//             amountWei,
//           ), // Send the native currency as value
//         ),
//         parameters:
//             [], // buyStars function takes no explicit parameters (value is sent separately)
//       );

//       _transactionStatus = 'Buy Transaction sent! Hash: $txHash';
//       print('WalletService: Buy Stars Tx Hash: $txHash');

//       // Refresh balance and transactions after a short delay
//       // Use a reasonable delay (e.g., 10-20 seconds) for transaction to be mined and indexed
//       Future.delayed(Duration(seconds: 15), () {
//         print("WalletService: Delayed fetch after buy transaction.");
//         getStarsBalance(); // Refresh STARS balance
//         // _updateNativeBalance is triggered by balanceNotifier listener which fires when native balance changes
//         fetchTokenTransactions(); // Fetch transactions
//         _transactionStatus = 'Buy successful. Ready.'; // Update final status
//         notifyListeners(); // Notify UI for final status update
//       });
//     } catch (e, s) {
//       print('WalletService: Error sending buy stars transaction: $e\n$s');
//       _transactionStatus = 'Buy transaction failed or rejected.';

//       if (_isUserRejectedError(e)) {
//         _handleModalError(UserRejectedRequest());
//       } else if (e is JsonRpcError) {
//         _handleModalError(
//           ModalError('RPC Error buying: ${e.message ?? "Unknown error"}'),
//         );
//       } else {
//         _handleModalError(ModalError('Failed to send buy transaction.'));
//       }
//     } finally {
//       notifyListeners(); // Update UI status (initial failure)
//     }
//   }

//   @override
//   void dispose() {
//     print("WalletService: Disposing WalletService...");
//     // Dispose the modal if it still exists
//     // Call _performLocalCleanup as the definitive way to clean up the modal
//     if (_appKitModal != null) {
//       print(
//         "WalletService: Calling _performLocalCleanup during service dispose.",
//       );
//       // Use a future microtask to ensure dispose cycle completes properly
//       Future.microtask(() => _performLocalCleanup());
//     } else {
//       print(
//         "WalletService: _appKitModal was already null or disposed during service dispose.",
//       );
//       // Ensure service state is clean even if modal wasn't there
//       _status = ReownAppKitModalStatus.idle;
//       _connectedNetwork = null;
//       _currentSession = null;
//       _connectedAddress = null;
//       _connectedWalletName = null;
//       _currentNativeBalanceWei = BigInt.zero;
//       _currentStarsBalanceWei = BigInt.zero;
//       _starsBalanceDisplay = 'Connect to see balance';
//       _transactionStatus = 'Ready.';
//       _transactions = [];
//       _transactionListStatus = 'Connect to see transactions';
//       _hasFetchedInitialData = false;
//       // Don't call notifyListeners here, dispose is the end of the road.
//     }
//     print("WalletService: WalletService disposed.");
//     super
//         .dispose(); // Call super.dispose() AFTER starting cleanup of owned resources
//   }
// }
