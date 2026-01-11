import cv2
import numpy as np

def preprocess_image(image_bytes: bytes) -> bytes:
    """Preprocess image: resize, grayscale, denoise"""
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)

    # Resize if too large (improves speed & accuracy)
    max_dim = 1500
    h, w = img.shape[:2]
    if max(h, w) > max_dim:
        scale = max_dim / max(h, w)
        img = cv2.resize(img, (int(w * scale), int(h * scale)))

    # Convert to grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Denoise
    denoised = cv2.fastNlMeansDenoising(gray, None, 10, 7, 21)

    # Threshold (optional: improves contrast)
    _, thresh = cv2.threshold(denoised, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)

    # Encode back to bytes
    _, buffer = cv2.imencode('.png', thresh)
    return buffer.tobytes()