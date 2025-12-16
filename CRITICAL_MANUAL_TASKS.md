# Critical Manual Tasks - Quick Reference

## ⚠️ Most Important Manual Tasks

### 1. Organize Dataset Images (2-4 hours) ⚠️ CRITICAL

**What**: Manually organize 4,423 images into 57 sign folders

**Why**: The dataset comes unorganized, needs manual sorting

**Steps**:
1. Download dataset from Mendeley
2. Extract ZIP file
3. Review how images are named/organized in source
4. Create 57 folders: `dataset/tsl_dataset/organized/{sign_name}/`
5. Copy images to appropriate folders based on sign
6. Verify each folder has images

**Location**: `dataset/tsl_dataset/organized/`

**57 Folders Needed**:
hello, goodbye, thank_you, please, sorry, yes, no, maybe, ok, help, mother, father, brother, sister, family, water, food, eat, drink, sleep, house, school, work, home, friend, today, tomorrow, yesterday, morning, evening, what, where, when, why, how, who, go, come, see, hear, speak, read, write, learn, teach, understand, zero, one, two, three, four, five, six, seven, eight, nine, good, bad, happy, sad, love, like, want, need

---

### 2. Create Gesture Images (2-4 hours) ⚠️ CRITICAL

**What**: Create/obtain 57 PNG images showing TSL gestures

**Why**: Needed for text-to-gesture visualization feature

**Steps**:
1. Create folder: `mobile/assets/gestures/`
2. For each of 57 signs, create/obtain an image
3. Name format: `{sign_name}.png` (e.g., `hello.png`)
4. Image size: 200x200 to 400x400 pixels
5. Format: PNG (recommended) or JPG

**Location**: `mobile/assets/gestures/`

**Options for Images**:
- Extract from TSL dataset (one representative image per sign)
- Use gesture visualization tools
- Create custom illustrations
- Collaborate with TSL signers

**57 Images Needed**: Same list as above

---

## Other Manual Tasks (Less Critical)

### 3. Download Dataset (30-60 min)
- Visit Mendeley Data
- Download ZIP file
- Extract to `dataset/tsl_dataset/`

### 4. Configure Environment (10-15 min)
- Create `backend/.env` file
- Fill in database credentials
- Set JWT_SECRET

### 5. Test Everything (1-2 hours)
- Test model training
- Test mobile app
- Test backend API
- Verify all features work

---

## Total Time Estimate

**Critical Tasks**: 4-8 hours
- Organize dataset: 2-4 hours
- Create gesture images: 2-4 hours

**Other Tasks**: 2-3 hours
- Download, configure, test

**Total**: 6-12 hours of manual work

---

## Automation Status

✅ **Automated**:
- Model training (runs automatically)
- Model conversion to TFLite
- File copying scripts
- API endpoints
- Mobile services

❌ **Must Be Manual**:
- Dataset image organization (structure unknown)
- Gesture image creation (creative work)

---

## Priority Order

1. **First**: Download dataset
2. **Second**: Organize images (blocks training)
3. **Third**: Train model (automated, but needs organized data)
4. **Fourth**: Create gesture images (blocks text-to-gesture feature)
5. **Fifth**: Test and deploy

---

## Quick Checklist

- [ ] Download TSL dataset (30-60 min)
- [ ] **Organize 4,423 images into 57 folders (2-4 hours)** ⚠️
- [ ] Train model (automated, 4-8 hours)
- [ ] **Create 57 gesture images (2-4 hours)** ⚠️
- [ ] Copy model files (5 min)
- [ ] Configure environment (10-15 min)
- [ ] Test everything (1-2 hours)

**See `MANUAL_TASKS_CHECKLIST.md` for complete detailed checklist.**

