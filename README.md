How to install this overlay
----------------------------

### Eselect
```sh
eselect repository enable reagentoo
```
or
```sh
eselect repository add reagentoo git https://gitlab.com/reagentoo/gentoo-overlay.git
```

### Manually
Add an entry to `/etc/portage/repos.conf`:
```ini
[reagentoo]
location = /var/db/repos/reagentoo
sync-type = git
sync-uri = https://gitlab.com/reagentoo/gentoo-overlay.git
priority = 10
```
