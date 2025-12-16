#!/bin/bash

# Setup Python environment for TSL model training

echo "Setting up Python environment for TSL model training..."

# Check Python version
python3 --version

# Create virtual environment (optional but recommended)
if [ ! -d ".venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv .venv
fi

# Activate virtual environment
source .venv/bin/activate 2>/dev/null || {
    echo "Note: Virtual environment activation may vary by shell"
    echo "Run: source .venv/bin/activate"
}

# Upgrade pip
echo "Upgrading pip..."
python3 -m pip install --upgrade pip

# Install dependencies
echo "Installing dependencies..."
python3 -m pip install -r requirements.txt

echo ""
echo "✓ Environment setup complete!"
echo ""
echo "To activate virtual environment:"
echo "  source .venv/bin/activate"
echo ""
echo "To run training:"
echo "  ./run_training.sh"
echo "  or"
echo "  python3 train_tsl_enhanced.py"

