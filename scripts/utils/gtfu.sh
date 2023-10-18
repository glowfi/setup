#!/bin/bash

gitMakeMine() {

	read -p "Enter new name: " new_name
	read -p "Enter new email: " new_email

	if [[ "$new_name" != "" && "$new_email" != "" ]]; then

		git filter-branch --env-filter "
if [ \"\$GIT_AUTHOR_EMAIL\" != \"$new_email\" ]; then
    export GIT_AUTHOR_NAME=\"$new_name\"
    export GIT_AUTHOR_EMAIL=\"$new_email\"
fi
if [ \"\$GIT_COMMITTER_EMAIL\" != \"$new_email\" ]; then
    export GIT_COMMITTER_NAME=\"$new_name\"
    export GIT_COMMITTER_EMAIL=\"$new_email\"
fi
        " --tag-name-filter cat -- --branches --tags
	fi

}

gitChangeCommitMessage() {

	commit_hash=""
	new_message=""

	commit_hash=$(git log --no-abbrev-commit --pretty=format:"%H %ad %s" --date=short --date-order | fzf --ansi --preview="git show {1} | delta --syntax-theme 'gruvbox-dark'" --preview-window="up:70%" | awk -F" " '{print $1}')

	if [[ "$commit_hash" != "" ]]; then

		read -p "Enter a new commit message: " new_message

		if [[ "$new_message" != "" ]]; then

			git filter-branch -f --msg-filter '
    if [ "$GIT_COMMIT" = "'"$commit_hash"'" ]; then
        echo "'"$new_message"'"
    else
        cat
    fi
            ' HEAD
		fi

	fi

}

gitCheckout() {
	commit_hash=$(git log --no-abbrev-commit --pretty=format:"%H %ad %s" --date=short --date-order | fzf --ansi --preview="git show {1} | delta --syntax-theme 'gruvbox-dark'" --preview-window="up:70%" | awk -F" " '{print $1}')
	git checkout "$commit_hash"
}

if [ -d "$PWD/.git" ]; then
	out=$(printf "1.Change all the name and email of the repository to a custom name and email \n2.Change Git Commit Message of a Particular Hash Commit\n3.Checkout to a particular commit" | fzf | awk -F"." '{print $1}')

	if [ "$out" = "1" ]; then
		gitMakeMine
	elif
		[ "$out" = "2" ]
	then
		gitChangeCommitMessage
	elif
		[ "$out" = "3" ]
	then
		gitCheckout
	fi
else
	echo "Not a Git Repository"
	exit 1
fi