import script
from unittest.mock import patch, Mock
import pytest
import logging


@patch("script.get_controls")
@patch("script.get_issues_url")
@patch("script.get_header")
@patch("script.get_issues_json")
@patch("script.post_request")
def test_main(
    mock_post_request,
    mock_get_issues_json,
    mock_get_header,
    mock_get_issues_url,
    mock_get_controls,
):
    mock_get_controls.return_value = [
        [
            "Family1",
            "Control1",
            "E1",
            "Control1 name",
            "Class1",
            "Definition1",
            "Supplemental guidance1",
            "References1",
            "IT Security Function",
            "",
            "",
            "",
            "",
            "",
            "Medium",
            "",
            "",
            "",
        ],
        [
            "Family2",
            "Control2",
            "E2",
            "Control2 name",
            "Class2",
            "Definition2",
            "Supplemental guidance2",
            "References2",
            "",
            "IT Operation Group",
            "",
            "",
            "",
            "",
            "Low",
            "",
            "",
            "",
        ],
    ]
    mock_post_request.return_value.status_code = 201
    mock_get_header.return_value = {
        "Accept": "application/vnd.github+json",
        "Authorization": "Bearer token",
        "X-GitHub-Api-Version": "2022-11-28",
    }
    mock_get_issues_json.return_value = {
        "title": "title",
        "body": "body",
        "labels": "labels",
    }
    mock_get_issues_url.return_value = "https://api.github.com/repos/owner/repo/issues"
    script.main()

    assert mock_post_request.call_count == 2


@patch("script.requests.post")
def test_post_request_failure(mock_post, caplog):
    issues_url = "https://api.github.com/repos/owner/repo/issues"
    headers = {"Authorization": "Bearer token"}
    issues_json = {"title": "Test Issue", "body": "This is a test issue"}
    mock_post.return_value = Mock(status_code=400, text="Bad request")
    caplog.set_level(logging.ERROR)

    script.post_request(issues_url, headers, issues_json)
    assert "Failed to create issue for control" in caplog.text
    assert "Response: Bad request" in caplog.text


@patch("script.requests.post")
def test_post_request_success(mock_post, caplog):
    issues_url = "https://api.github.com/repos/owner/repo/issues"
    headers = {"Authorization": "Bearer token"}
    issues_json = {"title": "Test Issue", "body": "This is a test issue"}
    mock_post.return_value = Mock(status_code=201, text="Created")
    caplog.set_level(logging.INFO)

    response = script.post_request(issues_url, headers, issues_json)
    assert response == mock_post.return_value
    assert "Created issue for control" in caplog.text


@patch("script.GITHUB_TOKEN", "DuMMyToKeN125795")
def test_get_github_token_exists():
    token = script.get_github_token()
    assert token == "DuMMyToKeN125795"


@patch("script.GITHUB_TOKEN", "")
def test_get_github_token_not_exists():
    with pytest.raises(Exception) as excinfo:
        script.get_github_token()
    assert str(excinfo.value) == "GITHUB_TOKEN env var not set"


@patch("script.REPO", "owner/repo")
def test_get_issues_url():
    issues_url = script.get_issues_url()
    assert issues_url == "https://api.github.com/repos/owner/repo/issues"


@patch("script.REPO", "")
def test_get_issues_url_not_exists():
    with pytest.raises(Exception) as excinfo:
        script.get_issues_url()
    assert str(excinfo.value) == "REPO env var not set"


@patch("script.GITHUB_TOKEN", "DuMMyToKeN125795")
def test_get_header():
    header = script.get_header()
    assert header == {
        "Accept": "application/vnd.github+json",
        "Authorization": "Bearer DuMMyToKeN125795",
        "X-GitHub-Api-Version": "2022-11-28",
    }


@patch("script.get_title", return_value="title")
@patch("script.get_body", return_value="body")
@patch("script.get_labels", return_value=["label1", "label2"])
def test_get_issues_json(mock_get_labels, mock_get_body, mock_get_title):
    row = []
    issues_json = script.get_issues_json(row)
    assert issues_json == {
        "title": "title",
        "body": "body",
        "labels": ["label1", "label2"],
    }


@patch("script.get_suggested_assignment", return_value="IT Security")
@patch("script.get_support_teams", return_value="IT Operation Group")
def test_get_body(mock_get_support_teams, mock_get_suggested_assignment):
    print("test_get_body")
    row = [
        "CM",
        "3",
        "-3",
        "CONFIGURATION CHANGE CONTROL",
        "Operational",
        "The org requires an infosec to be a member of the comitee",
        "Supplemental Guidance text",
        "Reference text",
        "R",
        "S",
        "",
        "",
        "",
        "",
        "text",
        "P1",
        "",
        "",
        "",
    ]
    body = script.get_body(row)
    assert (
        body
        == "#Control Definition\nThe org requires an infosec to be a member of the comitee\n\n#Class\nOperational\n\n#Supplemental Guidance\nSupplemental Guidance text\n\n#References\nReference text\n\n#General Guide\ntext\n\n#Suggested Assignment\nIT Security\n\n#Support Teams\nIT Operation Group\n\n"
    )


@patch("script.get_suggested_assignment", return_value="IT Security")
def test_get_labels(mock_get_suggested_assignment):
    row = [
        "CM",
        "3",
        "-3",
        "CONFIGURATION CHANGE CONTROL",
        "Operational",
        "The org requires an infosec to be a member of the comitee",
        "Supplemental Guidance text",
        "Reference text",
        "R",
        "S",
        "",
        "",
        "",
        "",
        "text",
        "P1",
        "",
        "",
        "",
    ]
    labels = script.get_labels(row)
    assert labels == [
        "Control: CM-3",
        "Priority: P1",
        "Class: Operational",
        "Suggested Assignment: IT Security",
        "ITSG-33"
    ]


def test_get_suggested_assignment():
    row = [
        "CM",
        "3",
        "-3",
        "CONFIGURATION CHANGE CONTROL",
        "Operational",
        "The org requires an infosec to be a member of the comitee",
        "Supplemental Guidance text",
        "Reference text",
        "R",
        "S",
        "",
        "",
        "",
        "",
        "text",
        "P1",
        "",
        "",
        "",
    ]
    suggested_assignment = script.get_suggested_assignment(row)
    assert suggested_assignment == "IT Security Function"


def test_get_support_teams():
    row = [
        "CM",
        "3",
        "-3",
        "CONFIGURATION CHANGE CONTROL",
        "Operational",
        "The org requires an infosec to be a member of the comitee",
        "Supplemental Guidance text",
        "Reference text",
        "R",
        "S",
        "",
        "",
        "",
        "",
        "text",
        "P1",
        "",
        "",
        "",
    ]
    support_teams = script.get_support_teams(row)
    assert support_teams == "IT Operations Group"


def test_get_support_teams_more_than_one():
    row = [
        "CM",
        "3",
        "-3",
        "CONFIGURATION CHANGE CONTROL",
        "Operational",
        "The org requires an infosec to be a member of the comitee",
        "Supplemental Guidance text",
        "Reference text",
        "S",
        "S",
        "R",
        "",
        "",
        "",
        "text",
        "P1",
        "",
        "",
        "IT Security",
    ]
    support_teams = script.get_support_teams(row)
    assert support_teams == "IT Security Function, IT Operations Group"


def test_get_enum_string_startswith_it():
    assert "IT Security Function" == script.get_enum_string(8)


def test_get_enum_string_without_it():
    assert "Learning Center" == script.get_enum_string(13)


def test_get_enum_string_has_it_in_the_middle():
    assert "Physical Security Group" == script.get_enum_string(11)


def test_get_title_with_enhancement():
    row = [
        "CM",
        "3",
        "-3",
        "CONFIGURATION CHANGE CONTROL",
        "Operational",
        "The org requires an infosec to be a member of the comitee",
        "Supplemental Guidance text",
        "Reference text",
        "R",
        "S",
        "",
        "",
        "",
        "",
        "text",
        "P1",
        "",
        "",
        "",
    ]
    assert script.get_title(row) == "CM-3(-3): Configuration Change Control"


def test_get_title_without_enhancement():
    row = [
        "CM",
        "3",
        "",
        "CONFIGURATION CHANGE CONTROL",
        "Operational",
        "The org requires an infosec to be a member of the comitee",
        "Supplemental Guidance text",
        "Reference text",
        "R",
        "S",
        "",
        "",
        "",
        "",
        "text",
        "P1",
        "",
        "",
        "",
    ]
    assert script.get_title(row) == "CM-3: Configuration Change Control"


@patch("script.csv.reader")
@patch("builtins.open")
def test_get_controls_different_header(mock_builtins_open, mock_script_csv_reader):
    mock_script_csv_reader.return_value = iter(
        [
            [
                "a",
                "Control ID",
                "Enhancement",
                "Name",
                "Class",
                "Definition" "Supplemental Guidance",
                "References",
                "IT Security Function",
                "IT Operations Group",
                "IT Projects",
                "Physical Security Group",
                "Personnel Security Group",
                "Learning Center",
                "General Tailoring and Implementation Guidance Notes",
                "SuggestedPriority",
                "Suggested for this Profile",
                "Suggested Placeholder Values",
                "Profile-Specific Notes",
            ]
        ]
    )
    with pytest.raises(ValueError) as excinfo:
        script.get_controls()
    assert str(excinfo.value) == "Headers different than expected"


@patch("script.csv.reader")
@patch("builtins.open")
def test_get_controls_no_controls(mock_builtins_open, mock_script_csv_reader):
    mock_script_csv_reader.return_value = iter(
        [
            [
                "Family",
                "Control ID",
                "Enhancement",
                "Name",
                "Class",
                "Definition" "Supplemental Guidance",
                "References",
                "IT Security Function",
                "IT Operations Group",
                "IT Projects",
                "Physical Security Group",
                "Personnel Security Group",
                "Learning Center",
                "General Tailoring and Implementation Guidance Notes",
                "SuggestedPriority",
                "Suggested for this Profile",
                "Suggested Placeholder Values",
                "Profile-Specific Notes",
            ]
        ]
    )
    with pytest.raises(ValueError) as excinfo:
        script.get_controls()
    assert str(excinfo.value) == "No controls found in csv file"


@patch("script.csv.reader")
@patch("builtins.open")
def test_get_controls(mock_builtins_open, mock_script_csv_reader):
    mock_script_csv_reader.return_value = iter(
        [
            [
                "Family",
                "Control ID",
                "Enhancement",
                "Name",
                "Class",
                "Definition" "Supplemental Guidance",
                "References",
                "IT Security Function",
                "IT Operations Group",
                "IT Projects",
                "Physical Security Group",
                "Personnel Security Group",
                "Learning Center",
                "General Tailoring and Implementation Guidance Notes",
                "SuggestedPriority",
                "Suggested for this Profile",
                "Suggested Placeholder Values",
                "Profile-Specific Notes",
            ],
            [
                "CM",
                "3",
                "",
                "CONFIGURATION CHANGE CONTROL",
                "Operational",
                "The org requires an infosec to be a member of the comitee",
                "Supplemental Guidance text",
                "Reference text",
                "R",
                "S",
                "",
                "",
                "",
                "",
                "text",
                "P1",
                "",
                "",
                "",
            ],
        ]
    )
    controls = script.get_controls()
    assert controls == [
        [
            "CM",
            "3",
            "",
            "CONFIGURATION CHANGE CONTROL",
            "Operational",
            "The org requires an infosec to be a member of the comitee",
            "Supplemental Guidance text",
            "Reference text",
            "R",
            "S",
            "",
            "",
            "",
            "",
            "text",
            "P1",
            "",
            "",
            "",
        ]
    ]
