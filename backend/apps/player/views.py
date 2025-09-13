from rest_framework import generics, status
from .models import Player
from .serializers import PlayerSerializer
from rest_framework.response import Response


class PlayerCreateAPIView(generics.CreateAPIView):

    queryset = Player.objects.all()
    serializer_class = PlayerSerializer

    def create(self, request, *args, **kwargs):
        username = request.data.get('username')
        if not username:
            return Response({'error': 'Username is Required'}, status = status.HTTP_400_BAD_REQUEST)
        player, created = Player.objects.get_or_create(username=username)
        serializer = self.get_serializer(player)

        status_code = status.HTTP_201_CREATED if created else status.HTTP_200_OK

        return Response(serializer.data, status=status_code )