#Requires -RunAsAdministrator


param(
    [System.IO.FileInfo]
    [Parameter()]
    [ValidateScript({ Test-Path $_ })]
    $VMDriveRoot = (Get-Item (Get-ItemPropertyValue "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "ProfilesDirectory")).PSDrive.root
)


$ErrorActionPreference = "Stop"


$VMPath = Join-Path -Path $VMDriveRoot -ChildPath "private\vm\Hyper-V"
$VHDPath = Join-Path -Path $VMDriveRoot -ChildPath "private\vm\Hyper-V\Drives"


MD -Path $VMPath,$VHDPath -ErrorAction 0


Set-VMHost -VirtualHardDiskPath $VHDPath -VirtualMachinePath $VMPath


Get-VMHost | Format-List | Out-String | Write-Host
