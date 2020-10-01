package net.awesometechno.khadoandsons


import androidx.annotation.NonNull
import net.awesometechno.khadoandsons.epub_kitty.EpubKittyPlugin
//import com.iqonic.KhadoAndSons.braintree.BrainTreePaymentPlugin
import net.awesometechno.khadoandsons.paytm.PaytmPlugin
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugins.GeneratedPluginRegistrant


class MainActivity : FlutterActivity(){

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        GeneratedPluginRegistrant.registerWith(flutterEngine)
        PaytmPlugin.registerWith(this, flutterEngine);
        EpubKittyPlugin.registerWith(this, flutterEngine);
//        BrainTreePaymentPlugin.registerWith(this, flutterEngine);

    }


}
