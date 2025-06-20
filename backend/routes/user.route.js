const express = require('express');
const User = require('../models/user.model');
const bcrypt = require('bcrypt');
const router = express.Router();
const { createAccessToken } = require('../utils');

// Helper function for validation
const validateInput = (req, res, next) => {
  const { username, password, email } = req.body;
  
  // Basic validation checks
  const errors = [];
  
  if (!username || username.length < 3) {
    errors.push('Username must be at least 3 characters');
  }
  
  if (req.path === '/signup') {
    if (!email || !email.includes('@')) {
      errors.push('Invalid email address');
    }
    if (!password || password.length < 6) {
      errors.push('Password must be at least 6 characters');
    }
  } else {
    if (!password) {
      errors.push('Password is required');
    }
  }
  
  if (errors.length > 0) {
    return res.status(400).json({
      success: false,
      errors,
      message: 'Validation failed'
    });
  }
  
  next();
};

// Signup route
router.post('/signup', validateInput, async (req, res) => {
  try {
    const { username, email, password } = req.body;

    // Check for existing user
    const existingUser = await User.findOne({ 
      $or: [
        { username },
        { email }
      ]
    });
    
    if (existingUser) {
      return res.status(409).json({ 
        success: false,
        message: existingUser.username === username 
          ? 'Username is not available' 
          : 'Email is already registered'
      });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);
    
    // Create new user
    const newUser = new User({
      username,
      email,
      password: hashedPassword
    });

    const savedUser = await newUser.save();
    
    // Generate token
    const accessToken = await createAccessToken({
      _id: savedUser._id,
      username: savedUser.username,
      email: savedUser.email
    });

    // Prepare response
    const userResponse = {
      _id: savedUser._id,
      username: savedUser.username,
      email: savedUser.email,
      createdAt: savedUser.createdAt
    };

    res.status(201).json({
      success: true,
      message: 'User created successfully',
      user: userResponse,
      accessToken
    });

  } catch (err) {
    console.error('Signup error:', err);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
});

// Signin route
router.post('/signin', validateInput, async (req, res) => {
  try {
    const { username, password } = req.body;

    // Find user
    const user = await User.findOne({ username }).select('+password');
    if (!user) {
      return res.status(401).json({ 
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Compare passwords
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ 
        success: false,
        message: 'Invalid credentials'
      });
    }

    // Generate token
    const accessToken = await createAccessToken({
      _id: user._id,
      username: user.username,
      email: user.email
    });

    // Prepare response
    const userResponse = {
      _id: user._id,
      username: user.username,
      email: user.email,
      createdAt: user.createdAt
    };

    res.json({
      success: true,
      message: 'Login successful',
      user: userResponse,
      accessToken
    });

  } catch (err) {
    console.error('Signin error:', err);
    res.status(500).json({
      success: false,
      message: 'Internal server error',
      error: process.env.NODE_ENV === 'development' ? err.message : undefined
    });
  }
});

module.exports = router;