import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:fivecrowns_protocol/fivecrowns_protocol.dart';

typedef WsEventHandler = void Function(dynamic event);

enum ConnectionState { disconnected, connecting, connected, reconnecting }

class WebSocketService {
  final String wsUrl;
  WebSocketChannel? _channel;
  StreamSubscription? _subscription;

  final _eventController = StreamController<WsEvent>.broadcast();
  Stream<WsEvent> get events => _eventController.stream;

  final _connectionStateController = StreamController<ConnectionState>.broadcast();
  Stream<ConnectionState> get connectionStateStream => _connectionStateController.stream;

  ConnectionState _connectionState = ConnectionState.disconnected;
  ConnectionState get connectionState => _connectionState;
  bool get isConnected => _connectionState == ConnectionState.connected;

  bool _authenticated = false;
  bool get isAuthenticated => _authenticated;

  Completer<void>? _authCompleter;

  String? _accessToken;
  int _clientSeq = 0;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 10;
  Timer? _reconnectTimer;
  bool _intentionalDisconnect = false;

  WebSocketService({required this.wsUrl});

  int _nextSeq() => ++_clientSeq;

  void _setConnectionState(ConnectionState state) {
    _connectionState = state;
    _connectionStateController.add(state);
  }

  Future<void> connect(String accessToken) async {
    debugPrint('[WS] Connecting to WebSocket...');
    _accessToken = accessToken;
    _authenticated = false;
    _intentionalDisconnect = false;
    _reconnectAttempts = 0;
    _authCompleter = Completer<void>();
    _setConnectionState(ConnectionState.connecting);

    await _connectInternal();
    // Wait for authentication to complete
    await _authCompleter!.future.timeout(
      const Duration(seconds: 10),
      onTimeout: () {
        _setConnectionState(ConnectionState.disconnected);
        throw Exception('WebSocket authentication timeout');
      },
    );
    debugPrint('[WS] Connected and authenticated');
  }

  Future<void> _connectInternal() async {
    if (_accessToken == null || _intentionalDisconnect) return;

    try {
      final uri = Uri.parse('$wsUrl?token=$_accessToken');
      _channel = WebSocketChannel.connect(uri);

      _subscription = _channel!.stream.listen(
        _onMessage,
        onError: _onError,
        onDone: _onDone,
      );

      // Send hello command and wait for EvtHello response
      _sendRaw(CmdHello(jwt: _accessToken!, clientSeq: _nextSeq()).toJson());
    } catch (e) {
      debugPrint('[WS] Connection error: $e');
      _setConnectionState(ConnectionState.disconnected);
      _authCompleter?.completeError(e);
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic data) {
    try {
      debugPrint('[WS] Received: $data');
      final json = jsonDecode(data as String) as Map<String, dynamic>;
      final event = WsEvent.fromJson(json);

      debugPrint('[WS] Parsed event: ${event.type}');

      // Handle authentication response
      if (event is EvtHello) {
        _authenticated = true;
        _reconnectAttempts = 0; // Reset on successful connection
        _setConnectionState(ConnectionState.connected);
        debugPrint('[WS] Authenticated as: ${event.userId}');
        if (_authCompleter != null && !_authCompleter!.isCompleted) {
          _authCompleter?.complete();
        }
      }

      _eventController.add(event);
      debugPrint('[WS] Event added to controller, listeners: ${_eventController.hasListener}');
    } catch (e) {
      debugPrint('[WS] Error parsing message: $e');
    }
  }

  void _onError(Object error) {
    debugPrint('[WS] WebSocket error: $error');
    _authenticated = false;
    _setConnectionState(ConnectionState.disconnected);
    _eventController.addError(error);
    _scheduleReconnect();
  }

  void _onDone() {
    debugPrint('[WS] WebSocket closed');
    _authenticated = false;
    _setConnectionState(ConnectionState.disconnected);
    _scheduleReconnect();
  }

  void _scheduleReconnect() {
    if (_intentionalDisconnect || _accessToken == null) return;
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      debugPrint('[WS] Max reconnect attempts reached');
      return;
    }

    _reconnectTimer?.cancel();

    // Exponential backoff: 1s, 2s, 4s, 8s... capped at 30s
    final delay = min(pow(2, _reconnectAttempts).toInt(), 30);
    _reconnectAttempts++;

    debugPrint('[WS] Scheduling reconnect attempt $_reconnectAttempts in ${delay}s');
    _setConnectionState(ConnectionState.reconnecting);

    _reconnectTimer = Timer(Duration(seconds: delay), () async {
      if (_accessToken != null && !_intentionalDisconnect) {
        debugPrint('[WS] Attempting reconnect...');
        await _connectInternal();
      }
    });
  }

  void _sendRaw(Map<String, dynamic> data) {
    if (_channel != null) {
      _channel!.sink.add(jsonEncode(data));
    }
  }

  void _send(Map<String, dynamic> data) {
    if (_channel != null && isConnected && _authenticated) {
      _channel!.sink.add(jsonEncode(data));
    } else {
      debugPrint('[WS] Cannot send - not connected/authenticated');
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
    _intentionalDisconnect = true;
    _reconnectTimer?.cancel();
    _accessToken = null;
    _authenticated = false;
    _setConnectionState(ConnectionState.disconnected);
    await _subscription?.cancel();
    await _channel?.sink.close();
    _channel = null;
  }

  void dispose() {
    disconnect();
    _eventController.close();
    _connectionStateController.close();
  }
}
