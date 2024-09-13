import { createClient } from 'https://cdn.jsdelivr.net/npm/@supabase/supabase-js/+esm';

const supabaseUrl = 'https://ytirxxclotiueajinlkv.supabase.co';
const supabaseKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inl0aXJ4eGNsb3RpdWVhamlubGt2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjUyMzExODEsImV4cCI6MjA0MDgwNzE4MX0.YR--t9YR6gaRUqzGoRGmLz0M9EfxXz68hkT67EJthtU';
const supabase = createClient(supabaseUrl, supabaseKey);

function getTeamIDFromURL() {
    const urlParams = new URLSearchParams(window.location.search);
    return urlParams.get('teamID'); // Returns the teamID parameter from the URL
}

function fetchTeamInfo(teamID) {

    return supabase
        .from('teams')
        .select('*')
        .eq('team_id', teamID)
        .then(({ data: teams, error }) => {
            if (error) {
                console.error('Error fetching team info:', error);
                return null;
            }
            console.log('Query response:', teams); // Log the raw response
            return teams;
        });
}

// Example usage
function fetchAndDisplayTeamInfo() {
    const teamID = getTeamIDFromURL();
    if (teamID) {
        fetchTeamInfo(teamID).then(teamInfo => {
            if (teamInfo && teamInfo.length > 0) {
                document.getElementById('team-name').textContent = teamInfo[0].team_name;
                document.getElementById('team-logo').src = teamInfo[0].logo_link;
            } else {
                console.warn('No team info found for teamID:', teamID);
            }
        }).catch(error => {
            console.error('Error in fetching team info:', error);
        });
    } else {
        console.warn('No teamID found in the URL');
    }
}

fetchAndDisplayTeamInfo();
