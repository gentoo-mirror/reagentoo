How to install this overlay
----------------------------

### Layman
```sh
layman -a reagentoo
```
or
```sh
layman -o 'https://github.com/reagentoo/gentoo-overlay/raw/master/repositories.xml' -f -a reagentoo
```

### Manually
Add an entry to `/etc/portage/repos.conf`:
```ini
[reagentoo]
location = /usr/local/portage/reagentoo
sync-uri = https://github.com/reagentoo/gentoo-overlay.git
sync-type = git
auto-sync = yes
```
