from django.contrib import admin

from .models import (
    ChatMessage,
    DashboardSnapshot,
    FutureHealthPrediction,
    GameResult,
    MedicalReport,
    ProgressEntry,
    UserProfile,
)


@admin.register(UserProfile)
class UserProfileAdmin(admin.ModelAdmin):
    list_display = ['user', 'phone', 'age', 'gender', 'blood_group', 'updated_at']
    search_fields = ['user__username', 'user__email', 'phone', 'emergency_contact']
    list_filter = ['gender', 'blood_group', 'diabetes', 'smoking']


@admin.register(DashboardSnapshot)
class DashboardSnapshotAdmin(admin.ModelAdmin):
    list_display = ['user', 'health_score', 'bmi', 'bio_age', 'bp', 'heart_rate', 'created_at']
    search_fields = ['user__username', 'user__email']
    list_filter = ['created_at']


@admin.register(GameResult)
class GameResultAdmin(admin.ModelAdmin):
    list_display = ['user', 'game_name', 'score', 'status', 'created_at']
    search_fields = ['user__username', 'user__email', 'game_name']
    list_filter = ['game_name', 'status', 'created_at']


@admin.register(MedicalReport)
class MedicalReportAdmin(admin.ModelAdmin):
    list_display = ['user', 'title', 'report_type', 'summary', 'created_at']
    search_fields = ['user__username', 'user__email', 'title', 'summary']
    list_filter = ['report_type', 'created_at']


@admin.register(FutureHealthPrediction)
class FutureHealthPredictionAdmin(admin.ModelAdmin):
    list_display = ['user', 'future_health_score', 'bio_age', 'risk', 'created_at']
    search_fields = ['user__username', 'user__email']
    list_filter = ['risk', 'created_at']


@admin.register(ChatMessage)
class ChatMessageAdmin(admin.ModelAdmin):
    list_display = ['user', 'message', 'created_at']
    search_fields = ['user__username', 'user__email', 'message', 'reply']
    list_filter = ['created_at']


@admin.register(ProgressEntry)
class ProgressEntryAdmin(admin.ModelAdmin):
    list_display = ['user', 'period', 'weight', 'bmi', 'health_score', 'recorded_at']
    search_fields = ['user__username', 'user__email', 'note']
    list_filter = ['period', 'recorded_at']
