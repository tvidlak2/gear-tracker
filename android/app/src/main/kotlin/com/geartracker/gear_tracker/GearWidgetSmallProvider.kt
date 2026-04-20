package com.geartracker.gear_tracker

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

class GearWidgetSmallProvider : AppWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val widgetData = HomeWidgetPlugin.getData(context)

        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.gear_widget_small)

            val overdueCount = widgetData.getInt("overdue_count", 0)
            val upcomingCount = widgetData.getInt("upcoming_count", 0)

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
