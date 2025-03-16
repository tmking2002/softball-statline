// Get the player ID and season from the URL query parameters
const queryString = window.location.search;
const urlParams = new URLSearchParams(queryString);
const playerID = urlParams.get('playerID');

document.addEventListener("DOMContentLoaded", function() {
    // Define the playerID (you can replace this with the actual player ID)
    const urlParams = new URLSearchParams(window.location.search);
    const playerID = urlParams.get('playerID');

    // Fetch the CSV data
    fetch('teams/data/pitching_stats/total_pitching_stats.csv')
        .then(response => response.text())
        .then(csvText => {
            // Parse the CSV data into an array of objects
            const rows = csvText.split('\n').map(row => row.split(','));
            const headers = rows[0]; // First row contains the headers
            const playerIdIndex = headers.indexOf('\"player_id\"'); // Find the column index for player_id
            
            // Check if playerID exists in the player_id column
            let playerExists = false;
            for (let i = 1; i < rows.length - 1; i++) { // Start from 1 to skip the header row
                if (rows[i][playerIdIndex] === playerID) {
                    playerExists = true;
                    break;
                }
            }

            // If playerID is not found, remove the pitching button
            if (!playerExists) {
                const pitchingButton = document.querySelector('#pitching-button');
                if (pitchingButton) {
                    pitchingButton.remove();
                }
            }
        })
        .catch(error => {
            console.error('Error loading CSV file:', error);
        });

    // Fetch the CSV data
    fetch('teams/data/hitting_stats/total_hitting_stats.csv')
        .then(response => response.text())
        .then(csvText => {
            // Parse the CSV data into an array of objects
            const rows = csvText.split('\n').map(row => row.split(','));
            const headers = rows[0]; // First row contains the headers
            const playerIdIndex = headers.indexOf('\"player_id\"'); // Find the column index for player_id
            
            // Check if playerID exists in the player_id column
            let playerExists = false;
            for (let i = 1; i < rows.length - 1; i++) { // Start from 1 to skip the header row
                if (rows[i][playerIdIndex] === playerID) {
                    playerExists = true;
                    break;
                }
            }

            // If playerID is not found, remove the hitting button
            if (!playerExists) {
                const hittingButton = document.querySelector('#hitting-button');
                if (hittingButton) {
                    hittingButton.remove();
                }
            }
        })
        .catch(error => {
            console.error('Error loading CSV file:', error);
        });
});

function isMobile() {
    return window.matchMedia("(max-width: 768px)").matches;
}

// Filter players for search bar //

const allPlayers = [];

function displayPlayer(playerArray) {
    const playerList = document.getElementById("players-filtered");
    playerList.innerHTML = "";

    // Sort the playerArray alphabetically by player
    playerArray.sort((a, b) => a.player.localeCompare(b.player));

    playerArray.forEach(player => {
        const link = document.createElement("a");

        link.href = `player_info?playerID=${player.player_id}`;
        link.textContent = player.player;

        // Optionally style the link (e.g., add a class or style directly)
        link.classList.add("player-link");  // Add a class for styling purposes

        // Append the link to the playerList
        playerList.appendChild(link);

        // Optionally, add a line break after each link
        playerList.appendChild(document.createElement("br"));
    });
}

function filterPlayers(searchTerm, playerArray) {
    const filteredPlayer = playerArray.filter(player => {
        return player.player.toLowerCase().includes(searchTerm.toLowerCase());
    });

    // Display nothing if there are more than 30 players, else display the players
    if (filteredPlayer.length <= 30) {
        displayPlayer(filteredPlayer);
    } else {
        // Optionally, clear the player list if there are more than 10 players
        displayPlayer([]); // Clear the display if the list is too long
    }
}


const searchInput = document.getElementById("search-bar");
searchInput.addEventListener("input", () => {
    filterPlayers(searchInput.value, allPlayers);
});

function formatSeasons(seasons) {
    // Ensure seasons is an array before applying join
    if (Array.isArray(seasons)) {
        return seasons.length === 1 ? seasons[0].toString() : seasons.join('+');
    } else if (seasons) {
        return seasons.toString(); // In case 'Seasons' is a string or other format
    }
    return ''; // Return empty string if 'Seasons' is undefined or not valid
}

// Declare statSeasons globally
let statSeasons;

Papa.parse("players/data/all_players.csv", {
    download: true,
    header: true,
    skipEmptyLines: true,
    complete: function (results) {
        allPlayers.push(...results.data);

        // Use a regular for loop to break once player is found
        for (let i = 0; i < allPlayers.length; i++) {
            const player = allPlayers[i];
            
            if (player.player_id === playerID) {
                statSeasons = player['seasons'];

                // Adjust the season format (remove '+' if only one season)
                statSeasons = formatSeasons(statSeasons);

                let playerClass = "Graduated"; // Default value if no valid season year found
                const cur_year = 2025;
            
                // Split the statSeasons to get the seasons array
                const seasonsArray = statSeasons.split('+').map(s => s.trim());
            
                // Determine the max and min season years
                const maxYear = Math.max(...seasonsArray.map(season => parseInt(season.trim())));
                const minYear = Math.min(...seasonsArray.map(season => parseInt(season.trim())));
            
                // Determine class based on maxYear and minYear
                if (maxYear === cur_year) {
                    if (minYear === cur_year){
                        playerClass = "Freshman";
                    } else if (minYear === cur_year - 1) {
                        playerClass = "Sophomore";
                    } else if (minYear === cur_year - 2) {
                        playerClass = "Junior";
                    } else if (minYear === cur_year - 3) {
                        playerClass = "Senior";
                    } else if (minYear <= cur_year - 4) {
                        playerClass = "Grad Senior";
                    }
                } else if (maxYear < cur_year) {
                    playerClass = `Graduated in ${maxYear}`;
                }

                grad_container = document.querySelector("#player-grad");
                grad_container.textContent = playerClass;

                // Break the loop after finding the player
                break;
            }
        }
    }
});

// Top Container Filling //

function findPlayer(csvData, playerID) {

    const lines = csvData.split("\n");

    let playerName = "a";
    let headshot_link = "NA";

    // Find the player name and headshot link
    for (let i = 1; i < lines.length; i++) {
        const currentLine = lines[i].split(",");
        let cur_ID = currentLine[1];
        if (cur_ID.startsWith('"') && cur_ID.endsWith('"')) {
            cur_ID = cur_ID.slice(1, -1);
        }

        if (cur_ID == playerID) {
            playerName = currentLine[2].slice(1, -1);
            headshot_link = currentLine[7].slice(1, -2);
            break;
        }
    }

    // Return playerName, headshot_link, and class
    return { playerName, headshot_link};
}



fetch("players/data/all_players.csv")
    .then(response => response.text())
    .then(csvData => {
        const { playerName, headshot_link} = findPlayer(csvData, playerID);

        // Update the page title
        const pageTitle = document.querySelector('title');
        pageTitle.textContent = `Softball Statline - ${playerName}`;

        // Update player name in the container
        const playerNameContainer = document.querySelector('.player-name');
        playerNameContainer.textContent = playerName;

        // Update player headshot container
        const headshotContainer = document.querySelector('.headshot-container');
        headshotContainer.innerHTML = ''; // Clear existing content

        if (headshot_link !== "") {
            const imgElement = document.createElement('img');
            imgElement.src = headshot_link;
            imgElement.id = "headshot";
            headshotContainer.appendChild(imgElement); // Append the headshot image to the container
        } else {
            // Create a Font Awesome icon if no headshot is available
            const iconElement = document.createElement('i');
            iconElement.classList.add('fa-solid', 'fa-user', 'fa-4x'); // Font Awesome user icon
            headshotContainer.appendChild(iconElement); // Append the icon to the container
        }
    })
    .catch(error => console.error("Error fetching or parsing CSV:", error));


// Populate Hitting Stats Table

// Hitting Stats

function parseStatsCSV(csvData, type) {
    const lines = csvData.split("\n");
    if (type === "hitting") {
        headers = ['', 'Team ID', 'Player ID', 'Season', 'Player', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'R', 'BB', 'HBP', 'K', 'SB', 'CS', 'AVG', 'OBP', 'OPS', 'Team'];
      } else if (type === "pitching") {
        headers = ['', 'Team ID', 'Player ID', 'Season', 'Player', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP', 'Team'];
      } else if (type === "gamelog_hitting") {
        headers = ['', 'Game ID', 'Game Date', 'Team', 'Opponent', 'Player ID', 'Player', 'Pos', 'AB', 'R', 'H', 'RBI', 'HR', 'K', 'BB']; 
      } else if (type === "gamelog_pitching") {
        headers = ['', 'Game ID', 'Team', 'Opponent', 'Player ID', 'Player', 'IP', 'HA', 'ER', 'BB', 'HB', 'SO', 'BF', 'HR A', 'GO', 'FO', 'Game Order']; 
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

                if (['AVG', 'OBP', 'OPS', 'OPP AVG', 'ERA', 'WHIP', 'FIP'].includes(header)) {
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

function displaySeasonStats_hitting(csvData) {
    const tableContainer_hitting = document.getElementById("table-container");

    // Create the table only if it doesn't exist
    let table = tableContainer_hitting.querySelector("table");
    let headers = [];

    if (!table) {
        table = document.createElement("table");
        headers = ['Season', 'Team', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'BB', 'K', 'AVG', 'OBP', 'OPS'];
        const headerRow = document.createElement("tr");

        // Create headers and add click event for sorting
        headers.forEach((header, index) => {
            const th = document.createElement("th");
            th.textContent = header;
            th.style = "padding: 10px";
            headerRow.appendChild(th);
        });

        table.appendChild(headerRow);
        tableContainer_hitting.appendChild(table); // Append table to the container
    }

    // Load the teams data
    fetch('teams/data/all_teams.csv')
        .then(response => response.text())
        .then(teamsCsvText => {
            const rows = teamsCsvText.split('\n').map(row => row.split(','));
            let headers = rows[0];
            const teamIdIndex = headers.indexOf('"team_id"');
            const teamNameIndex = headers.indexOf('"team_name"');

            const teamMap = {};  // Map to store Team ID -> Team Name
            for (let i = 1; i < rows.length - 1; i++) {
                const teamId = rows[i][teamIdIndex].slice(1, -1);
                const teamName = rows[i][teamNameIndex].slice(1, -1);
                teamMap[teamId] = teamName;
            }

            // Create the table rows based on CSV data for each season
            for (const currentLine of csvData) {
                let curPlayerID = currentLine["Player ID"];
                const curSeason = currentLine["Season"].trim();
                let curAB = currentLine["AB"];

                if (curPlayerID === playerID) {
                    const row = document.createElement("tr");
                    headers = ['Season', 'Team', 'AB', 'H', '2B', '3B', 'HR', 'RBI', 'BB', 'K', 'AVG', 'OBP', 'OPS'];

                    for (let i = 0; i < headers.length; i++) {
                        const header = headers[i];
                        const td = document.createElement("td");

                        if ((header === "Team") && (currentLine["Team ID"] === "Total")) {
                            td.textContent = "Total";
                        } else if (header === "Team") {
                            const teamId = currentLine["Team ID"];
                            const teamName = teamMap[teamId] || "Unknown"; // Get team name from the map
                            td.textContent = teamName;
                        } else {
                            td.textContent = currentLine[header];
                        }

                        row.appendChild(td); // Append the data cell to the row
                    }

                    table.appendChild(row); // Append the row for the season
                }
            }
        })
        .catch(error => {
            console.error('Error loading teams data:', error);
        });
}

// Function to display the stats for the selected season
function displaySeasonStats_pitching(csvData) {
    const tableContainer_pitching = document.getElementById("table-container");

    // Create the table only if it doesn't exist
    let table = tableContainer_pitching.querySelector("table");
    let headers = [];

    if (!table) {
        table = document.createElement("table");
        headers = ['Season', 'Team', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP'];
        const headerRow = document.createElement("tr");

        // Create headers and add click event for sorting
        headers.forEach((header, index) => {
            const th = document.createElement("th");
            th.textContent = header;
            th.style = "padding: 10px";
            headerRow.appendChild(th);
        });

        table.appendChild(headerRow);
        tableContainer_pitching.appendChild(table); // Append table to the container
    }

    // Load the teams data
    fetch('teams/data/all_teams.csv')
        .then(response => response.text())
        .then(teamsCsvText => {
            const rows = teamsCsvText.split('\n').map(row => row.split(','));
            let headers = rows[0];
            const teamIdIndex = headers.indexOf('"team_id"');
            const teamNameIndex = headers.indexOf('"team_name"');

            const teamMap = {};  // Map to store Team ID -> Team Name
            for (let i = 1; i < rows.length - 1; i++) {
                const teamId = rows[i][teamIdIndex].slice(1, -1);
                const teamName = rows[i][teamNameIndex].slice(1, -1);
                teamMap[teamId] = teamName;
            }

            // Create the table rows based on CSV data for each season
            for (const currentLine of csvData) {
                let curPlayerID = currentLine["Player ID"];
                const curSeason = currentLine["Season"].trim();
                let curAB = currentLine["AB"];
                
                if (curPlayerID === playerID) {
                    const row = document.createElement("tr");
                    headers = ['Season', 'Team', 'IP', 'H', 'BB', 'HB', 'SO', 'HR', 'ERA', 'OPP AVG', 'WHIP', 'FIP'];

                    for (let i = 0; i < headers.length; i++) {
                        const header = headers[i];
                        const td = document.createElement("td");
                    
                        if ((header === "Team") && (currentLine["Team ID"] === "Total")) {
                            td.textContent = "Total";
                        } else if(header === "Team") {
                            const teamId = currentLine["Team ID"];
                            const teamName = teamMap[teamId] || "Unknown"; // Get team name from the map
                            td.textContent = teamName;
                        } else {
                            td.textContent = currentLine[header];
                        }
                    
                        row.appendChild(td); // Append the data cell to the row
                    }
                    
                    table.appendChild(row); // Append the row for the season
                }
            }
        })
        .catch(error => {
            console.error('Error loading teams data:', error);
        });
}

// Function to display the stats for the selected season
function displayGameLog_hitting(csvData) {
    const tableContainer_hitting = document.getElementById("gamelog-container");

    // Create the table only if it doesn't exist
    let table = tableContainer_hitting.querySelector("table");
    let headers = [];

    if (!table) {
        table = document.createElement("table");
        headers = ['Box', 'Game Date', 'Opponent', 'Pos', 'AB', 'H', 'HR', 'RBI', 'R', 'K', 'BB'];
        const headerRow = document.createElement("tr");

        // Create headers
        headers.forEach((header) => {
            const th = document.createElement("th");
            th.textContent = header;
            th.style = "padding: 10px";
            headerRow.appendChild(th);
        });

        table.appendChild(headerRow);
        tableContainer_hitting.appendChild(table);
    }

    // Filter and sort data by game date
    let filteredData = csvData.filter(line => line["Player ID"] === playerID);
    
    filteredData.sort((a, b) => {
        let dateA = new Date(a["Game Date"]);
        let dateB = new Date(b["Game Date"]);
        return dateB - dateA; // Descending order
    });

    // Create table rows based on sorted data
    for (const currentLine of filteredData) {
        const row = document.createElement("tr");

        headers.forEach(header => {
            const td = document.createElement("td");

            if (header === "Box") {
                const a = document.createElement("a");
                a.textContent = "Box";
                a.href = "game_info?gameID=" + currentLine["Game ID"];
                td.appendChild(a);
            } else {
                td.textContent = currentLine[header];
            }

            row.appendChild(td);
        });

        table.appendChild(row);
    }
}

function displayGameLog_pitching(csvData) {
    const tableContainer_pitching= document.getElementById("gamelog-container");

    // Create the table only if it doesn't exist
    let table = tableContainer_pitching.querySelector("table");
    let headers = [];

    if (!table) {
        table = document.createElement("table");
        headers = ['Box', 'Opponent', 'IP', 'HA', 'ER', 'BB', 'SO', 'HB', 'BF', 'HR A'];
        const headerRow = document.createElement("tr");

        // Create headers
        headers.forEach((header) => {
            const th = document.createElement("th");
            th.textContent = header;
            th.style = "padding: 10px";
            headerRow.appendChild(th);
        });

        table.appendChild(headerRow);
        tableContainer_pitching.appendChild(table);
    }

    // Filter and sort data by game date
    let filteredData = csvData.filter(line => line["Player ID"] === playerID);
    
    filteredData.sort((a, b) => {
        let dateA = new Date(a["Game Order"]);
        let dateB = new Date(b["Game Order"]);
        return dateA - dateB; // Ascending order
    });

    // Create table rows based on sorted data
    for (const currentLine of filteredData) {
        const row = document.createElement("tr");

        headers.forEach(header => {
            const td = document.createElement("td");

            if (header === "Box") {
                const a = document.createElement("a");
                a.textContent = "Box";
                a.href = "game_info?gameID=" + currentLine["Game ID"];
                td.appendChild(a);
            } else {
                td.textContent = currentLine[header];
            }

            row.appendChild(td);
        });

        table.appendChild(row);
    }
}


// Default is stats //

function read_and_display_hitting() {
    const tableContainer_hitting = document.getElementById("table-container");
    tableContainer_hitting.innerHTML = '';
    tableContainer_hitting.style = "display: block"

    const tableContainer_gamelog = document.getElementById("gamelog-container");
    tableContainer_gamelog.innerHTML = '';
    tableContainer_gamelog.style = 'display: none';

    setTimeout(() => {
        if (!playerID || !statSeasons) {
            console.error("statSeasons is missing or playerID is not defined.");
            return;
        }

        const seasonsArray = statSeasons.split('+').map(s => s.trim());
        seasonsArray.push('Total');

        // Sort seasons in descending order, keeping "Total" at the end
        seasonsArray.sort((a, b) => (a === 'Total' ? 1 : b === 'Total' ? -1 : parseInt(b, 10) - parseInt(a, 10)));

        const fetchPromises = seasonsArray.map(season => {
            const csvFileName = season === "Total" 
                ? `teams/data/hitting_stats/total_hitting_stats.csv`
                : `teams/data/hitting_stats/hitting_stats_${season}.csv`;

            return fetch(csvFileName)
                .then(response => response.ok ? response.text() : Promise.reject(`Failed to fetch ${csvFileName}`))
                .then(csvData => ({ season, data: parseStatsCSV(csvData, "hitting") }))
                .catch(error => {
                    console.warn(`Error fetching or parsing CSV for season ${season}:`, error);
                    return { season, data: null };
                });
        });

        Promise.all(fetchPromises)
            .then(results => {
                const validResults = results.filter(result => 
                    result.data && result.data.some(row => row["Player ID"] === playerID)
                );

                if (validResults.length === 0) {
                    console.warn("No valid hitting data found. Switching to pitching stats.");

                    const hittingButton = document.querySelector('#hitting-button');
                    const pitchingButton = document.querySelector('#pitching-button');

                    if (hittingButton) hittingButton.style = "display: none";
                    if (pitchingButton) pitchingButton.classList.add('pressed');

                    read_and_display_pitching();
                    return;
                }

                // Display hitting stats for each valid season
                validResults.forEach(({ season, data }) => displaySeasonStats_hitting(data, season));
            })
            .catch(error => console.error("Error processing fetch requests:", error));
        }, 1000);
}

function read_and_display_pitching() {
    const tableContainer_pitching = document.getElementById("table-container");
    tableContainer_pitching.innerHTML = '';
    tableContainer_pitching.style = "display: block"

    const tableContainer_gamelog = document.getElementById("gamelog-container");
    tableContainer_gamelog.innerHTML = '';
    tableContainer_gamelog.style = 'display: none';

    setTimeout(() => {
        if (!playerID || !statSeasons) {
            console.error("statSeasons is missing or playerID is not defined.");
            return;
        }

        const seasonsArray = statSeasons.split('+').map(s => s.trim());
        seasonsArray.push('Total');

        // Sort seasons in descending order, keeping "Total" at the end
        seasonsArray.sort((a, b) => (a === 'Total' ? 1 : b === 'Total' ? -1 : parseInt(b, 10) - parseInt(a, 10)));

        const fetchPromises = seasonsArray.map(season => {
            const csvFileName = season === "Total" 
                ? `teams/data/pitching_stats/total_pitching_stats.csv`
                : `teams/data/pitching_stats/pitching_stats_${season}.csv`;

            return fetch(csvFileName)
                .then(response => response.ok ? response.text() : Promise.reject(`Failed to fetch ${csvFileName}`))
                .then(csvData => ({ season, data: parseStatsCSV(csvData, "pitching") }))
                .catch(error => {
                    console.warn(`Error fetching or parsing CSV for season ${season}:`, error);
                    return { season, data: null };
                });
        });

        Promise.all(fetchPromises)
            .then(results => {
                const validResults = results.filter(result => 
                    result.data && result.data.some(row => row["Player ID"] === playerID)
                );

                if (validResults.length === 0) {
                    console.warn("No valid pitching data found. Switching to hitting stats.");

                    const hittingButton = document.querySelector('#hitting-button');
                    const pitchingButton = document.querySelector('#pitching-button');

                    if (hittingButton) hittingButton.classList.add('pressed');
                    if (pitchingButton) pitchingButton.style = "display: none";

                    read_and_display_hitting();
                    return;
                }
                // Display hitting stats for each valid season
                validResults.forEach(({ season, data }) => displaySeasonStats_pitching(data, season));
            })
            .catch(error => console.error("Error processing fetch requests:", error));
        }, 1000);
}

function read_and_display_hitting_gamelog() {
    const tableContainer = document.getElementById("table-container");
    tableContainer.innerHTML = '';
    tableContainer.style = "display: none";

    const tableContainer_gamelog = document.getElementById("gamelog-container");
    tableContainer_gamelog.innerHTML = '';
    tableContainer_gamelog.style = "display: block";

    setTimeout(() => {
        if (!playerID || !statSeasons) {
            console.error("statSeasons is missing or playerID is not defined.");
            return;
        }

        const seasonsArray = statSeasons.split('+').map(s => s.trim());
        seasonsArray.sort((a, b) => (parseInt(b, 10) - parseInt(a, 10)));

        const season_select = document.getElementById('season-select');
        const selectedSeason = season_select.value

        // Add event listener for the dropdown change
        season_select.addEventListener('change', function() {
            const selectedSeason = this.value;
            fetchDataForSeason(selectedSeason, true); // Call for hitting data
        });

        // Initial fetch for the selected season
        fetchDataForSeason(selectedSeason, true); // Call for hitting data
    }, 1000);
}

function read_and_display_pitching_gamelog() {
    const tableContainer = document.getElementById("table-container");
    tableContainer.innerHTML = '';
    tableContainer.style = "display: none";

    const tableContainer_gamelog = document.getElementById("gamelog-container");
    tableContainer_gamelog.innerHTML = '';
    tableContainer_gamelog.style = "display: block";

    setTimeout(() => {
        if (!playerID || !statSeasons) {
            console.error("statSeasons is missing or playerID is not defined.");
            return;
        }

        const seasonsArray = statSeasons.split('+').map(s => s.trim());
        seasonsArray.sort((a, b) => (parseInt(b, 10) - parseInt(a, 10)));

        const season_select = document.getElementById('season-select');
        const selectedSeason = season_select.value

        // Add event listener for the dropdown change
        season_select.addEventListener('change', function() {
            const selectedSeason = this.value;
            fetchDataForSeason(selectedSeason, false); // Call for pitching data
        });

        // Initial fetch for the selected season
        fetchDataForSeason(selectedSeason, false); // Call for pitching data
    }, 1000);
}

function fetchDataForSeason(selectedSeason, isHitting) {
    const csvFileName = isHitting 
        ? `teams/data/box_scores/hitting_box_${selectedSeason}.csv`
        : `teams/data/box_scores/pitching_box_${selectedSeason}.csv`;

    fetch(csvFileName)
        .then(response => response.ok ? response.text() : Promise.reject(`Failed to fetch ${csvFileName}`))
        .then(csvData => {
            let parsedData = isHitting
                ? parseStatsCSV(csvData, "gamelog_hitting")
                : parseStatsCSV(csvData, "gamelog_pitching");


            parsedData = isHitting 
                ? parsedData.filter(row => parseInt(row["AB"]) > 0)
                : parsedData;

            const validResults = parsedData.filter(row => row["Player ID"] === playerID);

            if (validResults.length === 0) {
                console.warn(`No valid ${isHitting ? 'hitting' : 'pitching'} data found.`);
                return;
            }

            // Display stats (hitting or pitching)
            if (isHitting) {
                displayGameLog_hitting(validResults, selectedSeason);
            } else {
                displayGameLog_pitching(validResults, selectedSeason);
            }
        })
        .catch(error => console.error("Error processing fetch requests:", error));
}


function populateSeasonSelect(season_select, seasonsArray) {
    season_select.innerHTML = ''; // Clear current options
    seasonsArray.forEach(season => {
        const option = document.createElement('option');
        option.value = season;
        option.textContent = season;
        season_select.appendChild(option);
    });
}

setTimeout(() => {
    const seasonsArray = statSeasons.split('+').map(s => s.trim());
    seasonsArray.sort((a, b) => (parseInt(b, 10) - parseInt(a, 10)));
    const season_select = document.getElementById('season-select')
    populateSeasonSelect(season_select, seasonsArray)
}, 1000);

read_and_display_hitting()


// Check for Press of Stats/Game Log Button //

let selectedButton = 'stats-button';
let selectedStatsButton = 'hitting-button';
let selectedSeason = '';

// Function to update selectedStatsButton
function updateSelectedStatsButton() {
    const selectedStatsElement = document.querySelector('.stats-button-container button.pressed');
    selectedStatsButton = selectedStatsElement ? selectedStatsElement.id : 'hitting-button'; // Default to hitting-button
}

// Attach event listeners for stats buttons
document.querySelectorAll('.stats-button-container button').forEach(button => {
    button.addEventListener('click', function() {
        // Remove 'pressed' from all buttons in the stats container
        document.querySelectorAll('.stats-button-container button').forEach(btn => btn.classList.remove('pressed'));
        this.classList.add('pressed');
        updateSelectedStatsButton();

        // Update the content based on the selected button
        if (selectedButton === 'stats-button') {
            removeYearDropdown();
            if (selectedStatsButton === 'hitting-button') {
                read_and_display_hitting();  // Display hitting stats
            } else if (selectedStatsButton === 'pitching-button') {
                read_and_display_pitching();  // Display pitching stats
            }
        } else if (selectedButton === 'gamelog-button') {
            showYearDropdown();
            if (selectedStatsButton === 'hitting-button') {
                read_and_display_hitting_gamelog();  // Display hitting game logs
            } else if (selectedStatsButton === 'pitching-button') {
                read_and_display_pitching_gamelog();  // Display pitching game logs
            }
        }
    });
});

// Attach event listeners for main buttons
document.querySelectorAll('.button-container button').forEach(button => {
    button.addEventListener('click', function() {
        // Remove 'pressed' from all buttons in the main container
        document.querySelectorAll('.button-container button').forEach(btn => btn.classList.remove('pressed'));
        this.classList.add('pressed');
        selectedButton = this.id;

        // Update selectedStatsButton before using it
        updateSelectedStatsButton();

        // Clear table content
        document.querySelector('#table-container').innerHTML = '';

        if (selectedButton === 'stats-button') {
            removeYearDropdown();
            if (selectedStatsButton === 'hitting-button') {
                read_and_display_hitting();
            } else if (selectedStatsButton === 'pitching-button') {
                read_and_display_pitching();
            }
        } else if (selectedButton === 'gamelog-button') {
            showYearDropdown();
            if (selectedStatsButton === 'hitting-button') {
                read_and_display_hitting_gamelog();
            } else if (selectedStatsButton === 'pitching-button') {
                read_and_display_pitching_gamelog();
            }
        }
    });
});

document.getElementById('season-select').addEventListener('change', function() {
    // Update selected season
    selectedSeason = this.value;

    // Check the selected stats button and call the corresponding function
    if (selectedStatsButton === 'hitting-button') {
        read_and_display_hitting_gamelog();
    } else if (selectedStatsButton === 'pitching-button') {
        read_and_display_pitching_gamelog();
    }
});



function removeStatsButtons() {

    const hittingButton = document.getElementById('hitting-button')
    hittingButton.style = "display: none"

    const pitchingButton = document.getElementById('pitching-button')
    pitchingButton.style = "display: none"

}

function showYearDropdown() {
    const season_select = document.getElementById('season-select');
    season_select.style = "display: block";

    // Ensure the season select retains its selected value
    if (selectedSeason) {
        season_select.value = selectedSeason;
    }
}

function removeYearDropdown() {

    const season_select = document.getElementById('season-select')
    season_select.style = "display: none";

}
