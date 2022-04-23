package com.uber.hacktag.uber_hacktag_group_booking

import android.net.Uri
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant


//import androidx.appcompat.app.AppCompatActivity
class ShowMap : FlutterActivity() {

    override fun getInitialRoute(): String? {
//            String action = getIntent().getAction();
//        print("from SHOWMAP printing in getInititalroute+ ")
        // Initial route depends on intent's action
//            if (action != null && action.equals("example_action")) {
        return "some_route";
//            } else {
//                return "another_route";
//            }


        return super.getInitialRoute()

    }

    //    fun createFlutterView(context: Context?): FlutterView? {
//        print("from SHOWMAP printing")
//
//        val matchParent: ActionBar.LayoutParams = ActionBar.LayoutParams(-1, -1)
//    val nativeView: FlutterNativeView = this.createFlutterView(context)!!.flutterNativeView
//    val flutterView = FlutterView(this, null as AttributeSet?, nativeView)
//    flutterView.setInitialRoute("/dashboard")
//    flutterView.layoutParams = matchParent
//    this.setContentView(flutterView)
//    return flutterView
//}
    private val CHANNEL: String = "Sample/test"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
//        val intent: Intent = getIntent()
//        val action: String? = intent.getAction()
//        val type: String? = intent.getType()
        print("from SHOWMAP printing kt" + initialRoute.toString() + '\n')
        print("from SHOWMAP printing kt" + getDartEntrypointFunctionName().toString()+ '\n')
        val data: Uri? = this.intent.data
        print("from SHOWMAP printing kt" + data+ '\n')
//        channel = MethodChannel(getFlutterView(), "myChannel")

        val mc = MethodChannel(
            flutterEngine!!.dartExecutor.binaryMessenger,
            "Sample/test"
        )
        mc.setMethodCallHandler { methodCall: MethodCall, result: MethodChannel.Result ->
            if (methodCall.method == "test") {
//                methodCall.argument("data")
                result.success(
                    data.toString()  + methodCall.argument("data")
                )
//Accessing data sent from flutter
            } else {
                print("from SHOWMAP printing New method came" + methodCall.method.toString())
            }
        }
//    val engine: FlutterEngine? = getFlutterEngine()
//    engine!!.navigationChannel.pushRoute("/dashboard")

//        public String getInitialRoute() {
//            String action = getIntent().getAction();
//
//            // Initial route depends on intent's action
//            if (action != null && action.equals("example_action")) {
//                return "some_route";
//            } else {
//                return "another_route";
//            }
//        }
//        val mListener: FlutterView.FirstFrameListener = object : FlutterView.FirstFrameListener {
//            override fun onFirstFrame() {
//                getFlutterView().pushRoute("/alarm")
//            }
//        }
//
//        getFlutterView().addFirstFrameListener(mListener)
//        startActivity(
//            FlutterActivity
//                .withCachedEngine("my_engine_id")
//                .backgroundMode(FlutterActivityLaunchConfigs.BackgroundMode.transparent)
//                .build(context)
//        );
//        withNewEngine()
//            .initialRoute("/my_route")
//            .build(this);


        //        Log.d("TAG", "from SHOWMAP")

//        if (Intent.ACTION_SEND == action && type != null) {
//            if ("text/plain" == type) {
//
//            }
//        }
    }

    override fun getDartEntrypointFunctionName(): String {

        return "anotherMain"
    }
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        GeneratedPluginRegistrant.registerWith(flutterEngine)

    }
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine) //missing this
//
//    }
//    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
//        super.configureFlutterEngine(flutterEngine!!)
//    }
//
//lateinit var flutterEngine : FlutterEngine
//    override fun onCreate() {
//        super.onCreate()
//        // Instantiate a FlutterEngine.
//        print("from SHOWMAP printing start")
//        flutterEngine = FlutterEngine(this)
//        // Configure an initial route.
//        flutterEngine.navigationChannel.setInitialRoute("your/route/here");
//        // Start executing Dart code to pre-warm the FlutterEngine.
//        flutterEngine.dartExecutor.executeDartEntrypoint(
//            DartExecutor.DartEntrypoint.createDefault()
//        )
//        print("from SHOWMAP printing end")
//        // Cache the FlutterEngine to be used by FlutterActivity or FlutterFragment.
//        FlutterEngineCache
//            .getInstance()
//            .put("my_engine_id", flutterEngine)
//    }
}
