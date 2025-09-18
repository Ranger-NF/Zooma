from django.core.serializers import serialize
from rest_framework import generics, views, status
from rest_framework.response import Response

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


class JoinRoomAPIView(views.APIView):
    def post(self, request, *args, **kwargs):
        room_code = request.data.get('room_code')
        player_id = request.data.get('player_id')

        if not room_code or not player_id:
            Response({'error': 'Room code and Players ID are required'}, status=status.HTTP_400_BAD_REQUEST)

        try:
            room = Room.objects.get(code__iexact=room_code)
            player = Player.objects.get(id=player_id)
        except Room.DoesNotExist:
            return Response({'error':'Room not found'}, status=status.HTTP_404_NOT_FOUND)
        except Player.DoesNotExist:
            return Response({'error': 'Player not found'}, status=status.HTTP_404_NOT_FOUND)

        if room.players.count() >= room.max_players:
            return Response({'error': 'Room is full'}, status=status.HTTP_400_BAD_REQUEST)
        if room.players.filter(id=player_id).exists():
            return Response({'You are Already in this Room'}, status=status.HTTP_200_OK)

        room.players.add(player)
        serializer = RoomSerializer(room)
        return Response(serializer.data, status=status.HTTP_200_OK)

class GameControlAPIView(views.APIView):
    def post(self, request, *args, **kwargs):
        room_code = request.data.get('room_code')
        mentor_id = request.data.get('mentor_id')
        action = request.data.get('action') # start or end

        if not all([room_code, mentor_id, action]):
            return Response({'error': 'Room code, mentor ID, and action are required.'},status=status.HTTP_400_BAD_REQUEST)
        try:
            room = Room.objects.get(code__iexact=room_code, mentor_id=mentor_id)
        except Room.DoesNotExist:
            return Response({'error': 'Room not found or you are not the mentor.'}, status=status.HTTP_403_FORBIDDEN)

        if action.lower() == 'start':
            room.is_active = True
            room.save()
            return Response({'message': 'Game has started.'}, status=status.HTTP_200_OK)
        elif action.lower() == 'end':
            room.is_active = False
            room.save()
        else:
            return Response({'error': "Invalid action. Use 'start' or 'end'."}, status=status.HTTP_400_BAD_REQUEST)