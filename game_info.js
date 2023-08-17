// Get the team ID and season from the URL query parameters
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const gameID = urlParams.get('gameID');
const season = urlParams.get('season');

const csvFileName = `teams/data/box_scores/d1_hitting_box_${season}.csv`;

const gameInfo = []
const homeTableContainer = document.getElementById("home-table-container");
const awayTableContainer = document.getElementById("away-table-container");

function findGameInfo(csvData, gameID) {
    const lines = csvData.split("\n");

    for (let i = 1; i < lines.length; i++) {
        const currentLine = lines[i].split(",");
        const gameIdColumnIndex = 3;
        const homeIndicatorIndex = 6;
        const teamColumnIndex = 5;
        const opponentColumnIndex = 7;
        const gameDateColumnIndex = 4;
        const teamRuns = 9;
        const opponentRuns = 10;

        if (currentLine[gameIdColumnIndex].slice(1, -1) === gameID) {

            let awayTeam, homeTeam, awayRuns, homeRuns, gameDate;

            if(currentLine[homeIndicatorIndex] === "@") {
                awayTeam = currentLine[teamColumnIndex].slice(1, -1);
                homeTeam = currentLine[opponentColumnIndex].slice(1, -1);
                awayRuns = currentLine[teamRuns];
                homeRuns = currentLine[opponentRuns];
                gameDate = currentLine[gameDateColumnIndex].slice(1, -1);
            } else{
                awayTeam = currentLine[opponentColumnIndex].slice(1, -1);
                homeTeam = currentLine[teamColumnIndex].slice(1, -1);
                awayRuns = currentLine[opponentRuns];
                homeRuns = currentLine[teamRuns];
                gameDate = currentLine[gameDateColumnIndex].slice(1, -1);
            }

            return [awayTeam, homeTeam, awayRuns, homeRuns, gameDate];
        }
    }

    return []; 
}

fetch(`teams/data/game_logs/game_logs_${season}.csv`)
    .then(response => response.text())
    .then(csvData => {
        const gameInfo = findGameInfo(csvData, gameID);

        const pageTitle = document.querySelector('title');
        const pageTitleText = pageTitle.textContent;
        pageTitle.textContent = `Softball Statline  - ${gameInfo[0]} at ${gameInfo[1]} (${gameInfo[4]})`;

        const heading = document.querySelector('h1');
        const headingText = heading.textContent;
        heading.textContent = `${gameInfo[0]} at ${gameInfo[1]} (${gameInfo[4]})`;

        const homeNameElement = document.querySelector('#home-team');
        homeNameElement.textContent = `${gameInfo[1]}: ${gameInfo[3]}`;

        const awayNameElement = document.querySelector('#away-team');
        awayNameElement.textContent = `${gameInfo[0]}: ${gameInfo[2]}`;
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));

function parseCSV(csvData) {
    const lines = csvData.split("\n");
    const headers = ['', 'Game ID', 'Team', 'Opponent', 'Player', 'Pos', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'BB', 'HBP', 'SO'];
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

function displayInfo(gameInfo) {
    fetch(`teams/data/game_logs/game_logs_${season}.csv`)
    .then(response => response.text())
    .then(csvData => {
        const teamInfo = findGameInfo(csvData, gameID);

        const homeTable = document.createElement("table");
        const awayTable = document.createElement("table");
        const headers = Object.keys(gameInfo[0]);

        const homeHeaderRow = document.createElement("tr");
        const awayHeaderRow = document.createElement("tr");

        for (const header of headers) {
            if (header === "Game ID" || header === "Opponent" || header === "Team") {
                continue;
            } 
            const thHome = document.createElement("th");
            thHome.textContent = header;
            homeHeaderRow.appendChild(thHome);

            const thAway = document.createElement("th");
            thAway.textContent = header;
            awayHeaderRow.appendChild(thAway);
        }

        homeTable.appendChild(homeHeaderRow);
        awayTable.appendChild(awayHeaderRow);

        for (const playerData of gameInfo) {
            const row = document.createElement("tr");
            
            if (playerData["Game ID"] != gameID | (parseInt(playerData["AB"]) + parseInt(playerData["BB"]) + parseInt(playerData["HBP"]) === 0)) {
                continue;
            }

            console.log(playerData)

            for (const header of headers) {
                if (header === "Game ID" || header === "Opponent" || header === "Team") {
                    continue;
                }

                const cell = document.createElement("td");
                cell.textContent = playerData[header];
                row.appendChild(cell);
            }
            
            if(playerData["Opponent"] === teamInfo[0]) {
                homeTable.appendChild(row);
            } else {
                awayTable.appendChild(row);
            }
        }

        homeTableContainer.appendChild(homeTable);
        awayTableContainer.appendChild(awayTable);
    })

}


 fetch(csvFileName)
    .then(response => response.text())
    .then(csvData => {
        const parsedData = parseCSV(csvData);
        displayInfo(parsedData);
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));


    





