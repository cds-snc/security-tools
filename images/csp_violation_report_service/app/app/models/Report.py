""" Report Model """

from masoniteorm.models import Model


class Report(Model):
    """Report Model"""

    __fillable__ = [
        "id",
        "domain",
        "document_uri",
        "referrer",
        "violated_directive",
        "original_policy",
        "blocked_uri",
    ]
