/**
 * GameChat Module
 * Handles chat message rendering for the game room
 * XSS-safe implementation using textContent only
 */
(function() {
  'use strict';

  // XSS-safe HTML escape function (backup, but we use textContent)
  function escapeHtml(str) {
    if (typeof str !== 'string') return '';
    return str.replace(/&/g, '&amp;')
              .replace(/</g, '&lt;')
              .replace(/>/g, '&gt;')
              .replace(/"/g, '&quot;')
              .replace(/'/g, '&#039;');
  }

  /**
   * Append a chat message to the chat log
   * @param {Object} payload - Message payload with structure:
   *   - { sender, message } or
   *   - { data: { sender, message } }
   */
  function appendChatMessage(payload) {
    // Find chat log container (priority order)
    const chatLog = document.getElementById("chatLog") ||
                    document.getElementById("chatScroll");

    if (!chatLog) {
      console.warn("GameChat: No chat log container found (#chatLog or #chatScroll)");
      return;
    }

    // Extract sender and message from payload
    let sender = "Unknown";
    let message = "";

    // Handle both { sender, message } and { data: { sender, message } } structures
    if (payload.data && typeof payload.data === 'object') {
      sender = payload.data.sender || "Unknown";
      message = payload.data.message || "";
    } else {
      sender = payload.sender || "Unknown";
      message = payload.message || "";
    }

    // Create chat message element
    const chatDiv = document.createElement("div");

    // Create sender span (XSS-safe using textContent)
    const senderSpan = document.createElement("span");
    senderSpan.style.color = "#1976d2";
    senderSpan.textContent = sender + ":";

    // Create message text node (XSS-safe)
    const messageText = document.createTextNode(" " + message);

    // Append to chat div
    chatDiv.appendChild(senderSpan);
    chatDiv.appendChild(messageText);

    // Append to chat log
    chatLog.appendChild(chatDiv);

    // Auto-scroll to bottom
    chatLog.scrollTop = chatLog.scrollHeight;
  }

  // Export to global namespace
  window.GameChat = {
    append: appendChatMessage
  };

  console.log("GameChat module loaded");
})();
