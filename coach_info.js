// Get the coach ID and season from the URL query parameters
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const coachID = urlParams.get('coachID');


function findcoach(csvData, coachID) {
    const lines = csvData.split("\n");

    let coachName = "a";

    for (let i = 1; i < lines.length; i++) {
        const currentLine = lines[i].split(",");
        console.log(currentLine)
        let cur_ID = currentLine[3].replace(/\r/g, '');
        console.log(cur_ID)

        if(cur_ID == coachID) {
            coachName = currentLine[1].slice(1, -1)
            break;
        }
    }
    
    return coachName;
}

fetch("coaches/coach_ids.csv")
    .then(response => response.text())
    .then(csvData => {
        const coachName = findcoach(csvData, coachID);

        const pageTitle = document.querySelector('title');
        const pageTitleText = pageTitle.textContent;
        pageTitle.textContent = `Softball Statline  - ${coachName}`;

        const heading = document.querySelector('h1');
        const headingText = heading.textContent;
        heading.textContent = coachName
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));

const csvFileName = `coaches/coach_history.csv`;

const coachInfo = []
const tableContainer = document.getElementById("coach-container");

function parseCSV(csvData) {
    const lines = csvData.split("\n");
    const headers = ['', 'Season', 'Team Name', 'Division', 'Conference', 'Record', 'Win %', 'Team ID', 'Coach ID'];
    const rows = [];

    for (let i = 1; i < lines.length; i++) {
        const currentLine = lines[i].split(",");
        const row = {};
        for (let j = 1; j < headers.length; j++) {
            const header = headers[j];
            let value = currentLine[j] ? currentLine[j].trim() : ''; // Handle empty or missing values

            // Remove quotes around the value if present
            if (value.startsWith('"') && value.endsWith('"')) {
                value = value.slice(1, -1);
            }

            row[header] = value;
        }
        rows.push(row);
    }

    return rows;
}

function displayInfo(coachInfo) {
    const table = document.createElement("table");
    const headers = Object.keys(coachInfo[0]);
    
    const headerRow = document.createElement("tr");

    for (const header of headers.slice(0,6)) {
        const th = document.createElement("th");
        th.textContent = header;
        headerRow.appendChild(th);
    }

    table.appendChild(headerRow);

    for (const rowData of coachInfo) {
        if (rowData['Coach ID'] === coachID) {
            const row = document.createElement("tr");
            for (const header of headers) {
                const td = document.createElement("td");
                if (header === "Season" & rowData[header] >= 2016) {
                    const seasonLink = document.createElement("a");
                    seasonLink.href = `team_season_info?teamID=${rowData["Team ID"]}&season=${rowData[header]}`;
                    seasonLink.textContent = rowData[header];
                    td.appendChild(seasonLink);
                } else {
                    td.textContent = rowData[header];
                }
                row.appendChild(td);
            }
            table.appendChild(row);
        }
    }

    tableContainer.appendChild(table);
}

 fetch(csvFileName)
    .then(response => response.text())
    .then(csvData => {
        const parsedData = parseCSV(csvData);
        displayInfo(parsedData);
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));







