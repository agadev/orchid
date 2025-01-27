package net.orchid.Orchid

import net.orchid.Orchid.BuildConfig;

import android.os.Bundle
import android.util.Log

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import android.content.Intent;
import android.net.VpnService;
import java.io.*

class MainActivity(): FlutterActivity() {
    lateinit var feedback: MethodChannel

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        installConfig();

        feedback = MethodChannel(flutterView, "orchid.com/feedback")
        feedback.setMethodCallHandler { call, result ->
            Log.d("Orchid", call.method)
            when (call.method) {
                "group_path" -> {
                    result.success(getFilesDir().getAbsolutePath())
                    feedback.invokeMethod("providerStatus", true)
                }
                "connect" -> {
                    val intent = VpnService.prepare(this);
                    if (intent != null) {
                        startActivityForResult(intent, 0)
                    } else {
                        startService(getServiceIntent())
                        feedback.invokeMethod("connectionStatus", "Connected")
                    }
                }
                "disconnect" -> {
                    startService(getServiceIntent().setAction("disconnect"))
                    feedback.invokeMethod("connectionStatus", "Disconnected")
                }
                "reroute" -> {
                }
                "version" -> {
                    result.success("${BuildConfig.VERSION_NAME} (${BuildConfig.VERSION_CODE})")
                }
                "get_config" -> {
                    var file = configFile();
                    val text = file.readText()
                    result.success(text);
                }
                "set_config" -> {
                    Log.d("Orchid", "in set config")
                    var text: String? = call.argument<String>("text")
                    Log.d("Orchid", "arg = "+text)
                    if ( text == null ) {
                        Log.d("Orchid", "invalid argument in set_config")
                        text = "";
                    }
                    val textIn = text.byteInputStream();
                    var file = configFile();
                    copyTo(textIn, file);
                    Log.d("Orchid", "copy complete")
                    result.success("true"); // todo, validation
                }
            }
        }

        // we *could* hook feedback "connectionStatus" up to ConnectivityService:
        // NetworkAgentInfo [VPN () - 112] EVENT_NETWORK_INFO_CHANGED, going from CONNECTING to CONNECTED
        // but we'd need to make sure it's the Orchid VPN.
    }

    override fun onActivityResult(request: Int, result: Int, data: Intent?) {
        if (result == RESULT_OK) {
            startService(getServiceIntent());
            feedback.invokeMethod("connectionStatus", "Connected")
        }
    }

    private fun getServiceIntent(): Intent {
        return Intent(this, OrchidVpnService::class.java);
    }

    private fun configFile(): File {
        return File(filesDir.absolutePath + "/orchid.cfg");
    }

    // Install the default config file on first launch.
    private fun installConfig() {
        var file = configFile();
        val defaultConfig = assets.open("flutter_assets/assets/default.cfg")
        defaultConfig.use { defaultConfig ->
            if (!file.exists()) {
                Log.d("Orchid", "Installing default config file")
                copyTo(defaultConfig, file);
            }
        }
    }

    fun copyTo(ins: InputStream, dst: File) {
        ins.use { ins ->
            val out = FileOutputStream(dst)
            out.use { out ->
                // Transfer bytes from in to out
                val buf = ByteArray(4096)
                var len: Int = 0
                while ({ len = ins.read(buf); len }() > 0) {
                    out.write(buf, 0, len)
                }
            }
        }
    }
}
