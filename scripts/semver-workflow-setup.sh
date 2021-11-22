#!/bin/bash

repository=(
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

echo "Check if all repos are clean and if we can create new branch from them..."
for repo in "${repository[@]}"
do
    echo "Entering repositories/${repo}"
    pushd ~/repositories/"${repo}" || exit
    git checkout develop || exit
    git pull || exit
done

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
    git checkout -f develop || exit
    git pull || exit
    git checkout -B norn-update-workflow || exit
    rm pr-semver-release-title.yml
    rm .github/workflows/*
    cp ~/repositories/geoadmin.github/workflow-templates/semver.yml .github/workflows/ || exit
    cp ~/repositories/geoadmin.github/workflow-templates/pr-auto-semver.yml .github/workflows/ || exit
    git add .github/workflows/*
    git commit -m "$MSG"
    git push origin HEAD
    popd || exit
done
