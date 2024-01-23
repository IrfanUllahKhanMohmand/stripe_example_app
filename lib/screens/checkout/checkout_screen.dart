import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_checkout/stripe_checkout.dart';
import 'package:stripe_example_app/widgets/example_scaffold.dart';
import '../../.env.example.dart';

import '../../config.dart';
import 'platforms/stripe_checkout.dart'
    if (dart.library.js) 'platforms/stripe_checkout_web.dart';

class CheckoutScreenExample extends StatefulWidget {
  const CheckoutScreenExample({
    Key? key,
  }) : super(key: key);

  @override
  State<CheckoutScreenExample> createState() => _CheckoutScreenExample();
}

class _CheckoutScreenExample extends State<CheckoutScreenExample> {
  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Checkout Page',
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 120),
        Center(
          child: ElevatedButton(
            onPressed: getCheckout,
            child: const Text('Open Checkout'),
          ),
        )
      ],
    );
  }

  Future<void> getCheckout() async {
    final String sessionId = await _createCheckoutSession();
    if (context.mounted) {
      final result = await redirectToCheckout(
        context: context,
        sessionId: sessionId,
        publishableKey: stripePublishableKey,
        successUrl: 'https://checkout.stripe.dev/success',
        canceledUrl: 'https://checkout.stripe.dev/cancel',
      );

      if (mounted) {
        final text = result.when(
          success: () => 'Paid succesfully',
          canceled: () => 'Checkout canceled',
          error: (e) => 'Error $e',
          redirected: () => 'Redirected succesfully',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(text)),
        );
      }
    }
  }

  Future<String> _createCheckoutSession() async {
    final url = Uri.parse('$kApiUrl/create-checkout-session');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        if (kIsWeb) 'port': getUrlPort(),
      }),
    );
    final Map<String, dynamic> bodyResponse = json.decode(response.body);
    print(bodyResponse);
    final id = bodyResponse['sessionId'] as String;
    log('Checkout session id $id');
    return id;
  }
}
