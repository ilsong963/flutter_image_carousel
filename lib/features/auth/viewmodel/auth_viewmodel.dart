import '../data/auth_repository.dart';

class AuthViewModel {
  final AuthRepository authRepository;

  bool isSignIn = false;
  AuthViewModel(this.authRepository);



  void signIn() {
    authRepository.signIn();
  }



}