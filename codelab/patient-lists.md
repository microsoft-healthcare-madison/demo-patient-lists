summary: Patient Lists "Hospital Rounds" Demo App and Vignettes
id: docs
categories: patient-lists argonaut
environments: Web
status: Draft
feedback link: https://github.com/microsoft-healthcare-madison/demo-patient-lists/issues
tags: patient-lists fhir argonaut
authors: Carl Anderson

<!--- DEV NOTE
# Run this in a terminal to automatically re-extract the codelab when the source
# markdown is changed.

# Prerequisites:
#  - claat: https://github.com/googlecodelabs/tools/tree/master/claat
#  - kqwait: https://github.com/sschober/kqwait (optional)

# Serve the codelab html from the current 'docs' dir on port 9090.
cd docs
claat serve &  # opens a new browser window
cd ..

# Watch the codelab markdown for saves, exporting on each change.
CODELAB=./codelab/patient-lists.md
while kqwait $CODELAB && claat export $_; do continue; done

# To PRINT a codelab, refer to Marc Cohen's post here:
# https://groups.google.com/d/msg/codelab-authors/pnnY50o82Qw/V0PILK9iBQAJ

# Instructions:
npm install easy-pdf-merge puppeteer
wget https://raw.githubusercontent.com/googlecodelabs/tools/clprint/clprint.js
node clprint.js http://localhost:9090 0 4
--->

# Build a Hospital Rounds App using the Patient Lists API


## Introduction
Duration: 2

### Welcome, student!

This codelab is intended to teach you about the [2020 Argonaut](http://2020.argo.run) initiative for [Patient Lists](https://github.com/argonautproject/patient-lists) by walking you through a coding exercise that uses the new API.

<dt>positive</dt>
<div>
#### Profile Audience
<br>This guide is intended for programmers who wish to *learn by doing*.  You should already have a working knowledge of web programing, access to a development machine, and about **1 to 2 total hours** to dedicate to completing the whole codelab.
<br>Your completion time will vary based on your familiarity with Javascript, web programming concepts, and the APIs in general.
</div>

#### Prerequisites

This guide assumes you are already familiar with javascript and are comfortable with web programming concepts.  It also helps to know the basics of `git`, but there will be example commands throughout for convenience.  The provided initial codebase uses `javascript`, `node`, `nvm`, `npm`, and `express` - so some prior experience with those tools will be helpful, but not required.  JavaScript in the browser and in Node.js, and the express Web framework for Node.js

#### Contributing

As always, you are free to re-write entire portions of the code in whatever framework you like (and please feel free to share your work with us)!

The codelab has a wiki which should help you decide how to best contribute:
<https://github.com/microsoft-healthcare-madison/demo-patient-lists/wiki>

Also, take notice of the [Report a mistake](https://github.com/microsoft-healthcare-madison/demo-patient-lists/issues) link that appears in the lower left corner of each page!

#### Major Milestones

You will start with an already-implemented app that displays an empty table of patients that will be visited by a doctor who is walking rounds in a hospital.

- v1: Provide a remote FHIR server to pull patients from, displaying the default list of patients.
- v2: Implement filters, restricting the patient list to meet specified criteria.
- v3: Include other patient details in the displayed table, fetching it from related resources using a [`Questionnaire`](https://www.hl7.org/fhir/questionnaire.html).


## Patient Lists
Duration: 2

### Patient Lists API

Provider-facing apps often need to know things like:
* Who are the patients I'm seeing today?
* Who are the patients I'm responsible for in the hospital right now?
* Who are the patients in this ward?

<dt>negative</dt>
<div>
#### Vendor-specific APIs
Non-FHIR APIs provide access to this kind of information, but it's hard to write a cross-platform app for patient management without a standard approach.
</div>

The FHIR Patient Lists will define a few key "list types" and ensure that FHIR-based apps can interact with lists as needed.  The initial focus is read-only access to lists.


## Initial App
Duration: 10

### Instructions
Begin by cloning the [repository](https://github.com/barabo/demo-patient-lists) that contains the skeletal app and installing it locally on your machine.

```bash
mkdir -p ~/code/msft-fhir
cd $_
git clone git@github.com:barabo/demo-patient-lists.git
cd demo-patient-lists
npm install
```

The demo app is now ready to be started using this command:

```sh
npm run demo
```

To view the app, visit this URL: <http://localhost:3001>


## Example Data Table
Duration: 5

The table below shows one example list of patient data that might be displayed in the rounding app.  Several data points will not be found within the `Patient` resource directly, and must be gathered indirectly; we will explore a method to do this this as efficiently as possible using the `Questionnaire` resource.

| Patient          | Age     | Gender     | Location     | Last Visit         | Admit               | Scheduled Departure     | Chief Complaint     | PCP             | Attending     |
|------------------|---------|------------|--------------|--------------------|---------------------|-------------------------|---------------------|-----------------|---------------|
| **Patient**      | **Age** | **Gender** | **Location** | **Last Visit**     | **Admit**           | **Scheduled Departure** | **Chief Complaint** | **PCP**         | **Attending** |
| Johnson, Adam    | 76      | M          | 704          | 2020-07-03 6:14:00 | 2020-07-02 12:34:56 | 2020-07-05 7:30:00      | Chest Pain          | Waterhouse, Ben | James, Craig  |
| Thomson, Jeffer  | 79      | M          | 705          | 2020-07-03 6:22:00 | 2020-07-01 21:09:54 | 2020-07-06 7:30:00      | Low Back Pain       | Rush, Benjamin  | James, Craig  |

Some other more interesting data points to consider adding for extra credit might be:
  * Latest Lab Results
  * Next Medication Due
  * Latest Pain Score

