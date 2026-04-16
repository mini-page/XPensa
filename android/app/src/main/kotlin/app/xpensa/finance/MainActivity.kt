package app.xpensa.finance

import android.app.Activity
import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.speech.RecognizerIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {

    // ── Voice recognition ──────────────────────────────────────────────
    private var voiceResultCallback: MethodChannel.Result? = null
    private val voiceRequestCode = 0xA1CE

    // ── Widget action routing ──────────────────────────────────────────
    // Stores the most-recent widget action string until Flutter reads it.
    private var pendingWidgetAction: String? = null
    // Tracks which Intent instance we've already extracted to avoid re-processing.
    private var processedIntentIdentity: Int = -1

    // ── MethodChannel ─────────────────────────────────────────────────
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WidgetConstants.CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                // Flutter → Android: write widget data to SharedPreferences and refresh widgets
                "syncWidgetData" -> {
                    val prefs = getSharedPreferences(
                        WidgetConstants.PREFS_NAME,
                        Context.MODE_PRIVATE,
                    )
                    prefs.edit().apply {
                        val balance = call.argument<Double>("totalBalance") ?: 0.0
                        putFloat(WidgetConstants.KEY_TOTAL_BALANCE, balance.toFloat())
                        putString(
                            WidgetConstants.KEY_CURRENCY_SYMBOL,
                            call.argument<String>("currencySymbol") ?: "₹",
                        )
                        putString(
                            WidgetConstants.KEY_TRANSACTIONS,
                            call.argument<String>("transactions") ?: "[]",
                        )
                        putLong(
                            WidgetConstants.KEY_LAST_SYNCED,
                            call.argument<Long>("lastSynced")
                                ?: System.currentTimeMillis(),
                        )
                        apply()
                    }
                    refreshAllWidgets()
                    result.success(null)
                }

                // Flutter → Android: return the pending widget action (consumes it)
                "getPendingAction" -> {
                    result.success(pendingWidgetAction)
                    pendingWidgetAction = null
                }

                // Flutter → Android: clear any stored pending action
                "clearPendingAction" -> {
                    pendingWidgetAction = null
                    result.success(null)
                }

                // Flutter → Android: launch the system speech recogniser
                "startVoiceInput" -> {
                    voiceResultCallback = result
                    startVoiceRecognition()
                }

                else -> result.notImplemented()
            }
        }
    }

    // ── Activity lifecycle ─────────────────────────────────────────────

    override fun onResume() {
        super.onResume()
        extractWidgetAction(intent)
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        setIntent(intent)          // Keep getIntent() current for future onResume calls
        extractWidgetAction(intent)
    }

    // ── Voice recognition ──────────────────────────────────────────────

    private fun startVoiceRecognition() {
        val speechIntent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH).apply {
            putExtra(
                RecognizerIntent.EXTRA_LANGUAGE_MODEL,
                RecognizerIntent.LANGUAGE_MODEL_FREE_FORM,
            )
            putExtra(RecognizerIntent.EXTRA_LANGUAGE, Locale.getDefault())
            putExtra(RecognizerIntent.EXTRA_PROMPT, "Say your transaction…")
        }
        @Suppress("DEPRECATION")
        startActivityForResult(speechIntent, voiceRequestCode)
    }

    @Suppress("DEPRECATION", "OVERRIDE_DEPRECATION")
    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        if (requestCode == voiceRequestCode) {
            val text = if (resultCode == Activity.RESULT_OK) {
                data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)?.firstOrNull()
            } else {
                null
            }
            voiceResultCallback?.success(text)
            voiceResultCallback = null
            return
        }
        super.onActivityResult(requestCode, resultCode, data)
    }

    // ── Helpers ────────────────────────────────────────────────────────

    /**
     * Read a `widget_action` extra from [intent] and store it in
     * [pendingWidgetAction] so Flutter can poll it via `getPendingAction`.
     * Each distinct Intent object is processed at most once.
     */
    private fun extractWidgetAction(incomingIntent: Intent?) {
        val action = incomingIntent?.getStringExtra(WidgetConstants.EXTRA_WIDGET_ACTION)
            ?: return
        val id = System.identityHashCode(incomingIntent)
        if (id != processedIntentIdentity) {
            processedIntentIdentity = id
            pendingWidgetAction = action
        }
    }

    /** Push fresh RemoteViews to every placed instance of both widget types. */
    private fun refreshAllWidgets() {
        val manager = AppWidgetManager.getInstance(this)

        val qaName = ComponentName(this, QuickActionWidget::class.java)
        val qaIds = manager.getAppWidgetIds(qaName)
        if (qaIds.isNotEmpty()) {
            QuickActionWidget().onUpdate(this, manager, qaIds)
        }

        val rtName = ComponentName(this, RecentTransactionsWidget::class.java)
        val rtIds = manager.getAppWidgetIds(rtName)
        if (rtIds.isNotEmpty()) {
            RecentTransactionsWidget().onUpdate(this, manager, rtIds)
        }
    }
}
