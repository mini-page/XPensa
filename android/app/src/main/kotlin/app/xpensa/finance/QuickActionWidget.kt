package app.xpensa.finance

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.os.Build
import android.widget.RemoteViews
import kotlin.math.abs
import java.text.NumberFormat
import java.util.Locale

/**
 * AppWidgetProvider for Widget 1 — Quick Finance Action Widget.
 *
 * Displays the total account balance and one-tap buttons for:
 *   • Add Expense / Add Income / Add Transfer
 *   • Scan QR / receipt
 *   • Voice entry
 *
 * Data is read from SharedPreferences (key-space: [WidgetConstants.PREFS_NAME])
 * which is written by [MainActivity] via the Flutter MethodChannel.
 */
class QuickActionWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            widgetId: Int,
        ) {
            val prefs = context.getSharedPreferences(
                WidgetConstants.PREFS_NAME,
                Context.MODE_PRIVATE,
            )

            val hasData = prefs.contains(WidgetConstants.KEY_LAST_SYNCED)
            val rawBalance = prefs.getFloat(WidgetConstants.KEY_TOTAL_BALANCE, 0f).toDouble()
            val symbol = prefs.getString(WidgetConstants.KEY_CURRENCY_SYMBOL, "₹") ?: "₹"

            val balanceText = if (hasData) {
                formatBalance(symbol, rawBalance)
            } else {
                "Open XPensa"
            }

            val views = RemoteViews(context.packageName, R.layout.widget_quick_action)

            views.setTextViewText(R.id.widget_qa_balance, balanceText)

            // Balance area taps → open app home
            views.setOnClickPendingIntent(
                R.id.widget_qa_header,
                buildActionIntent(context, "open_app", widgetId * 10),
            )

            // Individual action buttons
            views.setOnClickPendingIntent(
                R.id.widget_qa_add_expense,
                buildActionIntent(context, "add_expense", widgetId * 10 + 1),
            )
            views.setOnClickPendingIntent(
                R.id.widget_qa_add_income,
                buildActionIntent(context, "add_income", widgetId * 10 + 2),
            )
            views.setOnClickPendingIntent(
                R.id.widget_qa_add_transfer,
                buildActionIntent(context, "add_transfer", widgetId * 10 + 3),
            )
            views.setOnClickPendingIntent(
                R.id.widget_qa_scanner,
                buildActionIntent(context, "scanner", widgetId * 10 + 4),
            )
            views.setOnClickPendingIntent(
                R.id.widget_qa_voice,
                buildActionIntent(context, "voice", widgetId * 10 + 5),
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }

        /** Build a PendingIntent that starts [MainActivity] with [widgetAction] stored as an extra. */
        private fun buildActionIntent(
            context: Context,
            widgetAction: String,
            requestCode: Int,
        ): PendingIntent {
            val intent = Intent(context, MainActivity::class.java).apply {
                putExtra(WidgetConstants.EXTRA_WIDGET_ACTION, widgetAction)
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or
                        Intent.FLAG_ACTIVITY_SINGLE_TOP
            }
            return PendingIntent.getActivity(
                context,
                requestCode,
                intent,
                pendingIntentFlags(),
            )
        }

        private fun pendingIntentFlags(): Int {
            return if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) {
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            } else {
                PendingIntent.FLAG_UPDATE_CURRENT
            }
        }

        private fun formatBalance(symbol: String, amount: Double): String {
            val absVal = abs(amount)
            val formatted = NumberFormat.getNumberInstance(Locale.getDefault()).apply {
                maximumFractionDigits = 2
                minimumFractionDigits = 0
            }.format(absVal)
            return if (amount < 0) "-$symbol$formatted" else "$symbol$formatted"
        }
    }
}
