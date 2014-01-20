#Initial setup for the name pair randomizer

$testnames = "Syed, Kim, Sam, Hazem, Pilar, Terry, Amy, Greg, Pamela, Julie, David, Robert, Shai, Ann, Mason, Sharon, Dude"
$testnames = ($testnames.split(',')).trim()

### BUG: If a duplicate name is in the second list, both will get removed when one is matched. 
###      This causes a problem particularly with how the odd-number handler is written now, but will be masked when Primary handling is introduced.
###      This should preferrably be corrected in spite of that, however; perhaps by creating a separate random index for each person.

function Sort-Random {
    param([string[]]$names)

    $continue = $True

    if ($names.count % 2 -eq 1) { 
        #Note: to make this work, we should mark the person getting a second partner as a Primary.
        #Since there's no mechanism for that yet, we'll just hope they don't get themselves for now.
        Write-Warning "The number of people in your list is $($names.count), which is an odd number.`nPlease select a person to get two partners:"
        $i = 1
        $PossibleSelections = @()
        foreach ($name in $names) {
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
            $extra = $names[[int]$selection - 1]
            Write-Warning "$extra selected to take multiple partners."
            $names = $names + $extra
        }
    }

    if ($continue) {
        $GetRandom = $true
        while ($GetRandom) {
            $MasterList = foreach ($name in $names) {
                $random = Get-Random -Minimum 100000 -Maximum 150000
                if ($false) {
                    #for Primes, not implemented yet
                    #Reduce random number by 100000 to ensure it's at the top
                    $random = $random - 100000
                }

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
        $list1 = $MasterList[0..($names.count/2-1)]
        $list2 = $MasterList[($names.count/2)..($names.count)]

        $output = foreach ($name in $list1) {
            #get list of exceptions here
            $partner = $list2 | Get-Random # | where name -notin $exceptions
            $list2 = $list2 | where Name -ne $partner.name
            $props = @{'Name' = $name.name;
                       'Parter' = $partner.name}

            $obj = New-Object -TypeName PSObject -Property $props
            Write-Output $obj
        }
        Write-Output $output
    }
}

Sort-Random $testnames