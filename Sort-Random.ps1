<######################################################################################
Functions for Powershell Scripting Games (improve this part)
Created 01-18-2014 by Christopher R. Lowery (The Powershell Bear)

Contributors:
CRL - Christopher R. Lowery

Changelog:
01-18-2014 - CRL: Created basic script; works for even numbers only, very basic.
01-19-2014 - CRL: Added logic to handle an odd number of participants and request which ones
    to give an extra pairing to; also fixed a bug that was causing pairings to not remove participants
    from $list2 as they got assigned.
    Discovered an unfixed new bug, that if the person selected to get two partners gets both copies of their
    name added to list2, both will be removed when they are pairef the first time, causing an unmatched person at
    the end.  setting them as Primary (which will eliminate the possibility that they will be matched to themselves)
    will fix this, but it should be corrected anyway.
01-20-2014 - CRL: Added framework for help (not written yet). Added validation for Names parameter, and marked Mandatory.
    Added Primary and Save parameters, though the latter will likely be moved to a different function.
    Fixed bug with duplicate names in $list2 getting removed at the same time by switching to removing them
    by their random (and unique) index number instead. Added support for Primary selections and set extra odd-match
    to process as a primary.
    Addendum: Fixed a bug with selection of odd extras introduced with Primary handling.
######################################################################################>

$testnames = "Syed, Kim, Sam, Hazem, Pilar, Terry, Amy, Greg, Pamela, Julie, David, Robert, Shai, Ann, Mason, Sharon, Dude"
$testnames = ($testnames.split(',')).trim()
$testprimes = "Martan, Leonard, Sheldon, Madison"
$testprimes = ($testprimes.split(',')).trim()

function Sort-Random {
<#
.SYNOPSIS

.DESCRIPTION

.PARAMETER Names

.PARAMETER Primary

.PARAMETER Save

.EXAMPLE

.EXAMPLE

#>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$True)]
        [ValidateCount(4,10000)]
        [string[]]
        $Names,

        [string[]]
        [ValidateCount(0,5)]
        $Primary,
        
        [switch]
        $Save
    )
    <#
        Notes about parameters:
        Names is set to require at least 4 input objects; otherwise, this won't work.
            Might increase this in the future.
        Primary is a separate list, not related to the first, which will be processed with lower random values.
        Save is a currently unused switch for telling the script to save the output.  This will likely be moved
            to a controlling script.
    #>

    $continue = $True

    $count = $Names.count + $Primary.count
    $PrimaryList = @()
    if ($Primary) { #if needed to prevent a blank primary from being added when Primary not used
        $PrimaryList += $Primary #allows us to break the validation count later
    }

    if ($count % 2 -eq 1) { 
        #Note: to make this work, we should mark the person getting a second partner as a Primary.
        #Since there's no mechanism for that yet, we'll just hope they don't get themselves for now.
        Write-Warning "The number of people in your list is $($count), which is an odd number."
        Write-Warning "Please select a person to get two partners:"
        $i = 1
        $OddList = $PrimaryList + $Names
        $PossibleSelections = @()
        foreach ($name in $PrimaryList) {
            Write-Output "$($i): $name (Primary)"
            $PossibleSelections += "$i"
            $i ++
        }
        foreach ($name in $Names) {
            Write-Output "$($i): $name"
            $PossibleSelections += "$i"
            $i ++
        }
        Write-Output "0: Cancel and try again"
        $selection = Read-Host -Prompt "Please select"
        if ($selection -eq "0") {
            Write-Warning "Cancelling random selection."
            $continue = $false
        }
        elseif ($selection -notin $PossibleSelections) {
            #should make this have it try again; being lazy for now
            Write-Warning "That was not a recoginzed selection; please try again."
            $continue = $false
        }
        else {
            $extra = $OddList[[int]$selection - 1]
            Write-Warning "$extra selected to take multiple partners."
            if ($extra -notin $PrimaryList) {
                #Ugly way to remove a string from a string array, but it works:
                $Names = $Names | foreach {if ($_ -ne $extra) {$_}}
                $PrimaryList += $extra
            }
            $PrimaryList += $extra
            $count ++  #This is needed later on for sorting the lists
        }
    }

    if ($continue) {
        $GetRandom = $true
        while ($GetRandom) {
            $MasterList = @()
            $MasterList += foreach ($name in $PrimaryList) {
                $random = Get-Random -Minimum 1 -Maximum 50000
                $props = @{'Name' = $name;
                           'Random' = $random}
                $obj = New-Object -TypeName PSObject -Property $props
                Write-Output $obj
            }
            $MasterList += foreach ($name in $Names) {
                $random = Get-Random -Minimum 100000 -Maximum 150000
                $props = @{'Name' = $name;
                           'Random' = $random}
                $obj = New-Object -TypeName PSObject -Property $props
                Write-Output $obj
            }
        
            #Make sure all random numbers are unique; otherwise, re-randomize the list
            if ( ($MasterList | Group -Property Random).count -eq $MasterList.count ) {
                $GetRandom = $False
            }
        }

        $MasterList = $MasterList | Sort -Property Random
        $list1 = $MasterList[0..($count/2-1)]
        $list2 = $MasterList[($count/2)..($count)]

        $output = foreach ($name in $list1) {
            #get list of exceptions here
            $partner = $list2 | Get-Random # | where name -notin $exceptions
            $list2 = $list2 | where Random -ne $partner.Random
            $props = @{'Name' = $name.name;
                       'Parter' = $partner.name}

            $obj = New-Object -TypeName PSObject -Property $props
            Write-Output $obj
        }
        Write-Output $output
    }
}

Sort-Random -Names $testnames -Primary $testprimes