import os
import logging
import requests

REPO = os.getenv("REPO")
GITHUB_TOKEN = os.getenv("GITHUB_TOKEN")
LABEL = os.getenv("LABEL", "ATO")
LOG_LEVEL = os.getenv("LOG_LEVEL", logging.INFO)


"""
Set logging level
"""
logging.basicConfig(
    level=LOG_LEVEL,
    format="%(asctime)s :%(levelname)s:%(funcName)s:%(lineno)d %(message)s",
    datefmt="%d-%b-%y %H:%M:%S",
)


def main():
    issues = get_issues_with_label()
    for issue in issues:
        for comment in get_issues_comment(issue["number"]):
            control_comment = parse_issues_comment(comment)
            if control_comment:
                logging.info("Control Comment: {}".format(control_comment))
                

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


def get_issues_with_label():
    """
    Get issues with label
    """
    url = get_issues_url()
    params = {"labels": LABEL}
    response = requests.get(url, headers=get_header(), params=params)
    if response.status_code == 200:
        return response.json()
    else:
        logging.error("Failed to get issues with label: {}".format(LABEL))
        logging.error("Response: {}".format(response.text))
        return None
    

def get_issues_comment(issue_number):
    """
    Get issues comment
    """
    url = "{}/{}/comments".format(get_issues_url(), issue_number)
    response = requests.get(url, headers=get_header())
    if response.status_code == 200:
        return response.json()
    else:
        logging.error("Failed to get issues comment for issue: {}".format(issue_number))
        logging.error("Response: {}".format(response.text))
        return None
    

def parse_issues_comment(issues_comment):
    """
    Parse issues comment
    """
    if issues_comment:
        return [comment["body"] for comment in issues_comment if "## Controls in place:" in comment["body"]]
    else:
        raise Exception("No controls in place found in comments for the issue: {}".format(issues_comment["issue_url"]))
    

if __name__ == "__main__":
    main()
