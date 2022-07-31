from masonite.routes import Route

ROUTES = [
    Route.get("/", "ReportController@show").name("show"),
    Route.post("/", "ReportController@save").name("save"),
    Route.post("/filter/domain", "ReportController@filter_domain").name("filter_domain"),
    Route.get("/healthcheck", "HealthController@show").name("healthcheck"),
    Route.get("/lang/@lang", "LangController@switch").name("language_switcher"),
]
