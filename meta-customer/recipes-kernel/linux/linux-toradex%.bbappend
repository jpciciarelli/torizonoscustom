FILESEXTRAPATHS:prepend := "${THISDIR}/linux-toradex:"

# Prevent the use of in-tree defconfig
#unset KBUILD_DEFCONFIG

#CUSTOM_DEVICETREE = "my-custom-devicetree-file.dts"

#SRC_URI += "\
#	file://${CUSTOM_DEVICETREE} \
#	file://custom-display.patch \
#	file://defconfig \
#"

#do_configure:append() {
#	# For arm32 bit devices
#	# cp ${WORKDIR}/${CUSTOM_DEVICETREE} ${S}/arch/arm/boot/dts
#	# For arm64 bit freescale/NXP devices
#	cp ${WORKDIR}/${CUSTOM_DEVICETREE} ${S}/arch/arm64/boot/dts/freescale
#}

SRC_URI += "file://fragment.cfg"
