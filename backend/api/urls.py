from django.urls import include, path
from rest_framework.routers import DefaultRouter
from rest_framework_simplejwt.views import TokenRefreshView, TokenVerifyView

from .views import (
    AiHealthReportView,
    ChatMessageViewSet,
    DashboardView,
    DietView,
    FutureHealthPredictionViewSet,
    GameResultViewSet,
    HealthAnalysisView,
    LoginView,
    LogoutView,
    MedicalReportViewSet,
    ProfileView,
    ProgressEntryViewSet,
    RegisterView,
    health_check,
)

router = DefaultRouter()
router.register('games', GameResultViewSet, basename='games')
router.register('reports', MedicalReportViewSet, basename='reports')
router.register('future-health', FutureHealthPredictionViewSet, basename='future-health')
router.register('chat', ChatMessageViewSet, basename='chat')
router.register('progress', ProgressEntryViewSet, basename='progress')

urlpatterns = [
    path('health/', health_check, name='health-check'),
    path('register/', RegisterView.as_view(), name='register'),
    path('login/', LoginView.as_view(), name='login'),
    path('logout/', LogoutView.as_view(), name='logout'),
    path('token/refresh/', TokenRefreshView.as_view(), name='token-refresh'),
    path('token/verify/', TokenVerifyView.as_view(), name='token-verify'),
    path('profile/', ProfileView.as_view(), name='profile'),
    path('dashboard/', DashboardView.as_view(), name='dashboard'),
    path('analysis/', HealthAnalysisView.as_view(), name='analysis'),
    path('ai-report/', AiHealthReportView.as_view(), name='ai-report'),
    path('diet/', DietView.as_view(), name='diet'),
    path('', include(router.urls)),
]
