function isMobile() {
    return window.matchMedia("(max-width: 768px)").matches;
}

// Get the team ID and season from the URL query parameters
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const playerID = urlParams.get('playerID');

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



function findPlayer(csvData, teamID) {
    const lines = csvData.split("\n");

    let playerName = "a";

    for (let i = 1; i < lines.length; i++) {
        const currentLine = lines[i].split(",");
        let cur_ID = currentLine[1];

        if(cur_ID == playerID) {
            playerName = currentLine[2].slice(1, -1);
            break;
        }
    }

    return playerName;
}

fetch("players/data/all_players.csv")
    .then(response => response.text())
    .then(csvData => {
        const player = findPlayer(csvData, playerID);

        const pageTitle = document.querySelector('title');
        pageTitle.textContent = `Softball Statline  - ${player}`;

        const heading = document.querySelector('h1');
        heading.textContent = player;
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));

function getSeasons() {
    const queryString = window.location.search;
    const urlParams = new URLSearchParams(queryString);
    const playerID = urlParams.get('playerID');

    return fetch("players/data/all_players.csv")
        .then(response => response.text())
        .then(csvData => {
            const lines = csvData.split("\n");
            let seasons = [];
            for (let i = 1; i < lines.length; i++) {
                let curID = lines[i].split(",")[1];
                
                if (curID === playerID) {
                    seasons = lines[i].split(",")[4].slice(1, -1).split("+");
                }
            }
            console.log(seasons)
            return seasons;
        });
}

// Hitting

const tableContainer_hitting = document.getElementById("hitting-stats-container");

function parseCSV(csvData, type) {
    const lines = csvData.split("\n");

    let headers;
    
    if (type === "Hitting") {
        headers = ['', 'Team ID', 'Player ID', 'Season', 'Player', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'R', 'BB', 'HBP', 'SO', 'SB', 'CS', 'AVG', 'OBP', 'OPS'];
    } else if (type === "Pitching") {
        headers = ['', 'Team ID', 'Player ID', 'Season', 'Player', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP'];
    }

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

const table_hitting = document.createElement("table");

function displayHeaders(type, table) {
    let headers;
    
    if(isMobile() && type === "Hitting") {
        headers = ['', 'Team', 'Player ID', 'Season', 'Player', 'AB', 'H', '2B', 'HR', 'RBI', 'BB', 'SO', 'OPS'];
    } else if(type === "Hitting") { 
        headers = ['', 'Team', 'Player ID', 'Season', 'Player', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'R', 'BB', 'HBP', 'SO', 'SB', 'CS', 'AVG', 'OBP', 'OPS'];
    } else if (type === "Pitching" && isMobile()) {
        headers = ['', 'Team', 'Player ID', 'Season', 'Player', 'IP', 'H', 'BB', 'SO', 'ERA', 'WHIP', 'FIP'];
    } else if (type === "Pitching") {
        headers = ['', 'Team', 'Player ID', 'Season', 'Player', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP'];
    }

    const headerRow = document.createElement("tr");

    for (const header of headers) {
        if (header === "Team ID" || header == "Player ID" || header === "" || header === "Player"){
            continue;
        }
        const th = document.createElement("th");
        th.textContent = header;
        headerRow.appendChild(th);
    }

    table.appendChild(headerRow);
}


function displayStats_hitting(data) {

    const headers = ['', 'Team', 'Player ID', 'Season', 'Player', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'R', 'BB', 'HBP', 'SO', 'SB', 'CS', 'AVG', 'OBP', 'OPS'];

    for (const rowData of data) {


        if (rowData["Player ID"] != playerID) {
            continue;
        }
        
        /*  Create hitting button */

        var existingButton = document.querySelector("#stats-buttons .w3-bar-item.w3-button.tablink");

        var buttons = document.querySelectorAll("#stats-buttons .w3-button.tablink");
        var buttonAlreadyExists = false;
            
        buttons.forEach(function(button) {
            if (button.textContent === "Hitting Stats") {
                buttonAlreadyExists = true;
            }
        });
            
        if (!buttonAlreadyExists) {
            // Create a new button element
            var buttonElement = document.createElement("button");
            buttonElement.className = "w3-bar-item w3-button tablink";
            buttonElement.textContent = "Hitting Stats";
            buttonElement.onclick = function() {
                openTab('hitting-stats');
            };

            // Find the container by its ID
            var container = document.getElementById("stats-buttons");

                // Append the button to the container
            container.appendChild(buttonElement);
        }

        const teamID = rowData["Team ID"];

        fetch("teams/data/all_teams.csv")
            .then(response => response.text())
            .then(csvData => {
                const teamName = findTeam(csvData, teamID);

                const row = document.createElement("tr");

                for (const header of headers) {
                    const td = document.createElement("td");

                    if ((header === "HBP" || header === "SB" || header === "CS" || header === "R" || header === "3B" || header === "OBP" || header == "AVG") && isMobile()) {
                        continue;
                    } else if (header === "Season") {
                        const seasonLink = document.createElement("a");
                        /*seasonLink.href = `player_season_info?playerID=${playerID}&season=${rowData[header]}`; Add this later*/ 
                        seasonLink.textContent = rowData[header];
                        td.appendChild(seasonLink);
                    } else if (header === "Team") {
                        const teamLink = document.createElement("a");
                        teamLink.href = `team_season_info?teamID=${rowData["Team ID"]}&season=${rowData["Season"]}`;
                        teamLink.textContent = teamName; 
                        td.appendChild(teamLink);
                    } else if (header == "Player ID" || header === "" || header === "Player"){
                        continue;
                    } else {
                        td.textContent = rowData[header];
                    }
                    row.appendChild(td);
                }
                table_hitting.appendChild(row);
                
            })

            .catch(error => console.error("Error fetching or parsing CSV:", error));
    }
}

function displayTotalStats_Hitting(data) {

    const headers = ['', 'Team ID', 'Season', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'R', 'BB', 'HBP', 'SO', 'SB', 'CS', 'AVG', 'OBP', 'OPS'];

    for (const rowData of data) {

        if (rowData["Player ID"] != playerID) {
            continue;
        }

        const row = document.createElement("tr");

        for (const header of headers) {
            const td = document.createElement("td");

            if ((header === "HBP" || header === "SB" || header === "CS" || header === "R" || header === "3B" || header === "OBP" || header == "AVG") && isMobile()) {
                continue;
            } else if (header === "Season") {
                const seasonLink = document.createElement("a");
                /*seasonLink.href = `player_season_info?playerID=${playerID}&season=${rowData[header]}`; Add this later*/ 
                seasonLink.textContent = rowData[header];
                td.appendChild(seasonLink);
            } else if (header == "Player ID" || header === "" || header === "Player"){
                continue;
            } else {
                td.textContent = rowData[header];
            }
            row.appendChild(td);
        }
        table_hitting.appendChild(row);

    }
    tableContainer_hitting.appendChild(table_hitting);


}

function run_hitting(){
    displayData_hitting(displayTotals_hitting);
}

function displayData_hitting(callback){
    setTimeout(function(){
        getSeasons()
            .then(seasons => {
                displayHeaders("Hitting", table_hitting);
                const fetchPromises = [];

                for (let i = 0; i < seasons.length; i++) {
                    const season = seasons[i];
                    const fetchPromise = fetch (`teams/data/hitting_stats/hitting_stats_${season}.csv`)
                        .then(response => response.text())
                        .then(csvData => {
                            return parseCSV(csvData, "Hitting");
                        });

                    fetchPromises.push(fetchPromise);
                }

                // Wait for all fetch operations to complete
                return Promise.all(fetchPromises);
            })
            .then(parsedDataArray => {
                for (let i = 0; i < parsedDataArray.length; i++) {
                    const parsedData = parsedDataArray[i];
                    displayStats_hitting(parsedData);
                }
            })
            .catch(error => {
                console.error("Error:", error);
            });
        
        callback();
    })
}

async function displayTotals_hitting(){
    await new Promise(resolve => setTimeout(resolve, 1000));
    fetch("teams/data/hitting_stats/total_hitting_stats.csv")
        .then(response => response.text())
        .then(csvData => {
            const totalHittingData = parseCSV(csvData, "Hitting");
            displayTotalStats_Hitting(totalHittingData);
        })
    }


run_hitting();



// Pitching

const tableContainer_pitching = document.getElementById("pitching-stats-container");

const table_pitching = document.createElement("table");

function displayStats_pitching(data) {

    const headers = ['', 'Team', 'Player ID', 'Season', 'Player', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP'];

    for (const rowData of data) {
        if (rowData["Player ID"] != playerID) {
            continue;
        }
        
        /*  Create pitching button */

        var existingButton = document.querySelector("#stats-buttons .w3-bar-item.w3-button.tablink");

        var existingPitchingButton = false;

        if(existingButton) {   
            if(existingButton.textContent === "Pitching Stats") {
                existingPitchingButton = true;
            }
        } else {
            openTab('pitching-stats');
        }

        if (!existingPitchingButton) {
            var buttons = document.querySelectorAll("#stats-buttons .w3-button.tablink");
            var buttonAlreadyExists = false;
            
            buttons.forEach(function(button) {
                if (button.textContent === "Pitching Stats") {
                    buttonAlreadyExists = true;
                }
            });

            if (!buttonAlreadyExists) {
                // Create a new button element
                var buttonElement = document.createElement("button");
                buttonElement.className = "w3-bar-item w3-button tablink";
                buttonElement.textContent = "Pitching Stats";
                buttonElement.onclick = function() {
                    openTab('pitching-stats');
                };

                // Find the container by its ID
                var container = document.getElementById("stats-buttons");

                // Append the button to the container
                container.appendChild(buttonElement);
            }
        }

        const teamID = rowData["Team ID"];

        fetch("teams/data/all_teams.csv")
            .then(response => response.text())
            .then(csvData => {
                const teamName = findTeam(csvData, teamID);

                const row = document.createElement("tr");

                for (const header of headers) {
                    const td = document.createElement("td");

                    if ((header === "HB" || header === "HR" || header === "OPP AVG") && isMobile()) {
                        continue;
                    } else if (header === "Season") {
                        const seasonLink = document.createElement("a");
                        /*seasonLink.href = `player_season_info?playerID=${playerID}&season=${rowData[header]}`; Add this later*/ 
                        seasonLink.textContent = rowData[header];
                        td.appendChild(seasonLink);
                    } else if (header === "Team") {
                        const teamLink = document.createElement("a");
                        teamLink.href = `team_season_info?teamID=${rowData["Team ID"]}&season=${rowData["Season"]}`;
                        teamLink.textContent = teamName; 
                        td.appendChild(teamLink);
                    } else if (header == "Player ID" || header === "" || header === "Player"){
                        continue;
                    } else {
                        td.textContent = rowData[header];
                    }
                    row.appendChild(td);
                }
                table_pitching.appendChild(row);

            })
            .catch(error => console.error("Error fetching or parsing CSV:", error));
    }

    tableContainer_pitching.appendChild(table_pitching);

}

function displayTotalStats_Pitching(data) {

    const headers = ['', 'Team', 'Player ID', 'Season', 'Player', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP'];

    for (const rowData of data) {

        if (rowData["Player ID"] != playerID) {
            continue;
        }

        const row = document.createElement("tr");

        for (const header of headers) {
            const td = document.createElement("td");

            if ((header === "HB" || header === "HR" || header === "OPP AVG") && isMobile()) {
                continue;
            } else if (header === "Season") {
                const seasonLink = document.createElement("a");
                /*seasonLink.href = `player_season_info?playerID=${playerID}&season=${rowData[header]}`; Add this later*/ 
                seasonLink.textContent = rowData[header];
                td.appendChild(seasonLink);
            } else if (header == "Player ID" || header === "" || header === "Player"){
                continue;
            } else if(header == "Team"){
                td.textContent = "Total";
            } else {
                td.textContent = rowData[header];
            }
            row.appendChild(td);
        }
        table_pitching.appendChild(row);

    }
    tableContainer_pitching.appendChild(table_pitching);


}

function run_pitching(){
    displayData_pitching(displayTotals_pitching);
}

function displayData_pitching(callback){
    setTimeout(function(){
        getSeasons()
            .then(seasons => {
                displayHeaders("Pitching", table_pitching);
                const fetchPromises = [];

                for (let i = 0; i < seasons.length; i++) {
                    const season = seasons[i];
                    const fetchPromise = fetch (`teams/data/pitching_stats/pitching_stats_${season}.csv`)
                        .then(response => response.text())
                        .then(csvData => {
                            return parseCSV(csvData, "Pitching");
                        });

                    fetchPromises.push(fetchPromise);
                }

                // Wait for all fetch operations to complete
                return Promise.all(fetchPromises);
            })
            .then(parsedDataArray => {
                for (let i = 0; i < parsedDataArray.length; i++) {
                    const parsedData = parsedDataArray[i];
                    displayStats_pitching(parsedData);
                }
            })
            .catch(error => {
                console.error("Error:", error);
            });
        
        callback();
    })
}

async function displayTotals_pitching(){
    await new Promise(resolve => setTimeout(resolve, 1000));
    fetch("teams/data/pitching_stats/total_pitching_stats.csv")
        .then(response => response.text())
        .then(csvData => {
            const totalPitchingData = parseCSV(csvData, "Pitching");
            displayTotalStats_Pitching(totalPitchingData);
        })
    }

run_pitching();
