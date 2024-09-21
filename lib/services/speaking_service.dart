import "dart:async";
import 'dart:typed_data';
import 'dart:math' show Random, pow;

import "package:deepgram_speech_to_text/deepgram_speech_to_text.dart"
    show Deepgram;
import "package:flutter_book_reader/algoritms/text_chanks_splitter.dart";
import "package:flutter_tts/flutter_tts.dart";
import 'package:just_audio/just_audio.dart';
import "package:just_audio_background/just_audio_background.dart";

abstract class SpeakingService {
  /// stops last text, if it is talking now and speaks [text]
  /// if [onFinish] is! null, it will be called , when text will finished
  /// and it wasn't stoped by the next text or from pause() method
  void speak(String text, {void Function()? onFinish});

  /// stops text, if speaking
  FutureOr stop();
}

final class SpeakingServiceProvider {
  SpeakingServiceProvider(String initialService, this._selectSpeaker) {
    changeSpeaker(initialService);
  }

  SpeakingService _curService = SystemSpeaker();
  String _serviceName = "system";
  final SpeakingService? Function(String) _selectSpeaker;

  SpeakingService get service => _curService;
  String get serviceName => _serviceName;

  void changeSpeaker(String service) {
    try {
      var newService = _selectSpeaker(service);
      if (newService != null) {
        _curService.stop();
        _curService = newService;
        _serviceName = service;
      }
    } catch (_) {}
  }
}

final class SystemSpeaker implements SpeakingService {
  SystemSpeaker() {
    _speaker.setCompletionHandler(__onCompleted);
    _speaker.setStartHandler(() => _state = TtsState.playing);
  }

  void __onCompleted() {
    _state = TtsState.stopped;

    if (_forsedStop) {
      _forsedStop = false;
    } else if (_onFinish != null) {
      _onFinish!();
    }
  }

  final _speaker = FlutterTts();
  bool _forsedStop = false;
  static TtsState _state = TtsState.stopped;

  void Function()? _onFinish;

  @override
  Future speak(String text, {Function()? onFinish}) async {
    if (_state != TtsState.stopped) _forsedStop = true;
    await _speaker.stop();
    _speaker.speak(text);
    _onFinish = onFinish;
  }

  @override
  void stop() async {
    if (_state != TtsState.stopped) {
      _forsedStop = true;
      await _speaker.stop();
    }
  }
}

class DeepgramSpeakingService implements SpeakingService {
  DeepgramSpeakingService(String apiKey) {
    _speaker = Deepgram(apiKey);
    _player.playerStateStream.listen((event) {
      if (event.processingState == ProcessingState.completed) {
        if (_forsedStop) {
          _forsedStop = false;
        } else if (_onFinish != null) {
          _onFinish!();
        }
        // dont influe on the next text speach, this hanler can be called after
        // the next text speach start loading
        if (_status == TtsState.playing) _status = TtsState.stopped;
      }
    });
  }
  late final Deepgram _speaker;
  final AudioPlayer _player = AudioPlayer()..setShuffleModeEnabled(false);

  bool _forsedStop = false;
  void Function()? _onFinish;
  TtsState _status = TtsState.stopped;
  Future? _converters;
  int _curText = 0;

  static const maxChanksLength = 2000;

  @override
  FutureOr stop() async {
    if (_status == TtsState.playing) {
      _forsedStop = true;
      _status = TtsState.stopped;
      await _player.stop();
    } else if (_status == TtsState.loading) {
      _forsedStop = true;
      _status = TtsState.stopped;
      _converters?.ignore();
    }
  }

  @override
  void speak(String text, {void Function()? onFinish}) async {
    _curText = text.hashCode;
    if (_status == TtsState.playing) {
      _forsedStop = true;
      await _player.stop();
    } else if (_status == TtsState.loading) {
      _converters?.ignore();
      _status = TtsState.stopped;
    }
    _status = TtsState.loading;
    try {
      print("start request");
      var chanks = text.splitTextByChanks(maxChanksLength).toList();
      var mapShanks = <int, AudioSource>{};
      var futures = <Future>[];

      for (int j = 0; j < chanks.length; j++) {
        futures.add(
          _speaker.speakFromText(chanks[j]).then((ttsText) => mapShanks[j] =
              BytesBufferAudioSource(
                  ttsText.data, ttsText.contentType ?? "audio/wav")),
        );
      }

      print("requests started");
      _converters = Future.wait(futures, eagerError: true);
      await _converters;
      print("play sound");

      if (_status == TtsState.loading && text.hashCode == _curText) {
        var audioChanks = List.generate(chanks.length, (i) => mapShanks[i]!);
        var finalSource = ConcatenatingAudioSource(children: audioChanks);
        _status = TtsState.playing;
        await _player.setAudioSource(finalSource);
        _onFinish = onFinish;
        print("run playing");
        await _player.play();
        print("after play");
      } else {
        _forsedStop = false;
      }
    } catch (_) {
      _status = TtsState.stopped;
    }
  }
}

// -------------------------------------------------------
// additional classes
// -------------------------------------------------------

enum TtsState {
  stopped,
  loading,
  playing;
}

class BytesBufferAudioSource extends StreamAudioSource {
  final Uint8List _buffer;
  final String _contentType;

  static final _random = Random();

  BytesBufferAudioSource(this._buffer, this._contentType,
      {String tag = "book_reader"})
      : super(
          tag: MediaItem(
            id: '${_random.nextInt(pow(2, 32).toInt() - 1)}',
            title: tag,
          ),
        );

  @override
  Future<StreamAudioResponse> request([int? start, int? end]) async {
    // Returning the stream audio response with the parameters
    return StreamAudioResponse(
      sourceLength: _buffer.length,
      contentLength: (end ?? _buffer.length) - (start ?? 0),
      offset: start ?? 0,
      stream: Stream.fromIterable([_buffer.sublist(start ?? 0, end)]),
      contentType: _contentType,
    );
  }
}
