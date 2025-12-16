# How to Download the TSL Dataset

## Dataset Source

**Name**: "First ever Tunisian Sign Language Dataset"  
**URL**: https://data.mendeley.com/datasets/fbjjgzgv7f  
**Platform**: Mendeley Data  
**Publication**: May 22, 2023

## Step-by-Step Download

### Method 1: Direct Download

1. **Visit the Dataset Page**
   - Go to: https://data.mendeley.com/datasets/fbjjgzgv7f
   - You may need to create a free Mendeley account

2. **Download the Dataset**
   - Click "Download" button
   - Select all files or specific components
   - Dataset will download as ZIP file(s)

3. **Extract Files**
   ```bash
   # Extract to dataset directory
   cd dataset
   unzip downloaded_file.zip -d tsl_dataset/
   ```

### Method 2: Using the Script

1. **Run Download Script**
   ```bash
   cd ml
   python download_tsl_dataset.py
   ```

2. **Follow Instructions**
   - Script will create directory structure
   - You'll need to manually organize images into sign folders
   - Based on dataset structure

## Dataset Structure

### Expected Organization

```
dataset/tsl_dataset/organized/
├── hello/
│   ├── image001.jpg
│   ├── image002.jpg
│   └── ...
├── yes/
│   ├── image001.jpg
│   └── ...
├── no/
├── thank_you/
├── please/
└── ... (57 sign folders total)
```

### Dataset Contents

- **Total Images**: 4,423
- **Signs**: 57 standard TSL signs
- **Signers**: 7 individuals
- **Image Size**: 224 × 224 pixels
- **Format**: JPG/PNG

## Dataset Details

### Signs Included (57 total)

**Greetings**: hello, goodbye, thank_you, please, sorry  
**Basic**: yes, no, maybe, ok, help  
**Family**: mother, father, brother, sister, family  
**Common**: water, food, eat, drink, sleep, house, school, work, home, friend  
**Time**: today, tomorrow, yesterday, morning, evening  
**Questions**: what, where, when, why, how, who  
**Actions**: go, come, see, hear, speak, read, write, learn, teach, understand  
**Numbers**: zero, one, two, three, four, five, six, seven, eight, nine  
**Emotions**: good, bad, happy, sad, love, like, want, need

### Image Characteristics

- **Resolution**: 224 × 224 pixels
- **Background**: Varied (diverse environments)
- **Lighting**: Varied (different conditions)
- **Angles**: Multiple hand angles
- **Accessories**: Some images include hand accessories
- **Clothing**: Varied (different signers)

## Verification

### Check Dataset Integrity

```bash
# Count total images
find dataset/tsl_dataset/organized -name "*.jpg" -o -name "*.png" | wc -l
# Should be close to 4,423

# Count sign folders
ls -d dataset/tsl_dataset/organized/*/ | wc -l
# Should be 57

# Check image sizes
identify dataset/tsl_dataset/organized/*/*.jpg | head -5
# Should show 224x224 or similar
```

## After Download

### Next Steps

1. **Organize Images**
   - Ensure images are in correct sign folders
   - Verify folder names match TSL sign names

2. **Train Model**
   ```bash
   cd ml
   python train_tsl_model.py
   ```

3. **Verify Training**
   - Check training logs
   - Review accuracy metrics
   - Test model inference

## Troubleshooting

### Dataset Not Downloading

- **Check Account**: You may need a Mendeley account
- **Check Internet**: Large file, needs stable connection
- **Try Alternative**: Contact dataset authors if needed

### Images Not Organized

- **Manual Organization**: You may need to organize manually
- **Check Documentation**: Review dataset README
- **Use Script**: `download_tsl_dataset.py` creates structure

### Missing Images

- **Verify Download**: Re-download if corrupted
- **Check Format**: Ensure JPG/PNG files
- **Contact Source**: Reach out to dataset maintainers

## Dataset Citation

If you use this dataset, please cite:

```
"First ever Tunisian Sign Language Dataset", Mendeley Data, 
https://data.mendeley.com/datasets/fbjjgzgv7f, 2023
```

## Support

- **Dataset Issues**: Contact Mendeley Data support
- **Technical Questions**: Check dataset documentation
- **Research Questions**: Contact ATILS (Tunisian Association of Sign Language Interpreters)

