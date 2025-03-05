$CSVFile = "C:\AD_users.csv"
$CSVData = Import-Csv -Path $CSVFile -Delimiter ";" -Encoding UTF8

Foreach($Utilisateur in $CSVData){

    $UtilisateurPrenom = $Utilisateur.Prenom
    $UtilisateurNom = $Utilisateur.Nom
    $UtilisateurLogin = ($UtilisateurPrenom).Substring(0,1) + "." + $UtilisateurNom
    $UtilisateurEmail = "$UtilisateurLogin@M2M.lan"
    $UtilisateurMotDePasse = "Azerty1234$"

# Vérifier la présence de l'utilisateur dans l'AD

if(Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin})
{
    Write-Warning "L'identifiant $UtilisateurLogin existe déjà dans l'AD"
}
else
{
    New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
           -DisplayName "$UtilisateurNom $UtilisateurPrenom" `
           -GivenName $UtilisateurPrenom `
           -Surname $UtilisateurNom `
           -SamAccountName $UtilisateurLogin `
           -UserPrincipalName "$UtilisateurLogin@M2M.lan" `
           -EmailAddress $UtilisateurEmail `
           -Path "OU=Utilisateurs,DC=M2M,DC=LAN" `
           -AccountPassword (ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
           -Enabled $true

Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"

    }

} 

# Importer le module Active Directory
Import-Module ActiveDirectory

# Créer l'OU "Techniciens"
$NomOU = "Techniciens"
$CheminOU = "DC=M2M,DC=LAN"

# Vérifier si l'OU existe déjà
if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $NomOU} -SearchBase $CheminOU)) {
    New-ADOrganizationalUnit -Name $NomOU -Path $CheminOU
    Write-Output "L'OU '$NomOU' a été créée dans '$CheminOU'."
} else {
    Write-Output "L'OU '$NomOU' existe déjà."
}

# Définir les informations des utilisateurs à créer
$Utilisateurs = @(
    @{
        Prenom = "Alice"
        Nom = "Dupont"
        Login = "a.dupont"
        Email = "a.dupont@M2M.lan"
        MotDePasse = "Azerty1234$"
    },
    @{
        Prenom = "Bob"
        Nom = "Martin"
        Login = "b.martin"
        Email = "b.martin@M2M.lan"
        MotDePasse = "Azerty1234$"
    }
)

# Ajouter les utilisateurs dans l'OU "Techniciens"
foreach ($Utilisateur in $Utilisateurs) {
    $UtilisateurNom = $Utilisateur.Nom
    $UtilisateurPrenom = $Utilisateur.Prenom
    $UtilisateurLogin = $Utilisateur.Login
    $UtilisateurEmail = $Utilisateur.Email
    $UtilisateurMotDePasse = $Utilisateur.MotDePasse

    # Vérifier la présence de l'utilisateur dans l'AD
    if (-not (Get-ADUser -Filter {SamAccountName -eq $UtilisateurLogin})) {
        New-ADUser -Name "$UtilisateurNom $UtilisateurPrenom" `
                   -DisplayName "$UtilisateurNom $UtilisateurPrenom" `
                   -GivenName $UtilisateurPrenom `
                   -Surname $UtilisateurNom `
                   -SamAccountName $UtilisateurLogin `
                   -UserPrincipalName "$UtilisateurEmail" `
                   -EmailAddress $UtilisateurEmail `
                   -Path "OU=$NomOU,$CheminOU" `
                   -AccountPassword (ConvertTo-SecureString $UtilisateurMotDePasse -AsPlainText -Force) `
                   -Enabled $true

        Write-Output "Création de l'utilisateur : $UtilisateurLogin ($UtilisateurNom $UtilisateurPrenom)"
    } else {
        Write-Warning "L'utilisateur $UtilisateurLogin existe déjà dans l'AD."
    }
}
