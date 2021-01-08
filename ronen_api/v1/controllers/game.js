const { validationResult } = require('express-validator')
const formidable = require('formidable')
const admin = require('firebase-admin')
const uuid = require('uuid')

exports.addGame = (req, res, next) => {
    const errors = validationResult(req)
    if (!errors.isEmpty()) {
        return next({
            statusCode: 400,
            message: 'Invalid params',
            error: errors.array()
        })
    }

    const form = new formidable.IncomingForm()

    form.parse(req, (err, fields, files) => {
        if (err) {
            return next({
                statusCode: 500,
                message: 'Error parsing request',
                error: err
            })
        }

        if (fields.name === undefined || fields.description === undefined ||
            files.coverImage === undefined || new Date(fields.release_date).toString() === 'Invalid Date') {
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
                        cover: {
                            imageUrl: val[0],
                            imageId: imageId
                        },
                        date_created: admin.firestore.Timestamp.now(),
                        release_date: admin.firestore.Timestamp.fromDate(
                            new Date(fields.release_date))
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

exports.listGames = async (req, res, next) => {
    const orderBy = req.query.order_by
    const lastVisibleGameId = req.query.last_visible_id
    let limit = req.query.limit
    const direction = req.query.direction

    if (direction !== undefined) {
        if (direction !== 'asc' && direction !== 'desc') {
            return next({
                statusCode: 400,
                message: 'direction parameter must be either asc or desc'
            })
        }
    }

    limit = isNaN(parseInt(limit)) === false ? parseInt(limit) : 10
    let lastVisibleDoc
    if (lastVisibleGameId !== undefined) {
        lastVisibleDoc = await admin.firestore().collection('games').doc(lastVisibleGameId).get()
        if (lastVisibleDoc.exists === false) {
            next({
                statusCode: 400,
                message: 'DocumentId does not exist'
            })
        }
    } else {
        const queryTemp = await admin.firestore().collection('games')
            .orderBy(orderBy || 'date_created', direction || 'desc').limit(1).get()
        lastVisibleDoc = queryTemp.docs[0]
    }

    admin.firestore().collection('games')
        .orderBy(orderBy || 'date_created', direction || 'desc')
        .startAt(lastVisibleDoc)
        .limit(lastVisibleGameId ? limit + 1 : limit)
        .get().then(qurySnap => {
            const games = []
            qurySnap.docs.forEach(doc => {
                if (doc.id !== lastVisibleGameId) {
                    games.push(Object.assign(doc.data(), { gameId: doc.id }))
                }
            })
            res.status(200).json({
                successful: true,
                data: {
                    lenght: games.length,
                    games: games
                }
            })
        })
}
