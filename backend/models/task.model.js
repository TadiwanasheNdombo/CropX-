const mongoose = require('mongoose');

const TaskSchema = new mongoose.Schema({
  name: { 
    type: String, 
    required: true,
    trim: true
  },
  dueDate: { 
    type: String,
    required: true
  },
  description: { 
    type: String,
    default: ''
  },
  resources: { 
    type: [String],
    default: [] 
  },
  isCompleted: { 
    type: Boolean, 
    default: false 
  }
}, { timestamps: true }); // Adds createdAt and updatedAt automatically

module.exports = mongoose.model('Task', TaskSchema);