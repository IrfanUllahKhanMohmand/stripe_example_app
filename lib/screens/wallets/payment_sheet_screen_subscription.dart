import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:http/http.dart' as http;
import 'package:stripe_example_app/config.dart';
import 'package:stripe_example_app/screens/payment_sheet/payment_sheet_screen_custom_flow.dart';
import 'package:stripe_example_app/widgets/example_scaffold.dart';
import 'package:stripe_example_app/widgets/loading_button.dart';

class ApplePayPaymentSheetScreen extends StatefulWidget {
  const ApplePayPaymentSheetScreen({super.key});

  @override
  State<ApplePayPaymentSheetScreen> createState() => _PaymentSheetScreenState();
}

class _PaymentSheetScreenState extends State<ApplePayPaymentSheetScreen> {
  int step = 0;

  @override
  Widget build(BuildContext context) {
    return ExampleScaffold(
      title: 'Payment Sheet apple pay subscription',
      tags: const ['Single Step'],
      children: [
        Stepper(
          controlsBuilder: emptyControlBuilder,
          currentStep: step,
          steps: [
            Step(
              title: const Text('Init payment'),
              content: LoadingButton(
                onPressed: () => initPaymentSheet(
                  amount: 1099,
                  currency: 'usd',
                ),
                text: 'Init payment sheet',
              ),
            ),
            Step(
              title: const Text('Confirm payment'),
              content: LoadingButton(
                onPressed: confirmPayment,
                text: 'Pay now',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<Map<String, dynamic>> _createTestPaymentSheet(
      {required int amount, required String currency}) async {
    final url = Uri.parse('$kApiUrl/payment-sheet');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'amount': amount,
        'currency': currency,
      }),
    );
    final body = json.decode(response.body);
    if (body['error'] != null) {
      throw Exception(body['error']);
    }
    return body;
  }

  Future<void> initPaymentSheet(
      {required int amount, required String currency}) async {
    try {
      // 1. create payment intent on the server
      final data =
          await _createTestPaymentSheet(amount: amount, currency: currency);

      // create some billingdetails
      const billingDetails = BillingDetails(
        name: 'Flutter Stripe',
        email: 'email@stripe.com',
        phone: '+48888000888',
        address: Address(
          city: 'Houston',
          country: 'US',
          line1: '1459  Circle Drive',
          line2: '',
          state: 'Texas',
          postalCode: '77063',
        ),
      ); // mocked data for tests

      // 2. initialize the payment sheet
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          // Main params
          paymentIntentClientSecret: data['paymentIntent'],
          merchantDisplayName: 'Flutter Stripe Store Demo',
          // Customer params
          customerId: data['customer'],
          customerEphemeralKeySecret: data['ephemeralKey'],
          // Extra params
          primaryButtonLabel: 'Pay now',
          applePay: const PaymentSheetApplePay(
            merchantCountryCode: 'DE',
            cartItems: [
              ApplePayCartSummaryItem.recurring(
                label: 'Test subscription',
                amount: '10.00',
                intervalUnit: ApplePayIntervalUnit.month,
                intervalCount: 1,
              ),
            ],
            request: PaymentRequestType.recurring(
              description: 'subscription',
              managementUrl: 'https://flutter.dev',
              billing: ImmediateCartSummaryItem(
                label: 'Subscription',
                amount: '10.0',
                isPending: false,
              ),
            ),
          ),
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'DE',
            testEnv: true,
          ),
          style: ThemeMode.dark,
          appearance: const PaymentSheetAppearance(
            colors: PaymentSheetAppearanceColors(
              background: Colors.lightBlue,
              primary: Colors.blue,
              componentBorder: Colors.red,
            ),
            shapes: PaymentSheetShape(
              borderWidth: 4,
              shadow: PaymentSheetShadowParams(color: Colors.red),
            ),
            primaryButton: PaymentSheetPrimaryButtonAppearance(
              shapes: PaymentSheetPrimaryButtonShape(blurRadius: 8),
              colors: PaymentSheetPrimaryButtonTheme(
                light: PaymentSheetPrimaryButtonThemeColors(
                  background: Color.fromARGB(255, 231, 235, 30),
                  text: Color.fromARGB(255, 235, 92, 30),
                  border: Color.fromARGB(255, 235, 92, 30),
                ),
              ),
            ),
          ),
          billingDetails: billingDetails,
        ),
      );
      setState(() {
        step = 1;
      });
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
      rethrow;
    }
  }

  Future<void> confirmPayment() async {
    try {
      // 3. display the payment sheet.
      await Stripe.instance.presentPaymentSheet();

      setState(() {
        step = 0;
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment succesfully completed'),
          ),
        );
      }
    } on Exception catch (e) {
      if (e is StripeException && context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error from Stripe: ${e.error.localizedMessage}'),
          ),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Unforeseen error: $e'),
            ),
          );
        }
      }
    }
  }
}
