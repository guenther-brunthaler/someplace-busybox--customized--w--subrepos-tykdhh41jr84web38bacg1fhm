#! /bin/sh

# v2024.29
set -e
trap 'test $? = 0 || echo "\"$0\" failed!" >& 2' 0

me=$0
case $0 in
	/*) ;;
	*) me=$PWD/$me
esac
me=`dirname -- "$me"`
cd -- "$me"

while getopts r opt
do
	case $opt in
		r)
			for f in \
				workdir/configs workdir/busybox workdir
			do
				test ! -L $f && continue
				echo "Removing $f" >& 2
				rm $f
			done
			git submodule deinit --all --force
			find submodules -depth -exec rmdir {} +
			exit
			;;
		*) false || exit
	esac
done
shift `expr $OPTIND - 1 || :`

if test ! -d submodules
then
	git submodule update --init
fi

git_ignore() {
	(
		ignore=`basename $1`
		ignorex=/$ignore
		cd -P `dirname $1`
		test -L $ignore
		f=.git
		if test -f $f
		then
			read key f < $f
			test "$key" = gitdir:
			test -d "$f"
		else
			test -d $d
		fi
		f=$f/info/exclude
		test -f "$f"
		if grep -q "$ignorex" "$f"
		then
			:
		else
			echo "Ignoring '$ignore' in $f" >& 2
			echo "$ignorex" >> "$f"
			LC_COLLATE=C sort -o "$f" -u "$f"
		fi
	)
}

if test ! -L workdir
then 
	echo "Creating workdir" >& 2
	ln -s submodules/customization workdir
	git_ignore workdir
fi
cd workdir

if test ! -L configs
then
	echo "Creating workdir/configs" >& 2
	ln -s ../configs
	git_ignore configs
fi

if test ! -L busybox
then
	echo "Creating workdir/busybox" >& 2
	ln -s ../busybox
	git_ignore busybox
fi
