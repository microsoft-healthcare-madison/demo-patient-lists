summary: Patient Lists "Hospital Rounds" Demo App and Vignettes
id: docs
categories: patient-lists argonaut
environments: Web
status: Draft
feedback link: https://github.com/microsoft-healthcare-madison/demo-patient-lists/issues
tags: patient-lists fhir argonaut
authors: Carl Anderson

<!--- DEV NOTE
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

- v1: Read patient data from either a FHIR server or from flat files, displaying the list of patients.
- v2: Include other patient details in the displayed table, fetching it from related resources using several parallel queries.
- v3: Implement filters, restricting the patient list to meet specified criteria.


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

### EXERCISE: Open the Docs
<dt>positive</dt>
<div>Refer to the (currently DRAFT) documentation here: <https://github.com/argonautproject/patient-lists></div>


## Example Data Table
Duration: 5

The table below shows one example list of patient data that might be displayed in an Hourly Rounding app.
<dt>positive</dt>
<div>Several data points shown below will not be found direclty within the `Patient` resource, and must be gathered individually.  At first we will query for these using a naive approach; later, we will explore a method to do this this as efficiently as possible using the `Questionnaire` resource, if the server supports it.</div>


| Patient          | Age     | Gender     | Location     | Last Visited       | Admit               | Chief Complaint     | PCP             | Attending     |
|------------------|---------|------------|--------------|--------------------|---------------------|---------------------|-----------------|---------------|
| **Patient**      | **Age** | **Gender** | **Location** | **Last Visited**   | **Admit**           | **Chief Complaint** | **PCP**         | **Attending** |
| Johnson, Adam    | 76      | M          | 704          | 2020-07-03 6:14:00 | 2020-07-02 12:34:56 | Chest Pain          | Waterhouse, Ben | James, Craig  |
| Thomson, Jeffer  | 79      | M          | 705          | 2020-07-03 6:22:00 | 2020-07-01 21:09:54 | Low Back Pain       | Rush, Benjamin  | James, Craig  |

<dt>negative</dt>
<div>**Some other more interesting data points to consider adding for extra credit might be:**
  * Scheduled Departure
  * New Lab Results Y/N
  * Time Until Next Medication
  * Pain Score 5-hour Trend
</div>


## Codelab Setup
Duration: 10

### Instructions
Begin by cloning the [repository](https://github.com/microsoft-healthcare-madison/demo-patient-lists) that contains the skeletal app and installing it locally on your machine.

```bash
mkdir -p ~/code/msft-fhir
cd $_
git clone git@github.com:microsoft-healthcare-madison/demo-patient-lists.git
cd demo-patient-lists
npm ci
```

The demo app is now ready to be started using this command:

```sh
npm run demo
```

### EXERCISE: View the App
<dt>positive</dt>
<div>To view the app, visit this URL: <http://localhost:2020></div>


## Server Support
Duration: 2

<dt>negative</dt>
<div>**As of June, 2020 - most servers do not yet support the Patient Lists API!**</div>

<dt>positive</dt>
<div>This codelab provides static 'canned' server responses in the form of flat json files and a mock server interface which simulates an operational server.  You can do this exercise with or without a real server!</div>

### Server Compliance Test
If you would like to *test* your server for Patient List API compliance, visit this link:
<dt>negative</dt>
<div>TODO(carl) - link to the server tester site when it's available (work in progress).</div>

### Required Server Capabilities
In summary, the required server capabilities are:

* Group resource support.

### EXERCISE: Configure the Source Data
<dt>positive</dt>
<div>The remainder of this codelab assumes you have a common source of data.  You may either configure the app to use your own server or to read from provided files.

#### OPTION 1: Genuine Server
If you intend to bring your own server for this exercise, please update `index.html` to use your server URL:
```js
<script>
  var SERVER = "http://localhost:2019"  // TODO: update this with your own URL
</script>
```

#### OPTION 2: Mock Server
Launch the local server which will provide canned output on <http://localhost:2019>.
```bash
npm start server
```
</div>


## Group Resource
Duration: 10

The Patient Lists API takes advantage of the [Group](https://www.hl7.org/fhir/group.html) resource to represent a collection of patients with something in common, as opposed to a [List](https://www.hl7.org/fhir/list.html), which is a manually curated collection.

### EXERCISE: Fetch all the Groups
<dt>positive</dt>
<div>Begin by adding code to fetch the groups from your source data.
```js
    <table id="patients" border=1>
        <tr>
            <th>Patient</th>
            <th>Age</th>
            <th>Gender</th>
            <th>Location</th>
            <th>Last Visited</th>
            <th>Admit</th>
            <th>Chief Complaint</th>
            <th>PCP</th>
            <th>Attending</th>
        </tr>
    </table>
    <script>
        fetch(SERVER + '/Group')
            .then(function (response) {
                return response.json();
            })
            .then(function (bundle) {
                unbundle(bundle);
            })
            .catch(function (err) {
                console.log('error: ' + err);
            });

        function unbundle(bundle) {
            var patients = document.getElementById("patients");
            for (var i = 0; i < bundle.entry.length; i++) {
                var tr = document.createElement("tr");
                var td = document.createElement("td");
                tr.appendChild(td);
                td.innerHTML = "Lastname, Firstname";
                // TODO: add the other elements.
                patients.appendChild(tr);
            }
            // TODO: also handle paging of results in the bundle.
        }
    </script>
```
</div>


## META TODO
Duration: 0

<dt>positive</dt>
<div>
```
  0/ - This section details the plan for this codelab and is subject to change!
 <Y
 / \
 ```
 </div>

### Administrative
  * Move this repo over to the microsoft-healthcare-madison team page (and update all links).
  * Convert this section into github issues for work tracking and assignment (if anyone else is interested in helping)

### Supporting materials
  * I need to write a dumb local 'fhir' server which will serve up canned / static files on port 2019.

### Remaining sections / exercises
  * Populate Location
  * Populate Admit date
  * Populate Last Visited timestamp.
  * Populate PCP and Attending providers.
  * Populate Chief Complaint.
  * App Filters

### Bonus
Finally, once the mechanics are better understood, the option of having a Questionnaire and response suggested in the Group extensions should be explored in the codelab.
