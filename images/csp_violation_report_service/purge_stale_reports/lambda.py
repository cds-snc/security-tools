"""
Lambda that will delete old csp-reports
"""

import os
import psycopg2
from aws_lambda_powertools import Logger

log = Logger()

hostname = os.environ["DB_HOST"]
username = os.environ["DB_USERNAME"]
password = os.environ["DB_PASSWORD"]
database = os.environ["DB_DATABASE"]
port = os.getenv("DB_PORT", 5432)

max_report_age_days = os.getenv("MAX_REPORT_AGE_DAYS", 90)


def doPurgeReports(conn):
    log.info("Cleaning up reports older than %s" % max_report_age_days)
    cur = conn.cursor()
    try:
        cur.execute(
            "PREPARE purgeplan AS "
            "DELETE FROM reports WHERE created_at < NOW() - INTERVAL '1 day' * $1"
        )
        cur.execute("EXECUTE purgeplan (%s)", [max_report_age_days])
    except Exception as e:
        log.error(e)


def doCleanupDomains(conn):
    log.info("Removing domains that no longer have reports")
    cur = conn.cursor()
    try:
        cur.execute(
            "DELETE FROM domains d WHERE NOT EXISTS (SELECT FROM reports r WHERE r.domain = d.name);"
        )
    except Exception as e:
        log.error(e)


def handler(event, context):
    try:
        connection = psycopg2.connect(
            host=hostname, user=username, password=password, dbname=database, port=port
        )
        connection.autocommit = True
    except Exception as e:
        log.error("Failed to connect to database: %s" % str(e))

    doPurgeReports(connection)
    doCleanupDomains(connection)

    connection.close()
    return True
