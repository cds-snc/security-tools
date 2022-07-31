""" Domain Model """

from masoniteorm.models import Model


class Domain(Model):
    """Domain Model"""

    __fillable__ = ["id", "name"]
