Write-Output "Checking latest commit message.."

# check git
git --version
git status

# Get the latest commit message and author
$COMMIT_MESSAGE = git log -1 --pretty=%B
$COMMIT_AUTHOR = git log -1 --pretty=format:'%an'
Write-Output "Latest commit message: $COMMIT_MESSAGE"
Write-Output "Commit author: $COMMIT_AUTHOR"

# Define the Azure DevOps organization URL
$ORG_URL = "https://dev.azure.com/silversea21"

# Extract Task ID in the format [Task#....]
$TASK_ID_MATCH = $COMMIT_MESSAGE | Select-String -Pattern "\[Task#(\d+)\]" -AllMatches
Write-Output "Match result: $($TASK_ID_MATCH.Matches | ForEach-Object { $_.Value })"

if ($TASK_ID_MATCH.Matches.Count -gt 0) {
    $TASK_ID = $TASK_ID_MATCH.Matches.Groups[1].Value
    Write-Output "Found Task ID: $TASK_ID"

    # Chỗ này có thể làm swith case để đổi PAT của người comment
    # Set the Azure DevOps Personal Access Token (PAT) for authentication
    if ($COMMIT_AUTHOR -eq "HuyPham"){
        $Env:AZURE_DEVOPS_EXT_PAT = "8Awke4Xri2RmMEAJjrdEJNUbh8sFHCcLV81auEcR5vJ1dy7wvH3MJQQJ99BCACAAAAAnzwFcAAASAZDO1sou"
        Write-Output "me"
    }
    else {
        $Env:AZURE_DEVOPS_EXT_PAT = "FYW5sNk1rHoqkzcK32wtc0bLTO2RWC5LcKSmerKLBMc3vGcmXwECJQQJ99BCACAAAAAnzwFcAAASAZDO29GW"
        Write-Output "not me"
    }

    Write-Output "Current PAT: $Env:AZURE_DEVOPS_EXT_PAT"
    
    # Prepare the comment content
    $COMMENT_TEXT = "Fixed bug for task $TASK_ID by $COMMIT_AUTHOR"

    # Update the work item with the comment
    az boards work-item update `
        --id $TASK_ID `
        --fields "System.History=$COMMENT_TEXT" `
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