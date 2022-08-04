from masonite.providers import (
    RouteProvider,
    FrameworkProvider,
    ViewProvider,
    WhitenoiseProvider,
    ExceptionProvider,
    SessionProvider,
    QueueProvider,
    CacheProvider,
    EventProvider,
    StorageProvider,
    HelpersProvider,
    BroadcastProvider,
    AuthenticationProvider,
    AuthorizationProvider,
    HashServiceProvider,
    ORMProvider,
)


from masonite.scheduling.providers import ScheduleProvider
from masonite.notification.providers import NotificationProvider
from masonite.validation.providers import ValidationProvider

from app.providers import AppProvider

PROVIDERS = [
    FrameworkProvider,
    HelpersProvider,
    RouteProvider,
    ViewProvider,
    WhitenoiseProvider,
    ExceptionProvider,
    NotificationProvider,
    SessionProvider,
    CacheProvider,
    QueueProvider,
    ScheduleProvider,
    EventProvider,
    StorageProvider,
    BroadcastProvider,
    HashServiceProvider,
    AuthenticationProvider,
    ValidationProvider,
    AuthorizationProvider,
    ORMProvider,
    AppProvider,
]
