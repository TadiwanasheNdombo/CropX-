const express = require('express');
const router = express.Router();
const assistantController = require('../controllers/assistantController');
const auth = require('../middlewares/auth');

router.use(auth); // Protect all assistant routes

router.post('/chat', assistantController.sendMessage);
router.get('/conversation', assistantController.getConversation);

module.exports = router;