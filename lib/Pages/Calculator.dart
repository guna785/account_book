import 'dart:math';

import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../app_localisation.dart';

String monthlyInstallment = "", interestPayable = "", totalAmountPayable = "";

class Calculator extends StatefulWidget {
  @override
  _CalculatorState createState() => _CalculatorState();
}

class _CalculatorState extends State<Calculator> {
  TextEditingController principleController = TextEditingController();
  TextEditingController rateController = TextEditingController();
  TextEditingController durationController = TextEditingController();
  bool isValidated = false;

  ShapeBorder _defaultShape() {
    return RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
      side: BorderSide(
        color: Colors.deepOrange,
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      monthlyInstallment = "";
      interestPayable = "";
      totalAmountPayable = "";
    });
  }

  @override
  Widget build(BuildContext context) {
    final _form = GlobalKey<FormState>();
    return SingleChildScrollView(
        child: Container(
      padding: const EdgeInsets.all(25.0),
      child: Form(
        key: _form,
        child: Column(
          children: <Widget>[
            Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                    margin:
                        EdgeInsets.only(top: 4, bottom: 0, left: 4, right: 4),
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                    child: Column(children: [
                      TextFormField(
                        controller: principleController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Principle Amount",
                          //AppLocalisation.of(this.context).getTranslationKey("incomeAddAmount"),
                          icon: Icon(MdiIcons.currencyInr),
                        ),
                        validator: (text) {
                          if (!(text.isNotEmpty)) {
                            return AppLocalisation.of(this.context)
                                .getTranslationKey("AddErrorsAmount");
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: rateController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Rate per year",
                          //AppLocalisation.of(this.context).getTranslationKey("incomeAddDetail"),
                          icon: Icon(MdiIcons.percent),
                        ),
                        validator: (text) {
                          if (!(text.isNotEmpty)) {
                            return AppLocalisation.of(this.context)
                                .getTranslationKey("AddErrorsDetail");
                          }
                          return null;
                        },
                      ),
                      TextFormField(
                        controller: durationController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          labelText: "Duration in Months",
                          //AppLocalisation.of(this.context).getTranslationKey("incomeAddDetail"),
                          icon: Icon(MdiIcons.timelineClock),
                        ),
                        validator: (text) {
                          if (!(text.isNotEmpty)) {
                            return AppLocalisation.of(this.context)
                                .getTranslationKey("AddErrorsDetail");
                          }
                          return null;
                        },
                      ),
                      ElevatedButton(
                          style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  Colors.deepOrange)),
                          child: Text(AppLocalisation.of(this.context)
                              .getTranslationKey("incomeAddSubmit")),
                          onPressed: () async {
                            final isValid = _form.currentState.validate();
                            if (!isValid) {
                              return;
                            }
                            var p = double.parse(principleController.text);
                            var r =
                                double.parse(rateController.text) / (12 * 100);
                            var d = int.parse(durationController.text);
                            var pf = pow(r + 1, d);
                            double emi = (p * r * pf) / (pf - 1);
                            setState(() {
                              monthlyInstallment =
                                  "\u20B9  " + (emi).toStringAsFixed(2) + "\n";
                              interestPayable = "\u20B9  " +
                                  ((emi * d) - p).toStringAsFixed(2) +
                                  "\n";
                              totalAmountPayable = "\u20B9  " +
                                  (emi * d).toStringAsFixed(2) +
                                  "\n";
                              isValidated = true;
                            });
                          })
                    ]))),
            _emi_result()
          ],
        ),
      ),
    ));
  }

  _emi_result() {
    return isValidated
        ? Container(
            margin: EdgeInsets.only(top: 4, bottom: 0, left: 4, right: 4),
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
            child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Container(
                  margin: EdgeInsets.only(top: 4, bottom: 0, left: 4, right: 4),
                  padding:
                      const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                  child: Column(
                    children: [
                      Text(
                        'EMI Amount',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$monthlyInstallment',
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent),
                      ),
                      Text(
                        'Total Interest Payable',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$interestPayable',
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent),
                      ),
                      Text(
                        'Total Amount Payable',
                        style: TextStyle(
                            fontSize: 19, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '$totalAmountPayable',
                        style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent),
                      ),
                    ],
                  ),
                )),
          )
        : Container();
  }
}
