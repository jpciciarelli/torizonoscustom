## Archivos necesarios post-instalación

### Containers autostart

El archivo **docker-compose.yml** ejecuta los contenedores automáticamente. De esta forma la aplicación está lista para usar cuando enciende el módulo.

El archivo debe copiarse al directorio:

`/var/sota/storage/docker-compose/docker-compose.yml`

Se puede verificar el correcto inicio del servicio una vez encendido el módulo con el comando:

```
systemctl status docker-compose.service
```

### CAN0 autostart

Copiar el archivo **can0.service** en /etc/systemd/system/can0.service.

Luego ejecutar los siguientes comandos como root:

```
systemctl daemon-reexec
systemctl enable can0.service
systemctl start can0.service
```

Verificar que la interfaz está habilitada:

```
ip link show can0
```