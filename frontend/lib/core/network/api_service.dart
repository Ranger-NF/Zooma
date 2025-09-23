import 'package:dio/dio.dart';
import 'package:frontend/core/util/token_storage.dart';

class ApiService {
  static final Dio _dio = Dio(
    BaseOptions(
      baseUrl: "http://localhost:3000",
      connectTimeout: Duration(minutes: 2),
      receiveTimeout: Duration(minutes: 2),
    )
  )..interceptors.add(InterceptorsWrapper(
    onRequest: (options, handle) async{
      final token = await TokenStorage.getToken();
      if(token != null){
        options.headers["Authorization"] = "Bearer $token";
      }
      return handle.next(options);
    },
    onError: (e, handler){
      if(e.response?.statusCode == 401){
        // UnAuthorized Request Handler
      }

      return handler.next(e);
    }
  ));


  static Future<Response> get(String endpoint) async {
    return await _dio.get(endpoint);
  }

  static Future<Response> post(String endpoint, {required Map<String, dynamic> data}) async {
    return await _dio.post(endpoint, data: data);
  }

  static Future<Response> patch(String endpoint, {required Map<String, dynamic> data}) async {
    return await _dio.patch(endpoint, data: data);
  }

  static Future<Response> delete(String endpoint) async {
    return await _dio.delete(endpoint);
  }
}