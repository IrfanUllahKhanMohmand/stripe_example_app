import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:stripe_example_app/config.dart';
import 'package:http/http.dart' as http;

class PaymentMethodsList extends StatefulWidget {
  const PaymentMethodsList({super.key});

  @override
  State<PaymentMethodsList> createState() => _PaymentMethodsListState();
}

class _PaymentMethodsListState extends State<PaymentMethodsList> {
  late final Future paymentMethodsFuture;
  String customerId = 'cus_PUjAhuX2HzZ5UJ';
  List<Map<String, dynamic>> paymentMethods = [];
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
        for (var paymentMethod in body['paymentMethods']) {
          paymentMethods.add(paymentMethod);
        }
      }
    }
    return body;
  }

  @override
  void initState() {
    paymentMethodsFuture = listPaymentMethods();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Methods'),
      ),
      body: FutureBuilder(
          future: paymentMethodsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done &&
                !snapshot.hasError) {
              return ListView.builder(
                itemCount: paymentMethods.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(paymentMethods[index]['card']['brand']),
                    subtitle: Text(
                        '**** **** **** ${paymentMethods[index]['card']['last4']}'),
                    onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => PaymentMethodDetails(
                      //         paymentMethod: paymentMethods[index]),
                      //   ),
                      // );
                    },
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        Map<String, dynamic> paymentMethod =
                            await deletePaymentMethod(
                                paymentMethodId: paymentMethods[index]['id']);
                        if (paymentMethod != null) {
                          setState(() {
                            paymentMethods.removeAt(index);
                          });
                        }
                      },
                    ),
                  );
                },
              );
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            }
            return const Center(child: CircularProgressIndicator());
          }),
    );
  }

  Future<Map<String, dynamic>> deletePaymentMethod(
      {required String paymentMethodId}) async {
    final url = Uri.parse('$kApiUrl/detach-payment-method');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({'paymentMethodId': paymentMethodId}),
    );
    final body = json.decode(response.body);
    if (body['error'] != null) {
      throw Exception(body['error']);
    }
    return body;
  }
}

class PaymentMethodDetails extends StatefulWidget {
  final Map<String, dynamic> paymentMethod;

  const PaymentMethodDetails({Key? key, required this.paymentMethod})
      : super(key: key);

  @override
  State<PaymentMethodDetails> createState() => _PaymentMethodDetailsState();
}

class _PaymentMethodDetailsState extends State<PaymentMethodDetails> {
  TextEditingController? _nameController;
  TextEditingController? _emailController;
  TextEditingController? _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController!.dispose();
    _emailController!.dispose();
    _phoneController!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Method Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Phone'),
            ),
            const SizedBox(height: 16.0),
            ElevatedButton(
              child: const Text('Update'),
              onPressed: () {
                // Handle update logic here
                String name = _nameController!.text;
                String email = _emailController!.text;
                String phone = _phoneController!.text;
                // Update the payment method data
                widget.paymentMethod['billing_details']['name'] = name;
                widget.paymentMethod['billing_details']['email'] = email;
                widget.paymentMethod['billing_details']['phone'] = phone;
                // Show a success message or perform any other actions
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Success'),
                    content: const Text('Payment method details updated.'),
                    actions: [
                      TextButton(
                        child: const Text('OK'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
