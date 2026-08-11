from django.contrib.auth import get_user_model
from django.contrib.auth.password_validation import validate_password
import re

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
    phone = serializers.CharField(write_only=True, required=False, allow_blank=True)
    password = serializers.CharField(write_only=True, validators=[validate_password])

    class Meta:
        model = User
        fields = ['id', 'name', 'email', 'phone', 'password']

    def validate_email(self, value):
        value = value.lower().strip()
        if User.objects.filter(email=value).exists():
            raise serializers.ValidationError('A user with this email already exists.')
        return value

    def validate_name(self, value):
        value = value.strip()
        if len(value) < 2:
            raise serializers.ValidationError('Name must contain at least 2 letters.')
        if not re.fullmatch(r"[A-Za-z\s.'-]+", value):
            raise serializers.ValidationError('Name can contain only letters, spaces, apostrophes, periods, and hyphens.')
        return value

    def validate_phone(self, value):
        value = value.strip()
        if value and not re.fullmatch(r'\d{10}', value):
            raise serializers.ValidationError('Phone number must contain exactly 10 digits.')
        return value

    def validate_password(self, value):
        validate_password(value)
        if len(value) > 10:
            raise serializers.ValidationError('Password must be 10 characters or fewer.')
        if not re.search(r'[A-Z]', value):
            raise serializers.ValidationError('Password needs at least one uppercase letter.')
        if not re.search(r'[a-z]', value):
            raise serializers.ValidationError('Password needs at least one lowercase letter.')
        if not re.search(r'\d', value):
            raise serializers.ValidationError('Password needs at least one number.')
        if not re.search(r'[!@#$%^&*(),.?":{}|<>_\-+=\[\]\\;/`~]', value):
            raise serializers.ValidationError('Password needs at least one symbol.')
        return value

    def create(self, validated_data):
        name = validated_data.pop('name').strip()
        phone = validated_data.pop('phone', '')
        email = validated_data['email']
        user = User.objects.create_user(username=email, email=email, password=validated_data['password'])
        parts = name.split(' ', 1)
        user.first_name = parts[0]
        user.last_name = parts[1] if len(parts) > 1 else ''
        user.save(update_fields=['first_name', 'last_name'])
        UserProfile.objects.create(user=user, phone=phone)
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

    def validate_phone_like(self, field_name, value):
        if value and not re.fullmatch(r'\d{10}', value):
            raise serializers.ValidationError({field_name: 'Must contain exactly 10 digits.'})

    def validate(self, attrs):
        user_data = attrs.get('user', {})
        name = user_data.get('first_name')
        if name is not None:
            name = name.strip()
            if name and not re.fullmatch(r"[A-Za-z\s.'-]+", name):
                raise serializers.ValidationError({'name': 'Name can contain only letters, spaces, apostrophes, periods, and hyphens.'})
            user_data['first_name'] = name

        phone = attrs.get('phone')
        emergency_contact = attrs.get('emergency_contact')
        self.validate_phone_like('phone', phone)
        self.validate_phone_like('emergency_contact', emergency_contact)

        blood_pressure = attrs.get('blood_pressure')
        if blood_pressure and not re.fullmatch(r'\d{2,3}/\d{2,3}', blood_pressure):
            raise serializers.ValidationError({'blood_pressure': 'Use a value like 120/80.'})

        water_intake = attrs.get('water_intake')
        if water_intake and not re.fullmatch(r'\d{1,2}(\.\d)?L?', water_intake, re.IGNORECASE):
            raise serializers.ValidationError({'water_intake': 'Use a value like 2.5L.'})

        ranges = {
            'age': (1, 120),
            'height': (40, 260),
            'weight': (2, 300),
            'heart_rate': (30, 220),
            'sleep_hours': (0, 24),
        }
        for field, (minimum, maximum) in ranges.items():
            value = attrs.get(field)
            if value is not None and not (minimum <= value <= maximum):
                raise serializers.ValidationError({field: f'Must be between {minimum} and {maximum}.'})
        return attrs

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

    def validate(self, attrs):
        ranges = {
            'weight': (2, 300),
            'walking': (0, 120),
            'sleep': (0, 24),
            'water': (0, 10),
            'exercise': (0, 10),
            'smoking': (0, 10),
            'alcohol': (0, 10),
        }
        for field, (minimum, maximum) in ranges.items():
            value = attrs.get(field)
            if value is not None and not (minimum <= value <= maximum):
                raise serializers.ValidationError({field: f'Must be between {minimum} and {maximum}.'})
        return attrs


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

    def validate(self, attrs):
        ranges = {
            'weight': (2, 300),
            'bmi': (5, 80),
            'health_score': (0, 100),
            'steps': (0, 100000),
            'sleep': (0, 24),
            'heart_rate': (30, 220),
        }
        for field, (minimum, maximum) in ranges.items():
            value = attrs.get(field)
            if value is not None and not (minimum <= value <= maximum):
                raise serializers.ValidationError({field: f'Must be between {minimum} and {maximum}.'})
        water_intake = attrs.get('water_intake')
        if water_intake and not re.fullmatch(r'\d{1,2}(\.\d)?L?', water_intake):
            raise serializers.ValidationError({'water_intake': 'Use a value like 2.5L.'})
        return attrs
