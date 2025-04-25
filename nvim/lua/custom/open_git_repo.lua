local function get_https_url()
  local handle = io.popen 'git config --get remote.origin.url'
  local result = handle:read '*a'
  handle:close()

  result = result:gsub('%s+', '') -- trim newline/spaces

  -- Convert SSH to HTTPS
  if result:match '^git@github.com:' then
    return result:gsub('^git@github.com:', 'https://github.com/'):gsub('%.git$', '')
  elseif result:match '^git@gitlab.com:' then
    return result:gsub('^git@gitlab.com:', 'https://gitlab.com/'):gsub('%.git$', '')
  elseif result:match '^git@bitbucket.org:' then
    return result:gsub('^git@bitbucket.org:', 'https://bitbucket.org/'):gsub('%.git$', '')
  end

  -- Return as-is if already HTTPS or unrecognized
  return result:gsub('%.git$', '')
end

local function get_open_command()
  if vim.fn.has 'mac' == 1 then
    return 'open'
  elseif vim.fn.has 'unix' == 1 then
    return 'xdg-open'
  elseif vim.fn.has 'win32' == 1 then
    return 'start'
  else
    print 'Tidak dapat mendeteksi OS untuk membuka URL.'
    return nil
  end
end

-- Open Git repository
local function open_git_repo()
  local url = get_https_url()
  local open_cmd = get_open_command()
  if url and open_cmd then
    os.execute(open_cmd .. ' ' .. url)
  end
end

-- Open pull request to main branch
local function open_pull_request_main()
  local url = get_https_url()
  local open_cmd = get_open_command()
  if not (url and open_cmd) then
    return
  end

  local pr_url
  if url:match 'github.com' then
    pr_url = url .. '/pulls?q=is%3Apr+is%3Aopen+base%3Amain'
  elseif url:match 'gitlab.com' then
    pr_url = url .. '/merge_requests?state=opened&target_branch=main'
  elseif url:match 'bitbucket.org' then
    pr_url = url .. '/pull-requests?state=OPEN&target=main'
  end

  if pr_url then
    os.execute(open_cmd .. ' ' .. pr_url)
  else
    print 'Platform Git tidak dikenali.'
  end
end

return {
  open_git_repo = open_git_repo,
  open_pull_request_main = open_pull_request_main,
}
