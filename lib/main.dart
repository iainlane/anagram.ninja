import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'circle_text.dart';

void main() => runApp(App());

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode f = FocusScope.of(context);

        if (!f.hasPrimaryFocus && f.focusedChild != null) {
          f.focusedChild.unfocus();
        }
      },
      child: MaterialApp(
        title: 'anagram.ninja',
        home: SafeArea(
          child: AnagramNinja(),
        ),
      ),
    );
  }
}

class _AnagramNinjaState extends State<AnagramNinja> {
  final TextEditingController _controller = new TextEditingController();
  String _text;
  String _shuffledText;
  bool _textEntryVisible = true;
  FocusNode _focusNode;

  void _onFocusChange() {
    if (!_focusNode.hasPrimaryFocus) {
      _dismissTextEntry();
    }
  }

  @override
  void initState() {
    super.initState();

    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    _focusNode.dispose();

    super.dispose();
  }

  void _textChanged(String newText) {
    setState(() {
      _text = newText;
      var t = newText.toLowerCase().replaceAll(' ', '').split('');
      t.shuffle();
      _shuffledText = t.join();
    });
  }

  void _dismissTextEntry() {
    setState(() {
      if (_controller.text == null || _controller.text.trim() == "") {
        // Can't unfocus if the state is invalid
        _focusNode.requestFocus();
      } else {
        _textEntryVisible = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Scaffold(
            floatingActionButton: Visibility(
                visible: _text != null && _text != "",
                child: FloatingActionButton(
                  onPressed: () {
                    _controller.text = _text;
                    _controller.selection = TextSelection(
                        baseOffset: 0, extentOffset: _controller.text.length);
                    setState(() {
                      _textEntryVisible = true;
                    });
                    _focusNode.requestFocus();
                  },
                  child: Icon(Icons.edit),
                  backgroundColor: Colors.pink,
                )),
            body: Stack(children: [
              Container(
                child: CircleText(
                  text: _shuffledText,
                  textStyle: TextStyle(fontSize: 24, color: Colors.green[900]),
                ),
              ),
              Visibility(
                visible: _textEntryVisible,
                child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      TextField(
                        controller: _controller,
                        decoration: InputDecoration(
                            focusedBorder: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            hintText: "enter an anagram…",
                            hintStyle: TextStyle(
                              fontStyle: FontStyle.italic,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              onPressed: () => _dismissTextEntry(),
                            )),
                        focusNode: _focusNode,
                        onChanged: (newValue) => _textChanged(newValue),
                        onSubmitted: (newValue) => _dismissTextEntry(),
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 36,
                        ),
                        textAlign: TextAlign.center,
                      )
                    ]),
              ),
            ]));
      },
    );
  }
}

class AnagramNinja extends StatefulWidget {
  @override
  _AnagramNinjaState createState() => _AnagramNinjaState();
}
