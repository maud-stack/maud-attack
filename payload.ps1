Function Open-Website {
    param (
        [parameter(Mandatory=$True)]
        [string]$Url
    )
    
    # Open the URL in the default web browser
    Start-Process $Url
}

# Example Usage: Open Google and navigate to fvtal.com
$searchEngine = "https://www.google.com"
$website = "https://www.fvtal.com"

# Open Google
Open-Website -Url $searchEngine

# Pause for 2 seconds to ensure the browser is open
Start-Sleep -Seconds 2

# Open fvtal.com
Open-Website -Url $website
