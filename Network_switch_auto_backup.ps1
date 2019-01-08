
###############################################################################
# Script info     :  Network Switch Automated Backup using SSH and TFTP
# Script          :  Network_switch_auto_backup.ps1
# Verified on     :  Cisco(iOS), HP(Procurve and Aruba)
# Author          :  Sijo John
# Version         :  V-1.0
# Last Modified   :  10/12/2018
# The Script can be used for the configuration backup of network devices which are accessible via ssh.
# .SYNOPSIS
# Usage Example   : PS>.\Network_switch_auto_backup.ps1 hp (For HP network switches)
#                 : PS>.\Network_switch_auto_backup.ps1 cisco (For cisco network switches)
#                 : PS>.\Network_switch_auto_backup.ps1 fortigate (For Fortigate Firewall)
#                 : PS>.\Network_switch_auto_backup.ps1 All (For All the above)
################################################################################


Param
(
    [Parameter(Mandatory = $True)]
    [ValidateNotNull()]
    $devicename
)

Begin {

    write-host $devicename
    $tftpfolder = "$PSScriptRoot"
    Write-Host ("Starting TFTP Server")
    Invoke-Item "$PSScriptRoot\tftpd64\tftpd64.exe"

    $ContentFolder = "$PSScriptRoot\Content"
    $LogFolder = "$PSScriptRoot\logs"
    $securePassword = Get-Content $ContentFolder\pass.txt | ConvertTo-SecureString
    #Change the user name if it is not manager - Ex: admin, root
    $cred = New-Object System.Management.Automation.PSCredential ('manager', $securePassword)
    $today = Get-Date -Format "ddMMyyy"
    $year = Get-Date -Format "yyyy"
    #Enter your TFTP Server ip address here.
    $tftp_server = "Enter Your TFTP IP Address Here"


    #region generate the transcript log
    #Modifying the VerbosePreference in the Function Scope
    $Start = Get-Date
    $VerbosePreference = 'Continue'
    $TranscriptName = '{0}_{1}.log' -f $(($MyInvocation.MyCommand.Name.split('.'))[0]), $(Get-Date -Format ddMMyyyyhhmmss)
    Start-Transcript -Path "$LogFolder\$TranscriptName"
    #endregion generate the transcript log

    # create a folder for every year
    try {
        Get-Item "$PSScriptRoot\$year\" -ErrorAction SilentlyContinue
        if (!$?) {
            New-Item "$PSScriptRoot\$year\" -ItemType Directory
        }

        # create a folder for every day
        Get-Item "$PSScriptRoot\$year\$today\" -ErrorAction SilentlyContinue
        if (!$?) {
            New-Item "$PSScriptRoot\$year\$today\" -ItemType Directory
        }
    }
    Catch {
        Show-Message -Severity high -Message "Failed to create the folder. Permission!"
        Write-Verbose -ErrorInfo $PSItem
        Stop-Transcript
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }

    # Import required PS Modules

    try {
        Import-Module -name posh-ssh
 
    }
    catch {
        Show-Message -Severity high -Message "[EndRegion] Failed - Prerequisite of loading modules"
        Write-VerboseLog -ErrorInfo $PSItem
        $PSCmdlet.ThrowTerminatingError($PSItem)
    }


    Function hp()
    {

        Write-Host ("Getting switch ip address from hp.txt list")

        # Collect all the devices from hp.txt and put into the array
        $switches_array = @()
        $switches_array = Get-Content $ContentFolder\hp.txt
        foreach ($switch in $switches_array) {
            # create a folder for every device
            Get-Item "$PSScriptRoot\$year\$today\$switch" -ErrorAction SilentlyContinue
            if (!$?) {
                New-Item "$PSScriptRoot\$year\$today\$switch" -ItemType Director
            }

            # start the SSH Session
            New-SSHSession -ComputerName $switch -Credential $Cred -AcceptKey:$true
            $session = Get-SSHSession -Index 0
            # usual SSH won't work for many switches, so using shell stream
            $stream = $session.Session.CreateShellStream("dumb", 80, 9999, 800, 600, 1024)
            # send a "space" for the "Press any key to continue" and wait before you issue the next command
            $stream.Write("`n")
            Sleep 10
            # copy startup-config and wait before you issue the next command
            $stream.Write("copy startup-config tftp $tftp_server \$year\$today\$switch\startup-config")
            $stream.Write("`n")
            Write-Host ("Copying startup-config of $switch into tftp server's defined storage location")
            Sleep 10
            # copy running-config and wait before you issue the next command
            $stream.Write("copy running-config tftp $tftp_server \$year\$today\$switch\running-config")
            $stream.Write("`n")
            Write-Host ("Copying running-config of $switch into tftp server's defined storage location")
            Sleep 10
            # disconnect from host
            Remove-SSHSession -SessionId 0
        }
    }

    Function cisco() 
    {

        Write-Host ("Getting switch ip address from cisco.txt list")

        # Collect all the devices from cisco.txt and put into the array
        $switches_array = @()
        $switches_array = Get-Content $ContentFolder\cisco.txt
        foreach ($switch in $switches_array) {
            # create a folder for every device
            Get-Item "$PSScriptRoot\$year\$today\$switch" -ErrorAction SilentlyContinue
            if (!$?) {
                New-Item "$PSScriptRoot\$year\$today\$switch" -ItemType Director
            }

            # start the SSH Session
            New-SSHSession -ComputerName $switch -Credential $Cred -AcceptKey:$true -force

            $session = Get-SSHSession -Index 0
            # usual SSH won't work for many switches, so using shell stream
            $stream = $session.Session.CreateShellStream("dumb", 80, 9999, 800, 600, 1024)
            # send a "space" for the "Press any key to continue" and wait before you issue the next command
            $stream.Write("`n")
            Sleep 10
            # copy startup-config and wait before you issue the next command
            $stream.Write("copy startup-config tftp")
            $stream.Write("`n")
            $stream.Write("$tftp_server")
            $stream.Write("`n")
            $stream.Write("\$year\$today\$switch\startup-config")
            Write-Host ("Copying startup-config of $switch into tftp server's defined storage location")
            Sleep 10
            # copy running-config and wait before you issue the next command
            $stream.Write("copy running-config tftp")
            $stream.Write("`n")
            $stream.Write("$tftp_server")
            $stream.Write("`n")
            $stream.Write("\$year\$today\$switch\running-config")
            Write-Host ("Copying running-config of $switch into tftp server's defined storage location")
            Sleep 10
            # disconnect from host
            Remove-SSHSession -SessionId 0
        }
    }

    Function fortigate()
    {

        Write-Host ("Getting switch ip address from fortigate.txt list")

        # Collect all the devices from fortigate.txt and put into the array
        $switches_array = @()
        $switches_array = Get-Content $ContentFolder\fortigate.txt
        foreach ($switch in $switches_array) {
            # create a folder for every device
            Get-Item "$PSScriptRoot\$year\$today\$switch" -ErrorAction SilentlyContinue
            if (!$?) {
                New-Item "$PSScriptRoot\$year\$today\$switch" -ItemType Director
            }

            # start the SSH Session
            New-SSHSession -ComputerName $switch -Credential $Cred -AcceptKey:$true -Force
            $session = Get-SSHSession -Index 0
            # usual SSH won't work for many switches, so using shell stream
            $stream = $session.Session.CreateShellStream("dumb", 80, 9999, 800, 600, 1024)
            # send a "space" for the "Press any key to continue" and wait before you issue the next command
            $stream.Write("`n")
            Sleep 10
            # copy startup-config and wait before you issue the next command
            $stream.Write("execute backup config tftp $switch\bak.cfg $tftp_server")
            $stream.Write("`n")
            Write-Host ("Copying startup-config of $switch into tftp server's defined storage location")
            Sleep 10
            # disconnect from host
            Remove-SSHSession -SessionId 0
        }
    }

    if ($devicename -like "HP") {hp continue; }
    elseif ($devicename -like "Cisco") {cisco continue; }
    elseif ($devicename -like "fortigate") {fortigate continue; }
    elseif ($devicename -like "All") {hp continue; cisco continue; fortigate continue; }
    else {Write-host "Enter valid options"} 
    
    Write-Host ("Configuration backup has been saved into the defined location, stopping tftp server.....")
    Sleep 15
    Stop-Process -Name tftpd64
    Write-Host ("TFTP Server stopped")
    Write-Host ("End")
               
}
    
