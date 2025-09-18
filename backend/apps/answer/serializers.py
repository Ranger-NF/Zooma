from rest_framework import serializers
from .models import Player, Answer


class AnswerSerializer(serializers.ModelSerializer):
    player_username = serializers.CharField(source='player.username', read_only=True)
    question_text = serializers.CharField(source='question.text', read_only=True)

    class Meta:
        model = Answer
        fields = ['id', 'player', 'player_username', 'question', 'question_text', 'room', 'image', 'score','submitted_at']
        read_only_fields = ['id', 'score', 'submitted_at', 'player_username', 'question_text']


class LeaderboardSerializer(serializers.ModelSerializer):
    total_score = serializers.IntegerField()

    class Meta:
        model = Player
        fields = ['id', 'username', 'total_score']