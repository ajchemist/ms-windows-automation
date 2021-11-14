[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
$ref = "master"
$name = "ms-windows-automation"
$uri = "https://codeload.github.com/ajchemist/$name/zip/$ref"
$target = Join-Path $env:TEMP "$name.zip"
Invoke-RestMethod $uri -OutFile $target
Expand-Archive $target -DestinationPath $env:TEMP -Force
cd "$env:TEMP\$name-$ref"


if (!$DEBUG)
{
    iex (".\Bootstrap\main.ps1")
}
