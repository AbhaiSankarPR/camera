from flask import Flask, request, jsonify
import cv2
import pytesseract
import numpy as np
import io

app = Flask(__name__)

# ✅ Optional root route to avoid 404 errors
@app.route('/')
def index():
    return "🕒 Clock Time Detection API is running. Use POST /detect-time to send an image."

# 🧠 Detect time using pytesseract (digital clocks only)
def detect_digital_time(image):
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    # Optional: preprocess to improve OCR accuracy
    gray = cv2.threshold(gray, 0, 255, cv2.THRESH_BINARY + cv2.THRESH_OTSU)[1]
    text = pytesseract.image_to_string(gray)
    return text.strip()

# 🔥 Main endpoint to receive image and return detected time
@app.route('/detect-time', methods=['POST'])
def detect_time():
    if 'image' not in request.files:
        return jsonify({'error': 'No image part in request'}), 400

    file = request.files['image']
    if file.filename == '':
        return jsonify({'error': 'No image selected'}), 400

    try:
        img_bytes = file.read()
        np_arr = np.frombuffer(img_bytes, np.uint8)
        image = cv2.imdecode(np_arr, cv2.IMREAD_COLOR)

        time_text = detect_digital_time(image)

        return jsonify({'time': time_text})
    except Exception as e:
        return jsonify({'error': str(e)}), 500

# 🚀 Start the Flask app
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)
