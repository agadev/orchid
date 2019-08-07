import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:orchid/api/analysis_db.dart';

import '../app_colors.dart';
import '../app_text.dart';

class TrafficView extends StatefulWidget {
  @override
  _TrafficViewState createState() => _TrafficViewState();
}

class _TrafficViewState extends State<TrafficView> {
  var _searchview = TextEditingController();
  String _query = "";
  List<FlowEntry> _resultList;
  Timer _pollTimer;

  @override
  void initState() {
    super.initState();

    // Update on search text
    _searchview.addListener(() {
      _query = _searchview.text.isEmpty ? "" : _searchview.text;
      _performQuery();
    });

    // Update periodically
    _pollTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _performQuery();
    });

    // Update first view
    _performQuery();

    AnalysisDb().update.listen((_) {
      _performQuery();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[_buildSearchView(), _buildResultListView()],
    );
  }

  Widget _buildSearchView() {
    return Container(
      padding: EdgeInsets.only(left: 8.0),
      //decoration: BoxDecoration(border: Border.all(width: 1.0)),
      child: TextField(
        controller: _searchview,
        decoration: InputDecoration(
          hintText: "Search",
          hintStyle: TextStyle(color: AppColors.neutral_5),
        ),
        textAlign: TextAlign.left,
      ),
    );
  }

  Future<void> _performQuery() async {
    Completer<void> completer = Completer();
    AnalysisDb().query(textFilter: _query).then((results) {
      //print("got rows: ${results.length}");
      setState(() {
        _resultList = results;
      });
      completer.complete();
    });
    return completer.future;
  }

  Widget _buildResultListView() {
    return Flexible(
      child: RefreshIndicator(
        onRefresh: () {
          return _performQuery();
        },
        child: ListView.builder(
            itemCount: _resultList?.length ?? 0,
            itemBuilder: (BuildContext context, int index) {
              var item = _resultList[index];
              var hostname = (item.hostname == null || item.hostname.isEmpty)
                  ? item.dst_addr
                  : item.hostname;
              var date = DateFormat.yMd().add_jm().format(item.start.toLocal());
              var protStyle = AppText.logStyle.copyWith(fontSize: 12.0);
              return Card(
                  color: Colors.white,
                  elevation: 1.0,
                  // additional margin outside each card
                  margin: EdgeInsets.symmetric(horizontal: 0.0, vertical: 4.0),
                  child: Theme(
                    data: ThemeData(accentColor: AppColors.purple_3),
                    child: ExpansionTile(
                      key: PageStorageKey<int>(item.rowId), // unique key
                      leading: Icon(
                        Icons.check_circle_outline,
                        color: AppColors.purple,
                      ),
                      title: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Expanded(
                                flex: 10,
                                child: Text("$hostname",
                                    overflow: TextOverflow.ellipsis,
                                    style: AppText.textLabelStyle
                                        .copyWith(fontWeight: FontWeight.bold)),
                              ),
                              Spacer(),
                              Text("${item.protocol}",
                                  style: AppText.textLabelStyle.copyWith(
                                      fontSize: 14.0,
                                      color: AppColors.neutral_3)),
                              SizedBox(width: 8)
                            ],
                          ),
                          SizedBox(height: 4),
                          Text("$date",
                              style: AppText.logStyle.copyWith(fontSize: 12.0)),
                        ],
                      ),
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(
                              left: 73, top: 4.0, bottom: 16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Text('Source Addr: ${item.src_addr}',
                                  style: protStyle),
                              SizedBox(height: 2),
                              Text('Source Port : ${item.src_port}',
                                  style: protStyle),
                              SizedBox(height: 2),
                              Text('Dest Addr: ${item.dst_addr}',
                                  style: protStyle),
                              SizedBox(height: 2),
                              Text('Dest Port: ${item.dst_port}',
                                  style: protStyle),
                            ],
                          ),
                        )
                      ],
                    ),
                  ));
            }),
      ),
    );
  }

  // Currently unused
  void dispose() {
    super.dispose();
    _pollTimer.cancel();
  }
}