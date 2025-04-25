# Importation du module Active Directory
Import-Module ActiveDirectory

# Demande à l'utilisateur de choisir l'action (ajouter ou supprimer)
$action = Read-Host "Veuillez entrer 1 pour ajouter des ordinateurs au groupe ou 2 pour les supprimer"

if ($action -ne "1" -and $action -ne "2") {
    Write-Error "Action invalide. Veuillez entrer 1 pour ajouter ou 2 pour supprimer."
    exit 1
}

# Demande à l'utilisateur de fournir le nom du groupe AD
$groupName = Read-Host "Veuillez entrer le nom du groupe AD"

# Vérification de l'existence du groupe
try {
    $null = Get-ADGroup -Identity $groupName -ErrorAction Stop
} catch {
    Write-Error "Le groupe '$groupName' n'existe pas dans l'AD."
    exit 1
}

# Demande du chemin du fichier CSV
$csvPath = Read-Host "Veuillez entrer le chemin du fichier CSV contenant les ordinateurs"

if (-not (Test-Path $csvPath)) {
    Write-Error "Le fichier CSV '$csvPath' est introuvable."
    exit 1
}

# Import des données CSV
$computers = Import-Csv -Path $csvPath
if (!$computers -or $computers.Count -eq 0) {
    Write-Error "Le fichier CSV est vide ou ne contient pas de données valides."
    exit 1
}

if (-not $computers[0].PSObject.Properties["computer"]) {
    Write-Error "Le fichier CSV ne contient pas de colonne 'computer'."
    exit 1
}

# Initialisation du compteur pour les ajouts
[int]$addedCount = 0

# Traitement de chaque ligne : silence sur succès, affichage des erreurs/warnings
foreach ($entry in $computers) {
    $compName = $entry.computer

    try {
        # Récupération de l'objet ordinateur
        $computerAD = Get-ADComputer -Identity $compName -ErrorAction Stop

        if ($action -eq "1") {
            # Ajout silencieux
            Add-ADGroupMember -Identity $groupName -Members $computerAD -ErrorAction Stop
            # Incrémentation du compteur
            $addedCount++
        } else {
            # Suppression silencieuse
            Remove-ADGroupMember -Identity $groupName -Members $computerAD -Confirm:$false -ErrorAction Stop
        }
    }
    catch [Microsoft.ActiveDirectory.Management.ADIdentityNotFoundException] {
        # Ordinateur non trouvé
        Write-Warning "L'ordinateur '$compName' n'existe pas dans l'AD."
    }
    catch {
        # Autre erreur lors de l'opération
        Write-Error "Erreur sur '$compName' : $($_.Exception.Message)"
    }
}

# Affichage du récapitulatif des ajouts
if ($action -eq "1") {
    Write-Host "Nombre d'ordinateurs ajoutés au groupe '$groupName' : $addedCount" -ForegroundColor Green
}
