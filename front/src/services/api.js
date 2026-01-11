const API_BASE = "https://ocr-backend-7uq2.onrender.com";

export const ocrImage = async (file, lang = 'eng') => {
  const formData = new FormData();
  formData.append("image", file);
  formData.append("lang", lang);

  const res = await fetch(`${API_BASE}/ocr`, {
    method: "POST",
    body: formData,
  });

  if (!res.ok) {
    const err = await res.json().catch(() => ({}));
    throw new Error(err.detail || "OCR failed");
  }

  const data = await res.json();
  return data.text;
};