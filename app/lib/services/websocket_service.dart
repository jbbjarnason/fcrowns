import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';

typedef WsEventHandler = void Function(dynamic event);

class WebSocketService {
  final String wsUrl;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _eventController = StreamController<WsEvent>.broadcast();
  Stream<WsEvent> get events => _eventController.stream;

  bool _connected = false;
  bool get isConnected => _connected;

  bool _authenticated = false;
  bool get isAuthenticated => _authenticated;

  Completer<void>? _authCompleter;

  String? _accessToken;
  int _clientSeq = 0;

  WebSocketService({required this.wsUrl});

  int _nextSeq() => ++_clientSeq;

  Future<void> connect(String accessToken) async {
    _accessToken = accessToken;
    _authenticated = false;
    _authCompleter = Completer<void>();
    await _connectInternal();
    // Wait for authentication to complete
    await _authCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw Exception('WebSocket authentication timeout'),
    );
  }

  Future<void> _connectInternal() async {
    if (_accessToken == null) return;

    try {
      final uri = Uri.parse('$wsUrl?token=$_accessToken');
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      _connected = true;

      // Send hello command and wait for EvtHello response
      _sendRaw(CmdHello(jwt: _accessToken!, clientSeq: _nextSeq()).toJson());
    } catch (e) {
      _connected = false;
      _authCompleter?.completeError(e);
      rethrow;
    }
  }

  void _onMessage(dynamic data) {
    try {
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final event = WsEvent.fromJson(json);

      // Handle authentication response
      if (event is EvtHello) {
        _authenticated = true;
        _authCompleter?.complete();
      }

      _eventController.add(event);
    } catch (e) {
      // Log error
    }
  }

  void _onError(Object error) {
    _connected = false;
    _eventController.addError(error);
  }

  void _onDone() {
    _connected = false;
    // Attempt reconnect after delay
    Future.delayed(const Duration(seconds: 2), () {
      if (_accessToken != null) {
        _connectInternal();
      }
    });
  }

  void _sendRaw(Map<String, dynamic> data) {
    if (_channel != null && _connected) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null && _connected && _authenticated) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void joinGame(String gameId) {
    _send(CmdJoinGame(gameId: gameId, clientSeq: _nextSeq()).toJson());
  }

  void resync(String gameId) {
    _send(CmdResync(gameId: gameId, clientSeq: _nextSeq()).toJson());
  }

  void startGame(String gameId) {
    _send(CmdStartGame(gameId: gameId, clientSeq: _nextSeq()).toJson());
  }

  void draw(String gameId, DrawSource from) {
    _send(CmdDraw(gameId: gameId, from: from, clientSeq: _nextSeq()).toJson());
  }

  void discard(String gameId, String card) {
    _send(CmdDiscard(gameId: gameId, card: card, clientSeq: _nextSeq()).toJson());
  }

  void layDown(String gameId, List<List<String>> melds) {
    _send(CmdLayDown(gameId: gameId, melds: melds, clientSeq: _nextSeq()).toJson());
  }

  void goOut(String gameId, List<List<String>> melds, String discard) {
    _send(CmdGoOut(gameId: gameId, melds: melds, discard: discard, clientSeq: _nextSeq()).toJson());
  }

  Future<void> disconnect() async {
    _accessToken = null;
    _connected = false;
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _eventController.close();
  }
}
