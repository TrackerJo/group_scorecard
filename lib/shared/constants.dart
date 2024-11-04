import 'package:flutter/material.dart';

class Constants {
  static List<Map<String, String>> gameTypes = [
    {"id": "outdoor", "value": "Outdoor"},
    {"id": "cards", "value": "Cards"}
  ];

  static Map<String, String> gameTypesMap = {
    "outdoor": "Outdoor",
    "cards": "Cards"
  };

  static Map<String, String> gameIdMap = {
    "spp": "Singles Ping Pong",
    "dpp": "Doubles Ping Pong",
    "cornhole": "Cornhole",
    "cribbage": "Cribbage",
    "euchre": "Euchre",
    "ohhell": "Oh Hell"
  };
}
