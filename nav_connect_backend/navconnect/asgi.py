import os
import django
from channels.routing import ProtocolTypeRouter, URLRouter
from channels.auth import AuthMiddlewareStack
from django.core.asgi import get_asgi_application
from api.routing import ws_urlpatterns
from espgps.routing import websocket_urlpatterns

os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'navconnect.settings')

# Initialize Django ASGI application first
django.setup()
asgi_app = get_asgi_application()

application = ProtocolTypeRouter({
    'http': asgi_app,
    "websocket": AuthMiddlewareStack(
        URLRouter(
            ws_urlpatterns + websocket_urlpatterns
        )
    )
})

app = application
