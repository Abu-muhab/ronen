const express = require('express')
const router = express.Router()
const gameController = require('../controllers/game')
const { body } = require('express-validator')

router.post('/add', gameController.addGame)

router.get('/listGames', gameController.listGames)

module.exports = router
