Clear-Host

#incoming target directory
$studyDir = $args[0]


function Validate-Path(
    [string]$path,
    [string]$message = ""
    )
{
    if((Test-Path $path) -eq $false)
    {
        $message = if($message -ne "") { $message } else { "Error - The following path does not exist: $path" }
        Write-Host $message
        Read-Host "Press any key to exit"
        exit
    }
}

$scriptDir = split-path -parent $MyInvocation.MyCommand.Definition
$devDir = (Get-Item $studyDir).Parent.FullName

#inputs
$client = Read-Host "Enter the client name"
$clientId = Read-Host "Enter the client Id"
$protocol = Read-Host "Enter the study protocol"
$version = Read-Host "Enter the IRT version"


$appConfigName = "App.config"

#only keep Major.Minor of version
$versionParts = $version.Split(".")
$version = $versionParts[0] + "." + $versionParts[1]

$templateName = "template_$version.config"
$templatePath = "$scriptDir\templates\$templateName"
Validate-Path $templatePath "Error - IRT version not supported"

$username = $env:USERNAME

$settingsDir = "$studyDir\settings"
$userSettingsDir = "$settingsDir\$username"
$appConfigPath = "$userSettingsDir\$appConfigName";
$settyPath = "$studyDir\.setty"

#template keyword replacement map
$replaceMap = @{
"{Protocol}" = $protocol;
"{Client}" = $client;
"{ClientId}" = $clientId
}


#App.config
if ((Test-Path $userSettingsDir) -eq $false)
{
    #add user settings directory
    New-Item -Path $userSettingsDir -ItemType directory

    if ((Test-Path $appConfigPath) -eq $false)
    {
        #copy default App.config into user settings dir
        Copy-Item $templatePath $appConfigPath
    
        #replace template keywords in App.config
        $configFile = Get-Content $appConfigPath

        foreach($e in $replaceMap.GetEnumerator())
        {
            $configFile = $configFile -replace $e.Name, $e.Value
        }

        Set-Content -Path $appConfigPath -Value $configFile
    }
}

#.setty
if((Test-Path $settyPath) -eq $false)
{
    New-Item -Path $settyPath -ItemType file
    Set-Content -Path $settyPath -Value "settings\$username"
}

Read-Host "Complete. Press any key to exit"