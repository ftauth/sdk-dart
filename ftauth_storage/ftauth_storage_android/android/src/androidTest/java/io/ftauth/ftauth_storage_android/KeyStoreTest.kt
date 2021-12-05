package io.ftauth.ftauth_storage_android

import androidx.test.ext.junit.runners.AndroidJUnit4
import androidx.test.platform.app.InstrumentationRegistry
import org.junit.Assert.*
import org.junit.Before
import org.junit.Test
import org.junit.runner.RunWith

@RunWith(AndroidJUnit4::class)
class KeyStoreTest {
    private val appContext = InstrumentationRegistry.getInstrumentation().targetContext
    private val keyStore = KeyStore(appContext)

    companion object {
        const val key = "key"
        const val value = "value"
        const val anotherKey = "anotherKey"
        const val anotherValue = "anotherValue"
        const val aThirdKey = "aThirdKey"
        const val aThirdValue = "aThirdValue"
    }

    @Before
    fun setUp() {
        keyStore.clear()
    }

    @Test
    fun keyStoreGet() {
        // Empty keyStore throws
        try {
            keyStore.get(key)
            fail("Should throw Keystore exception")
        } catch (e: Exception) {
        }

        // Successful save/get
        try {
            keyStore.save(key, value)
            val savedValue = keyStore.get(key)
            assertEquals(value, savedValue)
        } catch (e: Exception) {
            fail("Should not throw")
        }

        // Nil key throws
        try {
            keyStore.get(null)
            fail("Should throw Keystore exception")
        } catch (e: Exception) {
        }
    }

    @Test
    fun keyStoreSet() {


        keyStore.save(key, value)
        keyStore.save(anotherKey, anotherValue)
        assertEquals(value, keyStore.get(key))
        assertEquals(anotherValue, keyStore.get(anotherKey))
    }

    @Test
    fun keyStoreDelete() {
        keyStore.save(key, value)
        assertEquals(value, keyStore.get(key))

        keyStore.delete(key)
        try {
            keyStore.get(key)
            fail("Should throw Keystore exception")
        } catch (e: Exception) {
        }
    }

    @Test
    fun keyStoreClear() {
        keyStore.save(key, value)
        keyStore.save(anotherKey, anotherValue)
        keyStore.save(aThirdKey, aThirdValue)

        assertEquals(value, keyStore.get(key))
        assertEquals(anotherValue, keyStore.get(anotherKey))
        assertEquals(aThirdValue, keyStore.get(aThirdKey))

        keyStore.clear()

        try {
            keyStore.get(key)
            fail("Should throw Keystore exception")
        } catch (e: Exception) {
        }
        try {
            keyStore.get(anotherKey)
            fail("Should throw Keystore exception")
        } catch (e: Exception) {
        }
        try {
            keyStore.get(aThirdKey)
            fail("Should throw Keystore exception")
        } catch (e: Exception) {
        }
    }
}