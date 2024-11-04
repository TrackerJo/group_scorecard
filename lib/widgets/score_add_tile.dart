import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:group_scorecard/widgets/widgets.dart';

class ScoreAddTile extends StatefulWidget {
  final int scoreToAdd;
  final Function(int) changeScore;

  const ScoreAddTile(
      {super.key, required this.scoreToAdd, required this.changeScore});

  @override
  State<ScoreAddTile> createState() => _ScoreAddTileState();
}

class _ScoreAddTileState extends State<ScoreAddTile> {
  TextEditingController scoreToAddController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    scoreToAddController.text = widget.scoreToAdd.toString();
    return Container(
      // padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () {
              setState(() {
                widget.changeScore(widget.scoreToAdd + 1);
                scoreToAddController.text = widget.scoreToAdd.toString();
                FocusScope.of(context).unfocus();
              });
            },
            child: Text(
              "+",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
          SizedBox(
            width: 25,
            height: 25,
            child: TextFormField(
              controller: scoreToAddController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                setState(() {
                  if (value == "") {
                    value = "0";
                  }
                  widget.changeScore(int.parse(value));
                });
              },
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: (widget.scoreToAdd > 99 || widget.scoreToAdd < -9)
                    ? 10
                    : 15,
              ),
              // decoration: textInputDecoration.copyWith(
              //     contentPadding: const EdgeInsets.symmetric(horizontal: 10),
              //     border: OutlineInputBorder(
              //       borderRadius: BorderRadius.circular(5),
              //     )),
            ),
          ),
          GestureDetector(
            onTap: () {
              setState(() {
                widget.changeScore(widget.scoreToAdd - 1);
                scoreToAddController.text = widget.scoreToAdd.toString();
                //Unselect the text field
                FocusScope.of(context).unfocus();
              });
            },
            child: Text(
              "-",
              style: const TextStyle(
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
