// Get the team ID and season from the URL query parameters
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const teamID = urlParams.get('teamID');
let statSeasons = [2016, 2017, 2018, 2019, 2020, 2021, 2022, 2023, 2024, 2025]
statSeasons.reverse();

function isMobile() {
    return window.matchMedia("(max-width: 768px)").matches;
}

// Filter teams for search bar //

const allTeams = [];

function displayTeam(teamArray) {
    const teamList = document.getElementById("teams-filtered");
    teamList.innerHTML = "";

    // Sort the teamArray alphabetically by team_name
    teamArray.sort((a, b) => a.team_name.localeCompare(b.team_name));

    teamArray.forEach(team => {
        const link = document.createElement("a");

        link.href = `team_info?teamID=${team.team_id}`;
        link.textContent = team.team_name;

        // Optionally style the link (e.g., add a class or style directly)
        link.classList.add("team-link");  // Add a class for styling purposes

        // Append the link to the teamList
        teamList.appendChild(link);

        // Optionally, add a line break after each link
        teamList.appendChild(document.createElement("br"));
    });
}

function filterTeam(searchTerm, teamArray) {
    const filteredTeam = teamArray.filter(team => {
        return team.team_name.toLowerCase().includes(searchTerm.toLowerCase());
    });

    // Display nothing if there are more than 10 teams, else display the teams
    if (filteredTeam.length <= 10) {
        displayTeam(filteredTeam);
    } else {
        // Optionally, clear the team list if there are more than 10 teams
        displayTeam([]); // Clear the display if the list is too long
    }
}


const searchInput = document.getElementById("search-bar");
searchInput.addEventListener("input", () => {
    filterTeam(searchInput.value, allTeams);
});

Papa.parse("teams/data/teams_d1.csv", {
    download: true,
    header: true,
    skipEmptyLines: true,
    complete: function (results) {
        allTeams.push(...results.data);
    }
});

Papa.parse("teams/data/teams_d2.csv", {
    download: true,
    header: true,
    skipEmptyLines: true,
    complete: function (results) {
        allTeams.push(...results.data);
    }
});

Papa.parse("teams/data/teams_d3.csv", {
    download: true,
    header: true,
    skipEmptyLines: true,
    complete: function (results) {
        allTeams.push(...results.data);
    }
});

// Top Container Filling //

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

function findTeamRecordInfo(rankings, teamID) {
    const lines = rankings.split("\n")

    let record = "0-0";
    let rpi = 0;
    let sos = 0;
    let power_ranking = 0;

    for (let i = 1; i < lines.length; i++) {
        const currentLine = lines[i].split(",");
        let cur_ID = currentLine[13];
        if (cur_ID.startsWith('"') && cur_ID.endsWith('"')) {
            cur_ID = cur_ID.slice(1, -1);
        }

        if(cur_ID == teamID) {
            record = currentLine[2].slice(0, -2);
            rpi = currentLine[3];
            sos = currentLine[22];
            power_ranking = currentLine[11];
            logo = currentLine[0];
            break;
        }
    }
    
    return [record, rpi, sos, power_ranking, logo];

}

fetch("teams/data/all_teams.csv")
    .then(response => response.text())
    .then(csvData => {
        const teamName = findTeam(csvData, teamID);

        const pageTitle = document.querySelector('title');
        const pageTitleText = pageTitle.textContent;
        pageTitle.textContent = `Softball Statline  - ${teamName}`;

        const teamNameContainer = document.querySelector('.team-name');
        teamNameContainer.textContent = teamName
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));

fetch("rankings/d1_rankings.csv")
    .then(response => response.text())
    .then(csvData => {
        const recordInfo = findTeamRecordInfo(csvData, teamID);

        const record = recordInfo[0];
        const rpi = recordInfo[1];
        const sos = recordInfo[2];
        const power_ranking = recordInfo[3];
        const logo = recordInfo[4];

        const recordContainer = document.querySelector('#team-record');
        recordContainer.innerHTML = "W-L<br>" + record;

        const offRankingContainer = document.querySelector('#team-rpi');
        offRankingContainer.innerHTML = "RPI<br>" + rpi;

        const defRankingContainer = document.querySelector('#team-sos');
        defRankingContainer.innerHTML = "SOS<br>" + sos;

        const powerRankingContainer = document.querySelector('#team-power');
        powerRankingContainer.innerHTML = "Power<br>" + power_ranking;

        const logoContainer = document.querySelector('#team-logo');
        logoContainer.src = logo;
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));

const csvFileName = `teams/data/team_info/team_${teamID}.csv`;

const teamInfo = []
const tableContainer = document.getElementById("table-container");

// Populate History Table //

function parseHistoryCSV(csvData) {
    const lines = csvData.split("\n");
    const headers = ['', 'Season', 'Head Coach', 'Conf.', 'Record', 'Win%'];
    const rows = [];

    for (let i = 1; i < lines.length - 1; i++) {
        const currentLine = lines[i].split(",");
        const row = {};
        for (let j = 1; j < headers.length; j++) {
            const header = headers[j];
            let value = currentLine[j] ? currentLine[j].trim() : ''; // Handle empty or missing values

            // Remove quotes around the value if present
            if (value.startsWith('"') && value.endsWith('"')) {
                value = value.slice(1, -1);
            }

            if (header === 'Win%') {
                // Check if the value is numeric
                if (!isNaN(value) && value !== '') {
                    value = parseFloat(value).toFixed(3);
                } else {
                    value = '';  // Set to blank if not numeric
                }
            }

            if (['Record'].includes(header)) {
                value = value.slice(0, -2);
            }
            

            row[header] = value;
        }
        rows.push(row);
    }

    rows.sort((a, b) => b["Season"] - a["Season"]);

    return rows;
}

function displayHistory(teamInfo) {
    const table = document.createElement("table");
    table.classList.add("history-table");
    const headers = Object.keys(teamInfo[0]);

    const headerRow = document.createElement("tr");

    for (const header of headers) {
        const th = document.createElement("th");
        th.textContent = header;
        headerRow.appendChild(th);
    }

    table.appendChild(headerRow);

    teamInfo.sort((a, b) => b["Season"] - a["Season"]);


    const fetchCoachPromises = teamInfo.map(rowData =>
        fetch("coaches/coach_ids.csv")
            .then(response => response.text())
            .then(csvData => {
                const coachID = findCoach(csvData, rowData["Head Coach"]);
                return coachID;
            })
            .catch(error => {
                console.error("Error fetching or parsing CSV:", error);
                return null; // Handle errors by returning null
            })
    );
    
    Promise.all(fetchCoachPromises)
        .then(coachIDs => {
            for (let i = 0; i < teamInfo.length; i++) {
                const rowData = teamInfo[i];
                const coachID = coachIDs[i];
    
                const row = document.createElement("tr");
    
                for (const header of headers) {
                    const td = document.createElement("td");
    
                    if (header === "Season" && parseInt(rowData[header]) >= 2016) {
                        const seasonLink = document.createElement("p");
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
            }
        });

    tableContainer.appendChild(table);
}




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
            coachID = currentLine[3]
            break;
        }
    }
    return coachID;
}

// Populate Hitting Stats Table

// Hitting Stats

function parseStatsCSV(csvData, type) {
    const lines = csvData.split("\n");
    if (type === "hitting") {
        headers = ['', 'Team ID', 'Player ID', 'Season', 'Player', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'R', 'BB', 'HBP', 'K', 'SB', 'CS', 'AVG', 'OBP', 'OPS'];
      } else if (type === "gamelog") {
        headers = ['', 'Team ID', 'Opponent ID', 'Game ID', 'Game Date', 'Team', '', 'Opponent', 'Result', 'R', 'RA', 'Record']; 
      } else if (type === "pitching") {
        headers = ['', 'Team ID', 'Player ID', 'Season', 'Player', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP'];
      }

    const rows = [];

    for (let i = 1; i < lines.length; i++) {
        try {
            const currentLine = lines[i].split(",");
            const row = {};
            for (let j = 1; j < headers.length; j++) {
                const header = headers[j];
                let value = currentLine[j] ? currentLine[j].trim() : ''; // Handle empty or missing values

                // Remove quotes around the value if present
                if (value.startsWith('"') && value.endsWith('"')) {
                    value = value.slice(1, -1);
                }

                if (['AVG', 'OBP', 'OPS'].includes(header)) {
                    value = parseFloat(value).toFixed(3);
                }

                if (['Record'].includes(header)) {
                    value = value.slice(0, -2);
                }

                row[header] = value;
            }
            rows.push(row);
        } catch (error) {
            console.log('Error parsing line ${i}: ', error);
        }
    }

    return rows;
}

// Function to display the stats for the selected season
function displaySeasonStats_hitting(csvData) {
    const table = document.createElement("table");
    const headers = isMobile() ? ['Player', 'AB', 'H', 'HR', 'RBI', 'AVG', 'OPS'] : ['Player', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'BB', 'K', 'AVG', 'OBP', 'OPS'];
    const headerRow = document.createElement("tr");

    // Create headers and add click event for sorting
    headers.forEach((header, index) => {
        const th = document.createElement("th");
        th.textContent = header;
        th.style = "padding: 10px";
        
        // Add sorting functionality
        th.addEventListener("click", () => sortTable(index, csvData));
        headerRow.appendChild(th);
    });

    table.appendChild(headerRow);

    // Create the table rows based on CSV data
    for (const currentLine of csvData) {
        let curTeamID = currentLine["Team ID"];
        const curSeason = currentLine["Season"].trim();
        let curAB = currentLine["AB"];
        
        if (curTeamID === teamID && curSeason === season) {
            const row = document.createElement("tr");
            headers.forEach((header) => {
                const td = document.createElement("td");
                if (header === "Player") {
                    const a = document.createElement("a");
                    a.textContent = currentLine[header];
                    a.href = "player_info?playerID=" + currentLine["Player ID"];
                    td.appendChild(a);
                } else {
                    td.textContent = currentLine[header];
                }
                row.appendChild(td);
            });
            table.appendChild(row);
        }
    }

    const tableContainer_hitting = document.getElementById("table-container");

    // Clear existing table content and append the new table
    tableContainer_hitting.innerHTML = '';
    tableContainer_hitting.appendChild(table);
}

// Function to display the stats for the selected season
function displaySeasonStats_pitching(csvData) {
    const table = document.createElement("table");
    const headers = isMobile() ? ['Player', 'IP', 'H', 'BB', 'SO', 'HR', 'ERA', 'FIP'] : ['Player', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP'];

    const headerRow = document.createElement("tr");

    for (const header of headers) {
        const th = document.createElement("th");
        th.textContent = header;
        headerRow.appendChild(th);
    }
    
    table.appendChild(headerRow);
    // Find the indices of the columns containing team ID and season

    for (const currentLine of csvData) {
        let curTeamID = currentLine["Team ID"];
        const curSeason = currentLine["Season"].trim();
        let curIP = currentLine["IP"];
        if (curTeamID === teamID && curSeason === season) {
            const row = document.createElement("tr");
            for (const header of headers) {
                const td = document.createElement("td");
                if (header === "Player") {
                    const a = document.createElement("a");
                    a.textContent = currentLine[header];
                    a.href = "player_info?playerID=" + currentLine["Player ID"];

                    td.appendChild(a);
                    row.appendChild(td);
                } else {
                    td.textContent = currentLine[header];
                }
                row.appendChild(td);
            }
        table.appendChild(row);
        }
    }

    const tableContainer_pitching= document.getElementById("table-container");

    // Clear existing table content and append the new table
    tableContainer_pitching.innerHTML = '';
    tableContainer_pitching.appendChild(table);

}

// Display Game Log/Schedule //
function displaySeasonStats_gamelog(csvData) {
    const table = document.createElement("table");
    let headers;
    if(isMobile()) {
        headers = ['Game Date', 'Home Indicator', 'Opponent', 'Result', 'R', 'RA', 'Record']
    } else {
        headers = ['Box Score', 'Game Date', 'Home Indicator', 'Opponent', 'Result', 'R', 'RA', 'Record']
    }

    const headerRow = document.createElement("tr");

    for (const header of headers) {
        const th = document.createElement("th");
        if(header === "Home Indicator") {
            th.textContent = "";
        } else {
            th.textContent = header;
        }
        headerRow.appendChild(th);
    }
    
    table.appendChild(headerRow);
    // Find the indices of the columns containing team ID and season

    for (const currentLine of csvData) {
        let curTeamID = currentLine["Team ID"];
        if (curTeamID === teamID) {

            const row = document.createElement("tr");

            for (const header of headers) {
                if (header === "Opponent") {
                    const a = document.createElement("a");
                    a.textContent = currentLine[header];
                    a.href = "team_season_info?teamID=" + currentLine["Opponent ID"] + "&season=" + season;
    
                    const td = document.createElement("td");
                    td.appendChild(a); // Append the link to the table cell
                    row.appendChild(td);
                } else if (header === "Home Indicator") {
                    const td = document.createElement("td");
                    td.textContent = currentLine[""];
                    row.appendChild(td);
                } else if ((header === "Game Date") && isMobile()) {
                    const a = document.createElement("a");
                    a.textContent = currentLine[header];
                    a.href = "game_info?gameID=" + currentLine["Game ID"] + "&season=" + season;
                    const td = document.createElement("td");
                    td.appendChild(a);
                    row.appendChild(td);
                } else if(header === "Box Score"){
                    const a = document.createElement("a");
                    a.textContent = "Link";
                    a.href = "game_info?gameID=" + currentLine["Game ID"] + "&season=" + season;
                    const td = document.createElement("td");
                    td.appendChild(a);
                    row.appendChild(td);
                } else {
                    const td = document.createElement("td");
                    td.textContent = currentLine[header];
                    if ((header === "Team") && isMobile()) {
                        td.classList.add("mobile-hide"); // Add the mobile-hide class
                    }
                    row.appendChild(td);
                }
            }
        table.appendChild(row);
        }
    }

    const tableContainer_gamelog= document.getElementById("table-container");

    // Clear existing table content and append the new table
    tableContainer_gamelog.innerHTML = '';
    tableContainer_gamelog.appendChild(table);

}



// Default is history //

if (teamID) {
    fetch(csvFileName)
        .then(response => response.text())
        .then(csvData => {
            const parsedData = parseHistoryCSV(csvData);
            displayHistory(parsedData);
        })
        .catch(error => console.error("Error fetching or parsing CSV:", error));
}

// Check for Press of History/Stats/Schedule Button //

let selectedButton = 'history-button'

document.querySelectorAll('.button-container button').forEach(button => {
    button.addEventListener('click', function() {
        // Remove 'pressed' from all buttons to ensure only one is active at a time
        document.querySelectorAll('.button-container button').forEach(btn => btn.classList.remove('pressed'));

        // Add 'pressed' to the clicked button
        this.classList.add('pressed');

        // Set selectedButton to the clicked button's id
        selectedButton = this.id;

        // Clear previous table content if any button other than 'history-button' is clicked
        const tableContainer = document.querySelector('#table-container');
        tableContainer.innerHTML = '';  // Clear any previous content

        // Only display the history table if the 'history-button' is selected
        if (selectedButton === 'history-button') {
            // Remove hitting and pitching buttons //
            const hittingButton = document.getElementById('hitting-button')
            hittingButton.style = "display: none"

            const pitchingButton = document.getElementById('pitching-button')
            pitchingButton.style = "display: none"

            const seasonSelect = document.getElementById('season-select');
            seasonSelect.innerHTML = '';

            fetch(csvFileName)
                .then(response => response.text())
                .then(csvData => {
                    const parsedData = parseHistoryCSV(csvData);
                    displayHistory(parsedData);
                })
                .catch(error => console.error("Error fetching or parsing CSV:", error));
        }
        else if (selectedButton === 'stats-button') {
            // Fill Seasons in Dropdown //

            const seasonSelect = document.getElementById('season-select');
            seasonSelect.innerHTML = '';

            statSeasons.forEach(season => {
                const option = document.createElement('option');
                option.value = season;
                option.textContent = season;
                seasonSelect.appendChild(option);
            });

            // Show hitting and pitching buttons //
            const hittingButton = document.getElementById('hitting-button')
            hittingButton.style = "display: block"
            document.querySelectorAll('.stats-button-container button').forEach(btn => btn.classList.remove('pressed'));
            hittingButton.classList.add('pressed');

            const pitchingButton = document.getElementById('pitching-button')
            pitchingButton.style = "display: block"

            seasonContainer = document.getElementById('season-select')
            season = seasonContainer.value;

            // Construct the CSV file name for the selected season
            const csvFileName_hitting = `teams/data/hitting_stats/hitting_stats_${season}.csv`;

            fetch(csvFileName_hitting)
                .then(response => response.text())
                .then(csvData => {
                    const parsedData = parseStatsCSV(csvData, "hitting");
                    displaySeasonStats_hitting(parsedData);
                })
                .catch(error => console.error("Error fetching or parsing CSV:", error));

                // Add event listener for the season select dropdown to update dynamically
                seasonContainer.addEventListener('change', function () {
                    const activeButton = document.querySelector('.button-container .pressed');

                    if (activeButton && activeButton.id === 'stats-button') {

                        season = seasonContainer.value;

                        // Determine which button is currently pressed
                        const activeButton = document.querySelector('.stats-button-container .pressed');

                        if (activeButton) {
                            if (activeButton.id === 'hitting-button') {
                                const csvFileName_hitting = `teams/data/hitting_stats/hitting_stats_${season}.csv`;

                                fetch(csvFileName_hitting)
                                    .then(response => response.text())
                                    .then(csvData => {
                                        const parsedData = parseStatsCSV(csvData, "hitting");
                                        displaySeasonStats_hitting(parsedData);
                                    })
                                    .catch(error => console.error("Error fetching or parsing CSV:", error));

                            } else if (activeButton.id === 'pitching-button') {
                                const csvFileName_pitching = `teams/data/pitching_stats/pitching_stats_${season}.csv`;

                                fetch(csvFileName_pitching)
                                    .then(response => response.text())
                                    .then(csvData => {
                                        const parsedData = parseStatsCSV(csvData, "pitching");
                                        displaySeasonStats_pitching(parsedData);
                                    })
                                    .catch(error => console.error("Error fetching or parsing CSV:", error));
                            }
                        }
                    }
                });


                document.querySelectorAll('.stats-button-container button').forEach(button => {
                    button.addEventListener('click', function() {
                        // Remove 'pressed' from all stats buttons to ensure only one is active at a time
                        document.querySelectorAll('.stats-button-container button').forEach(btn => btn.classList.remove('pressed'));
                
                        // Add 'pressed' to the clicked button
                        this.classList.add('pressed');
                
                        // Set selectedButton to the clicked button's id
                        selectedStatsButton = this.id;
                        
                        if (selectedStatsButton === 'hitting-button') {
                            
                            seasonContainer = document.getElementById('season-select');
                            season = seasonContainer.value;
                
                            // Construct the CSV file name for the selected season
                            const csvFileName_hitting = `teams/data/hitting_stats/hitting_stats_${season}.csv`;
                
                            // Fetch the CSV data for the selected season
                            fetch(csvFileName_hitting)
                                .then(response => response.text())
                                .then(csvData => {
                                    const parsedData = parseStatsCSV(csvData, "hitting");
                                    displaySeasonStats_hitting(parsedData);
                                })
                                .catch(error => console.error("Error fetching or parsing CSV:", error));
                        } else {
                            seasonContainer = document.getElementById('season-select');
                            season = seasonContainer.value;
                
                            // Construct the CSV file name for the selected season
                            const csvFileName_pitching = `teams/data/pitching_stats/pitching_stats_${season}.csv`;
                
                            // Fetch the CSV data for the selected season
                            fetch(csvFileName_pitching)
                                .then(response => response.text())
                                .then(csvData => {
                                    const parsedData = parseStatsCSV(csvData, "pitching");
                                    displaySeasonStats_pitching(parsedData);
                                })
                                .catch(error => console.error("Error fetching or parsing CSV:", error));
                        }
                    });
                });
                
        }
        else if (selectedButton === 'schedule-button') {
            // Remove hitting and pitching buttons //
            const hittingButton = document.getElementById('hitting-button')
            hittingButton.style = "display: none"

            const pitchingButton = document.getElementById('pitching-button')
            pitchingButton.style = "display: none"
            
            // Fill Seasons in Dropdown //

            seasonContainer = document.getElementById('season-select');
            seasonContainer.innerHTML = '';

            statSeasons.forEach(season => {
                const option = document.createElement('option');
                option.value = season;
                option.textContent = season;
                seasonContainer.appendChild(option);
            });

            season = seasonContainer.value;
            const csvFileName_gamelog = `teams/data/game_logs/game_logs_${season}.csv`;

            fetch(csvFileName_gamelog)
                .then(response => response.text())
                .then(csvData => {
                    const parsedData = parseStatsCSV(csvData, "gamelog");
                    displaySeasonStats_gamelog(parsedData);
                })
                .catch(error => console.error("Error fetching or parsing CSV:", error));

            seasonContainer.addEventListener('change', function () {
                const activeButton = document.querySelector('.button-container .pressed');
            
                if (activeButton && activeButton.id === 'schedule-button') {
                    season = seasonContainer.value;
                    const csvFileName_gamelog = `teams/data/game_logs/game_logs_${season}.csv`;
            
                    fetch(csvFileName_gamelog)
                        .then(response => response.text())
                        .then(csvData => {
                            const parsedData = parseStatsCSV(csvData, "gamelog");
                            displaySeasonStats_gamelog(parsedData);
                        })
                        .catch(error => console.error("Error fetching or parsing CSV:", error));
                }
            });
                
        }
    });
});



