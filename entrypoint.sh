#!/bin/bash

release_branch=${RELEASE_BRANCHES:-master}
with_v=${WITH_V:-true}
commit_message=${COMMIT_MESSAGE:-no_message}
current_branch=$(git rev-parse --abbrev-ref HEAD)
initial_version=${INITIAL_VERSION:-1.0.0}

# determine release type
release_type="beta"
IFS=',' read -ra branch <<< "$release_branch"
for b in "${branch[@]}"; do
    echo "On ${current_branch} branch"
    if [[ "${current_branch}" =~ $b ]]
				release_type="patch"
				if [[ $commit_message =~ "MAJOR" ]]
				then
						release_type="minor"
				fi
    then
        release_type="alpha"
		elif [[ "${current_branch}" =~ "release" ]]
		then
			if [[ $commit_message =~ "hotfix" ]]
			then
				release_type="rc"
			fi
    fi
done
echo "release_type=$release_type"

# fetch tags
git fetch --tags

tag=$(git for-each-ref --sort=-v:refname --count=1 --format '%(refname)' refs/tags/[0-9]*.[0-9]*.[0-9]* refs/tags/v[0-9]*.[0-9]*.[0-9]* | cut -d / -f 3-)
echo "previous_tag=$tag"

# get current commit hash for tag
tag_commit=$(git rev-list -n 1 $tag)
# get current commit hash
commit=$(git rev-parse HEAD)

if [ "$tag_commit" == "$commit" ]; then
    echo "No new commits since previous tag. Skipping..."
    echo ::set-output name=tag::$tag
    exit 0
fi

if [ -z "$tag" ]
then
    tag="$initial_version"
fi

tag="1.0.0"
new=""

is_prerel="false"
new=""
if [ ${release_type} != "major" ] && [ ${release_type} != "minor" ] && [ ${release_type} != "patch" ]
then
		is_prerel="true"
		echo "hi"
		if [[ ! "$tag" =~ "beta" ]] && [[ ! "$tag" =~ "alpha" ]] && [[ ! "$tag" =~ "rc" ]]
		then
				echo "hii"
				if [ ${release_type} == "beta" ]
				then
						new="${tag}-beta-1"
				elif [ ${release_type} == "alpha" ]
				then
						new="${tag}-alpha-1"
				fi
		else
				perel_version=$(semver get prerel $tag)
				echo $perel_version
				perel_version_num=$(echo "$perel_version" | sed 's/.*-//')
				echo $perel_version_num
				new_perel_version_num=`echo "$perel_version_num + 1" | bc`
				new="${tag%-*}-${new_perel_version_num}"
		fi
fi



case "$release_type" in
    *major* ) new=$(semver bump major $tag);;
    *minor* ) new=$(semver bump minor $tag);;
    *patch* ) new=$(semver bump patch $tag);;
		*patch* ) new=$(semver bump patch $tag);;
    * ) ;;
esac



echo $new