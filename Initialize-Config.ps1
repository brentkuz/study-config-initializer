Clear-Host

#incoming target directory
$studyDir = $args[0]

$scriptDir = split-path -parent $MyInvocation.MyCommand.Definition

#load config
$config = Get-Content "$scriptDir\config.json" -Raw | ConvertFrom-Json

Write-Host "Target: $studyDir"

function Exit-With-Message([string]$message){
    Write-Host $message
    Read-Host "Press any key to exit"
    exit;
}

function Validate-Path(
    [string]$path,
    [string]$message = ""
    )
{
    if((Test-Path $path) -eq $false)
    {
        $message = if($message -ne "") { $message } else { "Error - The following path does not exist: $path" }
        Exit-With-Message $message
    }
}


$devDir = (Get-Item $studyDir).Parent.FullName

#inputs
$client = Read-Host "Enter the client name"
$clientId = Read-Host "Enter the client Id"

#IRT or TM?
$tmOrIRT = Read-Host "Trial Manager or IRT (TM = Trial Manager; IRT = IRT)"
$isIRT = if($tmOrIRT.ToLower() -eq "irt") { $true } else { if($tmOrIRT.ToLower() -eq "tm") { $false } else { Exit-With-Message "Only Trial Manager and IRT are supported" }}

if($isIRT -eq $true) {
    $protocol = Read-Host "Enter the study protocol"
}
$version = if($isIRT -eq $true) { Read-Host "Enter the IRT version" } else { Read-Host "Enter the Trial Manager version" }
$forceOverwrite = Read-Host "Overwrite existing config files (y/n)"
$force = if($forceOverwrite.ToLower() -eq "y") { $true } else { $false }

#only keep Major.Minor of version
$versionParts = $version.Split(".")
$version = $versionParts[0] + "." + $versionParts[1]

$templateName = "template_$version.config"
$templateSubDir = if($isIRT -eq $true) { $config.irtTemplatesSubDir } else { $config.tmTemplatesSubDir }
$templatePath = "$scriptDir\$templateSubDir\$templateName"
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
if ((Test-Path $userSettingsDir) -eq $false -or $force -eq $true) {
    #add user settings directory
    New-Item -Path $userSettingsDir -ItemType directory -Force

    if ((Test-Path $appConfigPath) -eq $false -or $force -eq $true) {
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


if((Test-Path $studyEmailDumpDir) -eq $false) {
    New-Item -Path $studyEmailDumpDir -ItemType directory
}


#.setty
if((Test-Path $settyPath) -eq $false) {
    New-Item -Path $settyPath -ItemType file
    Set-Content -Path $settyPath -Value ($config.settingsSubDir +"$username")
}

Write-Host ""
Read-Host "Complete. Press any key to exit"