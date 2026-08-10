from django.conf import settings
from django.db import models


class UserProfile(models.Model):
    user = models.OneToOneField(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='health_profile')
    phone = models.CharField(max_length=20, blank=True)
    age = models.PositiveSmallIntegerField(null=True, blank=True)
    gender = models.CharField(max_length=30, blank=True)
    height = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    weight = models.DecimalField(max_digits=5, decimal_places=2, null=True, blank=True)
    blood_pressure = models.CharField(max_length=20, blank=True)
    heart_rate = models.PositiveSmallIntegerField(null=True, blank=True)
    blood_group = models.CharField(max_length=10, blank=True)
    family_history = models.TextField(blank=True)
    allergies = models.TextField(blank=True)
    diabetes = models.CharField(max_length=50, blank=True)
    smoking = models.CharField(max_length=50, blank=True)
    alcohol = models.CharField(max_length=50, blank=True)
    exercise = models.CharField(max_length=100, blank=True)
    sleep_hours = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    water_intake = models.CharField(max_length=20, blank=True)
    emergency_contact = models.CharField(max_length=100, blank=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.user.get_full_name() or self.user.username


class DashboardSnapshot(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='dashboard_snapshots')
    health_score = models.PositiveSmallIntegerField(default=91)
    bmi = models.DecimalField(max_digits=4, decimal_places=1, default=22.4)
    bio_age = models.PositiveSmallIntegerField(default=23)
    bp = models.CharField(max_length=20, default='120/80')
    heart_rate = models.PositiveSmallIntegerField(default=74)
    sleep = models.DecimalField(max_digits=4, decimal_places=1, default=7.8)
    steps = models.PositiveIntegerField(default=8230)
    water = models.CharField(max_length=20, default='2.5L')
    calories = models.PositiveIntegerField(default=640)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.user} dashboard {self.created_at:%Y-%m-%d}'


class GameResult(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='game_results')
    game_name = models.CharField(max_length=80)
    score = models.PositiveSmallIntegerField()
    status = models.CharField(max_length=40)
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return f'{self.game_name}: {self.score}'


class MedicalReport(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='medical_reports')
    title = models.CharField(max_length=120)
    file = models.FileField(upload_to='reports/', blank=True, null=True)
    report_type = models.CharField(max_length=30, blank=True)
    blood_sugar = models.CharField(max_length=50, default='Normal')
    cholesterol = models.CharField(max_length=50, default='Slightly High')
    bp = models.CharField(max_length=20, default='120/80')
    summary = models.CharField(max_length=255, default='Healthy')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']

    def __str__(self):
        return self.title


class FutureHealthPrediction(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='future_predictions')
    weight = models.DecimalField(max_digits=5, decimal_places=1)
    walking = models.DecimalField(max_digits=5, decimal_places=1)
    sleep = models.DecimalField(max_digits=4, decimal_places=1)
    water = models.DecimalField(max_digits=4, decimal_places=1)
    exercise = models.DecimalField(max_digits=4, decimal_places=1)
    smoking = models.DecimalField(max_digits=4, decimal_places=1)
    alcohol = models.DecimalField(max_digits=4, decimal_places=1)
    future_health_score = models.PositiveSmallIntegerField(default=97)
    bio_age = models.PositiveSmallIntegerField(default=21)
    risk = models.CharField(max_length=40, default='Very Low')
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-created_at']


class ChatMessage(models.Model):
    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='chat_messages')
    message = models.TextField()
    reply = models.TextField()
    created_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['created_at']

    def __str__(self):
        return self.message[:60]


class ProgressEntry(models.Model):
    PERIOD_CHOICES = [('W', 'Weekly'), ('M', 'Monthly'), ('Y', 'Yearly')]

    user = models.ForeignKey(settings.AUTH_USER_MODEL, on_delete=models.CASCADE, related_name='progress_entries')
    period = models.CharField(max_length=1, choices=PERIOD_CHOICES, default='W')
    weight = models.DecimalField(max_digits=5, decimal_places=1, null=True, blank=True)
    bmi = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    health_score = models.PositiveSmallIntegerField(null=True, blank=True)
    water_intake = models.CharField(max_length=20, blank=True)
    steps = models.PositiveIntegerField(null=True, blank=True)
    sleep = models.DecimalField(max_digits=4, decimal_places=1, null=True, blank=True)
    heart_rate = models.PositiveSmallIntegerField(null=True, blank=True)
    note = models.CharField(max_length=255, blank=True)
    recorded_at = models.DateTimeField(auto_now_add=True)

    class Meta:
        ordering = ['-recorded_at']
