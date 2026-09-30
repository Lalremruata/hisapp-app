# App icon

A workshop bill (torn receipt with a rupee total) and an orange wrench badge,
on the Nocturne night ground. Masters are in `assets/icon/`.

To change it, edit `render.py`, then from the project root:

```sh
mkdir -p /tmp/icon
python3 tool/app_icon/render.py assets/fonts/Inter-SemiBold.ttf /tmp/icon
python3 tool/app_icon/export.py /tmp/icon
```

`export.py` writes every iOS, macOS, Android (legacy + adaptive) and web size.
Needs Pillow.
