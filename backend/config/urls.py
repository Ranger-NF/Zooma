

from django.contrib import admin
from django.urls import path, include
from django.conf.urls.static import static
import settings

urlpatterns = [
    path("admin/", admin.site.urls),
    path('api/player/', include('player.urls'))
]

# Serve media files during development
if settings.DEBUG:
    urlpatterns += static(settings.MEDIA_URL, document_root=settings.MEDIA_ROOT)