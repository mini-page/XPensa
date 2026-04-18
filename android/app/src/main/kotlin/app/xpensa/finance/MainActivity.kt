package app.xpensa.finance

import android.app.Activity
import android.content.Intent
import android.speech.RecognizerIntent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.util.Locale

class MainActivity : FlutterActivity() {

    // ── Voice recognition ──────────────────────────────────────────────
    private var voiceResultCallback: MethodChannel.Result? = null
    private val voiceRequestCode = 0xA1CE

    // ── SMS receiver ───────────────────────────────────────────────────
    private var smsReceiverPlugin: SmsReceiverPlugin? = null

    // ── MethodChannel ─────────────────────────────────────────────────
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WidgetConstants.CHANNEL_NAME,
        ).setMethodCallHandler { call, result ->
            when (call.method) {

                // Flutter → Android: launch the system speech recogniser
                "startVoiceInput" -> {
                    voiceResultCallback = result
                    startVoiceRecognition()
                }

                // Flutter → Android: enable live SMS monitoring
                "startSmsMonitoring" -> {
                    if (smsReceiverPlugin == null) {
                        smsReceiverPlugin = SmsReceiverPlugin(flutterEngine)
                        smsReceiverPlugin!!.register(applicationContext)
                    }
                    result.success(null)
                }

                // Flutter → Android: disable live SMS monitoring
                "stopSmsMonitoring" -> {
                    smsReceiverPlugin?.unregister(applicationContext)
                    smsReceiverPlugin = null
                    result.success(null)
                }

                else -> result.notImplemented()
            }
        }
    }

    override fun onDestroy() {
        smsReceiverPlugin?.unregister(applicationContext)
        smsReceiverPlugin = null
        super.onDestroy()
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
}
