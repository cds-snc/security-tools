from masonite.tests import TestCase, DatabaseTransactions
from app.models.Report import Report

from unittest.mock import Mock, patch
from uuid import uuid4


class ReportTest(TestCase, DatabaseTransactions):

    connection = "testing"

    def test_create_report(self):
        report = Report.create(
            id=str(uuid4()),
            domain="domain",
            document_uri="document_uri",
            referrer="referrer",
            violated_directive="violated_directive",
            original_policy="original_policy",
            blocked_uri="blocked_uri",
        )
        report.save()
