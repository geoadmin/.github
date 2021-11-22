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
    git status --porcelain && echo "local changes on develop, exiting..."; exit
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
Renamed the workflow templates

The main workflow file parameter `name` is used in the github PR check
section as prefix to display every actions. In order to keep this display
a bit cleaner and short we use a shorter name.

e.g changed such display:

`PR New SemVer Release Auto Title / pr-edit / Set PR title (pull_request)`
`PR New SemVer Release Auto Title / pr-edit / Set PR label
(pull_request)`

to

`on-pr / pr-edit / Set PR title (pull_request)`
`on-pr / pr-edit / Set PR label (pull_request)`
EOM

for repo in "${repository[@]}"
do
    echo "Entering repositories/${repo}"
    pushd ~/repositories/"${repo}" || exit
    git checkout ${branch_name} || exit
    cp ~/repositories/geoadmin.github/workflow-templates/semver.yml .github/workflows/ || exit
    cp ~/repositories/geoadmin.github/workflow-templates/pr-auto-semver.yml .github/workflows/ || exit
    git add --all .github/workflows/ || exit
    git commit -m "$MSG" || exit
    git push -f origin HEAD || exit
    popd || exit
    echo "--------------------------------------------------------------------"
done
