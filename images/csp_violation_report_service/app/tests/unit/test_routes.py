from tests import TestCase


class Routes(TestCase):
    def test_routes(self):
        self.get("/").assertIsStatus(200)
        self.post("/filter/domain").assertIsStatus(302)
