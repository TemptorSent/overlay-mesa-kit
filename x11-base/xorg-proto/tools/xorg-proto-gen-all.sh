#!/bin/sh
for eb in xorg-proto-*.ebuild ; do
	ppkg="${eb/%.ebuild/}"
	ppkg="${ppkg##*/}"
	ppkgver="${ppkg#xorg-proto-}"

	ebuild "${eb}" manifest
	ebuild "${eb}" unpack

	pushd ~portage/x11-base/${ppkg}/work
		if [ -d "${ppkg}" ] ; then cd "${ppkg}"
		elif [ -d "xorgproto-${ppkgver}" ] ; then cd "xorgproto-${ppkgver}"
		else printf --  "Can't fingure out location of sources for ${eb}, skipping!" ; continue ; fi
		if ! [ -e meson.build ] ; then printf -- "No meson.build file found for ${eb}, skipping!" ; continue ; fi
		pkgs="$(cat meson.build | sed -n '/^pcs = \[/,/^\]/ { s/'"'"',[[:space:]]*'"'"'/-/ ; s/'"'"'],//; s/.*\['"'"'// p};')"
		pkgs_legacy="$(cat meson.build | sed -n '/^[[:space:]]*legacy_pcs = \[/,/^[[:space:]]*\]/ { s/'"'"',[[:space:]]*'"'"'/-/ ; s/'"'"'],//; s/.*\['"'"'// p};')"
	popd

	for proto in ${pkgs} ${pkgs_legacy} ; do

		protoname="${proto%-[0-9]*}"
		protover="${proto#${protoname}}"
		protodir="../../x11-proto/${protoname}"
		mkdir -p "${protodir}"
		protoebuild="${protodir}/${proto}.ebuild"
		[ -e "${protoebuild}" ] && continue
		cat > "${protoebuild}" \
<<EOF
# Distributed under the terms of the GNU General Public License v2
EAPI=6

DESCRIPTION="X.Org Protocol ${protoname} package stub (provided by ${ppkg})."

KEYWORDS="*"

SLOT="0"

RDEPEND=">=x11-base/${ppkg}"
DEPEND="\${RDEPEND}"
EOF

	done

	sed -e '/LEGACY_DEPS="/,/"/ d ; /DEPEND="/,/"/ d ' -i "${eb}"
	printf -- "LEGACY_DEPS=\"" >> "${eb}"
	for pl in ${pkgs_legacy} ; do printf -- "\n!<x11-proto/${pl}" >> "${eb}" ; done
	printf -- "\"\n" >> "${eb}"
	printf -- "DEPEND=\"legacy? ( \${LEGACY_DEPS} )" >> "${eb}"
	for p in ${pkgs}\ ; do printf -- "\n!<x11-proto/${p}" >> "${eb}" ; done
	printf -- "\"\n" >> "${eb}"

	ebuild "${eb}" manifest
done

