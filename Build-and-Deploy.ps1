﻿######################################################################################
# This is the master Build and Deploy script.
# Common variables are defined here to call configurations and configuationdata which
# are then used to crate all MOF files, checksums, and have the entire process
# deployed to the Pull Server
######################################################################################

######################################################################################
# Master Variables
######################################################################################
$Configurations = 'SCCM-Configuration'
$ConfigurationData = 'ProximusHosts'
$SourceModules = '$env:HOMEDRIVE\DSC-Manager\Modules'
$PullServerModules = '$env:PROGRAMFILES\WindowsPowershell\DscService\Modules'
$PullServerConfiguration = '$env:PROGRAMFILES\WindowsPowershell\DscService\Configuration'
$PullServerCertStore = '$env:PROGRAMFILES\WindowsPowershell\DscService\NodeCertificates'
$PullServerNodeCSV = '$env:PROGRAMFILES\WindowsPowershell\DscService\Configuration\dscnodes.csv'

######################################################################################
# Import DSC-Management
######################################################################################
if(!(Get-Module DSC-Management)) {
    Try {
        Import-Module ('.\core\DSC-Management.ps1')
        }
    Catch {
        Throw "Cannot load the DSC GUID and Certificate Management Tools.  Please make sure the module is present and try again"
        }
    }

######################################################################################
# Run DSC-Management functions
######################################################################################

#Update the CSV table with missing Server,GUID, and Thumbprint information
Update-DSCMTable -ConfigurationData $ConfigurationData -FileName $PullServerNodeCSV -CertStore $PullServerCertStore

#Load ConfigurationData then add thumbprint information if available for final configuration application
$UpdatedConfigurationData = Update-DSCMConfigurationData -ConfigurationData $ConfigurationData -FileName $PullServerNodeCSV


######################################################################################
# Unload DSC-Management
######################################################################################
if(Get-Module DSC-Management) {
    Try {
        Remove-Module 'DSC-Management'
        }
    Catch {
        Throw "There was an error unloading the DSC-Management module!  Module still in memory"
        }
    }