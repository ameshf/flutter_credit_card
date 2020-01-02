import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_credit_card/flutter_credit_card.dart';

import 'credit_card_model.dart';
import 'credit_card_model.dart';
import 'credit_card_widget.dart';
import 'credit_card_widget.dart';
import 'credit_card_widget.dart';
import 'credit_card_widget.dart';

class CreditCardForm extends StatefulWidget {
  const CreditCardForm({
    Key key,
    this.cardNumber,
    this.expiryDate,
    this.cardHolderName,
    this.cvvCode,
    @required this.preCardNumber,
    @required this.preCardHolderName,
    @required this.preCvvCode,
    @required this.preExpiryDate,
    @required this.onExpiryDateError,
    @required this.onCreditCardModelChange,
    this.themeColor,
    this.textColor = Colors.black,
    this.cursorColor,
  }) : super(key: key);

  final String cardNumber;
  final String expiryDate;
  final String cardHolderName;
  final String cvvCode;
  final String preCardNumber;
  final String preExpiryDate;
  final String preCardHolderName;
  final String preCvvCode;
  final void Function(CreditCardModel) onCreditCardModelChange;
  final Color themeColor;
  final Color textColor;
  final Color cursorColor;
  final String onExpiryDateError;

  @override
  _CreditCardFormState createState() => _CreditCardFormState();
}

class _CreditCardFormState extends State<CreditCardForm> {
  String cardNumber;
  String expiryDate;
  String cardHolderName;
  String cvvCode;
  bool isCvvFocused = false;
  Color themeColor;
  bool isAmex = false;
  bool isExpError = false;
  FocusNode cardFocusNode = FocusNode();
  FocusNode expDateFocusNode = FocusNode();
  FocusNode cvvFocusNode = FocusNode();
  FocusNode cardNameFocusNode = FocusNode();

  void Function(CreditCardModel) onCreditCardModelChange;
  CreditCardModel creditCardModel;
  MaskedTextController _cardNumberController;
  /* MaskedTextController(mask: '0000 0000 0000 0000');*/
  final TextEditingController _expiryDateController =
      MaskedTextController(mask: '00/00');
  final TextEditingController _cardHolderNameController =
      TextEditingController();
  MaskedTextController _cvvCodeController;
  /*MaskedTextController(mask: '0000');*/

  void textFieldFocusDidChange() {
    creditCardModel.isCvvFocused = cvvFocusNode.hasFocus;
    onCreditCardModelChange(creditCardModel);
  }

  void createCreditCardModel() {
    cardNumber = widget.cardNumber ?? widget.preCardNumber;
    expiryDate = widget.expiryDate ?? widget.preExpiryDate;
    cardHolderName = widget.cardHolderName ?? widget.preCardHolderName;
    cvvCode = widget.cvvCode ?? widget.preCvvCode;
    if (cardNumber != '' ) {
      _cardNumberController.text = cardNumber ?? '';
      _expiryDateController.text = expiryDate ?? '';
      _cvvCodeController.text = cvvCode ?? '';
      _cardHolderNameController.text = cardHolderName ?? '';
    }
    creditCardModel = CreditCardModel(
        cardNumber, expiryDate, cardHolderName, cvvCode, isCvvFocused);
  }

  @override
  void initState() {
    super.initState();

    int currentMonth = DateTime.now().month;
    int currentYear = int.parse(DateTime.now().year.toString().substring(2, 4));

    createCreditCardModel();

    _cardNumberController = MaskedTextController(mask: '0000 0000 0000 0000');
    _cvvCodeController = MaskedTextController(mask: '000');

    onCreditCardModelChange = widget.onCreditCardModelChange;

    cvvFocusNode.addListener(textFieldFocusDidChange);

    /*setState(() {
      creditCardModel.cardNumber = widget.preCardNumber;
      creditCardModel.expiryDate = widget.preExpiryDate;
      creditCardModel.cvvCode = widget.preCvvCode;
      creditCardModel.cardHolderName = widget.preCardHolderName;
      onCreditCardModelChange(creditCardModel);
    });*/

    _cardNumberController.addListener(() {
      setState(() {
        cardNumber = _cardNumberController.text;
        creditCardModel.cardNumber = cardNumber;
        onCreditCardModelChange(creditCardModel);
        if (cardNumber.length > 2) {
          if (cardNumber.substring(0, 2) == '34' ||
              cardNumber.substring(0, 2) == '37') {
            _cardNumberController.updateMask('0000 000000 00000');
            isAmex = true;
          } else {
            _cardNumberController.updateMask('0000 0000 0000 0000');
            isAmex = false;
          }
        }
      });
    });

    _expiryDateController.addListener(() {
      setState(() {
        expiryDate = _expiryDateController.text;
        creditCardModel.expiryDate = expiryDate;
        onCreditCardModelChange(creditCardModel);
        if (expiryDate.length == 5) {
          var enteredMonth = int.parse(expiryDate.substring(0, 2));

          var enteredYear = int.parse(expiryDate.substring(3, 5));
          if (enteredYear < currentYear ||
              (enteredYear == currentYear && enteredMonth < currentMonth)) {
            isExpError = true;
          } else {
            isExpError = false;
          }
        } else {
          isExpError = false;
        }
      });
    });

    _cardHolderNameController.addListener(() {
      setState(() {
        cardHolderName = _cardHolderNameController.text;
        creditCardModel.cardHolderName = cardHolderName;
        onCreditCardModelChange(creditCardModel);
      });
    });

    _cvvCodeController.addListener(() {
      setState(() {
        cvvCode = _cvvCodeController.text;
        creditCardModel.cvvCode = cvvCode;
        onCreditCardModelChange(creditCardModel);
        if (cardNumber.length > 2) {
          if (cardNumber.substring(0, 2) == '34' ||
              cardNumber.substring(0, 2) == '37') {
            _cvvCodeController.updateMask('0000');
          } else {
            _cvvCodeController.updateMask('000');
          }
        } else {
          _cvvCodeController.updateMask('000');
        }
      });
    });
  }

  @override
  void didChangeDependencies() {
    themeColor = widget.themeColor ?? Theme.of(context).primaryColor;
    super.didChangeDependencies();
  }

  void fieldFocusChange(
      BuildContext context, FocusNode currentFocus, FocusNode nextFocus) {
    currentFocus.unfocus();
    FocusScope.of(context).requestFocus(nextFocus);
  }

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: ThemeData(
        primaryColor: themeColor.withOpacity(0.8),
        primaryColorDark: themeColor,
      ),
      child: Form(
        child: Column(
          children: <Widget>[
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, top: 8, right: 16),
              child: TextFormField(
                focusNode: cardFocusNode,
                onFieldSubmitted: (term) {
                  fieldFocusChange(context, cardFocusNode, expDateFocusNode);
                },
                controller: _cardNumberController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: const InputDecoration(
                  labelText: 'Card number',
                  hintText: 'xxxx xxxx xxxx xxxx',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: TextFormField(
                focusNode: expDateFocusNode,
                onFieldSubmitted: (term) {
                  fieldFocusChange(context, expDateFocusNode, cvvFocusNode);
                },
                controller: _expiryDateController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: isExpError ? Colors.red : widget.textColor,
                ),
                decoration: const InputDecoration(
                    labelText: 'Expired Date', hintText: 'MM/YY'),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
              ),
            ),
            isExpError
                ? Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(left: 20),
                        child: Text(
                          widget.onExpiryDateError,
                          style: TextStyle(color: Colors.red, fontSize: 12),
                        ),
                      ),
                    ],
                  )
                : Container(),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: TextFormField(
                focusNode: cvvFocusNode,
                onFieldSubmitted: (term) {
                  fieldFocusChange(context, cvvFocusNode, cardNameFocusNode);
                },
                controller: _cvvCodeController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: InputDecoration(
                  labelText: 'CVV',
                  hintText: isAmex ? 'XXXX' : 'XXX',
                ),
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.next,
                onChanged: (String text) {
                  setState(() {
                    cvvCode = text;
                  });
                },
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              margin: const EdgeInsets.only(left: 16, right: 16),
              child: TextFormField(
                focusNode: cardNameFocusNode,
                controller: _cardHolderNameController,
                cursorColor: widget.cursorColor ?? themeColor,
                style: TextStyle(
                  color: widget.textColor,
                ),
                decoration: const InputDecoration(
                  labelText: 'Card Holder',
                ),
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
