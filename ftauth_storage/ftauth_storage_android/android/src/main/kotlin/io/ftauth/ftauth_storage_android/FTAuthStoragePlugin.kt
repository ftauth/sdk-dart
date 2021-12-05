package io.ftauth.ftauth_storage_android

import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin


class FTAuthStoragePlugin : FlutterPlugin, GeneratedBindings.NativeStorage {
    private lateinit var context: Context
    private lateinit var keyStore: KeyStore

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        GeneratedBindings.NativeStorage.setup(flutterPluginBinding.binaryMessenger, this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {}

    override fun clear() {
        keyStore.clear()
    }

    override fun delete(key: String?) {
        keyStore.delete(key)
    }

    override fun getString(key: String?): String {
        return keyStore.get(key)
    }

    override fun init() {
        keyStore = KeyStore(context)
    }

    override fun setString(key: String?, value: String?) {
        keyStore.save(key, value)
    }
}
