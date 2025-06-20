const Conversation = require('../models/conversation');
const { generateResponse } = require('../config/gemini');
const mongoose = require('mongoose');

// Configuration
const AI_RESPONSE_TIMEOUT = 20000; // 20 seconds
const MAX_RETRIES = 2;
const RETRY_DELAY_MS = 1000;

exports.sendMessage = async (req, res) => {
  const { message } = req.body;
  const userId = req.user._id;

  // Validate userId
  if (!userId || !mongoose.Types.ObjectId.isValid(userId)) {
    return res.status(401).json({
      success: false,
      error: 'User authentication required'
    });
  }

  // Input validation
  if (!message?.trim()) {
    return res.status(400).json({
      success: false,
      error: 'Message is required'
    });
  }

  const timeoutPromise = new Promise((_, reject) => 
    setTimeout(() => reject(new Error('Operation timed out')), 25000)
  );

  try {
    // Find or create conversation with proper ObjectId
    let conversation = await Conversation.findOne({ 
      userId: new mongoose.Types.ObjectId(userId)
    });
    
    if (!conversation) {
      conversation = new Conversation({
        userId: new mongoose.Types.ObjectId(userId),
        messages: []
      });
    }

    // Add user message
    conversation.messages.push({
      text: message.trim(),
      sender: 'user',
      timestamp: new Date()
    });

    // Get AI response with retry logic
    let aiResponse;
    let lastError;
    
    for (let attempt = 0; attempt <= MAX_RETRIES; attempt++) {
      try {
        aiResponse = await Promise.race([
          generateResponse(message),
          timeoutPromise
        ]);
        break; // Success - exit retry loop
      } catch (error) {
        lastError = error;
        console.error(`Attempt ${attempt + 1} failed:`, error.message);
        
        if (attempt < MAX_RETRIES) {
          await new Promise(resolve => setTimeout(resolve, RETRY_DELAY_MS * (attempt + 1)));
        }
      }
    }

    if (!aiResponse) {
      throw lastError || new Error('Failed to get AI response');
    }

    // Add AI response
    conversation.messages.push({
      text: aiResponse,
      sender: 'ai',
      timestamp: new Date()
    });

    await conversation.save();

    res.json({
      success: true,
      response: aiResponse,
      messageId: conversation.messages.slice(-1)[0]._id
    });

  } catch (error) {
    console.error('Assistant error:', error);
    
    const status = 
      error.message.includes('timeout') ? 504 :
      error.message.includes('AI service') ? 503 :
      500;
      
    res.status(status).json({
      success: false,
      error: getFriendlyErrorMessage(error),
      ...(process.env.NODE_ENV === 'development' && { stack: error.stack })
    });
  }
};

exports.getConversation = async (req, res) => {
  const userId = req.user._id;

  try {
    const conversation = await Conversation.findOne({ userId })
      .sort({ updatedAt: -1 })
      .lean();

    res.json({
      success: true,
      messages: conversation?.messages || [],
      lastUpdated: conversation?.updatedAt
    });
  } catch (error) {
    console.error('Conversation fetch error:', error);
    res.status(500).json({
      success: false,
      error: 'Failed to load conversation history',
      ...(process.env.NODE_ENV === 'development' && { details: error.message })
    });
  }
};

// Helper functions
function getFriendlyErrorMessage(error) {
  if (error.message.includes('timeout')) {
    return 'Our assistant is taking longer than usual to respond. Please try again.';
  }
  if (error.message.includes('AI service')) {
    return 'Our AI service is currently unavailable. Please try again later.';
  }
  return 'An error occurred while processing your message.';
}