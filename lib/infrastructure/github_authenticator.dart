import 'package:flutter/services.dart';
import 'package:github_app/infrastructure/credentials_storage/credentials_storage.dart';
import 'package:oauth2/oauth2.dart';


class GithubAuthenticator {
  final CredentialsStorage _credentialsStorage;
  GithubAuthenticator(this._credentialsStorage);
  static const clientId = '39524830abe838732be';
  static const clientSecret = '328ef8be21f06225ef31618e93d63c06382f81c7';
  static const scopes = ['read:user','repo'];
  static final authorizationEndPoint = Uri.parse('https://github.com/login/oauth/authorize');
  static final tokenEndPoint = Uri.parse('https://github.com/login/oauth/access_token');
  static final redirectUrl = Uri.parse('http://localhost:3000/callback');
  Future<Credentials?>getSignedInCredentials() async {
  
   try{
      final storedCredentials = await _credentialsStorage.read();
    if(storedCredentials != null){
      if(storedCredentials.canRefresh && storedCredentials.isExpired){
        // TODO: refresh
      }
    }
    return storedCredentials;
   } on PlatformException{
     return null;
   }
  }
}
