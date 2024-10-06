import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:net_x_app/animations.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => PaymentModel(),
      child: const PaymentApp(),
    ),
  );
}

// Theme model for managing app theme
class ThemeModel with ChangeNotifier {
  ThemeMode _mode = ThemeMode.light;
  ThemeMode get mode => _mode;

  void toggleTheme() {
    _mode = _mode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

// Custom theme data
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.white,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey[900],
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[900],
      foregroundColor: Colors.white,
      elevation: 0,
    ),
  );
}

// Main app widget
class PaymentApp extends StatelessWidget {
  const PaymentApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => PaymentModel()),
        ChangeNotifierProvider(create: (context) => ThemeModel()),
      ],
      child: Consumer<ThemeModel>(
        builder: (context, themeModel, child) {
          return MaterialApp(
            title: 'Payment App',
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeModel.mode,
            home: const PaymentHomePage(),
            debugShowCheckedModeBanner: false,
          );
        },
      ),
    );
  }
}

// Updated PaymentHomePage with responsive design
class PaymentHomePage extends StatelessWidget {
  const PaymentHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Payment'),
            actions: [
              IconButton(
                icon: const Icon(Icons.add),
                onPressed: () => _showAddCardDialog(context),
              ),
              IconButton(
                icon: Icon(Theme.of(context).brightness == Brightness.light
                    ? Icons.dark_mode
                    : Icons.light_mode),
                onPressed: () {
                  context.read<ThemeModel>().toggleTheme();
                  HapticFeedback.mediumImpact();
                },
              ),
            ],
          ),
          body: constraints.maxWidth < 600
              ? _buildMobileLayout(context)
              : _buildTabletLayout(context),
        );
      },
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return Column(
      children: [
        Expanded(child: _buildCardList(context)),
        _buildPayButton(context),
      ],
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: _buildCardList(context),
        ),
        Expanded(
          flex: 3,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSelectedCardDetails(context),
              const SizedBox(height: 20),
              _buildPayButton(context),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCardList(BuildContext context) {
    final cards = context.watch<PaymentModel>().cards;
    return ListView.builder(
      itemCount: cards.length,
      itemBuilder: (context, index) {
        return CardWidget(
          card: cards[index],
          onTap: () {
            context.read<PaymentModel>().selectCard(index);
            HapticFeedback.selectionClick();
          },
        );
      },
    );
  }

  Widget _buildSelectedCardDetails(BuildContext context) {
    final selectedCard = context.watch<PaymentModel>().selectedCard;
    if (selectedCard == null) {
      return const Center(child: Text('No card selected'));
    }
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Card Number: ${selectedCard.number}'),
            Text('Cardholder: ${selectedCard.holderName}'),
            Text('Expiration: ${selectedCard.expirationDate}'),
          ],
        ),
      ),
    );
  }

  Widget _buildPayButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ElevatedButton(
        onPressed: () => _showPaymentOptions(context),
        child: const Text('Pay Now'),
      ),
    );
  }

  void _showAddCardDialog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
              left: 16,
              right: 16,
              top: 16,
            ),
            child: AddCardForm(
              onCardAdded: (CreditCard newCard) {
                context.read<PaymentModel>().addCard(newCard);
                Navigator.of(context).pop();
                HapticFeedback.mediumImpact();
              },
            ),
          ),
        );
      },
    );
  }

  void _showPaymentOptions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Select Payment Outcome'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processPayment(context, true);
              },
              child: const Text('Successful Transaction'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _processPayment(context, false);
              },
              child: const Text('Failed Transaction'),
            ),
          ],
        );
      },
    );
  }

  void _processPayment(BuildContext context, bool isSuccess) {
    HapticFeedback.mediumImpact();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedLoadingIndicator(
                phoneNumber: "14372293302",
                latitude: isSuccess ? 49.269557 : 28.622221,
                longitude: isSuccess ? -123.251976 : 77.206911,
              ),
              const SizedBox(height: 16),
              // const Text('Api called with latitude: and longitude'),
            ],
          ),
        );
      },
    );

    // Future.delayed(const Duration(seconds: 2), () {
    //   Navigator.of(context).pop(); // Dismiss loading dialog
    //   // Show success or failure message
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text(isSuccess ? 'Payment successful!' : 'Payment failed!')),
    //   );
    //   HapticFeedback.mediumImpact();
    // });
  }
}

class CardWidget extends StatelessWidget {
  final CreditCard card;
  final VoidCallback? onTap;

  const CardWidget({
    Key? key,
    required this.card,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (onTap != null) {
          onTap!();
          HapticFeedback.selectionClick();
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          image: card.type == CardType.rogers ? const DecorationImage(
            image: AssetImage('assets/Rogers_Mastercard.png'),
            fit: BoxFit.fill,
          ) : null,
          color: card.type == CardType.mastercard ? card.color : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: AspectRatio(
          aspectRatio: 16 / 9,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Align(
                      alignment: Alignment.topRight,
                      child: Text(
                        card.number,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          card.holderName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Expires ${card.expirationDate}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                card.type == CardType.mastercard ?
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Image.asset(
                    'assets/mastercard_logo.png',
                    height: 40,
                  ),
                ) : Container(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

enum CardType { mastercard , rogers}

// Updated AddCardForm with haptic feedback
class AddCardForm extends StatefulWidget {
  final Function(CreditCard) onCardAdded;

  const AddCardForm({Key? key, required this.onCardAdded}) : super(key: key);

  @override
  _AddCardFormState createState() => _AddCardFormState();
}

class _AddCardFormState extends State<AddCardForm> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  final _nameController = TextEditingController();
  final _expirationController = TextEditingController();
  final _cvvController = TextEditingController();

  @override
  void dispose() {
    _numberController.dispose();
    _nameController.dispose();
    _expirationController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _numberController,
            decoration: const InputDecoration(labelText: 'Card Number'),
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(16),
              _CardNumberFormatter(),
            ],
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 19) {
                return 'Please enter a valid 16-digit card number';
              }
              return null;
            },
          ),
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: 'Cardholder Name'),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter the cardholder name';
              }
              return null;
            },
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _expirationController,
                  decoration: const InputDecoration(labelText: 'Expiration (MM/YY)'),
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(4),
                    _ExpirationDateFormatter(),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 5) {
                      return 'Please enter a valid expiration date';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _cvvController,
                  decoration: const InputDecoration(labelText: 'CVV'),
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: (value) {
                    if (value == null || value.isEmpty || value.length < 3) {
                      return 'Please enter a valid 3-digit CVV';
                    }
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                final newCard = CreditCard(
                  id: DateTime.now().millisecondsSinceEpoch,
                  number: _numberController.text,
                  holderName: _nameController.text,
                  expirationDate: _expirationController.text,
                  type: CardType.mastercard,
                  color: Colors.purple,
                );
                widget.onCardAdded(newCard);
                HapticFeedback.mediumImpact();
              } else {
                HapticFeedback.vibrate();
              }
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.length > 19) return oldValue;
    final formatted = newText.replaceAllMapped(
      RegExp(r'.{4}'),
      (match) => '${match.group(0)} ',
    );
    return newValue.copyWith(
      text: formatted.trim(),
      selection: TextSelection.collapsed(offset: formatted.trim().length),
    );
  }
}

class _ExpirationDateFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final newText = newValue.text;
    if (newText.length > 5) return oldValue;
    if (newText.length == 2 && oldValue.text.length == 1) {
      return newValue.copyWith(
        text: '$newText/',
        selection: TextSelection.collapsed(offset: 3),
      );
    }
    return newValue;
  }
}

// PaymentModel (unchanged)
class PaymentModel extends ChangeNotifier {
  final List<CreditCard> _cards = [
    CreditCard(id: 1, number: '**** **** **** 1234', holderName: 'Arjun Mishra', expirationDate: '12/28', color: const Color.fromARGB(255, 24, 120, 145), type: CardType.rogers,),
    CreditCard(id: 2, number: '**** **** **** 5678', holderName: 'Hrishi Logani', expirationDate: '06/29', color: const Color.fromRGBO(25, 84, 137, 1), type:  CardType.mastercard,),
    CreditCard(id: 3, number: '**** **** **** 9012', holderName: 'Gagenvir Gill', expirationDate: '09/27', color: const Color.fromARGB(255, 198, 41, 138), type: CardType.mastercard, ),
  ];

  CreditCard? _selectedCard;

  List<CreditCard> get cards => _cards;
  CreditCard? get selectedCard => _selectedCard;

  void selectCard(int index) {
    _selectedCard = _cards[index];
    notifyListeners();
  }

  void addCard(CreditCard card) {
    _cards.add(card);
    notifyListeners();
  }
}

class CreditCard {
  final int id;
  final String number;
  final String holderName;
  final String expirationDate;
  final Color color;
  final CardType type;

  CreditCard({
    required this.id,
    required this.number,
    required this.holderName,
    required this.expirationDate,
    required this.color,
    required this.type,
  });
}