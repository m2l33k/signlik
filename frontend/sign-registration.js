// Configuration
const API_BASE_URL = 'http://localhost:8081/api';

// Global State
let currentUser = {
    email: null,
    token: null,
    role: null
};

let mediaStream = null;
let mediaRecorder = null;
let recordedChunks = [];
let currentFile = null; // Can be video blob or image blob

// DOM Elements
const loginSection = document.getElementById('loginSection');
const registerSection = document.getElementById('registerSection');
const mainSection = document.getElementById('mainSection');
const videoPreview = document.getElementById('videoPreview');
const canvasPreview = document.getElementById('canvasPreview');
const recordedVideo = document.getElementById('recordedVideo');
const capturedImage = document.getElementById('capturedImage');
const previewContainer = document.getElementById('previewContainer');
const recordingIndicator = document.getElementById('recordingIndicator');

// Initialize
document.addEventListener('DOMContentLoaded', () => {
    checkAuthStatus();
    setupEventListeners();
});

// Check if user is already logged in
function checkAuthStatus() {
    const token = localStorage.getItem('jwt_token');
    const email = localStorage.getItem('user_email');
    const role = localStorage.getItem('user_role');
    
    if (token && email) {
        currentUser = { email, token, role };
        showMainSection();
    } else {
        showLoginSection();
    }
}

// Setup Event Listeners
function setupEventListeners() {
    // Login/Register
    document.getElementById('loginForm').addEventListener('submit', handleLogin);
    document.getElementById('registerForm').addEventListener('submit', handleRegister);
    document.getElementById('showRegister').addEventListener('click', (e) => {
        e.preventDefault();
        showRegisterSection();
    });
    document.getElementById('showLogin').addEventListener('click', (e) => {
        e.preventDefault();
        showLoginSection();
    });

    // Camera Controls
    document.getElementById('startCameraBtn').addEventListener('click', startCamera);
    document.getElementById('stopCameraBtn').addEventListener('click', stopCamera);
    document.getElementById('startRecordingBtn').addEventListener('click', startRecording);
    document.getElementById('stopRecordingBtn').addEventListener('click', stopRecording);
    document.getElementById('capturePhotoBtn').addEventListener('click', capturePhoto);
    document.getElementById('retakeBtn').addEventListener('click', retake);
    document.getElementById('useThisBtn').addEventListener('click', useThisMedia);

    // File Upload
    document.getElementById('fileInput').addEventListener('change', handleFileSelect);

    // Sign Form
    document.getElementById('signForm').addEventListener('submit', handleSignSubmit);

    // Browse Signs
    document.getElementById('searchBtn').addEventListener('click', searchSigns);
    document.getElementById('searchInput').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') searchSigns();
    });
    document.getElementById('categoryFilter').addEventListener('change', filterByCategory);
    document.getElementById('loadPopularBtn').addEventListener('click', loadPopularSigns);
    document.getElementById('loadRecentBtn').addEventListener('click', loadRecentSigns);
    document.getElementById('loadMySignsBtn').addEventListener('click', loadMySigns);
}

// Authentication Functions
async function handleLogin(e) {
    e.preventDefault();
    const email = document.getElementById('loginEmail').value;
    const password = document.getElementById('loginPassword').value;

    try {
        const response = await fetch(`${API_BASE_URL}/auth/login`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({ email, password })
        });

        let data;
        try {
            const text = await response.text();
            data = text ? JSON.parse(text) : {};
        } catch (parseError) {
            data = { message: 'Failed to parse response' };
        }

        if (response.ok) {
            currentUser = {
                email: data.email || email,
                token: data.token,
                role: data.role
            };
            
            localStorage.setItem('jwt_token', currentUser.token);
            localStorage.setItem('user_email', currentUser.email);
            localStorage.setItem('user_role', currentUser.role || '');
            
            showStatus('Login successful!', 'success');
            showMainSection();
        } else {
            const errorMsg = data.message || `Login failed (${response.status})`;
            showStatus(errorMsg, 'error');
        }
    } catch (error) {
        showStatus('Error: ' + error.message, 'error');
    }
}

async function handleRegister(e) {
    e.preventDefault();
    const username = document.getElementById('registerUsername').value;
    const email = document.getElementById('registerEmail').value;
    const password = document.getElementById('registerPassword').value;

    try {
        const response = await fetch(`${API_BASE_URL}/auth/register`, {
            method: 'POST',
            headers: { 'Content-Type': 'application/json' },
            body: JSON.stringify({
                username,
                email,
                password,
                role: 'SPECIALIST'
            })
        });

        const data = await response.json();

        if (response.ok) {
            showStatus('Registration successful! Please login.', 'success');
            showLoginSection();
            document.getElementById('loginEmail').value = email;
        } else {
            showStatus(data.message || 'Registration failed', 'error');
        }
    } catch (error) {
        showStatus('Error: ' + error.message, 'error');
    }
}

// Camera Functions
async function startCamera() {
    try {
        mediaStream = await navigator.mediaDevices.getUserMedia({
            video: { 
                width: { ideal: 1280 },
                height: { ideal: 720 },
                facingMode: 'user'
            },
            audio: true  // Enable audio recording
        });

        videoPreview.srcObject = mediaStream;
        
        document.getElementById('startCameraBtn').disabled = true;
        document.getElementById('stopCameraBtn').disabled = false;
        document.getElementById('startRecordingBtn').disabled = false;
        document.getElementById('capturePhotoBtn').disabled = false;
        
        showStatus('Camera started', 'info');
    } catch (error) {
        showStatus('Error accessing camera: ' + error.message, 'error');
        console.error('Camera error:', error);
    }
}

function stopCamera() {
    if (mediaStream) {
        mediaStream.getTracks().forEach(track => track.stop());
        mediaStream = null;
        videoPreview.srcObject = null;
    }

    document.getElementById('startCameraBtn').disabled = false;
    document.getElementById('stopCameraBtn').disabled = true;
    document.getElementById('startRecordingBtn').disabled = true;
    document.getElementById('stopRecordingBtn').disabled = true;
    document.getElementById('capturePhotoBtn').disabled = true;
    
    showStatus('Camera stopped', 'info');
}

function startRecording() {
    if (!mediaStream) return;

    recordedChunks = [];
    const options = { mimeType: 'video/webm;codecs=vp9' };
    
    try {
        mediaRecorder = new MediaRecorder(mediaStream, options);
    } catch (e) {
        try {
            mediaRecorder = new MediaRecorder(mediaStream);
        } catch (e2) {
            showStatus('MediaRecorder not supported', 'error');
            return;
        }
    }

    mediaRecorder.ondataavailable = (e) => {
        if (e.data.size > 0) {
            recordedChunks.push(e.data);
        }
    };

    mediaRecorder.onstop = () => {
        const blob = new Blob(recordedChunks, { type: 'video/webm' });
        currentFile = blob;
        recordedVideo.src = URL.createObjectURL(blob);
        recordedVideo.style.display = 'block';
        capturedImage.style.display = 'none';
        previewContainer.style.display = 'block';
        recordingIndicator.style.display = 'none';
    };

    mediaRecorder.start();
    recordingIndicator.style.display = 'flex';
    
    document.getElementById('startRecordingBtn').disabled = true;
    document.getElementById('stopRecordingBtn').disabled = false;
    
    showStatus('Recording started', 'info');
}

function stopRecording() {
    if (mediaRecorder && mediaRecorder.state !== 'inactive') {
        mediaRecorder.stop();
        document.getElementById('startRecordingBtn').disabled = false;
        document.getElementById('stopRecordingBtn').disabled = true;
        showStatus('Recording stopped', 'info');
    }
}

function capturePhoto() {
    if (!mediaStream) return;

    const context = canvasPreview.getContext('2d');
    canvasPreview.width = videoPreview.videoWidth;
    canvasPreview.height = videoPreview.videoHeight;
    context.drawImage(videoPreview, 0, 0);

    canvasPreview.toBlob((blob) => {
        currentFile = blob;
        capturedImage.src = URL.createObjectURL(blob);
        capturedImage.style.display = 'block';
        recordedVideo.style.display = 'none';
        previewContainer.style.display = 'block';
        showStatus('Photo captured', 'success');
    }, 'image/jpeg', 0.95);
}

function retake() {
    currentFile = null;
    previewContainer.style.display = 'none';
    recordedVideo.src = '';
    capturedImage.src = '';
    document.getElementById('signForm').reset();
    updateSubmitButton();
}

function useThisMedia() {
    if (currentFile) {
        document.getElementById('submitBtn').disabled = false;
        showStatus('Media ready for upload', 'success');
    }
}

function handleFileSelect(e) {
    const file = e.target.files[0];
    if (file) {
        currentFile = file;
        
        if (file.type.startsWith('video/')) {
            recordedVideo.src = URL.createObjectURL(file);
            recordedVideo.style.display = 'block';
            capturedImage.style.display = 'none';
        } else if (file.type.startsWith('image/')) {
            capturedImage.src = URL.createObjectURL(file);
            capturedImage.style.display = 'block';
            recordedVideo.style.display = 'none';
        }
        
        previewContainer.style.display = 'block';
        document.getElementById('submitBtn').disabled = false;
        showStatus('File selected', 'success');
    }
}

// Helper function to check if error is due to expired/invalid token
function isAuthError(response, data) {
    return response.status === 401 || 
           response.status === 403 || 
           (response.status === 500 && (
               data?.message?.toLowerCase().includes('jwt') ||
               data?.message?.toLowerCase().includes('token') ||
               data?.message?.toLowerCase().includes('expired') ||
               data?.error?.toLowerCase().includes('jwt') ||
               data?.error?.toLowerCase().includes('token')
           ));
}

// Helper function to handle authentication errors
function handleAuthError() {
    showStatus('Your session has expired. Please login again.', 'error');
    // Clear stored credentials
    localStorage.removeItem('jwt_token');
    localStorage.removeItem('user_email');
    localStorage.removeItem('user_role');
    currentUser = { email: null, token: null, role: null };
    // Redirect to login
    setTimeout(() => {
        showLoginSection();
    }, 2000);
}

// Sign Registration
async function handleSignSubmit(e) {
    e.preventDefault();

    if (!currentFile) {
        showStatus('Please record or upload a video/image first', 'error');
        return;
    }

    const signName = document.getElementById('signName').value;
    if (!signName) {
        showStatus('Please enter a sign name', 'error');
        return;
    }

    const formData = new FormData();
    formData.append('file', currentFile);
    formData.append('name', signName);
    formData.append('description', document.getElementById('signDescription').value);
    formData.append('category', document.getElementById('signCategory').value);
    formData.append('difficultyLevel', document.getElementById('signDifficulty').value);

    const submitBtn = document.getElementById('submitBtn');
    submitBtn.disabled = true;
    submitBtn.innerHTML = '<span class="loading"></span> Uploading...';

    try {
        const response = await fetch(`${API_BASE_URL}/signs/add`, {
            method: 'POST',
            headers: {
                'Authorization': `Bearer ${currentUser.token}`
            },
            body: formData
        });

        let data;
        try {
            const text = await response.text();
            data = text ? JSON.parse(text) : {};
        } catch (parseError) {
            data = { error: 'Failed to parse response', message: await response.text() };
        }

        if (response.ok) {
            showStatus('Sign registered successfully!', 'success');
            document.getElementById('signForm').reset();
            retake();
            loadMySigns();
        } else {
            // Check if it's an authentication error
            if (isAuthError(response, data)) {
                handleAuthError();
            } else {
                // Display validation or other errors
                const errorMsg = data.message || data.error || `Failed to register sign (${response.status})`;
                console.error('Sign registration error:', response.status, data);
                showStatus(errorMsg, 'error');
            }
            submitBtn.disabled = false;
            submitBtn.innerHTML = '<span>✅</span> Register Sign';
        }
    } catch (error) {
        showStatus('Error: ' + error.message, 'error');
        submitBtn.disabled = false;
        submitBtn.innerHTML = '<span>✅</span> Register Sign';
    }
}

function updateSubmitButton() {
    const hasFile = currentFile !== null;
    const hasName = document.getElementById('signName').value.trim() !== '';
    document.getElementById('submitBtn').disabled = !(hasFile && hasName);
}

document.getElementById('signName').addEventListener('input', updateSubmitButton);

// Browse Signs Functions
async function searchSigns() {
    const query = document.getElementById('searchInput').value;
    if (!query.trim()) return;

    try {
        const response = await fetch(`${API_BASE_URL}/signs/search?query=${encodeURIComponent(query)}`);
        const signs = await response.json();
        displaySigns(signs, 'signsContainer');
    } catch (error) {
        showStatus('Error searching signs: ' + error.message, 'error');
    }
}

async function filterByCategory() {
    const category = document.getElementById('categoryFilter').value;
    if (!category) return;

    try {
        const response = await fetch(`${API_BASE_URL}/signs/category/${encodeURIComponent(category)}`);
        const signs = await response.json();
        displaySigns(signs, 'signsContainer');
    } catch (error) {
        showStatus('Error loading signs: ' + error.message, 'error');
    }
}

async function loadPopularSigns() {
    try {
        const response = await fetch(`${API_BASE_URL}/signs/popular?limit=20`);
        const signs = await response.json();
        displaySigns(signs, 'signsContainer');
    } catch (error) {
        showStatus('Error loading popular signs: ' + error.message, 'error');
    }
}

async function loadRecentSigns() {
    try {
        const response = await fetch(`${API_BASE_URL}/signs/recent?limit=20`);
        const signs = await response.json();
        displaySigns(signs, 'signsContainer');
    } catch (error) {
        showStatus('Error loading recent signs: ' + error.message, 'error');
    }
}

async function loadMySigns() {
    if (!currentUser.email) return;

    try {
        const response = await fetch(`${API_BASE_URL}/signs/specialist/${encodeURIComponent(currentUser.email)}`, {
            headers: {
                'Authorization': `Bearer ${currentUser.token}`
            }
        });
        
        let data;
        try {
            const text = await response.text();
            data = text ? JSON.parse(text) : {};
        } catch (parseError) {
            data = { error: 'Failed to parse response' };
        }
        
        if (response.ok) {
            displaySigns(data, 'mySignsContainer', true);
        } else if (isAuthError(response, data)) {
            handleAuthError();
        } else {
            showStatus('Error loading your signs', 'error');
        }
    } catch (error) {
        showStatus('Error loading your signs: ' + error.message, 'error');
    }
}

function displaySigns(signs, containerId, showActions = false) {
    const container = document.getElementById(containerId);
    container.innerHTML = '';

    if (signs.length === 0) {
        container.innerHTML = '<p style="text-align: center; color: #666;">No signs found</p>';
        return;
    }

    signs.forEach(sign => {
        const card = document.createElement('div');
        card.className = 'sign-card';
        
        // Determine if it's an image or video based on content type
        const isImage = sign.contentType && sign.contentType.startsWith('image/');
        const mediaUrl = sign.signedVideoUrl || sign.signedThumbnailUrl;
        
        // Build media HTML based on content type
        let mediaHtml = '';
        if (mediaUrl) {
            if (isImage) {
                mediaHtml = `<img src="${mediaUrl}" alt="${sign.name}" style="width: 100%; margin-top: 10px; border-radius: 4px; max-height: 400px; object-fit: contain; background: #000;">`;
            } else {
                mediaHtml = `<video controls style="width: 100%; margin-top: 10px; border-radius: 4px;" src="${mediaUrl}"></video>`;
            }
        }
        
        card.innerHTML = `
            <h3>${sign.name}</h3>
            ${sign.description ? `<p>${sign.description}</p>` : ''}
            <div class="sign-meta">
                ${sign.category ? `<span class="sign-badge">${sign.category}</span>` : ''}
                ${sign.difficultyLevel ? `<span class="sign-badge">${sign.difficultyLevel}</span>` : ''}
                ${sign.isApproved ? '<span class="sign-badge" style="background: #28a745;">Approved</span>' : '<span class="sign-badge" style="background: #ffc107; color: #000;">Pending</span>'}
                <span class="sign-badge" style="background: #6c757d;">👁️ ${sign.viewCount || 0}</span>
            </div>
            ${mediaHtml}
            ${showActions ? `
                <div class="sign-actions">
                    ${!sign.isApproved ? `<button class="btn btn-success" onclick="approveSign(${sign.id})">Approve</button>` : ''}
                    <button class="btn btn-danger" onclick="deleteSign(${sign.id})">Delete</button>
                </div>
            ` : ''}
        `;
        
        container.appendChild(card);
    });
}

async function approveSign(signId) {
    try {
        const response = await fetch(`${API_BASE_URL}/signs/${signId}/approve`, {
            method: 'PUT',
            headers: {
                'Authorization': `Bearer ${currentUser.token}`
            }
        });

        let data;
        try {
            const text = await response.text();
            data = text ? JSON.parse(text) : {};
        } catch (parseError) {
            data = {};
        }

        if (response.ok) {
            showStatus('Sign approved!', 'success');
            loadMySigns();
        } else if (isAuthError(response, data)) {
            handleAuthError();
        } else {
            showStatus('Failed to approve sign', 'error');
        }
    } catch (error) {
        showStatus('Error: ' + error.message, 'error');
    }
}

async function deleteSign(signId) {
    if (!confirm('Are you sure you want to delete this sign?')) return;

    try {
        const response = await fetch(`${API_BASE_URL}/signs/${signId}`, {
            method: 'DELETE',
            headers: {
                'Authorization': `Bearer ${currentUser.token}`
            }
        });

        let data;
        try {
            const text = await response.text();
            data = text ? JSON.parse(text) : {};
        } catch (parseError) {
            data = {};
        }

        if (response.ok) {
            showStatus('Sign deleted!', 'success');
            loadMySigns();
        } else if (isAuthError(response, data)) {
            handleAuthError();
        } else {
            showStatus('Failed to delete sign', 'error');
        }
    } catch (error) {
        showStatus('Error: ' + error.message, 'error');
    }
}

// UI Helper Functions
function showLoginSection() {
    loginSection.style.display = 'block';
    registerSection.style.display = 'none';
    mainSection.style.display = 'none';
}

function showRegisterSection() {
    loginSection.style.display = 'none';
    registerSection.style.display = 'block';
    mainSection.style.display = 'none';
}

function showMainSection() {
    loginSection.style.display = 'none';
    registerSection.style.display = 'none';
    mainSection.style.display = 'block';
    loadRecentSigns(); // Load signs on page load
}

function showStatus(message, type = 'info') {
    const statusEl = document.getElementById('statusMessage');
    statusEl.textContent = message;
    statusEl.className = `status-message ${type} show`;
    
    setTimeout(() => {
        statusEl.classList.remove('show');
    }, 3000);
}

// Make functions available globally for onclick handlers
window.approveSign = approveSign;
window.deleteSign = deleteSign;

