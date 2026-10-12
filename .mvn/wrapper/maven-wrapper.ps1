$ErrorActionPreference = "Stop"

$projectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$propertiesPath = Join-Path $PSScriptRoot "maven-wrapper.properties"
$properties = @{}
Get-Content $propertiesPath | ForEach-Object {
    if ($_ -match "^\s*([^#=]+?)\s*=\s*(.*)\s*$") {
        $properties[$matches[1]] = $matches[2]
    }
}

$distributionUrl = $properties["distributionUrl"]
if ([string]::IsNullOrWhiteSpace($distributionUrl)) {
    throw "distributionUrl is missing from $propertiesPath"
}

$versionMatch = [regex]::Match($distributionUrl, "/apache-maven-([^/]+)-bin\.zip$")
if (-not $versionMatch.Success) {
    throw "Unable to determine Maven version from distributionUrl"
}

$version = $versionMatch.Groups[1].Value
$cacheRoot = Join-Path $env:USERPROFILE ".m2\wrapper\dists\apache-maven-$version"
$distributionDirectory = Join-Path $cacheRoot "apache-maven-$version"
$archivePath = Join-Path $cacheRoot "apache-maven-$version-bin.zip"
$mavenExecutable = Join-Path $distributionDirectory "bin\mvn.cmd"

if (-not (Test-Path $mavenExecutable)) {
    New-Item -ItemType Directory -Force -Path $cacheRoot | Out-Null
    if (-not (Test-Path $archivePath)) {
        Write-Host "Downloading Maven $version..."
        Invoke-WebRequest -Uri $distributionUrl -OutFile $archivePath
    }

    $temporaryDirectory = Join-Path $cacheRoot "extract-$([Guid]::NewGuid().ToString('N'))"
    try {
        Expand-Archive -Path $archivePath -DestinationPath $temporaryDirectory -Force
        $extractedDirectory = Join-Path $temporaryDirectory "apache-maven-$version"
        if (-not (Test-Path (Join-Path $extractedDirectory "bin\mvn.cmd"))) {
            throw "Downloaded Maven archive has an unexpected layout"
        }
        Move-Item -Path $extractedDirectory -Destination $distributionDirectory
    }
    finally {
        if (Test-Path $temporaryDirectory) {
            Remove-Item -Path $temporaryDirectory -Recurse -Force
        }
    }
}

& $mavenExecutable -f (Join-Path $projectRoot "pom.xml") @args
exit $LASTEXITCODE
