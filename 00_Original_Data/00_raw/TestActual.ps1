# Percorsi file
$forecastPath = "C:\Users\HP\Documents\GithubWorks\ForecastTimestamp.csv"
$outputPath   = "C:\Users\HP\Documents\GithubWorks\TestActual_Full.csv"

# Import CSV
$data = Import-Csv $forecastPath

# ------------------------------
# Controlla che ci siano dati
# ------------------------------
if (-not $data -or $data.Count -eq 0) {
    Write-Host "Errore: il CSV di forecast è vuoto o non leggibile!"
    exit
}

# ------------------------------
# Prendi solo l’ultima SnapshotDate
# ------------------------------
$maxDate = ($data | Measure-Object -Property SnapshotDate -Maximum).Maximum
Write-Host "Ultima SnapshotDate trovata: $maxDate"

$dataFiltered = $data | Where-Object { $_.SnapshotDate -eq $maxDate }

if ($dataFiltered.Count -eq 0) {
    Write-Host "Nessun contratto corrisponde all'ultima SnapshotDate!"
    exit
}

# ------------------------------
# Funzione markup realistico
# ------------------------------
function Get-BaseMarkup {
    $rand = Get-Random -Minimum 1 -Maximum 101
    if ($rand -le 5) { return (Get-Random -Minimum 0.02 -Maximum 0.05) }       # quasi break-even
    elseif ($rand -le 55) { return (Get-Random -Minimum 0.08 -Maximum 0.15) }   # core business
    elseif ($rand -le 85) { return (Get-Random -Minimum 0.15 -Maximum 0.25) }   # buoni margini
    else { return (Get-Random -Minimum 0.25 -Maximum 0.45) }                     # premium/rare
}

# ------------------------------
# Lista risultato
# ------------------------------
$result = @()

foreach ($row in $dataFiltered) {

    # Log di progresso
    Write-Host "Processing contract id: $($row.idContract) from $($row.startDate) to $($row.endDate) / $($row.endDateActual)"

    # Sicurezza sulle date
    $startDate = if ($row.startDate -and $row.startDate -ne "") { [datetime]$row.startDate } else { continue }

    if ($row.endDateActual -and $row.endDateActual -ne "") { 
        $endDate = [datetime]$row.endDateActual 
    }
    elseif ($row.endDate -and $row.endDate -ne "") { 
        $endDate = [datetime]$row.endDate 
    }
    else { 
        $endDate = Get-Date "2025-12-31" 
    }

    # Salta contratti con startDate > endDate
    if ($startDate -gt $endDate) {
        Write-Host "Skipping contract id $($row.idContract): startDate > endDate"
        continue
    }

    $baseMarkup = Get-BaseMarkup

    # Loop mese per mese
    $current = Get-Date -Year $startDate.Year -Month $startDate.Month -Day 1
    while ($current -le $endDate) {

        # Calcola monthlyCost: costo settimanale * 4.33 settimane
        $baseCost = [double]$row.hourlyCost * [double]$row.weeklyHours * 4.33
        $variation = Get-Random -Minimum -0.05 -Maximum 0.05
        $monthlyCost = $baseCost * (1 + $variation)

        # Rumore sul markup per agosto/dicembre
        $month = $current.Month
        if ($month -eq 8 -or $month -eq 12) { $markupNoise = Get-Random -Minimum -0.10 -Maximum 0.10 }
        else { $markupNoise = Get-Random -Minimum -0.03 -Maximum 0.03 }

        $finalMarkup = $baseMarkup + $markupNoise

        # Calcola monthlyRevenue basato su costo mensile + markup
        $monthlyRevenue = $monthlyCost * (1 + $finalMarkup)

        # Arrotonda a interi
        $monthlyCost = [math]::Round($monthlyCost,0)
        $monthlyRevenue = [math]::Round($monthlyRevenue,0)

        # InvoiceMonth AAAAMM
        $invoiceMonth = $current.ToString("yyyyMM")

        # Aggiungi riga al risultato
        $result += [PSCustomObject]@{
            idContract     = $row.idContract
            branch         = $row.branch
            client         = $row.client
            workerName     = $row.workerName
            idWorker       = $row.idWorker
            startDate      = $row.startDate
            endDate        = $row.endDate
            endDateActual  = $row.endDateActual
            weeklyHours    = $row.weeklyHours
            internalSales  = $row.internalSales
            monthlyCost    = $monthlyCost
            monthlyRevenue = $monthlyRevenue
            InvoiceMonth   = $invoiceMonth
        }

        # Vai al mese successivo
        $current = $current.AddMonths(1)
    }
}

# ------------------------------
# Esporta CSV finale
# ------------------------------
$result | Export-Csv -Path $outputPath -NoTypeInformation -Encoding UTF8

Write-Host "File generato correttamente in: $outputPath"