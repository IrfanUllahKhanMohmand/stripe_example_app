import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_example_app/config.dart';
import 'package:stripe_example_app/screens/payment_sheet/list_payment_methods.dart';
import 'package:stripe_example_app/widgets/example_scaffold.dart';
import 'package:stripe_example_app/widgets/loading_button.dart';

class ListPaymentIntentsScreen extends StatefulWidget {
  const ListPaymentIntentsScreen({super.key});

  @override
  State<ListPaymentIntentsScreen> createState() =>
      _ListPaymentIntentsScreenState();
}

class _ListPaymentIntentsScreenState extends State<ListPaymentIntentsScreen> {
  List<String> paymentIntents = [];
  List<Map<String, dynamic>> paymentMethods = [];
  String reslt = '';
  String customerId = 'cus_PUjAhuX2HzZ5UJ';
  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'List Payment Intents',
      tags: const ['Single Step'],
      children: [
        LoadingButton(
            onPressed: () async {
              await Stripe.instance.presentCustomerSheet();
            },
            text: 'Present customer sheet'),
        LoadingButton(
          onPressed: listPaymentIntents,
          text: 'List payment intents',
        ),
        LoadingButton(
          onPressed: listPaymentMethods,
          text: 'List payment methods',
        ),
        LoadingButton(
          onPressed: () async {
            Map<String, dynamic> result = await retrieveSetupIntent();
            setState(() {
              reslt = result.toString();
            });
          },
          text: 'Show first payment intent details',
        ),
        LoadingButton(
          onPressed: () async {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PaymentMethodsList(),
              ),
            );
          },
          text: 'Show All Payment Methods',
        ),
        Text(reslt)
      ],
    );
  }

  Future<Map<String, dynamic>> listPaymentIntents() async {
    final url = Uri.parse('$kApiUrl/list-setup-intents');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
    );
    final body = json.decode(response.body);
    if (body['error'] != null) {
      throw Exception(body['error']);
    }
    if (body['setupIntents'] != null) {
      if (body['setupIntents'].length > 0) {
        for (var setupIntent in body['setupIntents']) {
          paymentIntents.add(setupIntent['id']);
        }
      }
    }
    return body;
  }

  Future<Map<String, dynamic>> listPaymentMethods() async {
    final url = Uri.parse('$kApiUrl/fetch-payment-methods');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'customerId': customerId,
      }),
    );
    final body = json.decode(response.body);
    if (body['error'] != null) {
      throw Exception(body['error']);
    }
    if (body['paymentMethods'] != null) {
      if (body['paymentMethods'].length > 0) {
        for (var paymentMethods in body['paymentMethods']) {
          paymentMethods.add(paymentMethods);
        }
      }
    }
    return body;
  }

  Future<Map<String, dynamic>> retrieveSetupIntent() async {
    final url = Uri.parse('$kApiUrl/retrieve-setup-intent');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'setupIntentId': paymentIntents[0],
      }),
    );
    final body = json.decode(response.body);
    if (body['error'] != null) {
      throw Exception(body['error']);
    }
    if (body['setupIntent'] == null) {
      throw Exception('No setup intent found');
    }
    return body['setupIntent'];
  }
}
