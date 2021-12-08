package io.ftauth.ftauth_flutter_android

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.annotation.NonNull
import io.flutter.Log
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry
import net.openid.appauth.AuthorizationRequest
import net.openid.appauth.AuthorizationService
import net.openid.appauth.AuthorizationServiceConfiguration

class FTAuthFlutterPlugin : FlutterPlugin, ActivityAware, GeneratedBindings.NativeLogin,
    PluginRegistry.ActivityResultListener,
    PluginRegistry.NewIntentListener {
    private lateinit var context: Context
    private lateinit var mainActivity: Activity
    private lateinit var channel: MethodChannel
    private lateinit var authorizationService: AuthorizationService
    private var result: GeneratedBindings.Result<MutableMap<String, String>>? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        GeneratedBindings.NativeLogin.setup(flutterPluginBinding.binaryMessenger, this)
        context = flutterPluginBinding.applicationContext
        authorizationService = AuthorizationService(context)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        mainActivity = binding.activity
        binding.addActivityResultListener(this)
        binding.addOnNewIntentListener(this)
    }

    override fun onDetachedFromActivityForConfigChanges() {}

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {}

    override fun onDetachedFromActivity() {}

    override fun login(
        config: GeneratedBindings.ClientConfiguration?,
        result: GeneratedBindings.Result<MutableMap<String, String>>?
    ) {
        val serviceConfiguration = AuthorizationServiceConfiguration(
            Uri.parse(config!!.authorizationEndpoint!!),
            Uri.parse(config.tokenEndpoint!!),
        )
        val request = AuthorizationRequest.Builder(
            serviceConfiguration,
            config.clientId!!,
            "code",
            Uri.parse(config.redirectUri!!),
        )
            .setScopes(config.scopes)
            .setState(config.state)
            .setCodeVerifier(config.codeVerifier)
            .build()
        val requestIntent = authorizationService.getAuthorizationRequestIntent(request)
        mainActivity.startActivityForResult(requestIntent, 100)
        this.result = result!!
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        Log.i("ActivityListener", "onActivityResult: $requestCode, $resultCode, $data")
        return false
    }

    override fun onNewIntent(intent: Intent?): Boolean {
        Log.i("ActivityListener", "onNewIntent: $intent")
        return false
    }
}