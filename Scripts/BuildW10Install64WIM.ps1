<#
.SYNOPSIS
    Build install.wim
.EXAMPLE
    PS> BuildW10Install64WIM.ps1 -IsoDriveLetter E -targetDir D:\private\tmp -mountDir D:\private\tmp\mount
#>
param
(
    # MSDN ISO Drive letter
    [string]$IsoDriveLetter,
    [Parameter(Mandatory=$true)][string]$targetDir,
    [Parameter(Mandatory=$true)][string]$mountDir
)
$ErrorActionPreference = 'Stop'


if ($IsoDriveLetter)
{
    $IsoDrive = (Get-PSDrive -Name $IsoDriveLetter)
}
else
{
    Write-Host "Choose ISO Drive..."
    $IsoDrive = (Get-PSDrive -PSProvider FileSystem | Out-GridView -PassThru)
}
mkdir $mountDir -ea 0
$ImagePath = Join-Path $IsoDrive.root "sources\install.wim"
$SXSPath = Join-Path (Get-Item $ImagePath).Directory "sxs"
$targetImagePath = Join-Path $targetDir "install.wim"


Write-Host "Choose Windows Base Image..."
$baseImage = (get-windowsImage -imagePath $ImagePath | out-gridview -passthru)
$baseImage = (get-WIndowsImage -ImagePath $ImagePath -Index $baseImage.ImageIndex | Select-Object -Property *)
if (-Not ( $baseImage.Architecture -eq 9 ))
{
    $baseImage | format-table | out-string | write-host
    Write-Host "Invalid architecture: " $baseImage.Architecture
    Write-Host "Exit"
    exit
}


Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $baseImage.imageIndex -DestinationImagePath $targetImagePath -DestinationName $baseImage.ImageName
Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $baseImage.imageIndex -DestinationImagePath $targetImagePath -DestinationName (-join($baseImage.ImageName, " Hyper-V"))
Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $baseImage.imageIndex -DestinationImagePath $targetImagePath -DestinationName (-join($baseImage.ImageName, " NETFX3"))
Export-WindowsImage -SourceImagePath $ImagePath -SourceIndex $baseImage.imageIndex -DestinationImagePath $targetImagePath -DestinationName (-join($baseImage.ImageName, " Hyper-V + NETFX3"))


Mount-WindowsImage -ImagePath $targetImagePath -Index 2 -Path $mountDir
Enable-WindowsOptionalFeature -Path $mountDir -FeatureName "Microsoft-Hyper-V-All" -All
Get-WindowsOptionalFeature -Path $mountDir -FeatureName *Hyper-V* | Format-Table | Out-String | Write-Host
Get-WindowsImage -Mounted | Format-Table | Out-String | Write-Host
Dismount-WindowsImage -Path $mountDir -Save


Mount-WindowsImage -ImagePath $targetImagePath -Index 3 -Path $mountDir
Enable-WindowsOptionalFeature -Path $mountDir -FeatureName "netfx3" -Source $SXSPath -All -LimitAccess
Get-WindowsOptionalFeature -Path $mountDir -FeatureName *netfx3* | Format-Table | Out-String | Write-Host
Get-WindowsImage -Mounted | Format-Table | Out-String | Write-Host
Dismount-WindowsImage -Path $mountDir -Save


Mount-WindowsImage -ImagePath $targetImagePath -Index 4 -Path $mountDir
Enable-WindowsOptionalFeature -Path $mountDir -FeatureName "Microsoft-Hyper-V-All" -All
Enable-WindowsOptionalFeature -Path $mountDir -FeatureName "netfx3" -Source $SXSPath -All -LimitAccess
Get-WindowsOptionalFeature -Path $mountDir -FeatureName *Hyper-V* | Format-Table | Out-String | Write-Host
Get-WindowsOptionalFeature -Path $mountDir -FeatureName *netfx3* | Format-Table | Out-String | Write-Host
Get-WindowsImage -Mounted | Format-Table | Out-String | Write-Host
Dismount-WindowsImage -Path $mountDir -Save


Get-WindowsImage -ImagePath $targetImagePath | Format-Table | Out-String | Write-Host
