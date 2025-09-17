from rest_framework import generics
from .models import Room
from .serializers import RoomSerializer
from ..player.models import Player
from rest_framework.request import Request
from typing import cast

class RoomCreateAPIView(generics.CreateAPIView):
    queryset = Room.objects.all()
    serializer_class = RoomSerializer

    def perform_create(self, serializer):
        request = cast(Request, self.request)
        mentor_id = request.data.get("mentor_id")
        mentor = Player.objects.get(id=mentor_id)
        room = serializer.save(mentor=mentor)
        room.players.add(mentor)

