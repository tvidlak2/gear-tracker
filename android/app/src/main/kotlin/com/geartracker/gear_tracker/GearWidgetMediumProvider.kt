package com.geartracker.gear_tracker

import android.appwidget.AppWidgetManager
import android.content.Context
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider
import org.json.JSONArray

class GearWidgetMediumProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: Bundle?
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.gear_widget_medium)

            val overdueCount = widgetData?.getInt("overdue_count", 0) ?: 0
            val upcomingCount = widgetData?.getInt("upcoming_count", 0) ?: 0
            val itemsJson = widgetData?.getString("urgent_items_json") ?: "[]"

            views.setTextViewText(R.id.tv_total_issues, "${overdueCount + upcomingCount} položek")

            try {
                val arr = JSONArray(itemsJson)
                val rowIds = listOf(R.id.row_0, R.id.row_1, R.id.row_2)
                val gearIds = listOf(R.id.tv_gear_0, R.id.tv_gear_1, R.id.tv_gear_2)
                val taskIds = listOf(R.id.tv_task_0, R.id.tv_task_1, R.id.tv_task_2)

                for (i in 0..2) {
                    if (i < arr.length()) {
                        val item = arr.getJSONObject(i)
                        val status = item.getString("status")
                        val gearName = item.getString("gear")
                        val taskName = item.getString("task")

                        views.setViewVisibility(rowIds[i], View.VISIBLE)
                        views.setTextViewText(gearIds[i], gearName)
                        views.setTextViewText(taskIds[i], taskName)

                        val color = if (status == "overdue") 0xFFE53935.toInt() else 0xFFFF8F00.toInt()
                        views.setTextColor(gearIds[i], color)
                    } else {
                        views.setViewVisibility(rowIds[i], View.GONE)
                    }
                }
            } catch (e: Exception) {
                // ignore parse errors
            }

            views.setOnClickPendingIntent(
                R.id.btn_open_app,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            )
            views.setOnClickPendingIntent(
                R.id.widget_root,
                HomeWidgetLaunchIntent.getActivity(context, MainActivity::class.java)
            )

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }
}
