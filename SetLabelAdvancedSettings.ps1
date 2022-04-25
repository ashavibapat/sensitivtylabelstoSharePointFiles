<#
https://docs.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell?view=exchange-ps
https://docs.microsoft.com/en-us/azure/information-protection/rms-client/clientv2-admin-guide-customizations#migrate-labels-from-secure-islands-and-other-labeling-solutions
https://docs.microsoft.com/en-us/azure/information-protection/rms-client/clientv2-admin-guide-customizations#extend-your-label-migration-rules-to-sharepoint-properties
#>

Connect-IPPSSession -UserPrincipalName BrianJ@M365x414263.OnMicrosoft.com
#(Get-Label -Identity "ABC-Public").settings
#(Get-Label -Identity "ABC-Confidential").settings
(Get-Label -Identity "General")  | Format-List
#(Get-Label -Identity "ABC-UnRestricted").settings
#(Get-Label -Identity "ABC-Confidential").settings
                                                                            <#[migration rule name],[Secure Islands custom property name],[Secure Islands metadata Regex value]#>
Set-Label -Identity "ABC-Public"  -AdvancedSettings @{labelByCustomProperties="ABCTestRule1,SensitivityLabels,1;#ABC-Public|0f4b2a50-9fd1-4706-9c2e-9ce44c16528e"}
Set-Label -Identity "ABC-General"  -AdvancedSettings @{labelByCustomProperties="ABCTestRule2,SensitivityLabels,4;#ABC-General|0a47f512-df78-424e-804d-36afd9554b41"}
Set-Label -Identity "ABC-Restricted"  -AdvancedSettings @{labelByCustomProperties="ABCTestRule3,SensitivityLabels,2;#ABC-Restricted|3d084af8-5a09-4b2a-b701-783c13a5f942"}
Set-Label -Identity "ABC-UnRestricted"  -AdvancedSettings @{labelByCustomProperties="ABCTestRule4,SensitivityLabels,3;#ABC-UnRestricted|865a9e86-7848-41cf-8dd1-f94f2c0a152b"}
Set-Label -Identity "ABC-Confidential"  -AdvancedSettings @{labelByCustomProperties="ABCTestRule5,SensitivityLabels,6;#ABC-Confidential|1b3435e7-431c-4f92-985a-3bec7cf5d61a"}
