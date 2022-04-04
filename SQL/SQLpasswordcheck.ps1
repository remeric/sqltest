#variables
# $databases = Get-AzSqlDatabase -ServerName $$Env:SQL_SERVER -ResourceGroupName $rgname | Select-Object DatabaseName
$dbvariables = Import-Csv .\DbEnvVariables.csv

#Check if SQL server is accepting connections
$sqlconnection = new-object system.net.sockets.tcpclient -argumentlist $Env:SQL_SERVER, 1433

Write-Output "test output"
Write-Error "test error"

If ($sqlconnection.Connected -eq "True" ) {
    Write-Output "Connection to SQL is working"
}
Else {
    Write-Error "Cannot connect to SQL server, check your network connections between AKS And SQL and then re-run the job"
}

#Check if you can login to server
Try {
    $connectionString = 'Data Source={0};User ID={1};Password={2}' -f $Env:SQL_SERVER,$Env:SQL_ADMIN_LOGIN,$Env:SQL_ADMIN_PASSWORD
    $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
    $sqlConnection.Open()
}
Catch {
    Write-Error "Could not connect to SQL server, check the username and password and then re-run the job"
}
Finally {
    Write-Information "Successfully logged into SQL Server"
    $sqlConnection.Close()
}

#Check if databases can be connected to
foreach ($database in $databases) {
    if ($database.DatabaseName -ne "master") {
        try {
            $vars = $dbvariables | Where-Object {$_.Dbname -eq "$database.DatabaseName"}
            $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $Env:SQL_SERVER,$database.DatabaseName,$vars.Username,$vars.password
            $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
            $sqlConnection.Open()
        }
        catch {
            Write-Error "Could not login to Database name '$database.DatabaseName', verify username and password"
        }
        Finally {
            $sqlConnection.Close()
        }
    
    }
}

#Check if databases can be connected to
# foreach ($database in $dbvariables) {
#     if ($database.DatabaseName -ne "master") {
#         $error.clear()
#         try { 
#             $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $Env:SQL_SERVER,$database.DatabaseName,$Env:SQL_ADMIN_LOGIN,$Env:SQL_ADMIN_PASSWORD 
#             $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
#             $sqlConnection.Open()
#             $sqlConnection.Close()
#         }
#         catch { "$database.DatabaseName does not exist, if this project does not require then ignore this message, else check your SQL init" }
#     if (!$error) {
#         try {
#             $vars = $dbvariables | Where-Object {$_.Dbname -eq "$database.DatabaseName"}
#             $connectionString = 'Data Source={0};database={1};User ID={2};Password={3}' -f $Env:SQL_SERVER,$database.DatabaseName,$vars.Username,$vars.password
#             $sqlConnection = New-Object System.Data.SqlClient.SqlConnection $connectionString
#             $sqlConnection.Open()
#         }
#         catch {
#             Write-Error "Could not login to Database name '$database.DatabaseName', verify username and password"
#         }
#         Finally {
#             $sqlConnection.Close()
#         }
#     }
    
#     }
# }