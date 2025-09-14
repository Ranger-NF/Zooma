from rest_framework import generics
from .models import Room
from .serializers import RoomSerializer
from ..player.models import Player

class RoomCreateAPIView(generics.CreateAPIView):
    queryset = Room.objects.all()
    serializer_class = RoomSerializer

    def perform_create(self, serializer):
        # CORRECT: Use request.data to get data from the POST body
        mentor_id = self.request.data.get("mentor_id")


        mentor = Player.objects.get(id=mentor_id)
        room = serializer.save(mentor=mentor)
        room.players.add(mentor)