const express = require('express')
const admin = require('firebase-admin')
const bodyParser = require('body-parser')
const serviceAccount = require('./ronen-14b2a-firebase-adminsdk-bkywl-be8008144d.json')
const apiV1Router = require('./v1/routes/base')

const app = express()

admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
})

app.use(bodyParser.json())

app.use('/api/v1', apiV1Router)

app.use('*', (req, res) => {
    res.send('You seem to be lost, young one')
})

app.use((err, req, res, next) => {
    return res.status(err.statusCode).json({
        successful: false,
        message: err.message,
        error: err.error
    })
})

app.listen(8080, '192.168.43.91')
