from django.db import models
from ..core.utils import generate_room_code
from ..player.models import Player

class Room(models.Model):
    MAX_PLAYER_CHOICES = [
        (5, '5 Players'),
        (6, '6 Players'),
        (7, '7 Players')
    ]

    code = models.CharField(max_length=6, unique=True, default=generate_room_code)
    mentor = models.ForeignKey(Player, on_delete=models.CASCADE, related_name="mentored_room")
    players = models.ManyToManyField(Player, related_name="players")
    max_players = models.IntegerField(choices=MAX_PLAYER_CHOICES)
    is_active = models.BooleanField(default=False, help_text="Mentor starts/stops the game")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Room {self.code} - Mentor: {self.mentor.username}"