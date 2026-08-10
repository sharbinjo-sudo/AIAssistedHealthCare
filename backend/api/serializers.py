from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
from rest_framework import serializers
from rest_framework_simplejwt.serializers import TokenObtainPairSerializer

from .models import (
    ChatMessage,
    DashboardSnapshot,
    FutureHealthPrediction,
    GameResult,
    MedicalReport,
    ProgressEntry,
    UserProfile,
)

User = get_user_model()


class RegisterSerializer(serializers.ModelSerializer):
    name = serializers.CharField(write_only=True)
    password = serializers.CharField(write_only=True, validators=[validate_password])

    class Meta:
        model = User
        fields = ['id', 'name', 'email', 'password']

    def validate_email(self, value):
        value = value.lower().strip()
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError('A user with this email already exists.')
        return value

    def create(self, validated_data):
        name = validated_data.pop('name').strip()
        email = validated_data['email']
        user = User.objects.create_user(username=email, email=email, password=validated_data['password'])
        parts = name.split(' ', 1)
        user.first_name = parts[0]
        user.last_name = parts[1] if len(parts) > 1 else ''
        user.save(update_fields=['first_name', 'last_name'])
        UserProfile.objects.create(user=user)
        DashboardSnapshot.objects.create(user=user)
        return user


class EmailTokenObtainPairSerializer(TokenObtainPairSerializer):
    username_field = 'email'

    def validate(self, attrs):
        email = attrs.get('email', '').lower().strip()
        try:
            attrs['username'] = User.objects.get(email=email).get_username()
        except User.DoesNotExist as exc:
            raise serializers.ValidationError({'email': 'No account exists for this email.'}) from exc
        data = super().validate(attrs)
        data['user'] = UserSummarySerializer(self.user).data
        return data


class UserSummarySerializer(serializers.ModelSerializer):
    name = serializers.SerializerMethodField()

    class Meta:
        model = User
        fields = ['id', 'name', 'email']

    def get_name(self, obj):
        return obj.get_full_name() or obj.username


class UserProfileSerializer(serializers.ModelSerializer):
    name = serializers.CharField(source='user.first_name', required=False, allow_blank=True)
    email = serializers.EmailField(source='user.email', read_only=True)

    class Meta:
        model = UserProfile
        fields = [
            'name',
            'email',
            'phone',
            'age',
            'gender',
            'height',
            'weight',
            'blood_pressure',
            'heart_rate',
            'blood_group',
            'family_history',
            'allergies',
            'diabetes',
            'smoking',
            'alcohol',
            'exercise',
            'sleep_hours',
            'water_intake',
            'emergency_contact',
            'updated_at',
        ]
        read_only_fields = ['updated_at']

    def update(self, instance, validated_data):
        user_data = validated_data.pop('user', {})
        name = user_data.get('first_name')
        if name is not None:
            instance.user.first_name = name
            instance.user.save(update_fields=['first_name'])
        return super().update(instance, validated_data)


class DashboardSnapshotSerializer(serializers.ModelSerializer):
    healthScore = serializers.IntegerField(source='health_score')
    bmi = serializers.FloatField()
    bioAge = serializers.IntegerField(source='bio_age')
    heartRate = serializers.IntegerField(source='heart_rate')
    sleep = serializers.FloatField()

    class Meta:
        model = DashboardSnapshot
        fields = ['healthScore', 'bmi', 'bioAge', 'bp', 'heartRate', 'sleep', 'steps', 'water', 'calories']


class GameResultSerializer(serializers.ModelSerializer):
    gameName = serializers.CharField(source='game_name')

    class Meta:
        model = GameResult
        fields = ['id', 'gameName', 'score', 'status', 'created_at']
        read_only_fields = ['id', 'score', 'status', 'created_at']


class MedicalReportSerializer(serializers.ModelSerializer):
    analysis = serializers.SerializerMethodField()

    class Meta:
        model = MedicalReport
        fields = ['id', 'title', 'file', 'report_type', 'analysis', 'created_at']
        read_only_fields = ['id', 'analysis', 'created_at']

    def get_analysis(self, obj):
        return {
            'bloodSugar': obj.blood_sugar,
            'cholesterol': obj.cholesterol,
            'bp': obj.bp,
            'summary': obj.summary,
        }


class FutureHealthPredictionSerializer(serializers.ModelSerializer):
    futureHealthScore = serializers.IntegerField(source='future_health_score', read_only=True)
    bioAge = serializers.IntegerField(source='bio_age', read_only=True)

    class Meta:
        model = FutureHealthPrediction
        fields = [
            'id',
            'weight',
            'walking',
            'sleep',
            'water',
            'exercise',
            'smoking',
            'alcohol',
            'futureHealthScore',
            'bioAge',
            'risk',
            'created_at',
        ]
        read_only_fields = ['id', 'futureHealthScore', 'bioAge', 'risk', 'created_at']


class ChatMessageSerializer(serializers.ModelSerializer):
    class Meta:
        model = ChatMessage
        fields = ['id', 'message', 'reply', 'created_at']
        read_only_fields = ['id', 'reply', 'created_at']


class ProgressEntrySerializer(serializers.ModelSerializer):
    class Meta:
        model = ProgressEntry
        fields = [
            'id',
            'period',
            'weight',
            'bmi',
            'health_score',
            'water_intake',
            'steps',
            'sleep',
            'heart_rate',
            'note',
            'recorded_at',
        ]
        read_only_fields = ['id', 'recorded_at']
