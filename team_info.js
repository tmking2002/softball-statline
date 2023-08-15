// Get the team ID and season from the URL query parameters
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const teamID = urlParams.get('teamID');


function findTeam(csvData, teamID) {
    const lines = csvData.split("\n");

    let teamName = "a";

    for (let i = 1; i < lines.length; i++) {
        const currentLine = lines[i].split(",");
        let cur_ID = currentLine[2];
        if (cur_ID.startsWith('"') && cur_ID.endsWith('"')) {
            cur_ID = cur_ID.slice(1, -1);
        }

        if(cur_ID == teamID) {
            teamName = currentLine[1].slice(1, -1)
            break;
        }
    }
    
    return teamName;
}

fetch("teams/data/all_teams.csv")
    .then(response => response.text())
    .then(csvData => {
        const teamName = findTeam(csvData, teamID);

        const pageTitle = document.querySelector('title');
        const pageTitleText = pageTitle.textContent;
        pageTitle.textContent = `Softball Statline  - ${teamName}`;

        const heading = document.querySelector('h1');
        const headingText = heading.textContent;
        heading.textContent = teamName
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));

const csvFileName = `teams/data/team_info/team_${teamID}.csv`;

const teamInfo = []
const tableContainer = document.getElementById("table-container");

function parseCSV(csvData) {
    const lines = csvData.split("\n");
    const headers = ['', 'Season', 'Head Coach', 'Conf.', 'Record', 'Win%'];
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

function displayInfo(teamInfo) {
    const table = document.createElement("table");
    const headers = Object.keys(teamInfo[0]);

    const headerRow = document.createElement("tr");

    for (const header of headers) {
        const th = document.createElement("th");
        th.textContent = header;
        headerRow.appendChild(th);
    }

    table.appendChild(headerRow);

    for (const rowData of teamInfo) {
        fetch("coaches/coach_ids.csv")
            .then(response => response.text())
            .then(csvData => {
                const coachID = findCoach(csvData, rowData["Head Coach"]);

                const row = document.createElement("tr");

                for (const header of headers) {
                    const td = document.createElement("td");

                    if (header === "Season") {
                        const seasonLink = document.createElement("a");
                        seasonLink.href = `team_season_info?teamID=${teamID}&season=${rowData[header]}`;
                        seasonLink.textContent = rowData[header];
                        td.appendChild(seasonLink);
                    } else if (header === "Head Coach") {
                        const coachLink = document.createElement("a");
                        coachLink.href = `coach_info?coachID=${coachID}`;
                        coachLink.textContent = rowData[header];
                        td.appendChild(coachLink);
                    } else {
                        td.textContent = rowData[header];
                    }
                    row.appendChild(td);
                }
                table.appendChild(row);
            })
            .catch(error => console.error("Error fetching or parsing CSV:", error));
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


function findCoach(csvData, coachName) {
    const lines = csvData.split("\n");
   
    let coachID = 0;
    
    for (let i = 1; i < lines.length - 1; i++) {
        const currentLine = lines[i].split(",");
        let cur_Name = currentLine[1];
        if (cur_Name.startsWith('"') && cur_Name.endsWith('"')) {
            cur_Name = cur_Name.slice(1, -1);
        }
        if(cur_Name == coachName) {
            coachID = currentLine[2]
            break;
        }
    }
    return coachID;
}
    





