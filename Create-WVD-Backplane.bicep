param location string = 'eastus'
param workspaceName string = 'bicep-wvd-workspace'
param hostpoolName string = 'bicep-wvd-hostpool'
param appgroupName string = 'bicep-wvd-appgroup'
var myTag = 'bicep-tag'
var hostpooltype = 'pooled'
var loadbalancertype = 'BreadthFirst'
var appgroupType = 'Desktop'

resource hp 'Microsoft.DesktopVirtualization/hostpools@2019-12-10-preview' = {
    name: hostpoolName
    location: location
    properties: {
      friendlyname: 'My Bicep generated Host pool'
      tag: myTag
      hostpooltype : hostpooltype
      loadbalancertype : loadbalancertype
    }
  }

resource ag 'Microsoft.DesktopVirtualization/applicationgroups@2019-12-10-preview' = {
name: appgroupName
location: location
properties: {
    friendlyname: 'My Bicep generated application Group'
    tag: myTag
    applicationgrouptype: appgroupType
    hostpoolarmpath: hp.id
  }
}

resource ws 'Microsoft.DesktopVirtualization/workspaces@2019-12-10-preview' = {
    name: workspaceName
    location: location
    properties: {
        friendlyname: 'My Bicep generated Workspace'
        tag: myTag
        applicationGroupReferences: []
    }
  }

output workspaceid string = ws.id