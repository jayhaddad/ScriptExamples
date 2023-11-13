#
# Warning: Sample scripts in this repository are not supported under any Microsoft support program or service. 
# Scripts are provided AS IS without warranty of any kind. All warranties including, without limitation, any 
# implied warranties of merchantability or of fitness for a particular purpose. The entire risk arising out of 
# the use of sample scripts or configuration documentation remains with you. In no event shall Microsoft, its 
# authors, or anyone else involved in the creation, production, or delivery of this content be liable for any 
# damages whatsoever (including, without limitation, damages for loss of business profits, business interruption, 
# loss of business information, or other pecuniary loss) arising out of the use of or inability to use the sample
# scripts or documentation, even if Microsoft has been advised of the possibility of such damages.
#
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
