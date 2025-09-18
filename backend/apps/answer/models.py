from django.db import models
from apps.player.models import Player
from apps.question.models import Question
from apps.room.models import Room
# Create your models here.

def answer_image_path(instance, filename):
    return f'answers/{instance.room.code}/{instance.player.id}/{filename}'

class Answer(models.Model):
    player = models.ForeignKey(Player, on_delete=models.CASCADE)
    question = models.ForeignKey(Question, on_delete=models.CASCADE)
    room = models.ForeignKey(Room, on_delete=models.CASCADE)
    image = models.ImageField(upload_to=answer_image_path)
    score = models.IntegerField(default=0)
    submitted_at = models.DateTimeField(auto_now_add=True)

    # class Meta:
    #     unique_together = ('player', 'question', 'room')

    def __str__(self):
        return f"{self.player.username}'s answer to Q{self.question.id} in Room {self.room.code}"
