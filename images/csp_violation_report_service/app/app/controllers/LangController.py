from masonite.controllers import Controller
from masonite.request import Request
from masonite.response import Response


class LangController(Controller):
    def switch(self, request: Request, response: Response):
        lang = request.param("lang")
        request.session.set("lang", lang)
        return response.redirect(request.header("Referer"))
