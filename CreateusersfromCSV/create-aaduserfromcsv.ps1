$PasswordLength = 128

function New-TempPassword {
    Param([int]$length)
    $ascii=$NULL;
    
    For ($a=33;$a -le 126;$a++) {
        $ascii+=,[char][byte]$a
    }

    For ($loop=1; $loop -le $length; $loop++) {
        $TempPassword+=($ascii | GET-RANDOM)
    }
    return $TempPassword
}

# Connect to Microsoft Graph with user read/write permissions
Connect-MgGraph -Scopes User.ReadWrite.All

# Specify the path of the CSV file
$CSVFilePath = ".\users.csv"

# Import data from CSV file
$AADUsers = Import-Csv -Path $CSVFilePath

# Loop through each row containing user details in the CSV file
foreach ($User in $AADUsers) {
    
    $MailNickname = ""
    $UsageLocation = ""
    $TempPassword = ""

    $TempPassword = New-TempPassword -length $PasswordLength
    #Create password profile
    $PasswordProfile = @{
        Password                             = $TempPassword
        ForceChangePasswordNextSignIn        = $true
        ForceChangePasswordNextSignInWithMfa = $true
    }

    if (!($User.MailNickname)) {$MailNickname = $User.UserPrincipalName.split("@")[0]}else{$MailNickname = $User.MailNickname}
    if (!($User.UsageLocation)) {$Usagelocation = "US"} else {$Usagelocation = $user.UsageLocation}


    $UserParams = @{
        DisplayName       = $User.DisplayName
        GivenName         = $User.GivenName
        Surname           = $User.Surname
        UserPrincipalName = $User.UserPrincipalName
        Department        = $User.Department
        JobTitle          = $User.JobTitle
        BusinessPhones    = $User.OfficePhone
        Country           = "US"
        PasswordProfile   = $PasswordProfile
        AccountEnabled    = $true
        UsageLocation = $UsageLocation
        MailNickname = $MailNickname

    }

    write-host "Creating user " $User.DisplayName -ForegroundColor Yellow
    try {
        New-MgUser @UserParams -ErrorAction Stop
        Write-Host ("Successfully created the account for {0}" -f $User.DisplayName) -ForegroundColor Green
    }
    catch {
        Write-Host ("Failed to create the account for {0}. Error: {1}" -f $User.DisplayName, $_.Exception.Message) -ForegroundColor Red
    }

}

$Error | Out-File -FilePath .\"Create-AADUserFromCSV$(get-date -Format "MMddyy-HHmm")".txt
