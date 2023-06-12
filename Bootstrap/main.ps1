#Requires -RunAsAdministrator


<#
[System.Environment]::OSVersion
#>


$ErrorActionPreference = "Stop"


$self = $PSCommandPath
$selfdir = $PSScriptRoot
$parentdir = (Get-Item $selfdir).parent.fullName
$ProfileListProperty = Get-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList"


Import-Module "$selfdir\w10.psm1" -Force


Write-Host "Choose DATA Drive..."
$DataDrive = (Get-PSDrive -PSProvider FileSystem | Out-GridView -PassThru)
if ((Get-Item $ProfileListProperty.ProfilesDirectory).root -ne $DataDrive.root) {
    Write-Host "* Run subscript: profile_list.ps1"
    & "$selfdir\Script\profile_list.ps1" -ParentPath $DataDrive.root
}


# ** WindowsUpdate


Disable-WindowsUpdate


# ** TermSRV


Enable-RemoteDesktop


# * Registry Import
reg import "$parentdir\Registry\capslock_ctrl.reg"


# * Extensions


if (Get-Module -list "Hyper-V")
{
    & "$selfdir\Script\vmhost.ps1" -VMDriveRoot $DataDrive.root
}
