package com.jzoom.flutteramap;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.location.Location;
import android.net.ConnectivityManager;
import android.os.Bundle;

import com.amap.api.fence.GeoFence;
import com.amap.api.fence.GeoFenceClient;
import com.amap.api.fence.GeoFenceListener;
import com.amap.api.location.DPoint;
import com.amap.api.maps.AMap;
import com.amap.api.maps.CameraUpdateFactory;
import com.amap.api.maps.UiSettings;
import com.amap.api.maps.model.CameraPosition;
import com.amap.api.maps.model.LatLng;
import com.amap.api.maps.model.MyLocationStyle;
import com.amap.api.services.core.LatLonPoint;
import com.amap.api.services.core.PoiItem;
import com.amap.api.services.poisearch.PoiResult;
import com.amap.api.services.poisearch.PoiSearch;


import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.plugin.common.MethodChannel;

import static com.amap.api.fence.GeoFenceClient.GEOFENCE_IN;
import static com.amap.api.fence.GeoFenceClient.GEOFENCE_OUT;
import static com.amap.api.fence.GeoFenceClient.GEOFENCE_STAYED;

public class AMapViewManager {


    private MethodChannel channel;
    Map<String, Object> mapViewOptions;


    public AMapViewManager(MethodChannel channel) {
        this.channel = channel;
    }

    //定义接收广播的action字符串
    public static final String GEOFENCE_BROADCAST_ACTION = "com.jzoom.flutteramap.broadcast";

    //无用
    public AMapView createView(Context context) {
        final AMapView view = new AMapView(context);
        view.getMap().setOnMyLocationChangeListener(new AMap.OnMyLocationChangeListener() {
            @Override
            public void onMyLocationChange(Location location) {
                Map<String, Object> map = new HashMap<String, Object>();
                map.put("latitude", location.getLatitude());
                map.put("longitude", location.getLongitude());
                map.put("accuracy", location.getAccuracy());
                map.put("altitude", location.getAltitude());
                map.put("speed", location.getSpeed());
                map.put("timestamp", (double) location.getTime() / 1000);
                map.put("id", view.getKey());
                channel.invokeMethod("locationUpdate", map);
            }
        });
        view.getMap().setOnCameraChangeListener(new AMap.OnCameraChangeListener() {
            @Override
            public void onCameraChange(CameraPosition cameraPosition) {

            }

            @Override
            public void onCameraChangeFinish(CameraPosition cameraPosition) {
                Map<String, Object> map = new HashMap<String, Object>();
                map.put("latitude", cameraPosition.target.latitude);
                map.put("longitude", cameraPosition.target.longitude);
                map.put("id", view.getKey());
                channel.invokeMethod("cameraUpdate", map);
            }
        });
        return view;
    }

    public void bindEvents(final AMapView view) {
        view.getMap().setOnMyLocationChangeListener(new AMap.OnMyLocationChangeListener() {
            @Override
            public void onMyLocationChange(Location location) {
                Map<String, Object> map = new HashMap<String, Object>();
                map.put("latitude", location.getLatitude());
                map.put("longitude", location.getLongitude());
                map.put("accuracy", location.getAccuracy());
                map.put("altitude", location.getAltitude());
                map.put("speed", location.getSpeed());
                map.put("timestamp", (double) location.getTime() / 1000);
                map.put("id", view.getKey());
                channel.invokeMethod("locationUpdate", map);
            }
        });
        view.getMap().setOnCameraChangeListener(new AMap.OnCameraChangeListener() {
            @Override
            public void onCameraChange(CameraPosition cameraPosition) {

            }

            @Override
            public void onCameraChangeFinish(CameraPosition cameraPosition) {
                Map<String, Object> map = new HashMap<String, Object>();
                map.put("latitude", cameraPosition.target.latitude);
                map.put("longitude", cameraPosition.target.longitude);
                map.put("id", view.getKey());
                channel.invokeMethod("cameraUpdate", map);
            }
        });
    }

    public void poiSearch(double lat, double lng, final AMapView view, String keyword) {
        PoiSearch.Query query = new PoiSearch.Query(keyword, "", "");
        query.setPageSize(10);
        PoiSearch poiSearch = new PoiSearch(view.getContext(), query);
        poiSearch.setBound(new PoiSearch.SearchBound(new LatLonPoint(lat,
                lng), 1000));//设置周边搜索的中心点以及半径
        poiSearch.setOnPoiSearchListener(new PoiSearch.OnPoiSearchListener() {

            @Override
            public void onPoiSearched(PoiResult poiResult, int i) {
                ArrayList<PoiItem> r = poiResult.getPois();
                ArrayList<Map<String, String>> list = new ArrayList<>();


                for(int j = 0; j < r.size(); j++){
                    PoiItem item = r.get(j);
                    Map<String, String> m = new HashMap<>();
                    m.put("title", item.getTitle());
                    m.put("lat", String.valueOf(item.getLatLonPoint().getLatitude()));
                    m.put("lng", String.valueOf(item.getLatLonPoint().getLongitude()));
                    m.put("address", item.getSnippet());
                    list.add(m);
                }
                Map<String, Object> map = new HashMap<>();
                map.put("id", view.getKey());
                map.put("list", list);

                channel.invokeMethod("poiResult", map);
            }

            @Override
            public void onPoiItemSearched(PoiItem poiItem, int i) {

            }
        });
        poiSearch.searchPOIAsyn();
    }

    public void moveCamera(AMapView view, double lat, double lng){
        view.getMap().moveCamera(CameraUpdateFactory.changeLatLng(new LatLng(lat, lng)));
    }

    public void updateProps(AMapView view, Map<String, Object> mapView) {

        AMap aMap = view.getMap();

        aMap.setMapType((Integer) mapView.get("mapType"));

        aMap.moveCamera(CameraUpdateFactory.zoomTo((float) (double) (Double) mapView.get("zoomLevel")));
        aMap.setMaxZoomLevel((float) (double) (Double) mapView.get("maxZoomLevel"));
        aMap.setMinZoomLevel((float) (double) (Double) mapView.get("minZoomLevel"));

        //定位按钮
        UiSettings mUiSettings = aMap.getUiSettings();//实例化UiSettings类对象
        mUiSettings.setMyLocationButtonEnabled((Boolean) mapView.get("showsUserLocation")); //显示默认的定位按钮
        aMap.setMyLocationEnabled((Boolean) mapView.get("showsUserLocation"));

        //定位蓝点
        MyLocationStyle myLocationStyle;
        myLocationStyle = new MyLocationStyle();
        if ((Boolean) mapView.get("locateOnce")) {
            myLocationStyle.myLocationType(MyLocationStyle.LOCATION_TYPE_LOCATE);
        }
        aMap.setMyLocationStyle(myLocationStyle);

        //中心
        Map<String, Object> centerCoordinate = (Map<String, Object>) mapView.get("centerCoordinate");
        if (centerCoordinate != null) {
            aMap.moveCamera(CameraUpdateFactory.changeLatLng(new LatLng(
                    (Double) centerCoordinate.get("latitude"),
                    (Double) centerCoordinate.get("longitude"))));
        }

        //地理围栏
        Map<String, Object> geoFence = (Map<String, Object>) mapView.get("geoFence");
        if(geoFence != null){
            GeoFenceClient mGeoFenceClient = new GeoFenceClient(view.getContext());
            double lat = (Double) geoFence.get("lat");
            double lng = (Double) geoFence.get("lng");
            double radius = (Double) geoFence.get("radius");
            mGeoFenceClient.setActivateAction(GEOFENCE_IN|GEOFENCE_OUT|GEOFENCE_STAYED);
            mGeoFenceClient.addGeoFence(new DPoint(lat,lng), (float) radius, (String) geoFence.get("customID"));
            //创建回调监听
            GeoFenceListener fenceListenter = new GeoFenceListener() {

                @Override
                public void onGeoFenceCreateFinished(List<GeoFence> list, int i, String s) {
                    if(i == GeoFence.ADDGEOFENCE_SUCCESS){//判断围栏是否创建成功
//                        tvReult.setText("添加围栏成功!!");
                        //geoFenceList是已经添加的围栏列表，可据此查看创建的围栏
                    } else {
//                        tvReult.setText("添加围栏失败!!");
                    }
                }
            };
            mGeoFenceClient.setGeoFenceListener(fenceListenter);
            //创建并设置PendingIntent
            mGeoFenceClient.createPendingIntent(GEOFENCE_BROADCAST_ACTION);
            IntentFilter filter = new IntentFilter(
                    ConnectivityManager.CONNECTIVITY_ACTION);
            filter.addAction(GEOFENCE_BROADCAST_ACTION);
            view.getContext().registerReceiver(mGeoFenceReceiver, filter);
        }



    }

    private BroadcastReceiver mGeoFenceReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction().equals(GEOFENCE_BROADCAST_ACTION)) {
                //解析广播内容
                Bundle bundle = intent.getExtras();
                int status = bundle.getInt(GeoFence.BUNDLE_KEY_FENCESTATUS);
                //获取自定义的围栏标识：
                String customId = bundle.getString(GeoFence.BUNDLE_KEY_CUSTOMID);
                Map<String, Object> map = new HashMap<String, Object>();
                map.put("status", status);
                map.put("id", customId);
                channel.invokeMethod("geoFenceChange", map);
            }
        }
    };


}

