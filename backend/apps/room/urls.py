from django.urls import path
from .views import RoomCreateAPIView


urlpatterns = [
    path('create/', RoomCreateAPIView.as_view(), name='room-create'),
    # path('join/', JoinRoomAPIView.as_view(), name='room-join'),
    # path('control/', GameControlAPIView.as_view(), name='game-control'),
]