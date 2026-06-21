import  'package:envied/envied.dart' ;

part 'env.g.dart' ;

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
  
  @EnviedField(varName:  'VISIONX_PROTOCOL_HISHAM' , obfuscate: true)
  static const String hishamProtocol = _Env.hishamProtocol;
  
  @EnviedField(varName:  'VISIONX_PROTOCOL_GLOBAL' , obfuscate: true)
  static const String globalProtocol = _Env.globalProtocol;

  @EnviedField(varName:  'VISIONX_MASTER_UID' , obfuscate: true)
  static const String masterUid = _Env.masterUid;
}