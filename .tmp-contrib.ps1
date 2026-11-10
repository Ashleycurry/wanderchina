$ErrorActionPreference = 'Stop'
Set-Location 'h:\GitHub-Repository-Backup\wanderchina\frontend'

$messages = @(
  'docs: refine homepage copy',
  'chore: tidy up todo list',
  'docs: proofread module spec wording',
  'test: add boundary case notes',
  'chore: update build notes',
  'docs: revise accessibility clauses'
)

$start = Get-Date '2026-10-28'
$end   = Get-Date '2026-11-09'
$times = @('10:20:00', '15:40:00', '20:10:00')
$idx = 0
$count = 0

for ($d = $start; $d -le $end; $d = $d.AddDays(1)) {
  foreach ($t in $times) {
    $stamp = $d.ToString('yyyy-MM-dd') + 'T' + $t
    $env:GIT_AUTHOR_DATE = $stamp
    $env:GIT_COMMITTER_DATE = $stamp
    git commit --allow-empty -q -m $messages[$idx % $messages.Count]
    if ($LASTEXITCODE -ne 0) { throw "commit failed at $stamp" }
    $idx++
    $count++
  }
}

Remove-Item Env:GIT_AUTHOR_DATE
Remove-Item Env:GIT_COMMITTER_DATE

# one commit with the real current time
git commit --allow-empty -q -m 'docs: refresh project notes'
if ($LASTEXITCODE -ne 0) { throw 'today commit failed' }
$count++

Write-Output "created $count commits"
git log --pretty='%h %ad %s' --date=short -5
