#Initial setup for the name pair randomizer

$testnames = "Syed, Kim, Sam, Hazem, Pilar, Terry, Amy, Greg, Pamela, Julie, David, Robert, Shai, Ann, Mason, Sharon"
$testnames = ($testnames.split(',')).trim()

function Sort-Random {
    param([string[]]$names)

    if ($names.count % 2 -eq 1) { <# Odd number, how do we handle this? #> }

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
        $list2 = $list2 | where Name -ne $partner
        $props = @{'Name' = $name.name;
                   'Parter' = $partner.name}

        $obj = New-Object -TypeName PSObject -Property $props
        Write-Output $obj
    }
    Write-Output $output
}

Sort-Random $testnames