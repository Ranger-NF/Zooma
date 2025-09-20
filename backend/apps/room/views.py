import shutil

from apps.question.models import Question
from rest_framework import generics, views, status
from rest_framework.response import Response
from apps.answer.models import Answer
from .models import Room
from .serializers import RoomSerializer
from ..player.models import Player
from rest_framework.request import Request
from typing import cast
import random
import os
from django.conf import settings

class RoomCreateAPIView(generics.CreateAPIView):
    queryset = Room.objects.all()
    serializer_class = RoomSerializer

    def perform_create(self, serializer):
        request = cast(Request, self.request)
        mentor_id = request.data.get("mentor_id")
        num_questions = int(request.data.get('num_questions', 5))
        mentor = Player.objects.get(id=mentor_id)
        room = serializer.save(mentor=mentor)
        room.players.add(mentor)

        all_questions = list(Question.objects.all())
        if len(all_questions) < num_questions:
            selected_questions = all_questions
        else:
            selected_questions = random.sample(all_questions, num_questions)

        room.questions.set(selected_questions)

class RoomQuestionListAPIView(views.APIView):
    def get(self, request, room_code, *args, **kwargs):
        try:
            room = Room.objects.get(code__iexact=room_code)
            questions = room.questions.all().values('id', 'text')
            return Response(list(questions))
        except Room.DoesNotExist:
            return Response({'error': 'Room not found.'}, status=status.HTTP_404_NOT_FOUND)


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
            answers = Answer.objects.filter(room=room)
            for answer in answers:
                if answer.image:
                    if os.path.isfile(answer.image.path):
                        os.remove(answer.image.path)
            answers.delete()
            room_upload_folder = os.path.join(settings.MEDIA_ROOT, 'answers', room.code)
            if os.path.exists(room_upload_folder) and not os.listdir(str(room_upload_folder)):
                shutil.rmtree(room_upload_folder)

            return Response({'message': 'Game has ended and answers have been cleared.'}, status=status.HTTP_200_OK)

        else:
            return Response({'error': "Invalid action. Use 'start' or 'end'."}, status=status.HTTP_400_BAD_REQUEST)