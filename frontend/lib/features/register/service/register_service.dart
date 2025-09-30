import 'package:frontend/core/network/api_service.dart';

class RegisterService {
  final ApiService apiService;
  RegisterService(this.apiService);

  Future<String> submitRegister(String username) async{
    try{
      final res = await apiService.post(
        'player/create/',
        data: {"username": username}
      );
      if(res.statusCode == 200 || res.statusCode == 201){
        return res.data["id"];
      }
      return "Failed to Register";
    } catch(e){
      return "$e";
    }
  }

}