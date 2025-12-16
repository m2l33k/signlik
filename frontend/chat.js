// Configuration
const API_BASE_URL = 'http://localhost:8081/api';
const WS_URL = 'http://localhost:8081/ws';

// State
let currentUser = null;
let currentContact = null;
let stompClient = null;
let localStream = null;
let remoteStream = null;
let peerConnection = null;
let isInCall = false;
let isMuted = false;
let isVideoEnabled = true;

// WebRTC Configuration (using Google's public STUN server)
const rtcConfiguration = {
    iceServers: [
        { urls: 'stun:stun.l.google.com:19302' },
        { urls: 'stun:stun1.l.google.com:19302' }
    ]
};

// Initialize on page load
document.addEventListener('DOMContentLoaded', () => {
    loadUserFromStorage();
    if (currentUser) {
        initializeChat();
    } else {
        showLoginPrompt();
    }
});

// Load user from localStorage
function loadUserFromStorage() {
    const token = localStorage.getItem('jwt_token');
    const email = localStorage.getItem('user_email');
    const role = localStorage.getItem('user_role');
    
    if (token && email) {
        currentUser = { email, token, role };
        document.getElementById('currentUserInfo').textContent = `Logged in as: ${email}`;
    }
}

// Show login prompt
function showLoginPrompt() {
    document.getElementById('currentUserInfo').textContent = 'Please login first';
    showStatus('Please login to use chat', 'error');
}

// Initialize chat
async function initializeChat() {
    setupEventListeners();
    await loadContacts();
    
    // Try to connect WebSocket, but don't block if it fails
    connectWebSocket().catch(error => {
        console.error('WebSocket connection failed, will retry:', error);
        showStatus('Chat connection failed. Messages may be delayed. Retrying...', 'error');
        // Retry after 3 seconds
        setTimeout(() => {
            connectWebSocket().catch(e => console.error('Retry failed:', e));
        }, 3000);
    });
}

// Connect to WebSocket
function connectWebSocket() {
    return new Promise((resolve, reject) => {
        try {
            const socket = new SockJS(WS_URL);
            stompClient = Stomp.over(socket);
            
            // Disable debug logging
            stompClient.debug = () => {};
            
            stompClient.connect({}, (frame) => {
                console.log('Connected to WebSocket');
                showStatus('Connected to chat server', 'success');
                
                // Subscribe to user-specific messages using topic pattern
                const userEmailEncoded = currentUser.email.replace("@", "_at_").replace(".", "_dot_");
                stompClient.subscribe(`/topic/messages/${userEmailEncoded}`, (message) => {
                    try {
                        const msg = JSON.parse(message.body);
                        // Only display if it's from the current contact
                        if (!currentContact || msg.sender?.email === currentContact.email || msg.receiver?.email === currentUser.email) {
                            displayMessage(msg, 'received');
                        }
                    } catch (e) {
                        console.error('Error parsing message:', e);
                    }
                });
                
                // Subscribe to call signaling using topic pattern
                stompClient.subscribe(`/topic/call/offer/${userEmailEncoded}`, (message) => {
                    try {
                        const data = JSON.parse(message.body);
                        handleIncomingCall(data);
                    } catch (e) {
                        console.error('Error handling call offer:', e);
                    }
                });
                
                stompClient.subscribe(`/topic/call/answer/${userEmailEncoded}`, (message) => {
                    try {
                        const data = JSON.parse(message.body);
                        handleCallAnswer(data);
                    } catch (e) {
                        console.error('Error handling call answer:', e);
                    }
                });
                
                stompClient.subscribe(`/topic/call/ice/${userEmailEncoded}`, (message) => {
                    try {
                        const data = JSON.parse(message.body);
                        handleIceCandidate(data);
                    } catch (e) {
                        console.error('Error handling ICE candidate:', e);
                    }
                });
                
                stompClient.subscribe(`/topic/call/end/${userEmailEncoded}`, (message) => {
                    try {
                        const data = JSON.parse(message.body);
                        handleCallEnd(data);
                    } catch (e) {
                        console.error('Error handling call end:', e);
                    }
                });
                
                stompClient.subscribe(`/topic/call/reject/${userEmailEncoded}`, (message) => {
                    try {
                        const data = JSON.parse(message.body);
                        handleCallReject(data);
                    } catch (e) {
                        console.error('Error handling call reject:', e);
                    }
                });
                
                // Notify online status
                try {
                    stompClient.send('/app/user.online', {}, currentUser.email);
                } catch (e) {
                    console.error('Error sending online status:', e);
                }
                
                resolve();
            }, (error) => {
                console.error('WebSocket connection error:', error);
                showStatus('Failed to connect to chat server. Please refresh the page.', 'error');
                reject(error);
            });
        } catch (error) {
            console.error('Error creating WebSocket connection:', error);
            showStatus('Failed to initialize chat. Please refresh the page.', 'error');
            reject(error);
        }
    });
}

// Load contacts (friends)
async function loadContacts() {
    try {
        const response = await fetch(`${API_BASE_URL}/friends`, {
            headers: {
                'Authorization': `Bearer ${currentUser.token}`
            }
        });
        
        if (response.ok) {
            const friends = await response.json();
            if (friends && friends.length > 0) {
                displayContacts(friends);
            } else {
                document.getElementById('contactsList').innerHTML = 
                    '<div style="padding: 20px; text-align: center; color: #999;">No contacts found. Add friends to start chatting!</div>';
            }
        } else if (response.status === 401) {
            showStatus('Session expired. Please login again.', 'error');
            setTimeout(() => {
                window.location.href = 'sign-registration.html';
            }, 2000);
        } else {
            const errorText = await response.text();
            console.error('Failed to load contacts:', errorText);
            showStatus('Failed to load contacts: ' + (errorText || response.statusText), 'error');
        }
    } catch (error) {
        console.error('Error loading contacts:', error);
        showStatus('Error loading contacts: ' + error.message, 'error');
    }
}

// Display contacts
function displayContacts(contacts) {
    const container = document.getElementById('contactsList');
    container.innerHTML = '';
    
    if (contacts.length === 0) {
        container.innerHTML = '<div style="padding: 20px; text-align: center; color: #999;">No contacts found</div>';
        return;
    }
    
    contacts.forEach(contact => {
        const contactDiv = document.createElement('div');
        contactDiv.className = 'contact-item';
        contactDiv.innerHTML = `
            <div>
                <div class="contact-name">${contact.name || contact.email}</div>
                <div style="font-size: 12px; color: #666;">${contact.email}</div>
            </div>
            <div class="contact-actions">
                <button class="btn-call" onclick="startVideoCall('${contact.email}')">📹 Call</button>
            </div>
        `;
        contactDiv.onclick = () => selectContact(contact);
        container.appendChild(contactDiv);
    });
}

// Select contact
function selectContact(contact) {
    currentContact = contact;
    document.getElementById('chatWithName').textContent = contact.name || contact.email;
    document.getElementById('messageInput').disabled = false;
    document.getElementById('sendBtn').disabled = false;
    
    // Update active state
    document.querySelectorAll('.contact-item').forEach(item => {
        item.classList.remove('active');
    });
    if (event && event.currentTarget) {
        event.currentTarget.classList.add('active');
    }
    
    // Load conversation
    loadConversation(contact.email);
}

// Global function for call button
window.startVideoCall = function(receiverEmail) {
    if (!stompClient || !stompClient.connected) {
        showStatus('Not connected to server. Please refresh the page.', 'error');
        return;
    }
    startVideoCall(receiverEmail);
};

// Load conversation
async function loadConversation(otherUserEmail) {
    try {
        const response = await fetch(
            `${API_BASE_URL}/messages/conversation?user1=${encodeURIComponent(currentUser.email)}&user2=${encodeURIComponent(otherUserEmail)}`,
            {
                headers: {
                    'Authorization': `Bearer ${currentUser.token}`
                }
            }
        );
        
        if (response.ok) {
            const messages = await response.json();
            if (messages && messages.length > 0) {
                displayMessages(messages);
            } else {
                document.getElementById('chatMessages').innerHTML = 
                    '<div style="text-align: center; color: #999; padding: 40px;">No messages yet. Start the conversation!</div>';
            }
        } else if (response.status === 401) {
            showStatus('Session expired. Please login again.', 'error');
        } else {
            console.error('Failed to load conversation:', response.statusText);
        }
    } catch (error) {
        console.error('Error loading conversation:', error);
        showStatus('Error loading conversation: ' + error.message, 'error');
    }
}

// Display messages
function displayMessages(messages) {
    const container = document.getElementById('chatMessages');
    container.innerHTML = '';
    
    messages.forEach(msg => {
        const isSent = msg.sender?.email === currentUser.email;
        displayMessage(msg, isSent ? 'sent' : 'received');
    });
    
    container.scrollTop = container.scrollHeight;
}

// Display single message
function displayMessage(message, type) {
    const container = document.getElementById('chatMessages');
    const messageDiv = document.createElement('div');
    messageDiv.className = `message ${type}`;
    
    const time = new Date(message.timestamp).toLocaleTimeString();
    messageDiv.innerHTML = `
        <div class="message-bubble">${message.content || '[Media]'}</div>
        <div class="message-time">${time}</div>
    `;
    
    container.appendChild(messageDiv);
    container.scrollTop = container.scrollHeight;
}

// Setup event listeners
function setupEventListeners() {
    document.getElementById('sendBtn').addEventListener('click', sendMessage);
    document.getElementById('messageInput').addEventListener('keypress', (e) => {
        if (e.key === 'Enter') {
            sendMessage();
        }
    });
    
    document.getElementById('endCallBtn').addEventListener('click', endCall);
    document.getElementById('muteBtn').addEventListener('click', toggleMute);
    document.getElementById('videoToggleBtn').addEventListener('click', toggleVideo);
}

// Send message
async function sendMessage() {
    const input = document.getElementById('messageInput');
    const content = input.value.trim();
    
    if (!content || !currentContact) {
        showStatus('Please select a contact first', 'error');
        return;
    }
    
    const message = {
        content: content,
        type: 'TEXT',
        sender: { email: currentUser.email },
        receiver: { email: currentContact.email }
    };
    
    // Display message immediately (optimistic UI)
    const tempMessage = {
        ...message,
        timestamp: new Date().toISOString()
    };
    displayMessage(tempMessage, 'sent');
    
    // Clear input immediately
    input.value = '';
    
    // Try to send via WebSocket if connected
    if (stompClient && stompClient.connected) {
        try {
            stompClient.send('/app/chat.send', {}, JSON.stringify(message));
        } catch (wsError) {
            console.error('WebSocket send failed:', wsError);
        }
    }
    
    // Always send via REST API as primary/backup method
    try {
        const response = await fetch(`${API_BASE_URL}/messages/send`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${currentUser.token}`
            },
            body: JSON.stringify(message)
        });
        
        if (!response.ok) {
            if (response.status === 401) {
                showStatus('Session expired. Please login again.', 'error');
            } else {
                const errorText = await response.text();
                showStatus('Failed to send message: ' + (errorText || response.statusText), 'error');
            }
        } else {
            // Reload conversation to get the saved message
            loadConversation(currentContact.email);
        }
    } catch (apiError) {
        console.error('REST API send failed:', apiError);
        showStatus('Failed to send message: ' + apiError.message, 'error');
    }
}

// Start video call
async function startVideoCall(receiverEmail) {
    if (isInCall) {
        showStatus('Already in a call', 'error');
        return;
    }
    
    currentContact = { email: receiverEmail };
    isInCall = true;
    
    // Show call modal
    document.getElementById('videoCallModal').classList.add('active');
    document.getElementById('callingIndicator').textContent = `Calling ${receiverEmail}...`;
    
    try {
        // Get user media
        localStream = await navigator.mediaDevices.getUserMedia({
            video: true,
            audio: true
        });
        
        document.getElementById('localVideo').srcObject = localStream;
        
        // Create peer connection
        peerConnection = new RTCPeerConnection(rtcConfiguration);
        
        // Add local stream tracks
        localStream.getTracks().forEach(track => {
            peerConnection.addTrack(track, localStream);
        });
        
        // Handle remote stream
        peerConnection.ontrack = (event) => {
            remoteStream = event.streams[0];
            document.getElementById('remoteVideo').srcObject = remoteStream;
            document.getElementById('remoteVideoLabel').textContent = receiverEmail;
        };
        
        // Handle ICE candidates
        peerConnection.onicecandidate = (event) => {
            if (event.candidate) {
                sendIceCandidate(receiverEmail, event.candidate);
            }
        };
        
        // Create and send offer
        const offer = await peerConnection.createOffer();
        await peerConnection.setLocalDescription(offer);
        
        stompClient.send('/app/call.offer', {}, JSON.stringify({
            callerEmail: currentUser.email,
            receiverEmail: receiverEmail,
            offer: offer
        }));
        
    } catch (error) {
        console.error('Error starting call:', error);
        showStatus('Failed to start call: ' + error.message, 'error');
        endCall();
    }
}

// Handle incoming call
async function handleIncomingCall(data) {
    const callerEmail = data.callerEmail;
    const offer = data.offer;
    
    const accept = confirm(`${callerEmail} is calling you. Accept?`);
    
    if (!accept) {
        // Reject call
        stompClient.send('/app/call.reject', {}, JSON.stringify({
            callerEmail: callerEmail,
            receiverEmail: currentUser.email
        }));
        return;
    }
    
    isInCall = true;
    currentContact = { email: callerEmail };
    
    // Show call modal
    document.getElementById('videoCallModal').classList.add('active');
    document.getElementById('callingIndicator').textContent = `In call with ${callerEmail}`;
    
    try {
        // Get user media
        localStream = await navigator.mediaDevices.getUserMedia({
            video: true,
            audio: true
        });
        
        document.getElementById('localVideo').srcObject = localStream;
        
        // Create peer connection
        peerConnection = new RTCPeerConnection(rtcConfiguration);
        
        // Add local stream tracks
        localStream.getTracks().forEach(track => {
            peerConnection.addTrack(track, localStream);
        });
        
        // Handle remote stream
        peerConnection.ontrack = (event) => {
            remoteStream = event.streams[0];
            document.getElementById('remoteVideo').srcObject = remoteStream;
            document.getElementById('remoteVideoLabel').textContent = callerEmail;
        };
        
        // Handle ICE candidates
        peerConnection.onicecandidate = (event) => {
            if (event.candidate) {
                sendIceCandidate(callerEmail, event.candidate);
            }
        };
        
        // Set remote description and create answer
        await peerConnection.setRemoteDescription(new RTCSessionDescription(offer));
        const answer = await peerConnection.createAnswer();
        await peerConnection.setLocalDescription(answer);
        
        // Send answer
        stompClient.send('/app/call.answer', {}, JSON.stringify({
            callerEmail: callerEmail,
            receiverEmail: currentUser.email,
            answer: answer
        }));
        
    } catch (error) {
        console.error('Error accepting call:', error);
        showStatus('Failed to accept call: ' + error.message, 'error');
        endCall();
    }
}

// Handle call answer
async function handleCallAnswer(data) {
    const answer = data.answer;
    
    try {
        await peerConnection.setRemoteDescription(new RTCSessionDescription(answer));
        document.getElementById('callingIndicator').textContent = 'Connected';
    } catch (error) {
        console.error('Error handling answer:', error);
        showStatus('Failed to establish connection', 'error');
        endCall();
    }
}

// Send ICE candidate
function sendIceCandidate(receiverEmail, candidate) {
    stompClient.send('/app/call.ice-candidate', {}, JSON.stringify({
        senderEmail: currentUser.email,
        receiverEmail: receiverEmail,
        candidate: candidate
    }));
}

// Handle ICE candidate
async function handleIceCandidate(data) {
    try {
        await peerConnection.addIceCandidate(new RTCIceCandidate(data.candidate));
    } catch (error) {
        console.error('Error adding ICE candidate:', error);
    }
}

// Handle call end
function handleCallEnd(data) {
    endCall();
    showStatus('Call ended', 'info');
}

// Handle call reject
function handleCallReject(data) {
    endCall();
    showStatus('Call was rejected', 'info');
}

// End call
function endCall() {
    isInCall = false;
    
    // Stop all tracks
    if (localStream) {
        localStream.getTracks().forEach(track => track.stop());
        localStream = null;
    }
    
    if (remoteStream) {
        remoteStream.getTracks().forEach(track => track.stop());
        remoteStream = null;
    }
    
    // Close peer connection
    if (peerConnection) {
        peerConnection.close();
        peerConnection = null;
    }
    
    // Clear video elements
    document.getElementById('localVideo').srcObject = null;
    document.getElementById('remoteVideo').srcObject = null;
    
    // Hide modal
    document.getElementById('videoCallModal').classList.remove('active');
    
    // Notify other party
    if (currentContact) {
        stompClient.send('/app/call.end', {}, JSON.stringify({
            callerEmail: currentUser.email,
            receiverEmail: currentContact.email,
            endedBy: currentUser.email
        }));
    }
}

// Toggle mute
function toggleMute() {
    if (localStream) {
        isMuted = !isMuted;
        localStream.getAudioTracks().forEach(track => {
            track.enabled = !isMuted;
        });
        document.getElementById('muteIcon').textContent = isMuted ? '🔇' : '🔊';
    }
}

// Toggle video
function toggleVideo() {
    if (localStream) {
        isVideoEnabled = !isVideoEnabled;
        localStream.getVideoTracks().forEach(track => {
            track.enabled = isVideoEnabled;
        });
        document.getElementById('videoIcon').textContent = isVideoEnabled ? '📹' : '📵';
    }
}

// Show status message
function showStatus(message, type) {
    const statusDiv = document.getElementById('statusMessage');
    if (!statusDiv) return;
    
    statusDiv.className = `status-message ${type}`;
    statusDiv.textContent = message;
    statusDiv.style.display = 'block';
    
    setTimeout(() => {
        statusDiv.style.display = 'none';
    }, 5000);
}

// Cleanup on page unload
window.addEventListener('beforeunload', () => {
    if (stompClient) {
        stompClient.send('/app/user.offline', {}, currentUser.email);
        stompClient.disconnect();
    }
    endCall();
});

