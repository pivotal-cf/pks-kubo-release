create_pr_payload() {
  title="bump $1 to $2"
  body="This is an auto generated PR created for $1 upgrade to $2"
  echo '{"title":"'"$title"'","body":"'"$body"'","head":"'"$3"'","base":"'"$4"'"}'
}

setup_git_config() {
  git config --global user.email "pks-bosh-lifecycle+cibot@pivotal.io"
  git config --global user.name "PKS BOSH LIFECYCLE CI BOT"
}

get_branch_name() {
  echo "bump-$1-$2"
}

create_branch() {
  local component tag
  component="$1"
  tag="$2"

  branch_name=$(get_branch_name "$component" "$tag")
  git checkout -b "$branch_name"
}

git_current_branch () {
	local ref
	ref=$(command git symbolic-ref --quiet HEAD 2> /dev/null)
	local ret=$?
	if [[ $ret != 0 ]]
	then
		[[ $ret == 128 ]] && return
		ref=$(command git rev-parse --short HEAD 2> /dev/null)  || return
	fi
	echo "${ref#refs/heads/}"
}

commit() {
  local component tag
  component="$1"
  tag="$2"

  git add .
  git commit -m "Bump $component to $tag"
}

setup_ssh() {
  mkdir -p ~/.ssh
  cat > ~/.ssh/config <<EOF
StrictHostKeyChecking no
LogLevel quiet
EOF
  chmod 0600 ~/.ssh/config

  cat > ~/.ssh/id_rsa <<EOF
${GIT_SSH_KEY}
EOF
  chmod 0600 ~/.ssh/id_rsa
  eval "$(ssh-agent)" >/dev/null 2>&1
  trap "kill $SSH_AGENT_PID" 0
  ssh-add ~/.ssh/id_rsa
}

push_current_branch() {
  git push origin "$(git_current_branch)"
}

create_pr_through_curl() {
  local component tag branch_name base_branch repo
  component="$1"
  tag="$2"
  base_branch="$3"
  repo="$4"

  branch_name=$(get_branch_name "$component" "$tag")

  payload=$(create_pr_payload "$component" "$tag" "$branch_name" "$base_branch")
  curl -u "pks-bosh-lifecycle:${GIT_USER_TOKEN}" -H "Content-Type: application/json" -X POST -d "$payload" "https://api.github.com/repos/pivotal-cf/${repo}/pulls" --fail
}
