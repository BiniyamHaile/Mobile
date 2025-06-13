import 'dart:convert';

import 'package:decimal/decimal.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:mobile/models/token.dart';
import 'package:mobile/services/api/wallet/wallet_repository.dart';
import 'package:reown_appkit/modal/i_appkit_modal_impl.dart';
import 'package:reown_appkit/modal/services/coinbase_service/i_coinbase_service.dart';
import 'package:reown_appkit/modal/services/third_party_wallet_service.dart';
import 'package:reown_appkit/reown_appkit.dart';

final String _etherscanApiKey = dotenv.env['ETHERSCAN_API_KEY'] ?? '';

const double _STARS_PER_NATIVE_TOKEN = 100.0;
const double _NATIVE_PER_STAR = 1.0 / _STARS_PER_NATIVE_TOKEN;

class WalletService extends ChangeNotifier {
  ReownAppKitModal? _appKitModal;
  final WalletRepository _walletRepository;

  WalletService({required WalletRepository walletRepository})
    : _walletRepository = walletRepository;

  ReownAppKitModalStatus _status = ReownAppKitModalStatus.idle;
  @override
  ReownAppKitModalStatus get status => _status;

  ReownAppKitModalNetworkInfo? _connectedNetwork;
  @override
  ReownAppKitModalNetworkInfo? get connectedNetwork => _connectedNetwork;

  ReownAppKitModalSession? _currentSession;
  @override
  ReownAppKitModalSession? get currentSession => _currentSession;

  String? _connectedAddress;
  String? _connectedWalletName;
  BigInt _currentNativeBalanceWei = BigInt.zero;
  BigInt _currentStarsBalanceWei = BigInt.zero;
  String _starsBalanceDisplay = 'Connect to see balance';

  final String _sepoliaChainId = 'eip155:11155111';
  final String _starsTokenAddress = dotenv.env['STARS_TOKEN_ADDRESS'] ?? 'DefaultTokenAddress';
  final String _starsPlatformAddress =
      dotenv.env['STARS_PLATFORM_ADDRESS'] ?? 'DefaultPlatformAddress';
  final int _starsTokenDecimals = 18;
  final String _starsTokenSymbol = 'STR';

  DeployedContract? _starsTokenContract;
  DeployedContract? _starsPlatformContract;
  bool _areContractsLoaded = false;

  String _transactionStatus = 'Ready.';
  List<TokenTransaction> _transactions = [];
  bool _isLoadingTransactions = false;
  String _transactionListStatus = 'Connect to see transactions';

  bool _hasFetchedInitialData = false;

  BuildContext? _context;

  @override
  ReownAppKitModal get appKitModal => _appKitModal!;

  bool get isConnected =>
      _status == ReownAppKitModalStatus.initialized && _currentSession != null;

  String? get connectedAddress => _connectedAddress;
  String? get connectedWalletName => _connectedWalletName;
  BigInt get currentNativeBalanceWei => _currentNativeBalanceWei;
  BigInt get currentStarsBalanceWei => _currentStarsBalanceWei;
  String get starsBalanceDisplay => _starsBalanceDisplay;

  String get sepoliaChainId => _sepoliaChainId;
  String get starsTokenAddress => _starsTokenAddress;
  String get starsPlatformAddress => _starsPlatformAddress;
  int get starsTokenDecimals => _starsTokenDecimals;
  String get starsTokenSymbol => _starsTokenSymbol;

  bool get areContractsLoaded => _areContractsLoaded;

  String get transactionStatus => _transactionStatus;
  set transactionStatus(String status) {
    if (_transactionStatus != status) {
      _transactionStatus = status;
      notifyListeners();
    }
  }

  List<TokenTransaction> get transactions => _transactions;
  bool get isLoadingTransactions => _isLoadingTransactions;
  String get transactionListStatus => _transactionListStatus;

  double get starsPerNativeToken => _STARS_PER_NATIVE_TOKEN;
  double get nativePerStar => _NATIVE_PER_STAR;

  bool get _isSepoliaAndReady {
    return _appKitModal != null &&
        isConnected &&
        _connectedNetwork?.chainId == _sepoliaChainId &&
        _connectedAddress != null &&
        _currentSession != null &&
        _areContractsLoaded;
  }

  Future<void> init(BuildContext context) async {
    print('WalletService: Starting service initialization...');
    _context = context;

    await _loadContractAbis();

    print('WalletService: Service initialization complete.');
  }

  void _resetState() {
    _status = ReownAppKitModalStatus.idle;
    _connectedNetwork = null;
    _currentSession = null;
    _connectedAddress = null;
    _connectedWalletName = null;
    _currentNativeBalanceWei = BigInt.zero;
    _currentStarsBalanceWei = BigInt.zero;
    _starsBalanceDisplay = 'Connect to see balance';
    _transactionStatus = 'Ready.';
    _transactions = [];
    _transactionListStatus = 'Connect to see transactions';
    _hasFetchedInitialData = false;
    notifyListeners();
  }

  Future<void> connectWallet(BuildContext context) async {
    print('WalletService: Connect Wallet requested.');

    if (_appKitModal != null) {
      print(
        'WalletService: Existing AppKitModal instance found. Cleaning up before new connection.',
      );
      await _performLocalCleanup();
    }
    if (_appKitModal != null) {
      print(
        'WalletService: AppKitModal instance already exists. Calling openModalView() on existing instance.',
      );
      try {
        if (_status == ReownAppKitModalStatus.idle) {
          _status = ReownAppKitModalStatus.initializing;
          _transactionStatus = 'Opening wallet connection modal...';
          notifyListeners();
        } else {
          print(
            'WalletService: AppKitModal status is already $_status, not changing status immediately.',
          );
        }
        await _appKitModal!.openModalView();
        print(
          'WalletService: Called openModalView() on existing modal instance.',
        );
      } catch (e, s) {
        print(
          'WalletService: Error calling openModalView() on existing modal: $e\n$s',
        );
        _status = ReownAppKitModalStatus.error;
        _transactionStatus = 'Failed to open wallet modal.';
        notifyListeners();
        _handleModalError(
          ModalError('Failed to open wallet modal. Check console for details.'),
        );
      }
      return;
    }

    print('WalletService: Creating a new AppKitModal instance...');
    _status = ReownAppKitModalStatus.initializing;
    _transactionStatus = 'Initializing wallet connection...';
    notifyListeners();

    try {
      _appKitModal = ReownAppKitModal(
        context: context,
        projectId: 'b7e85b640fc5a027e6c638804768b616',
        metadata: const PairingMetadata(
          name: 'Secure Wallet App',
          description: 'A secure wallet application',
          url: 'https://reown.com/',
          icons: ['https://reown.com/logo.png'],
          redirect: Redirect(
            native: 'mysecurewalletapp://',
            universal: 'https://reown.com/mysecurewalletapp',
          ),
        ),
        requiredNamespaces: {
          'eip155': RequiredNamespace(
            chains: [_sepoliaChainId],
            methods: [
              'eth_sendTransaction',
              'eth_signTypedData_v4',
              'personal_sign',
              'eth_call',
              'wallet_switchEthChain',
              'wallet_addEthChain',
              'wallet_watchAsset',
            ],
            events: ['chainChanged', 'accountsChanged'],
          ),
        },
        logLevel: LogLevel.debug,
      );

      print('WalletService: Adding listeners to new modal instance...');

      _appKitModal!.addListener(_updateState);
      _appKitModal!.balanceNotifier.addListener(_updateNativeBalance);
      _appKitModal!.onModalError.subscribe(_handleModalError);

      print('WalletService: Initializing new AppKitModal instance...');
      await _appKitModal!.init();

      print('WalletService: Calling openModalView() on new modal instance...');

      if (_appKitModal != null) {
        await _appKitModal!.openModalView();
        print('WalletService: Called openModalView() on new modal instance.');
      } else {
        print(
          'WalletService: AppKitModal instance became null/disposed immediately after init. Cannot call openModalView.',
        );

        throw Exception(
          "Wallet connection modal became unavailable after initialization.",
        );
      }
    } catch (e, s) {
      print(
        'WalletService: Error during new AppKitModal creation/opening: $e\n$s',
      );

      if (_appKitModal != null) {
        print('WalletService: Attempting cleanup of failed modal instance.');
        await _performLocalCleanup();
      } else {
        print(
          'WalletService: No valid modal instance to clean up during error.',
        );

        _status = ReownAppKitModalStatus.error;
        _connectedNetwork = null;
        _currentSession = null;
        _connectedAddress = null;
        _connectedWalletName = null;
        _currentNativeBalanceWei = BigInt.zero;
        _currentStarsBalanceWei = BigInt.zero;
        _starsBalanceDisplay = 'Connection failed.';
        _transactionStatus = 'Connection failed.';
        _transactions = [];
        _transactionListStatus = 'Connection failed.';
        _hasFetchedInitialData = false;
        notifyListeners();
      }

      _handleModalError(
        ModalError("Failed to connect wallet. Check console for details."),
      );
    }
  }

  void _updateState() {
    print(
      'WalletService: _updateState called. AppKitModal Status: ${_appKitModal?.status}, isConnected: ${_appKitModal?.isConnected}',
    );
    print('WalletService: Current Sepolia target chainId: $_sepoliaChainId');

    if (_appKitModal == null) {
      print(
        'WalletService: _updateState called but _appKitModal is null or disposed. Skipping state update.',
      );
      return;
    }

    final newStatus = _appKitModal!.status;
    final bool newIsConnected = _appKitModal!.isConnected;
    final ReownAppKitModalSession? newSession = _appKitModal!.session;
    final ReownAppKitModalNetworkInfo? newConnectedNetwork =
        _appKitModal!.selectedChain;

    final bool wasConnectedAndReady = _isSepoliaAndReady;
    final bool isNowConnectedAndReady =
        newIsConnected &&
        newConnectedNetwork?.chainId == _sepoliaChainId &&
        newSession != null &&
        _areContractsLoaded;

    bool stateChanged = false;

    if (_status != newStatus) {
      _status = newStatus;
      stateChanged = true;
      print('Status changed to $_status');
    }
    if (_currentSession != newSession) {
      _currentSession = newSession;
      stateChanged = true;
      print('Session changed');
    }
    if (_connectedNetwork != newConnectedNetwork) {
      _connectedNetwork = newConnectedNetwork;
      stateChanged = true;
      print('Network changed to ${newConnectedNetwork?.chainId}');
    }

    String? derivedAddress = null;
    String? derivedWalletName = null;

    if (newIsConnected && newSession != null && newConnectedNetwork != null) {
      final namespace = NamespaceUtils.getNamespaceFromChain(
        newConnectedNetwork.chainId,
      );
      try {
        derivedAddress = newSession.getAddress(namespace);
      } catch (e) {
        print(
          "WalletService: Could not get address for namespace $namespace on update: $e",
        );
      }
      derivedWalletName =
          newSession.peer?.metadata.name ??
          newSession.sessionEmail ??
          newSession.sessionUsername ??
          'Unknown Wallet';
    }

    if (_connectedAddress != derivedAddress) {
      _connectedAddress = derivedAddress;
      stateChanged = true;
      print('Address changed');
    }
    if (_connectedWalletName != derivedWalletName) {
      _connectedWalletName = derivedWalletName;
      stateChanged = true;
      print('Wallet name changed');
    }

    if (isNowConnectedAndReady &&
        !wasConnectedAndReady &&
        !_hasFetchedInitialData) {
      print(
        "WalletService: Transitioned to Sepolia+Ready state. Triggering initial data fetch.",
      );

      Future.microtask(() {
        if (_isSepoliaAndReady && !_hasFetchedInitialData) {
          final address = _connectedAddress;
          if (address != null) {
            print(
              "WalletService: Calling updateWallet backend API with ID: $address",
            );
            try {
              _walletRepository
                  .updateWallet(walletId: address)
                  .then((_) {
                    print("WalletService: Backend Wallet update successful.");
                  })
                  .catchError((e, s) {
                    print(
                      "WalletService: Error calling backend updateWallet API: $e\n$s",
                    );
                    _handleModalError(
                      ModalError(
                        'Failed to update backend wallet information. Please try reconnecting.',
                      ),
                    );
                  });
            } catch (e, s) {
              print(
                "WalletService: Unexpected sync error calling backend updateWallet API: $e\n$s",
              );
              _handleModalError(
                ModalError(
                  'An unexpected error occurred during backend wallet update.',
                ),
              );
            }
          } else {
            print(
              "WalletService: Cannot call updateWallet backend API, connected address is null.",
            );
          }
          _fetchInitialData();
        } else {
          print(
            "WalletService: State changed again before initial fetch could run.",
          );
        }
      });
      _starsBalanceDisplay = 'Loading...';
      _transactionListStatus = 'Loading...';
      _transactionStatus = 'Connected to Sepolia. Loading data...';
      stateChanged = true;
    } else if (isNowConnectedAndReady && _hasFetchedInitialData) {
      if (!_transactionStatus.contains('Loading') &&
          !_transactionStatus.contains('Error') &&
          !_transactionStatus.contains('Failed') &&
          _transactionStatus != 'Ready to transact on Sepolia.') {
        _transactionStatus = 'Ready to transact on Sepolia.';
        stateChanged = true;
      }
      if (_transactionListStatus != 'Error: Etherscan API key is missing.' &&
          !_transactionListStatus.contains('Loading') &&
          !_transactionListStatus.contains('Error') &&
          !_transactionListStatus.contains('Failed')) {
        if (_transactions.isEmpty &&
            _transactionListStatus !=
                'No recent STARS transactions found for this address.') {
          _transactionListStatus =
              'No recent STARS transactions found for this address.';
          stateChanged = true;
        } else if (_transactions.isNotEmpty && _transactionListStatus != '') {
          _transactionListStatus = '';
          stateChanged = true;
        }
      }
    } else if (newIsConnected &&
        newConnectedNetwork?.chainId != _sepoliaChainId) {
      print(
        'WalletService: Connected to non-Sepolia chain (${newConnectedNetwork?.chainId}). Resetting Sepolia states.',
      );
      if (wasConnectedAndReady ||
          _hasFetchedInitialData ||
          _starsBalanceDisplay != 'Connect to see balance' ||
          _transactionListStatus != 'Connect to see transactions') {
        _starsBalanceDisplay = 'Switch wallet to Sepolia to see balance';
        _transactionStatus = 'Switch wallet to Sepolia to transact';
        _transactions = [];
        _transactionListStatus = 'Switch wallet to Sepolia to see transactions';
        _currentStarsBalanceWei = BigInt.zero;
        _currentStarsBalanceWei = BigInt.zero;
        _hasFetchedInitialData = false;
        stateChanged = true;
        print(
          'WalletService: Sepolia specific states reset due to non-Sepolia connection.',
        );
      } else {
        print(
          'WalletService: Sepolia specific states already reflect non-Sepolia connection.',
        );
      }
    } else if (!newIsConnected) {
      print(
        'WalletService: Not connected (modal still valid). Status reflects state.',
      );
      if (!newStatus.toString().contains('connecting') &&
          !newStatus.toString().contains('initializing') &&
          !newStatus.toString().contains('disconnecting') &&
          _starsBalanceDisplay != 'Connect to see balance') {
        _connectedAddress = null;
        _connectedWalletName = null;
        _currentSession = null;
        _connectedNetwork = null;
        _currentNativeBalanceWei = BigInt.zero;
        _currentStarsBalanceWei = BigInt.zero;
        _starsBalanceDisplay = 'Connect to see balance';
        _transactionStatus = 'Ready.';
        _transactions = [];
        _transactionListStatus = 'Connect to see transactions';
        _hasFetchedInitialData = false;
        stateChanged = true;
        print(
          'WalletService: Display states reset due to not connected status.',
        );
      }
    }

    if (stateChanged && _appKitModal != null) {
      print('WalletService: Notifying listeners of state change');
      notifyListeners();
    } else if (stateChanged) {
      print(
        'WalletService: State changed but modal is null/disposed. Assuming cleanup already notified.',
      );
    } else {
      print(
        'WalletService: _updateState finished, no state changes detected requiring notification.',
      );
    }
  }

  Future<void> _cleanSession({dynamic args, bool event = true}) async {
    print('WalletService: _cleanSession called by AppKitModal event.');
    await _performLocalCleanup();
  }

  Future<void> disconnect() async {
    print('WalletService: Requesting disconnect...');

    if (_appKitModal == null || !_appKitModal!.isConnected) {
      _resetState();
      return;
    }
    if (_appKitModal == null || !_appKitModal!.isConnected) {
      print(
        'WalletService: AppKitModal instance is null, disposed, or not connected. Performing local cleanup directly.',
      );
      if (_appKitModal != null) {
        await _performLocalCleanup();
      } else {
        print(
          'WalletService: No valid modal instance found, ensuring service state is reset.',
        );
        _status = ReownAppKitModalStatus.idle;
        _connectedNetwork = null;
        _currentSession = null;
        _connectedAddress = null;
        _connectedWalletName = null;
        _currentNativeBalanceWei = BigInt.zero;
        _currentStarsBalanceWei = BigInt.zero;
        _starsBalanceDisplay = 'Connect to see balance';
        _transactionStatus = 'Ready.';
        _transactions = [];
        _transactionListStatus = 'Connect to see transactions';
        _hasFetchedInitialData = false;
        notifyListeners();
      }
      return;
    }

    _status = ReownAppKitModalStatus.initializing;
    _transactionStatus = 'Disconnecting...';
    notifyListeners();

    try {
      print('WalletService: Calling appKitModal.disconnect()...');
      await _appKitModal!.disconnect();
      print(
        'WalletService: appKitModal.disconnect() returned. Expecting _cleanSession via event.',
      );
      await _performLocalCleanup();
      print('WalletService: Cleanup completed after disconnect.');
    } catch (e, s) {
      print('WalletService: Error during disconnect request: $e\n$s');
      _transactionStatus = 'Error requesting disconnect.';
      await _performLocalCleanup();

      _handleModalError(
        ModalError('Failed to disconnect properly. Please check wallet app.'),
      );
    } finally {}
  }

  Future<void> _performLocalCleanup() async {
    if (_appKitModal == null) {
      print(
        'WalletService: _performLocalCleanup called but _appKitModal is null or disposed. Skipping modal specific cleanup.',
      );
      if (_status != ReownAppKitModalStatus.idle) {
        _status = ReownAppKitModalStatus.idle;
        _connectedNetwork = null;
        _currentSession = null;
        _connectedAddress = null;
        _connectedWalletName = null;
        _currentNativeBalanceWei = BigInt.zero;
        _currentStarsBalanceWei = BigInt.zero;
        _starsBalanceDisplay = 'Connect to see balance';
        _transactionStatus = 'Ready.';
        _transactions = [];
        _transactionListStatus = 'Connect to see transactions';
        _hasFetchedInitialData = false;
        notifyListeners();
      }
      return;
    }
    print('WalletService: Performing local cleanup for modal instance...');

    try {
      print('WalletService: Removing listeners...');
      _appKitModal!.removeListener(_updateState);
      _appKitModal!.balanceNotifier.removeListener(_updateNativeBalance);
      _appKitModal!.onModalError.unsubscribe(_handleModalError);
      print('WalletService: Listeners removed.');
    } catch (e) {
      print(
        'WalletService: Error removing listeners (may indicate listeners weren\'t fully added or instance is unstable): $e',
      );
    }

    try {
      print('WalletService: Disposing AppKitModal instance...');
      await _appKitModal!.dispose();
      print('WalletService: AppKitModal instance disposed.');
    } catch (e) {
      print('WalletService: Error disposing AppKitModal instance: $e');
    } finally {
      _appKitModal = null;
    }

    print('WalletService: Resetting service state...');
    _status = ReownAppKitModalStatus.idle;
    _connectedNetwork = null;
    _currentSession = null;
    _connectedAddress = null;
    _connectedWalletName = null;
    _currentNativeBalanceWei = BigInt.zero;
    _currentStarsBalanceWei = BigInt.zero;
    _starsBalanceDisplay = 'Connect to see balance';
    _transactionStatus = 'Ready.';
    _transactions = [];
    _transactionListStatus = 'Connect to see transactions';
    _hasFetchedInitialData = false;

    print('WalletService: Local cleanup complete.');
    notifyListeners();
  }

  void _fetchInitialData() {
    if (_hasFetchedInitialData) {
      print(
        "WalletService: _fetchInitialData called but flag already true. Skipping.",
      );
      return;
    }
    if (_appKitModal == null) {
      print(
        "WalletService: Cannot fetch initial data, modal is null or disposed.",
      );
      _starsBalanceDisplay = 'Error fetching balance';
      _transactionListStatus = 'Error fetching transactions';
      _transactionStatus = 'Error fetching data';
      notifyListeners();
      return;
    }

    print(
      "WalletService: Calling _fetchInitialData(). Setting flag and status.",
    );
    _hasFetchedInitialData = true;

    _starsBalanceDisplay = 'Fetching balance...';
    _transactionListStatus = 'Fetching transactions...';
    _transactionStatus = 'Fetching data...';
    notifyListeners();

    _updateNativeBalance();
    getStarsBalance();
    fetchTokenTransactions();
  }

  void _updateNativeBalance() async {
    print("WalletService: _updateNativeBalance triggered.");

    if (_appKitModal == null ||
        !isConnected ||
        _connectedNetwork?.chainId != _sepoliaChainId ||
        _connectedAddress == null ||
        _currentSession == null) {
      print(
        "WalletService: _updateNativeBalance skipped - not connected to Sepolia or missing data.",
      );

      if (_currentNativeBalanceWei != BigInt.zero) {
        _currentNativeBalanceWei = BigInt.zero;
        notifyListeners();
      }
      return;
    }

    print(
      "WalletService: _updateNativeBalance fetching raw balance via RPC for address $_connectedAddress...",
    );

    try {
      final address = EthereumAddress.fromHex(_connectedAddress!);
      final topic = _currentSession?.topic;

      if (topic == null) {
        print(
          "WalletService: _updateNativeBalance skipped - session topic is null.",
        );
        if (_currentNativeBalanceWei != BigInt.zero) {
          _currentNativeBalanceWei = BigInt.zero;
          notifyListeners();
        }
        return;
      }

      final dynamic result = await _appKitModal!.request(
        topic: topic,
        chainId: _sepoliaChainId,
        request: SessionRequestParams(
          method: 'eth_getBalance',
          params: [address.hex, 'latest'],
        ),
      );

      if (result is String && result.startsWith('0x')) {
        final balance = BigInt.parse(result.substring(2), radix: 16);
        if (_currentNativeBalanceWei != balance) {
          _currentNativeBalanceWei = balance;
          print(
            "WalletService: Native balance updated via RPC: $_currentNativeBalanceWei wei",
          );
        } else {
          print("WalletService: Native balance fetched but unchanged.");
        }
      } else {
        print(
          "WalletService: Unexpected result format from eth_getBalance: $result",
        );
        if (_currentNativeBalanceWei != BigInt.zero) {
          _currentNativeBalanceWei = BigInt.zero;
        } else {
          print(
            "WalletService: Native balance result unexpected but was already zero.",
          );
        }
      }
    } catch (e, s) {
      print("WalletService: Error updating native balance via RPC: $e\n$s");
      if (_currentNativeBalanceWei != BigInt.zero) {
        _currentNativeBalanceWei = BigInt.zero;
      }
    } finally {
      notifyListeners();
    }
  }

  void _handleModalError(ModalError? event) {
    print('WalletService: AppKit Modal Error: ${event?.message}');
    if (event?.message != null && event!.message.isNotEmpty) {
      if (_context != null && _context!.mounted) {
        Future.delayed(Duration(milliseconds: 100), () {
          if (_context!.mounted) {
            ScaffoldMessenger.of(_context!).showSnackBar(
              SnackBar(
                backgroundColor: Colors.red,
                content: Text('Wallet Error: ${event.message}' , style: TextStyle(
                  color: Colors.white
                ),)),
            );
          }
        });
      }
    }
  }

  bool _isUserRejectedError(dynamic e) {
    final regexp = RegExp(
      r'\b(rejected|cancelled|disapproved|denied|User canceled|User denied)\b',
      caseSensitive: false,
    );

    if (e is UserRejectedRequest) return true;

    if (e is JsonRpcError) {
      if (e.code == 4001) return true;
      if (e.message != null && regexp.hasMatch(e.message!)) {
        return true;
      }
      if (e.code != null && e.code! >= 5000 && e.code! < 6000) {
        if (regexp.hasMatch(e.message ?? '')) return true;
      }
    }
    if (e is CoinbaseServiceException) {
      if (regexp.hasMatch(e.error.toString()) ||
          regexp.hasMatch(e.message.toString())) {
        return true;
      }
    }
    if (e is ThirdPartyWalletException) {
      if (regexp.hasMatch(e.message ?? '')) {
        return true;
      }
    }

    return regexp.hasMatch(e.toString());
  }

  Future<void> _loadContractAbis() async {
    print('WalletService: Starting to load ABIs...');
    _areContractsLoaded = false;

    try {
      print('WalletService: Loading StarsToken.json...');
      final starsTokenAbiString = await rootBundle.loadString(
        'assets/abis/StarsToken.json',
      );
      print('WalletService: Loading StarsPlatform.json...');
      final starsPlatformAbiString = await rootBundle.loadString(
        'assets/abis/StarsPlatform.json',
      );

      final starsTokenAbiJson = jsonDecode(starsTokenAbiString);
      final starsPlatformAbiJson = jsonDecode(starsPlatformAbiString);

      final starsTokenAbiArray = starsTokenAbiJson['abi'];
      final starsPlatformAbiArray = starsPlatformAbiJson['abi'];

      if (starsTokenAbiArray == null ||
          starsPlatformAbiArray == null ||
          starsTokenAbiArray is! List ||
          starsPlatformAbiArray is! List) {
        print('WalletService: ABI validation failed: JSON structure invalid.');
        throw Exception(
          "ABI JSON is not structured as expected (missing 'abi' key or not an array)",
        );
      }

      final starsTokenAbi = ContractAbi.fromJson(
        jsonEncode(starsTokenAbiArray),
        'StarsToken',
      );
      final starsPlatformAbi = ContractAbi.fromJson(
        jsonEncode(starsPlatformAbiArray),
        'StarsPlatform',
      );

      _starsTokenContract = DeployedContract(
        starsTokenAbi,
        EthereumAddress.fromHex(_starsTokenAddress),
      );
      _starsPlatformContract = DeployedContract(
        starsPlatformAbi,
        EthereumAddress.fromHex(_starsPlatformAddress),
      );

      _areContractsLoaded = true;
      print('WalletService: Contract ABIs loaded successfully.');

      if (_isSepoliaAndReady && !_hasFetchedInitialData) {
        print(
          "WalletService: Contracts loaded AFTER Wallet was Sepolia+Ready. Triggering initial data fetch.",
        );
        Future.microtask(() {
          if (_isSepoliaAndReady && !_hasFetchedInitialData) {
            _fetchInitialData();
          } else {
            print(
              "WalletService: State changed again before initial fetch (post-ABI load) could run.",
            );
          }
        });
        _starsBalanceDisplay = 'Loading...';
        _transactionListStatus = 'Loading...';
        _transactionStatus = 'Contracts loaded. Fetching data...';
        notifyListeners();
      } else {
        print(
          "WalletService: Contracts loaded. Sepolia ready state: $_isSepoliaAndReady, Initial fetch done: $_hasFetchedInitialData.",
        );
      }
    } catch (e, s) {
      print('WalletService: FATAL ERROR loading or parsing ABIs: $e\n$s');
      _areContractsLoaded = false;
      _starsTokenContract = null;
      _starsPlatformContract = null;
      _starsBalanceDisplay = 'Error loading contracts';
      _transactionStatus = 'Error loading contracts';
      _transactionListStatus = 'Error loading contracts';
      _currentNativeBalanceWei = BigInt.zero;
      _currentStarsBalanceWei = BigInt.zero;
      _hasFetchedInitialData = false;

      _handleModalError(
        ModalError('Error loading contract data. Check console for details.'),
      );
    } finally {
      notifyListeners();
    }
  }

  BigInt starsToWei(double starsAmount) {
    if (starsAmount < 0) return BigInt.zero;
    final bigDecimal = BigInt.from(10).pow(_starsTokenDecimals);
    try {
      final starsDecimal = Decimal.parse(starsAmount.toString());
      final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
      final weiAmountDecimal = starsDecimal * bigDecimalDecimal;
      return BigInt.parse(weiAmountDecimal.round().toString());
    } catch (e, s) {
      print(
        'WalletService: Error converting stars $starsAmount to wei: $e\n$s',
      );
      _handleModalError(ModalError("Conversion Error: Invalid star amount."));
      return BigInt.zero;
    }
  }

  BigInt starsIntToWei(int starsAmount) {
    if (starsAmount < 0) return BigInt.zero;
    final bigDecimal = BigInt.from(10).pow(_starsTokenDecimals);
    return BigInt.from(starsAmount) * bigDecimal;
  }

  double weiToStarsDouble(BigInt weiAmount, int decimals) {
    if (decimals < 0) decimals = 0;
    final bigDecimal = BigInt.from(10).pow(decimals);
    if (bigDecimal == BigInt.zero) return weiAmount.toDouble();

    try {
      final weiDecimal = Decimal.parse(weiAmount.toString());
      final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
      return (weiDecimal / bigDecimalDecimal).toDouble();
    } catch (e, s) {
      print(
        "WalletService: Error converting wei $weiAmount to stars double: $e\n$s",
      );
      return 0.0;
    }
  }

  int weiToStarsInt(BigInt weiAmount, int decimals) {
    if (decimals < 0) decimals = 0;
    final bigDecimal = BigInt.from(10).pow(decimals);
    if (bigDecimal == BigInt.zero) return 0;
    try {
      return (weiAmount ~/ bigDecimal).toInt();
    } catch (e, s) {
      print(
        "WalletService: Error converting wei $weiAmount to stars int: $e\n$s",
      );
      return 0;
    }
  }

  BigInt nativeDoubleToWei(double amount) {
    try {
      if (amount < 0) amount = 0;
      final decimalAmount = Decimal.parse(amount.toString());
      final weiFactor = Decimal.parse(BigInt.from(10).pow(18).toString());
      final weiAmountDecimal = decimalAmount * weiFactor;
      return BigInt.parse(weiAmountDecimal.round().toString());
    } catch (e, s) {
      print(
        'WalletService: Error in nativeDoubleToWei for amount $amount: $e\n$s',
      );
      _handleModalError(
        ModalError("Conversion Error: Invalid native amount entered."),
      );
      return BigInt.zero;
    }
  }

  double weiToNativeDouble(BigInt weiAmount) {
    final bigDecimal = BigInt.from(10).pow(18);
    if (bigDecimal == BigInt.zero) return weiAmount.toDouble();

    try {
      final weiDecimal = Decimal.parse(weiAmount.toString());
      final bigDecimalDecimal = Decimal.parse(bigDecimal.toString());
      return (weiDecimal / bigDecimalDecimal).toDouble();
    } catch (e, s) {
      print(
        "WalletService: Error converting wei $weiAmount to native double: $e\n$s",
      );
      return 0.0;
    }
  }

  double getNativeAmountForStars(int starsAmount) {
    if (starsAmount < 0) return 0.0;
    try {
      final starsDecimal = Decimal.parse(starsAmount.toString());
      final rateDecimal = Decimal.parse(_NATIVE_PER_STAR.toString());
      final nativeAmountDecimal = starsDecimal * rateDecimal;
      return nativeAmountDecimal.toDouble();
    } catch (e, s) {
      print(
        'WalletService: Error calculating native amount for stars $starsAmount: $e\n$s',
      );
      _handleModalError(
        ModalError("Conversion Error: Cannot calculate native cost."),
      );
      return 0.0;
    }
  }

  int getStarsAmountForNative(double nativeAmount) {
    if (nativeAmount < 0) return 0;
    try {
      final nativeDecimal = Decimal.parse(nativeAmount.toString());
      final rateDecimal = Decimal.parse(_STARS_PER_NATIVE_TOKEN.toString());
      final starsAmountDecimal = nativeDecimal * rateDecimal;
      return starsAmountDecimal.floor().toBigInt().toInt();
    } catch (e, s) {
      print(
        'WalletService: Error calculating stars for native amount $nativeAmount: $e\n$s',
      );
      _handleModalError(
        ModalError("Conversion Error: Cannot calculate stars amount."),
      );
      return 0;
    }
  }

  Future<void> getStarsBalance() async {
    print("WalletService: Attempting to get STARS balance.");
    if (!_isSepoliaAndReady) {
      print(
        "WalletService: Not ready to get STARS balance. State not Sepolia+Ready.",
      );
      if (!(_starsBalanceDisplay.contains('Loading') ||
          _starsBalanceDisplay.contains('Error') ||
          _starsBalanceDisplay.contains('Failed'))) {
        _starsBalanceDisplay = 'Not connected to Sepolia';
      }
      notifyListeners();
      return;
    }

    if (!_starsBalanceDisplay.contains('Loading')) {
      _starsBalanceDisplay = 'Getting balance...';
      notifyListeners();
    }

    try {
      final address = EthereumAddress.fromHex(_connectedAddress!);
      final topic = _currentSession?.topic;

      if (topic == null) {
        throw Exception("Session topic is null");
      }
      if (_appKitModal == null) {
        print(
          "WalletService: AppKitModal instance is null or disposed during getStarsBalance.",
        );
        throw Exception(
          "Wallet service is not in a valid state to fetch balance.",
        );
      }

      final result = await _appKitModal!.requestReadContract(
        topic: topic,
        chainId: _sepoliaChainId,
        deployedContract: _starsTokenContract!,
        functionName: 'balanceOf',
        parameters: [address],
      );

      if (result.isNotEmpty && result[0] is BigInt) {
        _currentStarsBalanceWei = result[0] as BigInt;
        final balanceDouble = weiToStarsDouble(
          _currentStarsBalanceWei,
          _starsTokenDecimals,
        );
        String formattedBalance = balanceDouble.toStringAsFixed(4);
        if (formattedBalance.contains('.')) {
          formattedBalance = formattedBalance.replaceAll(RegExp(r'0*$'), '');
          if (formattedBalance.endsWith('.')) {
            formattedBalance = formattedBalance.substring(
              0,
              formattedBalance.length - 1,
            );
          }
        }

        _starsBalanceDisplay = '$formattedBalance $_starsTokenSymbol';
        print("WalletService: Fetched STARS balance: $_starsBalanceDisplay");
      } else {
        _currentStarsBalanceWei = BigInt.zero;
        _starsBalanceDisplay = 'Could not parse balance';
        print("WalletService: Failed to parse STARS balance result: $result");
        _handleModalError(ModalError('Failed to parse STARS balance.'));
      }
    } catch (e, s) {
      print('WalletService: Error getting STARS balance: $e\n$s');
      _currentStarsBalanceWei = BigInt.zero;
      _starsBalanceDisplay = 'Error fetching balance';
      if (e is JsonRpcError) {
        print('WalletService: RPC Error fetching balance: ${e.message}');
        _handleModalError(
          ModalError(
            'RPC Error fetching balance: ${e.message ?? "Unknown error"}',
          ),
        );
      } else {
        print('WalletService: Unknown Error fetching balance: $e');
        _handleModalError(ModalError('Failed to get balance.'));
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchTokenTransactions() async {
    print('WalletService: Starting fetchTokenTransactions...');

    if (_etherscanApiKey == 'YOUR_ETHERSCAN_API_KEY' ||
        _etherscanApiKey.isEmpty) {
      print(
        "WalletService: WARNING: Etherscan API key is not set. Cannot fetch transactions.",
      );
      _transactionListStatus = 'Error: Etherscan API key is missing.';
      _transactions = [];
      _isLoadingTransactions = false;
      notifyListeners();
      return;
    }

    if (!_isSepoliaAndReady) {
      print(
        "WalletService: Not ready to fetch transactions. State not Sepolia+Ready.",
      );
      if (_transactionListStatus != 'Error: Etherscan API key is missing.' &&
          !(_transactionListStatus.contains('Loading') ||
              _transactionListStatus.contains('Error') ||
              _transactionListStatus.contains('Failed'))) {
        _transactionListStatus = 'Connect to Sepolia to see transactions.';
      }
      _transactions = [];
      _isLoadingTransactions = false;
      notifyListeners();
      return;
    }

    if (_isLoadingTransactions) {
      print("WalletService: Transaction fetch already in progress.");
      return;
    }

    _isLoadingTransactions = true;
    _transactionListStatus = 'Loading transactions...';
    notifyListeners();

    final String apiKey = _etherscanApiKey;
    final String address = _connectedAddress!;
    final String tokenAddress = _starsTokenAddress;
    final String baseUrl = 'https://api-sepolia.etherscan.io/api';

    try {
      final url = Uri.parse(
        '$baseUrl?module=account&action=tokentx&contractaddress=$tokenAddress&address=$address&page=1&offset=50&sort=desc&apikey=$apiKey',
      );

      print('WalletService: Fetching transactions from Etherscan: $url');

      final response = await get(url);
      print(
        'WalletService: Received Etherscan response status code: ${response.statusCode}',
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print(
          'WalletService: Etherscan API response status: ${data['status']}, message: ${data['message']}',
        );

        if (data['status'] == '1' && data['result'] is List) {
          final List resultList = data['result'];
          print('WalletService: Processing ${resultList.length} transactions');

          final List<TokenTransaction> fetchedTransactions = resultList
              .where((json) => json != null)
              .map((json) {
                try {
                  return TokenTransaction.fromJson(json);
                } catch (e, s) {
                  print(
                    'WalletService: Error parsing transaction JSON item: $json\nError: $e\nStack: $s',
                  );
                  return null;
                }
              })
              .where((tx) => tx != null)
              .cast<TokenTransaction>()
              .toList();

          print(
            'WalletService: Successfully fetched and parsed ${fetchedTransactions.length} transactions.',
          );

          _transactions = fetchedTransactions;
          if (_transactions.isEmpty) {
            _transactionListStatus =
                'No recent STARS transactions found for this address.';
          } else {
            _transactionListStatus = '';
          }
        } else if (data['status'] == '0' &&
            data['message'] == 'No transactions found') {
          print('WalletService: Etherscan API: No transactions found.');
          _transactionListStatus =
              'No recent STARS transactions found for this address.';
          _transactions = [];
        } else {
          final errorMessage = data['message'] ?? 'Unknown error';
          print(
            'WalletService: Etherscan API error/unexpected format (status ${data['status']}): $errorMessage',
          );
          _transactionListStatus = 'Etherscan API error: $errorMessage';
          _transactions = [];
        }
      } else {
        print(
          'WalletService: HTTP Error fetching transactions: ${response.statusCode} - ${response.reasonPhrase}',
        );
        _transactionListStatus =
            'HTTP Error: ${response.statusCode} - ${response.reasonPhrase}';
        _transactions = [];
      }
    } catch (e, s) {
      print('WalletService: Error fetching or processing transactions: $e\n$s');
      _transactionListStatus =
          'Failed to fetch transactions: ${e.runtimeType} - ${e.toString()}';
      _transactions = [];
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }

  Future<void> addStarsTokenToWallet() async {
    print("WalletService: Attempting to add STARS token to wallet.");
    if (!_isSepoliaAndReady) {
      print("WalletService: Not ready to add STARS token.");
      _transactionStatus =
          'Error: Wallet not connected to Sepolia or contracts not loaded.';
      notifyListeners();
      _handleModalError(
        ModalError('Please connect to Sepolia to add the token.'),
      );
      return;
    }

    _transactionStatus = 'Requesting wallet to add STARS token...';
    notifyListeners();

    try {
      final watchAssetParams = {
        'type': 'ERC20',
        'options': {
          'address': _starsTokenAddress,
          'symbol': _starsTokenSymbol,
          'decimals': _starsTokenDecimals,
        },
      };

      final topic = _currentSession?.topic;
      if (topic == null) {
        throw Exception("Session topic is null, cannot request add token.");
      }
      if (_appKitModal == null) {
        throw Exception("Wallet service is not in a valid state to add token.");
      }

      await _appKitModal!.request(
        topic: topic,
        chainId: _sepoliaChainId,
        request: SessionRequestParams(
          method: 'wallet_watchAsset',
          params: watchAssetParams,
        ),
      );

      _transactionStatus = 'Wallet prompted to add STARS token.';
      print('WalletService: Sent wallet_watchAsset request for STARS token.');
      Future.delayed(Duration(seconds: 2), () {
        getStarsBalance();
      });
    } catch (e, s) {
      print(
        'WalletService: Error requesting wallet to add STARS token: $e\n$s',
      );
      _transactionStatus = 'Failed to prompt wallet to add token.';

      if (_isUserRejectedError(e)) {
        _handleModalError(UserRejectedRequest());
      } else if (e is JsonRpcError) {
        _handleModalError(
          ModalError('RPC Error adding token: ${e.message ?? "Unknown error"}'),
        );
      } else {
        _handleModalError(ModalError('Failed to send add token request.'));
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> sendGiftStars(
    String recipientAddressString,
    int amountInStars,
  ) async {
    print(
      "WalletService: Attempting to send gift of $amountInStars STARS to $recipientAddressString",
    );

    if (amountInStars < 1) {
      print("WalletService: Cannot send less than 1 star.");
      _transactionStatus = 'Cannot send less than 1 star.';
      notifyListeners();
      _handleModalError(ModalError('Cannot send less than 1 star.'));
      return;
    }

    final amountWei = starsIntToWei(amountInStars);

    if (!_isSepoliaAndReady) {
      print("WalletService: Not ready to send gift.");
      _transactionStatus =
          'Error: Wallet not connected to Sepolia or contracts not loaded.';
      notifyListeners();
      _handleModalError(
        ModalError(
          'Please connect wallet and ensure contracts are loaded on Sepolia.',
        ),
      );
      return;
    }

    if (recipientAddressString.isEmpty) {
      print("WalletService: Recipient address is empty.");
      _transactionStatus = 'Error: Recipient address is empty.';
      notifyListeners();
      _handleModalError(ModalError('Please enter a recipient address.'));
      return;
    }

    EthereumAddress recipientAddress;
    try {
      recipientAddress = EthereumAddress.fromHex(
        recipientAddressString,
        enforceEip55: true,
      );
      if (recipientAddress.hex.toLowerCase() ==
          _connectedAddress!.toLowerCase()) {
        print("WalletService: Cannot gift to self.");
        _transactionStatus = 'Error: Cannot send gift to yourself.';
        notifyListeners();
        _handleModalError(ModalError('Cannot send gift to yourself.'));
        return;
      }
    } catch (e) {
      print(
        "WalletService: Invalid recipient address format or checksum: $recipientAddressString, Error: $e",
      );
      _transactionStatus = 'Error: Invalid recipient address.';
      notifyListeners();
      _handleModalError(
        ModalError('Invalid recipient address format or checksum.'),
      );
      return;
    }

    if (_currentStarsBalanceWei < amountWei) {
      print(
        "WalletService: Insufficient STARS balance for gift (Need $amountWei, have $_currentStarsBalanceWei).",
      );
      _transactionStatus = 'Error: Insufficient STARS balance.';
      notifyListeners();
      _handleModalError(ModalError('Insufficient STARS balance.'));
      return;
    }

    _transactionStatus =
        'Sending $amountInStars $_starsTokenSymbol to ${recipientAddressString.substring(0, 6)}...${recipientAddressString.substring(recipientAddressString.length - 4)}...';
    notifyListeners();

    try {
      final fromAddress = EthereumAddress.fromHex(_connectedAddress!);
      final topic = _currentSession?.topic;

      if (topic == null) {
        throw Exception("Session topic is null, cannot send gift.");
      }
      if (_starsPlatformContract == null) {
        throw Exception("StarsPlatform contract not loaded.");
      }
      if (_appKitModal == null) {
        throw Exception("Wallet service is not in a valid state to send gift.");
      }

      print("WalletService: Calling giftStars on platform contract...");
      final txHash = await _appKitModal!.requestWriteContract(
        topic: topic,
        chainId: _sepoliaChainId,
        deployedContract: _starsPlatformContract!,
        functionName: 'giftStars',
        transaction: Transaction(from: fromAddress),
        parameters: [recipientAddress, amountWei],
      );

      _transactionStatus = 'Gift Transaction sent! Hash: $txHash';
      print('WalletService: Gift Stars Tx Hash: $txHash');

      Future.delayed(Duration(seconds: 15), () {
        print("WalletService: Delayed fetch after gift transaction.");
        getStarsBalance();
        fetchTokenTransactions();
        _transactionStatus = 'Gift sent. Ready.';
        notifyListeners();
      });
    } catch (e, s) {
      print('WalletService: Error sending gift stars: $e\n$s');
      _transactionStatus = 'Gift transaction failed or rejected.';

      if (_isUserRejectedError(e)) {
        _handleModalError(UserRejectedRequest());
      } else if (e is JsonRpcError) {
        _handleModalError(
          ModalError('RPC Error gifting: ${e.message ?? "Unknown error"}'),
        );
      } else {
        _handleModalError(ModalError('Failed to send gift.'));
      }
    } finally {
      notifyListeners();
    }
  }

  Future<void> buyStars(double amountNative) async {
    print(
      "WalletService: Attempting to buy STARS with $amountNative native tokens.",
    );

    if (amountNative <= 0) {
      print("WalletService: Buy amount is zero or negative.");
      _transactionStatus = 'Error: Invalid buy amount.';
      notifyListeners();
      _handleModalError(
        ModalError('Invalid amount entered. Please enter a positive number.'),
      );
      return;
    }

    if (!_isSepoliaAndReady) {
      print("WalletService: Not ready to buy stars.");
      _transactionStatus =
          'Error: Wallet not connected to Sepolia or contracts not loaded.';
      notifyListeners();
      _handleModalError(
        ModalError(
          'Please connect wallet and ensure contracts are loaded on Sepolia.',
        ),
      );
      return;
    }

    BigInt amountWei;
    try {
      amountWei = nativeDoubleToWei(amountNative);
      if (amountWei <= BigInt.zero) {
        print(
          "WalletService: Calculated native amount in wei is zero or negative.",
        );
        _transactionStatus = 'Error: Amount conversion resulted in zero.';
        notifyListeners();
        _handleModalError(ModalError('Calculated native amount is too small.'));
        return;
      }
    } catch (e) {
      print(
        "WalletService: Error converting native amount $amountNative to wei.",
      );
      _transactionStatus = 'Error: Amount conversion failed.';
      notifyListeners();
      return;
    }

    if (_currentNativeBalanceWei < amountWei) {
      print(
        "WalletService: Insufficient native balance for buy (Need $amountWei, have $_currentNativeBalanceWei).",
      );
      _transactionStatus = 'Error: Insufficient native balance.';
      notifyListeners();
      _handleModalError(
        ModalError('Insufficient native balance to complete purchase.'),
      );
      return;
    }

    _transactionStatus =
        'Buying STARS with ${amountNative.toStringAsFixed(4).replaceAll(RegExp(r'0*$'), '').replaceAll(RegExp(r'\.$'), '')} ${_connectedNetwork?.currency ?? "Native"}...';
    notifyListeners();

    try {
      final fromAddress = EthereumAddress.fromHex(_connectedAddress!);
      final topic = _currentSession?.topic;

      if (topic == null) {
        throw Exception("Session topic is null, cannot send buy transaction.");
      }
      if (_starsPlatformContract == null) {
        throw Exception("StarsPlatform contract not loaded.");
      }
      if (_appKitModal == null) {
        throw Exception(
          "Wallet service is not in a valid state to send buy transaction.",
        );
      }

      print(
        "WalletService: Calling buyStars on platform contract with value $amountWei...",
      );
      final txHash = await _appKitModal!.requestWriteContract(
        topic: topic,
        chainId: _sepoliaChainId,
        deployedContract: _starsPlatformContract!,
        functionName: 'buyStars',
        transaction: Transaction(
          from: fromAddress,
          value: EtherAmount.inWei(amountWei),
        ),
        parameters: [],
      );

      _transactionStatus = 'Buy Transaction sent! Hash: $txHash';
      print('WalletService: Buy Stars Tx Hash: $txHash');

      Future.delayed(Duration(seconds: 15), () {
        print("WalletService: Delayed fetch after buy transaction.");
        getStarsBalance();
        fetchTokenTransactions();
        _transactionStatus = 'Buy successful. Ready.';
        notifyListeners();
      });
    } catch (e, s) {
      print('WalletService: Error sending buy stars transaction: $e\n$s');
      _transactionStatus = 'Buy transaction failed or rejected.';

      if (_isUserRejectedError(e)) {
        _handleModalError(UserRejectedRequest());
      } else if (e is JsonRpcError) {
        _handleModalError(
          ModalError('RPC Error buying: ${e.message ?? "Unknown error"}'),
        );
      } else {
        _handleModalError(ModalError('Failed to send buy transaction.'));
      }
    } finally {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    print("WalletService: Disposing WalletService...");
    if (_appKitModal != null) {
      print(
        "WalletService: Calling _performLocalCleanup during service dispose.",
      );
      Future.microtask(() => _performLocalCleanup());
    } else {
      print(
        "WalletService: _appKitModal was already null or disposed during service dispose.",
      );
      _status = ReownAppKitModalStatus.idle;
      _connectedNetwork = null;
      _currentSession = null;
      _connectedAddress = null;
      _connectedWalletName = null;
      _currentNativeBalanceWei = BigInt.zero;
      _currentStarsBalanceWei = BigInt.zero;
      _starsBalanceDisplay = 'Connect to see balance';
      _transactionStatus = 'Ready.';
      _transactions = [];
      _transactionListStatus = 'Connect to see transactions';
      _hasFetchedInitialData = false;
    }
    print("WalletService: WalletService disposed.");
    super.dispose();
  }
}
