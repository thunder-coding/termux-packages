TERMUX_PKG_HOMEPAGE=https://flacon.github.io/
TERMUX_PKG_DESCRIPTION="Extracts individual tracks from one big audio file and saves them as separate audio files"
TERMUX_PKG_LICENSE="LGPL-2.1"
TERMUX_PKG_MAINTAINER="@termux"
TERMUX_PKG_VERSION=11.0.0
TERMUX_PKG_SRCURL=https://github.com/flacon/flacon/archive/v${TERMUX_PKG_VERSION}.tar.gz
TERMUX_PKG_SHA256=55fdf6641ee1d37c8088da1af0e1b62ad7d0f7b97d05e88932d813804128177f
TERMUX_PKG_AUTO_UPDATE=true
TERMUX_PKG_DEPENDS="libc++, libuchardet, qt5-qtbase, taglib"
TERMUX_PKG_BUILD_DEPENDS="qt5-qtbase-cross-tools, qt5-qttools-cross-tools"
