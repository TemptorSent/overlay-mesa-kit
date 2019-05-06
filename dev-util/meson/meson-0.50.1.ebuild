# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6
PYTHON_COMPAT=( python3_{5,6,7} )

if [[ ${PV} = *9999* ]]; then
	EGIT_REPO_URI="https://github.com/mesonbuild/meson"
	inherit git-r3
else
	SRC_URI="mirror://pypi/${PN:0:1}/${PN}/${P}.tar.gz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~m68k ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x64-macos ~x64-solaris"
fi

inherit distutils-r1

DESCRIPTION="Open source build system"
HOMEPAGE="http://mesonbuild.com/"

LICENSE="Apache-2.0"
SLOT="0"
IUSE="vim-syntax bash-completion zsh-completion"
RESTRICT="test"

RDEPEND=">=dev-util/ninja-1.5"
DEPEND="
	${RDEPEND}
	dev-python/setuptools[${PYTHON_USEDEP}]
"

python_test() {
	ninja test || die
}

python_install_all() {
	distutils-r1_python_install_all

	if use vim-syntax ; then
		insinto /usr/share/vim/vimfiles
		doins -r data/syntax-highlighting/vim/{ftdetect,ftplugin,indent,syntax}
	fi

	if use bash-completion ; then
		insinto /usr/share/bash-completion/completions
		doins data/shell-completions/bash/meson
	fi

	if use zsh-completion ; then
		insinto /usr/share/zsh/site-functions
		doins data/shell-completions/zsh/_meson
	fi
}
