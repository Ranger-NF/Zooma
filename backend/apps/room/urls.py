from django.urls import path
from .views import RoomCreateAPIView, JoinRoomAPIView, GameControlAPIView, RoomQuestionListAPIView


urlpatterns = [
    path('create/', RoomCreateAPIView.as_view(), name='room-create'),
    path('join/', JoinRoomAPIView.as_view(), name='room-join'),
    path('control/', GameControlAPIView.as_view(), name='game-control'),
    path('<str:room_code>/questions/', RoomQuestionListAPIView.as_view(), name='room-question-list'),
]