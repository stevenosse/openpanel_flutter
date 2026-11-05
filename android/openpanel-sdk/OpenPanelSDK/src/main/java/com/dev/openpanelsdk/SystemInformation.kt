package com.dev.openpanelsdk

import android.Manifest
import android.annotation.SuppressLint
import android.bluetooth.BluetoothAdapter
import android.bluetooth.BluetoothManager
import android.content.Context
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.net.ConnectivityManager
import android.net.NetworkCapabilities
import android.os.Build
import android.telephony.TelephonyManager
import android.util.DisplayMetrics
import android.util.Log
import android.view.WindowManager

class SystemInformation private constructor(private val context: Context) {

    val appVersionName: String?
    val appVersionCode: Long?
    val appName: String
    val hasNFC: Boolean
    val hasTelephony: Boolean
    private val _displayMetrics: DisplayMetrics = DisplayMetrics()

    val displayMetrics: DisplayMetrics
        get() = DisplayMetrics().also { it.setTo(_displayMetrics) }

    init {
        val packageManager = context.packageManager

        var foundAppVersionName: String? = null
        var foundAppVersionCode: Long? = null

        try {
            val packageInfo: PackageInfo = packageManager.getPackageInfo(context.packageName, 0)
            foundAppVersionName = packageInfo.versionName
            foundAppVersionCode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.longVersionCode
            } else {
                @Suppress("DEPRECATION")
                packageInfo.versionCode.toLong()
            }
        } catch (_: PackageManager.NameNotFoundException) {
            Log.w(
                LOG_TAG,
                "System information constructed with a context that apparently doesn't exist."
            )
        }

        val applicationInfo: ApplicationInfo = context.applicationInfo
        val appNameStringId = applicationInfo.labelRes

        appVersionName = foundAppVersionName
        appVersionCode = foundAppVersionCode
        appName = if (appNameStringId == 0) {
            applicationInfo.nonLocalizedLabel?.toString() ?: "Misc"
        } else {
            context.getString(appNameStringId)
        }

        hasNFC = packageManager.hasSystemFeature(PackageManager.FEATURE_NFC)
        hasTelephony = packageManager.hasSystemFeature(PackageManager.FEATURE_TELEPHONY)

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            context.resources.displayMetrics.let { metrics ->
                _displayMetrics.density = metrics.density
                _displayMetrics.densityDpi = metrics.densityDpi
                @Suppress("DEPRECATION")
                _displayMetrics.scaledDensity =
                    metrics.density * context.resources.configuration.fontScale
                _displayMetrics.xdpi = metrics.xdpi
                _displayMetrics.ydpi = metrics.ydpi
                _displayMetrics.widthPixels = metrics.widthPixels
                _displayMetrics.heightPixels = metrics.heightPixels
            }
        } else {
            @Suppress("DEPRECATION")
            val display =
                (context.getSystemService(Context.WINDOW_SERVICE) as WindowManager).defaultDisplay
            @Suppress("DEPRECATION")
            display.getMetrics(_displayMetrics)
        }
    }

    fun getCurrentNetworkOperator(): String? {
        val telephonyManager =
            context.getSystemService(Context.TELEPHONY_SERVICE) as? TelephonyManager
        return telephonyManager?.networkOperatorName
    }

    @SuppressLint("MissingPermission")
    fun isWifiConnected(): Boolean? {
        if (context.checkCallingOrSelfPermission(Manifest.permission.ACCESS_NETWORK_STATE) == PackageManager.PERMISSION_GRANTED) {
            val connManager =
                context.getSystemService(Context.CONNECTIVITY_SERVICE) as ConnectivityManager
            val network = connManager.activeNetwork ?: return false
            val capabilities = connManager.getNetworkCapabilities(network) ?: return false
            return capabilities.hasTransport(NetworkCapabilities.TRANSPORT_WIFI)
        }
        return null
    }

    @SuppressLint("MissingPermission")
    fun isBluetoothEnabled(context: Context): Boolean? {
        val hasBluetoothPermission =
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
                context.checkSelfPermission(Manifest.permission.BLUETOOTH_CONNECT) ==
                        PackageManager.PERMISSION_GRANTED
            } else {
                @Suppress("DEPRECATION")
                context.checkSelfPermission(Manifest.permission.BLUETOOTH) ==
                        PackageManager.PERMISSION_GRANTED
            }

        if (!hasBluetoothPermission) return null

        val bluetoothAdapter = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.S) {
            context.getSystemService(BluetoothManager::class.java)?.adapter
        } else {
            @Suppress("DEPRECATION")
            BluetoothAdapter.getDefaultAdapter()
        }

        return bluetoothAdapter?.isEnabled
    }

    fun getBluetoothVersion(): String {
        return when {
            context.packageManager.hasSystemFeature(
                PackageManager.FEATURE_BLUETOOTH_LE
            ) -> "ble"

            context.packageManager.hasSystemFeature(PackageManager.FEATURE_BLUETOOTH) -> "classic"
            else -> "none"
        }
    }

    companion object {
        @SuppressLint("StaticFieldLeak") // Safe: stores applicationContext, not Activity/Service
        private var sInstance: SystemInformation? = null
        private val sInstanceLock = Any()
        private const val LOG_TAG = "OpenPanel.SysInfo"

        @JvmStatic
        fun getInstance(context: Context): SystemInformation {
            synchronized(sInstanceLock) {
                if (sInstance == null) {
                    sInstance = SystemInformation(context.applicationContext)
                }
                return sInstance!!
            }
        }
    }
}