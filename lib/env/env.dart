import 'package:envied/envied.dart';
part 'env.g.dart';

// when change:
// flutter pub run build_runner build --delete-conflicting-outputs

@Envied(path: 'secret.env')
abstract class Env {
  @EnviedField(varName: 'deepgram', obfuscate: true)
  static final String myApiKey = _Env.myApiKey;
}
