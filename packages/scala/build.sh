TERMUX_PKG_HOMEPAGE=https://www.scala-lang.org
TERMUX_PKG_DESCRIPTION="Scala 3 compiler and standard library."
TERMUX_PKG_LICENSE="Apache-2.0"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION="3.4.1"
TERMUX_PKG_SRCURL=https://github.com/lampepfl/dotty/releases/download/$TERMUX_PKG_VERSION/scala3-$TERMUX_PKG_VERSION.tar.gz
TERMUX_PKG_SHA256=4063104c1998afc8dc6563ba5f33837f911d13bd99c0e5dc965ce56edcb0d777
TERMUX_PKG_DEPENDS="openjdk-17"
TERMUX_PKG_BUILD_IN_SRC=true
TERMUX_PKG_PLATFORM_INDEPENDENT=true
TERMUX_PKG_AUTO_UPDATE=true

termux_step_make_install() {
	rm -f ./bin/*.bat
	rm -rf $TERMUX_PREFIX/opt/scala
	mkdir -p $TERMUX_PREFIX/opt/scala
	cp -r ./* $TERMUX_PREFIX/opt/scala/
	for i in $TERMUX_PREFIX/opt/scala/bin/*; do
		if [ ! -f "$i" ]; then
			continue
		fi
		ln -sfr $i $TERMUX_PREFIX/bin/$(basename $i)
	done
}
