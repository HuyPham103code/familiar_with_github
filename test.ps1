# get_commit_message.ps1
Write-Output "Checking latest commit message..."

# Điều hướng tới thư mục chứa repo
Set-Location "D:\nam_3\github\familiar_with_github\familiar_with_github"

# Kiểm tra Git có hoạt động không
git --version
git status

# Lấy commit message gần nhất
$COMMIT_MESSAGE = git log -1 --pretty=%B
Write-Output "Latest commit message: $COMMIT_MESSAGE"

# Kiểm tra nếu commit là merge commit
if ($COMMIT_MESSAGE -match "Merge") {
    Write-Output "This is a merge commit. Proceeding with task ID extraction..."

    # Sử dụng Select-String để tìm Task ID trong format [Task#....]
    $TASK_ID_MATCH = $COMMIT_MESSAGE | Select-String -Pattern "\[Task#(\d+)\]" -AllMatches

    # Hiển thị kết quả $TASK_ID_MATCH để kiểm tra
    Write-Output "Match result: $($TASK_ID_MATCH.Matches | ForEach-Object { $_.Value })"

    # Nếu tìm thấy kết quả trong nhóm con (capture group)
    if ($TASK_ID_MATCH.Matches.Count -gt 0) {
        $TASK_ID = $TASK_ID_MATCH.Matches.Groups[1].Value
        Write-Output "Found Task ID: $TASK_ID"
    } else {
        Write-Output "No Task ID found in commit message."
    }
} else {
    Write-Output "Not a merge commit. Skipping task ID processing."
}
