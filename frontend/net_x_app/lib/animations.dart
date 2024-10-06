import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Animated loading indicator

class AnimatedLoadingIndicator extends StatefulWidget {
  final double size;
  final Color color;
  final String phoneNumber;
  final double latitude;
  final double longitude;

  const AnimatedLoadingIndicator({
    Key? key,
    this.size = 50.0,
    this.color = Colors.blue,
    required this.phoneNumber,
    required this.latitude,
    required this.longitude,
  }) : super(key: key);

  @override
  _AnimatedLoadingIndicatorState createState() => _AnimatedLoadingIndicatorState();
}

class _AnimatedLoadingIndicatorState extends State<AnimatedLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isLoading = true;
  String _message = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();

    _makeApiCall();
  }

  Future<void> _makeApiCall() async {
    try {
      // Call the SIM swap API first
      final simSwapResponse = await http.get(
        Uri.parse('http://128.189.220.228:8000/isAuthorizedSwap?phoneNumber=14372293302'),
      );

      if (simSwapResponse.statusCode == 200) {
        final simSwapData = json.decode(simSwapResponse.body);
        if (simSwapData['isSwapped'] == false) {
          // SIM swap check is okay, proceed with location verification
          final locationVerificationResponse = await http.get(
            Uri.parse('http://128.189.220.228:8000/locationVerification?phoneNumber=${widget.phoneNumber}&latitude=${widget.latitude}&longitude=${widget.longitude}'),
          );

          if (locationVerificationResponse.statusCode == 200) {
            final locationData = json.decode(locationVerificationResponse.body);
            if (locationData['withinRadius'] == true) {
              // Payment successful
              _message = 'Payment successful!';
            } else {
              // Transaction failure due to location check failure
              _message = 'Transaction failed: User not in correct location.';
            }
          } else {
            // Handle location verification error
            _message = 'Error in location verification: ${locationVerificationResponse.body}';
          }
        } else {
          // Transaction failure due to SIM swap detection
          _message = 'Transaction failed: SIM swap detected.';
        }
      } else {
        // Handle SIM swap API error
        _message = 'Error in SIM swap check: ${simSwapResponse.body}';
      }
    } catch (e) {
      // Handle other exceptions
      _message = 'An error occurred: $e';
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Transform.rotate(
                angle: _controller.value * 2 * 3.14,
                child: Container(
                  width: widget.size,
                  height: widget.size,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: widget.color,
                      width: 4,
                      style: BorderStyle.solid,
                    ),
                    gradient: SweepGradient(
                      center: Alignment.center,
                      colors: [
                        widget.color.withOpacity(0),
                        widget.color,
                      ],
                      stops: [0.0, _controller.value],
                    ),
                  ),
                ),
              );
            },
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                _message.contains('successful') ? Icons.check_circle : Icons.error,
                color: _message.contains('successful') ? Colors.green : Colors.red,
                size: widget.size,
              ),
              const SizedBox(height: 10),
              Text(_message,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              Text("API called with latitude: ${widget.latitude}, longitude: ${widget.longitude}",
                  style: TextStyle(fontSize: 12,)),
            ],
          );
  }
}