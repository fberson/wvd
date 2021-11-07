//Scaling plan parameters
param scalingPlanName string
param scalingPlanLocation string
param scalingPlanDescription string
param scalingPlanExclusionTag string
param scalingPlanFriendlyName string
@allowed([
  'Pooled'
])
param scalingPlanHostPoolType string
param scalingPlanTimeZone string

//Weekdays schedule parameters
param weekdaysScheduleName string
param weekdaysSchedulerampUpStartTimeHour int
param weekdaysSchedulerampUpStartTimeMinute int
@allowed([
  'BreadthFirst'
  'DepthFirst'
])
param weekdaysSchedulerampUpLoadBalancingAlgorithm string
param weekdaysSchedulerampUpMinimumHostsPct int
param weekdaysSchedulerampUpCapacityThresholdPct int
param weekdaysSchedulepeakStartTimeHour int
param weekdaysSchedulepeakStartTimeMinute int
param weekdaysSchedulerampDownStartTimeHour int
param weekdaysSchedulerampDownStartTimeMinute int
@allowed([
  'BreadthFirst'
  'DepthFirst'
])
param weekdaysSchedulerampDownLoadBalancingAlgorithm string
param weekdaysScheduleoffPeakStartTimeHour int
param weekdaysScheduleoffPeakStartTimeMinute int
@allowed([
  'BreadthFirst'
  'DepthFirst'
])
param weekdaysSchedulepeakLoadBalancingAlgorithm string
param weekdaysSchedulerampDownMinimumHostsPct int
param weekdaysSchedulerampDownCapacityThresholdPct int
param weekdaysSchedulerampDownForceLogoffUsers bool
@allowed([
  'ZeroSessions'
  'ZeroActiveSessions'
])
param weekdaysSchedulerampDownStopHostsWhen string
param weekdaysrampDownWaitTimeMinutes int
param weekdaysrampDownNotificationMessage string

//weekends schedule parameters
param weekendsScheduleName string
param weekendsSchedulerampUpStartTimeHour int
param weekendsSchedulerampUpStartTimeMinute int
@allowed([
  'BreadthFirst'
  'DepthFirst'
])
param weekendsSchedulerampUpLoadBalancingAlgorithm string
param weekendsSchedulerampUpMinimumHostsPct int
param weekendsSchedulerampUpCapacityThresholdPct int
param weekendsSchedulepeakStartTimeHour int
param weekendsSchedulepeakStartTimeMinute int
param weekendsSchedulerampDownStartTimeHour int
param weekendsSchedulerampDownStartTimeMinute int
@allowed([
  'BreadthFirst'
  'DepthFirst'
])
param weekendsSchedulerampDownLoadBalancingAlgorithm string
param weekendsScheduleoffPeakStartTimeHour int
param weekendsScheduleoffPeakStartTimeMinute int
@allowed([
  'BreadthFirst'
  'DepthFirst'
])
param weekendsSchedulepeakLoadBalancingAlgorithm string
param weekendsSchedulerampDownMinimumHostsPct int
param weekendsSchedulerampDownCapacityThresholdPct int
param weekendsSchedulerampDownForceLogoffUsers bool
@allowed([
  'ZeroSessions'
  'ZeroActiveSessions'
])
param weekendsSchedulerampDownStopHostsWhen string
param weekendsrampDownWaitTimeMinutes int
param weekendsrampDownNotificationMessage string

@description('Create AVD Scaling plan including a weekdays & weekens schdedule')
resource sp 'Microsoft.DesktopVirtualization/scalingPlans@2021-09-03-preview' = {
  name: scalingPlanName
  location: scalingPlanLocation
  properties: {
    description: scalingPlanDescription
    exclusionTag: scalingPlanExclusionTag
    friendlyName: scalingPlanFriendlyName
    hostPoolType: scalingPlanHostPoolType
    schedules: [
      {
        rampUpStartTime: {
          hour: weekdaysSchedulerampUpStartTimeHour
          minute: weekdaysSchedulerampUpStartTimeMinute
        }
        peakStartTime: {
          hour: weekdaysSchedulepeakStartTimeHour
          minute: weekdaysSchedulepeakStartTimeMinute
        }
        rampDownStartTime: {
          hour: weekdaysSchedulerampDownStartTimeHour
          minute: weekdaysSchedulerampDownStartTimeMinute
        }
        offPeakStartTime: {
          hour: weekdaysScheduleoffPeakStartTimeHour
          minute: weekdaysScheduleoffPeakStartTimeMinute
        }
        name: weekdaysScheduleName
        daysOfWeek: [
          'Monday'
          'Tuesday'
          'Wednesday'
          'Thursday'
          'Friday'
        ]
        rampUpLoadBalancingAlgorithm: weekdaysSchedulerampUpLoadBalancingAlgorithm
        rampUpMinimumHostsPct: weekdaysSchedulerampUpMinimumHostsPct
        rampUpCapacityThresholdPct: weekdaysSchedulerampUpCapacityThresholdPct
        peakLoadBalancingAlgorithm: weekdaysSchedulepeakLoadBalancingAlgorithm
        rampDownLoadBalancingAlgorithm: weekdaysSchedulerampDownLoadBalancingAlgorithm
        rampDownMinimumHostsPct: weekdaysSchedulerampDownMinimumHostsPct
        rampDownCapacityThresholdPct: weekdaysSchedulerampDownCapacityThresholdPct
        rampDownForceLogoffUsers: weekdaysSchedulerampDownForceLogoffUsers
        rampDownWaitTimeMinutes: weekdaysrampDownWaitTimeMinutes
        rampDownNotificationMessage: weekdaysrampDownNotificationMessage
        rampDownStopHostsWhen: weekdaysSchedulerampDownStopHostsWhen
        offPeakLoadBalancingAlgorithm: weekdaysSchedulepeakLoadBalancingAlgorithm
      }
      {
        rampUpStartTime: {
          hour: weekendsSchedulerampUpStartTimeHour
          minute: weekendsSchedulerampUpStartTimeMinute
        }
        peakStartTime: {
          hour: weekendsSchedulepeakStartTimeHour
          minute: weekendsSchedulepeakStartTimeMinute
        }
        rampDownStartTime: {
          hour: weekendsSchedulerampDownStartTimeHour
          minute: weekendsSchedulerampDownStartTimeMinute
        }
        offPeakStartTime: {
          hour: weekendsScheduleoffPeakStartTimeHour
          minute: weekendsScheduleoffPeakStartTimeMinute
        }
        name: weekendsScheduleName
        daysOfWeek: [
          'Saturday'
          'Sunday'
        ]
        rampUpLoadBalancingAlgorithm: weekendsSchedulerampUpLoadBalancingAlgorithm
        rampUpMinimumHostsPct: weekendsSchedulerampUpMinimumHostsPct
        rampUpCapacityThresholdPct: weekendsSchedulerampUpCapacityThresholdPct
        peakLoadBalancingAlgorithm: weekendsSchedulepeakLoadBalancingAlgorithm
        rampDownLoadBalancingAlgorithm: weekendsSchedulerampDownLoadBalancingAlgorithm
        rampDownMinimumHostsPct: weekendsSchedulerampDownMinimumHostsPct
        rampDownCapacityThresholdPct: weekendsSchedulerampDownCapacityThresholdPct
        rampDownForceLogoffUsers: weekendsSchedulerampDownForceLogoffUsers
        rampDownWaitTimeMinutes: weekendsrampDownWaitTimeMinutes
        rampDownNotificationMessage: weekendsrampDownNotificationMessage
        rampDownStopHostsWhen: weekendsSchedulerampDownStopHostsWhen
        offPeakLoadBalancingAlgorithm: weekendsSchedulepeakLoadBalancingAlgorithm
      }
    ]
    timeZone: scalingPlanTimeZone
    hostPoolReferences: []
  }
}
