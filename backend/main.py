from fastapi import FastAPI, File, UploadFile, Form, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from preprocess import preprocess_image          # ← absolute import
from ocr_engine import extract_text             # ← absolute import
import logging

app = FastAPI(title="Open OCR API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:3000",   # React dev server
        "https://ocr-app-psi-rose.vercel.app",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/ocr")
async def ocr_endpoint(
    image: UploadFile = File(...),
    lang: str = Form("eng")
):
    if not image.content_type.startswith("image/"):
        raise HTTPException(400, "File must be an image")

    try:
        image_bytes = await image.read()
        processed = preprocess_image(image_bytes)
        text = extract_text(processed, lang=lang)
        return {"text": text}
    except Exception as e:
        logging.error(f"OCR error: {e}")
        # Still return valid JSON — FastAPI will add CORS headers
        raise HTTPException(500, "Failed to process image. Please try again.")