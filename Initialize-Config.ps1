Clear-Host

#incoming target directory
$studyDir = $args[0]

$scriptDir = split-path -parent $MyInvocation.MyCommand.Definition

#load config
$config = Get-Content "$scriptDir\config.json" -Raw | ConvertFrom-Json

Write-Host "Target: $studyDir"

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


$devDir = (Get-Item $studyDir).Parent.FullName

#inputs
$client = Read-Host "Enter the client name"
$clientId = Read-Host "Enter the client Id"
$protocol = Read-Host "Enter the study protocol"
$version = Read-Host "Enter the IRT version"
$forceOverwrite = Read-Host "Overwrite existing config files (y/n)"
$force = if($forceOverwrite.ToLower() -eq "y") { $true } else { $false }

#only keep Major.Minor of version
$versionParts = $version.Split(".")
$version = $versionParts[0] + "." + $versionParts[1]

$templateName = "template_$version.config"
$templatePath = "$scriptDir\" + $config.templatesSubDir + "\$templateName"
Validate-Path $templatePath "Error - IRT version not supported"

$username = $env:USERNAME

$settingsDir = "$studyDir\" + $config.settingsSubDir
$userSettingsDir = "$settingsDir\$username"
$appConfigPath = "$userSettingsDir\" + $config.appConfigName;
$settyPath = "$studyDir\" + $config.settyName

#template keyword replacement map
$replaceMap = @{
"Protocol" = $protocol;
"Client" = $client;
"ClientId" = $clientId
}


#App.config
if ((Test-Path $userSettingsDir) -eq $false -or $force -eq $true)
{
    #add user settings directory
    New-Item -Path $userSettingsDir -ItemType directory -Force

    if ((Test-Path $appConfigPath) -eq $false -or $force -eq $true)
    {
        #copy default App.config into user settings dir
        Copy-Item $templatePath $appConfigPath -Force
    
        #replace template keywords in App.config
        $configFile = Get-Content $appConfigPath

        foreach($e in $replaceMap.GetEnumerator())
        {
            $configFile = $configFile -replace ($config.templates.varOpen + $e.Name + $config.templates.varClose), $e.Value
        }

        Set-Content -Path $appConfigPath -Value $configFile
    }
}


#create study specific email dump
$appConfigXml = [xml](Get-Content $appConfigPath)
$xPath = $config.appSettingsXPath + '[@key="' + $config.emailPickupDirectoryPath + '"]'
$emailPickupDirectoryPathNode = $appConfigXml | Select-Xml -XPath $xPath

$studyEmailDumpDir = $emailPickupDirectoryPathNode.Node.value


if((Test-Path $studyEmailDumpDir) -eq $false)
{
    New-Item -Path $studyEmailDumpDir -ItemType directory
}


#.setty
if((Test-Path $settyPath) -eq $false)
{
    New-Item -Path $settyPath -ItemType file
    Set-Content -Path $settyPath -Value ($config.settingsSubDir +"$username")
}

Write-Host ""
Read-Host "Complete. Press any key to exit"