import uuid
from django.db import models

class Player(models.Model):
    id = models.UUIDField(primary_key=True, default=uuid.uuid4, editable=False)
    username = models.CharField(max_length=40, unique=True)
    created_at = models.DateTimeField(auto_now_add=True)

    def __str__(self):
        return self.username