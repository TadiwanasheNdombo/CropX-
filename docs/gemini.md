Skip to main content
Google AI for Developers
Models

Solutions
Code assistance
More
Search
/


English

Tadiwanashe
Gemini API docs
API Reference
Cookbook

Gemini 2.5 Pro Preview is now available for production use! Learn more
Home
Gemini API
Models

Gemini Developer API
Get a Gemini API Key
Get a Gemini API key and make your first API request in minutes.

Python
JavaScript
Go
REST

import { GoogleGenAI } from "@google/genai";

const ai = new GoogleGenAI({ apiKey: "YOUR_API_KEY" });

async function main() {
  const response = await ai.models.generateContent({
    model: "gemini-2.0-flash",
    contents: "Explain how AI works in a few words",
  });
  console.log(response.text);
}

await main();
Meet the models
Use Gemini in Google AI Studio

2.5 Pro 

Our most powerful thinking model with features for complex reasoning and much more

2.5 Flash 

Our newest multimodal model, with next generation features and improved capabilities

2.0 Flash-Lite 

Our fastest and most cost-efficient multimodal model with great performance for high-frequency tasks

Explore the API

Native Image Generation
Generate and edit highly contextual images natively with Gemini 2.0 Flash.


Explore long context
Input millions of tokens to Gemini models and derive understanding from unstructured images, videos, and documents.


Generate structured outputs
Constrain Gemini to respond with JSON, a structured data format suitable for automated processing.

Start building with the Gemini API
Get started
Except as otherwise noted, the content of this page is licensed under the Creative Commons Attribution 4.0 License, and code samples are licensed under the Apache 2.0 License. For details, see the Google Developers Site Policies. Java is a registered trademark of Oracle and/or its affiliates.

Last updated 2025-04-22 UTC.

Terms
Privacy

English
