from masonite.foundation import Application, Kernel
from masonite.utils.location import base_path
from masonite.configuration import config

from apig_wsgi import make_lambda_handler
from Kernel import Kernel as ApplicationKernel

"""Start The Application Instance."""
application = Application(base_path())

"""Now Bind important providers needed to make the framework work."""
application.register_providers(Kernel, ApplicationKernel)

"""Now Bind important application specific providers needed to make the application work."""
application.add_providers(*config("providers.providers"))

apig_wsgi_handler = make_lambda_handler(application, binary_support=True)


def handler(event, context):
    return apig_wsgi_handler(event, context)
