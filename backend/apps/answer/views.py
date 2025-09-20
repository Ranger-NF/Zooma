from apps.player.models import Player
from rest_framework import views, generics, status
from rest_framework.response import Response
from .serializers import LeaderboardSerializer
from apps.answer.models import Answer
from apps.answer.serializers import AnswerSerializer
from apps.room.models import Room
from django.db.models import Count, Q

class AnswerCreateAPIView(generics.CreateAPIView):

    queryset = Answer.objects.all()
    serializer_class = AnswerSerializer

    def create(self, request, *args, **kwargs):
        room_code = request.data.get("room_code")
        try:
            room = Room.objects.get(code__iexact=room_code)
            if not room.is_active:
                return Response({'error': 'This game is not currently active.'}, status=status.HTTP_400_BAD_REQUEST)
        except Room.DoesNotExist:
            return Response({'error': 'Room not found.'}, status=status.HTTP_404_NOT_FOUND)

        mutable_data = request.data.copy()
        mutable_data['room'] = room.pk

        serializer = self.get_serializer(data=mutable_data)
        serializer.is_valid(raise_exception=True)
        self.perform_create(serializer)
        headers = self.get_success_headers(serializer.data)
        return Response(serializer.data, status=status.HTTP_201_CREATED, headers=headers)

class MentorDashboardAPIView(views.APIView):
    def get(self, request, *args, **kwargs):
        room_code = request.query_params.get('room_code')
        mentor_id = request.query_params.get('mentor_id')

        try:
            room = Room.objects.get(code__iexact=room_code, mentor__id=mentor_id)
        except Room.DoesNotExist:
            return Response({'error': 'Room not found or you are not the mentor.'},
                            status=status.HTTP_403_FORBIDDEN)

        answers = Answer.objects.filter(room=room).order_by('player__username', 'question__id')
        serializer = AnswerSerializer(answers, many=True, context={'request': request})
        return Response(serializer.data)

class EvaluateAnswerAPIView(views.APIView):

    def patch(self, request, *args, **kwargs):
        answer_id = request.data.get('answer_id')
        mentor_id = request.data.get('mentor_id')

        score = request.data.get('score')

        if score is None:
            return Response({'error': 'Score is required.'}, status=status.HTTP_400_BAD_REQUEST)
        try:
            answer = Answer.objects.select_related('room__mentor').get(id=answer_id)
            if str(answer.room.mentor.id) != str(mentor_id):
                return Response({'error': 'You are not the mentor of this room.'}, status=status.HTTP_403_FORBIDDEN)
            answer.score = int(score)
            answer.save()
            serializer = AnswerSerializer(answer)
            return Response(serializer.data)
        except Answer.DoesNotExist:
            return Response({'error': 'Answer not found.'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': str(e)}, status=status.HTTP_400_BAD_REQUEST)


class LeaderboardAPIView(views.APIView):
    def get(self, request, *args, **kwargs):
        room_code = request.query_params.get('room_code')
        try:
            room = Room.objects.get(code__iexact=room_code)
        except Room.DoesNotExist:
            return Response({'error': 'Room not found.'}, status=status.HTTP_404_NOT_FOUND)

        players_with_scores = room.players.annotate(
            validated_answers_count=Count(
                'answer',
                filter=Q(answer__room=room) & Q(answer__score__gt=0)
            )
        ).order_by('-validated_answers_count')

        serializer = LeaderboardSerializer(players_with_scores, many=True)
        return Response(serializer.data)
