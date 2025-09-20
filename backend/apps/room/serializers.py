from rest_framework import serializers
from .models import Room
from apps.player.serializers import PlayerSerializer

class RoomSerializer(serializers.ModelSerializer):
    mentor = PlayerSerializer(read_only=True)
    players = PlayerSerializer(many=True, read_only=True)
    mentor_id = serializers.UUIDField(write_only=True)

    class Meta:
        model = Room
        fields = [
            'code',
            'mentor',
            'mentor_id',
            'players',
            'max_players',
            'num_questions',
            'is_active',
            'created_at'
        ]
        read_only_fields = ['code', 'is_active', 'created_at', 'mentor', 'players']

    def validate_mentor_id(self, value):
        from ..player.models import Player
        if not Player.objects.filter(id=value).exists():
            raise serializers.ValidationError("Player with this ID does not exist.")
        return value