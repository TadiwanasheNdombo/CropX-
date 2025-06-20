const express = require('express');
const mongoose = require('mongoose');
const router = express.Router();
const Task = require('../models/task.model');


// Middleware to validate MongoDB ID format
const validateObjectId = (req, res, next) => {
  if (!mongoose.Types.ObjectId.isValid(req.params.id)) {
    return res.status(400).json({ message: 'Invalid task ID format' });
  }
  next();
};

// Get all tasks
router.get('/', async (req, res, next) => {
  try {
    const tasks = await Task.find().sort({ createdAt: -1 }); // Newest first
    res.json(tasks);
  } catch (err) {
    next(err);
  }
});

// Create a new task
router.post('/', async (req, res, next) => {
  try {
    // Generate a new ObjectId if not provided
    if (!req.body._id) {
      req.body._id = new mongoose.Types.ObjectId();
    }
    
    const newTask = new Task(req.body);
    const savedTask = await newTask.save();
    res.status(201).json(savedTask);
  } catch (err) {
    if (err.name === 'ValidationError') {
      return res.status(400).json({ 
        message: 'Validation Error',
        details: err.errors 
      });
    }
    next(err);
  }
});

// Update a task
router.put('/:id', validateObjectId, async (req, res, next) => {
  try {
    const updatedTask = await Task.findByIdAndUpdate(
      req.params.id,
      req.body,
      { 
        new: true,
        runValidators: true,
        context: 'query' // Ensures proper validation
      }
    );

    if (!updatedTask) {
      return res.status(404).json({ message: 'Task not found' });
    }

    res.json(updatedTask);
  } catch (err) {
    if (err.name === 'CastError') {
      return res.status(400).json({ message: 'Invalid task ID' });
    }
    if (err.name === 'ValidationError') {
      return res.status(400).json({ 
        message: 'Validation Error',
        details: err.errors 
      });
    }
    next(err);
  }
});

// Delete a task
router.delete('/:id', validateObjectId, async (req, res, next) => {
  try {
    const deletedTask = await Task.findByIdAndDelete(req.params.id);
    
    if (!deletedTask) {
      return res.status(404).json({ message: 'Task not found' });
    }

    res.status(204).send();
  } catch (err) {
    if (err.name === 'CastError') {
      return res.status(400).json({ message: 'Invalid task ID' });
    }
    next(err);
  }
});

// Error handling middleware (should be used in your app.js)
router.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({ message: 'Something went wrong!' });
});

module.exports = router;