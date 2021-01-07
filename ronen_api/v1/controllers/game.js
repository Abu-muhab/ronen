const { validationResult } = require('express-validator')
const formidable = require('formidable')
const admin = require('firebase-admin')
const uuid = require('uuid')
exports.addGame = (req, res, next) => {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
        return next({
            statusCode: 500,
            message: 'Invalid params',
            error: errors.array()
        })
    }

    const form = new formidable.IncomingForm()

    form.parse(req, (err, fields, files) => {
        if (err) {
            return next({
                statusCode: 400,
                message: 'Error parsing request',
                error: err
            })
        }

        if (fields.name === undefined || fields.description === undefined || files.coverImage === undefined) {
            return next({
                statusCode: 400,
                message: 'Invalid params'
            })
        }

        if (files.coverImage.type === 'image/png' || files.coverImage.type === 'image/jpg' || files.coverImage.type === 'image/jpeg') {
            const imageId = uuid.v4()
            return admin.storage().bucket('gs://ronen-14b2a.appspot.com').upload(files.coverImage.path, {
                metadata: {
                    contentType: files.coverImage.type,
                    metadata: {
                        firebaseStorageDownloadTokens: imageId
                    }
                },
                destination: `coverImages/${imageId}`
            }).then((val) => {
                val[0].getSignedUrl({
                    expires: '12-12-3000',
                    action: 'read'
                }).then(val => {
                    const data = {
                        name: fields.name,
                        description: fields.description,
                        coverImage: val[0]
                    }
                    admin.firestore().collection('games').doc().set(data).then(val => {
                        res.status(201).json({
                            successful: true,
                            message: 'Game added successfully',
                            data: data
                        })
                    })
                })
            })
        }
        next({
            statusCode: 400,
            message: 'File must be an image'
        })
    })
}
