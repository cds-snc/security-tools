from masonite.environment import env


KEY = env("APP_KEY", None)

DEBUG = env("APP_DEBUG", True)

HASHING = {
    "default": env("HASHING_FUNCTION", "bcrypt"),
    "bcrypt": {"rounds": 10},
    "argon2": {"memory": 1024, "threads": 2, "time": 2},
}

APP_URL = env("APP_URL", "http://localhost:8000/")
