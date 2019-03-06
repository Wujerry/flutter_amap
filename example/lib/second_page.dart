import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_amap/flutter_amap.dart';

class SecondPage extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    return _SecondPage();
  }

}

class _SecondPage extends State<SecondPage>{
  Key _key0;
  @override
  void initState() {
    _key0 = AMapView.createKey(_key0);
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(

      appBar:  AppBar(


      ),
      body: new AMapView(
          key:_key0,
          centerCoordinate:  LatLng(39.9242, 116.3979),
          zoomLevel: 13.0,
          mapType: MapType.standard,
          showsUserLocation: true,
          onPoiResult: (r){
            print('poipoipoipoipoi');
            print(r);
          },
        onGeoFenceChange: (status){
            if(status == 1){
              print('ininininininininininininininin');
            }else if (status == 2){
              print('outoutoutoutoutoutoutoutoutoutoutoutoutout');
            }else if(status == 3){
              print('staystaystaystaystaystaystaystay');
            }else if(status == 4){
              print('定位失败');
            }
          print('ggggggg' + status.toString());
        },
        onCameraChange: (Location location){
                  print('hahahahahaha');
                 print('cccccccccccc' + location.toString());
                   AMapView.poiSearch(LatLng(location.latitude, location.longitude), '', _key0);
                },
        geoFence: GeoFenceSetting(latLng: LatLng(39.66448, 106.4968),
            radius: 100,
            key: _key0.toString()
        ),
      ),

    );
  }

}