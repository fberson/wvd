param location string = 'eastus'
param workspaceName string = 'bicep-wvd-workspace'
param hostpoolName string = 'bicep-wvd-hostpool'
param appgroupName string = 'bicep-wvd-appgroup'
param preferredAppGroupType string = 'Desktop'
param hostPoolType string = 'pooled'
param loadbalancertype string = 'BreadthFirst'
param appgroupType string = 'Desktop'

resource hp 'Microsoft.DesktopVirtualization/hostpools@2019-12-10-preview' = {
    name: hostpoolName
    location: location
    properties: {
      friendlyName: 'My Bicep generated Host pool'
      hostPoolType : hostPoolType
      loadBalancerType : loadbalancertype
      preferredAppGroupType: preferredAppGroupType
    }
  }

resource ag 'Microsoft.DesktopVirtualization/applicationgroups@2019-12-10-preview' = {
name: appgroupName
location: location
properties: {
    friendlyName: 'My Bicep generated application Group'
    applicationGroupType: appgroupType
    hostPoolArmPath: hp.id
  }
}

resource ws 'Microsoft.DesktopVirtualization/workspaces@2019-12-10-preview' = {
    name: workspaceName
    location: location
    properties: {
        friendlyName: 'My Bicep generated Workspace'
        applicationGroupReferences: []
    }
  }
output workspaceid string = ws.id
