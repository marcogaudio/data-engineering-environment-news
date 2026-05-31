#!/bin/bash

# Local Data Engineering Environment Setup Script
# This script sets up the complete local data engineering environment

echo "🚀 Setting up Local Data Engineering Environment..."

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is not installed. Please install Python 3.9 or higher."
    exit 1
fi

# Check Python version
python_version=$(python3 -c 'import sys; print(".".join(map(str, sys.version_info[:2])))')
required_version="3.9"

if [ "$(printf '%s\n' "$required_version" "$python_version" | sort -V | head -n1)" != "$required_version" ]; then
    echo "❌ Python version $python_version is less than required version $required_version"
    exit 1
fi

echo "✅ Python $python_version detected"

# Create virtual environment
echo "📦 Creating virtual environment..."
python3 -m venv env

# Activate virtual environment
echo "🔧 Activating virtual environment..."
source env/bin/activate

# Upgrade pip
echo "⬆️ Upgrading pip..."
pip install --upgrade pip

# Install dependencies
echo "📚 Installing dependencies..."
pip install -r requirements.txt

# Create output directo ry
echo "📁 Creating output directory..."
mkdir -p output

# Create .env file if it doesn't exist
if [ ! -f .env ]; then
    echo "⚙️ Creating .env file..."
    cat > .env << EOF
# Environment variables for local data engineering environment
PIPELINE_NAME=local_data
DATASET_NAME=my_data
DATA_DIR=./data
OUTPUT_DIR=./output

# Jupyter configuration
JUPYTER_ENABLE_LAB=yes
JUPYTER_TOKEN=your_token_here
EOF
    echo "✅ Created .env file"
fi

echo ""
echo "🎉 Setup completed successfully!"
echo ""
