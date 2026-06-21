import  'package:envied/envied.dart' ;

part  'env.g.dart' ;

@Envied(path:  '.env' )
abstract class Env {
  @EnviedField(varName:  'VISIONX_API_KEY' , obfuscate: true)
  static const String apiKey = _Env.apiKey;
  
  @EnviedField(varName:  'VISIONX_API_URL' , obfuscate: true)
  static const String apiUrl = _Env.apiUrl;
  
  @EnviedField(varName:  'VISIONX_MODEL' , obfuscate: true)
  static const String model = _Env.model;
  
  @EnviedField(varName:  'VISIONX_TAVILY_KEY' , obfuscate: true)
  static const String tavilyKey = _Env.tavilyKey;
}