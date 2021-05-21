import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_statusbarcolor_ns/flutter_statusbarcolor_ns.dart';
import 'package:lottie/lottie.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    FlutterStatusbarcolor.setStatusBarColor(Colors.transparent);
    return MaterialApp(
      title: 'Flutter Demo',
      home: MyHomePage(title: 'Conversor de moedas'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  Future<Map> _getData() async {
    const API_URL = "https://api.hgbrasil.com/finance?format=json&key=b1b2d7df";

    http.Response res = await http.get(Uri.parse(API_URL));

    return json.decode(res.body)['results']['currencies'];
  }

  @override
  Widget build(BuildContext context) {
    final realController = TextEditingController();
    final dolarController = TextEditingController();
    final euroController = TextEditingController();

    double dolar = 0;
    double euro = 0;

    void _resetFields() {
      realController.text = "";
      dolarController.text = "";
      euroController.text = "";
    }

    void _moneyChange(String prefix, String text) {
      double value = double.parse(text);

      switch (prefix) {
        case 'R\$':
          dolarController.text = (1 / dolar * value).toStringAsFixed(2);
          euroController.text = (1 / euro * value).toStringAsFixed(2);
          break;
        case 'US\$':
          realController.text = (value * dolar).toStringAsFixed(2);
          euroController.text = ((value * dolar) / euro).toStringAsFixed(2);
          break;
        case '€':
          realController.text = (value * euro).toStringAsFixed(2);
          dolarController.text = (value * euro / dolar).toStringAsFixed(2);
          break;
        default:
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${widget.title}',
          style: GoogleFonts.lato(
              textStyle: TextStyle(color: NeumorphicColors.defaultTextColor)),
        ),
        centerTitle: true,
        backgroundColor: NeumorphicColors.background,
        elevation: 0,
      ),
      backgroundColor: NeumorphicColors.background,
      body: FutureBuilder<Map>(
        future: _getData(),
        builder: (context, snapshot) {
          switch (snapshot.connectionState) {
            case ConnectionState.none:
            case ConnectionState.waiting:
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset('animations/convert_money.json', width: 150),
                    Padding(
                      padding: EdgeInsets.only(top: 20),
                      child: Text(
                        'Carregando dados',
                        style: GoogleFonts.lato(
                            textStyle: TextStyle(fontSize: 22)),
                      ),
                    ),
                  ],
                ),
              );

            default:
              if (snapshot.hasError) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Lottie.asset('animations/error.json', width: 150),
                      Padding(
                        padding: EdgeInsets.only(top: 20),
                        child: Text(
                          'Erro ao carregar dados',
                          style: GoogleFonts.roboto(
                              textStyle:
                                  TextStyle(fontSize: 18, color: Colors.red)),
                        ),
                      ),
                    ],
                  ),
                );
              } else {
                dolar = snapshot.data!['USD']['buy'];
                euro = snapshot.data!['EUR']['buy'];

                return SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Lottie.asset('animations/money.json', width: 250),
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        child: Text(
                          'Insira os valores abaixo',
                          style: GoogleFonts.lato(
                            textStyle: TextStyle(
                                color: NeumorphicColors.defaultTextColor,
                                fontSize: 16),
                          ),
                        ),
                      ),
                      buildTextField(
                          "Reais", "R\$", realController, _moneyChange),
                      buildTextField(
                          "Dólares", "US\$", dolarController, _moneyChange),
                      buildTextField(
                          "Euros", "€", euroController, _moneyChange),
                      NeumorphicButton(
                        onPressed: _resetFields,
                        child: NeumorphicIcon(
                          Icons.delete,
                          size: 50,
                          style: NeumorphicStyle(
                              color: NeumorphicColors.defaultTextColor),
                        ),
                      )
                    ],
                  ),
                );
              }
          }
        },
      ),
    );
  }
}

Widget buildTextField(
    String label, String prefix, TextEditingController tec, Function onChange) {
  return Padding(
    padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
    child: Neumorphic(
      child: TextFormField(
        onChanged: (text) {
          onChange(prefix, text);
        },
        controller: tec,
        textAlign: TextAlign.center,
        style: GoogleFonts.lato(
          textStyle: TextStyle(fontSize: 20),
        ),
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          hintText: "$label",
          contentPadding: EdgeInsets.all(16.0),
          hintStyle: GoogleFonts.lato(
            textStyle: TextStyle(color: Colors.grey),
          ),
          border: InputBorder.none,
          prefixIcon: Padding(
            padding: EdgeInsets.only(left: 10),
            child: Text(
              "$prefix",
              style: GoogleFonts.lato(
                textStyle: TextStyle(color: Colors.grey, fontSize: 18),
              ),
            ),
          ),
          prefixIconConstraints: BoxConstraints(minWidth: 0, minHeight: 0),
        ),
      ),
    ),
  );
}
