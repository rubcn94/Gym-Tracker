#!/usr/bin/env python3
"""
Genera iconos PNG simples para la PWA sin SVG
Solo usa PIL/Pillow
"""
try:
    from PIL import Image, ImageDraw, ImageFont
    import os

    def create_icon(size):
        # Crear imagen con fondo negro
        img = Image.new('RGB', (size, size), color='#0f0f0f')
        draw = ImageDraw.Draw(img)

        # Colores
        accent = '#e8ff47'
        accent2 = '#c8df30'

        # Escalar dimensiones según tamaño
        scale = size / 512

        # Mancuerna estilizada
        center = size // 2

        # Barra central horizontal
        bar_width = int(280 * scale)
        bar_height = int(30 * scale)
        bar_x1 = center - bar_width // 2
        bar_y1 = center - bar_height // 2
        bar_x2 = center + bar_width // 2
        bar_y2 = center + bar_height // 2
        draw.rounded_rectangle([bar_x1, bar_y1, bar_x2, bar_y2], radius=int(15*scale), fill=accent)

        # Peso izquierdo
        left_x = center - int(140 * scale)
        weight_w = int(30 * scale)
        weight_h = int(100 * scale)
        draw.rounded_rectangle(
            [left_x - weight_w, center - weight_h//2, left_x, center + weight_h//2],
            radius=int(5*scale), fill=accent
        )
        draw.rounded_rectangle(
            [left_x - weight_w - int(20*scale), center - int(80*scale)//2,
             left_x - weight_w, center + int(80*scale)//2],
            radius=int(3*scale), fill=accent2
        )

        # Peso derecho
        right_x = center + int(140 * scale)
        draw.rounded_rectangle(
            [right_x, center - weight_h//2, right_x + weight_w, center + weight_h//2],
            radius=int(5*scale), fill=accent
        )
        draw.rounded_rectangle(
            [right_x + weight_w, center - int(80*scale)//2,
             right_x + weight_w + int(20*scale), center + int(80*scale)//2],
            radius=int(3*scale), fill=accent2
        )

        return img

    print("Generando iconos...")

    for size in [192, 512]:
        print(f"  Creando icon-{size}.png...")
        img = create_icon(size)
        img.save(f'icon-{size}.png', 'PNG')
        print(f"    OK icon-{size}.png")

    print("\nIconos generados!")
    print("\nAhora puedes:")
    print("  1. Abrir gymtracker.html en Chrome/Edge")
    print("  2. Click en el icono de instalacion (+) en la barra de direcciones")
    print("  3. Confirmar instalacion")
    print("  4. App lista!")

except ImportError:
    print("Error: PIL/Pillow no está instalado")
    print("\nInstala con: pip install pillow")
except Exception as e:
    print(f"Error: {e}")
