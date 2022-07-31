from masonite.controllers import Controller
from masonite.environment import env
from masonite.views import View
from masonite.response import Response


class HealthController(Controller):
    def show(self, response: Response):
        return response.json({"status": "ok", "sha": env("GIT_SHA")})
