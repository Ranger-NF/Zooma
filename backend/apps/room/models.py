from django.core.validators import MaxValueValidator, MinValueValidator
from django.db import models
from ..core.utils import generate_room_code
from ..player.models import Player
from ..question.models import Question


class Room(models.Model):

    code = models.CharField(max_length=6, unique=True, default=generate_room_code)
    mentor = models.ForeignKey(Player, on_delete=models.CASCADE, related_name="mentored_room")
    players = models.ManyToManyField(Player, related_name="players")
    questions = models.ManyToManyField(Question, related_name="rooms", help_text="Randomly selected questions for this room")
    max_players = models.IntegerField(
        validators=[
            MaxValueValidator(50),
            MinValueValidator(3)
        ]
    )
    num_questions = models.IntegerField(
        default=5,
        validators=[
            MaxValueValidator(10),
            MinValueValidator(5)
        ]
    )
    is_active = models.BooleanField(default=False, help_text="Mentor starts/stops the game")
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return f"Room {self.code} - Mentor: {self.mentor.username}"