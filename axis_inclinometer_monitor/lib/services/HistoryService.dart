import 'package:flutter/material.dart';
import 'package:axis_inclinometer_monitor/objects/History.dart';

class HistoryService {

  HistoryService();

  List<Widget> _historyList = [];
  List<History> _histories = [];

  List<Widget> getHistoryList() {
    // TODO Get list of available history entries
    _historyList.clear();
    _histories.clear();
    for(int counter=0; counter<3; counter++) {
      _histories.add(new History(productName: 'Axis Inclinometer', uuid: '00:AA:F0:33:FF:9B', dateTimeRange: '2021-08-03 09:15:24 - 2021-08-03 13:39:07 (4hr 17min)'));
    }
    for(int counter=0; counter<_histories.length; counter++) {
      History history = _histories[counter];
      _historyList.add(
        InkWell(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[300],
              border: Border.all(
                width: 1,
                color: Colors.black38,
              ),
              //color: Colors.teal,
            ),
            margin: EdgeInsets.fromLTRB(0, 10, 1, 10),
            height: 50,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                  child: Icon(Icons.aod, size: 48),
                ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(history.productName),
                    Text(history.uuid, style: TextStyle(fontSize: 11)),
                    Text(history.dateTimeRange, style: TextStyle(fontSize: 9)),
                  ],
                ),
              ],
            ),
          ),
          onTap: () {
            print('Tapped on $history.uuid');
          },
        ),
      );
    }
    return _historyList;
  }

}