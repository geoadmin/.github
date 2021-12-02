#!/bin/bash

repository=(
    "test-milestone-workflow"
    # "service-wms-bod"
    # "wms-bgdi"
    # "wms-mapfile_include"
    # "mf-chsdi3"
    # "service-sphinxsearch"
)

branch_name=norn-update-workflow

echo "Check if all repos are clean and if we can create new branch from them..."
for repo in "${repository[@]}"
do
    echo "Entering repositories/${repo}"
    pushd ~/repositories/"${repo}" || exit
    git checkout master || exit
    git pull || exit
    local_changes=$(git status --porcelain)
    if [ -n "${local_changes}" ]; then
        echo "${local_changes}"
        echo "local changes on develop, exiting..."
        exit
    fi
    git checkout -b ${branch_name} || exit
    echo "--------------------------------------------------------------------"
done

echo "Done"
echo "------------------------------------------------------------------------"
echo -n "All repos are clean do you want to continue [Y/n] ? "
read -r answer
case "$answer" in
    "Y" | "y" | "") echo "Continue" ;;
    *) echo "Stop"; exit 0 ;;
esac

read -r -d '' MSG << EOM
Added new Milestone Workflows
EOM

for repo in "${repository[@]}"
do
    echo "Entering repositories/${repo}"
    pushd ~/repositories/"${repo}" || exit
    git checkout ${branch_name} || exit
    rm -f .github/workflows/*
    cp ~/repositories/geoadmin.github/workflow-templates/milestone-version.yml .github/workflows/ || exit
    cp ~/repositories/geoadmin.github/workflow-templates/pr-auto-milestone.yml .github/workflows/ || exit
    cp ~/repositories/geoadmin.github/workflow-templates/create-milestone.yml .github/workflows/ || exit
    git add --all .github/workflows/ || exit
    git commit -m "$MSG" || exit
    git push -f origin HEAD || exit
    popd || exit
    echo "--------------------------------------------------------------------"
done
