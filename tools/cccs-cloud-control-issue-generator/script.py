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
import re
from enum import Enum
from io import StringIO
from pathlib import Path

"""
globals
"""
CONTROL_PROFILE_TYPE = ""
CONTROLS_FILTER_ORG = "ORGANIZATION"
CONTROLS_FILTER_SYS = "SYSTEM"

"""
env vars:
REPO = owner/repo
GITHUB_TOKEN = github token to create issues
CSV_FILE = path to csv file
CONTROLS_FILTER = SYSTEM (default) or ORGANIZATION
CONTROLS_OVERRIDE = CSV separated list of controls. If exists, only the specified controls will be added.
LOG_LEVEL = If exists, set logging level to this. Otherwise, set to INFO
"""
REPO = os.getenv("REPO")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
CSV_FILE = os.getenv("CSV_FILE")
CONTROLS_FILTER = os.getenv("CONTROLS_FILTER", CONTROLS_FILTER_SYS)
CONTROLS_OVERRIDE = os.getenv("CONTROLS_OVERRIDE")
LOG_LEVEL = os.getenv("LOG_LEVEL", logging.INFO)


"""
Long Security Control Family Description
"""
LONG_CONTROL_FAMILY = {
    "AC" : "Access Control (AC)",
    "AT" : "Security Awareness and Training (AT)",
    "AU" : "Audit and Accountability (AU)",
    "CA" : "Security Assessment and Authorization (CA)",
    "CM" : "Configuration Management (CM)",
    "CP" : "Contingency Planning (CP)",
    "IA" : "Identification and Authentication (IA)",
    "IR" : "Incident Response (IR)",
    "MA" : "System Management (MA)",
    "MP" : "Media Protection (MP)",
    "PE" : "Physical and Environment (PE)",
    "PL" : "Security Planning (PL)",
    "PS" : "Personnel Security (PS)",
    "RA" : "Risk Assessment (RA)",
    "SA" : "System and Services Acquisition (SA)",
    "SC" : "System and Communications Protection (SC)",
    "SI" : "System and Information Integrity (SI)"
}


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
    CDS_SUPP_ATTR_ORG_LEVEL_CTL = 12
    CDS_SUPP_ATTR_SYS_LEVEL_CTR = 13
    CDS_SUPP_ATTR_PRIORITY = 14


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
    if CONTROLS_OVERRIDE:
        ctls_override = CONTROLS_OVERRIDE.split(",")
        logging.info("Only creating issues for controls in CONTROLS_OVERRIDE: {}".format(ctls_override))

    for control in get_controls(get_csv_file()):
        if ctls_override:
            if control not in ctls_override:
                continue
        else:
            # apply selected controls filter: ORG/SYS
            if CONTROLS_FILTER.upper() == CONTROLS_FILTER_SYS:
                if not is_attribute_set(control, Header.CDS_SUPP_ATTR_SYS_LEVEL_CTR.value):
                    continue
            elif CONTROLS_FILTER.upper() == CONTROLS_FILTER_ORG:
                if not is_attribute_set(control, Header.CDS_SUPP_ATTR_SYS_LEVEL_CTR.value):
                    continue

        issues_url = get_issues_url()
        headers = get_header()
        issues_json = get_issues_json(control)

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


def get_csv_file():
    """
    Get repo from env var
    """
    if CSV_FILE:
        return CSV_FILE
    else:
        raise Exception("CSV_FILE env var not set")


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


def get_issues_json(row):
    """
    Get issues json to have the required and relevant fields
    """
    title = get_title(row)
    body = get_body(row)
    labels = get_labels(row)

    return {"title": title, "body": body, "labels": labels}


def get_control_definition_group(control_definition):
    ctl_grp = ""
    sio = StringIO(control_definition)
    pos = sio.tell()

    for line in sio:
        # ignore empty lines, lines with |
        match_empty = re.match(r"^\s*$", line)
        match_pipe = re.match(r".*\|.*$", line)
        if match_empty or match_pipe:
            continue

        # collect main control and sub-controls
        # - match main control, then
        # - match sub-control: (a) def
        if not ctl_grp:
            match_ctl_not_enum = re.match(r"[a-zA-Z0-9]+", line)
            match_ctl = re.match(r"\([A-Z]\).*", line)
            if match_ctl_not_enum or match_ctl:
                logging.debug("found main control: {}".format(line))
                ctl_grp = line.strip()
                pos = sio.tell()
                continue
        else:
            match_sub_ctl = re.match(r"\([a-z]\).*", line)
            if match_sub_ctl:
                logging.debug("found sub control: {}".format(line))
                ctl_grp += " {}".format(line.rstrip())
                continue
            else:
                # no sub-controls, reset stream position
                sio.seek(pos)

        if ctl_grp:
            yield ctl_grp
            ctl_grp = ""

    if ctl_grp:
        yield ctl_grp


def get_body(row):
    """
    Get body for issue: Control definition and Control management
    """
    body = "# Control Definition\n{}\n\n".format(row[Header.CONTROL_DEFINITION.value])
    if row[Header.CONTROL_CLASS.value]:
        body += "## Class\n{}\n\n".format(row[Header.CONTROL_CLASS.value])
    if row[Header.SUPPLEMENTAL_GUIDANCE.value]:
        body += "## Supplemental Guidance\n{}\n\n".format(
            row[Header.SUPPLEMENTAL_GUIDANCE.value]
        )

    body += "# Control Management\n"
    body += "## Assignment\n"
    body += "Responsible Principals:[^1] \n"
    body += "- _TBD: CDS Teams_\n"

    body += "## Risk Assessment\n"
    body += "| Impact Rating[^2] &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; "
    body += "&nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp; |"
    body += " Impact Description for a Realized Risk Event |\n"
    body += "| --- | --- |\n"
    body += "| <ul><li>[ ] Catastrophic</li></ul> "
    body += "|<ul><li><kbd>Confidentiality: **Complete** loss of confidentiality of **critical** data or systems, "
    body += "which could result in unauthorized access to **sensitive** information.</kbd></li>"
    body += "<li><kbd>Integrity: **Complete** loss of data or systems, which could result in data corruption, "
    body += "alteration or destruction of data, or manipulation of **critical** systems.</kbd></li>"
    body += "<li><kbd>Availability: **Complete** system failure, which could result in **extended** downtime, "
    body += "loss of access to **critical** systems, or **inability** to perform **critical** business functions.</kbd></li></ul> |\n"
    body += "| <ul><li>[ ] Critical</li></ul> "
    body += "|<ul><li><kbd>Confidentiality: **Partial** loss of confidentiality of **important** data or systems, "
    body += "which could result in unauthorized access to **sensitive** information.</kbd></li>"
    body += "<li><kbd>Integrity: **Partial** loss of data or systems, which could result in data corruption, "
    body += "alteration, or destruction of data, or manipulation of **important** systems.</kbd></li>"
    body += "<li><kbd>Availability: **Partial** system failure, which could result in **temporary** downtime, "
    body += "loss of access to **important** systems, or **reduced ability** to perform **critical** business functions.</kbd></li></ul> |\n"
    body += "| <ul><li>[ ] Marginal</li></ul> "
    body += "|<ul><li><kbd>Confidentiality: **Minor** loss of confidentiality of **non-critical** data or systems, "
    body += "which could result in unauthorized access to **less-sensitive** information.</kbd></li>"
    body += "<li><kbd>Integrity: **Minor** loss of data or systems, which could result in data corruption, "
    body += "alteration, or destruction of **non-critical** data, or manipulation of **non-critical** systems.</kbd></li>"
    body += "<li><kbd>Availability: **Minor** system disruption or degradation, "
    body += "which could result in **reduced** performance or access to **non-critical** systems.</kbd></li></ul> |\n"
    body += "| <ul><li>[ ] Negligible</li></ul> "
    body += "|<ul><li><kbd>Confidentiality: Little to no impact on confidentiality of data or systems.</kbd></li>"
    body += "<li><kbd>Integrity: Little to no impact on integrity of data or systems.</kbd></li>"
    body += "<li><kbd>Availability: Little to no impact on availability of systems or access to data.</kbd></li></ul> |\n"

    body += "\n| Probability[^3] | Likelihood of a Risk Event to be realized |\n"
    body += "| ------------- | --- |\n"
    body += "| <ul><li>[ ] Very Likely</li></ul> "
    body += "|<kbd>The risk event is expected to occur frequently or is highly likely to occur, based on historical data or expert opinion.</kbd>|\n"
    body += "| <ul><li>[ ] Likely</li></ul> "
    body += "|<kbd>The risk event is expected to occur occasionally or is somewhat likely to occur, based on historical data or expert opinion.</kbd>|\n"
    body += "| <ul><li>[ ] Neutral</li></ul> "
    body += "|<kbd>The likelihood of the risk event occurring is unclear or unknown.</kbd>|\n"
    body += "| <ul><li>[ ] Unlikely</li></ul> "
    body += "|<kbd>The risk event is not expected to occur often or is somewhat unlikely to occur, based on historical data or expert opinion.</kbd>|\n"
    body += "| <ul><li>[ ] Rare</li></ul> "
    body += "|<kbd>The risk event is not expected to occur at all or is highly unlikely to occur, based on historical data or expert opinion.</kbd>|\n"

    body += "## Rationale\n"
    body += "- _TBD: Provide rationale for Impact and/or Probability assessment_\n"

    body += "## Controls In Place\n"
    body += "| Control Definition | Control in Place "
    body += "&nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp; &nbsp;  &nbsp; &nbsp; &nbsp; &nbsp; | Evidence |\n"
    body += "| --- | --- | --- |\n"

    for ctl_grp in get_control_definition_group(row[Header.CONTROL_DEFINITION.value]):
        body += "| {} | <ul><li>[ ] Yes</li><li>[ ] No</li><li>[ ] Partial</li></ul> ".format(ctl_grp)
        body += "| _Note: Provide only link(s) to evidence in comments_ |\n"

    # footnote
    body += "[^1]: CDS Principals/Teams responsible for implementing controls, and providing evidence for the controls.\n"
    body += "[^2]: When assessing Impact, CDS business context and Security Categorization of information should be taken into account.\n"
    body += "[^3]: When assessing Probability, the controls in place, or lack thereof, should be taken into account.\n"

    return body


def get_control_family(control_id):
    match = re.match(r"([A-Z][A-Z])-.*", control_id)
    if match:
        return LONG_CONTROL_FAMILY[match.group(1)]


def get_labels(row):
    """
    Get labels for issue to help future retrieval
    """
    labels = []

    control_id = get_control_id(row)

    labels.append("Control: {}".format(control_id))
    labels.append("Family: {}".format(get_control_family(control_id)))

    if row[Header.CONTROL_CLASS.value]:
        labels.append("Class: {}".format(row[Header.CONTROL_CLASS.value].strip()))

    labels.append(CONTROL_PROFILE_TYPE)

    if is_attribute_set(row, Header.CLIENT_IAAS_PAAS.value):
        labels.append("IaaS/PaaS")
    if is_attribute_set(row, Header.CLIENT_SAAS.value):
        labels.append("SaaS")

    return labels


def get_title(row):
    """
    Get title for issue.
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


def is_attribute_set(row, header_enum):
    return row[header_enum].strip().upper() == "X"


def control_file_path(control_file):
    """
    Input control file location: input/<REPO>/<CSV_FILE>
    """
    return str(Path('input', get_repo().split('/')[-1], control_file))


def get_controls(control_file):
    """
    Get controls from CCCS Control Profile csv file located in:

    """
    with open(control_file_path(control_file), "r", newline='') as csvfile:
        logging.info("opened baseline control file: {}".format(control_file))
        csvreader = csv.reader(csvfile)

        for row in csvreader:
            if likely_header(row):
                set_control_profile_type(row)
            else:
                yield row


if __name__ == "__main__":
    main()
