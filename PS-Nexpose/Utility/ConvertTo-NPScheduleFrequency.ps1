function ConvertTo-NPScheduleFrequency {
    <#
    .SYNOPSIS
        Helper function to take a Date object "start point" and output text that represents a schedule based on the switches provided
    #>

    [CmdletBinding()]Param(
        [Parameter(Mandatory=$True)]
        [DateTime]
        $Start,

        [Parameter(Mandatory=$True)]
        [ValidateSet("Daily","Weekly","MonthlyDate","MonthlyDay")]
        [String]
        $Recurrence,

        [Parameter(Mandatory=$False)]
        [Switch]
        $IncludeTime
    )
    switch ($Recurrence) {
        "Daily" {
            if ($IncludeTime) {
                return "Every Day at $($Start.ToString("h tt"))"
            } else {
                return "Every Day"
            }
        }

        "Weekly" {
            if ($IncludeTime) {
                return "Every $($Start.DayOfWeek) at $($Start.ToString("h tt"))"
            } else {
                return "Every $($Start.DayOfWeek)"
            }
        }

        "MonthlyDate" {
            $Day = $Start.Day.toString()
            if ($Day -in 1, 21, 31) {
                $Day = $Day + "st"
            } elseif ($Day -in 2, 22) {
                $Day = $Day + "nd"
            } elseif ($Day -in 3, 23) {
                $Day = $Day + "rd"
            } else {
                $Day = $Day + "th"
            }
            if ($IncludeTime) {
                return "Every $Day of the Month at $($Start.ToString("h tt"))"
            } else {
                return "Every $Day of the Month"
            }
        }

        "MonthlyDay" {
            $Iteration = [Math]::Truncate($Start.Day / 7) + 1
            if ($Iteration -eq "1") {
                $Iteration = "1st"
            } elseif ($Iteration -eq "2") {
                $Iteration = "2nd"
            } elseif ($Iteration -eq "3") {
                $Iteration = "3rd"
            } else {
                $Iteration = $Iteration + "th"
            }
            if ($IncludeTime) {
                return "Every $Iteration $($Start.DayOfWeek) of the Month at $($Start.ToString("h tt"))"
            } else {
                return "Every $Iteration $($Start.DayOfWeek) of the Month"
            }
        }
    }
}