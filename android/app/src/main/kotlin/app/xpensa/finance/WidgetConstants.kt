package app.xpensa.finance

internal object WidgetConstants {
    // SharedPreferences file name (must match Flutter-side channel argument)
    const val PREFS_NAME = "xpensa_widget"

    // Data keys
    const val KEY_TOTAL_BALANCE = "total_balance"
    const val KEY_CURRENCY_SYMBOL = "currency_symbol"
    const val KEY_TRANSACTIONS = "transactions"
    const val KEY_LAST_SYNCED = "last_synced"

    // Per-widget filter key prefix: "txn_filter_<widgetId>"
    const val KEY_TXN_FILTER_PREFIX = "txn_filter_"

    // Intent action strings used in widget PendingIntents and MainActivity routing
    const val ACTION_ADD_EXPENSE = "app.xpensa.finance.ACTION_ADD_EXPENSE"
    const val ACTION_ADD_INCOME = "app.xpensa.finance.ACTION_ADD_INCOME"
    const val ACTION_ADD_TRANSFER = "app.xpensa.finance.ACTION_ADD_TRANSFER"
    const val ACTION_SCANNER = "app.xpensa.finance.ACTION_SCANNER"
    const val ACTION_VOICE = "app.xpensa.finance.ACTION_VOICE"
    const val ACTION_OPEN_APP = "app.xpensa.finance.ACTION_OPEN_APP"
    const val ACTION_SET_TXN_FILTER = "app.xpensa.finance.ACTION_SET_TXN_FILTER"

    // Intent extras
    const val EXTRA_WIDGET_ACTION = "widget_action"
    const val EXTRA_WIDGET_ID = "widget_id"
    const val EXTRA_FILTER_VALUE = "filter_value"

    // Filter values
    const val FILTER_TODAY = "today"
    const val FILTER_WEEK = "week"
    const val FILTER_MONTH = "month"

    // Flutter MethodChannel name
    const val CHANNEL_NAME = "app.xpensa.finance/widget"
}
