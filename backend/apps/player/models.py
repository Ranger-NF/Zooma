from django.db import models
# Create your models here.

class Player(models.Model):
    username = models.CharField(max_length=40)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.username