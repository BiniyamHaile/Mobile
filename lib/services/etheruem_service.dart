// import 'dart:async';
// import 'dart:convert'; // Required for utf8.encode
// import 'package:flutter/services.dart' show rootBundle;
// import 'package:flutter/foundation.dart';
// import 'package:http/http.dart' as http;
// import 'package:walletconnect_flutter_v2/walletconnect_flutter_v2.dart';
// import 'package:url_launcher/url_launcher_string.dart';
// import 'package:web3dart/crypto.dart'; // Required for bytesToHex
// import 'package:web3dart/web3dart.dart';

// class EthereumService extends ChangeNotifier {
//   // === Config ===
//   static const String _rpcUrl = 'https://eth-sepolia.g.alchemy.com/v2/QWQDj9pLO6MTD94t3E9Y2WJw4Jr5WJw4Jr5Xaxi';
//   static const int _chainId = 11155111; // Sepolia chain ID
//   static const String _platformContractAddress = '0xA14536b87f485F266560b218f6f19D0eCAB070d1';
//   // static const String _starsTokenContractAddress = 'YOUR_STARS_TOKEN_CONTRACT_ADDRESS_HERE'; // If used

//   // --- WalletConnect Cloud Project ID ---
//   static const String _wcProjectId = "ed598423e231b2288c9f702c76a6cb4b";

//   // --- CRITICAL: REPLACE WITH YOUR ACTUAL PUBLIC HTTPS URLS AND APP SCHEME ---
//   static const String _appScheme = 'mystarapp'; // e.g., 'mystarapp' - MUST MATCH MANIFESTS
//   static const String _dappUrl = 'https://devaminta.github.io/dapp_cover/'; // EXAMPLE: REPLACE
//   static const String _dappIconUrl = 'https://devaminta.github.io/dapp_cover/app-icon.jpg'; // EXAMPLE: REPLACE
//   // --- END CRITICAL REPLACEMENTS ---

//   late final Web3Client _client;
//   Web3App? _web3App;
//   SessionData? _sessionData;
//   EthereumAddress? _ownAddress;
//   String? _wcUri;

//   late final DeployedContract _platformContract;
//   late final ContractFunction _giftStarsFn;

//   bool _isInitializing = true;
//   bool get isInitializing => _isInitializing;
//   Completer<void> _initializationCompleter = Completer<void>();

//   bool _isConnecting = false;
//   bool get isConnecting => _isConnecting;

//   String? get wcUri => _wcUri;

//   EthereumService() {
//     _client = Web3Client(_rpcUrl, http.Client());
//     _initializeService();
//   }

//   Future<void> _initializeService() async {
//     debugPrint("EthereumService: _initializeService START");
//     _isInitializing = true;
//     notifyListeners();

//     try {
//       await _initializeWalletConnect();
//       await _loadContracts();
//       debugPrint("EthereumService: _initializeService COMPLETE.");
//       if (!_initializationCompleter.isCompleted) {
//         _initializationCompleter.complete();
//       }
//     } catch (e, s) {
//       debugPrint("EthereumService: Error during _initializeService: $e\nStack: $s");
//       if (!_initializationCompleter.isCompleted) {
//         _initializationCompleter.completeError(e, s);
//       }
//     } finally {
//       _isInitializing = false;
//       notifyListeners();
//     }
//   }

//   Future<void> _initializeWalletConnect() async {
//     debugPrint("EthereumService: _initializeWalletConnect START");
//     if (_dappUrl.contains("yourdapp.example.com") || _dappUrl.contains("YOUR_USERNAME.github.io")) {
//       debugPrint("CRITICAL WARNING: Default or placeholder _dappUrl is being used: $_dappUrl. "
//                   "You MUST replace this with your actual public HTTPS dApp URL for reliable WalletConnect functionality, "
//                   "especially for MetaMask to show the connection popup.");
//     }
//     if (_dappIconUrl.contains("yourdapp.example.com") || _dappIconUrl.contains("YOUR_USERNAME.github.io")) {
//       debugPrint("CRITICAL WARNING: Default or placeholder _dappIconUrl is being used. Ensure this is a valid public HTTPS URL to your dApp's icon.");
//     }


//     if (_web3App != null) {
//       debugPrint("EthereumService: _web3App already exists. Unsubscribing events before re-creating.");
//       _unsubscribeWalletConnectEvents();
//     }

//     _web3App = await Web3App.createInstance(
//       projectId: _wcProjectId,
//       metadata: PairingMetadata(
//         name: 'Star Sender dApp', // Descriptive name for your dApp
//         description: 'Send digital stars as gifts on the Sepolia network.',
//         url: _dappUrl,         // YOUR dApp's public HTTPS URL
//         icons: [_dappIconUrl], // YOUR dApp's public HTTPS icon URL
//         redirect: Redirect(
//           native: _appScheme,  // Your app's custom URL scheme
//         ),
//       ),
//     );
//     debugPrint("EthereumService: Web3App instance CREATED/RE-CREATED. Instance: ${_web3App.hashCode}");

//     _web3App!.onSessionConnect.subscribe(_onSessionConnect);
//     _web3App!.onSessionEvent.subscribe(_onSessionEvent);
//     _web3App!.onSessionDelete.subscribe(_onSessionDelete);
//     _web3App!.onSessionPing.subscribe(_onSessionPing);

//     debugPrint("EthereumService: Subscribed to WalletConnect events.");

//     // Session restoration logic
//     if (_web3App!.sessions.getAll().isNotEmpty) {
//       _sessionData = _web3App!.sessions.getAll().firstWhere(
//         (s) {
//           final bool isValid = s.acknowledged &&
//                                s.expiry > (DateTime.now().millisecondsSinceEpoch ~/ 1000 + 5) &&
//                                s.namespaces.containsKey('eip155') &&
//                                s.namespaces['eip155']!.accounts.isNotEmpty;
//           if (isValid) debugPrint("EthereumService: Found potentially valid existing session: ${s.topic}");
//           return isValid;
//         },
//         // orElse: () => null as SessionData, // This will cause type error if nothing found.
//         orElse: () {
//           // debugPrint("EthereumService: No suitable session found in orElse of firstWhere.");
//           return null as SessionData; // Explicitly return null of the correct type
//         }
//       );


//       if (_sessionData != null) {
//         debugPrint("EthereumService: Attempting to use restored session: ${_sessionData!.topic}");
//         final accounts = _sessionData!.namespaces['eip155']!.accounts;
//         _ownAddress = EthereumAddress.fromHex(accounts.first.split(':').last);
//         debugPrint("EthereumService: Restored session for address: $_ownAddress");
//       } else {
//         debugPrint("EthereumService: No valid, acknowledged, and non-expired sessions found. Cleaning up old ones.");
//         for (var session in _web3App!.sessions.getAll()) {
//           try {
//             debugPrint("EthereumService: Disconnecting stale/invalid session: ${session.topic}");
//             await _web3App!.disconnectSession(topic: session.topic, reason: Errors.getSdkError(Errors.EXPIRED));
//           } catch (e) {
//             debugPrint("Error trying to disconnect stale session ${session.topic}: $e");
//           }
//         }
//       }
//     } else {
//       debugPrint("EthereumService: No existing sessions found.");
//     }
//     debugPrint("EthereumService: _initializeWalletConnect END");
//   }

//   void _onSessionConnect(SessionConnect? args) {
//     debugPrint("EthereumService: _onSessionConnect ENTERED. Args valid: ${args != null}, Session Topic: ${args?.session.topic}, Acknowledged: ${args?.session.acknowledged}");
//     if (args != null && args.session.acknowledged) {
//       _sessionData = args.session;
//       if (_sessionData!.namespaces.containsKey('eip155')) {
//         final accounts = _sessionData!.namespaces['eip155']!.accounts;
//         if (accounts.isNotEmpty) {
//           _ownAddress = EthereumAddress.fromHex(accounts.first.split(':').last);
//           debugPrint("EthereumService: Wallet Connected! Address: $_ownAddress, Session Topic: ${_sessionData!.topic}");
//           _wcUri = null; // Clear URI once connected
//         } else {
//           debugPrint("EthereumService: _onSessionConnect - no accounts in eip155 namespace.");
//           _clearSessionLocalState();
//         }
//       } else {
//         debugPrint("EthereumService: _onSessionConnect - session does not have eip155 namespace.");
//         _clearSessionLocalState();
//       }
//       _isConnecting = false;
//       notifyListeners();
//     } else {
//       if (args != null && !args.session.acknowledged) {
//         debugPrint("EthereumService: _onSessionConnect called but session NOT acknowledged by wallet.");
//       } else {
//         debugPrint("EthereumService: _onSessionConnect called with null args.");
//       }
//        _isConnecting = false;
//        _wcUri = null; // Clear URI if connection failed or was not acknowledged
//        notifyListeners();
//     }
//   }

//   void _onSessionEvent(SessionEvent? args) {
//     debugPrint("EthereumService: Received session event: Name: ${args?.name}, Topic: ${args?.topic}, Data: ${args?.data}");
//     if (args?.name == 'accountsChanged') {
//       if (_sessionData != null && args?.topic == _sessionData!.topic && _sessionData!.namespaces.containsKey('eip155')) {
//         // WalletConnect v2 sends accounts as a list of CAIP-10 formatted strings
//         final newAccounts = args?.data as List<dynamic>?; // e.g. ["eip155:1:0x123..."]
//         if (newAccounts != null && newAccounts.isNotEmpty && newAccounts.first is String) {
//           final newFullAddress = newAccounts.first as String;
//           // Ensure the account belongs to the connected chain or handle appropriately
//           if (newFullAddress.startsWith('eip155:$_chainId:')) {
//              _ownAddress = EthereumAddress.fromHex(newFullAddress.split(':').last);
//              debugPrint("EthereumService: Account changed to: $_ownAddress");
//           } else {
//             // Account changed to one on a different chain than expected for the current session context
//              debugPrint("EthereumService: accountsChanged event to an account on a different chain ($newFullAddress). Disconnecting.");
//              disconnect(); // Or handle as a chain change
//              return; // Important to return after disconnect
//           }
//           notifyListeners();
//         } else {
//           debugPrint("EthereumService: accountsChanged event with invalid data or no accounts. Disconnecting.");
//           disconnect();
//         }
//       }
//     } else if (args?.name == 'chainChanged') {
//       debugPrint("EthereumService: Chain changed: ${args?.data}. New Chain ID from event: ${args?.chainId}"); // args.chainId is the CAIP-2 chain ID
//       final newChainCaip2 = args?.chainId; // e.g., "eip155:1"
//       if (newChainCaip2 != null && newChainCaip2 != 'eip155:$_chainId') {
//           debugPrint("EthereumService: Wallet switched to an unsupported chain ($newChainCaip2). Disconnecting.");
//           disconnect();
//       } else if (newChainCaip2 != null) {
//         // Potentially update internal chainId if app supports multiple chains and this is a valid one.
//         // For now, we assume a single supported chain.
//         debugPrint("EthereumService: Wallet switched to chain: $newChainCaip2 (which is the configured chain or was already handled).");
//       }
//     }
//   }

//   void _onSessionDelete(SessionDelete? args) {
//     debugPrint("EthereumService: Session delete event: Topic: ${args?.topic}");
//     if (args != null && _sessionData != null && args.topic == _sessionData!.topic) {
//       debugPrint("EthereumService: Current session was deleted by wallet or network.");
//       _clearSessionLocalState();
//     } else {
//       debugPrint("EthereumService: A different session was deleted or no current session to clear.");
//     }
//   }

//   void _clearSessionLocalState() {
//     debugPrint("EthereumService: Clearing local session state.");
//     _sessionData = null;
//     _ownAddress = null;
//     _wcUri = null;
//     _isConnecting = false; // Ensure connecting flag is reset
//     notifyListeners();
//   }

//   void _onSessionPing(SessionPing? args) {
//     debugPrint("EthereumService: Session ping: Topic: ${args?.topic}");
//   }

//   Future<void> _loadContracts() async {
//     debugPrint("EthereumService: Loading contracts...");
//     try {
//       final platformAbiString = await rootBundle.loadString('assets/contracts/StarsPlatform.json');
//       final platformAbiJson = jsonDecode(platformAbiString);
//       final platformContractName = platformAbiJson['contractName'] as String;
//       _platformContract = DeployedContract(
//         ContractAbi.fromJson(jsonEncode(platformAbiJson['abi']), platformContractName),
//         EthereumAddress.fromHex(_platformContractAddress),
//       );
//       _giftStarsFn = _platformContract.function('giftStars');
//       debugPrint("EthereumService: StarsPlatform contract loaded successfully. Function: giftStars");
//     } catch (e,s) {
//       debugPrint("EthereumService: Error loading contracts: $e\nStack: $s");
//       rethrow;
//     }
//   }

//   bool get isConnected {
//     if (_ownAddress != null && _sessionData != null) {
//       bool acknowledged = _sessionData!.acknowledged;
//       bool notExpired = _sessionData!.expiry > (DateTime.now().millisecondsSinceEpoch ~/ 1000);
//       bool hasEip155Accounts = _sessionData!.namespaces.containsKey('eip155') &&
//                                _sessionData!.namespaces['eip155']!.accounts.isNotEmpty &&
//                                _sessionData!.namespaces['eip155']!.accounts.first.startsWith('eip155:$_chainId:'); // Ensure account is for correct chain
//       if (acknowledged && notExpired && hasEip155Accounts) return true;
//       debugPrint("EthereumService: isConnected check failed. Acknowledged: $acknowledged, NotExpired: $notExpired, HasEip155Accounts for correct chain: $hasEip155Accounts. Topic: ${_sessionData?.topic}, Current Accounts: ${_sessionData?.namespaces['eip155']?.accounts}");
//       return false;
//     }
//     return false;
//   }

//   EthereumAddress? get ownAddress => _ownAddress;

//   Future<void> connect() async {
//     debugPrint("EthereumService: connect() method called. Current _web3App hash: ${_web3App.hashCode}");
//     if (!_initializationCompleter.isCompleted) {
//         debugPrint("EthereumService: connect() waiting for _initializationCompleter...");
//         await _initializationCompleter.future;
//         debugPrint("EthereumService: _initializationCompleter done. _web3App hash: ${_web3App.hashCode}");
//     }
    
//     if (_web3App == null) {
//       debugPrint("EthereumService: CRITICAL - _web3App is NULL in connect() even after waiting for init. Re-initializing as fallback.");
//       await _initializeService();
//       if (_web3App == null) {
//          throw StateError('WalletConnect Web3App is still null after re-initialization attempt in connect().');
//       }
//     }

//     if (_isConnecting) {
//       debugPrint("EthereumService: Connection attempt already in progress.");
//       return;
//     }
//     if (isConnected) {
//       debugPrint("EthereumService: Already connected with address: $_ownAddress");
//       notifyListeners(); // Notify to update UI if connect() was called when already connected
//       return;
//     }

//     debugPrint("EthereumService: Starting new connection process.");
//     _isConnecting = true;
//     _wcUri = null; // Clear any old URI
//     notifyListeners();

//     try {
//       ConnectResponse? resp = await _web3App!.connect(
//         requiredNamespaces: {
//           'eip155': RequiredNamespace(
//             chains: ['eip155:$_chainId'], // e.g. ['eip155:11155111'] for Sepolia
//             methods: ['eth_sendTransaction', 'personal_sign'],
//             events: ['chainChanged', 'accountsChanged'],
//           ),
//         },
//       );

//       _wcUri = resp?.uri.toString();
//       if (_wcUri != null) {
//         debugPrint("EthereumService: WalletConnect URI generated: $_wcUri");
//         notifyListeners();

//         // Launch the URI to connect with the wallet
//         if (await canLaunchUrlString(_wcUri!)) {
//           await launchUrlString(_wcUri!, mode: LaunchMode.externalApplication);
//           debugPrint("EthereumService: Launched WalletConnect URI. Waiting for session approval from wallet...");
//         } else {
//           _isConnecting = false;
//           _wcUri = null;
//           notifyListeners();
//           final errorMsg = "EthereumService: Could not launch WalletConnect URI. Check if a wallet is installed and deep link queries are set in AndroidManifest.xml / Info.plist.";
//           debugPrint(errorMsg);
//           throw Exception(errorMsg);
//         }
//       } else {
//         _isConnecting = false;
//         notifyListeners();
//         final errorMsg = "EthereumService: Failed to get WalletConnect URI from connect() response.";
//         debugPrint(errorMsg);
//         throw Exception(errorMsg);
//       }

//       // Wait for the session to be established
//       debugPrint("EthereumService: connect() method waiting for session.future...");
//       final session = await resp!.session.future.timeout(
//         const Duration(minutes: 2), 
//         onTimeout: () {
//           debugPrint("EthereumService: Session approval timed out after 2 minutes.");
//           if(_isConnecting) { // Check if still in connecting state
//             _isConnecting = false;
//             _wcUri = null; // Clear URI on timeout
//             notifyListeners();
//           }
//           throw TimeoutException("Wallet connection approval timed out.");
//         },
//       );
      
//       debugPrint("EthereumService: resp.session.future completed. Session acknowledged by wallet: ${session.acknowledged}, Topic: ${session.topic}");
//       // _onSessionConnect will handle setting _sessionData, _ownAddress, and _isConnecting=false if acknowledged.
//       // If not acknowledged, _onSessionConnect will also set _isConnecting=false.
//       if (!session.acknowledged) {
//          // This path might be redundant if _onSessionConnect handles unacknowledged sessions,
//          // but it's a safeguard.
//          if(_isConnecting) {
//             _isConnecting = false;
//             _wcUri = null; 
//             notifyListeners();
//          }
//          throw Exception("Session not acknowledged by wallet after connect response.");
//       }
//       // If acknowledged, _onSessionConnect callback is expected to handle the rest.
//       // The _isConnecting flag will be reset by _onSessionConnect.

//     } catch (e, s) {
//       debugPrint("EthereumService: Error during connect(): $e\nStack: $s");
//       if(_isConnecting) { // Ensure _isConnecting is reset on any error if not already handled
//         _isConnecting = false;
//         _wcUri = null; 
//         notifyListeners();
//       }
//       // Rethrow unless it's a timeout we explicitly handled by changing state and throwing our own TimeoutException
//       if (!(e is TimeoutException && e.message == "Wallet connection approval timed out.")) {
//          rethrow;
//       }
//     }
//   }

//   Future<void> disconnect() async {
//     debugPrint("EthereumService: disconnect() called.");
//     if (_web3App == null) {
//       debugPrint("EthereumService: Web3App not initialized, cannot disconnect.");
//       _clearSessionLocalState(); // Clear local state anyway
//       return;
//     }
//     final String? currentTopic = _sessionData?.topic;
//     if (currentTopic == null) {
//       debugPrint("EthereumService: No active session to disconnect.");
//       _clearSessionLocalState(); // Clear local state if no session topic
//       return;
//     }

//     // Clear local state immediately for responsive UI, then attempt to inform wallet
//     _clearSessionLocalState(); 

//     try {
//       debugPrint("EthereumService: Attempting to disconnect session: $currentTopic");
//       await _web3App!.disconnectSession(
//         topic: currentTopic,
//         reason: Errors.getSdkError(Errors.USER_DISCONNECTED),
//       );
//       debugPrint("EthereumService: Disconnect request sent for session: $currentTopic");
//     } catch (e, s) {
//       debugPrint("EthereumService: Error sending disconnect request for $currentTopic: $e\nStack: $s");
//       // Local state is already cleared, so primarily logging the error.
//     }
//     // _clearSessionLocalState() already called.
//   }

//   Future<String> giftPlatformStars({
//     required EthereumAddress recipient,
//     required int amount,
//   }) async {
//     debugPrint("EthereumService: giftPlatformStars() called for recipient: $recipient, amount: $amount");
//     if (!_initializationCompleter.isCompleted) {
//         debugPrint("EthereumService: giftPlatformStars() waiting for _initializationCompleter...");
//         await _initializationCompleter.future;
//     }
//     if (!isConnected) {
//       final errorMsg = "Wallet not connected or session invalid. Cannot gift stars via platform.";
//       debugPrint("EthereumService: $errorMsg");
//       throw StateError(errorMsg);
//     }
//     if (_web3App == null || _sessionData == null || _ownAddress == null) {
//        final errorMsg = "Web3App, session, or ownAddress is null. State inconsistent for giftPlatformStars.";
//        debugPrint("EthereumService: $errorMsg");
//        throw StateError(errorMsg);
//     }

//     final transactionData = _giftStarsFn.encodeCall([recipient, BigInt.from(amount)]);
//     final transactionParams = {
//       'from': _ownAddress!.hex,
//       'to': _platformContract.address.hex,
//       'data': bytesToHex(transactionData, include0x: true),
//       // 'gas': '0x...', // Optionally specify gas, gasPrice/maxFeePerGas, nonce
//     };

//     try {
//       debugPrint("EthereumService: Requesting eth_sendTransaction for giftPlatformStars. Topic: ${_sessionData!.topic}, Params: $transactionParams");
//       final dynamic result = await _web3App!.request(
//         topic: _sessionData!.topic,
//         chainId: 'eip155:$_chainId',
//         request: SessionRequestParams(
//           method: 'eth_sendTransaction',
//           params: [transactionParams], 
//         ),
//       ).timeout(const Duration(minutes: 5), onTimeout: (){
//         throw TimeoutException("Transaction signing timed out for giftPlatformStars.");
//       });

//       if (result is String) {
//         debugPrint("EthereumService: Transaction sent successfully for giftPlatformStars. Hash: $result");
//         return result;
//       } else {
//         final errorMsg = "Unexpected result type from eth_sendTransaction (giftPlatformStars): ${result.runtimeType}, value: $result";
//         debugPrint("EthereumService: $errorMsg");
//         throw Exception(errorMsg);
//       }
//     } on TimeoutException catch (e) {
//         debugPrint("EthereumService: Transaction signing timed out (giftPlatformStars): $e");
//         rethrow;
//     } on JsonRpcError catch (e) {
//       debugPrint("EthereumService: Wallet RPC Error during giftPlatformStars: ${e.message} (Code: ${e.code}) \nData: ${e}");
//       throw Exception('Wallet RPC Error: ${e.message} (Code: ${e.code})');
//     } catch (e,s) {
//       debugPrint("EthereumService: Error sending giftPlatformStars transaction: $e\nStack: $s");
//       rethrow;
//     }
//   }

//   // NEW METHOD for personal_sign
//   Future<String> signPersonalMessage({
//     required String message,
//   }) async {
//     debugPrint("EthereumService: signPersonalMessage() called with message: \"$message\"");
//     if (!_initializationCompleter.isCompleted) {
//         debugPrint("EthereumService: signPersonalMessage() waiting for _initializationCompleter...");
//         await _initializationCompleter.future;
//     }
//     if (!isConnected) {
//       final errorMsg = "Wallet not connected or session invalid. Cannot sign message.";
//       debugPrint("EthereumService: $errorMsg");
//       throw StateError(errorMsg);
//     }
//     if (_web3App == null || _sessionData == null || _ownAddress == null) {
//        final errorMsg = "Web3App, session, or ownAddress is null. State inconsistent for signPersonalMessage.";
//        debugPrint("EthereumService: $errorMsg");
//        throw StateError(errorMsg);
//     }

//     // Convert the UTF-8 message to a hex string, prefixed with 0x.
//     // personal_sign standard (EIP-191) expects the message to be hex-encoded.
//     final String hexMessage = '0x${bytesToHex(utf8.encode(message))}';

//     // Params for personal_sign: [messageToSign (hex), addressOfSigner]
//     // This order is based on your provided working example.
//     final List<String> params = [hexMessage, _ownAddress!.hex];
    
//     // Alternative order, sometimes seen: [_ownAddress!.hex, hexMessage]
//     // If the above `params` list doesn't work with some wallets, try swapping them.
//     // For now, sticking to your example's implied order.

//     try {
//       debugPrint("EthereumService: Requesting personal_sign. Topic: ${_sessionData!.topic}, ChainID: eip155:$_chainId, Params: $params");
//       final dynamic signature = await _web3App!.request(
//         topic: _sessionData!.topic,
//         chainId: 'eip155:$_chainId', // Chain ID is part of the request for context, though personal_sign itself is account-based.
//         request: SessionRequestParams(
//           method: 'personal_sign',
//           params: params,
//         ),
//       ).timeout(const Duration(minutes: 5), onTimeout: (){ // 5 minutes timeout for user to react
//         throw TimeoutException("Message signing timed out for personal_sign.");
//       });

//       if (signature is String) {
//         // The signature is typically a hex string
//         debugPrint("EthereumService: Message signed successfully. Signature: $signature");
//         return signature;
//       } else {
//         final errorMsg = "Unexpected result type from personal_sign: ${signature.runtimeType}, value: $signature";
//         debugPrint("EthereumService: $errorMsg");
//         throw Exception(errorMsg);
//       }
//     } on TimeoutException catch (e) {
//         debugPrint("EthereumService: Message signing timed out (personal_sign): $e");
//         rethrow;
//     } on JsonRpcError catch (e) {
//       // Handle specific wallet errors if needed (e.g., user rejected)
//       debugPrint("EthereumService: Wallet RPC Error during personal_sign: ${e.message} (Code: ${e.code}) \nData: ${e}");
//       throw Exception('Wallet RPC Error: ${e.message} (Code: ${e.code})');
//     } catch (e,s) {
//       debugPrint("EthereumService: Error during personal_sign: $e\nStack: $s");
//       rethrow;
//     }
//   }


//   void _unsubscribeWalletConnectEvents() {
//     if (_web3App == null) {
//         debugPrint("EthereumService: _unsubscribeWalletConnectEvents called but _web3App is null.");
//         return;
//     }
//     try {
//       _web3App!.onSessionConnect.unsubscribe(_onSessionConnect);
//       _web3App!.onSessionEvent.unsubscribe(_onSessionEvent);
//       _web3App!.onSessionDelete.unsubscribe(_onSessionDelete);
//       _web3App!.onSessionPing.unsubscribe(_onSessionPing);
//       debugPrint("EthereumService: Unsubscribed from WalletConnect events.");
//     } catch (e) {
//       debugPrint("EthereumService: Minor error during event unsubscription (might be normal if already unsubscribed or never subscribed): $e");
//     }
//   }

//   @override
//   void dispose() {
//     debugPrint("EthereumService: dispose() called. _web3App hash: ${_web3App.hashCode}");
//     _unsubscribeWalletConnectEvents();
//     // If _web3App has its own dispose or close method, call it here.
//     // For WalletConnect_flutter_v2, the core relay client might need explicit disconnection if not handled by library.
//     // _web3App?.core.relayClient.disconnect().catchError((e) {
//     //   debugPrint("Error disconnecting relay client on dispose: $e");
//     // }); // This can be aggressive; test if necessary.
//     super.dispose();
//   }
// }