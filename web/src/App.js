import React, { useState, useCallback } from 'react';
import { ocrImage } from './services/api';

function App() {
  const [image, setImage] = useState(null);
  const [preview, setPreview] = useState(null);
  const [text, setText] = useState('');
  const [loading, setLoading] = useState(false);
  const [lang, setLang] = useState('eng');
  const [error, setError] = useState('');
  const [copySuccess, setCopySuccess] = useState(false);

  const handleFile = useCallback((file) => {
    if (file && file.type.startsWith('image/')) {
      setImage(file);
      setPreview(URL.createObjectURL(file));
      setText('');
      setError('');
      setCopySuccess(false);
    }
  }, []);

  const onDrop = useCallback((e) => {
    e.preventDefault();
    const file = e.dataTransfer.files?.[0];
    handleFile(file);
  }, [handleFile]);

  const onFileChange = (e) => {
    const file = e.target.files?.[0];
    handleFile(file);
  };

  const handleSubmit = async () => {
    if (!image) return;
    setLoading(true);
    setError('');
    setCopySuccess(false);
    try {
      const result = await ocrImage(image, lang);
      setText(result);
    } catch (err) {
      setError(err.message || 'Processing failed. Please try again.');
    } finally {
      setLoading(false);
    }
  };

  const copyText = async () => {
    try {
      await navigator.clipboard.writeText(text);
      setCopySuccess(true);
      setTimeout(() => setCopySuccess(false), 2000);
    } catch (err) {
      setError('Failed to copy text');
    }
  };

  // ... (same imports and state logic as above)

return (
  <div style={{ 
    minHeight: '100vh',
    background: 'linear-gradient(to bottom right, #f9fafb, #f3f4f6)',
    padding: '2rem 1rem',
    fontFamily: '-apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
  }}>
    <div style={{ maxWidth: '800px', margin: '0 auto' }}>
      {/* Header */}
      <div style={{ textAlign: 'center', marginBottom: '2.5rem' }}>
        <h1 style={{ fontSize: '2.25rem', fontWeight: '700', color: '#1f2937', marginBottom: '0.5rem' }}>
          image to Text Converter
        </h1>
        <p style={{ color: '#6b7280' }}>Convert images to editable text in English or Amharic</p>
      </div>

      {/* Card */}
      <div style={{
        backgroundColor: 'white',
        borderRadius: '12px',
        boxShadow: '0 4px 6px -1px rgba(0, 0, 0, 0.1), 0 2px 4px -1px rgba(0, 0, 0, 0.06)',
        border: '1px solid #e5e7eb',
        overflow: 'hidden'
      }}>
        {/* Language Toggle */}
        <div style={{ padding: '1.25rem', borderBottom: '1px solid #e5e7eb', display: 'flex', justifyContent: 'center', gap: '0.5rem' }}>
          <button
            onClick={() => setLang('eng')}
            style={{
              padding: '0.5rem 1rem',
              borderRadius: '8px',
              fontWeight: '600',
              backgroundColor: lang === 'eng' ? '#2563eb' : '#f3f4f6',
              color: lang === 'eng' ? 'white' : '#374151',
              border: 'none',
              cursor: 'pointer'
            }}
          >
            English
          </button>
          <button
            onClick={() => setLang('amh')}
            style={{
              padding: '0.5rem 1rem',
              borderRadius: '8px',
              fontWeight: '600',
              backgroundColor: lang === 'amh' ? '#2563eb' : '#f3f4f6',
              color: lang === 'amh' ? 'white' : '#374151',
              border: 'none',
              cursor: 'pointer',
              fontFamily: lang === 'amh' ? '"Noto Sans Ethiopic", sans-serif' : 'inherit'
            }}
          >
            አማርኛ
          </button>
        </div>

        {/* Upload Area */}
        <div style={{ padding: '1.5rem', borderBottom: '1px solid #e5e7eb' }}>
          <label style={{ display: 'block', marginBottom: '0.75rem', fontSize: '0.875rem', fontWeight: '600', color: '#374151' }}>
            Upload an image or drag & drop
          </label>
          <div 
            style={{
              border: '2px dashed #d1d5db',
              borderRadius: '8px',
              padding: '1.5rem',
              backgroundColor: '#f9fafb',
              textAlign: 'center',
              cursor: 'pointer'
            }}
            onClick={() => document.getElementById('file-upload').click()}
          >
            <svg xmlns="http://www.w3.org/2000/svg" style={{ height: '3rem', width: '3rem', color: '#9ca3af', marginBottom: '0.75rem' }} fill="none" viewBox="0 0 24 24" stroke="currentColor">
              <path strokeLinecap="round" strokeLinejoin="round" strokeWidth="1.5" d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
            </svg>
            <div style={{ marginTop: '0.5rem' }}>
              <input
                type="file"
                accept="image/*"
                onChange={onFileChange}
                id="file-upload"
                style={{ display: 'none' }}
              />
              <span style={{ color: '#2563eb', fontWeight: '600' }}>Choose File</span>
              <p style={{ fontSize: '0.75rem', color: '#6b7280', marginTop: '0.25rem' }}>Supports JPG, PNG, BMP</p>
            </div>
          </div>

          {preview && (
            <div style={{ marginTop: '1rem' }}>
              <h3 style={{ fontSize: '0.875rem', fontWeight: '600', color: '#374151', marginBottom: '0.5rem' }}>Preview</h3>
              <div style={{ border: '1px solid #e5e7eb', borderRadius: '8px', overflow: 'hidden', maxHeight: '256px' }}>
                <img src={preview} alt="Preview" style={{ width: '100%', height: 'auto', objectFit: 'contain' }} />
              </div>
            </div>
          )}
        </div>

        {/* Submit Button */}
        <div style={{ padding: '1.25rem', backgroundColor: '#f9fafb' }}>
          <button
            onClick={handleSubmit}
            disabled={!image || loading}
            style={{
              width: '100%',
              padding: '0.75rem',
              borderRadius: '8px',
              fontWeight: '600',
              backgroundColor: (!image || loading) ? '#9ca3af' : '#2563eb',
              color: 'white',
              border: 'none',
              cursor: (!image || loading) ? 'not-allowed' : 'pointer',
              display: 'flex',
              alignItems: 'center',
              justifyContent: 'center',
              gap: '0.5rem'
            }}
          >
            {loading ? (
              <>
                <span style={{ width: '1.25rem', height: '1.25rem', border: '2px solid white', borderTopColor: 'transparent', borderRadius: '50%', animation: 'spin 1s linear infinite' }}></span>
                Processing...
              </>
            ) : 'Extract Text'}
          </button>
        </div>

        {/* Error */}
        {error && (
          <div style={{ padding: '0.75rem 1.25rem', backgroundColor: '#fef2f2', borderLeft: '4px solid #ef4444', color: '#dc2626' }}>
            {error}
          </div>
        )}

        {/* Result */}
        {text && (
          <div style={{ padding: '1.25rem', borderTop: '1px solid #e5e7eb' }}>
            <div style={{ display: 'flex', justifyContent: 'space-between', alignItems: 'center', marginBottom: '0.75rem' }}>
              <h3 style={{ fontSize: '1.125rem', fontWeight: '600', color: '#1f2937' }}>Extracted Text</h3>
              <div>
                <button
                  onClick={copyText}
                  style={{
                    padding: '0.375rem 0.75rem',
                    fontSize: '0.875rem',
                    backgroundColor: '#f3f4f6',
                    color: '#374151',
                    border: '1px solid #d1d5db',
                    borderRadius: '6px',
                    marginRight: '0.5rem',
                    cursor: 'pointer'
                  }}
                >
                  {copySuccess ? 'Copied!' : 'Copy'}
                </button>
                <a
                  href={`data:text/plain;charset=utf-8,${encodeURIComponent(text)}`}
                  download="extracted-text.txt"
                  style={{
                    padding: '0.375rem 0.75rem',
                    fontSize: '0.875rem',
                    backgroundColor: '#2563eb',
                    color: 'white',
                    textDecoration: 'none',
                    borderRadius: '6px',
                    display: 'inline-block'
                  }}
                >
                  Download
                </a>
              </div>
            </div>
            <textarea
              value={text}
              readOnly
              rows={6}
              style={{
                width: '100%',
                padding: '0.75rem',
                border: '1px solid #d1d5db',
                borderRadius: '8px',
                fontFamily: lang === 'amh' 
                  ? '"Noto Sans Ethiopic", monospace' 
                  : 'ui-monospace, SFMono-Regular, "SF Mono", Monaco, Consolas, "Liberation Mono", "Courier New", monospace',
                fontSize: '0.875rem',
                backgroundColor: '#f9fafb'
              }}
            />
          </div>
        )}
      </div>

      <div style={{ textAlign: 'center', marginTop: '2rem', fontSize: '0.875rem', color: '#6b7280' }}>
        © {new Date().getFullYear()} OCR App • Supports English & Amharic
      </div>
    </div>

    {/* Spinner Animation */}
    <style>{`
      @keyframes spin {
        to { transform: rotate(360deg); }
      }
    `}</style>
  </div>
);
}

export default App;