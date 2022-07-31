from urllib.parse import urlparse
from uuid import uuid4
from logger import log

from masonite.controllers import Controller
from masonite.request import Request
from masonite.response import Response
from masonite.views import View
from masoniteorm.query import QueryBuilder

from app.models.Domain import Domain
from app.models.Report import Report


class ReportController(Controller):
    def filter_domain(self, request: Request, response: Response):
        domain = request.input("domain", None)
        if domain:
            request.session.set("filter_domain", domain)
        else:
            if request.session.has("filter_domain"):
                request.session.delete("filter_domain")
        return response.redirect(request.header("Referer"))

    def show(self, request: Request, view: View):
        page = request.input("page", 1)
        domain_list = Domain.all()
        builder = QueryBuilder().table("reports")

        if request.session.has("filter_domain"):
            domain_filter = request.session.get("filter_domain")
        else:
            domain_filter = None

        if domain_filter:
            builder.where("domain", request.session.get("filter_domain"))

        reports = builder.simple_paginate(50, page)

        paged_reports = {
            "domain_filter": domain_filter,
            "domains": domain_list,
            "page": int(page),
            "reports": reports,
        }
        return view.render("home", paged_reports)

    def save(self, request: Request, response: Response):
        csp_report = request.input("csp-report")
        if csp_report and all(
            key in csp_report
            for key in (
                "document-uri",
                "referrer",
                "violated-directive",
                "original-policy",
                "blocked-uri",
            )
        ):
            domain = urlparse(csp_report["document-uri"]).netloc
            Report.create(
                id=str(uuid4()),
                domain=domain,
                document_uri=csp_report["document-uri"],
                referrer=csp_report["referrer"],
                violated_directive=csp_report["violated-directive"],
                original_policy=csp_report["original-policy"],
                blocked_uri=csp_report["blocked-uri"],
            )
            log.info("csp violation against: %s" % domain)
            domain_exists = Domain.where("name", domain).first()
            if not domain_exists:
                Domain.create(id=str(uuid4()), name=domain)
        else:
            return response.status(405)

        return response.status(200)
