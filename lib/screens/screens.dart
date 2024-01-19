import 'package:flutter/material.dart';
import 'package:stripe_example_app/screens/checkout/checkout_screen.dart';
import 'package:stripe_example_app/screens/customer_sheet/customer_sheet_screen.dart';
import 'package:stripe_example_app/screens/payment_sheet/payment_element/payment_element.dart';
import 'package:stripe_example_app/screens/payment_sheet/payment_sheet_deffered_screen.dart';
import 'package:stripe_example_app/screens/payment_sheet/payment_sheet_screen.dart';
import 'package:stripe_example_app/screens/payment_sheet/payment_sheet_screen_custom_flow.dart';
import 'package:stripe_example_app/screens/regional_payment_methods/ali_pay_screen.dart';
import 'package:stripe_example_app/screens/regional_payment_methods/aubecs_debit.dart';
import 'package:stripe_example_app/screens/regional_payment_methods/cash_app_screen.dart';
import 'package:stripe_example_app/screens/regional_payment_methods/fpx_screen.dart';
import 'package:stripe_example_app/screens/regional_payment_methods/ideal_screen.dart';
import 'package:stripe_example_app/screens/regional_payment_methods/klarna_screen.dart';
import 'package:stripe_example_app/screens/regional_payment_methods/paypal_screen.dart';
import 'package:stripe_example_app/screens/regional_payment_methods/revolutpay_screen.dart';
import 'package:stripe_example_app/screens/regional_payment_methods/sofort_screen.dart';
import 'package:stripe_example_app/screens/regional_payment_methods/us_bank_account.dart';
import 'package:stripe_example_app/screens/wallets/apple_pay_screen.dart';
import 'package:stripe_example_app/screens/wallets/apple_pay_screen_plugin.dart';
import 'package:stripe_example_app/screens/wallets/google_pay_screen.dart';
import 'package:stripe_example_app/screens/wallets/google_pay_stripe_screen.dart';
import 'package:stripe_example_app/screens/wallets/open_apple_pay_setup_screen.dart';
import 'package:stripe_example_app/widgets/platform_icons.dart';

import 'card_payments/custom_card_payment_screen.dart';
import 'card_payments/no_webhook_payment_cardform_screen.dart';
import 'card_payments/no_webhook_payment_screen.dart';
import 'card_payments/webhook_payment_screen.dart';
import 'financial_connections.dart/financial_connections_session_screen.dart';
import 'others/cvc_re_collection_screen.dart';
import 'others/legacy_token_bank_screen.dart';
import 'others/legacy_token_card_screen.dart';
import 'others/setup_future_payment_screen.dart';
import 'regional_payment_methods/grab_pay_screen.dart';
import 'themes.dart';
import 'wallets/apple_pay_create_payment_method.dart';
import 'wallets/payment_sheet_screen_subscription.dart';

class ExampleSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  final bool expanded;

  const ExampleSection({
    Key? key,
    required this.title,
    required this.children,
    this.expanded = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ExpansionTile(
      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
      initiallyExpanded: expanded,
      childrenPadding: const EdgeInsets.only(left: 20),
      title: Text(title),
      children:
          ListTile.divideTiles(tiles: children, context: context).toList(),
    );
  }
}

class Example extends StatelessWidget {
  final String title;
  final TextStyle? style;
  final Widget? leading;
  final List<DevicePlatform> platformsSupported;

  final WidgetBuilder builder;

  const Example({
    super.key,
    required this.title,
    required this.builder,
    this.style,
    this.leading,
    this.platformsSupported = DevicePlatform.values,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        final route = MaterialPageRoute(builder: builder);
        Navigator.push(context, route);
      },
      title: Text(title, style: style),
      leading: leading,
      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
        PlatformIcons(supported: platformsSupported),
        const Icon(Icons.chevron_right_rounded),
      ]),
    );
  }

  static List<Example> paymentMethodScreens = [];

  static List<Widget> screens = [
    ExampleSection(
      title: 'Payment Sheet',
      expanded: true,
      children: [
        Example(
          title: 'Single Step',
          builder: (context) => const PaymentSheetScreen(),
          platformsSupported: const [
            DevicePlatform.android,
            DevicePlatform.ios
          ],
        ),
        Example(
          title: 'Single Step (deffered payment)',
          builder: (context) => const PaymentSheetDefferedScreen(),
          platformsSupported: const [
            DevicePlatform.android,
            DevicePlatform.ios
          ],
        ),
        Example(
          title: 'Custom Flow',
          builder: (context) => const PaymentSheetScreenWithCustomFlow(),
          platformsSupported: const [
            DevicePlatform.android,
            DevicePlatform.ios
          ],
        ),
        Example(
          title: 'Web Payment Element',
          builder: (c) => const PaymentElementExample(),
          platformsSupported: const [
            DevicePlatform.web,
          ],
        ),
      ],
    ),
    ExampleSection(title: 'Customer sheet', children: [
      Example(
        title: 'Customer sheet',
        builder: (context) => const CustomerSheetScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
    ]),
    ExampleSection(
      title: 'Card Payments',
      children: [
        Example(
          title: 'Simple - Using webhooks',
          style: const TextStyle(fontWeight: FontWeight.w600),
          builder: (c) => const WebhookPaymentScreen(),
        ),
        Example(
          title: 'Without webhooks',
          builder: (c) => const NoWebhookPaymentScreen(),
        ),
        Example(
          title: 'Card Field themes',
          builder: (c) => const ThemeCardExample(),
        ),
        Example(
          title: 'Card Form',
          builder: (c) => const NoWebhookPaymentCardFormScreen(),
          platformsSupported: const [
            DevicePlatform.android,
            DevicePlatform.ios
          ],
        ),
        Example(
          title: 'Flutter UI (not PCI compliant)',
          builder: (c) => const CustomCardPaymentScreen(),
          platformsSupported: const [
            DevicePlatform.android,
            DevicePlatform.ios
          ],
        ),
      ],
    ),
    ExampleSection(
      title: 'Wallets',
      children: [
        Example(
          title: 'Apple Pay',
          leading: Image.asset(
            'assets/apple_pay.png',
            width: 48,
          ),
          builder: (c) => const ApplePayScreen(),
          platformsSupported: const [DevicePlatform.ios],
        ),
        Example(
          title: 'Apple Pay - Pay Plugin',
          leading: Image.asset(
            'assets/apple_pay.png',
            width: 48,
          ),
          builder: (c) => const ApplePayExternalPluginScreen(),
          platformsSupported: const [DevicePlatform.ios],
        ),
        Example(
          title: 'Apple Pay - Create payment method',
          leading: Image.asset(
            'assets/apple_pay.png',
            width: 48,
          ),
          builder: (c) => const ApplePayCreatePaymentMethodScreen(),
          platformsSupported: const [DevicePlatform.ios],
        ),
        Example(
          title: 'Apple Pay - Paymentsheet subscription',
          leading: Image.asset(
            'assets/apple_pay.png',
            width: 48,
          ),
          builder: (c) => const ApplePayPaymentSheetScreen(),
          platformsSupported: const [DevicePlatform.ios],
        ),
        Example(
          title: 'Open Apple Pay setup',
          leading: Image.asset(
            'assets/apple_pay.png',
            width: 48,
          ),
          builder: (c) => const OpenApplePaySetup(),
          platformsSupported: const [DevicePlatform.ios],
        ),
        Example(
          leading: Image.asset(
            'assets/google_play.png',
            width: 48,
          ),
          title: 'Google Pay',
          builder: (c) => const GooglePayStripeScreen(),
          platformsSupported: const [DevicePlatform.android],
        ),
        Example(
          leading: Image.asset(
            'assets/google_play.png',
            width: 48,
          ),
          title: 'Google Pay - Pay Plugin',
          builder: (c) => const GooglePayScreen(),
          platformsSupported: const [DevicePlatform.android],
        ),
      ],
    ),
    ExampleSection(title: 'Regional Payment Methods', children: [
      Example(
        title: 'Ali Pay',
        leading: Image.asset(
          'assets/alipay.png',
          width: 48,
        ),
        builder: (context) => const AliPayScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      Example(
        title: 'Cash app Pay',
        builder: (context) => const CashAppScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      Example(
        title: 'Ideal',
        leading: Image.asset(
          'assets/ideal_pay.png',
          width: 48,
        ),
        builder: (context) => const IdealScreen(),
      ),
      Example(
        title: 'Sofort',
        leading: const SizedBox(),
        builder: (context) => const SofortScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      Example(
        title: 'Aubecs',
        builder: (context) => const AubecsExample(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      Example(
        title: 'Fpx',
        leading: Image.asset(
          'assets/fpx.png',
          width: 48,
        ),
        builder: (contex) => const FpxScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      Example(
        title: 'Grab pay',
        leading: Image.asset(
          'assets/grab_pay.png',
          width: 48,
        ),
        builder: (contex) => const GrabPayScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      Example(
        title: 'Klarna',
        leading: Image.asset(
          'assets/klarna.jpg',
          width: 48,
        ),
        builder: (contex) => const KlarnaScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      Example(
        title: 'PayPal',
        leading: Image.asset(
          'assets/paypal.png',
          width: 48,
        ),
        builder: (contex) => const PayPalScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      Example(
        title: 'RevolutPay',
        leading: Image.asset(
          'assets/revolut.png',
          width: 48,
        ),
        builder: (context) => const RevolutPayScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      Example(
        title: 'Us bank accounts (ACH)',
        builder: (contex) => const UsBankAccountScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      // Example(
      //   title: 'WeChat Pay',
      //   leading: Image.asset(
      //     'assets/wechat_pay.png',
      //     width: 48,
      //   ),
      //   builder: (context) => WeChatPayScreen(),
      // ),
    ]),
    ExampleSection(
      title: 'Financial connections',
      children: [
        Example(
          title: 'Financial connection sessions',
          builder: (_) => const FinancialConnectionsScreen(),
          platformsSupported: const [
            DevicePlatform.android,
            DevicePlatform.ios,
          ],
        ),
      ],
    ),
    ExampleSection(title: 'Others', children: [
      Example(
        title: 'Setup Future Payment',
        builder: (c) => const SetupFuturePaymentScreen(),
      ),
      Example(
        title: 'Re-collect CVC',
        builder: (c) => const CVCReCollectionScreen(),
        platformsSupported: const [DevicePlatform.android, DevicePlatform.ios],
      ),
      Example(
        title: 'Create token for card (legacy)',
        builder: (context) => const LegacyTokenCardScreen(),
        platformsSupported: const [
          DevicePlatform.android,
          DevicePlatform.ios,
          DevicePlatform.web,
        ],
      ),
      Example(
        title: 'Create token for bank (legacy)',
        builder: (context) => const LegacyTokenBankScreen(),
        platformsSupported: const [
          DevicePlatform.android,
          DevicePlatform.ios,
          DevicePlatform.web,
        ],
      ),
    ]),
    Example(
      title: 'Checkout',
      builder: (c) => const CheckoutScreenExample(),
      platformsSupported: const [
        DevicePlatform.android,
        DevicePlatform.ios,
        DevicePlatform.web
      ],
    ),
  ];
}
