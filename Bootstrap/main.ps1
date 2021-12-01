#Requires -RunAsAdministrator


<#
[System.Environment]::OSVersion
#>


$ErrorActionPreference = "Stop"


$self = $PSCommandPath
$selfdir = $PSScriptRoot
$parentdir = (Get-Item $selfdir).parent.fullName


Write-Host "Choose DATA Drive..."


$DataDrive = (Get-PSDrive -PSProvider FileSystem | Out-GridView -PassThru)


# * Run subscript


Import-Module "$selfdir\w10.psm1" -Force
& "$selfdir\Script\profile_list.ps1" -ParentPath $DataDrive.root


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
