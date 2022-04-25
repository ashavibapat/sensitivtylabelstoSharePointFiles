# Applying Sensitivity Labels to SharePoint Files
In this article I will talk about the different ways to apply Sensitivity Labels to files stored in SharePoint.

# What are Sensitivity Labels?
Sensitivity labels are used to classify email messages, documents, sites, and more. When a label is applied (automatically or by the user), the content or site is protected based on the settings you choose. For example, you can create labels that encrypt files, add content marking, and control user access to specific sites.

https://docs.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels?view=o365-worldwide
https://docs.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels-sharepoint-onedrive-files?view=o365-worldwide

# Problem Statement
"Currently the Confidentiality column which is part of all content types represents the document classification (e.g. ABC-PUBLIC). As of right now this is just metadata. In SPO, sensitivity labels will be used to classify documents of different file types. At first, during the content migration ,Team must migrate the confidentiality column to SPO. Customer will provide a mapping between old confidentiality values to new sensitivity labels (e.g., all current SP 2013 ABC-PUBLIC values need to be transformed to the ABC-PUBLIC sensitivity label). Team must then transform confidentiality values to sensitivity labels and finally remove the confidentiality column. 

# Options
|  SharePoint OnPrem         | SharePoint Online        |
| ------------- |:-------------:| 
| AIP Scanner       | SetSensitivityLabel Beta API | 
| Set-AIPFileLabel PowerShell command   | Set default label for Document Library -PREVIEW | 
| MIP SDK   | MIP SDK | 
|    | MCAS | 
|    | Auto labelling policies | 

[Licensing requirements](https://docs.microsoft.com/en-us/office365/servicedescriptions/microsoft-365-service-descriptions/microsoft-365-tenantlevel-services-licensing-guidance/microsoft-365-security-compliance-licensing-guidance#microsoft-purview-information-protection-sensitivity-labeling)

# Capability Matrix
![Capability Matrix](/SensitivityLabelsapabilityMatrix.png "Capability Matrix Image!")

# Autolabelling policies
When you create a sensitivity label, you can automatically assign that label to files and emails when it matches conditions that you specify.

## Prerequisites
https://docs.microsoft.com/en-us/microsoft-365/compliance/apply-sensitivity-label-automatically?view=o365-worldwide#prerequisites-for-auto-labeling-policies

## Creating a policy
https://docs.microsoft.com/en-us/microsoft-365/compliance/apply-sensitivity-label-automatically?view=o365-worldwide#creating-an-auto-labeling-policy

## Capabilities: https://myignite.microsoft.com/archives/IG20-OD273
There are two different methods for automatically applying a sensitivity label to content in Microsoft 365:
Client-side labeling when users edit documents or compose (also reply or forward) emails: Use a label that's configured for auto-labeling for files and emails (includes Word, Excel, PowerPoint, and Outlook).
Service-side labeling when content is already saved (in SharePoint or OneDrive) or emailed (processed by Exchange Online): Use an auto-labeling policy.

## Limitations
- Only Office files for Word (.docx), PowerPoint (.pptx), and Excel (.xlsx) are supported.
- No provision to set rules by reading metadata of document.
- These files can be auto-labeled at rest before or after the auto-labeling policies are created. Files can't be auto-labeled if they're part of an open session (the file is open).
- Currently, attachments to list items aren't supported and won't be auto-labeled.
- Maximum of 25,000 automatically labeled files in your tenant per day.
- Maximum of 100 auto-labeling policies per tenant, each targeting up to 100 sites (SharePoint or OneDrive) when they're specified individually. You can also specify all sites, and this configuration is exempt from the 100 sites maximum.

# AIP Scanner
The AIP scanner runs as a service on Windows Server and allows scanning below locations. Stores configuration in onprem SQL DB instance.UNC paths for network shares that use the SMB or NFS (Preview) protocols and SharePoint document libraries and folder for SharePoint Server 2019 through SharePoint Server 2013.The scanner uses the Azure Information Protection client and can classify and protect the same types of files as the client. 

## Prerequisites
https://docs.microsoft.com/en-us/azure/information-protection/deploy-aip-scanner-prereqs

## Installing and Deploying the scanner
https://docs.microsoft.com/en-us/azure/information-protection/deploy-aip-scanner-configure-install?tabs=azure-portal-only
https://docs.microsoft.com/en-us/powershell/exchange/connect-to-scc-powershell?view=exchange-ps

## Capabilities: https://www.youtube.com/watch?v=f1gy1KalSts
- Run the scanner in discovery mode only to create reports that check to see what happens when your files are labeled.
- Run the scanner to discover files with sensitive information, without configuring labels that apply automatic classification.
- Run the scanner automatically to apply labels as configured. Define a file types list to specify specific files to scan or to exclude.
- PowerShell commands like below to set label advanced settings which specify metadata column(Classification) is to be read.
`Set-Label -Identity "ABC-Confidential"  -AdvancedSettings @{labelByCustomProperties="ABCTestRule5,SensitivityLabels,5;#DNB-Confidential|4d18ca4b-afa3-492d-93a9-231172edea3d"}`

## Limitations
This setting is supported when you use Word, Excel, and PowerPoint and depends on the SharePoint field values properly propagating to Document properties.
When you install the Azure Information Protection unified labeling client, PowerShell commands are automatically installed as part of the AzureInformationProtection module, with cmdlets for labeling. The module enables you to manage the client by running commands for automation scripts.

# Set-AIPFileLabel
Sets or removes an Azure Information Protection label for a file and sets or removes the protection according to the label configuration or custom permissions.

## Prerequisites
https://docs.microsoft.com/en-us/azure/information-protection/rms-client/clientv2-admin-guide-powershell#prerequisites-for-using-the-azureinformationprotection-module

## Capabilitites
- For the AIP unified labeling client, the Set-AIPFileLabel cmdlet sets or removes a sensitivity label for one or more files. This action can automatically apply protection when labels are configured to apply encryption.
`Set-AIPFileLabel -LabelId <Guid>  [-JustificationMessage <String>]  [-Owner <String>]  [-PreserveFileDetails]   [-Path] <String[]>]`
- Additionally, you can use this cmdlet to apply custom permissions when they are created as an ad-hoc protection policy object with the New-AIPCustomPermissions cmdlet.

## Limitations
- While it can Preserve Modified timestamp and Modified By, it loses all the other field values for the file. Custom script must handle readding field values back to item.
- Cannot be applied to file types like msg which was a major requirement for customer. We overcame this by converting msg files to eml.
- Doesn’t work properly with older office file formats. Gives Internal server errors.
- Commands for Get and Set label are slow and process intensive.
- File types supported
https://docs.microsoft.com/en-us/azure/information-protection/rms-client/clientv2-admin-guide-file-types

# Beta setsensitivityLabel API
A simple REST API call like below to apply sensitivity labels to documents stored in SPO site.
`“https://abc.sharepoint.com/sites/testsite/_api/v2.1/drives/"+ $driveId + "/items/"+ $docID + "/setsensitivityLabel" `

## Reference
https://www.linkedin.com/pulse/programatic-way-apply-sensitivity-label-file-sanjoyan-mustafi/

## Prerequisites
This only works "on behalf of" a user. In other words, you cannot call this api from an app that is registered in Azure AD which runs with "AppOnly" token

## Capabilities
Only works with Office file types.
https://docs.microsoft.com/en-us/microsoft-365/compliance/sensitivity-labels-office-apps?view=o365-worldwide#office-file-types-supported

## Limitations
- You will need permission to every single site in SharePoint for that; even Global admin doesn't have that unless added manually. On top of that you will be subject to heavy throttling. Also, the api is in beta stage so do test it out and not much documentation in this stage and subject to change anytime.
- Doesn’t retain Modified timestamp and Modified By

# MIP SDK
The MIP SDK exposes the labeling and protection services from Office 365 Security and Compliance Center, to third-party applications and services. Developers can use the SDK to build native support for applying labels and protection to files .Before you can release an application developed with MIP to the public, you must apply for and complete a formal agreement with Microsoft. This agreement is not required for applications that are intended only for internal use.

 ## Prerequisites
https://docs.microsoft.com/en-us/information-protection/develop/setup-configure-mip#prerequisites

## Capabilities
https://docs.microsoft.com/en-us/information-protection/develop/concept-apis-use-cases

- Two options offered by File engine to apply label. Both cases file stream is used to upload file back to SPO.	
    - Work with SPO files downloaded on file system.
    - Work with SPO file stream.
- Creates a new file version and doesn’t retain Modified, Modified By as CSOM code is used to upload file stream back to SPO.

## Limitations
- Custom code, needs considerations for scaling in migration scenarios. Not recommended due to working with in memory file streams and throttling issues.
- File tpes supported - Special considerations for **msg** files.
https://docs.microsoft.com/en-us/information-protection/develop/concept-email
https://docs.microsoft.com/en-us/information-protection/develop/concept-supported-filetypes


# Microsoft Defender for Cloud Apps
Microsoft Defender for Cloud Apps is a Cloud Access Security Broker (CASB) that supports various deployment modes including log collection, API connectors, and reverse proxy. It provides rich visibility, control over data travel, and sophisticated analytics to identify and combat cyberthreats across all your Microsoft and third-party cloud services. CASBs act as a gatekeeper to broker access in real time between your enterprise users and cloud resources they use, wherever your users are located and regardless of the device they are using.

## Prerequisites
https://docs.microsoft.com/en-us/defender-cloud-apps/azip-integration#prerequisites

## Capabilities
Microsoft Defender for Cloud Apps lets you automatically apply sensitivity labels from Microsoft Information Protection. These labels will be applied to files as a file policy governance action, and depending on the label configuration, can apply encryption for additional protection

## Limitations
- File Types supported:-Word: docm, docx, dotm, dotx Excel: xlam, xlsm, xlsx, xltx PowerPoint: potm, potx, ppsx, ppsm, pptm, pptx PDF
- The ability to apply a sensitivity label is a powerful capability. To protect customers from mistakenly applying a label to a large number of files, as a safety precaution there is a daily limit of 100 Apply label actions per app, per tenant. After the daily limit is reached, the apply label action pauses temporarily and continues automatically the next day (after 12:00 UTC). To raise the limit for your tenant, open a support ticket. 
- Limitation of 3.000 labels per day.

# Observations
- SPO Sensitivity column shows value of label only for Office type of files. 
- Needs AIP viewer for checking label on all other file types.
- To protect generic file types, which do not have built-in support for protection, while ensuring that recipients will be able to access them as expected, we recommend that you define the recipient as a co-owner of the file. For more information, see Protecting generic file types.
- Labels cannot be applied to files which are open, checked out, empty. encrypted by other protocols.
- Only encrypted labels are applied to all versions of the file.

# Resources
- [Information & support for Azure Information Protection - AIP | Microsoft Docs](https://docs.microsoft.com/en-us/azure/information-protection/information-support)
 - [Yammer : Microsoft Information Protection Team : Home](https://www.yammer.com/AskIPTeam/#/home)
- [Apply a sensitivity label to a model in Microsoft SharePoint Syntex](https://docs.microsoft.com/en-us/microsoft-365/contentunderstanding/apply-a-sensitivity-label-to-a-model)
- ["Default” label for a document library ](https://www.linkedin.com/pulse/default-label-document-library-sanjoyan-mustafi/)








