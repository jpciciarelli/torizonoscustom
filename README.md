# Proceso de personalización del sistema operativo Torizon OS

## Condición inicial

Sistema operativo y hardware:
```
$ neofetch --off
juan@debian
-----------
OS: Debian GNU/Linux 12 (bookworm) x86_64
Kernel: 6.12.43+deb12-amd64
Uptime: 43 mins
Packages: 2342 (dpkg)
Shell: bash 5.2.15
Resolution: 1920x1080, 1920x1080
DE: Plasma 5.27.5
WM: KWin
Theme: [Plasma], Breeze [GTK2/3]
Icons: [Plasma], breeze [GTK2/3]
Terminal: konsole
CPU: AMD Ryzen 9 9900X (24) @ 5.658GHz
GPU: NVIDIA GeForce GTX 1630
Memory: 2733MiB / 31720MiB
```
Sin máquina virtual recomendado por Toradex.

## Pasos seguidos

### Compilar Torizon OS sin modificaciones

Seguir la guía [Build Torizon OS from Source With Yocto Project/OpenEmbedded](https://developer.toradex.com/torizon/in-depth/build-torizoncore-from-source-with-yocto-projectopenembedded/#nativetorizoncorebuild) seleccionando la opción "Native Torizon OS Build".
Hacer los pasos hasta **Start Building** incluido, no hacer todabía la sección **Customization**. Esto es para ver si compila correctamente sin ninguna modificación. De todas formas al hacer pequeñas modificaciones a posteriori no se necesita descargar nada más y solo recompila una pequeña parte de lo que modifiquemos.
Luego de hacer ```bitbake torizon-docker```, si todo sale bien, estará disponible la imagen tar en:
~/build/deploy/images/verdin-imx8mp/torizon-docker-verdin-imx8mp-Tezi_7.3.0-devel-20250929144048+build.0.tar

#### Historial de comandos
```
$ mkdir ~/bin
$ PATH=~/bin:$PATH
$ curl http://commondatastorage.googleapis.com/git-repo-downloads/repo > ~/bin/repo
$ chmod a+x ~/bin/repo
$ git config --global user.email "you@example.com"
$ git config --global user.name "Your Name"
$ repo init -u git://git.toradex.com/toradex-manifest.git -b refs/tags/7.3.0 -m torizon/default.xml
$ repo sync --no-clone-bundle
$ mkdir build
$ MACHINE=verdin-imx8mp source setup-environment build/
$ bitbake torizon-docker
```

### Compilar Torizon OS con modificaciones

Seguir la guía [Custom Meta Layers, Recipes and Images in Yocto Project (hello-world Examples)](https://developer.toradex.com/linux-bsp/os-development/build-yocto/custom-meta-layers-recipes-and-images-in-yocto-project-hello-world-examples/) pero teniendo en cuenta la wiki de KOAN [Modify the linux kernel with configuration fragments in Yocto](https://wiki.koansoftware.com/index.php/Modify_the_linux_kernel_with_configuration_fragments_in_Yocto) ya que la documentación oficial de Toradex no esta actualizada al día de la fecha (Septiembre 2025), pero las herramientas de desarrollo admiten el uso de 'fragments', como se sugirió en el foro de Toradex en el hilo [Kernel Configuration using Config](https://community.toradex.com/t/kernel-configuration-using-config/26200).

#### Historial de comandos

Mantener el terminal del historial de comandos de "Compilar Torizon OS sin modificaciones" (el anterior) o hacer de nuevo: `$ MACHINE=verdin-imx8mp source setup-environment build/`. Tener en cuenta que en cualquier caso quedamos en el directorio ~/build/.

`$ bitbake-layers create-layer ../layers/meta-customer`

`$ nano ~/build/conf/bblayers.conf`

Con este comando vamos a agregar la línea `${TOPDIR}/../layers/meta-customer \` al final del archivo bblayers.conf.

`$ mkdir -p ~/layers/meta-customer/recipes-kernel/linux/linux-toradex`

`$ rm -rf ~/layers/meta-customer/`

`$ bitbake -c kernel_configme virtual/kernel`

`$ bitbake -c menuconfig virtual/kernel`

Poner en * los módulos `Sequencer support` y `Sequencer dummy client` ubicados en:
```
Device Drivers  --->
  Sound card support  --->
    Advanced Linux Sound Architecture  --->
      Sequencer support  --->
```

`$ bitbake -c diffconfig virtual/kernel`

`$ cp ~/build/tmp/work/verdin_imx8mp-tdx-linux/linux-toradex/6.6.94+git/fragment.cfg ~/layers/meta-customer/recipes-kernel/linux/linux-toradex/fragment.cfg`

Copia el archivo fragment.cfg creado con `bitbake -c diffconfig` al layer personalizado.

`$ touch ~/layers/meta-customer/recipes-kernel/linux/linux-toradex%.bbappend`

Tener en cuenta que al día de la fecha hay un error en la guía (Custom Meta Layers, Recipes and Images in Yocto Project (hello-world Examples)) en el directorio de este comando. Hay que seguir lo descrito en la wiki de KOAN.

`$ nano ~/layers/meta-customer/recipes-kernel/linux/linux-toradex%.bbappend`

Agregar esto al archivo linux-toradex%.bbappend:

```
FILESEXTRAPATHS:prepend := "${THISDIR}/linux-toradex:"
SRC_URI += "file://fragment.cfg"
```

`$ cd ~/layers/meta-customer/`

`git init`

`git add *`

`git commit -m "First commit"`

Con esto queda lista la modificación del kernel.
Y volvemos a re-compilar el OS.

`$ cd ~/build/`

`bitbake torizon-docker`

### Personalizar la imagen de Torizon OS

Seguir los pasos de la guía [Customize Torizon OS Images](https://developer.toradex.com/torizon/os-customization/customize-torizon-os-images/).

#### Historial de comandos

En un terminal nuevo!

`$ mkdir -p ~/tcbdir/ && cd ~/tcbdir/`

`$ wget https://raw.githubusercontent.com/toradex/tcb-env-setup/master/tcb-env-setup.sh`

`$ mkdir customimage && cd customimage/`

`$ cp -r ~/build/tmp/work-shared/verdin-imx8mp/kernel-source/ ./linux`

`$ git clone -b toradex_6.6-2.2.x-imx git://git.toradex.com/device-tree-overlays.git device-trees`

`$ cp ~/build/deploy/images/verdin-imx8mp/torizon-docker-verdin-imx8mp-Tezi_7.3.0-devel-20250929182408+build.0.tar .`

`$ source ../tcb-env-setup.sh`

`$ nano tcbuild.yaml`

Editar el contenido para que refleje el archivo tcbuild.yaml en el directorio "customimage".

`$ torizoncore-builder build`

### Flashear Torizon OS

Seguir los pasos de la guía [Loading Toradex Easy Installer](https://developer.toradex.com/easy-installer/toradex-easy-installer/loading-toradex-easy-installer/) con el "External Media Approach" y un pendrive.

#### Historial de comandos

`$ tar -xf torizon-docker-verdin-imx8mp-Tezi_7.3.0-devel-20250929182408+build.0.tar -C /media/juan/8CFA-D6BE`

Entrar al modo recovery en la placa madre.
