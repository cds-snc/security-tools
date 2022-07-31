from tests import TestCase
from app.controllers.HealthController import HealthController

from unittest.mock import Mock


class HealthControllerTest(TestCase):
    def test_show(self):
        controller = HealthController()
        response = Mock()
        controller.show(response)
        response.json.assert_called_once()
        response.json.assert_called_with({"status": "ok", "sha": "git_sha"})
