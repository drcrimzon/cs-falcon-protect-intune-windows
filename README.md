# Installing Crowdstrike Falcon Protect via Microsoft Intune

CrowdStrike does not provide msi installer files to push via Intune.

It's much easier and more reliable to use a powershell script to deploy Crowdstrike Falcon Protect to end-users.

Here's the steps required to get it working.

## Deployment Script

How to push the script via Intune:

1. Open open the [Microsoft Endpoint Manager admin center](https://endpoint.microsoft.com/#home)
2. Select `Devices` -> `Scripts`
3. Click `+ Add`\
   ![Step 1 - Create Script](img/script_1.png?raw=true)
4. Enter the basic details for the script\
   ![Step 2 - Basic Script Options](img/script_2.png?raw=true)
5. Upload [IntuneCrowdstrike.ps1](IntuneCrowdstrike.ps1)

- Select "No" For `Run script as signed-in user` so it runs as the superuser instead of the local user
- Choose your preference for `Enforce script signature check`
- It's not required to run the script in 64 bit powershell host, so No is fine there
  ![Step 3 - Script Settings](img/script_3.png?raw=true)

6. Select the users and devices you want to deploy Crowdstrike Falcon Protect to\
   ![Step 4 - Script Assignments](img/script_4.png?raw=true)
7. Review your settings and click `Add` if everything looks correct to you\
   ![Step 5 - Script Review](img/script_5.png?raw=true)
