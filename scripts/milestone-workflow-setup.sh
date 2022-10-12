#!/bin/bash

repository=(
    #"test-milestone-workflow"
    "service-wms-bod"
    "wms-bgdi"
    "wms-mapfile_include"
    "mf-chsdi3"
    "service-sphinxsearch"
)

branch_name=norn-update-workflow


tmp_dir=$(mktemp -d -t workflows-setup-XXXX)

echo "Check if all repos are clean and if we can create new branch from them..."
for repo in "${repository[@]}"
do
    echo "Cloning and entering ${tmp_dir}/${repo}"
    pushd "${tmp_dir}" || exit
    git clone "git@github.com:geoadmin/${repo}.git" || exit
    pushd "${repo}" || exit
    git checkout master || exit
    git pull || exit
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
Setup requirements for milestone branch protection and auto deletion

See https://github.com/geoadmin/.github/pull/24
EOM

for repo in "${repository[@]}"
do
    echo "Entering ${tmp_dir}/${repo}"
    pushd "${tmp_dir}/${repo}" || exit
    git checkout ${branch_name} || exit
    rm -f .github/workflows/*
    mkdir -p .github/workflows/
    cp ~/repositories/geoadmin.github/workflow-templates/milestone-version.yml .github/workflows/ || exit
    cp ~/repositories/geoadmin.github/workflow-templates/pr-auto-milestone.yml .github/workflows/ || exit
    cp ~/repositories/geoadmin.github/workflow-templates/create-milestone.yml .github/workflows/ || exit
    if [[ "${repo}" == "service-sphinxsearch" ]]; then
        sed -i "s/AWS CodeBuild eu-central-1 (CODEBUILD_PROJECT_NAME)//" .github/workflows/create-milestone.yml
    else
        CODEBUILD_PROJECT_NAME=${repo}
        if [[ "${repo}" == "wms-bgdi" ]]; then
            CODEBUILD_PROJECT_NAME=service-${repo}
        fi
        sed -i "s/CODEBUILD_PROJECT_NAME/${CODEBUILD_PROJECT_NAME}/" .github/workflows/create-milestone.yml
    fi
    git add --all .github/workflows/ || exit
    git commit -m "$MSG" || exit
    git push -f origin HEAD || exit
    popd || exit
    echo "--------------------------------------------------------------------"
done

rm -rf "${tmp_dir}"
