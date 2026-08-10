from django.contrib.auth import authenticate
from django.db import transaction
from rest_framework import mixins, status, viewsets
from rest_framework.decorators import action, api_view, permission_classes
from rest_framework.permissions import AllowAny, IsAuthenticated
from rest_framework.response import Response
from rest_framework.views import APIView
from rest_framework_simplejwt.tokens import RefreshToken

from .models import (
    ChatMessage,
    DashboardSnapshot,
    FutureHealthPrediction,
    GameResult,
    MedicalReport,
    ProgressEntry,
    UserProfile,
)
from .serializers import (
    ChatMessageSerializer,
    DashboardSnapshotSerializer,
    FutureHealthPredictionSerializer,
    GameResultSerializer,
    MedicalReportSerializer,
    ProgressEntrySerializer,
    RegisterSerializer,
    UserProfileSerializer,
    UserSummarySerializer,
)


def ok(data=None, message='Success', status_code=status.HTTP_200_OK):
    return Response({'success': True, 'message': message, 'data': data or {}}, status=status_code)


def calculate_dashboard_from_profile(user):
    profile = getattr(user, 'health_profile', None)
    if not profile:
        return DashboardSnapshot.objects.create(user=user)

    bmi = 22.4
    if profile.height and profile.weight:
        height_m = float(profile.height) / 100
        if height_m > 0:
            bmi = round(float(profile.weight) / (height_m * height_m), 1)

    return DashboardSnapshot.objects.create(
        user=user,
        bmi=bmi,
        bp=profile.blood_pressure or '120/80',
        heart_rate=profile.heart_rate or 74,
        sleep=profile.sleep_hours or 7.8,
        water=profile.water_intake or '2.5L',
    )


class RegisterView(APIView):
    permission_classes = [AllowAny]

    @transaction.atomic
    def post(self, request):
        serializer = RegisterSerializer(data=request.data)
        serializer.is_valid(raise_exception=True)
        user = serializer.save()
        refresh = RefreshToken.for_user(user)
        return ok(
            {
                'userId': str(user.id),
                'user': UserSummarySerializer(user).data,
                'access': str(refresh.access_token),
                'refresh': str(refresh),
            },
            'Registration successful',
            status.HTTP_201_CREATED,
        )


class LoginView(APIView):
    permission_classes = [AllowAny]

    def post(self, request):
        email = request.data.get('email', '').lower().strip()
        password = request.data.get('password', '')
        if not email or not password:
            return Response(
                {
                    'success': False,
                    'message': 'Email and password are required.',
                    'errors': {'non_field_errors': ['Email and password are required.']},
                },
                status=status.HTTP_400_BAD_REQUEST,
            )

        user = authenticate(request, username=email, password=password)
        if user is None:
            return Response({'success': False, 'message': 'Invalid email or password.'}, status=status.HTTP_401_UNAUTHORIZED)

        refresh = RefreshToken.for_user(user)
        payload = {
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': UserSummarySerializer(user).data,
        }
        response = ok(payload, 'Login Successful')
        response.data['access'] = payload['access']
        response.data['refresh'] = payload['refresh']
        response.data['user'] = payload['user']['name']
        return response


class LogoutView(APIView):
    def post(self, request):
        refresh = request.data.get('refresh')
        if not refresh:
            return Response({'success': False, 'message': 'Refresh token is required.', 'errors': {'refresh': ['This field is required.']}}, status=status.HTTP_400_BAD_REQUEST)
        try:
            RefreshToken(refresh).blacklist()
        except Exception:
            return Response({'success': False, 'message': 'Invalid refresh token.'}, status=status.HTTP_400_BAD_REQUEST)
        return ok(message='Logout successful')


class ProfileView(APIView):
    def get_object(self):
        profile, _ = UserProfile.objects.get_or_create(user=self.request.user)
        return profile

    def get(self, request):
        return ok(UserProfileSerializer(self.get_object()).data, 'Profile retrieved successfully')

    def put(self, request):
        serializer = UserProfileSerializer(self.get_object(), data=request.data)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        calculate_dashboard_from_profile(request.user)
        return ok(serializer.data, 'Profile saved successfully')

    def patch(self, request):
        serializer = UserProfileSerializer(self.get_object(), data=request.data, partial=True)
        serializer.is_valid(raise_exception=True)
        serializer.save()
        calculate_dashboard_from_profile(request.user)
        return ok(serializer.data, 'Profile saved successfully')


class DashboardView(APIView):
    def get(self, request):
        snapshot = DashboardSnapshot.objects.filter(user=request.user).first()
        if snapshot is None:
            snapshot = calculate_dashboard_from_profile(request.user)
        return ok(DashboardSnapshotSerializer(snapshot).data, 'Dashboard data retrieved successfully')


class HealthAnalysisView(APIView):
    def get(self, request):
        snapshot = DashboardSnapshot.objects.filter(user=request.user).first()
        if snapshot is None:
            snapshot = calculate_dashboard_from_profile(request.user)
        data = {
            'healthScore': snapshot.health_score,
            'risk': 'Low',
            'bioAge': snapshot.bio_age + 1,
            'bmi': float(snapshot.bmi),
            'stress': 'Medium',
        }
        return ok(data, 'Health analysis retrieved successfully')


class AiHealthReportView(APIView):
    def get(self, request):
        data = {
            'Health Summary': 'Your core markers are stable with strong activity consistency.',
            'Detected Risks': 'Low cardiovascular risk. Cholesterol needs light attention.',
            'Lifestyle Suggestions': 'Add two strength sessions and keep sleep above seven hours.',
            'Priority Level': 'Medium priority: nutrition optimization.',
            'Healthy Habits': 'Walking, hydration, and steady sleep are working well.',
            'Doctor Recommendation': 'Routine annual checkup is enough unless symptoms change.',
        }
        return ok(data, 'AI health report retrieved successfully')


class DietView(APIView):
    def get(self, request):
        data = {
            'targets': {'calories': 2200, 'protein': '110g', 'water': '3L'},
            'dailyPlan': {
                'Breakfast': 'Greek yogurt, berries, oats',
                'Lunch': 'Quinoa bowl with paneer and greens',
                'Dinner': 'Grilled protein, vegetables, lentil soup',
                'Snacks': 'Fruit, nuts, coconut water',
                'BMI Advice': 'Maintain current range with strength work',
                'Exercise Tips': 'Walk 8k steps and add mobility',
                'Shopping List': 'Leafy greens, eggs, pulses, curd, citrus',
            },
        }
        return ok(data, 'Diet plan retrieved successfully')


class GameResultViewSet(mixins.CreateModelMixin, mixins.ListModelMixin, viewsets.GenericViewSet):
    serializer_class = GameResultSerializer

    def get_queryset(self):
        return GameResult.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        game_name = serializer.validated_data.get('game_name', 'Mini Game')
        score = 88
        serializer.save(user=self.request.user, game_name=game_name, score=score, status='Good')

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        return ok(response.data, 'Game result saved successfully', status.HTTP_201_CREATED)

    def list(self, request, *args, **kwargs):
        return ok(super().list(request, *args, **kwargs).data, 'Game results retrieved successfully')


class MedicalReportViewSet(viewsets.ModelViewSet):
    serializer_class = MedicalReportSerializer

    def get_queryset(self):
        return MedicalReport.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        return ok(response.data, 'Report uploaded and analyzed successfully', status.HTTP_201_CREATED)

    def list(self, request, *args, **kwargs):
        return ok(super().list(request, *args, **kwargs).data, 'Reports retrieved successfully')

    def retrieve(self, request, *args, **kwargs):
        return ok(super().retrieve(request, *args, **kwargs).data, 'Report retrieved successfully')

    def update(self, request, *args, **kwargs):
        return ok(super().update(request, *args, **kwargs).data, 'Report updated successfully')

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return ok(message='Report deleted successfully')

    @action(detail=False, methods=['get'])
    def analysis(self, request):
        report = self.get_queryset().first()
        if report is None:
            report = MedicalReport.objects.create(user=request.user, title='Dummy AI Report')
        return ok(MedicalReportSerializer(report).data['analysis'], 'Report analysis retrieved successfully')


class FutureHealthPredictionViewSet(mixins.CreateModelMixin, mixins.ListModelMixin, viewsets.GenericViewSet):
    serializer_class = FutureHealthPredictionSerializer

    def get_queryset(self):
        return FutureHealthPrediction.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        return ok(response.data, 'Future health prediction created successfully', status.HTTP_201_CREATED)

    def list(self, request, *args, **kwargs):
        return ok(super().list(request, *args, **kwargs).data, 'Future predictions retrieved successfully')


class ChatMessageViewSet(mixins.CreateModelMixin, mixins.ListModelMixin, mixins.DestroyModelMixin, viewsets.GenericViewSet):
    serializer_class = ChatMessageSerializer

    def get_queryset(self):
        return ChatMessage.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        reply = 'Based on your current data, your Health Score is 91/100. Your BMI is normal. Continue daily walking and drink more water.'
        serializer.save(user=self.request.user, reply=reply)

    def create(self, request, *args, **kwargs):
        response = super().create(request, *args, **kwargs)
        return ok(response.data, 'Chat response generated successfully', status.HTTP_201_CREATED)

    def list(self, request, *args, **kwargs):
        return ok(super().list(request, *args, **kwargs).data, 'Chat history retrieved successfully')

    def destroy(self, request, *args, **kwargs):
        super().destroy(request, *args, **kwargs)
        return ok(message='Chat message deleted successfully')

    @action(detail=False, methods=['delete'])
    def clear(self, request):
        self.get_queryset().delete()
        return ok(message='Chat history cleared successfully')


class ProgressEntryViewSet(viewsets.ModelViewSet):
    serializer_class = ProgressEntrySerializer

    def get_queryset(self):
        return ProgressEntry.objects.filter(user=self.request.user)

    def perform_create(self, serializer):
        serializer.save(user=self.request.user)


@api_view(['GET'])
@permission_classes([IsAuthenticated])
def health_check(request):
    return ok({'user': request.user.email}, 'API is running')
