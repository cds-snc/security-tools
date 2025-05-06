import script
from unittest.mock import patch, Mock
import pytest

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