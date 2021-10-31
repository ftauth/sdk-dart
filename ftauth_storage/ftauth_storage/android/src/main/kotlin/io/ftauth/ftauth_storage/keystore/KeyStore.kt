package io.ftauth.ftauth_storage.keystore

import android.content.Context
import android.content.SharedPreferences
import android.security.keystore.KeyProperties
import android.security.keystore.KeyProtection
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKey
import io.flutter.Log
import java.security.KeyStore
import javax.crypto.spec.SecretKeySpec

enum class KeyStoreExceptionCode(val code: String) {
    ACCESS("KEYSTORE_ACCESS"),
    KEY_NOT_FOUND("KEY_NOT_FOUND"),
    UNKNOWN("KEYSTORE_UNKNOWN")
}

data class KeyStoreException(
    val code: KeyStoreExceptionCode,
    val details: String?
) : Exception("$code: $details") {
    companion object {
        fun access(details: String? = null) =
            KeyStoreException(KeyStoreExceptionCode.ACCESS, details)

        fun keyNotFound(key: String? = null) =
            KeyStoreException(KeyStoreExceptionCode.KEY_NOT_FOUND, key)

        fun unknown(details: String? = null) =
            KeyStoreException(KeyStoreExceptionCode.UNKNOWN, details)
    }
}

open class KeyStore(context: Context, private val encryptionKey: ByteArray? = null) {
    private val sharedPreferences: SharedPreferences

    private companion object {
        const val tag = "KeyStore"
    }

    init {
        val mainKey: MasterKey
        if (encryptionKey != null) {
            val ks = KeyStore.getInstance("AndroidKeyStore").apply {
                load(null)
            }
            if (ks.containsAlias("ftauth")) {
                Log.w(tag, "Replacing existing FTAuth key found")
            }
            ks.setEntry(
                "ftauth",
                KeyStore.SecretKeyEntry(
                    SecretKeySpec(
                        encryptionKey,
                        ""
                    )
                ),
                KeyProtection.Builder(KeyProperties.PURPOSE_ENCRYPT).build()
            )
            mainKey = MasterKey(context, "ftauth", MasterKey.KeyScheme.AES256_GCM)
        } else {
            mainKey = MasterKey.Builder(context)
                .setKeyScheme(MasterKey.KeyScheme.AES256_GCM)
                .build()
        }
        sharedPreferences = EncryptedSharedPreferences.create(
            context,
            "ftauth",
            mainKey,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    fun get(key: String?): ByteArray {
        if (key == null) {
            throw KeyStoreException.keyNotFound()
        }
        val value =
            sharedPreferences.getString(key, null) ?: throw KeyStoreException.keyNotFound(key)
        return value.toByteArray(Charsets.UTF_8)
    }

    fun save(key: String?, data: ByteArray?) {
        if (key == null) {
            throw KeyStoreException.keyNotFound()
        }
        val value = if (data == null) null else String(data)
        with(sharedPreferences.edit()) {
            putString(key, value)
            apply()
        }
    }

    fun clear() {
        with(sharedPreferences.edit()) {
            clear()
            apply()
        }
    }

    fun delete(key: String?) {
        if (key == null) {
            throw KeyStoreException.keyNotFound()
        }
        with(sharedPreferences.edit()) {
            remove(key)
            apply()
        }
    }
}