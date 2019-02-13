# Copyright 1999-2019 Gentoo Authors
# Distributed under the terms of the GNU General Public License v2

EAPI=6

PYTHON_COMPAT=( python3_4 python3_5 python3_6 python3_7 )

inherit llvm meson multilib-minimal pax-utils python-any-r1

OPENGL_DIR="xorg-x11"

MY_P="${P/_/-}"

DESCRIPTION="OpenGL-like graphic library for Linux"
HOMEPAGE="https://www.mesa3d.org/ https://mesa.freedesktop.org/"

if [[ ${PV} == 9999 ]]; then
	EGIT_REPO_URI="https://gitlab.freedesktop.org/mesa/mesa.git"
	EXPERIMENTAL="true"
	inherit git-r3
else
	SRC_URI="https://mesa.freedesktop.org/archive/${MY_P}.tar.xz"
	KEYWORDS="~alpha ~amd64 ~arm ~arm64 ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~amd64-fbsd ~x86-fbsd ~amd64-linux ~x86-linux ~sparc-solaris ~x64-solaris ~x86-solaris"
fi

LICENSE="MIT"
SLOT="0"
RESTRICT="
	!test? ( test )
"
# option_name option_name_option_list
mesa_option_array() {
	local myoptname="${1}"; shift
	local myopts=""

	local c
	for c in $@ ; do
		c="${c#+}"
		if use ${c} ; then myopts="${myopts:+${myopts},}${c#${myoptname}_}" ; fi
	done

	printf -- '-D%s=%s' "${myoptname#mesa_}" "${myopts}"
}

# option_name default_option option_name_option_list
mesa_option_combo() {
	local myoptname="${1}"; shift
	local mydefault="${1}"; shift
	local myopts=""

	local c
	for c in $@ ; do
		c="${c#+}"
		if use ${c} ; then myopts="${c#${myoptname}_}" ; fi
	done
	[ -z "${myopts}" ] && myopts="${mydefault}"

	printf -- '-D%s=%s' "${myoptname#mesa_}" "${myopts}"
}

# option_name default_option
mesa_option_autobool() {
	local myoptname="${1}"; shift
	local mydefault="${1}"; shift
	local myopts=""

	if use ${myoptname} ; then
		myopts="true"
	elif use ${myoptname}_auto ; then
		myopts="auto"
	else
		myopts="${mydefault:=false}"
	fi

	printf -- '-D%s=%s' "${myoptname#mesa_}" "${myopts}"
}

# option_name
mesa_option_boolean() {
	local myoptname="${1}"; shift
	local myopts=""

	if use ${myoptname} ; then myopts="true" ; else myopts="false" ; fi
	printf -- '-D%s=%s' "${myoptname#mesa_}" "${myopts}"
}

# option_name string
mesa_option_string() {
	local myoptname="${1}"; shift
	local myopts="$*"

	[ -z "${myopts}" ] && return

	printf -- '-D%s=%s' "${myoptname#mesa_}" "${myopts}"
}


# option( 'platforms', type : 'array', value : ['auto'],
# choices : [ '', 'auto', 'x11', 'wayland', 'drm', 'surfaceless', 'haiku', 'android', ],
# description : 'window systems to support. If this is set to `auto`, all platforms applicable will be enabled.' )
IUSE_MESA_PLATFORMS="mesa_platforms_auto +mesa_platforms_x11 +mesa_platforms_wayland +mesa_platforms_drm +mesa_platforms_surfaceless mesa_platforms_haiku mesa_platforms_android"
# option( 'dri3', type : 'combo', value : 'auto',
# choices : ['auto', 'true', 'false'],
# description : 'enable support for dri3' )
IUSE_MESA_DRI3="mesa_dri3_auto +mesa_dri3"

# option( 'dri-drivers', type : 'array', value : ['auto'],
# choices : ['', 'auto', 'i915', 'i965', 'r100', 'r200', 'nouveau', 'swrast'],
# description : 'List of dri drivers to build. If this is set to auto all drivers applicable to the target OS/architecture will be built' )
IUSE_MESA_DRI_DRIVERS="mesa_dri-drivers_auto mesa_dri-drivers_i915 mesa_dri-drivers_i965 mesa-dri_drivers_r100 mesa_dri-drivers_r200 mesa_dri-drivers_nouveau mesa_dri-drivers_swrast"

# option( 'gallium-drivers', type : 'array', value : ['auto'],
# choices : [ '', 'auto', 'kmsro', 'radeonsi', 'r300', 'r600', 'nouveau', 'freedreno', 'swrast', 'v3d', 'vc4', 'etnaviv', 'tegra', 'i915', 'svga', 'virgl', 'swr', ],
# description : 'List of gallium drivers to build. If this is set to auto all drivers applicable to the target OS/architecture will be built' )
IUSE_MESA_GALLIUM_DRIVERS="mesa_gallium-drivers_auto mesa_gallium-drivers_kmsro mesa_gallium-drivers_radeonsi mesa_gallium-drivers_r300 mesa_gallium-drivers_r600 mesa_gallium-drivers_nouveau mesa_gallium-drivers_freedreno +mesa_gallium-drivers_swrast mesa_gallium-drivers_v3d mesa_gallium-drivers_vc4 mesa_gallium-drivers_etnaviv mesa_gallium-drivers_tegra mesa_gallium-drivers_i915 mesa_gallium-drivers_svga mesa_gallium-drivers_virgl mesa_gallium-drivers_swr"

IUSE_MESA_GALLIUM_EXTRA_HUD="mesa_gallium-extra-hud"
IUSE_MESA_GALLIUM_VDPAU="+mesa_gallium-vdpau_auto mesa_gallium-vdpau"
IUSE_MESA_GALLIUM_XVMC="+mesa_gallium-xvmc_auto mesa_gallium-xvmc"
IUSE_MESA_GALLIUM_OMX="+mesa_gallium-omx_auto mesa_gallium-omx_bellagio mesa_gallium-omx_tizonia"
IUSE_MESA_GALLIUM_VA="+mesa_gallium-va_auto mesa_gallium-va"
IUSE_MESA_GALLIUM_XA="+mesa_gallium-xa_auto mesa_gallium-xa"
IUSE_MESA_GALLIUM_NINE="mesa_gallium-nine"
IUSE_MESA_GALLIUM_OPENCL="mesa_gallium-opencl_icd mesa_gallium-opencl_standalone"
IUSE_MESA_VULKAN_DRIVERS="mesa_vulkan-drivers_auto mesa_vulkan-drivers_amd mesa_vulkan-drivers_intel"
IUSE_MESA_SHADER_CACHE="+mesa_shader-cache"
IUSE_MESA_SHARED_GLAPI="+mesa_shared-glapi"
IUSE_MESA_GLES1="+mesa_gles1"
IUSE_MESA_GLES2="+mesa_gles2"
IUSE_MESA_OPENGL="+mesa_opengl"
IUSE_MESA_GBM="mesa_gbm_auto +mesa_gbm"
IUSE_MESA_GLX="mesa_glx_auto +mesa_glx_dri mesa_glx_xlib mesa_glx_gallium_xlib"
IUSE_MESA_EGL="mesa_egl_auto +mesa_egl"
IUSE_MESA_GLVND="+mesa_glvnd"
IUSE_MESA_ASM="+mesa_asm"
IUSE_MESA_GLX_READ_ONLY_TEXT="mesa_glx-read-only-text"
IUSE_MESA_LLVM="+mesa_llvm_auto mesa_llvm"
IUSE_MESA_SHARED_LLVM="+mesa_shared-llvm"
IUSE_MESA_VALGRIND="mesa_valgrind_auto mesa_valgrind"
IUSE_MESA_LIBUNWIND="mesa_libunwind_auto +mesa_libunwind"
IUSE_MESA_LMSENSORS="mesa_lmsensors_auto mesa_lmsensors"
IUSE_MESA_BUILD_TESTS="mesa_build-tests"
IUSE_MESA_SELINUX="mesa_selinux"
IUSE_MESA_OSMESA="mesa_osmesa_classic +mesa_osmesa_gallium"
# Note, must be 8 bits per channel for normal usage. Others require building non glx, non dri osmesa lib.
IUSE_MESA_OSMESA_BITS="+mesa_osmesa-bits_8 mesa_osmesa-bits_16 mesa_osmesa-bits_32"
IUSE_MESA_SWR_ARCHES="mesa_swr-arches_avx mesa_swr-arches_avx2 mesa_swr-arches_knl mesa_swr-arches_skx"
IUSE_MESA_TOOLS="mesa_tools_etnaviv mesa_tools_freedreno mesa_tools_glsl mesa_tools_intel mesa_tools_intel-ui mesa_tools_nir mesa_tools_nouveau mesa_tools_xvmc mesa_tools_all"
IUSE_MESA_POWER8="mesa_power8_auto mesa_power8"
IUSE_MESA_XLIB_LEASE="mesa_xlib-lease_auto +mesa_xlib-lease"
IUSE_MESA_GLX_DIRECT="+mesa_glx-direct"




IUSE="${IUSE_MESA_PLATFORMS} ${IUSE_MESA_DRI3} ${IUSE_MESA_DRI_DRIVERS} ${IUSE_MESA_GALLIUM_DRIVERS} ${IUSE_MESA_GALLIUM_EXTRA_HUD}
	${IUSE_MESA_GALLIUM_VDPAU} ${IUSE_MESA_GALLIUM_XVMC} ${IUSE_MESA_GALLIUM_OMX} ${IUSE_MESA_GALLIUM_VA} ${IUSE_MESA_GALLIUM_XA}
	${IUSE_MESA_GALLIUM_NINE} ${IUSE_MESA_GALLIUM_OPENCL} ${IUSE_MESA_VULKAN_DRIVERS} ${IUSE_MESA_SHADER_CACHE} ${IUSE_MESA_SHARED_GLAPI}
	${IUSE_MESA_GLES1} ${IUSE_MESA_GLES2} ${IUSE_MESA_OPENGL} ${IUSE_MESA_GBM} ${IUSE_MESA_GLX} ${IUSE_MESA_EGL} ${IUSE_MESA_GLVND}
	${IUSE_MESA_ASM} ${IUSE_MESA_GLX_READ_ONLY_TEXT} ${IUSE_MESA_LLVM} ${IUSE_MESA_SHARED_LLVM} ${IUSE_MESA_VALGRIND} ${IUSE_MESA_LIBUNWIND}
	${IUSE_MESA_LMSENSORS} ${IUSE_MESA_BUILD_TESTS} ${IUSE_MESA_SELINUX} ${IUSE_MESA_OSMESA} ${IUSE_MESA_OSMESA_BITS} ${IUSE_MESA_SWR_ARCHES}
	${IUSE_MESA_TOOLS} ${IUSE_MESA_POWER8} ${IUSE_MESA_XLIB_LEASE} ${IUSE_MESA_GLX_DIRECT}
	+classic d3d9 debug +dri3 +egl +gallium +gbm gles1 gles2 +llvm lm_sensors
	opencl osmesa pax_kernel pic selinux test unwind vaapi valgrind vdpau
	vulkan wayland xa xvmc"

REQUIRED_USE="
	mesa_gallium-nine? (
		|| ( mesa_dri3_auto mesa_dri3 )
		mesa_gallium-drivers_swrast
		|| ( mesa_gallium-drivers_r300 mesa_gallium-drivers_r600 mesa_gallium-drivers_radeonsi mesa_gallium-drivers_nouveau mesa_gallium-drivers_i915 mesa_gallium-drivers_svga )
	)
	mesa_gles1? ( || ( mesa_egl_auto mesa_egl ) )
	mesa_gles2? ( || ( mesa_egl_auto mesa_egl ) )

	mesa_vulkan-drivers_auto? ( || ( mesa_dri3_auto mesa_dri3 )  || ( mesa_llvm_auto mesa_llvm ) )
	mesa_vulkan-drivers_amd? ( || ( mesa_dri3_auto mesa_dri3 )  || ( mesa_llvm_auto mesa_llvm ) )
	mesa_vulkan-drivers_intel? ( || ( mesa_dri3_auto mesa_dri3 ) )
	mesa_gallium-drivers_radeonsi? ( || ( mesa_llvm_auto mesa_llvm ) )
	mesa_gallium-drivers_swr? ( || ( mesa_llvm_auto mesa_llvm ) )
	mesa_gallium-opencl_icd? ( || ( mesa_llvm_auto mesa_llvm ) )
	mesa_gallium-opencl_standalone? ( || ( mesa_llvm_auto mesa_llvm ) )

	mesa_platforms_wayland? ( || ( mesa_egl_auto mesa_egl )  || ( mesa_gbm_auto mesa_gbm ) )

	?? ( mesa_dri-drivers_i915 mesa_gallium-drivers_i915 )

	mesa_dri-drivers_swrast? ( !mesa_gallium-drivers_swrast !mesa_gallium-drivers_swr )
	mesa_gallium-drivers_kmsro? ( || ( mesa_gallium-drivers_vc4 mesa_gallium-drivers_etnaviv mesa_gallium-drivers_freedreno ) )
	mesa_gallium-drivers_tegra? ( mesa_gallium-drivers_nouveau )

	mesa_egl? (
		mesa_shared-glapi
		|| ( ${IUSE_MESA_PLATFORMS//+/} )
		mesa_gallium-drivers_radeonsi? ( || ( mesa_platforms_drm mesa_platforms_surfaceless ) )
		mesa_gallium-drivers_virgl? ( || ( mesa_platforms_drm mesa_platforms_surfaceless ) )
	)

	mesa_gallium-vdpau? ( mesa_platforms_x11 || ( mesa_gallium-drivers_r300 mesa_gallium-drivers_r600 mesa_gallium-drivers_radeonsi mesa_gallium-drivers_nouveau ) )
	mesa_gallium-xvmc? ( mesa_platforms_x11 || ( mesa_gallium-drivers_r600 mesa_gallium-drivers_nouveau ) )
	mesa_gallium-omx_bellagio? ( || ( mesa_platforms_x11 mesa_platforms_drm ) || ( mesa_gallium-drivers_r600 mesa_gallium-drivers_radeonsi mesa_gallium-drivers_nouveau ) )
	mesa_gallium-omx_tizonia? ( || ( mesa_egl_auto mesa_egl ) || ( mesa_platforms_x11 mesa_platforms_drm ) || ( mesa_gallium-drivers_r600 mesa_gallium-drivers_radeonsi mesa_gallium-drivers_nouveau ) )
	mesa_gallium-va? ( || ( mesa_platforms_x11 mesa_platforms_drm ) || ( mesa_gallium-drivers_r600 mesa_gallium-drivers_radeonsi mesa_gallium-drivers_nouveau ) )
	mesa_gallium-xa? ( || ( mesa_gallium-drivers_nouveau mesa_gallium-drivers_freedreno mesa_gallium-drivers_i915 mesa_gallium-drivers_svga ) )

	mesa_osmesa_classic? ( mesa_dri-drivers_swrast )
	mesa_osmesa_gallium? ( mesa_gallium-drivers_swrast )

"
# Make sure deps below meet these:
MESA_DEP_VDPAU_VERSION='>= 1.1'
MESA_DEP_XVMC_VERSION='>= 1.0.6'
MESA_DEP_OMX_TIZONIA_VERSION='>= 0.10.0'
MESA_DEP_VA_VERSION='>= 0.38.0' # This is API version, found in libva 1.6.0

MESA_DEP_DRM_AMDGPU_VER='2.4.97'
MESA_DEP_DRM_RADEOM_VER='2.4.71'
MESA_DEP_DRM_NOUVEAU_VER='2.4.66'
MESA_DEP_DRM_ETNAVIV_VER='2.4.89'
MESA_DEP_DRM_INTEL_VER='2.4.75'
MESA_DEP_DRM_VER='2.4.75'
MESA_DEP_DRM_VC4_VER='2.4.89'



LIBDRM_DEPSTRING=">=x11-libs/libdrm"
#LIBDRM_DEPSTRING=">=x11-libs/libdrm-2.4.97"
LIBDRM_RDEPEND="
	${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_VER}[${MULTILIB_USEDEP}]
	mesa_dri-drivers_i915? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_INTEL_VER}[video_cards_intel,${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_i915? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_INTEL_VER}[video_cards_intel,${MULTILIB_USEDEP}] )
	mesa_vulkan-drivers_amd? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_AMDGPU_VER}[video_cards_amdgpu,${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_radeonsi? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_AMDGPU_VER}[video_cards_amdgpu,video_cards_radeon,${MULTILIB_USEDEP}] )
	mesa_dri-drivers_r100? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_RADEON_VER}[video_cards_radeon,${MULTILIB_USEDEP}] )
	mesa_dri-drivers_r200? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_RADEON_VER}[video_cards_radeon,${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_r300? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_RADEON_VER}[video_cards_radeon,${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_r600? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_RADEON_VER}[video_cards_radeon,${MULTILIB_USEDEP}] )
	mesa_dri-drivers_nouveau? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_NOUVEAU_VER}[video_cards_nouveau,${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_nouveau? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_NOUVEAU_VER}[video_cards_nouveau,${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_etnaviv? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_ETNAVIV_VER}[video_cards_vivante,${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_vc4? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_VC4_VER}[video_cards_vc4,${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_svga? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_VER}[video_cards_vmware,${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_freedreno? ( ${LIBDRM_DEPSTRING}-${MESA_DEP_DRM_VER}[video_cards_freedreno,${MULTILIB_USEDEP}] )
"

RDEPED="
	${LIBDRM_RDEPEND}
	!app-eselect/eselect-mesa
	>=app-eselect/eselect-opengl-1.3.0
	>=dev-libs/expat-2.1.0-r3:=[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8[${MULTILIB_USEDEP}]
	>=x11-libs/libX11-1.6.2:=[${MULTILIB_USEDEP}]
	>=x11-libs/libxshmfence-1.1:=[${MULTILIB_USEDEP}]
	>=x11-libs/libXdamage-1.1.4-r1:=[${MULTILIB_USEDEP}]
	>=x11-libs/libXext-1.3.2:=[${MULTILIB_USEDEP}]
	>=x11-libs/libXxf86vm-1.1.3:=[${MULTILIB_USEDEP}]
	>=x11-libs/libxcb-1.13:=[${MULTILIB_USEDEP}]
	x11-libs/libXfixes:=[${MULTILIB_USEDEP}]
	mesa_xlib-lease? ( >=x11-libs/libXrandr-1.3:=[${MULTILIB_USEDEP}] )
	mesa_lmsensors? ( sys-apps/lm_sensors:=[${MULTILIB_USEDEP}] )
	mesa_libunwind? ( sys-libs/libunwind[${MULTILIB_USEDEP}] )
	mesa_glvd? ( sys-libs/libglvd[${MULTILIB_USEDEP}] )
"
RDEPEND="${RDEPEND}

	mesa_vulkan-drivers_amd? ( virtual/libelf:0=[${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_radeonsi? ( virtual/libelf:0=[${MULTILIB_USEDEP}] )
	mesa_gallium-drivers_r600? ( mesa_llvm_auto? ( virtual/libelf:0=[${MULTILIB_USEDEP}] ) mesa_llvm? ( virtual/libelf:0=[${MULTILIB_USEDEP}] ) )

	mesa_gallium-opencl_icd? (
		dev-libs/ocl-icd[khronos-headers,${MULTILIB_USEDEP}]
		dev-libs/libclc
		virtual/libelf:0=[${MULTILIB_USEDEP}]
	)
	mesa_gallium-opencl_standalone? (
		dev-libs/libclc
		virtual/libelf:0=[${MULTILIB_USEDEP}]
	)
	mesa_gallium-va? (
		>=x11-libs/libva-1.7.3:=[${MULTILIB_USEDEP}]
		mesa_gallium-drivers_nouveau? ( !<=x11-libs/libva-vdpau-driver-0.7.4-r3 )
	)
	mesa_gallium-vdpau? ( >=x11-libs/libvdpau-1.1:=[${MULTILIB_USEDEP}] )
	mesa_gallium-xvmc? ( >=x11-libs/libXvMC-1.0.8:=[${MULTILIB_USEDEP}] )

	mesa_platforms_wayland? (
		>=dev-libs/wayland-1.15.0:=[${MULTILIB_USEDEP}]
		>=dev-libs/wayland-protocols-1.11
	)
"

# Please keep the LLVM dependency block separate. Since LLVM is slotted,
# we need to *really* make sure we're not pulling one than more slot
# simultaneously.
#
# How to use it:
# 1. List all the working slots (with min versions) in ||, newest first.
# 2. Update the := to specify *max* version, e.g. < 7.
# 3. Specify LLVM_MAX_SLOT, e.g. 6.

#LLVM_MAX_SLOT="8"
LLVM_MAX_SLOT="7"

LLVM_DEPSTR_AMDGPU=" || ( sys-devel/llvm:8[llvm_targets_AMDGPU(-),${MULTILIB_USEDEP}] sys-devel/llvm:7[llvm_targets_AMDGPU(-),${MULTILIB_USEDEP}] ) sys-devel/llvm:=[llvm_targets_AMDGPU(-),${MULTILIB_USEDEP}]"
LLVM_DEPSTR_SWR=" || ( sys-devel/llvm:8[${MULTILIB_USEDEP}] sys-devel/llvm:7[${MULTILIB_USEDEP}] sys-devel/llvm:6 ) sys-devel/llvm:=[${MULTILIB_USEDEP}]"
LLVM_DEPSTR=" || ( sys-devel/llvm:8[${MULTILIB_USEDEP}] sys-devel/llvm:7[${MULTILIB_USEDEP}] sys-devel/llvm:6[${MULTILIB_USEDEP}] sys-devel/llvm:5[${MULTILIB_USEDEP}] ) sys-devel/llvm:=[${MULTILIB_USEDEP}]"

LLVM_RDEPEND="
	mesa_vulkan-drivers_amd? ( ${LLVM_DEPSTR_AMDGPU} )
	!mesa_vulkan-drivers_amd? (
		mesa_gallium-drivers_radeonsi? ( ${LLVM_DEPSTR_AMDGPU} )
		!mesa_gallium-drivers_radeonsi? (
			mesa_gallium-drivers_r600? ( ${LLVM_DEPSTR_AMDGPU} )
			!mesa_gallium-drivers_r600? (
				mesa_gallium-drivers_swr? ( ${LLVM_DEPSTR_SWR} )
				!mesa_gallium-drivers_swr? (
					mesa_llvm_auto? ( ${LLVM_DEPSTR} )
					mesa_llvm? ( ${LLVM_DEPSTR} )
				)
			)
		)
	)
"
CLANG_RDEPEND="
	mesa_gallium-opencl_icd? ( ${LLVM_RDEPEND//llvm:/clang:} )
	mesa_gallium-opencl_standalone? ( ${LLVM_RDEPEND//llvm:/clang:} )
"

RDEPEND="${RDEPEND}
	${LLVM_RDEPEND}
	${CLANG_RDEPEND}
"
unset LLVM_DEPSTR{_AMDGPU,_SWR,} {LLVM,CLANG}_RDEPEND

DEPEND="${RDEPEND}
	${PYTHON_DEPS}
	opencl? (
		>=sys-devel/gcc-4.6
	)
	sys-devel/bison
	sys-devel/flex
	sys-devel/gettext
	virtual/pkgconfig
	valgrind? ( dev-util/valgrind )
	x11-base/xorg-proto
	x11-libs/libXrandr[${MULTILIB_USEDEP}]
	$(python_gen_any_dep ">=dev-python/mako-0.8.0[\${PYTHON_USEDEP}]")
"

S="${WORKDIR}/${MY_P}"
EGIT_CHECKOUT_DIR=${S}

QA_WX_LOAD="
x86? (
	!pic? (
		usr/lib*/libglapi.so.0.0.0
		usr/lib*/libGLESv1_CM.so.1.0.0
		usr/lib*/libGLESv2.so.2.0.0
		usr/lib*/libGL.so.1.2.0
		usr/lib*/libOSMesa.so.8.0.0
	)
)"

llvm_check_deps() {
	local flags=${MULTILIB_USEDEP}
	if use mesa_vulkan-drivers_amd || use mesa_gallium-drivers_radeonsi || use mesa_gallium-drivers_r600
	then
		flags+=",llvm_targets_AMDGPU(-)"
	fi

	if use mesa_gallium-opencl_icd || use mesa_gallium-opencl_standalone ; then
		has_version "sys-devel/clang[${flags}]" || return 1
	fi
	has_version "sys-devel/llvm[${flags}]"
}

python_check_deps() {
	has_version ">=dev-python/mako-0.8.0[${PYTHON_USEDEP}]"
}

pkg_setup() {
	# warning message for bug 459306
	if ( use mesa_llvm_auto || use mesa_llvm )&& has_version sys-devel/llvm[!debug=]; then
		ewarn "Mismatch between debug USE flags in media-libs/mesa and sys-devel/llvm"
		ewarn "detected! This can cause problems. For details, see bug 459306."
	fi

	if use mesa_llvm || use mesa_llvm_auto; then
		llvm_pkg_setup
	fi
	python-any-r1_pkg_setup
}

multilib_src_configure() {
	# option( 'dri-drivers-path', type : 'string', value : '',
	# description : 'Location to install dri drivers. Default: $libdir/dri.' )
	MESA_DRI_DRIVERS_PATH=""

	# option( 'dri-search-path', type : 'string', value : '',
	# description : 'Locations to search for dri drivers, passed as colon separated list. Default: dri-drivers-path.' )
	MESA_DRI_SEARCH_PATH=""

	MESA_VDPAU_LIBS_PATH=""
	MESA_XVMC_LIBS_PATH=""
	MESA_OMX_LIBS_PATH=""
	MESA_VA_LIBS_PATH="${EPREFIX}/usr/$(get_libdir)/va/drivers"
	MESA_D3D_DRIVERS_PATH=""
	MESA_VULCAN_ICD_DIR=""

	local emesonargs=(
		$(mesa_option_array mesa_platforms ${IUSE_MESA_PLATFORMS})

		$(mesa_option_autobool mesa_dri3)
		$(mesa_option_array mesa_dri-drivers ${IUSE_MESA_DRI_DRIVERS})
		$(mesa_option_string dri-drivers-path "${MESA_DRI_DRIVERS_PATH}")
		$(mesa_option_string dri-search-path "${MESA_DRI_SEARCH_PATH}")

		# SWR only builds for 64 bit.
		$(mesa_option_array mesa_gallium-drivers ${IUSE_MESA_GALLIUM_DRIVERS} | ( if [[ ${ABI} == x86 ]] ; then  sed -e 's/,\?swr\b//g' ; else  cat ; fi ) )

		$(mesa_option_boolean mesa_gallium-extra-hud)

		$(mesa_option_autobool mesa_gallium-vdpau)
		$(mesa_option_string mesa_vdpau-libs-path"${MESA_VDPAU_LIBS_PATH}")
		$(mesa_option_autobool mesa_gallium-xvmc)
		$(mesa_option_string mesa_xvmc-libs-path "${MESA_XVMC_LIBS_PATH}")
		$(mesa_option_combo mesa_gallium-omx disabled ${IUSE_MESA_GALLIUM_OMX})
		$(mesa_option_string mesa_omx-libs-path "${MESA_OMX_LIBS_PATH}")
		$(mesa_option_autobool mesa_gallium-va)
		$(mesa_option_string mesa_va-libs-path "${MESA_VA_LIBS_PATH}")
		$(mesa_option_autobool mesa_gallium-xa)

		$(mesa_option_combo mesa_gallium-opencl disabled ${IUSE_MESA_GALLIUM_OPENCL})
		$(mesa_option_boolean mesa_gallium-nine)
		$(mesa_option_string mesa_d3d-drivers-path "${MESA_D3D_DRIVERS_PATH}")

		$(mesa_option_array mesa_vulkan-drivers ${IUSE_MESA_VULKAN_DRIVERS})
		$(mesa_option_boolean mesa_shader-cache)
		$(mesa_option_string mesa_vulcan-icd-dir "${MESA_VULCAN_ICD_DIR}")

		$(mesa_option_boolean mesa_shared-glapi)
		$(mesa_option_boolean mesa_gles1)
		$(mesa_option_boolean mesa_gles2)
		$(mesa_option_boolean mesa_opengl)
		$(mesa_option_autobool mesa_gbm)
		$(mesa_option_combo mesa_glx disabled ${IUSE_MESA_GLX})
		$(mesa_option_autobool mesa_egl)
		$(mesa_option_boolean mesa_glvnd)

		# x86 hardened pax_kernel needs glx-rts, bug 240956
		$( if [[ ${ABI} == x86 ]] ; then  meson_use pax_kernel glx-read-only-text ; else  mesa_option_boolean mesa_glx-read-only-text ; fi )

		# on abi_x86_32 hardened we need to have asm disable
		$( if [[ ${ABI} == x86* ]] && use pic ; then printf -- '-Dasm=false' ; else  mesa_option_boolean mesa_asm ; fi )

		$(mesa_option_autobool mesa_llvm)
		$(mesa_option_boolean mesa_shared-llvm)

		$(mesa_option_autobool mesa_valgrind)
		$(mesa_option_autobool mesa_libunwind)
		$(mesa_option_autobool mesa_lmsensors)

		$(mesa_option_boolean mesa_build-tests)

		$(mesa_option_combo mesa_osmesa none ${IUSE_MESA_OSMESA})
		$(mesa_option_combo mesa_osmesa-bits 8 ${IUSE_MESA_OSMESA_BITS})

		$(mesa_option_array mesa_swr-arches ${IUSE_MESA_SWR_ARCHES})

		$(mesa_option_array mesa_tools ${IUSE_MESA_TOOLS})

		$(mesa_option_boolean mesa_power8)

		$(mesa_option_autobool mesa_xlib-lease)
		$(mesa_option_boolean mesa_glx-direct)

		--buildtype $(usex debug debug plain)
		-Db_ndebug=$(usex debug false true)
	)

	meson_src_configure
}

multilib_src_compile() {
	meson_src_compile
}

multilib_src_install() {
	meson_src_install
}

multilib_src_install_all() {
	einstalldocs
}

multilib_src_test() {
	meson_src_test
}

pkg_postinst() {
	# Switch to the xorg implementation.
	echo
	eselect opengl set --use-old ${OPENGL_DIR}
}

