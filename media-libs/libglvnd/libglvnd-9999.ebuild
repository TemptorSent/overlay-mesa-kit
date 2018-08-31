# Copyright 1999-2018 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=6


PYTHON_COMPAT=( python2_7 )



inherit autotools multilib-minimal python-any-r1

DESCRIPTION="The GL Vendor-Neutral Dispatch library"
HOMEPAGE="https://github.com/NVIDIA/libglvnd"
EGIT_REPO_URI="${HOMEPAGE}.git"
SRC_URI="${HOMEPAGE}/releases/download/v${PV}/${P}.tar.gz"

PV_L=${PV##*.}
if [ ${PV_L} -gt 9000 ] ; then
	inherit git-r3
	if [ ${PV_L} -gt 19000101 ] ; then
		CD_YYYY="${PV_L%????}"
		CD_DD="${PV_L#??????}"
		CD_MM="${PV_L#${CD_YYYY}}"
		CD_MM="${CD_MM%${CD_DD}}"

		EGIT_COMMIT_DATE="${CD_YYYY}-${CD_MM}-${CD_DD}"
	fi
	SRC_URI=""
else
	KEYWORDS="*"
	EGIT_REPO_URI=""
fi

LICENSE="MIT"
SLOT="0"
IUSE="+asm +glx gles egl"

RDEPEND="
	x11-libs/libX11[${MULTILIB_USEDEP}]
	x11-proto/glproto
	x11-libs/libXext
"

DEPEND="
	!media-libs/mesa[-glvnd(-)]
	${PYTHON_DEPS}
	${RDEPEND}
"

src_unpack() {
	default
	[ -n "${EGIT_REPO_URI}" ] && git-r3_src_unpack
}

src_prepare() {
	default
	eautoreconf
}

multilib_src_configure() {
	ECONF_SOURCE=${S} econf $(use_enable asm) $(use_enable glx) $(use_enable gles) $(use_enable egl)
}

multilib_src_install() {
	default
	# libglvnd should replace existing Mesa gl if present
	PKGCONF_PATH="${ED}/usr/$(get_libdir)/pkgconfig"
	find "${ED}" -name '*.la' -delete || die
}
