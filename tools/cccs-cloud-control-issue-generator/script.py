"""
The purpose of this script is to take a CSV file with the CCCS Cloud Control Profile controls and create issues in github for each control.
The script will create the issue title, body, and labels. The body will have the control definition, class, supplemental guidance,
 references, general guide, suggested placeholder values, profile specific notes, suggested assignment, and support teams.
"""

import csv
import requests
import os
import string
import logging
import json
from enum import Enum

"""
env vars:
REPO = owner/repo
GITHUB_TOKEN = github token to create issues
CSV_FILE = path to csv file
LOG_LEVEL = If exists, set logging level to this. Otherwise, set to INFO
"""
REPO = os.getenv("REPO")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
CSV_FILE = os.getenv("CSV_FILE", "annex-b-cccs-medium-cloud-profile.csv")
SELECTED_CONTROLS_FILE = os.getenv("SELECTED_CONTROLS_FILE", "selected-system-level-controls.json")
LOG_LEVEL = os.getenv("LOG_LEVEL", logging.INFO)
CONTROL_PROFILE_TYPE = ""


class Header(Enum):
    CONTROL_ID = 0
    CONTROL_NAME = 1
    CONTROL_CLASS = 2
    CONTROL_TITLE = 3
    CONTROL_DEFINITION = 4
    SUPPLEMENTAL_GUIDANCE = 5
    CCCS_MEDIUM_PROFILE_FOR_CLOUD = 6
    CSP_FULL_STACK = 7
    CSP_STACKED_PAAS = 8
    CSP_STACKED_SAAS = 9
    CLIENT_IAAS_PAAS = 10
    CLIENT_SAAS = 11


"""
Set logging level
"""
logging.basicConfig(
    level=LOG_LEVEL,
    format="%(asctime)s :%(levelname)s:%(funcName)s:%(lineno)d %(message)s",
    datefmt="%d-%b-%y %H:%M:%S",
)


def main():
    """
    Program entrypoint to create issues in github for each control in CCCS control profile.
    """
    selected_controls = get_selected_controls(SELECTED_CONTROLS_FILE)

    for control in get_controls(CSV_FILE):
        control_id = get_control_id(control)
        if control_id in selected_controls.keys():
            issues_url = get_issues_url()
            headers = get_header()
            issues_json = get_issues_json(control, selected_controls[control_id])

            response = post_request(issues_url, headers, issues_json)

            logging.debug("Issues URL: {}".format(issues_url))
            logging.debug("Issues JSON: {}".format(issues_json))
            logging.debug("Response: {}".format(response.text))
            logging.debug("Headers: {}".format(headers))


def post_request(issues_url, headers, issues_json):
    """
    Post request to github api to create issue. If successful, print the control title.
    If not, print the control title and the response. Return the response.
    """
    response = requests.post(issues_url, headers=headers, json=issues_json, timeout=5)
    if response.status_code == 201:
        logging.info("Created issue for control: {}".format(issues_json["title"]))
    else:
        logging.error(
            "Failed to create issue for control: {}".format(issues_json["title"])
        )
        logging.error("Response: {}".format(response.text))
    return response


def get_github_token():
    """
    Get github token from env var
    """
    if GITHUB_TOKEN:
        return GITHUB_TOKEN
    else:
        raise Exception("GITHUB_TOKEN env var not set")


def get_repo():
    """
    Get repo from env var
    """
    if REPO:
        return REPO
    else:
        raise Exception("REPO env var not set")


def get_issues_url():
    """
    Get github issues url
    """
    return "https://api.github.com/repos/{}/issues".format(get_repo())


def get_header():
    """
    Get header for github api
    """
    header = {
        "Accept": "application/vnd.github+json",
        "Authorization": "Bearer {}".format(get_github_token()),
        "X-GitHub-Api-Version": "2022-11-28",
    }
    return header


def get_issues_json(row, supplementary_labels):
    """
    Get issues json to have the required and relevant fields
    """
    title = get_title(row)
    body = get_body(row)
    labels = get_labels(row)
    if supplementary_labels:
        labels.extend(supplementary_labels)

    return {"title": title, "body": body, "labels": labels}


def get_body(row):
    """
    Get body for issue. Has at least the control definition.
    """
    body = "# Control Definition\n{}\n\n".format(row[Header.CONTROL_DEFINITION.value])
    if row[Header.CONTROL_CLASS.value]:
        body += "# Class\n{}\n\n".format(row[Header.CONTROL_CLASS.value])
    if row[Header.SUPPLEMENTAL_GUIDANCE.value]:
        body += "# Supplemental Guidance\n{}\n\n".format(
            row[Header.SUPPLEMENTAL_GUIDANCE.value]
        )

    return body


def get_labels(row):
    """
    Get labels for issue to help future retrieval
    """
    labels = []
    labels.append(
        "Control: {}".format(get_control_id(row))
    )
    if row[Header.CONTROL_CLASS.value]:
        labels.append("Class: {}".format(row[Header.CONTROL_CLASS.value].strip()))

    labels.append(CONTROL_PROFILE_TYPE)

    if row[Header.CLIENT_IAAS_PAAS.value].strip() == "X":
        labels.append("IaaS/PaaS")
    if row[Header.CLIENT_SAAS.value].strip() == "X":
        labels.append("SaaS")

    return labels


def get_title(row):
    """
    Get title for issue. The logic required is encapsulated in this function. Some controls have enhancements, and if they do,
    the title should be formatted to show such info.
    """
    title = "{}: {}".format(
        get_control_id(row),
        string.capwords(row[Header.CONTROL_TITLE.value]),
    )

    return title


def set_control_profile_type(row):
    global CONTROL_PROFILE_TYPE

    for col in row:
        if "Medium Profile" in col:
            CONTROL_PROFILE_TYPE = "CCCS Medium"
        elif "Low Profile" in col:
            CONTROL_PROFILE_TYPE = "CCCS Low"


def get_control_id(row):
    return row[Header.CONTROL_ID.value].strip()


def likely_header(row):
    if not row[Header.CONTROL_DEFINITION.value]:
        return True
    elif row[Header.CONTROL_ID.value] == "ID":
        return True

    return False


def get_controls(control_file):
    """
    Get controls from CCCS Control Profile csv file.
    """
    with open(control_file, "r", newline='') as csvfile:
        logging.info("opened baseline control file: {}".format(control_file))
        csvreader = csv.reader(csvfile)

        for row in csvreader:
            if likely_header(row):
                set_control_profile_type(row)
            else:
                yield row


def get_selected_controls(selected_control_file):
    with open(selected_control_file, 'r') as f:
        logging.info("opened selected control file: {}".format(selected_control_file))
        data = json.load(f)
        return data


if __name__ == "__main__":
    main()
