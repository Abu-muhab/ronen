const express = require('express')
const router = express.Router()
const userRoute = require('./user')
const gameRoute = require('./game')

router.use('/user', userRoute)

router.use('/game', gameRoute)

module.exports = router
