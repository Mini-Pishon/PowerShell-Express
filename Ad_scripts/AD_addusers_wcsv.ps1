$CSVFile = "C:\AD_users.csv"
$CSVData = Import-Csv -Path $CSVFile -Delimiter ";" -Encoding UTF8

foreach ($User in $CSVData) {
    $UserFirstName = $User.Prenom
    $UserLastName = $User.Nom
    $UserLogin = ($UserFirstName).Substring(0, 1) + "." + $UserLastName
    $UserEmail = "$UserLogin@dinoland.lan"
    $UserPassword = "Azerty1234$"

    # Check if the user exists in AD
    if (Get-ADUser -Filter {SamAccountName -eq $UserLogin}) {
        Write-Warning "The login $UserLogin already exists in AD"
    } else {
        New-ADUser -Name "$UserLastName $UserFirstName" `
                   -DisplayName "$UserLastName $UserFirstName" `
                   -GivenName $UserFirstName `
                   -Surname $UserLastName `
                   -SamAccountName $UserLogin `
                   -UserPrincipalName "$UserLogin@dinoland.lan" `
                   -EmailAddress $UserEmail `
                   -Path "OU=Users,DC=dinoland,DC=lan" `
                   -AccountPassword (ConvertTo-SecureString $UserPassword -AsPlainText -Force) `
                   -Enabled $true

        Write-Output "User created: $UserLogin ($UserLastName $UserFirstName)"
    }
}

# Import the Active Directory module
Import-Module ActiveDirectory

# Define the base path for the OUs
$BaseOUPath = "DC=dinoland,DC=lan"

# Create the main OU "CORE"
$CoreOUName = "CORE"
$CoreOUPath = "OU=$CoreOUName,$BaseOUPath"

if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $CoreOUName} -SearchBase $BaseOUPath)) {
    New-ADOrganizationalUnit -Name $CoreOUName -Path $BaseOUPath
    Write-Output "The OU '$CoreOUName' has been created in '$BaseOUPath'."
} else {
    Write-Output "The OU '$CoreOUName' already exists."
}

# Create the "HUMANS" OU under "CORE"
$HumansOUName = "HUMANS"
$HumansOUPath = "OU=$HumansOUName,$CoreOUPath"

if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $HumansOUName} -SearchBase $CoreOUPath)) {
    New-ADOrganizationalUnit -Name $HumansOUName -Path $CoreOUPath
    Write-Output "The OU '$HumansOUName' has been created in '$CoreOUPath'."
} else {
    Write-Output "The OU '$HumansOUName' already exists."
}

# Create the "USERS" and "ADMIN" OUs under "HUMANS"
$SubOUsToCreate = @("USERS", "ADMIN")

foreach ($SubOUName in $SubOUsToCreate) {
    $SubOUPath = "OU=$SubOUName,$HumansOUPath"

    if (-not (Get-ADOrganizationalUnit -Filter {Name -eq $SubOUName} -SearchBase $HumansOUPath)) {
        New-ADOrganizationalUnit -Name $SubOUName -Path $HumansOUPath
        Write-Output "The OU '$SubOUName' has been created in '$HumansOUPath'."
    } else {
        Write-Output "The OU '$SubOUName' already exists."
    }
}


# Define the users to be created
$Users = @(
    @{
        FirstName = "Alice"
        LastName = "Dupont"
        Login = "a.dupont"
        Email = "a.dupont@dinoland.lan"
        Password = "Azerty1234$"
    },
    @{
        FirstName = "Bob"
        LastName = "Martin"
        Login = "b.martin"
        Email = "b.martin@dinoland.lan"
        Password = "Azerty1234$"
    }
)

# Add users to the "Technicians" OU
foreach ($User in $Users) {
    $UserLastName = $User.LastName
    $UserFirstName = $User.FirstName
    $UserLogin = $User.Login
    $UserEmail = $User.Email
    $UserPassword = $User.Password

    # Check if the user exists in AD
    if (-not (Get-ADUser -Filter {SamAccountName -eq $UserLogin})) {
        New-ADUser -Name "$UserLastName $UserFirstName" `
                   -DisplayName "$UserLastName $UserFirstName" `
                   -GivenName $UserFirstName `
                   -Surname $UserLastName `
                   -SamAccountName $UserLogin `
                   -UserPrincipalName "$UserEmail" `
                   -EmailAddress $UserEmail `
                   -Path "OU=$OUName,$OUPath" `
                   -AccountPassword (ConvertTo-SecureString $UserPassword -AsPlainText -Force) `
                   -Enabled $true

        Write-Output "User created: $UserLogin ($UserLastName $UserFirstName)"
    } else {
        Write-Warning "The user $UserLogin already exists in AD."
    }
}
