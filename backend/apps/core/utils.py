import string
import random
from ..room.models import Room

def generate_room_code():
    length = 6
    while True:
        code = ''.join(random.choices(string.ascii_uppercase+string.digits, k=length))
        if not Room.objects.filter(code=code).exists():
            return code

