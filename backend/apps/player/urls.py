from django.urls import path
from .views import PlayerCreateAPIView

urlpatterns = [
    path('create/', PlayerCreateAPIView.as_view(), name='player-create')
]