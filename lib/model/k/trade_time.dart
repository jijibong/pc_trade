class TradeTime {
  /**
   * Start : 06:00:00
   * End : 05:00:00
   */

  String? Start;
  String? End;

  TradeTime({this.Start, this.End});

  TradeTime.fromJson(Map<String, dynamic> json) {
    Start = json['Start'];
    End = json['End'];
  }

  Map<String, dynamic> toJson() {
    return {
      "Start":Start,
      "End":End,
    };
  }
}
