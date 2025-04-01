$CSVFile = "C:\AD_users.csv"
$CSVData = Import-Csv -Path $CSVFile -Delimiter ";" -Encoding UTF8

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

# Process the CSV data to create users
$UserCount = $CSVData.Count

for ($i = 0; $i -lt $UserCount; $i++) {
    $User = $CSVData[$i]
    $UserFirstName = $User.first_name
    $UserLastName = $User.last_name
    $UserLogin = ($UserFirstName).Substring(0, 1) + "." + $UserLastName
    $UserEmail = "$UserLogin@dinoland.lan"
    $UserPassword = $User.password

    # Determine the OU path based on user index
    if ($i -lt 200) {
        $TargetOU = "OU=USERS,$HumansOUPath"
    } else {
        $TargetOU = "OU=ADMIN,$HumansOUPath"
    }

    # Check if the user exists in AD
    if (-not (Get-ADUser -Filter {SamAccountName -eq $UserLogin})) {
        New-ADUser -Name "$UserLastName $UserFirstName" `
                   -DisplayName "$UserLastName $UserFirstName" `
                   -GivenName $UserFirstName `
                   -Surname $UserLastName `
                   -SamAccountName $UserLogin `
                   -UserPrincipalName "$UserLogin@dinoland.lan" `
                   -EmailAddress $UserEmail `
                   -Path $TargetOU `
                   -AccountPassword (ConvertTo-SecureString $UserPassword -AsPlainText -Force) `
                   -Enabled $true

        Write-Output "User created: $UserLogin ($UserLastName $UserFirstName) in $TargetOU"
    } else {
        Write-Warning "The login $UserLogin already exists in AD."
    }
}
