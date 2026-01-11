import pytesseract
from PIL import Image
from io import BytesIO

def extract_text(image_bytes: bytes, lang: str = 'eng') -> str:
    """
    Extract text using Tesseract.
    lang: 'eng' or 'amh'
    """
    try:
        image = Image.open(BytesIO(image_bytes))
        # Preserve line breaks and paragraphs
        custom_config = r'--oem 3 --psm 6'
        text = pytesseract.image_to_string(
            image,
            lang=lang,
            config=custom_config
        )
        # Clean extra whitespace but keep line breaks
        lines = [line.strip() for line in text.split('\n')]
        cleaned = '\n'.join(line for line in lines if line)
        return cleaned
    except Exception as e:
        raise RuntimeError(f"OCR failed: {str(e)}")