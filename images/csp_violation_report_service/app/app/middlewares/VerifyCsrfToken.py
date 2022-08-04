from masonite.middleware import VerifyCsrfToken as Middleware


class VerifyCsrfToken(Middleware):

    exempt = ["/report","/filter/domain"]
