#!/bin/sh

OUTDIR="../../x11-proto"
STUBREV="-r10"

for eb in xorg-proto-*.ebuild ; do
	ppkg="${eb/%.ebuild/}"
	ppkg="${ppkg##*/}"
	ppkgver="${ppkg#xorg-proto-}"

	ebuild "${eb}" manifest
	ebuild "${eb}" unpack

	pushd ~portage/x11-base/${ppkg}/work
		if [ -d "${ppkg}" ] ; then cd "${ppkg}"
		elif [ -d "xorgproto-${ppkgver}" ] ; then cd "xorgproto-${ppkgver}"
		else printf --  "Can't figure out location of sources for ${eb}, skipping!" ; continue ; fi
		if ! [ -e meson.build ] ; then printf -- "No meson.build file found for ${eb}, skipping!" ; continue ; fi
		pkgs="$(cat meson.build | sed -n '/^pcs = \[/,/^\]/ { s/'"'"',[[:space:]]*'"'"'/-/ ; s/'"'"'],//; s/.*\['"'"'// p};')"
		pkgs_legacy="$(cat meson.build | sed -n '/^[[:space:]]*legacy_pcs = \[/,/^[[:space:]]*\]/ { s/'"'"',[[:space:]]*'"'"'/-/ ; s/'"'"'],//; s/.*\['"'"'// p};')"
	popd

	for proto in ${pkgs} ${pkgs_legacy} ; do

		protoname="${proto%-[0-9]*}"
		protover="${proto#${protoname}}"
		protodir="${OUTDIR}/${protoname}"
		mkdir -p "${protodir}"
		protoebuild="${protodir}/${proto}${STUBREV}.ebuild"
		if [ -e "${protoebuild}" ] && ! grep -q "x11-base/${ppkg}" "${protoebuild}" ; then
			printf -- "Adding ${ppkg} as provider to ebuild '${protoebuild}'.\n"
			sed -e 's:RDEPEND=" || (:&\n\t=x11-base/'"${ppkg}:" -i "${protoebuild}"
			continue
		fi
		printf -- "Writing stub ebuild '${protoebuild}.'\n"
		cat > "${protoebuild}" \
<<EOF
# Distributed under the terms of the GNU General Public License v2
EAPI=6

inherit multilib-minimal

DESCRIPTION="X.Org Protocol ${proto} package stub (provided by ${ppkg%${ppkgver}})."

KEYWORDS="*"

SLOT="0"

RDEPEND=" || (
	=x11-base/${ppkg}[\${MULTILIB_USEDEP}]
)"
DEPEND="\${RDEPEND}"

multilib_src_configure() { return 0; }
multilib_src_compile() { return 0; }
multilib_src_install() { return 0; }

EOF

	ebuild "${protoebuild}" manifest
	done

	
	printf -- "\nUpdating '${eb}'.\n"
	sed -e '/LEGACY_DEPS="/,/"/ d ; /PDEPEND="/,/"/ d ' -i "${eb}"
	printf -- "LEGACY_DEPS=\"" >> "${eb}"
	for pl in ${pkgs_legacy} ; do printf -- "\n\t=x11-proto/${pl}${STUBREV}[\${MULTILIB_USEDEP}]" >> "${eb}" ; done
	printf -- '"\n' >> "${eb}"
	printf -- "PDEPEND=\"legacy? ( \${LEGACY_DEPS} )" >> "${eb}"
	for p in ${pkgs} ; do printf -- "\n\t=x11-proto/${p}${STUBREV}[\${MULTILIB_USEDEP}]" >> "${eb}" ; done
	printf -- '"\n' >> "${eb}"

	ebuild "${eb}" manifest
done

