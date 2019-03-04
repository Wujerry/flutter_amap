import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_amap/flutter_amap.dart';
import 'package:flutter_amap_example/second_page.dart';

void main(){
  FlutterAmap.setApiKey("119245a2f777ece25b8aaf89421e6f24");
  runApp( MaterialApp(
    home:  MyApp(),
    navigatorObservers: [new AMapNavigatorObserver()],
  ));
}

class AMapNavigatorObserver extends NavigatorObserver{

  @override
  void didPop(Route route, Route previousRoute) {
    //这个时候需要感知route下的widget

    MaterialPageRoute pageRoute = route;

    VoidCallback listener = null;

    listener = ( ( AnimationController controller ){
      return (){
        //原生的也进行同样的动画，或者直接设置位置

        if(controller.value==0.0){
          controller.removeListener(listener);
          listener = null;
        }

      };
    })(pageRoute.controller);

    pageRoute.controller.addListener( listener );


    super.didPop(route, previousRoute);
  }

  void _onAnimation(){

  }

}


class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() =>  _MyAppState();
}


class _MyAppState extends State<MyApp> {


  Location first;
  Location second;

  Key _key0;
  Key _key1;

  bool _showFirst = true;

  @override
  initState() {
    _key0 = AMapView.createKey(_key0);
    _key1 = AMapView.createKey(_key1);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return   Scaffold(
      appBar:  AppBar(
        title:  Text('Plugin example app'),
        actions: <Widget>[
           RaisedButton(onPressed: (){
            Navigator.of(context).push( AMapRouter(
                keys: [_key0,_key1],
                builder: (context){
              return SecondPage();

            }));

          },child:  Text("Next"),)
        ],
      ),
      body:  Container(
//         child:  Column(

//           children: <Widget>[
//              SizedBox(
//               height: 50.0,
//               child:  Text("第一个地图: $first"),
//             ), SizedBox(
//               height: 50.0,
//               child:  Text("第二个地图: $second" ),
//             ),
//              RaisedButton(onPressed: (){
//                 _showFirst = ! _showFirst;
//                 setState(() {

//                 });
//             },child:  Text("测试移除第一个"),),
//             _showFirst ?  Expanded(child:
//             AMapView(
//                 key: _key0,
//                 onLocationChange: (Location location){
//                   setState(() {
//                     first = location;
//                   });
//                 },
//                 locateOnce: true,
// //                centerCoordinate:  LatLng(60.9242, 116.3979),
//                 zoomLevel: 13.0,
//                 mapType: MapType.standard,
//                 showsUserLocation: true
//             )):Container(),
//              Expanded(child:
//             AMapView(
//                 onLocationChange: (Location location){
//                  print('lllllllllll'+location.toString());
//                 },
//                 onCameraChange: (Location location){
//                   print('hahahahahaha');
//                  print('cccccccccccc' + location.toString());
//                   // AMapView.poiSearch(LatLng(location.latitude, location.longitude), '', _key0);
//                 },
//                 onPoiResult: (r){
//                  print(r);
//                 },
//                 onGeoFenceChange: (status){
//                  print('ggggggg' + status.toString());
//                 },
//                 key:_key1,
//                 // geoFence: GeoFenceSetting(latLng: LatLng(39.9242, 116.3979),
//                 //   radius: 100,
//                 //   key: _key1.toString()
//                 // ),
//                 // centerCoordinate:  LatLng(39.9242, 116.3979),
//                 zoomLevel: 13.0,
//                 mapType: MapType.standard,
//                 showsUserLocation: true
//             )),
//           ],
//         ),
      ),
    );
  }

/*
  void show(){
    amap.show(
        mapview:  AMapView(
            centerCoordinate:  LatLng(39.9242, 116.3979),
            zoomLevel: 13.0,
            mapType: MapType.night,
            showsUserLocation: true),
        title:  TitleOptions(title: "我的地图"));
    amap.onLocationUpdated.listen((Location location){

      print("Location changed $location") ;

    });
  }*/
}
