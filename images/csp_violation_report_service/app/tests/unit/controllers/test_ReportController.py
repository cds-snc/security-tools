import json
from tests import TestCase
from app.controllers.ReportController import ReportController

from unittest.mock import ANY, MagicMock, patch


class ReportControllerTest(TestCase):
    @patch("app.controllers.ReportController.Report")
    @patch("app.controllers.ReportController.Domain")
    def test_save(self, mock_domain, mock_report):
        controller = ReportController()
        request = MagicMock()
        request.input.return_value = {
            "document-uri": "https://example.com/foo/bar",
            "referrer": "https://www.google.com/",
            "violated-directive": "default-src self",
            "original-policy": "default-src self; report-uri /csp-hotline.php",
            "blocked-uri": "http://evilhackerscripts.com",
        }
        response = MagicMock()
        mock_domain.where().first.return_value = None
        controller.save(request, response)
        mock_report.create.assert_called_with(
            id=ANY,
            domain="example.com",
            document_uri="https://example.com/foo/bar",
            referrer="https://www.google.com/",
            violated_directive="default-src self",
            original_policy="default-src self; report-uri /csp-hotline.php",
            blocked_uri="http://evilhackerscripts.com",
        )
        mock_domain.create.assert_called_with(id=ANY, name="example.com")
        response.status.assert_called_with(200)

    @patch("app.controllers.ReportController.Report")
    @patch("app.controllers.ReportController.Domain")
    def test_save_domain_exists(self, mock_domain, mock_report):
        controller = ReportController()
        request = MagicMock()
        request.input.return_value = {
            "document-uri": "https://example.com/foo/bar",
            "referrer": "https://www.google.com/",
            "violated-directive": "default-src self",
            "original-policy": "default-src self; report-uri /csp-hotline.php",
            "blocked-uri": "http://evilhackerscripts.com",
        }
        response = MagicMock()
        mock_domain.where().first.return_value = "example.com"
        controller.save(request, response)
        mock_report.create.assert_called_with(
            id=ANY,
            domain="example.com",
            document_uri="https://example.com/foo/bar",
            referrer="https://www.google.com/",
            violated_directive="default-src self",
            original_policy="default-src self; report-uri /csp-hotline.php",
            blocked_uri="http://evilhackerscripts.com",
        )
        mock_domain.create.assert_not_called()
        response.status.assert_called_with(200)

    @patch("app.controllers.ReportController.Report")
    @patch("app.controllers.ReportController.Domain")
    def test_save_invalid_csp_report_format(self, mock_domain, mock_report):
        controller = ReportController()
        request = MagicMock()
        request.input.return_value = {"foo": "bar"}
        response = MagicMock()
        controller.save(request, response)
        mock_report.create.assert_not_called()
        mock_domain.create.assert_not_called()
        response.status.assert_called_with(405)

    @patch("app.controllers.ReportController.Report")
    @patch("app.controllers.ReportController.Domain")
    def test_save_invalid_csp_report_format_not_dict(self, mock_domain, mock_report):
        controller = ReportController()
        request = MagicMock()
        request.input.return_value = "foo"
        response = MagicMock()
        controller.save(request, response)
        mock_report.create.assert_not_called()
        mock_domain.create.assert_not_called()
        response.status.assert_called_with(405)

    def test_show(self):
        with patch("app.controllers.ReportController.Domain") as mock_domain:
            controller = ReportController()
            request = MagicMock()
            request.session.get = MagicMock(return_value="")
            request.input.return_value = 1
            mock_domain.all = MagicMock(return_value=["www.example.com"])
            with patch("app.controllers.ReportController.QueryBuilder") as query_builder:
                query_builder().table().simple_paginate = MagicMock(return_value=["foo", "bar"])
                view = MagicMock()
                controller.show(request, view)
                view.render.assert_called_once()
                view.render.assert_called_with(
                    "home",
                    {
                        "domain_filter": "",
                        "domains": ["www.example.com"],
                        "page": 1,
                        "reports": ["foo", "bar"],
                    },
                )

    def test_show_with_domain_filter(self):
        with patch("app.controllers.ReportController.Domain") as mock_domain:
            controller = ReportController()
            request = MagicMock()
            request.session.get = MagicMock(return_value="www.example.com")
            request.input.return_value = 1
            mock_domain.all = MagicMock(return_value=["www.example.com"])
            with patch("app.controllers.ReportController.QueryBuilder") as query_builder:
                query_builder().table().simple_paginate = MagicMock(return_value=["foo", "bar"])
                view = MagicMock()
                controller.show(request, view)
                view.render.assert_called_once()
                view.render.assert_called_with(
                    "home",
                    {
                        "domain_filter": "www.example.com",
                        "domains": ["www.example.com"],
                        "page": 1,
                        "reports": ["foo", "bar"],
                    },
                )

    def test_filter_domain(self):
        controller = ReportController()
        request = MagicMock()
        request.input.return_value = "www.example.com"
        request.header.return_value = "https://www.foo.com"
        response = MagicMock()
        controller.filter_domain(request, response)
        request.session.set.assert_called_with("filter_domain", "www.example.com")
        response.redirect.assert_called_with("https://www.foo.com")

    def test_filter_domain_reset(self):
        controller = ReportController()
        request = MagicMock()
        request.input.return_value = None
        request.header.return_value = "https://www.foo.com"
        request.session.has.return_value = True
        response = MagicMock()
        controller.filter_domain(request, response)
        request.session.set.assert_not_called()
        request.session.delete.assert_called_with("filter_domain")
        response.redirect.assert_called_with("https://www.foo.com")
