import 'package:flutter_branch_sdk/flutter_branch_sdk.dart';

class Branch_Functions{
  BranchLinkProperties lp;
  Branch_Functions(){
    initializeDeepLinkData();
  }
  // BranchUniversalObject buo = BranchUniversalObject(
  //   canonicalIdentifier: 'flutter/branch',
  //   //canonicalUrl: '',
  //   title: 'Flutter Branch Plugin',
  //   imageUrl: 'https://firebasestorage.googleapis.com/v0/b/k-mobile-wallpaper-ab563.appspot.com/o/Cars%26Bikes%2Fcarsndbikes%20(1).jpg?alt=media&token=810c8bfb-6ce3-4002-9305-968cc86c72e1',
  //   contentDescription: 'Flutter Branch Description',
  //   keywords: ['Plugin', 'Branch', 'Flutter'],
  //   publiclyIndex: true,
  //   locallyIndex: true,
  //   contentMetadata: BranchContentMetaData()..addCustomMetadata('custom_string', 'abc')
  //     ..addCustomMetadata('custom_number', 12345)
  //     ..addCustomMetadata('custom_bool', true)
  //     ..addCustomMetadata('custom_list_number', [1,2,3,4,5 ])
  //     ..addCustomMetadata('custom_list_string', ['a', 'b', 'c']),
  // );

  //To Generate Deep Link For Branch Io
  Future<BranchResponse> generateDeepLink(String bookieUID, String bookieEmail,String cost, String rideID) async {
    BranchUniversalObject buo = BranchUniversalObject(
      canonicalIdentifier: 'flutter/branch/UBER_APP',
      //canonicalUrl: '',
      title: 'Flutter Branch UBER',
      // imageUrl: 'https://firebasestorage.googleapis.com/v0/b/k-mobile-wallpaper-ab563.appspot.com/o/Cars%26Bikes%2Fcarsndbikes%20(1).jpg?alt=media&token=810c8bfb-6ce3-4002-9305-968cc86c72e1',
      contentDescription: 'Flutter Branch Description',
      keywords: ['Plugin', 'Branch', 'Flutter'],
      publiclyIndex: true,
      locallyIndex: true,
      contentMetadata: BranchContentMetaData()..addCustomMetadata('rideID',rideID )
        ..addCustomMetadata('bookieUID', bookieUID)
        ..addCustomMetadata('bookieEmail',bookieEmail)
        // ..addCustomMetadata('custom_list_number', [1,2,3,4,5 ])
        // ..addCustomMetadata('custom_list_string', ['a', 'b', 'c']),
    );
    FlutterBranchSdk.registerView(buo: buo);

    BranchResponse response =
    await FlutterBranchSdk.getShortUrl(buo: buo, linkProperties: lp);
    return response;

  }

  void initializeDeepLinkData() {

    lp = BranchLinkProperties(channel: 'GMAIL');

    lp.addControlParam("android_url", 'https://play.google.com/store/apps/details?id=com.vsp.best_mobile_images');

  }




}