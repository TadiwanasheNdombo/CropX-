const { GoogleGenerativeAI } = require('@google/generative-ai');

// Configuration
const GEMINI_API_KEY = process.env.GEMINI_API_KEY || "AIzaSyCsD2tuKRLOa9qDnSCR4_jXBCfENHJBQNU";
const MODEL_NAME = 'gemini-1.5-flash';
const MAX_RETRIES = 3;
const TIMEOUT_MS = 30000; // 30 seconds

// Initialize with enhanced options
const genAI = new GoogleGenerativeAI(GEMINI_API_KEY, {
  timeout: TIMEOUT_MS,
});

const model = genAI.getGenerativeModel({ 
  model: MODEL_NAME,
  generationConfig: {
    maxOutputTokens: 1000,
    temperature: 0.7,
  },
  safetySettings: [
    {
      category: "HARM_CATEGORY_DANGEROUS_CONTENT",
      threshold: "BLOCK_NONE",
    },
  ],
});

async function generateResponse(prompt) {
  const systemPrompt = `
    You are FarmAI, an agricultural assistant specialized in maize farming. 
    Provide concise, practical advice to farmers with these guidelines:
    
    1. Focus specifically on maize/corn cultivation
    2. Use simple language (primary school level)
    3. Prioritize cost-effective methods
    4. Recommend sustainable practices
    5. Assume tropical climate if not specified
    6. Provide actionable steps
    7. Keep responses under 300 words
  `;

  for (let attempt = 1; attempt <= MAX_RETRIES; attempt++) {
    try {
      const result = await Promise.race([
        model.generateContent({
          contents: [{
            role: "user",
            parts: [{ text: `${systemPrompt}\n\nQuestion: ${prompt}` }],
          }],
        }),
        new Promise((_, reject) => 
          setTimeout(() => reject(new Error('Request timeout')), TIMEOUT_MS)
        )
      ]);

      const response = await result.response;
      return response.text().trim();
      
    } catch (error) {
      console.error(`Attempt ${attempt} failed:`, error.message);
      
      if (attempt === MAX_RETRIES) {
        console.error('Final attempt failed, returning fallback response');
        return getFallbackResponse(prompt);
      }
      
      // Exponential backoff
      await new Promise(resolve => 
        setTimeout(resolve, 1000 * Math.pow(2, attempt))
      );
    }
  }
}

function getFallbackResponse(prompt) {
  const fallbacks = [
    "I'm currently unable to access farming advice. Please try again later.",
    "Our maize farming experts are busy. For immediate help, contact your local agricultural extension officer.",
    "Network issues prevent me from responding. Here's a general tip: Ensure proper soil preparation before planting maize.",
    "I can't respond right now. Remember to test your soil pH before applying fertilizers."
  ];
  return fallbacks[Math.floor(Math.random() * fallbacks.length)];
}

module.exports = { generateResponse };