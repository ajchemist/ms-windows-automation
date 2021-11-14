param(
    [Parameter(Mandatory=$true)]
    [ValidateScript(
         {
             if( -Not ($_ | Test-Path) )
             {
                 throw "File or folder does not exist: $_"
             }
             return $true
         })]
    $ParentPath
)


$timestamp = Get-Date -UFormat "%s"


Write-Host "Export Current Profile List Registry..."
Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | Out-String | Write-Host
reg export (Convert-Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList") (Join-Path "$env:PROGRAMDATA" (-Join("ProfileList.", $timestamp, ".reg"))) /y


Set-ProfileListParentPath -ParentPath $ParentPath


Write-Host "Echo Changed Profile List"
Get-Item "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" | Out-String | Write-Host


(Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "ProfilesDirectory")


Function MovePath
{
    param
    (
        [Parameter(Mandatory=$true)]
        $Path,
        $Suffix = (Get-Date -UFormat "%s")
    )
    if (Test-Path $Path)
    {
        mv $Path "$Path.$Suffix"
    }
}


MovePath (Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "ProfilesDirectory")
MovePath (Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "ProgramData")
New-Item -ItemType directory -Path (Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "ProfilesDirectory") -Force
New-Item -ItemType directory -Path (Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "ProgramData") -Force


robocopy `
  "$env:SystemDrive\Users" `
  (Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "ProfilesDirectory") `
  /mt:10 /e /copyall /xj /r:0 /LOG+:"$env:PROGRAMDATA\ProfileList.Users.robocopy.txt"
robocopy `
  "$env:SystemDrive\ProgramData" `
  (Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "ProgramData") `
  /mt:10 /e /copyall /xj /r:0 /LOG+:"$env:PROGRAMDATA\ProfileList.ProgramData.robocopy.txt"
