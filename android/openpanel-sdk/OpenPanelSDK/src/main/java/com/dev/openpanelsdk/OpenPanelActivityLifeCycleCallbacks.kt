package com.dev.openpanelsdk

import android.app.Activity
import android.app.Application
import android.os.Bundle

class OpenPanelActivityLifeCycleCallbacks(private val openPanelInstance:OpenPanel): Application.ActivityLifecycleCallbacks {
    private var numStarted = 0

    override fun onActivityCreated(activity: Activity, savedInstanceState: Bundle?) {}

    override fun onActivityStarted(activity: Activity) {
        if (numStarted == 0) {
            // First activity started, app is in foreground
            openPanelInstance.track("app_opened")
        }
        numStarted++
    }

    override fun onActivityResumed(activity: Activity) {}
    override fun onActivityPaused(activity: Activity) {}

    override fun onActivityStopped(activity: Activity) {
        numStarted--
        if (numStarted == 0) {
            // Last activity stopped, app goes to background
            openPanelInstance.track("app_closed")
        }
    }

    override fun onActivitySaveInstanceState(activity: Activity, outState: Bundle) {}
    override fun onActivityDestroyed(activity: Activity) {}
}