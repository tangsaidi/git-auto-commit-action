#!/bin/sh
set -eu

# Set up .netrc file with GitHub credentials
git_setup ( ) {
  cat <<- EOF > $HOME/.netrc
        machine github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN

        machine api.github.com
        login $GITHUB_ACTOR
        password $GITHUB_TOKEN
EOF
    chmod 600 $HOME/.netrc

    git config --global user.email "actions@github.com"
    git config --global user.name "GitHub Actions"
}


# This section only runs if there have been file changes
echo "Checking for uncommitted changes in the git working tree."
if ! git diff --quiet
then
    git_setup

    : ${PUSH_BRANCH:=`echo "$GITHUB_HEAD_REF" | awk -F / '{ print $3 }' `}

    git switch -c $PUSH_BRANCH

    # Switch to branch from current Workflow run
    git checkout $PUSH_BRANCH

    git add .

    git commit -m "$INPUT_COMMIT_MESSAGE" --author="$INPUT_COMMIT_AUTHOR_NAME <$INPUT_COMMIT_AUTHOR_EMAIL>"

    git push --set-upstream origin $PUSH_BRANCH
else
    echo "Working tree clean. Nothing to commit."
fi
