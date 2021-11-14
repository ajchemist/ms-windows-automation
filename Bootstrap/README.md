---
title: MS Windows Bootstrap
author: ajchemist
description: Microsoft windows system automation
---


- `Shift-F10`: Launch `cmd.exe` in OOBE


# Basic


``` powershell
Set-ExecutionPolicy RemoteSigned


# SecurityProtocol (Optional)
[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
```


# Storage 점검


``` powershell
Get-Disk
Get-Volume


# DATA 볼륨 드라이브 문자 할당
Get-Partition -DiskNumber 1 | Set-Partition -NewDriveLetter D
```


# Optional Features


```powershell
Enable-WindowsOptionalFeature -Online -FeatureName "netfx3" -All -LimitAccess
Enable-WindowsOptionalFeature -Online -FeatureName "Microsoft-Hyper-V-All" -All
Get-WindowsOptionalFeature -Online
```


# Bootstrap Script


```powershell
iex (irm 'rebrand.ly/ajchemist-ms-windows-automation-bootstrap)
```


# Storage


## System Drive Configuration


```powershell
$GUID_EFI_SYSTEM_PARTITION = '{c12a7328-f81f-11d2-ba4b-00a0c93ec93b}'


get-disk
$disk = get-disk 0
$disk `
    | Clear-Disk -RemoveData -Passthru `
    | Initialize-Disk -PartitionStyle GPT -PassThru `
    | New-Partition -GptType $GUID_EFI_SYSTEM_PARTITION -Size 200MB -DriveLetter S `
    | Format-Volume -FileSystem FAT32 -NewFileSystemLabel ESP -confirm:$false
$disk `
    | New-Partition -UseMaximumSize -DriveLetter W `
    | Format-Volume -FileSystem NTFS -NewFileSystemLabel WINNT -confirm:$false
```


## Data Drive Configuration


```powershell
get-disk
$disk = get-disk 1
$disk `
    | Clear-Disk -RemoveData -Passthru `
    | Initialize-Disk -PartitionStyle GPT -PassThru `
    | New-Partition -UseMaximumSize -AssignDriveLetter `
    | Format-Volume -FileSystem NTFS -NewFileSystemLabel DATA -confirm:$false
```


## diskpart


``` batchfile
diskpart
lis dis
sel dis 0
clean
convert gpt
cre par efi size=200
format quick fs=fat32 label=ESP
assign
cre par pri
format quick fs=ntfs label=WINNT
assign
list vol
exit
```


``` batchfile
diskpart
lis dis
sel dis 1
clean
convert gpt
cre par pri
format fs=ntfs quick label=DATA
assign letter=D
exit
```


# Deploy



``` powershell
New-PSDrive -Name Z -Root \\host\share -PSProvider FileSystem
pushd D:
Get-WIndowsImage -ImagePath winntx.wim
Expand-WindowsImage -ImagePath winntx.wim -Index 5 -ApplyPath W:
# Add-WindowsDriver -Path W: -Driver $env:TEMP\drivers -Recurse -ForceUnsigned
bcdboot W:\Windows /s S: /l ko-kr /f UEFI /v
```


``` batchfile
dism /get-wiminfo /wimfile:winntx.wim
dism /apply-image /imagefile:winntx.wim /index:5 /applydir:W:
```


# BitLocker


## Enable BitLocker on data drive


``` powershell
.\scripts\bitlocker-data-drive.ps1
```


`gpedit.msc`


`로컬 컴퓨터 정책\컴퓨터 구성\Windows 설정\스크립트\시작프로그램` 파워셀 스크립트 `unlock_bitlocker_data_drive.ps1` 등록


## Enable BitLocker on system drive


> :warning: **DO NOT USE THIS STEP AT OOBE**


`gpedit.msc`


`로컬 컴퓨터 정책\컴퓨터 구성\관리 템플릿\Windows\BitLocker 드라이브 암호화\운영 체제 드라이브\시작 시 추가 인증 요구` -> 사용, 호환 TPM이 없는 BitLocker 허용 체크


``` powershell
$system_drive_pw = Read-Host "Password" -AsSecureString
Enable-BitLocker $env:SystemDrive -UsedSpaceOnly -PasswordProtector -Password $system_drive_pw
Add-BitLockerKeyProtector $env:SystemDrive -RecoveryPasswordProtector
```


# Scenario


## 1


1. [시스템 드라이브 구성](#system-drive-configuration)
2. [Deploy](#deploy)


## Others


- https://github.com/W4RH4WK/Debloat-Windows-10
- https://github.com/W4RH4WK/Debloat-Windows-10/blob/master/scripts/remove-onedrive.ps1
