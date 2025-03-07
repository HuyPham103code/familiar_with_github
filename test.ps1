# get_commit_message.ps1
Write-Output "Checking latest commit message..."

# Điều hướng tới thư mục chứa repo
Set-Location "D:\nam_3\github\familiar_with_github\familiar_with_github"

Write-Output "Updating PATH for Azure CLI..."

$Env:Path += ";C:\Program Files (x86)\Microsoft SDKs\Azure\CLI2\wbin"

Write-Output "Current PATH after update: $Env:Path"

# Kiểm tra Git có hoạt động không
git --version
git status

# Lấy commit message gần nhất
$COMMIT_MESSAGE = git log -1 --pretty=%B
Write-Output "Latest commit message: $COMMIT_MESSAGE"

Write-Output "Checking latest commit message..."

# Kiểm tra Git có hoạt động không
git --version
git status

# Lấy commit message gần nhất
$COMMIT_MESSAGE = git log -1 --pretty=%B
Write-Output "Latest commit message: $COMMIT_MESSAGE"
$ORG_URL = "https://dev.azure.com/silversea21"
# Tìm Task ID trong format [Task#....]
$TASK_ID_MATCH = $COMMIT_MESSAGE | Select-String -Pattern "\[Task#(\d+)\]" -AllMatches
Write-Output "Match result: $($TASK_ID_MATCH.Matches | ForEach-Object { $_.Value })"

if ($TASK_ID_MATCH.Matches.Count -gt 0) {
    $TASK_ID = $TASK_ID_MATCH.Matches.Groups[1].Value
    Write-Output "Found Task ID: $TASK_ID"

    # Gửi comment đến Task ID trong Azure DevOps
    Write-Output "Sending commit to Task ID $TASK_ID..."
    az devops invoke --area workitems --resource workItems `
    --route-parameters id=$TASK_ID `
    --http-method PATCH `
    --in-file comment.json `
    --organization $ORG_URL

    if ($LASTEXITCODE -eq 0) {
        Write-Output "Comment successfully!"
    } else {
        Write-Output "Failed to comment on Task ID $TASK_ID."
        exit 1
    }
} else {
    Write-Output "No Task ID found in commit message."
}
