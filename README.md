
# Network-Device-Configuration-Backup

The Script can be used to automate the configuration backup of network devices using SSH and TFTP Server

# Pre-requisites

1. Windows PowerShell version 5.0 or above
2. Posh-SSH module should be installed on windows PowerShell
3. Install and configure a TFTP Server
4. SSH should be enabled on all network devices
5. All devices should be configured with same login credentials (Read only)
6. After logging in, the devices should be in "Enable" (Privileged #) mode
7. Network devices firmware should be in-line with industry standards
8. Add IP address of devices into hp.txt, Cisco.txt & fortigate.txt
9. Not recommended to run on any servers installed with SCCM, WDS or any other tftp services.
10. Login credential need to be encrypted and saved in a text file pass.txt. Copy the pass.txt file into the script “content” folder

How to Convert

Open Administrative PowerShell window and execute the command below.

"Temp123*" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "C:\pass.txt”.

Password – Temp123* Output File – pass.txt in C drive

# How to use the script

STEP 1)	Download the script “Network_switch_config_auto_backup” from the GitHub and extract it to any drive.

STEP 2)	Open tftpd64 folder under script root folder and run tftpd64.exe, note down the IP address and edit the following settings. It is a one-time job.

2a) Open Tftpd64 program, click on Settings button.

2b) Settings window will open as shown below. Put a check mark only to TFTP Server option. Remove check mark from all other options

2c) then next select TFTP tab. click on Browse button to specify Base Directory. You need to specify the Base Directory of the TFTP Server. Set your script root folder as the base directory. Ex: H:\Network_switch_auto_backup Where H = your disk drive where the script folder is extracted to. Network_switch_auto_backup is the script folder.

2d) Under TFTP Security, select the option None

2e) A very important Step, Bind TFTP to this address: To set the IP address for TFTP server, please select the option Bind TFTP to this address then select the IP address available for you. You may get a different IP address, please use the IP address available in the drop down window.

You have to note down bonded IP address and write into the script line as mentioned in Step 3.

2f) once you have performed all the above steps, Click on OK. Now you will receive a window asking to restart Tftpd64 to apply the new settings. Click on OK.

2e) Reopen Tftpd64 program. Just ensure that you selected same IP address for Server Interface.

Reference: http://techzain.com/how-to-setup-tftp-server-tftpd64-tfptd32-windows/

STEP 3)	Edit the following portion in the script

If user name to login to your device is not "manager”, change it to your user name.

$cred = New-Object System.Management.Automation.PSCredential ('manager', $securePassword)

Enter your TFTP server IP address (Bonded TFTP Server IP address – Step 2e)

$tftp_server = "Enter your TFTP server ip address here"

STEP 4)	Open script root folder and navigate to “Content" folder

Replace Pass.txt with your encrypted device password key file

Enter the IP address of HP devices into hp.txt

Enter the IP address of Cisco devices into cisco.txt

Enter the IP address of Fortigate Firewall devices into fortigate.txt

STEP 5)	Open a PowerShell (Administrative PS recommended)

STEP 6)	Navigate and set path to script root folder

STEP 7)	If you want to backup HP devices configuration execute the below command

    PS>.\Network_switch_auto_backup.ps1 HP
    
STEP 8)	If you want to backup CISCO devices configuration execute the below command

    PS>.\Network_switch_auto_backup.ps1 Cisco
    
STEP 9)	If you want to backup Fortigate devices configuration execute the below command

    PS>.\Network_switch_auto_backup.ps1 Fortigate
    
STEP 10)	If you want to backup HP, CISCO and Fortigate devices configuration execute the below command

    PS>.\Network_switch_auto_backup.ps1 All
    
STEP 11)	Output will be saved in your script root folder

\2018\December\07122018\10.0.0.20\running-config.cfg

\2018\December\07122018\10.0.0.20\startup-config.cfg

Note : Fortigate UTM output will be saved into script root folder.

STEP 11)	Logging is enabled on the script to troubleshoot the, check “logs” folder under the script root folder if you come across any errors.

STEP 12)	The script can be schedule using task scheduler to backup devices configuration as per the requirement.

# How the script works

1. Script creates a folder at destination if it is not exist, folder structure as follows Year -> Date -> Switch IP.

2. Get device IP addresses from the hp.txt, cisco.txt & fortigate.txt

3. Import Posh-SSH module into PowerShell

4. Create a SSH Session into each devices and save the configurations into the defined location on by one.

5. Disconnect the SSH session.

# Troubleshooting

1.	Logging is enabled on the script with run time, date and year, check the folder "logs"

# Future Enhancements

1. Expand functionality for larger pool of network devices.

2. Compare the startup and running config and remove running-config if both are identical

# Devices Tested

1. HP Switches (Procurve and Aruba)
2. Fortinet Firewall (FortiOS)
3. Cisco switches (iOS)
