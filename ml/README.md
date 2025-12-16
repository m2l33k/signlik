# ASL Alphabet Training Pipeline

## Dataset
- Source: Kaggle `asl_alphabet` (A–Z + SPACE, DELETE, NOTHING)
- Place at `./dataset/asl_alphabet_kaggle/` (folders per class with images)

## Environment
```bash
python -m venv .venv
. .venv/Scripts/activate  # Windows
pip install -r ml/requirements.txt
```

## Steps
1) Analyze dataset
```bash
python ml/prepare_data.py
```
2) Train MobileNetV2 model
```bash
python ml/train_mobilenetv2.py
```
- Saves model to `models/asl_alphabet_model.h5`
- Saves history plots and metrics under `models/`

3) Evaluate (included in training script)

4) Realtime inference (OpenCV window)
```bash
python ml/asl_predict.py
```

5) WebSocket server for web app
```bash
python ml/ws_predict.py
```
- Frontend toggle "Use Python predictions" connects to `ws://localhost:8765`

## Integration
- For browser deployment, convert to TF.js format after training (optional):
```bash
pip install tensorflowjs
tensorflowjs_converter --input_format=keras models/asl_alphabet_model.h5 gesture-ai/public/gesture-model
```
- Then the Next.js app will load `/gesture-model/model.json` directly.

## Ethics & Impact
- Dataset is community-sourced via Kaggle; use is for accessibility.
- Avoid misuse; do not claim medical-grade accuracy.
- Future work: expand to ASL Citizen/WLASL for words/phrases.



