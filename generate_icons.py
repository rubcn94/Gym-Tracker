#!/usr/bin/env python3
"""
Genera iconos PNG para la PWA desde el SVG
Requiere: pip install cairosvg pillow
"""
import os

try:
    import cairosvg
    from PIL import Image
    import io

    svg_file = 'icon.svg'

    if not os.path.exists(svg_file):
        print(f"Error: {svg_file} no existe")
        exit(1)

    # Leer SVG
    with open(svg_file, 'r', encoding='utf-8') as f:
        svg_data = f.read()

    # Generar iconos de diferentes tamaños
    sizes = [192, 512]

    for size in sizes:
        print(f"Generando icon-{size}.png...")

        # Convertir SVG a PNG
        png_data = cairosvg.svg2png(
            bytestring=svg_data.encode('utf-8'),
            output_width=size,
            output_height=size
        )

        # Guardar
        output_file = f'icon-{size}.png'
        with open(output_file, 'wb') as f:
            f.write(png_data)

        print(f"  ✓ {output_file} creado ({size}x{size}px)")

    print("\nIconos generados correctamente!")
    print("\nAhora puedes:")
    print("  1. Abrir gymtracker.html en Chrome/Edge")
    print("  2. Click en el icono de instalacion en la barra de direcciones")
    print("  3. Confirmar instalacion")
    print("  4. La app aparecera como app nativa!")

except ImportError as e:
    print("Error: Falta instalar dependencias")
    print("\nEjecuta:")
    print("  pip install cairosvg pillow")
    print("\nO si estas en Windows y falla cairosvg:")
    print("  pip install pillow-simd")
    print("\nAlternativamente, usa un conversor online:")
    print("  1. Abre https://cloudconvert.com/svg-to-png")
    print("  2. Sube icon.svg")
    print("  3. Configura:")
    print("     - icon-192.png: 192x192px")
    print("     - icon-512.png: 512x512px")
    print("  4. Descarga y guarda en esta carpeta")
except Exception as e:
    print(f"Error: {e}")
    print("\nUsa un conversor online como alternativa (ver instrucciones arriba)")
