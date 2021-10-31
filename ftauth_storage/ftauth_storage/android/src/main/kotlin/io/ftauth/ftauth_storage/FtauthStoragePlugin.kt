package io.ftauth.ftauth_storage

import android.content.Context
import androidx.annotation.NonNull

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.ftauth.ftauth_storage.keystore.*

/** FtauthStoragePlugin */
class FtauthStoragePlugin: FlutterPlugin, MethodCallHandler {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context

  private var keystore: KeyStore? = null

  private val isInitialized: Boolean
    get() = keystore != null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "io.ftauth.ftauth_storage")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }

  private fun handleKeystoreError(result: Result, e: Exception) {
    if (e is KeyStoreException) {
      result.error(e.code.code, e.details, null)
    } else {
      result.error(KeyStoreExceptionCode.UNKNOWN.code, e.message, null)
    }
  }

  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
    if (call.method == "storageInit") {
      keystore = keystore ?: KeyStore(context)
      result.success(null)
      return
    }
    if (!isInitialized) {
      result.error(
        "UNKNOWN",
        "Must call \"storageInit\" before accessing methods",
        null
      )
      return
    }
    when (call.method) {
      "storageGet" -> {
        try {
          val key = call.arguments as? String
          val value = keystore!!.get(key)
          result.success(value)
        } catch(e: Exception) {
          handleKeystoreError(result, e)
        }
      }
      "storageSet" -> {
        try {
          val map = (call.arguments as? Map<*, *> ?: emptyMap<String, Any?>()) as Map<String, Any?>
          val key: String? by map
          val value: String? by map
          keystore!!.save(key, value?.toByteArray(Charsets.UTF_8))
          result.success(null)
        } catch(e: Exception) {
          handleKeystoreError(result, e)
        }
      }
      "storageDelete" -> {
        try {
          val key = call.arguments as? String
          keystore!!.delete(key)
          result.success(null)
        } catch(e: Exception) {
          handleKeystoreError(result, e)
        }
      }
      "storageClear" -> {
        try {
          keystore!!.clear()
          result.success(null)
        } catch(e: Exception) {
          handleKeystoreError(result, e)
        }
      }
    }
  }

  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
