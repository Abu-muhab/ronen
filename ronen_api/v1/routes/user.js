const express = require('express')
const router = express.Router()

router.get('/test', (req, res, next) => {
    res.json({
        message: 'it works!'
    })
})

module.exports = router
