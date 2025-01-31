import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:screenshot/screenshot.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import 'animatedballs.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: WebRTCChatScreen(),
    );
  }
}

class WebRTCChatScreen extends StatefulWidget {
  const WebRTCChatScreen({super.key});

  @override
  State createState() => _WebRTCChatScreenState();
}

class _WebRTCChatScreenState extends State<WebRTCChatScreen> {
  late IO.Socket socket;
  late RTCPeerConnection? _peerConnection;
  RTCDataChannel? _dataChannel;
  List<String> messages = [];
  final TextEditingController _messageController = TextEditingController();
  ScreenshotController screenshotController = ScreenshotController();
  late Timer _screenshotTimer;

  @override
  void initState() {
    super.initState();
    debugPrint("Initializing WebRTC Chat Screen...");
    _initializeSocket();
  }

  void _initializeSocket() {
    debugPrint("Initializing socket connection...");
    socket = IO.io('http://192.168.1.11:3000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': true,
    });

    socket.connect();
    socket.onConnect((_) {
      debugPrint('Connected to Signaling Server');
    });

    socket.on('offer', (data) async {
      debugPrint('Received offer...');
      var offer = RTCSessionDescription(data['sdp'], data['type']);
      await _peerConnection!.setRemoteDescription(offer);

      var answer = await _peerConnection!.createAnswer();
      await _peerConnection!.setLocalDescription(answer);

      socket.emit('answer', {'sdp': answer.sdp, 'type': answer.type});
      debugPrint('Answer sent!');
    });

    socket.on('answer', (data) async {
      debugPrint('Received answer...');
      var answer = RTCSessionDescription(data['sdp'], data['type']);
      await _peerConnection!.setRemoteDescription(answer);
    });

    socket.on('iceCandidate', (data) {
      debugPrint('Received iceCandidate...');
      var candidate = RTCIceCandidate(
        data['candidate'],
        data['sdpMid'],
        data['sdpMLineIndex'],
      );
      _peerConnection!.addCandidate(candidate);
    });

    _createPeerConnection();
  }

  Future<void> _createPeerConnection() async {
    debugPrint("Creating peer connection...");
    Map<String, dynamic> configuration = {
      'iceServers': [
        {'urls': 'stun:stun.l.google.com:19302'}
      ]
    };

    _peerConnection = await createPeerConnection(configuration);

    _peerConnection!.onIceCandidate = (candidate) {
      debugPrint("Sending iceCandidate...");
      socket.emit('iceCandidate', {
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    };

    _peerConnection!.onDataChannel = (channel) {
      debugPrint("Received data channel...");
      _setupDataChannel(channel);
    };
  }

  void _setupDataChannel(RTCDataChannel channel) {
    debugPrint("Setting up data channel...");
    _dataChannel = channel;
    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      setState(() {
        messages.add("Peer: ${message.text}");
        debugPrint("Received message: ${message.text}");
      });
    };
  }

  _startCall() async {
    debugPrint("Starting call...");
    RTCDataChannelInit dataChannelInit = RTCDataChannelInit();
    _dataChannel = await _peerConnection!.createDataChannel("chat", dataChannelInit);

    _dataChannel!.onMessage = (RTCDataChannelMessage message) {
      setState(() {
        messages.add("Peer: ${message.text}");
        debugPrint("Received message: ${message.text}");
      });
    };

    var offer = await _peerConnection!.createOffer();
    await _peerConnection!.setLocalDescription(offer);

    socket.emit('offer', {'sdp': offer.sdp, 'type': offer.type});
    debugPrint("Offer sent!");
  }

  void _sendMessage() {
    String message = _messageController.text;
    if (message.isNotEmpty) {
      _dataChannel!.send(RTCDataChannelMessage(message));
      setState(() {
        messages.add("Me: $message");
        _messageController.clear();
        debugPrint("Sent message: $message");
      });
    }
  }

  void _sendMessage1() {
    String message = "_messageController.text";
    if (message.isNotEmpty) {
      _dataChannel!.send(RTCDataChannelMessage(message));
      setState(() {
        messages.add("Me: $message");
        _messageController.clear();
        debugPrint("Sent message: $message");
      });
    }
  }

  Future<void> startSendingScreenshots() async {
    debugPrint("Starting screenshot sending...");
    await _startCall();

    _screenshotTimer = Timer.periodic(Duration(seconds: 5), (Timer t) {
      sendScreenshot();
    });
  }

  void stopSendingScreenshots() {
    debugPrint("Stopping screenshot sending...");
    _screenshotTimer.cancel();
  }

  void sendScreenshot() async {
    debugPrint("Capturing screenshot...");
    screenshotController.capture().then((Uint8List? image) {
      if (image != null && _dataChannel != null) {
        _dataChannel!.send(RTCDataChannelMessage.fromBinary(image));
        debugPrint('📤 Screenshot sent!');
      }
    });
  }

  void _endCall() {
    debugPrint("Ending call...");
    _dataChannel!.close();
    _peerConnection?.close();
    socket.disconnect();
    setState(() {
      messages.clear();
    });
  }

  @override
  void dispose() {
    debugPrint("Disposing WebRTC Chat Screen...");
    _endCall();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("WebRTC Desktop Monitor")),
      body: Screenshot(
        controller: screenshotController,
        child: Column(
          children: [
            AnimatedBallsContainer(),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _startCall,
                  child: Text("Start/Restart Stream"),
                ),
                ElevatedButton(
                  onPressed: startSendingScreenshots,
                  child: Text("Start Screenshot"),
                ),
                ElevatedButton(
                  onPressed: _endCall,
                  child: Text("End Stream"),
                ),
              ],
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
