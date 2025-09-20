from django.urls import path
from .views import (
    AnswerCreateAPIView,
    MentorDashboardAPIView,
    EvaluateAnswerAPIView,
    LeaderboardAPIView,
)

urlpatterns = [
    path('submit-answer/', AnswerCreateAPIView.as_view(), name='answer-create'),
    path('dashboard/', MentorDashboardAPIView.as_view(), name='mentor-dashboard'),
    path('evaluate/', EvaluateAnswerAPIView.as_view(), name='evaluate-answer'),
    path('leaderboard/', LeaderboardAPIView.as_view(), name='leaderboard'),
]
