from tests import TestCase
from app.controllers.LangController import LangController

from unittest.mock import Mock


class LangControllerTest(TestCase):
    def test_switch(self):
        controller = LangController()
        request = Mock()
        request.param = Mock(return_value="en")
        request.header = Mock(return_value="http://localhost/")
        response = Mock()
        response.redirect = Mock()
        controller.switch(request, response)
        response.redirect.assert_called_once()
        response.redirect.assert_called_with("http://localhost/")
        request.param.assert_called_once()
