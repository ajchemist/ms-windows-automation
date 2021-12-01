# * Profile List


Function Set-ProfileListParentPath
{
    param(
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
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "Default" -Type ExpandString -Value (Join-Path $ParentPath -ChildPath "\Users\Default")
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "ProfilesDirectory" -Type ExpandString -Value (Join-Path $ParentPath -ChildPath "\Users")
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "ProgramData" -Type ExpandString -Value (Join-Path $ParentPath -ChildPath "\ProgramData")
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList" -Name "Public" -Type ExpandString -Value (Join-Path $ParentPath -ChildPath "\Users\Public")
}


# * Windows Update


Function Disable-WindowsUpdate
{
    New-Item -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Force
    Set-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Microsoft\Windows\WindowsUpdate\AU" -Name "NoAutoUpdate" -Type DWord -Value 1 -Force
}


# * Remote Desktop Protocol


Function Enable-RemoteDesktopNeworkLevelAuthentication
{
    Write-Output "Enabling Remote Desktop Network-Level Authentication..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 1
}


Function Disable-RemoteDesktopNeworkLevelAuthentication
{
    # WinXP 네트워크 수준 인증이 불가능한 곳에서 접속해야만 하는 경우
    Write-Output "Disable Remote Desktop Network-Level Authentication..."
    Set-ItemProperty -Path "HKLM:\System\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp" -Name "UserAuthentication" -Type DWord -Value 0
}



# Enable Remote Desktop
Function Enable-RemoteDesktop
{
    Write-Output "Enabling Remote Desktop..."
    Enable-RemoteDesktopNeworkLevelAuthentication
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 0
    Enable-NetFirewallRule -Name "RemoteDesktop*"
    Test-NetConnection localhost -CommonTCPPort rdp
}


# Disable Remote Desktop
Function Disable-RemoteDesktop
{
    Write-Output "Disabling Remote Desktop..."
    Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server" -Name "fDenyTSConnections" -Type DWord -Value 1
    Disable-NetFirewallRule -Name "RemoteDesktop*"
}


# * Hyper-V
