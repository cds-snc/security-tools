"""
The purpose of this script is to take the CSV file with the ITSG-33 controls and create issues in github for each control.
The script will create the issue title, body, and labels. The body will have the control definition, class, supplemental guidance,
 references, general guide, suggested placeholder values, profile specific notes, suggested assignment, and support teams.
"""

import csv
import requests
import json
import os
import string
import logging
from enum import Enum

"""
env vars:
REPO = owner/repo
GITHUB_TOKEN = github token to create issues
CSV_FILE = path to csv file
DEBUG = True/False to print debug info
"""
REPO = os.getenv("REPO")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
CSV_FILE = "controls.csv"

class Header(Enum):
    FAMILY = 0
    CONTROL_ID = 1
    ENHANCEMENT = 2
    CONTROL_NAME = 3
    CONTROL_CLASS = 4
    CONTROL_DEFINITION = 5
    REFERENCES = 7
    SUPPLEMENTAL_GUIDANCE = 6
    IT_SECURITY_FUNCTION = 8
    IT_OPERATIONS_GROUP = 9
    IT_PROJECTS = 10
    PHYSICAL_SECURITY_GROUP = 11
    PERSONNEL_SECURITY_GROUP = 12
    LEARNING_CENTER = 13
    GENERAL_GUIDE = 14
    SUGGESTED_PRIORITY = 15
    SUGGESTED_PLACEHOLDER_VALUES = 16
    PROFILE_SPECIFIC_NOTES = 17


"""
Set logging level
"""
logging.basicConfig(level=logging.ERROR, format='%(asctime)s :%(levelname)s:%(funcName)s:%(lineno)d %(message)s', datefmt='%d-%b-%y %H:%M:%S')


def main():
    
    for row in get_controls():

        issues_url = get_issues_url()
        headers = get_header()
        issues_json = get_issues_json(row)
        
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
    response = requests.post(issues_url, headers=headers, json=issues_json)
    if response.status_code == 201:
        logging.info("Created issue for control: {}".format(issues_json["title"]))
    else:
        logging.error("Failed to create issue for control: {}".format(issues_json["title"]))
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
        "X-GitHub-Api-Version": "2022-11-28"
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


def get_body(row):
    """
    Get body for issue. Has at least the control definition.
    """
    body = "#Control Definition\n{}\n\n".format(row[Header.CONTROL_DEFINITION.value])
    if row[Header.CONTROL_CLASS.value]:
        body += "#Class\n{}\n\n".format(row[Header.CONTROL_CLASS.value])
    if row[Header.SUPPLEMENTAL_GUIDANCE.value]:
        body += "#Supplemental Guidance\n{}\n\n".format(row[Header.SUPPLEMENTAL_GUIDANCE.value])
    if row[Header.REFERENCES.value]:
        body += "#References\n{}\n\n".format(row[Header.REFERENCES.value])
    if row[Header.GENERAL_GUIDE.value]:
        body += "#General Guide\n{}\n\n".format(row[Header.GENERAL_GUIDE.value])
    if row[Header.SUGGESTED_PLACEHOLDER_VALUES.value]:
        body += "#Suggested Placeholder Values\n{}\n\n".format(row[Header.SUGGESTED_PLACEHOLDER_VALUES.value])
    if row[Header.PROFILE_SPECIFIC_NOTES.value]:
        body += "#Profile Specific Notes\n{}\n\n".format(row[Header.PROFILE_SPECIFIC_NOTES.value])
    if get_suggested_assignment(row):
        body += "#Suggested Assignment\n{}\n\n".format(get_suggested_assignment(row))
    if get_support_teams(row):
        body += "#Support Teams\n{}\n\n".format(get_support_teams(row))
    return body


def get_labels(row):
    """
    Get labels for issue to help future retrieval
    """
    labels = []
    labels.append("Control: {}-{}".format(row[Header.FAMILY.value], row[Header.CONTROL_ID.value]))
    if row[Header.SUGGESTED_PRIORITY.value]:
        labels.append("Priority: {}".format(row[Header.SUGGESTED_PRIORITY.value]))
    if row[Header.CONTROL_CLASS.value]:
        labels.append("Class: {}".format(row[Header.CONTROL_CLASS.value]))    
    if get_suggested_assignment(row):
        labels.append("Suggested Assignment: {}".format(get_suggested_assignment(row)))
    return labels


def get_suggested_assignment(row):
    """
    Get suggested assignment for issue by looking up in the fields who has the "R" (Responsible)
    """
    for i in range(8, 14):
        if row[i] == "R":
            return get_enum_string(i)


def get_support_teams(row):
    """
    Get support teams for issue by looking up in the fields who has the "S" (Support)
    """
    teams = []
    for i in range(8, 14):
        if row[i] == "S":
            teams.append(get_enum_string(i))
    return ", ".join(teams)


def get_enum_string(index):
    """
    Get enum string from index and return a string read friendly
    """
    temp = string.capwords(Header(index).name.replace("_", " "))
    if "It " == temp[0:3]:
        temp = temp.replace("It ", "IT ", 1)
    return temp
    

def get_title(row):
    """
    Get title for issue. The logic required is encapsulated in this function. Some controls have enhancements, and if they do,
    the title should be formatted to show such info.
    """
    title = ""
    if row[Header.ENHANCEMENT.value]:
        title = "{}-{}({}): {}".format(row[Header.FAMILY.value], row[Header.CONTROL_ID.value], 
                                       row[Header.ENHANCEMENT.value], string.capwords(row[Header.CONTROL_NAME.value]))
    else:
        title = "{}-{}: {}".format(row[Header.FAMILY.value], row[Header.CONTROL_ID.value], string.capwords(row[Header.CONTROL_NAME.value]))
    return title
    

def get_controls():
    """
    Get controls from csv file and jumps the header.
    """
    rows = []
    with open(CSV_FILE, 'r') as file:
        reader = csv.reader(file)
        
        if next(reader)[0] != "Family":
            raise ValueError("Headers different than expected")
        
        for row in reader:
            rows.append(row)
        
        if len(rows) < 1:
            raise ValueError("No controls found in csv file")
    return rows


if __name__ == "__main__":
    main()