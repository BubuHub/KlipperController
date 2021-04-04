import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:share/share.dart';
import '../globals.dart' as globals;

class LogScreen extends StatelessWidget {
  final TextEditingController __textEditingCtl = TextEditingController();
  String _response;
  Socket _s;

  void _showAlert(BuildContext context, String stext) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: Text(stext),
            ));
  }

  @override
  Widget build(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    //MediaQuery.of(context).viewInsets.bottom
    var width = screenSize.width;
    var height = screenSize.height;
    return FutureBuilder(
      future: fetchData(),
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          debugPrint('Step 3, build widget: ${snapshot.data}');
          __textEditingCtl.text = snapshot.data;
          return Scaffold(
              backgroundColor: Colors.black,
              body: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    SizedBox(width: 320, height: 40),
                    Container(
                      width: width - 40.0,
                      height: (height - 120.0),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10.0),
                        color: const Color(0xFF1E1E1E),
                      ),
                      child: SingleChildScrollView(
                        child: TextField(
                          keyboardType: TextInputType.multiline,
                          autofocus: false,
                          maxLines: null,
                          readOnly: true,
                          style: TextStyle(
                            fontFamily: 'HK Grotesk',
                            fontSize: 14.0,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            height: 1.09,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.all(10.0),
                          ),
                          controller: __textEditingCtl,
                        ),
                      ),
                    ),
                    Spacer(flex: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        InkWell(
                          onTap: () {
                            Share.share(_response, subject: 'Klipper log');
                          },
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Container(
                              alignment: Alignment(0.0, 0.02),
                              width: 120.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: Colors.blue,
                              ),
                              child: Text(
                                AppLocalizations.of(context).share,
                                style: TextStyle(
                                  fontFamily: 'HK Grotesk',
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  height: 0.97,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
// Group: Group 13
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Padding(
                            padding: EdgeInsets.all(20.0),
                            child: Container(
                              alignment: Alignment(0.0, 0.02),
                              width: 120.0,
                              height: 40.0,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10.0),
                                color: const Color(0xFFF32121),
                              ),
                              child: Text(
                                AppLocalizations.of(context).cancel,
                                style: TextStyle(
                                  fontFamily: 'HK Grotesk',
                                  fontSize: 20.0,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  height: 0.97,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ]));
        } else {
          // We can show the loading view until the data comes back.
          debugPrint('Step 1, build loading widget');
          return Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Future<String> fetchData() async {
    Completer<String> _cmp = new Completer<String>();
    print("Open connection to PI\n");
    _response = "";
    try {
      _s = await Socket.connect(globals.api_url, 55555);
      _s.listen((data) {
        _response += new String.fromCharCodes(data);
        print('(1)');
      }, onError: ((error, StackTrace trace) {
        _response = error.toString();
        print("(2) $_response");
        _cmp.complete(_response);
      }), onDone: (() {
        print("(3):Done");
        _cmp.complete(_response);
        _s.destroy();
      }), cancelOnError: false);
      _s.write("getlog\n");
      await _s.flush();
    } catch (e) {
      print("(4): Exeption $e");
      _cmp.complete(_response);
    }
    return _cmp.future;
  }
}
