Function Open-Website {
    param (
        [parameter(Mandatory=$True)]
        [string]$Url
    )
    
    # Open the URL in the default web browser
    Start-Process $Url
}

# Open fvtal.com
$website = "https://www.fvtal.com"
Open-Website -Url $website
