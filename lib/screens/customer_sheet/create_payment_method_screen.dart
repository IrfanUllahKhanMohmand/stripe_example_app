import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:stripe_example_app/config.dart';

class CreatePaymentMethodScreen extends StatefulWidget {
  const CreatePaymentMethodScreen({super.key});

  @override
  State<CreatePaymentMethodScreen> createState() =>
      _CreatePaymentMethodScreenState();
}

class _CreatePaymentMethodScreenState extends State<CreatePaymentMethodScreen> {
  String cardNumber = '';
  int expMonth = 0;
  int expYear = 0;
  String cvc = '';

  Future<void> sendPaymentMethod() async {
    final url = Uri.parse('$kApiUrl/create-payment-method');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'params': {
          'type': 'card',
          'card': {
            'number': cardNumber,
            'exp_month': expMonth,
            'exp_year': expYear,
            'cvc': cvc,
          }
        }
      }),
    );
    final body = json.decode(response.body);
    if (body['error'] != null) {
      throw Exception(body['error']);
    }
    return body;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Payment Method'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  cardNumber = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'Card Number',
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  expMonth = int.parse(value);
                });
              },
              decoration: const InputDecoration(
                labelText: 'Expiration Month',
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  expYear = int.parse(value);
                });
              },
              decoration: const InputDecoration(
                labelText: 'Expiration Year',
              ),
            ),
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) {
                setState(() {
                  cvc = value;
                });
              },
              decoration: const InputDecoration(
                labelText: 'CVC',
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                await sendPaymentMethod();
              },
              child: const Text('Create Payment Method'),
            ),
          ],
        ),
      ),
    );
  }
}
