param adDomainName string
param assetLocation string = 'https://raw.githubusercontent.com/fberson/wvd/master/'
param existingAvailabilitySetName string
param domainJoinUPN string
param existingSharedImageGalleryName string
param existingSharedImageGalleryDefinitionName string
param existingSharedImageGalleryVersionName string = 'latest'
param existingSharedImageGalleryResourceGroup string
param existingSubnetName string
param existingVnetName string
param existingVnetResourceGroupName string
param hostNamePrefixWVD string
param numberOfInstancesWVD int = 10
param ouLocationWVDSessionHost string
param sequenceStartNumberWVDHost int = 1
param virtualMachineSizeWVD string = 'Standard_D4s_v3'
param configureLogAnalyticsWorkspace bool = false

@secure()
param localAdminPassword string

@secure()
param domainJoinPassword string

@secure()
param registrationKey string

var domainJoinOptions = 3
var networkSubnetId = '${networkVnetId}/subnets/${existingSubnetName}'
var networkVnetId = resourceId(existingVnetResourceGroupName, 'Microsoft.Network/virtualNetworks', existingVnetName)
var storage = {
  type: 'StandardSSD_LRS'
}
var virtualmachineosdisk = {
  cacheOption: 'ReadWrite'
  createOption: 'FromImage'
  diskName: 'OS'
}
var vmTimeZone = 'W. Europe Standard Time'
var networkAdapterIPConfigName = 'ipconfig'
var networkAdapterNamePostFix = '-nic'
var networkAdapterIPAllocationMethod = 'Dynamic'
var imageResourceId = resourceId(existingSharedImageGalleryResourceGroup, 'Microsoft.Compute/galleries/images/versions', existingSharedImageGalleryName, existingSharedImageGalleryDefinitionName, existingSharedImageGalleryVersionName)
var configurationScriptWVD = 'Add-WVDHostToHostpoolSpringV2.ps1'

resource avset 'Microsoft.Compute/availabilitySets@2020-06-01' = {
  name: existingAvailabilitySetName
  location: resourceGroup().location
  tags: {
    displayName: 'WVD AvailabilitySet'
  }
  properties: {
    platformUpdateDomainCount: 2
    platformFaultDomainCount: 2
  }
  sku: {
    name: 'Aligned'
  }
}

resource nic 'Microsoft.Network/networkInterfaces@2020-06-01' = [for i in range(0, numberOfInstancesWVD): {
  name: '${hostNamePrefixWVD}-${(i+sequenceStartNumberWVDHost)}${networkAdapterNamePostFix}'
  tags: {
    displayName: 'WVD Session Host Network interfaces'
  }
  location: resourceGroup().location
  properties: {
    ipConfigurations: [
      {
        name: networkAdapterIPConfigName
        properties: {
          privateIPAllocationMethod: networkAdapterIPAllocationMethod
          subnet: {
            id: networkSubnetId
          }
        }
      }
    ]
  }
}]

resource vm 'Microsoft.Compute/virtualMachines@2020-06-01' = [for i in range(0, numberOfInstancesWVD): {
  name: '${hostNamePrefixWVD}-${(i+sequenceStartNumberWVDHost)}'
  tags: {
    displayName: 'WVD Session Host Virtual Machines'
  }
  location: resourceGroup().location
  properties: {
    licenseType: 'Windows_Client'
    hardwareProfile: {
      vmSize: virtualMachineSizeWVD
    }
    availabilitySet: {
      id: avset.id
    }
    osProfile: {
      computerName: '${hostNamePrefixWVD}-${(i+sequenceStartNumberWVDHost)}'
      adminUsername: '${hostNamePrefixWVD}-${(i+sequenceStartNumberWVDHost)}-adm'
      adminPassword: localAdminPassword
      windowsConfiguration: {
        timeZone: vmTimeZone
      }
    }
    storageProfile: {
      osDisk: {
        name: '${hostNamePrefixWVD}-${(i+sequenceStartNumberWVDHost)}-${virtualmachineosdisk.diskName}'
        managedDisk: {
          storageAccountType: storage.type
        }
        osType: 'Windows'
        caching: virtualmachineosdisk.cacheOption
        createOption: virtualmachineosdisk.createOption
      }
      imageReference: {
        id: imageResourceId
      }
      dataDisks: []
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic[i].id
        }
      ]
    }
  }
}]

resource wvd 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, numberOfInstancesWVD): {
  name: '${vm[i].name}/wvd'
  tags: {
    displayName: 'PowerShell Extension'
  }
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'CustomScriptExtension'
    typeHandlerVersion: '1.8'
    autoUpgradeMinorVersion: true
    settings: {
      fileUris: [
        '${assetLocation}${configurationScriptWVD}'
      ]
    }
    protectedSettings: {
      commandToExecute: 'powershell.exe -ExecutionPolicy Unrestricted -File ${configurationScriptWVD} ${registrationKey} >> ${configurationScriptWVD}.log 2>&1'
    }
  }
}]

resource domainjoin 'Microsoft.Compute/virtualMachines/extensions@2020-06-01' = [for i in range(0, numberOfInstancesWVD): {
  name: '${vm[i].name}/domainjoin'
  tags: {
    displayName: 'DomainJoin Extension'
  }
  location: resourceGroup().location
  properties: {
    publisher: 'Microsoft.Compute'
    type: 'JsonADDomainExtension'
    typeHandlerVersion: '1.3'
    autoUpgradeMinorVersion: true
    settings: {
      Name: adDomainName
      OUPath: ouLocationWVDSessionHost
      User: domainJoinUPN
      Restart: true
      Options: domainJoinOptions
    }
    protectedSettings: {
      Password: domainJoinPassword
    }
  }
  dependsOn: [
    wvd[i]
  ]
}]
