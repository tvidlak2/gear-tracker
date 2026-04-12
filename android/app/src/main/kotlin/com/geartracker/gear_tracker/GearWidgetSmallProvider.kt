package com.geartracker.gear_tracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.os.Bundle
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class GearWidgetSmallProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: Bundle?
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.gear_widget_small)

            val overdueCount = widgetData?.getInt("overdue_count", 0) ?: 0
            val upcomingCount = widgetData?.getInt("upcoming_count", 0) ?: 0

            views.setTextViewText(R.id.tv_overdue_count, overdueCount.toString())
            views.setTextViewText(R.id.tv_upcoming_count, upcomingCount.toString())

            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
