from django.urls import reverse
from rest_framework import status
from rest_framework.test import APITestCase


class HealthApiTests(APITestCase):
    def register_and_authenticate(self):
        response = self.client.post(
            reverse('register'),
            {'name': 'John', 'email': 'john@example.com', 'password': 'Str0ng!A'},
            format='json',
        )
        self.assertEqual(response.status_code, status.HTTP_201_CREATED)
        token = response.data['data']['access']
        self.client.credentials(HTTP_AUTHORIZATION=f'Bearer {token}')
        return response

    def test_registration_login_and_profile_flow(self):
        self.register_and_authenticate()
        login = self.client.post(
            reverse('login'),
            {'email': 'john@example.com', 'password': 'Str0ng!A'},
            format='json',
        )
        self.assertEqual(login.status_code, status.HTTP_200_OK)
        self.assertIn('access', login.data)

        profile = self.client.patch(
            reverse('profile'),
            {'age': 28, 'height': '175.0', 'weight': '72.0', 'blood_pressure': '120/80'},
            format='json',
        )
        self.assertEqual(profile.status_code, status.HTTP_200_OK)

        dashboard = self.client.get(reverse('dashboard'))
        self.assertEqual(dashboard.status_code, status.HTTP_200_OK)
        self.assertIn('healthScore', dashboard.data['data'])
        self.assertEqual(dashboard.data['data']['bioAge'], 26)

    def test_protected_endpoints_require_jwt(self):
        response = self.client.get(reverse('dashboard'))
        self.assertEqual(response.status_code, status.HTTP_401_UNAUTHORIZED)

    def test_chat_and_report_endpoints(self):
        self.register_and_authenticate()
        chat = self.client.post('/api/chat/', {'message': 'What is my BMI?'}, format='json')
        self.assertEqual(chat.status_code, status.HTTP_201_CREATED)
        self.assertIn('reply', chat.data['data'])

        analysis = self.client.get('/api/reports/analysis/')
        self.assertEqual(analysis.status_code, status.HTTP_200_OK)
        self.assertEqual(analysis.data['data']['summary'], 'Healthy')

    def test_rejects_malformed_signup_and_profile_input(self):
        weak_password = self.client.post(
            reverse('register'),
            {'name': 'John', 'email': 'bad@example.com', 'phone': '12345', 'password': 'password'},
            format='json',
        )
        self.assertEqual(weak_password.status_code, status.HTTP_400_BAD_REQUEST)

        self.register_and_authenticate()
        bad_profile = self.client.patch(
            reverse('profile'),
            {'age': 200, 'emergency_contact': 'abcdef', 'blood_pressure': 'high'},
            format='json',
        )
        self.assertEqual(bad_profile.status_code, status.HTTP_400_BAD_REQUEST)
