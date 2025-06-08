import 'package:dio/dio.dart';
import 'package:mobile/core/network/api_endpoints.dart';
import 'package:mobile/services/api/wallet/wallet_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WalletRepositoryImpl implements WalletRepository {
  final Dio _dio;
  final ApiEndpoints apiEndpoints;

  WalletRepositoryImpl({Dio? dio, required this.apiEndpoints})
    : _dio = dio ?? Dio();

  @override
  Future<void> updateWallet({required String walletId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var authToken = prefs.getString('token');
      final response = await _dio.put(
        apiEndpoints.updateWallet,
        data: {"walletId": walletId},
        options: Options(headers: {'Authorization': 'Bearer $authToken'}),
      );

      if (response.statusCode != 200 && response.statusCode != 204) {
        throw Exception(
          'Failed to update Wallet: ${response.statusCode} ${response.statusMessage}',
        );
      }

      print('Wallet updated successfully!');
    } on DioException catch (e) {
      print('Dio error updating Wallet: ${e.message}');
      String errorMessage = 'Failed to update Wallet.';
      if (e.response != null) {
        errorMessage =
            'Failed to update Wallet: ${e.response?.statusCode} ${e.response?.statusMessage}';
        if (e.response?.data != null && e.response!.data is Map) {
          errorMessage +=
              ' - ${e.response!.data['message'] ?? e.response!.data.toString()}';
        } else if (e.response?.data != null) {
          errorMessage += ' - ${e.response!.data.toString()}';
        }
        if (e.response?.statusCode == 404) {
          errorMessage = 'Wallet not found for update.';
        }
      } else {
        errorMessage = 'Network error: ${e.message}';
      }
      throw Exception(errorMessage);
    } catch (e) {
      print('Unknown error updating Wallet: $e');
      throw Exception('An unexpected error occurred while updating Wallet.');
    }
  }
}
