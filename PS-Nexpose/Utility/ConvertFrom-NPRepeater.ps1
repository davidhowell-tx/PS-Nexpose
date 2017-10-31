function ConvertFrom-NPRepeater {
    [CmdletBinding()]Param(
        [Parameter(Mandatory=$True)]
        $InputObject
    )
    $Object = [PSCustomObject]@{
        PSTypeName = "Nexpose.Schedule"
        scheduleID = $InputObject.scheduleID
        scanName = $InputObject.scanName
        scanTemplate = $InputObject.template
        scanEngine = $InputObject.engine
        enabled = $InputObject.enabled
        timezone = $InputObject.timezoneID
        startTime = ConvertTo-DateTime $InputObject.startTime -MS
        nextRunTime = ConvertTo-DateTime $InputObject.nextRunTime -MS
        frequency = ""
        frequencyType = $InputObject.repeater.scheduleType
        maxExecutionHours = $InputObject.maxExecutionMS / 1000 / 60 / 60
        excludedTargets = $InputObject.excludedTargets
        includedTargetStrings = $InputObject.includedTargetStrings
        excludedTargetStrings = $InputObject.excludedTargetStrings
        includedAssetGroups = $InputObject.includedAssetGroups
        excludedAssetGroups = $InputObject.excludedAssetGroups
        interval = $InputObject.interval
    }
    switch ($InputObject.repeater.scheduleType) {
        "D" {
            $Object.frequency = ConvertTo-NPScheduleFrequency -Start $Object.startTime -Recurrence Daily -IncludeTime
        }
        "W" {
            $Object.frequency = ConvertTo-NPScheduleFrequency -Start $Object.startTime -Recurrence Weekly -IncludeTime
        }
        "M" {
            $Object.frequency = ConvertTo-NPScheduleFrequency -Start $Object.startTime -Recurrence MonthlyDate -IncludeTime
        }
        "K" {
            $Object.frequency = ConvertTo-NPScheduleFrequency -Start $Object.startTime -Recurrence MonthlyDay -IncludeTime
        }
    }
    return $Object
}