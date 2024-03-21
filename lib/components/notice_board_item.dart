import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/material.dart';

// NoticeBoardItem widget displays an image on the notice board with drag and drop functionality
class NoticeBoardItem extends StatelessWidget {
  final String base64Image; // Base64 encoded image data
  final void Function(String)
      onDrop; // Callback function when the item is dropped

  const NoticeBoardItem({
    required this.base64Image,
    required this.onDrop,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      top: 0,
      child: DragTarget<String>(
        builder: (context, candidateData, rejectedData) {
          return GestureDetector(
            onTap: () =>
                onDrop(base64Image), // Call onDrop function when tapped
            child: FutureBuilder<Widget>(
              future: _decodeAndDisplayImage(base64Image),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CircularProgressIndicator(); // Placeholder while loading
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return snapshot.data ??
                      Container(); // Display the decoded image
                }
              },
            ),
          );
        },
        onWillAcceptWithDetails: (data) => true, // Allow drop operation
        onAcceptWithDetails: (data) =>
            onDrop(base64Image), // Call onDrop function when accepted
      ),
    );
  }

  // Helper function to decode and display the image asynchronously
  Future<Widget> _decodeAndDisplayImage(String base64Image) async {
    // Create a ReceivePort to listen for messages from the isolate
    final ReceivePort receivePort = ReceivePort();

    // Spawn an isolate to perform image decoding
    await Isolate.spawn(_decodeImageIsolate, receivePort.sendPort);

    // Get the sendPort of the spawned isolate
    final sendPort = await receivePort.first;

    // Create a ReceivePort to receive response from the isolate
    final response = ReceivePort();

    // Send base64Image data along with sendPort to the isolate
    sendPort.send([response.sendPort, base64Image]);

    // Create a Completer to handle future completion
    final completer = Completer<Widget>();

    // Listen for response from the isolate
    response.listen((dynamic message) {
      completer.complete(
          message as Widget); // Complete the future with the decoded image
      response.close(); // Close the response port
    });

    return completer.future; // Return the future for the decoded image
  }

// Isolate function to decode the image
  static void _decodeImageIsolate(SendPort sendPort) {
    // Create a ReceivePort to listen for messages from the main isolate
    final receivePort = ReceivePort();

    // Send the sendPort of the isolate back to the main isolate
    sendPort.send(receivePort.sendPort);

    // Listen for messages from the main isolate
    receivePort.listen((dynamic message) {
      final SendPort replyTo =
          message[0] as SendPort; // Get the sendPort to reply
      final String base64Image =
          message[1] as String; // Get the base64Image data

      try {
        // Decode the base64Image and create an Image widget
        final decodedImage = Image.memory(
          base64Decode(base64Image),
          fit: BoxFit.cover,
          width: 100,
          height: 100,
        );
        replyTo.send(
            decodedImage); // Send the decoded image back to the main isolate
      } catch (e) {
        replyTo.send(Container()); // Return an empty container on error
      }
    });
  }
}
