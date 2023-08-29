# Set the API Client ID and Secret from https://falcon.crowdstrike.com/api-clients-and-keys/clients and populate the variables below
# The CCID is pulled via the script, there is no need to populate it.
# Created with inspiration from https://github.com/cliv/cs-falcon-protect-intune and the crowdstrike api guide

$CLIENT_ID=
$CLIENT_SECRET=
$URI_BASE= # Ex. https://api.crowdstrike.com, https://api.us-2.crowdstrike.com

# Obtain the access-token
function Get-Access-Token {
    $json=$(Invoke-WebRequest -Method POST -Body "client_id=${CLIENT_ID}&client_secret=${CLIENT_SECRET}" -uri ${URI_BASE}/oauth2/token | ConvertFrom-Json)
    echo $json.access_token
}

# Get the SHA256 has from the latest windows installer
function Get-SHA256 {
    $json=$(Invoke-WebRequest -Headers @{"Authorization" = "Bearer $(Get-Access-Token)"} -uri ${URI_BASE}/sensors/combined/installers/v1\?filter=platform%3A%22windows%22 | ConvertFrom-Json)
    echo $json.resources[0].sha256
}

# Get the CCID from the account
function Get-CCID {
    $json=$(Invoke-WebRequest -Headers @{"Authorization" = "Bearer $(Get-Access-Token)"} -Uri ${URI_BASE}/sensors/queries/installers/ccid/v1 | ConvertFrom-Json)
    echo $json.resources
}

# Check for Crowdstrike install and install if not currently installed and running
if (!(Test-Path "C:\Program Files\CrowdStrike\CSFalconService.exe") -and ((Get-Service -Name csagent -ErrorAction SilentlyContinue) -eq $null) -or ((Get-Service -Name csagent -ErrorAction SilentlyContinue).Status -ne 'Running')) {
    $ProgressPreference = "SilentlyContinue"
    Invoke-WebRequest -OutFile $env:temp\CrowdstrikeInstaller.exe -H @{"Authorization" = "Bearer $(Get-Access-Token)"} -Uri ${URI_BASE}/sensors/entities/download-installer/v1?id=$(Get-SHA256)
    Start-Process -FilePath "${env:temp}\CrowdstrikeInstaller.exe" -ArgumentList "/install /quiet /norestart CID=$(Get-CCID)" -Wait -NoNewWindow
    rm ${env:temp}\CrowdstrikeInstaller.exe
} else {
    echo "Crowdstrike Falcon is installed and running"
}