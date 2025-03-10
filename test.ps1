Write-Output "Checking latest commit message.."

# Kiểm tra Git có hoạt động không
git --version
git status

# Lấy commit message gần nhất
$COMMIT_MESSAGE = git log -1 --pretty=%B
Write-Output "Latest commit message: $COMMIT_MESSAGE"

$ORG_URL = "https://dev.azure.com/silversea21"

# Nội dung comment trực tiếp dưới dạng JSON
$commentJson = @(
    @{
        "op" = "add"
        "path" = "/fields/System.History"
        "value" = "Fixed bug for task $TASK_ID"
    }
) | ConvertTo-Json -Depth 2

# Tìm Task ID trong format [Task#....]
$TASK_ID_MATCH = $COMMIT_MESSAGE | Select-String -Pattern "\[Task#(\d+)\]" -AllMatches
Write-Output "Match result: $($TASK_ID_MATCH.Matches | ForEach-Object { $_.Value })"

if ($TASK_ID_MATCH.Matches.Count -gt 0) {
    $TASK_ID = $TASK_ID_MATCH.Matches.Groups[1].Value
    Write-Output "Found Task ID: $TASK_ID"

    # Đăng nhập vào Azure DevOps bằng PAT
    # $PAT = "8Awke4Xri2RmMEAJjrdEJNUbh8sFHCcLV81auEcR5vJ1dy7wvH3MJQQJ99BCACAAAAAnzwFcAAASAZDO1sou"
    # az devops login --organization $ORG_URL <<< $PAT
    # Đăng nhập vào Azure DevOps bằng PAT
    $Env:AZURE_DEVOPS_EXT_PAT = "8Awke4Xri2RmMEAJjrdEJNUbh8sFHCcLV81auEcR5vJ1dy7wvH3MJQQJ99BCACAAAAAnzwFcAAASAZDO1sou"

    Write-Output "check1"
    


    # Tạo nội dung comment trong JSON payload
    $commentJson = @(
        @{
            "op" = "add"
            "path" = "/fields/System.History"
            "value" = "Fixed bug for task $TASK_ID"
        }
    ) | ConvertTo-Json -Depth 2

    # Sử dụng trực tiếp az boards work-item update với --fields
    az boards work-item update `
        --id $TASK_ID `
        --fields "System.History=Fixed bug for task $TASK_ID" `
        --organization https://dev.azure.com/silversea21



    if ($LASTEXITCODE -eq 0) {
        Write-Output "Comment successfully!"
    } else {
        Write-Output "Failed to comment on Task ID $TASK_ID."
        exit 1
    }
} else {
    Write-Output "No Task ID found in commit message."
}