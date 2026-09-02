import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:i18n_extension/i18n_extension.dart';

/// Helpers shared by the tests of the loaders ([I18nLoader.fromAssetDir] and
/// [I18nLoader.fromUrl]), which need to fake the asset bundle and the network.

/// Matches a [TranslationsException] whose message matches [msg].
Matcher isTranslationsException(Object msg) =>
    isA<TranslationsException>().having((e) => e.msg, 'msg', msg);

/// Makes [rootBundle] serve the given [files] (asset path -> content), as if they
/// were declared in `pubspec.yaml`. A file whose content is `null` is listed in the
/// asset manifest but fails to load.
///
/// If a [gate] is provided, every asset request waits for it before responding.
void mockAssets(Map<String, String?> files, {Future<void>? gate}) {
  rootBundle.clear();

  var manifest = {
    for (var path in files.keys)
      path: [
        {'asset': path}
      ],
  };

  var manifestBytes = const StandardMessageCodec().encodeMessage(manifest)!;

  // On the web, Flutter reads `AssetManifest.bin.json` instead, which holds the
  // same binary manifest, base64-encoded and wrapped in a JSON string. Serving
  // both lets these tests also run with `flutter test --platform chrome`.
  var manifestJson =
      json.encode(base64.encode(Uint8List.sublistView(manifestBytes)));

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      .setMockMessageHandler('flutter/assets', (ByteData? message) async {
    if (gate != null) await gate;

    var key = utf8.decode(Uint8List.sublistView(message!));

    if (key == 'AssetManifest.bin') return manifestBytes;

    if (key == 'AssetManifest.bin.json') {
      return ByteData.sublistView(Uint8List.fromList(utf8.encode(manifestJson)));
    }

    var content = files[key];
    if (content == null) return null;

    return ByteData.sublistView(Uint8List.fromList(utf8.encode(content)));
  });
}

/// Runs [body] with an http client that serves the given [responses]
/// (url -> body). Any other url responds with a 404.
Future<T> withMockHttp<T>(
  Map<String, String> responses,
  Future<T> Function() body,
) =>
    http.runWithClient(
      body,
      () => MockClient((request) async {
        var responseBody = responses[request.url.toString()];
        return (responseBody == null)
            ? http.Response('Not Found', 404)
            : http.Response(responseBody, 200);
      }),
    );
