package dev.openpanel.openpanel_flutter

import android.content.Context
import com.dev.openpanelsdk.OpenPanel
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class OpenpanelFlutterPlugin : FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private var context: Context? = null
    private var openPanel: OpenPanel? = null
    private var currentOptions: OpenPanel.Options? = null

    companion object {
        private const val CHANNEL_NAME = "dev.openpanel/openpanel_flutter"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, CHANNEL_NAME)
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        context = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "setCollectionEnabled" -> handleSetCollectionEnabled(call, result)
            "track" -> handleTrack(call, result)
            "identify" -> handleIdentify(call, result)
            "increment" -> handleIncrement(call, result)
            "decrement" -> handleDecrement(call, result)
            "alias" -> handleAlias(call, result)
            "setGlobalProperties" -> handleSetGlobalProperties(call, result)
            "setProfileId" -> handleSetProfileId(call, result)
            "clear" -> handleClear(result)
            "flush" -> handleFlush(result)
            "ready" -> handleReady(result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        val currentContext = context ?: run {
            result.error("NO_CONTEXT", "Application context is not available", null)
            return
        }

        val clientId = call.argument<String>("clientId") ?: run {
            result.error("INVALID_ARGUMENT", "clientId is required", null)
            return
        }

        val clientSecret = call.argument<String>("clientSecret")
        val apiUrl = call.argument<String>("apiUrl")
        val verbose = call.argument<Boolean>("verbose") ?: false
        val disabled = call.argument<Boolean>("disabled") ?: false
        val automaticTracking = call.argument<Boolean>("automaticTracking") ?: false
        val waitForProfile = call.argument<Boolean>("waitForProfile") ?: false

        val options = OpenPanel.Options(
            clientId = clientId,
            clientSecret = clientSecret,
            apiUrl = apiUrl,
            waitForProfile = waitForProfile,
            disabled = disabled,
            automaticTracking = automaticTracking,
            verbose = verbose
        )
        currentOptions = options
        openPanel = OpenPanel.create(currentContext, options)
        result.success(null)
    }

    private fun handleSetCollectionEnabled(call: MethodCall, result: Result) {
        val enabled = call.argument<Boolean>("enabled") ?: true
        val currentContext = context
        val opts = currentOptions
        if (currentContext != null && opts != null) {
            opts.disabled = !enabled
            openPanel = OpenPanel.create(currentContext, opts)
        }
        result.success(null)
    }

    private fun handleTrack(call: MethodCall, result: Result) {
        val name = call.argument<String>("name") ?: run {
            result.error("INVALID_ARGUMENT", "name is required", null)
            return
        }

        val properties = call.argument<Map<String, Any>>("properties")?.toMutableMap() ?: mutableMapOf()
        val profileId = call.argument<String>("profileId")
        if (profileId != null) {
            properties["profileId"] = profileId
        }

        openPanel?.track(name, properties)
        result.success(null)
    }

    private fun handleIdentify(call: MethodCall, result: Result) {
        val profileId = call.argument<String>("profileId") ?: run {
            result.error("INVALID_ARGUMENT", "profileId is required", null)
            return
        }

        val firstName = call.argument<String>("firstName")
        val lastName = call.argument<String>("lastName")
        val email = call.argument<String>("email")
        val avatar = call.argument<String>("avatar")
        val properties = call.argument<Map<String, Any>>("properties")

        val traits = mutableMapOf<String, Any>()
        firstName?.let { traits["firstName"] = it }
        lastName?.let { traits["lastName"] = it }
        email?.let { traits["email"] = it }
        avatar?.let { traits["avatar"] = it }
        if (properties != null) {
            traits.putAll(properties)
        }

        openPanel?.identify(profileId, traits)
        result.success(null)
    }

    private fun handleIncrement(call: MethodCall, result: Result) {
        val profileId = call.argument<String>("profileId") ?: run {
            result.error("INVALID_ARGUMENT", "profileId is required", null)
            return
        }
        val property = call.argument<String>("property") ?: run {
            result.error("INVALID_ARGUMENT", "property is required", null)
            return
        }
        val value = call.argument<Int>("value") ?: 1

        openPanel?.increment(profileId, property, value)
        result.success(null)
    }

    private fun handleDecrement(call: MethodCall, result: Result) {
        val profileId = call.argument<String>("profileId") ?: run {
            result.error("INVALID_ARGUMENT", "profileId is required", null)
            return
        }
        val property = call.argument<String>("property") ?: run {
            result.error("INVALID_ARGUMENT", "property is required", null)
            return
        }
        val value = call.argument<Int>("value") ?: 1

        openPanel?.decrement(profileId, property, value)
        result.success(null)
    }

    private fun handleAlias(call: MethodCall, result: Result) {
        val profileId = call.argument<String>("profileId") ?: run {
            result.error("INVALID_ARGUMENT", "profileId is required", null)
            return
        }
        val alias = call.argument<String>("alias") ?: run {
            result.error("INVALID_ARGUMENT", "alias is required", null)
            return
        }

        openPanel?.alias(profileId, alias)
        result.success(null)
    }

    private fun handleSetGlobalProperties(call: MethodCall, result: Result) {
        val properties = call.argument<Map<String, Any>>("properties") ?: emptyMap()
        openPanel?.setGlobalProperties(properties)
        result.success(null)
    }

    private fun handleSetProfileId(call: MethodCall, result: Result) {
        val profileId = call.argument<String>("profileId") ?: run {
            result.error("INVALID_ARGUMENT", "profileId is required", null)
            return
        }
        openPanel?.identify(profileId, emptyMap())
        result.success(null)
    }

    private fun handleClear(result: Result) {
        openPanel?.clear()
        result.success(null)
    }

    private fun handleFlush(result: Result) {
        result.success(null)
    }

    private fun handleReady(result: Result) {
        currentOptions?.waitForProfile = false
        result.success(null)
    }
}
