function Get-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]
        $UnifiedAuditLogIngestionEnabled = 'Disabled',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )
    Test-SecurityAndComplianceCenterConnection -GlobalAdminAccount $GlobalAdminAccount

    $nullReturn = @{
        UnifiedAuditLogIngestionEnabled = 'Disabled'
    }

    try
    {
        Write-Verbose -Message 'Getting AdminAuditLogConfig'
        $GetResults = Get-AdminAuditLogConfig
        if ($GetResults.UnifiedAuditLogIngestionEnabled)
        {
            $UnifiedAuditLogIngestionEnabledReturnValue = 'Enabled'
        }
        else
        {
            $UnifiedAuditLogIngestionEnabledReturnValue = 'Disabled'
        }

        return @{
            UnifiedAuditLogIngestionEnabled = $UnifiedAuditLogIngestionEnabledReturnValue
        }
    }
    catch
    {
        Write-Verbose 'Unable to determine Unified Audit Log Ingestion State.'
        return $nullReturn
    }
}

function Set-TargetResource
{
    [CmdletBinding()]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]
        $UnifiedAuditLogIngestionEnabled = 'Disabled',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )
    Write-Verbose -Message 'Setting AdminAuditLogConfig'
    Test-SecurityAndComplianceCenterConnection -GlobalAdminAccount $GlobalAdminAccount

    if ($UnifiedAuditLogIngestionEnabled -eq 'Enabled')
    {
        Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $true
    }
    else
    {
        Set-AdminAuditLogConfig -UnifiedAuditLogIngestionEnabled $false
    }
}

function Test-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]
        $UnifiedAuditLogIngestionEnabled = 'Disabled',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )
    Write-Verbose -Message 'Testing AdminAuditLogConfig'
    $CurrentValues = Get-TargetResource @PSBoundParameters
    return Test-Office365DSCParameterState -CurrentValues $CurrentValues `
        -DesiredValues $PSBoundParameters `
        -ValuesToCheck @('UnifiedAuditLogIngestionEnabled')
}

function Export-TargetResource
{
    [CmdletBinding()]
    [OutputType([System.String])]
    param
    (
        [Parameter(Mandatory = $true)]
        [ValidateSet('Yes')]
        [String]
        $IsSingleInstance,

        [Parameter()]
        [ValidateSet('Enabled', 'Disabled')]
        [System.String]
        $UnifiedAuditLogIngestionEnabled = 'Disabled',

        [Parameter(Mandatory = $true)]
        [System.Management.Automation.PSCredential]
        $GlobalAdminAccount
    )
    $IsSingleInstance = 'Yes'
    $result = Get-TargetResource @PSBoundParameters
    $result.GlobalAdminAccount = Resolve-Credentials -UserName $GlobalAdminAccount.UserName
    $content = "        AdminAuditLogConfig " + (New-GUID).ToString() + "`r`n"
    $content += "        {`r`n"
    $currentDSCBlock = Get-DSCBlock -Params $result -ModulePath $PSScriptRoot
    $content += Convert-DSCStringParamToVariable -DSCBlock $currentDSCBlock -ParameterName 'GlobalAdminAccount'
    $content += "        }`r`n"
    return $content
}

Export-ModuleMember -Function *-TargetResource