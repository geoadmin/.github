#!/bin/bash

repository=(
    "test-semver-workflow"
    "service-qrcode"
    "service-stac"
    "service-icons"
    "service-shortlink"
    "service-wmts"
    "service-feedback"
    "service-kml"
    "service-bod"
    "service-atom-inspire"
    "service-diemo"
    "web-mapviewer"
    "config-vt-gl-styles"
)

branch_name=norn-update-workflow

echo "Check if all repos are clean and if we can create new branch from them..."
for repo in "${repository[@]}"
do
    echo "Entering repositories/${repo}"
    pushd ~/repositories/"${repo}" || exit
    git checkout develop || exit
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
Consolidate PR workflows

Now the PR set Title and PR labeler are inside the same workflow. This speed up
a little bit the execution but moreover it simplify the maintenance of the workflows.

Also added proper job names that are displayed inside the PR.
EOM

for repo in "${repository[@]}"
do
    echo "Entering repositories/${repo}"
    pushd ~/repositories/"${repo}" || exit
    git checkout ${branch_name} || exit
    # rm -f .github/workflows/*
    cp ~/repositories/geoadmin.github/workflow-templates/semver.yml .github/workflows/ || exit
    cp ~/repositories/geoadmin.github/workflow-templates/pr-auto-semver.yml .github/workflows/ || exit
    git add --all .github/workflows/ || exit
    git commit -m "$MSG" || exit
    git push -f origin HEAD || exit
    popd || exit
    echo "--------------------------------------------------------------------"
done
