import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import '../util/utils.dart' as util;
import 'package:http/http.dart' as http;

class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {

  String _cityEntered;

  Future _goToNextScreen(BuildContext context) async {
    Map results = await Navigator.of(context).push(
        new MaterialPageRoute (builder: (BuildContext context) {
          return new ChangeCity();
        }));
    
    if(results !=null && results.containsKey('ввод')){
      _cityEntered = results['ввод'];
      // print(results['ввод'].toString());
    }
  }

  void showStuff() async {
    Map data = await getWeather(util.appId, util.defaultCity);
    print(data.toString());
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text('Pogoda'),
        centerTitle: true,
        backgroundColor: Colors.grey,
        actions: <Widget>[
          new IconButton(
              icon: new Icon(Icons.menu),
              onPressed: () {
                _goToNextScreen(context);
              })
        ],
      ),
      body: new Stack(
        children: <Widget>[
          new Center(
            child: new Image.asset(
              'images/clear.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,
            ),
          ),
          new Container(
              alignment: Alignment.topRight,
              margin: const EdgeInsets.fromLTRB(0.0, 10.9, 20.9, 0.0),
              child: new Text(
                '${_cityEntered == null ? util.defaultCity : _cityEntered}',
                style: cityStyle(),
              )),

          new Container(
            alignment: Alignment.center,
            child: new Image.asset(
                'images/lightcloud.png',
              width: 490.0,
              height: 1200.0,
              fit: BoxFit.fill,),
          ),
          //Container data
          new Container(
            margin: const EdgeInsets.fromLTRB(30.0, 290.0, 0.0, 0.0),
            child: updateTempWidget(_cityEntered),
          )
        ],
      ),
    );
  }

  Future<Map> getWeather(String appId, String city) async {
    String apiUrl = 'http://api.openweathermap.org/data/2.5/weather?q=$city&appid='
        '${util.appId}&units=metric';

    http.Response response = await http.get(apiUrl);

    return json.decode(response.body);
  }

  Widget updateTempWidget(String city) {
    return new FutureBuilder(
        future: getWeather(util.appId, city == null ? util.defaultCity: city),
        builder: (BuildContext context, AsyncSnapshot<Map> snapshot) {
          //info get json data
          if (snapshot.hasData) {
            Map content = snapshot.data;
            return new Container(
              child: new Column(
                children: <Widget>[
                  new ListTile(
                    title: new Text(content['main'] ['temp'].toString(),
                      style: new TextStyle(
                        fontStyle: FontStyle.normal,
                        fontSize: 49.0,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),),
                  )
                ],
              ),
            );
          } else {
            return new Container();
          }
        });
  }
}


class ChangeCity extends StatelessWidget {
  var _cityFieldController = new TextEditingController();

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: new AppBar(
          backgroundColor: Colors.black,
          title: new Text('Поменять город'),
          centerTitle: true,
        ),
        body: new Stack(
          children: <Widget>[
            new ListView(
              children: <Widget>[
                new Image.asset('images/thunderstorm.png',
                  width: 490.0,
                  height: 1200.0,
                  fit: BoxFit.fill,)
              ],
            ),
            new ListView(
              children: <Widget>[
                new ListTile(
                  title: new TextField(
                    decoration: new InputDecoration(
                      hintText: 'Введите город',
                    ),
                    controller: _cityFieldController,
                    keyboardType: TextInputType.text,
                  ),
                ),
                new ListTile(
                  title: new TextButton(
                      onPressed: (){
                        Navigator.pop(context,{
                          'ввод':_cityFieldController.text
                        });
                      },
                      child: new Text('Поиск')),
                ),
              ],
            )
          ],
        )
    );
  }
}


TextStyle cityStyle() {
  return new TextStyle(
      color: Colors.white, fontSize: 22.9, fontStyle: FontStyle.italic);
}

TextStyle tempStyle() {
  return new TextStyle(
      color: Colors.white,
      fontStyle: FontStyle.normal,
      fontWeight: FontWeight.w500,
      fontSize: 49.9);
}
