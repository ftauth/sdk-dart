package io.ftauth.ftauth_storage_android

import android.content.Context
import android.content.SharedPreferences
import androidx.security.crypto.EncryptedSharedPreferences
import androidx.security.crypto.MasterKeys

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

class KeyStore(context: Context) {
    private val sharedPreferences: SharedPreferences

    init {
        val mainKey = MasterKeys.getOrCreate(MasterKeys.AES256_GCM_SPEC)
        sharedPreferences = EncryptedSharedPreferences.create(
            "ftauth",
            mainKey,
            context,
            EncryptedSharedPreferences.PrefKeyEncryptionScheme.AES256_SIV,
            EncryptedSharedPreferences.PrefValueEncryptionScheme.AES256_GCM
        )
    }

    fun get(key: String?): String {
        if (key == null) {
            throw KeyStoreException.keyNotFound()
        }
        return sharedPreferences.getString(key, null) ?: throw KeyStoreException.keyNotFound(key)
    }

    fun save(key: String?, value: String?) {
        if (key == null) {
            throw KeyStoreException.keyNotFound()
        }
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