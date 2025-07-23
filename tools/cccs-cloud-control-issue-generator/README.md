# CCCS Cloud Control Issue Generator

## Description

The CCCS Cloud Control Issue Generator is a tool used to generate organization-level or system-level controls in a Github repository.

## Procedure

You will be working with two repositories:
| Repository | Description |
| --- | --- |
| _target-repository_ | Repository where you want to create issues. |
| _tool-repsitory_ | Repository where the tool resides: `security-tools` |

You will be working with the following input files:
| File | Repository | Description |
| --- | --- | --- |
| tools/cccs-cloud-control-issue-generator/Annex-A-CCCS-LOW-Cloud-Profile-Template.xlsx | _tool-repository_ | Annex A CCCS Low Cloud profile with CDS supplementary attributes in .xlsx |
| tools/cccs-cloud-control-issue-generator/Annex-B-CCCS-MEDIUM-Cloud-Profile-Template.xlsx | _tool-repository_ | Annex B CCCS Medium Cloud profile with CDS supplementary attributes in .xlsx |
| _cccs control profile template_ | _target-repository_ | Copy of Annex A/B Cloud profile template for controls selection. |
| tools/cccs-cloud-control-issue-generator/input/_target-repository_/_csv file_ | _tool-repsitory_ | csv file converted from _cccs control profile template_. |

## Preparation

- Create _target-repository_ from the following template: https://github.com/cds-snc/system-level-security-controls-template
- Create a Github action workflow (`.github/workflows/deploy-tickets.yml`) in _target-repository_:
  - Create a copy from https://github.com/cds-snc/test-cccs-cloud-control-issue-generator/blob/main/.github/workflows/deploy-tickets.yml
  - Update the parameter `csv_file` accordingly. This is the input csv file (see *Input* section below).
  - Check-in this file (`main` branch)
- Create a copy of CCCS Cloud Profile (_cccs control profile template_) from one of the CCCS Cloud profile templates (.xlsx).
  - Rename the copy, and check-in to the _target-repository_ (`main` branch).
  - Perform controls selection, and check-in.

### Input

- Convert the _cccs control profile template_ (.xlsx), in preparation step, to CSV format.
  - Create an input directory in the _tool-repository_ for the input file using the following naming convention: `input/<target-repository>`
  - Add the .csv file to this input directory.
  - Check-in this file (`main` branch).

### Output

The tool will create issues in the _target-repository_.

## Execute

### Parameters

The following parameters can be specified using environment variables:

| Parameter | Description | Default Value |
| --- | --- | --- |
| REPO | _target-repository_ | |
| GITHUB_TOKEN | token with write permission for _target-repository_ | |
| CSV_FILE | Input Control CSV file | |
| CONTROLS_FILTER | Controls Filter: *ORGANIZATION* or *SYSTEM* | *SYSTEM* |
| LOG_LEVEL | Logging level | *INFO* |

Parameters without default value must be specified.

### Github Actions Workflow

In the _target-repository_:
- Use the Github Actions workflow: `Create issues using CCCS Cloud Control Profile as baseline`.
- Optionally, select a branch `your-branch` to test changes on a branch (defaults to `main`).
- Run workflow.

This will create issues in the _target-repository_.
