from django.db import models
from ..core.utils import generate_room_code
from ..player.models import Player
from ..question.models import Question


class Room(models.Model):
    MAX_PLAYER_CHOICES = [
        (5, '5 Players'),
        (6, '6 Players'),
        (7, '7 Players')
    ]

    NUM_QUESTIONS_CHOICES = [
        (5, '5 Questions'),
        (6, '6 Questions'),
        (7, '7 Questions'),
    ]

    code = models.CharField(max_length=6, unique=True, default=generate_room_code)
    mentor = models.ForeignKey(Player, on_delete=models.CASCADE, related_name="mentored_room")
    players = models.ManyToManyField(Player, related_name="players")
    questions = models.ManyToManyField(Question, related_name="rooms", help_text="Randomly selected questions for this room")
    max_players = models.IntegerField(choices=MAX_PLAYER_CHOICES)
    num_questions = models.IntegerField(choices=NUM_QUESTIONS_CHOICES, default=5)
    is_active = models.BooleanField(default=False, help_text="Mentor starts/stops the game")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Room {self.code} - Mentor: {self.mentor.username}"