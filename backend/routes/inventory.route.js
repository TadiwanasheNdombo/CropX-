// routes/inventory.route.js
const express = require('express');
const Inventory = require('../models/inventory.model');
const router = express.Router();

// Create a new inventory item
router.post('/', async (req, res) => {
    try {
        const newItem = new Inventory(req.body);
        const savedItem = await newItem.save();
        res.status(201).json(savedItem);

        return;
    } catch (err) {
        console.error(err);
        res.status(400).json({ message: 'Error creating inventory item', error: err });

        return;
    }
});

// Get all inventory items
router.get('/', async (req, res) => {
    try {
        const items = await Inventory.find();
        res.json(items);

        return;
    } catch (err) {
        console.error(err);
        res.status(500).json({ message: 'Error retrieving inventory items', error: err });
    }
});

// Update an inventory item
router.put('/:id', async (req, res) => {
    try {
        const updatedItem = await Inventory.findByIdAndUpdate(req.params.id, req.body, { new: true });
        res.json(updatedItem);
        return; // Add return statement here
    } catch (err) {
        console.error(err);
        res.status(400).json({ message: 'Error updating inventory item', error: err });
        return; // Add return statement here
    }
});

// Delete an inventory item
router.delete('/:id', async (req, res) => {
    try {
        await Inventory.findByIdAndDelete(req.params.id);
        res.status(204).send(); // No content
        return; // Add return statement here
    } catch (err) {
        console.error(err);
        res.status(400).json({ message: 'Error deleting inventory item', error: err });
        return; // Add return statement here
    }
});

module.exports = router;