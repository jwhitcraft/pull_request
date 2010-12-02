#!/bin/bash

# This work is licensed under a Creative Commons Attribution-ShareAlike 3.0 Unported License.
# http://creativecommons.org/licenses/by-sa/3.0/


REVISION=""

WD=`pwd`
BRANCH=master
PROJECT=MyProject.git

while getopts ":r:u:b:d:p:" optname "$@"
do
    case "$optname" in
    "r")
      REVISION="$OPTARG"
      ;;
    "u")
      PLUSER="$OPTARG"
      ;;
	"b")
	  BRANCH="$OPTARG"
	  ;;
	"d")
	  WD="$OPTARG"
	  ;;
    "p")
      PROJECT="$OPTARG"
      ;;
    "?")
      echo "Unknown option $OPTARG"
      ;;
    ":")
      echo "No argument value for option $OPTARG"
      ;;
    *)
    # Should not occur
      echo "Unknown error while processing options"
      ;;
    esac
done

shift $(($OPTIND - 1))

if [ "$PLUSER" == "" ]; then
    PLUSER=$1
fi


if [ "$PLUSER" == "" ]; then
    echo "No Pull Request Pull User Found";
fi


#move into the proper working dir
cd $WD

# make sure we are on the current branch
echo -n "Making Sure We Are on the Proper Branch..."
git co --quiet $BRANCH
echo "Done"

# pull in any change
echo -n "Updating the Branch..."
git pull --quiet origin $BRANCH
echo "Done"

# make sure the remote exists
GITREMOTE=`git remote | grep "${PLUSER}"`
if [ "${GITREMOTE}" == "" ]; then
    echo -n "Remote Doesn't Exist, Lets Create..."
    git remote add $PLUSER git@github.com:$PLUSER/$PROJECT
    echo "Done"
fi

echo -n "Fetching the Remote Branch To Merge..."
git fetch --quiet $PLUSER
echo "Done"

LASTREV=`git log --pretty="format:%ar" -n1 --author="$COMMITER"`

if [ "$REVISION" == "" ]; then
    echo -n "Merge in ${PLUSER}/${BRANCH}..."
    git merge --quiet $PLUSER/$BRANCH
    echo "Done"
else
    echo -n "Merge in Revision ${REVISION}..."
    git cherry-pick -x $REVISION
    echo "Done"
fi

echo -n "Pushing Branch To GitHub..."
git push --quiet origin $BRANCH
echo "Done"

echo ""
echo ""
echo "Commits New Commits From ${PLUSER}:"
git log --oneline --since="${LASTREV}" --author="$COMMITER"
